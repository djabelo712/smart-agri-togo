"""
============================================================
 Smart Agri-Togo — Main Control Loop
 File   : software/edge_controller/main.py
 Author : Ounimborbitibou DJABON

 This is the entry point that runs 24/7 on the Raspberry Pi.
 It ties together all modules into a single control loop.

 Control loop (every 30 minutes):
   1. READ    — measure soil moisture from all 25 sensors
   2. WEATHER — fetch latest ET₀ forecast from LSTM / API
   3. DECIDE  — run MPC (or PID) to compute optimal irrigation
   4. ACT     — send valve commands to Arduino via Serial
   5. LOG     — save all data to SQLite (+ Firebase if configured)
   6. REPORT  — print status to terminal and push to mobile app
   7. SLEEP   — wait until next control step

 Run modes:
   --mode simulation   : no hardware, realistic simulation (laptop)
   --mode hardware     : full hardware on Raspberry Pi
   --mode pid          : use PID controller instead of MPC
   --mode manual       : no automatic control, log sensors only

 Usage:
   python main.py --mode simulation
   python main.py --mode hardware --controller mpc
   python main.py --help
============================================================
"""

import os
import sys
import time
import signal
import logging
import argparse
import numpy as np
from pathlib import Path
from datetime import datetime

# ── Ensure project root is on Python path ─────────────────────
sys.path.insert(0, str(Path(__file__).resolve().parent))

# ── Project modules ───────────────────────────────────────────
from config         import (
    N_CELLS, N_ROWS, LOG_INTERVAL_MIN,
    MPC_THETA_TARGET, THETA_FC, THETA_WP,
    CROP_PER_ROW,
)
from sensors        import SensorManager, SensorSnapshot
from valves         import ValveController
from mpc_controller import MPCController
from pid_controller import PIDController
from database       import DataLogger

# ── Logging setup ─────────────────────────────────────────────
LOG_DIR = Path(__file__).resolve().parent.parent.parent / "logs"
LOG_DIR.mkdir(exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s — %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler(LOG_DIR / "controller.log", mode="a"),
    ],
)
log = logging.getLogger("main")

# ── Constants ─────────────────────────────────────────────────
CONTROL_INTERVAL_S = LOG_INTERVAL_MIN * 60   # 30 minutes in seconds
CROP_EMOJIS = {
    "onion": "🧅", "carrot": "🥕",
    "lettuce": "🥬", "maize": "🌽",
}


# ── ET₀ forecast stub ─────────────────────────────────────────
def get_et_forecast(horizon: int = 48) -> np.ndarray:
    """
    Get ET_c forecast for the next `horizon` steps.

    Currently returns default values from the weather logger CSV.
    Will be replaced by the LSTM model once trained.

    Returns
    -------
    ET_c : shape (horizon, N_CELLS) [mm/h]
    """
    try:
        import pandas as pd
        from pathlib import Path as P
        csv = P(__file__).resolve().parent.parent.parent / \
              "data" / "weather" / "processed" / "Bangeli_Bassar_Togo_daily.csv"
        if csv.exists():
            df     = pd.read_csv(csv, parse_dates=["date"])
            latest = df.iloc[-1]
            et0_day = float(latest.get("ET0_PM_mm_day", 6.0))
        else:
            et0_day = 6.0   # fallback: typical dry season value

        # Kc values per row (mid-season)
        kc_per_row = {"onion": 1.05, "carrot": 1.05, "lettuce": 1.00, "maize": 1.20}
        et_per_hour = np.zeros((horizon, N_CELLS))
        for cell_id in range(N_CELLS):
            row  = cell_id // 5
            crop = CROP_PER_ROW.get(row, "onion")
            kc   = kc_per_row.get(crop, 1.0)
            # ET_c = Kc × ET₀, converted from mm/day to mm/h
            et_per_hour[:, cell_id] = (kc * et0_day) / 24.0

        return et_per_hour

    except Exception as exc:
        log.warning(f"ET forecast error: {exc} — using constant default.")
        return np.full((horizon, N_CELLS), 6.0 / 24.0)


