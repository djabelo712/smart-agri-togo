"""
============================================================
 Smart Agri-Togo — Soil Sensor Module
 File   : software/edge_controller/sensors.py
 Author : Ounimborbitibou DJABON

 Hardware:
   - 25 capacitive soil moisture sensors (analog 0–3.3V)
   - 7 × ADS1115 ADC (16-bit, I2C, 4 channels each)
     Addresses: 0x48, 0x49, 0x4A, 0x4B (set via ADDR pin)
     Chips 0–5 cover cells 0–23 (4 cells each)
     Chip  6 covers cell 24 (channel 0 only)
   - DS18B20 temperature sensors (1-Wire, GPIO pin 4)

 I2C Wiring:
   RPi SDA (pin 3)  → all ADS1115 SDA
   RPi SCL (pin 5)  → all ADS1115 SCL
   RPi 3.3V         → all ADS1115 VDD
   RPi GND          → all ADS1115 GND
   ADDR pin per chip: GND=0x48, VDD=0x49, SDA=0x4A, SCL=0x4B
   Use TCA9548A I2C multiplexer to allow address reuse for chips 4–6

 Cell-to-chip mapping:
   Cells  0– 3  → Chip 0 (0x48), channels 0–3
   Cells  4– 7  → Chip 1 (0x49), channels 0–3
   Cells  8–11  → Chip 2 (0x4A), channels 0–3
   Cells 12–15  → Chip 3 (0x4B), channels 0–3
   Cells 16–19  → Chip 4 (0x48 via MUX), channels 0–3
   Cells 20–23  → Chip 5 (0x49 via MUX), channels 0–3
   Cell  24     → Chip 6 (0x4A via MUX), channel 0
============================================================
"""

import time
import logging
import numpy as np
from dataclasses import dataclass, field
from typing import List, Tuple

log = logging.getLogger("sensors")

# ── Try hardware import (RPi only) ───────────────────────────
try:
    import board
    import busio
    import adafruit_ads1x15.ads1115 as ADS
    from adafruit_ads1x15.analog_in import AnalogIn
    HARDWARE_AVAILABLE = True
    log.info("ADS1115 hardware library loaded.")
except (ImportError, NotImplementedError):
    HARDWARE_AVAILABLE = False
    log.warning("ADS1115 not found — SIMULATION mode active.")

# ── Grid constants ────────────────────────────────────────────
N_CELLS           = 25
N_ROWS            = 5
N_COLS            = 5
N_CHIPS           = 7
CHANNELS_PER_CHIP = 4

# ADS1115 I2C addresses
ADS_ADDRESSES = [0x48, 0x49, 0x4A, 0x4B, 0x48, 0x49, 0x4A]

# ── Calibration defaults (update after field calibration) ─────
# Measure V_DRY in oven-dried soil and V_WET in saturated soil
# at your Bangeli field. See calibrate_cell() method below.
V_DRY     = 0.80   # [V] — soil at wilting point
V_WET     = 2.80   # [V] — soil at field capacity / saturation
THETA_DRY = 0.12   # [m³/m³] — wilting point
THETA_WET = 0.82   # [m³/m³] — saturated water content

# Fault thresholds
V_MIN_VALID = 0.20  # below → disconnected or short
V_MAX_VALID = 3.20  # above → hardware fault


# ── Data structures ───────────────────────────────────────────

@dataclass
class CellReading:
    """Sensor reading for a single field cell."""
    cell_id:      int    # 0–24
    row:          int    # 0–4
    col:          int    # 0–4
    voltage:      float  # raw ADC voltage [V]
    moisture:     float  # volumetric water content θ [m³/m³]
    temperature:  float  # soil temperature [°C]
    fault:        bool = False
    fault_reason: str  = ""


@dataclass
class SensorSnapshot:
    """Complete reading from all 25 cells."""
    timestamp:     float
    readings:      List[CellReading] = field(default_factory=list)
    n_faults:      int   = 0
    mean_moisture: float = 0.0
    min_moisture:  float = 0.0
    max_moisture:  float = 0.0

    def as_array(self) -> np.ndarray:
        """Return moisture values as shape-(25,) numpy array for MPC."""
        return np.array([r.moisture for r in self.readings])

    def as_grid(self) -> np.ndarray:
        """Return moisture values as shape-(5,5) numpy array for display."""
        return self.as_array().reshape(N_ROWS, N_COLS)


