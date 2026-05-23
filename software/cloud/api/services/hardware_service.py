"""
SmartFarm Togo - Hardware Control Service

Runs in two modes:
- HARDWARE_MODE=True  : sends real serial commands to the Arduino
- HARDWARE_MODE=False : simulation mode (for cloud deployment / testing)
"""
import logging
import time
from datetime import datetime
from typing import Optional

from config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()

# ── Serial connection (Raspberry Pi only) ─────────────────────────────────
_serial_conn = None


def init_hardware():
    """Initialize serial connection to Arduino. No-op in simulation mode."""
    global _serial_conn
    if not settings.HARDWARE_MODE:
        logger.info("Hardware mode OFF -- running in simulation.")
        return
    try:
        import serial
        _serial_conn = serial.Serial(
            settings.ARDUINO_PORT,
            settings.ARDUINO_BAUDRATE,
            timeout=2,
        )
        time.sleep(2)  # Arduino reset delay
        logger.info(f"Arduino connected on {settings.ARDUINO_PORT}")
    except Exception as e:
        logger.error(f"Arduino connection failed: {e}")
        _serial_conn = None


def _send_command(cmd: str) -> bool:
    """Send a command string to the Arduino via serial."""
    if _serial_conn is None:
        logger.warning(f"SIMULATION: {cmd}")
        return True
    try:
        _serial_conn.write((cmd + "\n").encode())
        time.sleep(0.1)
        response = _serial_conn.readline().decode().strip()
        logger.info(f"Arduino response: {response}")
        return response.startswith("OK")
    except Exception as e:
        logger.error(f"Serial command failed: {e}")
        return False


# ── Valve control ─────────────────────────────────────────────────────────

def open_valve(cell_id: str, duration_min: int = 15) -> dict:
    """
    Open the irrigation valve for a specific cell.
    Protocol: CMD:VALVE_SET:<row>,<col>,OPEN,<duration_seconds>
    """
    # Parse cell ID: C00 -> row=0, col=0
    row = int(cell_id[1])
    col = int(cell_id[2])
    duration_sec = duration_min * 60
    cmd = f"CMD:VALVE_SET:{row},{col},OPEN,{duration_sec}"
    success = _send_command(cmd)
    return {
        "cell_id":     cell_id,
        "action":      "open",
        "duration_min": duration_min,
        "success":     success,
        "timestamp":   datetime.utcnow().isoformat(),
        "mode":        "hardware" if settings.HARDWARE_MODE else "simulation",
    }


def close_valve(cell_id: str) -> dict:
    """Close the irrigation valve for a specific cell."""
    row = int(cell_id[1])
    col = int(cell_id[2])
    cmd = f"CMD:VALVE_SET:{row},{col},CLOSE"
    success = _send_command(cmd)
    return {
        "cell_id":   cell_id,
        "action":    "close",
        "success":   success,
        "timestamp": datetime.utcnow().isoformat(),
        "mode":      "hardware" if settings.HARDWARE_MODE else "simulation",
    }


def close_all_valves() -> dict:
    """Emergency: close all 25 valves immediately."""
    cmd = "CMD:ALL_VALVES_CLOSE"
    success = _send_command(cmd)
    return {
        "action":    "close_all",
        "success":   success,
        "timestamp": datetime.utcnow().isoformat(),
    }


# ── Pump control ──────────────────────────────────────────────────────────

def start_pump(duration_min: int = 30) -> dict:
    """Start the main irrigation pump."""
    duration_sec = duration_min * 60
    cmd = f"CMD:PUMP_START,{duration_sec}"
    success = _send_command(cmd)
    return {
        "action":       "start",
        "duration_min": duration_min,
        "success":      success,
        "timestamp":    datetime.utcnow().isoformat(),
        "mode":         "hardware" if settings.HARDWARE_MODE else "simulation",
    }


def stop_pump() -> dict:
    """Stop the main irrigation pump."""
    cmd = "CMD:PUMP_STOP"
    success = _send_command(cmd)
    return {
        "action":    "stop",
        "success":   success,
        "timestamp": datetime.utcnow().isoformat(),
    }


# ── Controller mode ───────────────────────────────────────────────────────

_current_mode = "MPC"


def set_controller_mode(mode: str) -> dict:
    """Switch between MPC, PID, and Manuel modes."""
    global _current_mode
    valid_modes = ["MPC", "PID", "Manuel"]
    if mode not in valid_modes:
        raise ValueError(f"Invalid mode: {mode}. Valid: {valid_modes}")
    cmd = f"CMD:SET_MODE,{mode}"
    success = _send_command(cmd)
    if success:
        _current_mode = mode
    return {
        "mode":      mode,
        "success":   success,
        "timestamp": datetime.utcnow().isoformat(),
    }


def get_controller_mode() -> str:
    return _current_mode
