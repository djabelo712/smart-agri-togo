"""
============================================================
 Smart Agri-Togo — MPC Irrigation Controller
 File   : software/edge_controller/mpc_controller.py
 Author : Ounimborbitibou DJABON

 Mathematical formulation (matches Chapter 4 of the course):

   State    : θ ∈ R^N  — soil moisture vector (25 cells)
   Control  : I ∈ R^N  — irrigation rate vector [mm/h]
   Dynamics : θ^{k+1} = θ^k + (Δt/z_r)(I^k - ET_c^k)

   Optimisation (Quadratic Program):

     min_{I^k,...,I^{k+H-1}}  Σ_{j=0}^{H-1} [
         α ‖θ^{k+j} - θ*‖² + β ‖I^{k+j}‖²
     ] + Φ(θ^{k+H})

     subject to:
       θ^{j+1} = A θ^j + B I^j + d^j       (dynamics)
       0 ≤ I^j ≤ I_max · 1                  (valve limits)
       1^T I^j ≤ Q_max                       (pump capacity)
       θ_wp ≤ θ^j ≤ θ_fc                    (soil bounds)

   Solved with CVXPY + OSQP at every control step.
   Only the first control action I^k is applied (receding horizon).

 Performance:
   N=25 cells, H=48 steps (24h at Δt=30min)
   QP has 25×48=1200 variables, ~3600 constraints
   OSQP solve time on RPi 4: ~5–12 seconds (well within 30-min loop)
============================================================
"""

import time
import logging
import numpy as np
from typing import Optional, List

log = logging.getLogger("mpc")

# ── CVXPY import ──────────────────────────────────────────────
try:
    import cvxpy as cp
    CVXPY_AVAILABLE = True
except ImportError:
    CVXPY_AVAILABLE = False
    log.warning("cvxpy not installed — MPC will fall back to greedy rule-based control.")

# ── Import project config ─────────────────────────────────────
try:
    from config import (
        N_CELLS, N_ROWS, N_COLS,
        THETA_FC, THETA_WP, MPC_HORIZON, MPC_DT_MIN,
        MPC_ALPHA, MPC_BETA, MPC_THETA_TARGET, MPC_THETA_LOW,
        PUMP_FLOW_MAX_LPH, IRR_RATE_MAX_MMH, TOTAL_FLOW_MAX_MMH,
        ROOT_DEPTH_M, CROP_PER_ROW,
    )
except ImportError:
    # Defaults for standalone testing
    N_CELLS           = 25
    N_ROWS            = 5
    N_COLS            = 5
    THETA_FC          = 0.30
    THETA_WP          = 0.12
    MPC_HORIZON       = 48
    MPC_DT_MIN        = 30
    MPC_ALPHA         = 0.70
    MPC_BETA          = 0.30
    MPC_THETA_TARGET  = 0.65 * 0.30   # 65% of FC
    MPC_THETA_LOW     = 0.40 * 0.30
    PUMP_FLOW_MAX_LPH = 2880
    IRR_RATE_MAX_MMH  = 3.0
    TOTAL_FLOW_MAX_MMH = 10.0
    ROOT_DEPTH_M      = 0.30
    CROP_PER_ROW      = {0:"onion",1:"onion",2:"carrot",3:"lettuce",4:"maize"}

# ── Crop ET rates [mm/h] — used when no LSTM forecast available ──
# These are mean dry-season values for Bangeli at ET0 ≈ 6 mm/day
# Updated automatically when LSTM forecast module is ready
DEFAULT_ET_RATES = {
    "onion":   0.25 / 24,   # mm/h
    "carrot":  0.22 / 24,
    "lettuce": 0.28 / 24,
    "maize":   0.35 / 24,
}


# ── MPC Controller ────────────────────────────────────────────

