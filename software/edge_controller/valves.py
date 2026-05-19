"""
============================================================
 Smart Agri-Togo — Valve Control Module
 File   : software/edge_controller/valves.py
 Author : Ounimborbitibou DJABON

 Architecture:
   Raspberry Pi  →  USB/Serial  →  Arduino Mega
                                        ↓
                                 4 × 8-ch relay boards
                                        ↓
                                 25 solenoid valves + 1 pump

 Serial Protocol (RPi → Arduino):
   Command format : "CMD:<action>:<data>\n"
   Actions:
     VALVE_SET  : set a single valve state
                  "CMD:VALVE_SET:<row>,<state>\n"
                  row=0–4, state=0(close) or 1(open)
     PUMP_SET   : set main pump state
                  "CMD:PUMP_SET:<state>\n"
                  state=0 or 1
     ALL_CLOSE  : emergency close all valves and pump
                  "CMD:ALL_CLOSE\n"
     STATUS     : request current state of all valves
                  "CMD:STATUS\n"

 Arduino Response format:
   "OK:<action>:<data>\n"   — success
   "ERR:<code>:<msg>\n"     — error

 Safety:
   - Arduino maintains valve state independently of RPi
   - If serial connection is lost, Arduino holds last state
   - Emergency ALL_CLOSE triggered on RPi crash/reboot
   - Maximum valve-open duration enforced on Arduino side
   - Pump cannot run unless at least one valve is open
============================================================
"""

import time
import logging
import threading
from typing import List, Optional

log = logging.getLogger("valves")

# ── Hardware import (RPi only) ────────────────────────────────
try:
    import serial
    import serial.tools.list_ports
    SERIAL_AVAILABLE = True
except ImportError:
    SERIAL_AVAILABLE = False
    log.warning("pyserial not found — valve control in SIMULATION mode.")

# ── Constants ─────────────────────────────────────────────────
N_ROWS          = 5     # one valve per row
SERIAL_BAUD     = 115200
SERIAL_TIMEOUT  = 2.0   # seconds
MAX_VALVE_OPEN_H = 4.0  # maximum hours a valve can stay open continuously
CMD_RETRIES     = 3     # retry failed serial commands this many times
RETRY_DELAY_S   = 0.5   # seconds between retries


# ── Valve state machine ───────────────────────────────────────

class ValveState:
    """Tracks the state and history of a single valve."""

    def __init__(self, row: int):
        self.row        = row
        self.is_open    = False
        self.opened_at  = 0.0   # Unix timestamp when last opened
        self.total_open_s = 0.0 # cumulative seconds open (for water accounting)
        self.open_count   = 0   # number of times opened

    def open(self) -> None:
        if not self.is_open:
            self.is_open   = True
            self.opened_at = time.time()
            self.open_count += 1
            log.info(f"Valve row {self.row} → OPEN (open #{self.open_count})")

    def close(self) -> None:
        if self.is_open:
            duration = time.time() - self.opened_at
            self.total_open_s += duration
            self.is_open = False
            log.info(
                f"Valve row {self.row} → CLOSED "
                f"(was open {duration:.1f}s, "
                f"total {self.total_open_s/3600:.2f}h)"
            )

    @property
    def open_duration_h(self) -> float:
        """Hours the valve has been open in the current session."""
        if not self.is_open:
            return 0.0
        return (time.time() - self.opened_at) / 3600.0

    @property
    def exceeded_max_duration(self) -> bool:
        """True if valve has been open longer than safety maximum."""
        return self.open_duration_h >= MAX_VALVE_OPEN_H


class PumpState:
    """Tracks the main pump state."""

    def __init__(self):
        self.is_running  = False
        self.started_at  = 0.0
        self.total_run_s = 0.0
        self.run_count   = 0

    def start(self) -> None:
        if not self.is_running:
            self.is_running  = True
            self.started_at  = time.time()
            self.run_count  += 1
            log.info(f"Pump → ON (run #{self.run_count})")

    def stop(self) -> None:
        if self.is_running:
            duration = time.time() - self.started_at
            self.total_run_s += duration
            self.is_running   = False
            log.info(f"Pump → OFF (ran {duration:.1f}s, total {self.total_run_s/3600:.2f}h)")

    @property
    def total_run_h(self) -> float:
        return self.total_run_s / 3600.0


# ── Main valve controller ─────────────────────────────────────