# ── Status display ────────────────────────────────────────────
def print_status(
    step:     int,
    snapshot: SensorSnapshot,
    valves:   list,
    cost_j:   float,
    mode:     str,
    db:       DataLogger,
) -> None:
    """Print a human-readable status table to the terminal."""
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    print("\n" + "═" * 60)
    print(f"  🌱 Smart Agri-Togo   Step {step:04d}   {now}")
    print(f"  Controller: {mode.upper()}   Cost J = {cost_j:.4f}")
    print("═" * 60)

    # Moisture grid
    grid = snapshot.as_grid()
    print("  Moisture grid [m³/m³]:")
    for row_idx in range(5):
        crop = CROP_PER_ROW.get(row_idx, "onion")
        emoji = CROP_EMOJIS.get(crop, "🌿")
        v_str = "  ".join(
            f"\033[92m{v:.3f}\033[0m" if v >= THETA_FC * 0.60
            else f"\033[93m{v:.3f}\033[0m" if v >= THETA_WP + 0.08
            else f"\033[91m{v:.3f}\033[0m"
            for v in grid[row_idx]
        )
        valve_icon = "💧" if valves[row_idx] else "  "
        print(f"  {emoji} R{row_idx+1} [{v_str}] {valve_icon}")

    # Summary
    print(f"\n  Mean θ  : {snapshot.mean_moisture:.3f}   "
          f"Min: {snapshot.min_moisture:.3f}   "
          f"Max: {snapshot.max_moisture:.3f}")
    open_rows = [r for r, v in enumerate(valves) if v]
    print(f"  Valves  : {len(open_rows)}/5 open  "
          f"{'rows ' + str([r+1 for r in open_rows]) if open_rows else '(all closed)'}")
    print(f"  Faults  : {snapshot.n_faults} sensors")

    # Database summary every 10 steps
    if step % 10 == 0:
        summary = db.get_season_summary()
        print(f"\n  💾 DB: {summary['n_sensor_readings']} readings, "
              f"{summary['total_water_l']:.0f} L used")

    print("═" * 60)


# ── Graceful shutdown ─────────────────────────────────────────
class GracefulShutdown:
    """Catches SIGINT/SIGTERM and sets a flag to stop the main loop."""
    def __init__(self, valve_ctrl: ValveController):
        self.running     = True
        self.valve_ctrl  = valve_ctrl
        signal.signal(signal.SIGINT,  self._handler)
        signal.signal(signal.SIGTERM, self._handler)

    def _handler(self, signum, frame):
        log.warning(f"Signal {signum} received — initiating graceful shutdown ...")
        self.valve_ctrl.close_all()
        self.running = False


