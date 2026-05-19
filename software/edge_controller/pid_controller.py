"""
============================================================
 Smart Agri-Togo — PID Baseline Controller
 File   : software/edge_controller/pid_controller.py
 Author : Ounimborbitibou DJABON

 Role in the research experiment:
   Treatment T1 in the 5×5 field trial.
   The PID provides a simpler, model-free baseline against
   which MPC performance is compared (water saved, yield gain).

 PID equation (discrete time):
   e^k       = θ* - θ^k              (error: moisture deficit)
   I_P^k     = Kp · e^k              (proportional)
   I_I^k     = I_I^{k-1} + Ki·Δt·e^k (integral — anti-windup)
   I_D^k     = Kd · (e^k - e^{k-1})/Δt (derivative)
   I^k       = clip(I_P + I_I + I_D, 0, I_max)

 One PID instance per row (5 independent PID controllers).
 No coordination between rows (contrast with MPC which handles
 the pump capacity constraint jointly across all rows).
============================================================
"""

import time
import logging
import numpy as np
from typing import List

log = logging.getLogger("pid")

# ── Import config ─────────────────────────────────────────────
try:
    from config import (
        N_CELLS, N_ROWS, N_COLS,
        MPC_THETA_TARGET, IRR_RATE_MAX_MMH, MPC_DT_MIN
    )
except ImportError:
    N_CELLS           = 25
    N_ROWS            = 5
    N_COLS            = 5
    MPC_THETA_TARGET  = 0.20
    IRR_RATE_MAX_MMH  = 3.0
    MPC_DT_MIN        = 30

# ── Default PID gains (tune after first season of data) ───────
# These initial values are derived from the Ziegler-Nichols method
# applied to the linearised soil water balance with τ ≈ 48h.
# Kp: proportional gain [mm/h per m³/m³ deficit]
# Ki: integral gain [mm/h per m³/m³ per hour]
# Kd: derivative gain [mm·h per m³/m³]
DEFAULT_KP = 8.0
DEFAULT_KI = 0.05
DEFAULT_KD = 0.5


class RowPID:
    """
    Single PID controller for one crop row.

    Controls irrigation rate for all 5 cells in a row based on
    the row-average soil moisture, with anti-windup protection.
    """

    def __init__(
        self,
        row:        int,
        kp:         float = DEFAULT_KP,
        ki:         float = DEFAULT_KI,
        kd:         float = DEFAULT_KD,
        setpoint:   float = MPC_THETA_TARGET,
        i_max:      float = IRR_RATE_MAX_MMH,
        dt_h:       float = MPC_DT_MIN / 60.0,
    ):
        """
        Parameters
        ----------
        row      : row index 0–4 (for logging)
        kp, ki, kd : PID gains
        setpoint : target soil moisture θ* [m³/m³]
        i_max    : maximum irrigation rate [mm/h]
        dt_h     : time step [hours]
        """
        self.row      = row
        self.kp       = kp
        self.ki       = ki
        self.kd       = kd
        self.setpoint = setpoint
        self.i_max    = i_max
        self.dt       = dt_h

        # Internal state
        self._integral  = 0.0    # accumulated integral term
        self._prev_error = None  # previous error for derivative
        self._prev_time  = None  # timestamp of last compute call

        # Anti-windup limits: integral cannot exceed these bounds
        self._i_min_clamp = -i_max / ki if ki > 0 else -100
        self._i_max_clamp =  i_max / ki if ki > 0 else  100

    def compute(self, moisture: float) -> float:
        """
        Compute PID irrigation rate for the current row moisture.

        Parameters
        ----------
        moisture : current row-average soil moisture [m³/m³]

        Returns
        -------
        I_row : irrigation rate [mm/h], clipped to [0, I_max]
        """
        error = self.setpoint - moisture

        # ── Proportional term ──────────────────────────────
        P = self.kp * error

        # ── Integral term with anti-windup ─────────────────
        self._integral += error * self.dt
        # Anti-windup: clamp integral to prevent overshoot
        self._integral = np.clip(
            self._integral, self._i_min_clamp, self._i_max_clamp
        )
        I_term = self.ki * self._integral

        # ── Derivative term ────────────────────────────────
        if self._prev_error is not None:
            D = self.kd * (error - self._prev_error) / self.dt
        else:
            D = 0.0  # no derivative on first call (avoids derivative kick)
        self._prev_error = error

        # ── Total PID output ───────────────────────────────
        I_pid = P + I_term + D

        # Clip: irrigation cannot be negative (can't remove water)
        # and cannot exceed valve capacity
        I_out = float(np.clip(I_pid, 0.0, self.i_max))

        log.debug(
            f"PID row {self.row}: θ={moisture:.3f}, e={error:+.3f}, "
            f"P={P:.3f} I={I_term:.3f} D={D:.3f} → I={I_out:.3f} mm/h"
        )
        return I_out

    def reset(self) -> None:
        """Reset PID internal state (use when switching setpoints)."""
        self._integral   = 0.0
        self._prev_error = None
        log.info(f"PID row {self.row} reset.")

    def set_gains(self, kp: float, ki: float, kd: float) -> None:
        """Update PID gains online (for adaptive tuning)."""
        self.kp, self.ki, self.kd = kp, ki, kd
        log.info(f"PID row {self.row} gains updated: Kp={kp}, Ki={ki}, Kd={kd}")