# ── Calibration functions ─────────────────────────────────────

def voltage_to_moisture(
    voltage:   float,
    v_dry:     float = V_DRY,
    v_wet:     float = V_WET,
    theta_dry: float = THETA_DRY,
    theta_wet: float = THETA_WET,
) -> float:
    """
    Convert raw ADC voltage → volumetric soil water content θ [m³/m³].

    Linear calibration model (FAO standard approach):
        θ = θ_dry + (θ_wet - θ_dry) × (V - V_dry) / (V_wet - V_dry)

    For research-grade accuracy, replace with a 3-point polynomial
    calibration after measuring at known θ values in your Bangeli soil.

    Parameters
    ----------
    voltage   : ADC reading [V]
    v_dry     : voltage at wilting point (from calibrate_cell())
    v_wet     : voltage at field capacity (from calibrate_cell())
    theta_dry : wilting point [m³/m³]
    theta_wet : saturation water content [m³/m³]

    Returns
    -------
    θ clipped to physical bounds [theta_dry, theta_wet]
    """
    span = v_wet - v_dry
    if span == 0:
        return theta_dry
    theta = theta_dry + (theta_wet - theta_dry) * (voltage - v_dry) / span
    return float(np.clip(theta, theta_dry, theta_wet))


def cell_to_chip_channel(cell_id: int) -> Tuple[int, int]:
    """
    Map cell index (0–24) to (chip_index, channel_index).

    Returns
    -------
    (chip_idx, channel_idx) — channel_idx ∈ {0,1,2,3}
    """
    return cell_id // CHANNELS_PER_CHIP, cell_id % CHANNELS_PER_CHIP


# ── Spatial interpolation for faulty sensors ──────────────────

def interpolate_faults(readings: List[CellReading]) -> List[CellReading]:
    """
    Estimate moisture in cells with faulty sensors using
    inverse-distance weighting from neighbouring good sensors.

    This is the fast approximation of the Gaussian Process spatial
    interpolation described in Chapter 5 of the technical course.
    Replace with gpytorch GPR for publication-quality results.

    Parameters
    ----------
    readings : list of 25 CellReading objects

    Returns
    -------
    readings with fault cells filled in by interpolation
    """
    good = [(r.row, r.col, r.moisture) for r in readings if not r.fault]

    if len(good) < 3:
        # Not enough good sensors — use field mean
        mean_m = np.mean([m for _, _, m in good]) if good else 0.5
        log.warning(f"<3 good sensors — using field mean θ={mean_m:.3f}")
        for r in readings:
            if r.fault:
                r.moisture = mean_m
        return readings

    good_pos = np.array([[row, col] for row, col, _ in good], dtype=float)
    good_m   = np.array([m for _, _, m in good])

    for r in readings:
        if not r.fault:
            continue
        pos     = np.array([r.row, r.col], dtype=float)
        dists   = np.linalg.norm(good_pos - pos, axis=1)
        dists   = np.maximum(dists, 1e-6)
        weights = 1.0 / dists ** 2
        r.moisture = float(np.average(good_m, weights=weights))
        log.info(
            f"Cell {r.cell_id} ({r.row},{r.col}) fault "
            f"→ interpolated θ={r.moisture:.3f}"
        )
    return readings


# ── Main sensor manager ───────────────────────────────────────