# ── Main control loop ─────────────────────────────────────────
def run(
    mode:       str = "simulation",
    controller: str = "mpc",
    interval_s: int = CONTROL_INTERVAL_S,
) -> None:
    """
    Main 24/7 control loop.

    Parameters
    ----------
    mode       : 'simulation' | 'hardware'
    controller : 'mpc' | 'pid' | 'manual'
    interval_s : control step interval in seconds
    """
    simulate = (mode == "simulation")
    log.info("=" * 55)
    log.info("  🌱 Smart Agri-Togo — Control System Starting")
    log.info(f"  Mode: {mode.upper()}   Controller: {controller.upper()}")
    log.info(f"  Control interval: {interval_s}s ({interval_s/60:.0f} min)")
    log.info(f"  Field: Bangeli, Bassar, Togo — 25m×25m — 5×5 grid")
    log.info("=" * 55)

    # ── Initialise all modules ─────────────────────────────
    sensors = SensorManager(simulate=simulate)
    valves  = ValveController(simulate=simulate)
    db      = DataLogger()

    if controller == "mpc":
        ctrl = MPCController()
    elif controller == "pid":
        ctrl = PIDController()
    else:
        ctrl = None   # manual mode: no automatic control

    shutdown = GracefulShutdown(valves)

    step = 0
    log.info("Control loop started. Press Ctrl+C to stop safely.\n")

    # ── Main loop ──────────────────────────────────────────
    while shutdown.running:
        t_loop_start = time.time()
        step        += 1

        try:
            # ── 1. READ SENSORS ────────────────────────────
            snapshot = sensors.read_all()
            theta    = snapshot.as_array()   # shape (25,)

            # Inform simulator of current valve states
            sensors.set_irrigation_state(valves.current_states)

            # ── 2. LOG SENSOR DATA ─────────────────────────
            db.log_sensor_snapshot(snapshot)

            # ── 3. COMPUTE CONTROL ACTION ──────────────────
            if ctrl is not None:
                t_solve_start = time.time()
                ET_forecast   = get_et_forecast(horizon=48)

                if controller == "mpc":
                    I_opt        = ctrl.compute(theta, ET_forecast)
                    solve_time_s = ctrl.last_solve_s
                    cost_j       = ctrl.compute_cost(theta)
                else:  # PID
                    I_opt        = ctrl.compute(theta)
                    solve_time_s = time.time() - t_solve_start
                    cost_j       = float(np.sum((theta - MPC_THETA_TARGET)**2))

                new_valve_states = ctrl.to_valve_states(I_opt)

                # ── 4. SAFETY CHECK ────────────────────────
                valves.safety_check()

                # ── 5. APPLY VALVE COMMANDS ────────────────
                prev_states = valves.current_states
                valves.set_valves(new_valve_states)

                # Log valve events for changed states
                for row in range(N_ROWS):
                    if new_valve_states[row] and not prev_states[row]:
                        db.log_valve_open(row)
                    elif not new_valve_states[row] and prev_states[row]:
                        db.log_valve_close(row)

                # ── 6. LOG CONTROL DECISION ────────────────
                db.log_control_decision(
                    controller   = controller.upper(),
                    cost_j       = cost_j,
                    solve_time_s = solve_time_s,
                    valve_states = new_valve_states,
                    i_opt        = I_opt.tolist(),
                )

            else:
                # Manual mode — just read and log
                new_valve_states = valves.current_states
                cost_j           = 0.0

            # ── 7. PRINT STATUS ────────────────────────────
            print_status(
                step     = step,
                snapshot = snapshot,
                valves   = valves.current_states,
                cost_j   = cost_j,
                mode     = controller,
                db       = db,
            )

        except KeyboardInterrupt:
            break
        except Exception as exc:
            log.error(f"Control loop error at step {step}: {exc}", exc_info=True)
            # Safety: close all valves on unexpected error
            valves.close_all()
            time.sleep(5)   # brief pause before retrying

        # ── 8. SLEEP until next control step ───────────────
        elapsed  = time.time() - t_loop_start
        sleep_s  = max(0, interval_s - elapsed)
        log.debug(f"Step {step} took {elapsed:.1f}s — sleeping {sleep_s:.1f}s")

        if sleep_s > 0 and shutdown.running:
            time.sleep(sleep_s)

    # ── Clean shutdown ─────────────────────────────────────
    log.info("Shutting down — closing all valves ...")
    valves.close_all()
    valves.disconnect()
    summary = db.get_season_summary()
    log.info(f"Final season summary: {summary}")
    log.info("Smart Agri-Togo control system stopped. Goodbye. 🌱")


# ── CLI entry point ───────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(
        description="Smart Agri-Togo — Intelligent Irrigation Control System"
    )
    parser.add_argument(
        "--mode",
        choices=["simulation", "hardware"],
        default="simulation",
        help="Run mode: 'simulation' (laptop) or 'hardware' (Raspberry Pi)"
    )
    parser.add_argument(
        "--controller",
        choices=["mpc", "pid", "manual"],
        default="mpc",
        help="Control algorithm: 'mpc' (optimal), 'pid' (baseline), 'manual' (log only)"
    )
    parser.add_argument(
        "--interval",
        type=int,
        default=CONTROL_INTERVAL_S,
        help=f"Control interval in seconds (default: {CONTROL_INTERVAL_S})"
    )
    args = parser.parse_args()

    run(
        mode       = args.mode,
        controller = args.controller,
        interval_s = args.interval,
    )


if __name__ == "__main__":
    main()