class PIDController:
    """
    5-row PID irrigation controller for Smart Agri-Togo.

    One RowPID instance per crop row. Each row is controlled
    independently based on its average moisture.

    This is Treatment T1 in the research experiment —
    the baseline against which MPC (Treatment T2) is compared.

    Example
    -------
    pid = PIDController()
    theta = np.array([...])         # shape (25,)
    I_opt = pid.compute(theta)      # shape (25,)
    valve_states = pid.to_valve_states(I_opt)
    """

    def __init__(
        self,
        kp:       float = DEFAULT_KP,
        ki:       float = DEFAULT_KI,
        kd:       float = DEFAULT_KD,
        setpoint: float = MPC_THETA_TARGET,
        i_max:    float = IRR_RATE_MAX_MMH,
        dt_h:     float = MPC_DT_MIN / 60.0,
    ):
        self.rows = [
            RowPID(row=r, kp=kp, ki=ki, kd=kd, setpoint=setpoint,
                   i_max=i_max, dt_h=dt_h)
            for r in range(N_ROWS)
        ]
        self.n_computes = 0
        log.info(f"PIDController initialised: Kp={kp}, Ki={ki}, Kd={kd}")

    def compute(self, theta: np.ndarray) -> np.ndarray:
        """
        Compute PID irrigation rates for all cells.

        Parameters
        ----------
        theta : current soil moisture, shape (N_CELLS,)

        Returns
        -------
        I_out : irrigation rates [mm/h], shape (N_CELLS,)
                All cells in a row receive the same rate (row-level control).
        """
        theta = np.array(theta).flatten()
        I_out = np.zeros(N_CELLS)

        for row in range(N_ROWS):
            cells = theta[row * N_COLS : (row + 1) * N_COLS]
            row_moisture = float(np.mean(cells))
            row_rate     = self.rows[row].compute(row_moisture)

            # Apply same rate to all cells in this row
            I_out[row * N_COLS : (row + 1) * N_COLS] = row_rate

        self.n_computes += 1
        return I_out

    def to_valve_states(self, I_opt: np.ndarray) -> List[bool]:
        """
        Convert irrigation vector to valve states.
        A valve opens if its row's irrigation rate > 0.01 mm/h.
        """
        threshold    = 0.01
        valve_states = []
        for row in range(N_ROWS):
            row_rate = float(np.mean(I_opt[row * N_COLS : (row + 1) * N_COLS]))
            valve_states.append(row_rate > threshold)
        return valve_states

    def reset_all(self) -> None:
        """Reset all 5 PID controllers."""
        for pid in self.rows:
            pid.reset()


# ── Standalone test ───────────────────────────────────────────
if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s"
    )

    pid   = PIDController()
    theta = np.random.uniform(0.15, 0.28, N_CELLS)
    theta[5] = 0.13   # dry row 1

    print(f"\nMoisture grid:\n{theta.reshape(5,5)}")
    I = pid.compute(theta)
    print(f"\nIrrigation grid:\n{I.reshape(5,5)}")
    print(f"\nValve states: {pid.to_valve_states(I)}")