class SensorManager:
    """
    Manages all 25 soil moisture sensors and temperature probes.

    On Raspberry Pi     : reads real ADS1115 hardware via I2C.
    On laptop / testing : generates realistic simulated data.

    Example
    -------
    mgr = SensorManager()           # auto-detects hardware
    snapshot = mgr.read_all()       # full 25-cell snapshot
    theta = snapshot.as_array()     # shape-(25,) for MPC
    grid  = snapshot.as_grid()      # shape-(5,5) for display
    """

    def __init__(self, simulate: bool = not HARDWARE_AVAILABLE):
        self.simulate   = simulate
        self.ads_chips  = []
        self.n_cells    = N_CELLS

        # Simulation state: moisture levels for each cell
        self._sim_moisture = np.random.uniform(0.40, 0.70, N_CELLS)
        # Simulation: track which cells are being irrigated
        self._sim_irrigating = np.zeros(N_CELLS, dtype=bool)

        if not simulate:
            self._init_hardware()
        else:
            log.info("SensorManager → SIMULATION mode.")

    def _init_hardware(self) -> None:
        """Initialise I2C bus and all 7 ADS1115 chips."""
        try:
            i2c = busio.I2C(board.SCL, board.SDA)
            for idx, addr in enumerate(ADS_ADDRESSES):
                ads = ADS.ADS1115(i2c, address=addr, gain=1)
                # gain=1 → ±4.096V full-scale, 0.125mV resolution
                self.ads_chips.append(ads)
                log.debug(f"ADS1115 [{idx}] at 0x{addr:02X} — OK")
            log.info(f"All {N_CHIPS} ADS1115 chips ready.")
        except Exception as exc:
            log.error(f"Hardware init failed: {exc} — falling back to simulation.")
            self.simulate = True

    def _read_voltage_hw(self, chip_idx: int, channel: int) -> float:
        """Read one ADS1115 channel. Returns -1.0 on error."""
        try:
            ads  = self.ads_chips[chip_idx]
            pin  = [ADS.P0, ADS.P1, ADS.P2, ADS.P3][channel]
            return AnalogIn(ads, pin).voltage
        except Exception as exc:
            log.warning(f"Read error chip={chip_idx} ch={channel}: {exc}")
            return -1.0

    def _simulate_voltage(self, cell_id: int) -> float:
        """
        Generate realistic simulated voltage for development.
        Applies continuous ET loss and irrigation gain.
        """
        crop_row    = cell_id // N_COLS
        # ET rates by crop row (matching config.py ET_RATE values)
        et_rates    = [0.0034, 0.0034, 0.0028, 0.004, 0.0048]
        et          = et_rates[crop_row] * np.random.uniform(0.7, 1.3)

        self._sim_moisture[cell_id] -= et
        if self._sim_irrigating[cell_id]:
            self._sim_moisture[cell_id] += 0.022 * np.random.uniform(0.8, 1.2)

        self._sim_moisture[cell_id] = np.clip(
            self._sim_moisture[cell_id], THETA_DRY + 0.02, THETA_WET - 0.02
        )
        theta   = self._sim_moisture[cell_id]
        voltage = V_DRY + (V_WET - V_DRY) * (theta - THETA_DRY) / (THETA_WET - THETA_DRY)
        voltage += np.random.normal(0, 0.012)   # sensor noise
        return float(np.clip(voltage, V_MIN_VALID, V_MAX_VALID))

    def _read_temperature(self, cell_id: int) -> float:
        """
        Read soil temperature.
        Simulation: realistic diurnal cycle for Bangeli.
        Hardware: reads from DS18B20 1-Wire sensor.
        """
        if self.simulate:
            hour    = (time.time() % 86400) / 3600
            # Bangeli: soil temp peaks around 14:00, minimum around 06:00
            temp    = 29 + 7 * np.sin((hour - 6) * np.pi / 8)
            temp   += np.random.normal(0, 0.4)
            return float(np.clip(temp, 22, 40))
        # Hardware: DS18B20 via 1-Wire
        # (full implementation in a separate ds18b20.py module)
        return 28.0   # placeholder until DS18B20 module is added

    def set_irrigation_state(self, valve_states: List[bool]) -> None:
        """
        Inform the sensor manager which valves are open,
        so the simulator can apply the correct moisture gain.

        Called by the main control loop after each MPC decision.

        Parameters
        ----------
        valve_states : list of 5 booleans (one per row)
        """
        for cell_id in range(N_CELLS):
            row = cell_id // N_COLS
            self._sim_irrigating[cell_id] = valve_states[row]

    def read_all(self) -> SensorSnapshot:
        """
        Read all 25 soil moisture sensors.

        Steps:
          1. Read ADC voltage (hardware or simulation)
          2. Detect faults
          3. Convert voltage → moisture via calibration
          4. Read soil temperature
          5. Interpolate faulty cells spatially
          6. Compute summary statistics

        Returns
        -------
        SensorSnapshot — full field state at current timestamp
        """
        readings   = []
        fault_mask = np.zeros(N_CELLS, dtype=bool)

        for cell_id in range(N_CELLS):
            row = cell_id // N_COLS
            col = cell_id %  N_COLS

            # 1. Read voltage
            if self.simulate:
                voltage = self._simulate_voltage(cell_id)
            else:
                chip, ch = cell_to_chip_channel(cell_id)
                voltage  = self._read_voltage_hw(chip, ch)

            # 2. Fault detection
            if voltage < 0:
                fault, reason = True, "hardware read error"
            elif voltage < V_MIN_VALID:
                fault, reason = True, f"V={voltage:.2f} < {V_MIN_VALID} (disconnected?)"
            elif voltage > V_MAX_VALID:
                fault, reason = True, f"V={voltage:.2f} > {V_MAX_VALID} (short circuit?)"
            else:
                fault, reason = False, ""

            fault_mask[cell_id] = fault

            # 3. Voltage → moisture
            moisture = 0.0 if fault else voltage_to_moisture(voltage)

            # 4. Temperature
            temp = self._read_temperature(cell_id)

            readings.append(CellReading(
                cell_id      = cell_id,
                row          = row,
                col          = col,
                voltage      = voltage,
                moisture     = moisture,
                temperature  = temp,
                fault        = fault,
                fault_reason = reason,
            ))

        # 5. Spatial interpolation for faulty cells
        if np.any(fault_mask):
            readings = interpolate_faults(readings)

        # 6. Summary statistics
        moistures = np.array([r.moisture for r in readings])
        snapshot  = SensorSnapshot(
            timestamp     = time.time(),
            readings      = readings,
            n_faults      = int(np.sum(fault_mask)),
            mean_moisture = float(np.mean(moistures)),
            min_moisture  = float(np.min(moistures)),
            max_moisture  = float(np.max(moistures)),
        )

        log.debug(
            f"Sensors: mean={snapshot.mean_moisture:.3f} "
            f"min={snapshot.min_moisture:.3f} "
            f"max={snapshot.max_moisture:.3f} "
            f"faults={snapshot.n_faults}"
        )
        return snapshot

    def calibrate_cell(
        self,
        cell_id:     int,
        known_theta: float,
        n_samples:   int = 20,
    ) -> float:
        """
        Field calibration: record mean voltage at a known moisture level.

        Use this during initial setup:
          1. Dry soil → gravimetric θ ≈ wilting point → calibrate_cell(id, 0.12)
          2. Wet soil → gravimetric θ ≈ field capacity → calibrate_cell(id, 0.30)

        Gravimetric method: take a 100g soil sample, weigh it,
        oven-dry at 105°C for 24h, reweigh. 
        θ_gravimetric = (wet_mass - dry_mass) / dry_mass × bulk_density

        Parameters
        ----------
        cell_id     : cell index to calibrate
        known_theta : gravimetric θ at time of measurement [m³/m³]
        n_samples   : readings to average for stability

        Returns
        -------
        mean voltage — record this in config.py calibration table
        """
        voltages = []
        chip, ch = cell_to_chip_channel(cell_id)
        for i in range(n_samples):
            v = self._read_voltage_hw(chip, ch) if not self.simulate \
                else self._simulate_voltage(cell_id)
            if v > 0:
                voltages.append(v)
            time.sleep(0.15)
        mean_v = float(np.mean(voltages)) if voltages else -1.0
        log.info(
            f"Calibration — cell {cell_id}: "
            f"θ={known_theta:.3f} m³/m³ → V_mean={mean_v:.4f} V "
            f"(n={len(voltages)} samples)"
        )
        return mean_v


# ── Standalone test ───────────────────────────────────────────
if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s"
    )
    mgr  = SensorManager(simulate=True)
    snap = mgr.read_all()

    print("\n╔══════════════════════════════════════╗")
    print("║  Smart Agri-Togo — Sensor Snapshot  ║")
    print("╠══════════════════════════════════════╣")
    print(f"║  Mean θ : {snap.mean_moisture:.3f} m³/m³              ║")
    print(f"║  Min  θ : {snap.min_moisture:.3f} m³/m³              ║")
    print(f"║  Max  θ : {snap.max_moisture:.3f} m³/m³              ║")
    print(f"║  Faults : {snap.n_faults}                            ║")
    print("╠══════════════════════════════════════╣")
    print("║  Moisture grid (5×5):                ║")
    grid = snap.as_grid()
    for row in grid:
        line = "  ".join(f"{v:.3f}" for v in row)
        print(f"║    {line}    ║")
    print("╚══════════════════════════════════════╝")