class MPCController:
    """
    Model Predictive Controller for Smart Agri-Togo irrigation.

    At each control step:
      1. Receives current soil moisture vector θ (from sensors)
      2. Receives ET forecast for the next H steps (from LSTM or default)
      3. Solves the QP over horizon H using cvxpy + OSQP
      4. Returns the optimal irrigation vector for the current step

    Automatically falls back to a greedy rule-based controller
    if cvxpy is not installed or if the QP solve fails.

    Example
    -------
    mpc  = MPCController()
    θ    = np.array([...])          # shape (25,)
    ET_c = np.ones((48, 25)) * 0.01 # shape (H, 25) — from LSTM
    I_opt = mpc.compute(θ, ET_c)    # shape (25,) — mm/h per cell
    valve_states = mpc.to_valve_states(I_opt)  # shape (5,) — bool per row
    """

    def __init__(
        self,
        alpha:         float = MPC_ALPHA,
        beta:          float = MPC_BETA,
        horizon:       int   = MPC_HORIZON,
        theta_target:  float = None,
        theta_low:     float = None,
        i_max_mmh:     float = IRR_RATE_MAX_MMH,
        q_max_mmh:     float = TOTAL_FLOW_MAX_MMH,
        dt_h:          float = MPC_DT_MIN / 60.0,
        z_r_m:         float = ROOT_DEPTH_M,
    ):
        """
        Parameters
        ----------
        alpha        : weight on crop stress (yield loss penalty)
        beta         : weight on water use (conservation penalty)
        horizon      : prediction horizon H [steps]
        theta_target : optimal moisture target [m³/m³]. Default: 65% of FC.
        theta_low    : threshold below which irrigation is triggered [m³/m³]
        i_max_mmh    : max irrigation rate per cell [mm/h]
        q_max_mmh    : max total irrigation rate across all cells [mm/h]
        dt_h         : time step [hours]
        z_r_m        : root zone depth [m]
        """
        self.alpha        = alpha
        self.beta         = beta
        self.H            = horizon
        self.theta_star   = theta_target if theta_target else THETA_FC * 0.65
        self.theta_low    = theta_low    if theta_low    else THETA_WP + 0.10
        self.i_max        = i_max_mmh
        self.q_max        = q_max_mmh
        self.dt           = dt_h
        self.z_r          = z_r_m * 1000  # convert to mm (matches I in mm/h)
        self.delta        = dt_h / (z_r_m * 1000)  # Δt/z_r [h/mm]

        # Solve time tracking
        self.last_solve_s  = 0.0
        self.n_solves      = 0
        self.n_fallbacks   = 0

        log.info(
            f"MPCController initialised: "
            f"α={alpha}, β={beta}, H={horizon}, "
            f"θ*={self.theta_star:.3f}, Δt={dt_h*60:.0f}min"
        )

    def _build_et_forecast(
        self,
        et_forecast: Optional[np.ndarray],
        n_steps: int,
    ) -> np.ndarray:
        """
        Prepare ET_c forecast array of shape (H, N_CELLS).

        If et_forecast is None, uses default constant ET rates per crop.
        If et_forecast is provided (from LSTM), validates its shape.

        Parameters
        ----------
        et_forecast : LSTM output, shape (H, N_CELLS) or (H, N_ROWS), or None
        n_steps     : H

        Returns
        -------
        ET_c array, shape (H, N_CELLS) [mm/h per cell]
        """
        if et_forecast is None:
            # Build default ET from crop type per row
            ET = np.zeros((n_steps, N_CELLS))
            for cell_id in range(N_CELLS):
                row  = cell_id // N_COLS
                crop = CROP_PER_ROW.get(row, "onion")
                ET[:, cell_id] = DEFAULT_ET_RATES.get(crop, 0.012)
            return ET

        et = np.array(et_forecast)

        # If per-row forecast (H, 5) → expand to (H, 25)
        if et.shape == (n_steps, N_ROWS):
            ET = np.zeros((n_steps, N_CELLS))
            for cell_id in range(N_CELLS):
                row = cell_id // N_COLS
                ET[:, cell_id] = et[:, row]
            return ET

        # If already (H, N_CELLS)
        if et.shape == (n_steps, N_CELLS):
            return et

        log.warning(
            f"ET forecast shape {et.shape} unexpected — using defaults."
        )
        return self._build_et_forecast(None, n_steps)

    def compute(
        self,
        theta:       np.ndarray,
        et_forecast: Optional[np.ndarray] = None,
    ) -> np.ndarray:
        """
        Solve the MPC QP and return optimal first-step irrigation.

        Parameters
        ----------
        theta       : current soil moisture [m³/m³], shape (N_CELLS,)
        et_forecast : predicted ET_c for next H steps, shape (H, N_CELLS) or None

        Returns
        -------
        I_opt : optimal irrigation vector [mm/h], shape (N_CELLS,)
                Values > 0 indicate cells that should be irrigated.
        """
        theta = np.array(theta, dtype=float).flatten()
        if len(theta) != N_CELLS:
            raise ValueError(f"theta must have length {N_CELLS}, got {len(theta)}")

        ET = self._build_et_forecast(et_forecast, self.H)

        if CVXPY_AVAILABLE:
            return self._solve_qp(theta, ET)
        else:
            log.warning("cvxpy not available — using greedy fallback.")
            self.n_fallbacks += 1
            return self._greedy_fallback(theta)

    def _solve_qp(
        self,
        theta0: np.ndarray,
        ET:     np.ndarray,
    ) -> np.ndarray:
        """
        Solve the MPC quadratic program using cvxpy + OSQP.

        Variables  : U [shape (H, N_CELLS)] — irrigation rates
        Objective  : Σ_k [α ‖θ^k - θ*‖² + β ‖I^k‖²]
        Constraints: dynamics, valve bounds, pump capacity, soil bounds

        Returns
        -------
        I_opt : first-step optimal control, shape (N_CELLS,)
        """
        t_start = time.time()

        N = N_CELLS
        H = self.H

        # ── Decision variable ──────────────────────────────
        U = cp.Variable((H, N), nonneg=True)  # I^k [mm/h], non-negative

        # ── Build state trajectory ─────────────────────────
        # θ^{k+1} = θ^k + δ(I^k - ET_c^k)  where δ = Δt/z_r
        # Using the lifted system formulation:
        theta_traj = [None] * (H + 1)
        theta_traj[0] = theta0   # initial condition (parameter, not variable)

        for k in range(H):
            theta_traj[k + 1] = (
                theta_traj[k] + self.delta * (U[k] - ET[k])
            )

        # ── Objective ──────────────────────────────────────
        cost = 0
        theta_star_vec = np.full(N, self.theta_star)

        for k in range(H):
            theta_k = theta_traj[k + 1]
            # Crop stress penalty: (θ - θ*)²
            cost += self.alpha * cp.sum_squares(theta_k - theta_star_vec)
            # Water use penalty: β ‖I‖²
            cost += self.beta  * cp.sum_squares(U[k])

        objective = cp.Minimize(cost)

        # ── Constraints ────────────────────────────────────
        constraints = []

        for k in range(H):
            # Valve capacity: 0 ≤ I_i^k ≤ I_max
            constraints.append(U[k] <= self.i_max)
            # Pump capacity: Σ I_i^k ≤ Q_max (total flow)
            constraints.append(cp.sum(U[k]) <= self.q_max)
            # Soil bounds: θ_wp ≤ θ ≤ θ_fc (prevents over- and under-irrigation)
            constraints.append(theta_traj[k + 1] >= THETA_WP)
            constraints.append(theta_traj[k + 1] <= THETA_FC)

        # ── Solve ──────────────────────────────────────────
        prob = cp.Problem(objective, constraints)
        try:
            prob.solve(
                solver=cp.OSQP,
                warm_start=True,   # reuse previous solution for speed
                eps_abs=1e-4,
                eps_rel=1e-4,
                max_iter=10000,
                verbose=False,
            )
        except cp.SolverError as exc:
            log.error(f"OSQP solver error: {exc} — using greedy fallback.")
            self.n_fallbacks += 1
            return self._greedy_fallback(theta0)

        solve_time = time.time() - t_start
        self.last_solve_s = solve_time
        self.n_solves    += 1

        # ── Extract and validate result ────────────────────
        if prob.status in [cp.OPTIMAL, cp.OPTIMAL_INACCURATE]:
            I_opt = np.array(U.value[0]).flatten()
            I_opt = np.clip(I_opt, 0, self.i_max)   # numerical safety clip

            log.info(
                f"MPC solve #{self.n_solves}: "
                f"status={prob.status}, "
                f"J={prob.value:.4f}, "
                f"time={solve_time:.2f}s, "
                f"I_opt_max={I_opt.max():.3f} mm/h"
            )
            return I_opt

        else:
            log.warning(
                f"MPC infeasible (status={prob.status}) — using greedy fallback."
            )
            self.n_fallbacks += 1
            return self._greedy_fallback(theta0)

    def _greedy_fallback(self, theta: np.ndarray) -> np.ndarray:
        """
        Simple greedy rule-based fallback when MPC is unavailable.

        Rule: irrigate at I_max for cells where θ < θ_low,
              subject to total pump capacity Q_max.

        This is equivalent to a threshold controller and serves as
        the T3 (manual / rule-based) treatment in the research experiment.
        """
        I = np.zeros(N_CELLS)
        total_flow = 0.0

        # Sort cells by moisture (driest first) for priority scheduling
        order = np.argsort(theta)

        for cell_id in order:
            if theta[cell_id] < self.theta_low:
                if total_flow + self.i_max <= self.q_max:
                    I[cell_id]  = self.i_max
                    total_flow += self.i_max

        if np.any(I > 0):
            log.debug(
                f"Greedy fallback: irrigating {np.sum(I>0)} cells, "
                f"total flow {total_flow:.1f} mm/h"
            )
        return I

    def to_valve_states(self, I_opt: np.ndarray) -> List[bool]:
        """
        Convert a cell-level irrigation vector to row-level valve states.

        A row valve is opened if ANY cell in that row has I_opt > threshold.
        The drip system then applies water to all 5 cells in the row evenly.

        Parameters
        ----------
        I_opt : optimal irrigation vector, shape (N_CELLS,)

        Returns
        -------
        valve_states : list of 5 booleans — True = open valve for that row
        """
        threshold = 0.01  # mm/h — below this, treat as "no irrigation"
        valve_states = []

        for row in range(N_ROWS):
            row_cells = I_opt[row * N_COLS : (row + 1) * N_COLS]
            # Open valve if average recommended irrigation exceeds threshold
            should_open = float(np.mean(row_cells)) > threshold
            valve_states.append(should_open)

        return valve_states

    def compute_cost(self, theta: np.ndarray) -> float:
        """
        Compute the current control cost J(θ) for monitoring/logging.
        J = α Σ(θ_i - θ*)² — a measure of total field stress.
        """
        return float(self.alpha * np.sum((theta - self.theta_star) ** 2))

    def stats(self) -> dict:
        """Return controller performance statistics."""
        return {
            "n_solves":      self.n_solves,
            "n_fallbacks":   self.n_fallbacks,
            "last_solve_s":  round(self.last_solve_s, 2),
            "fallback_rate": round(
                self.n_fallbacks / max(1, self.n_solves + self.n_fallbacks), 3
            ),
        }


# ── Standalone test ───────────────────────────────────────────
if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s"
    )

    mpc = MPCController(horizon=12)  # short horizon for quick test

    # Simulate a field with some dry cells
    theta = np.random.uniform(0.15, 0.28, N_CELLS)
    theta[0]  = 0.13   # very dry cell
    theta[10] = 0.26   # well-irrigated cell

    print(f"\nInitial moisture: mean={theta.mean():.3f}, min={theta.min():.3f}")

    I_opt = mpc.compute(theta)

    print(f"\nOptimal irrigation I^0 [mm/h]:")
    grid = I_opt.reshape(5, 5)
    for row in grid:
        print("  " + "  ".join(f"{v:.3f}" for v in row))

    valve_states = mpc.to_valve_states(I_opt)
    print(f"\nValve states: {valve_states}")
    print(f"Open valves : {sum(valve_states)}/{N_ROWS}")
    print(f"MPC stats   : {mpc.stats()}")