class ValveController:
    """
    Controls 5 row valves and the main pump via Arduino over Serial.

    The Arduino acts as a real-time relay driver, ensuring valves
    respond immediately and safely even if the RPi is busy with MPC.

    Example
    -------
    ctrl = ValveController()
    ctrl.open_valve(2)          # open row 2 (carrot)
    ctrl.set_valves([True, False, True, False, False])   # rows 0 and 2
    ctrl.close_all()            # emergency close everything
    """

    def __init__(self, port: Optional[str] = None, simulate: bool = not SERIAL_AVAILABLE):
        """
        Parameters
        ----------
        port     : serial port (e.g. "/dev/ttyUSB0"). If None, auto-detect.
        simulate : run without hardware (laptop development mode)
        """
        self.simulate   = simulate
        self.port       = port
        self.serial     = None
        self._lock      = threading.Lock()  # thread-safe serial access

        # Valve and pump state objects
        self.valves = [ValveState(r) for r in range(N_ROWS)]
        self.pump   = PumpState()

        if not simulate:
            self._connect()
        else:
            log.info("ValveController → SIMULATION mode.")

    # ── Serial connection ─────────────────────────────────────

    def _find_arduino_port(self) -> Optional[str]:
        """
        Auto-detect Arduino Mega on available serial ports.
        Looks for USB serial devices (typical VID for Arduino).
        """
        for port in serial.tools.list_ports.comports():
            # Arduino Mega has VID 0x2341 or 0x1A86 (CH340 chip)
            if port.vid in [0x2341, 0x1A86, 0x0403]:
                log.info(f"Arduino detected on {port.device} ({port.description})")
                return port.device
        return None

    def _connect(self) -> None:
        """Open serial connection to Arduino."""
        try:
            if self.port is None:
                self.port = self._find_arduino_port()
            if self.port is None:
                raise IOError("No Arduino found on any serial port.")

            self.serial = serial.Serial(
                self.port,
                baudrate=SERIAL_BAUD,
                timeout=SERIAL_TIMEOUT,
            )
            time.sleep(2.0)  # wait for Arduino to reset after serial connect
            log.info(f"Arduino connected on {self.port} at {SERIAL_BAUD} baud.")

            # Verify connection
            self._send_command("STATUS")

        except Exception as exc:
            log.error(f"Serial connection failed: {exc} — falling back to simulation.")
            self.simulate = True

    def _send_command(self, cmd: str) -> str:
        """
        Send a command to Arduino and return its response.
        Retries up to CMD_RETRIES times on failure.

        Parameters
        ----------
        cmd : command string WITHOUT the "CMD:" prefix and newline

        Returns
        -------
        Response string from Arduino, or "ERR:timeout" if no response.
        """
        full_cmd = f"CMD:{cmd}\n".encode()

        for attempt in range(CMD_RETRIES):
            try:
                with self._lock:
                    self.serial.reset_input_buffer()
                    self.serial.write(full_cmd)
                    response = self.serial.readline().decode().strip()

                if response.startswith("OK"):
                    log.debug(f"Serial CMD '{cmd}' → '{response}'")
                    return response
                else:
                    log.warning(f"CMD '{cmd}' unexpected response: '{response}' (attempt {attempt+1})")

            except Exception as exc:
                log.warning(f"Serial error attempt {attempt+1}/{CMD_RETRIES}: {exc}")
                time.sleep(RETRY_DELAY_S)

        log.error(f"Command '{cmd}' failed after {CMD_RETRIES} attempts.")
        return "ERR:max_retries"

    # ── Valve control ─────────────────────────────────────────

    def open_valve(self, row: int) -> bool:
        """
        Open the solenoid valve for a given crop row.
        Automatically starts the pump if it is not running.

        Parameters
        ----------
        row : row index 0–4

        Returns
        -------
        True if successful, False on error
        """
        if row < 0 or row >= N_ROWS:
            log.error(f"Invalid row {row} — must be 0–{N_ROWS-1}")
            return False

        if self.valves[row].exceeded_max_duration:
            log.warning(
                f"Row {row} valve exceeded max open duration "
                f"({MAX_VALVE_OPEN_H}h) — forcing close for safety."
            )
            self.close_valve(row)
            return False

        success = True
        if not self.simulate:
            resp    = self._send_command(f"VALVE_SET:{row},1")
            success = resp.startswith("OK")

        if success:
            self.valves[row].open()
            # Start pump if at least one valve is now open
            if not self.pump.is_running:
                self._set_pump(True)

        return success

    def close_valve(self, row: int) -> bool:
        """
        Close the solenoid valve for a given crop row.
        Automatically stops the pump if all valves are now closed.

        Parameters
        ----------
        row : row index 0–4

        Returns
        -------
        True if successful, False on error
        """
        if row < 0 or row >= N_ROWS:
            log.error(f"Invalid row {row}")
            return False

        success = True
        if not self.simulate:
            resp    = self._send_command(f"VALVE_SET:{row},0")
            success = resp.startswith("OK")

        if success:
            self.valves[row].close()
            # Stop pump if no valves remain open
            if not any(v.is_open for v in self.valves):
                self._set_pump(False)

        return success

    def set_valves(self, states: List[bool]) -> bool:
        """
        Set all 5 valves simultaneously from a boolean list.
        This is the primary method called by the MPC controller
        at each control step.

        Parameters
        ----------
        states : list of 5 booleans — True = open, False = closed

        Returns
        -------
        True if all commands succeeded
        """
        if len(states) != N_ROWS:
            log.error(f"set_valves expects {N_ROWS} states, got {len(states)}")
            return False

        all_ok = True
        for row, state in enumerate(states):
            if state and not self.valves[row].is_open:
                ok = self.open_valve(row)
                all_ok = all_ok and ok
            elif not state and self.valves[row].is_open:
                ok = self.close_valve(row)
                all_ok = all_ok and ok
            # If state matches current state, do nothing (avoid unnecessary serial commands)

        log.info(
            "Valve states → " +
            " ".join(f"R{r}:{'OPEN' if s else 'CLSD'}" for r, s in enumerate(states))
        )
        return all_ok

    def close_all(self) -> None:
        """
        Emergency stop: close all valves and stop the pump immediately.
        Called on system shutdown, error, or manual override.
        """
        log.warning("EMERGENCY CLOSE ALL — shutting down all valves and pump.")
        if not self.simulate:
            self._send_command("ALL_CLOSE")
        for v in self.valves:
            v.close()
        self._set_pump(False)

    def _set_pump(self, state: bool) -> None:
        """Set main pump on/off."""
        if not self.simulate:
            self._send_command(f"PUMP_SET:{1 if state else 0}")
        if state:
            self.pump.start()
        else:
            self.pump.stop()

    # ── Safety watchdog ───────────────────────────────────────

    def safety_check(self) -> None:
        """
        Run safety checks. Called at every control loop iteration.

        Checks:
          1. Close any valve that has exceeded max open duration.
          2. Ensure pump is off if no valves are open.
          3. Ensure pump is on if any valve is open.
        """
        for v in self.valves:
            if v.is_open and v.exceeded_max_duration:
                log.warning(
                    f"Safety: row {v.row} open too long "
                    f"({v.open_duration_h:.1f}h ≥ {MAX_VALVE_OPEN_H}h) → closing."
                )
                self.close_valve(v.row)

        any_open = any(v.is_open for v in self.valves)
        if any_open and not self.pump.is_running:
            log.warning("Safety: valves open but pump off → starting pump.")
            self._set_pump(True)
        elif not any_open and self.pump.is_running:
            log.warning("Safety: pump running but no valves open → stopping pump.")
            self._set_pump(False)

    # ── Status and reporting ──────────────────────────────────

    @property
    def current_states(self) -> List[bool]:
        """Current open/closed state of all 5 valves."""
        return [v.is_open for v in self.valves]

    @property
    def n_open(self) -> int:
        """Number of currently open valves."""
        return sum(1 for v in self.valves if v.is_open)

    def status_report(self) -> dict:
        """
        Return a dictionary summarising current valve and pump status.
        Used for logging, dashboard, and Firebase sync.
        """
        return {
            "timestamp":    time.time(),
            "pump_running": self.pump.is_running,
            "pump_total_h": round(self.pump.total_run_h, 2),
            "valves": [
                {
                    "row":          v.row,
                    "is_open":      v.is_open,
                    "open_count":   v.open_count,
                    "total_open_h": round(v.total_open_s / 3600, 3),
                }
                for v in self.valves
            ],
        }

    def disconnect(self) -> None:
        """Safely close all valves and serial connection on shutdown."""
        self.close_all()
        if self.serial and self.serial.is_open:
            self.serial.close()
            log.info("Serial connection closed.")


# ── Standalone test ───────────────────────────────────────────
if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s"
    )
    ctrl = ValveController(simulate=True)

    print("\n=== Valve Controller Test ===")
    print("Opening rows 0 and 2 ...")
    ctrl.set_valves([True, False, True, False, False])
    time.sleep(1)
    print(f"Open valves: {ctrl.n_open}")
    print(f"Status: {ctrl.current_states}")

    print("\nClosing all ...")
    ctrl.close_all()
    print(f"Open valves: {ctrl.n_open}")
    print(f"Full report: {ctrl.status_report()}")
