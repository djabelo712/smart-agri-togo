"""
Smart Agri-Togo — System Configuration
File: software/edge_controller/config.py

All physical parameters, calibration constants, and system settings.
Edit this file to match your actual field measurements after soil sampling.
"""

# ── Field geometry ────────────────────────────────────────
FIELD_SIZE_M     = 25.0      # field side length [m]
GRID_ROWS        = 5
GRID_COLS        = 5
N_CELLS          = GRID_ROWS * GRID_COLS   # 25

# ── Site location ─────────────────────────────────────────
LATITUDE_DEG     = 9.2488    # Bangeli, Bassar District, Kara Region, Togo
LONGITUDE_DEG    = 0.7685
ALTITUDE_M       = 333.0      # elevation above sea level [m]

# ── Soil parameters (update after lab analysis) ───────────
# Default values for sandy loam — southern Togo
THETA_FC         = 0.30      # field capacity [m³/m³]
THETA_WP         = 0.12      # permanent wilting point [m³/m³]
THETA_SAT        = 0.45      # saturated water content [m³/m³]
ROOT_DEPTH_M     = 0.30      # root zone depth [m] — average across crops

# Van Genuchten parameters (update after calibration)
VG_ALPHA         = 0.036     # [1/cm]
VG_N             = 1.56      # dimensionless
VG_KS            = 0.025     # saturated hydraulic conductivity [m/h]

# ── Crop parameters ───────────────────────────────────────
# Row assignment: row index 0-4 → crop
CROP_PER_ROW     = {0: "onion", 1: "onion", 2: "carrot", 3: "lettuce", 4: "maize"}

# FAO-56 depletion fractions p (before stress)
DEPLETION_FRACTION = {"onion": 0.30, "carrot": 0.35, "lettuce": 0.30, "maize": 0.55}

# FAO-56 mid-season crop coefficients Kc
KC_MID           = {"onion": 1.05, "carrot": 1.05, "lettuce": 1.00, "maize": 1.20}

# ── MPC parameters ───────────────────────────────────────
MPC_HORIZON      = 48        # prediction horizon [steps]
MPC_DT_MIN       = 30        # time step [minutes]
MPC_ALPHA        = 0.70      # yield penalty weight
MPC_BETA         = 0.30      # water-use penalty weight
MPC_THETA_TARGET = 0.65      # target soil moisture (fraction of FC)
MPC_THETA_LOW    = 0.40      # lower threshold — triggers irrigation

# ── Hardware limits ───────────────────────────────────────
PUMP_FLOW_MAX_LPH   = 2880   # max pump flow [L/h] = 0.8 L/s
IRR_RATE_MAX_MMH    = 3.0    # max irrigation rate per cell [mm/h]
TOTAL_FLOW_MAX_MMH  = 10.0   # total flow across all open valves [mm/h]
VALVE_MIN_ON_MIN    = 30     # minimum valve-on duration [min]

# ── GPIO pin mapping (Raspberry Pi 4) ────────────────────
# Valve relay pins (BCM numbering) — one per row
VALVE_PINS       = {0: 17, 1: 27, 2: 22, 3: 23, 4: 24}
PUMP_PIN         = 25        # main pump relay pin

# ── Firebase (fill in after Firebase project setup) ───────
FIREBASE_URL     = "https://YOUR-PROJECT.firebaseio.com"
FIREBASE_KEY     = "secrets/firebase_credentials.json"   # not committed to git

# ── Logging ───────────────────────────────────────────────
LOG_INTERVAL_MIN = 30        # how often to log sensor data [min]
DATA_DIR         = "../../data"
