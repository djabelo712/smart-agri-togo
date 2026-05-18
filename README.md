# 🌱 Smart Agri-Togo

**Intelligent Counter-Season Irrigation System for Smallholder Farming in Togo**

> A research and deployment project combining Optimal Control, Machine Learning, and IoT
> technology to make profitable dry-season agriculture accessible to young Togolese farmers.

---

## 📋 Project Overview

Smart Agri-Togo is a **research-first, deploy-second** agritech project targeting the
counter-season vegetable market in Togo (onion, carrot, lettuce, maize). The system uses:

- **Model Predictive Control (MPC)** for optimal irrigation scheduling
- **LSTM neural networks** for 48-hour ET₀ and rainfall forecasting
- **IoT sensor network** (25 soil moisture probes on a 5×5 grid)
- **Remote smartphone control** via Firebase + Flutter mobile app
- **100% organic fertilization** via composting, biogas digestate, and human biosolids
- **Off-grid solar power** (1.1 kWp PV + 200 Ah LiFePO4 battery bank)

**Pilot field**: 25 m × 25 m (625 m²), Lomé area, Togo  
**Target season**: October–April (dry counter-season)  
**Primary crops**: Onion 🧅 · Carrot 🥕 · Lettuce 🥬 · Maize 🌽

---

## 🗂️ Repository Structure

```
smart-agri-togo/
│
├── docs/                        # Project documentation
│   ├── report/                  # Full feasibility & strategic report (PDF + LaTeX)
│   ├── course/                  # Technical course: Math, Irrigation, Fertilization, Energy
│   ├── images/                  # Diagrams, simulation screenshots
│   └── hardware_diagrams/       # Wiring schematics, PCB layouts
│
├── data/                        # All project data (raw + processed)
│   ├── weather/
│   │   ├── raw/                 # Raw Open-Meteo API responses (JSON)
│   │   └── processed/           # Cleaned CSV: timestamp, T, RH, Rs, u2, ET0
│   ├── soil/                    # Lab soil analysis results
│   ├── sensors/                 # Real-time field sensor readings
│   └── harvest/                 # Season yield records per cell
│
├── hardware/                    # Physical system specifications
│   ├── wiring/                  # Circuit diagrams (RPi, Arduino, sensors, valves)
│   └── bom/                     # Bill of Materials with suppliers & prices
│
├── software/                    # All source code
│   ├── edge_controller/         # Raspberry Pi 4 — main control loop
│   │   ├── main.py              # Entry point — runs the MPC loop
│   │   ├── sensors.py           # Soil moisture, temperature, EC reading
│   │   ├── valves.py            # Solenoid valve control via GPIO/relay
│   │   ├── mpc_controller.py    # MPC solver (cvxpy + OSQP)
│   │   ├── pid_controller.py    # PID baseline controller
│   │   └── config.py            # System parameters & calibration constants
│   │
│   ├── data_logger/             # Data acquisition & logging
│   │   ├── weather_logger.py    # ← Open-Meteo API logger (BUILT FIRST)
│   │   ├── sensor_logger.py     # Field sensor data logger
│   │   └── firebase_sync.py     # Push data to Firebase Realtime DB
│   │
│   ├── ml_models/               # Machine learning pipelines
│   │   ├── et0_lstm/            # LSTM for ET₀ & rainfall forecasting
│   │   ├── soil_gpr/            # Gaussian Process for sensor gap-filling
│   │   ├── crop_health_cnn/     # MobileNetV3 for plant stress detection
│   │   └── yield_rf/            # Random Forest for yield prediction
│   │
│   ├── cloud/                   # Cloud backend
│   │   ├── firebase_config.py   # Firebase credentials & setup
│   │   └── api/                 # FastAPI REST endpoints for mobile app
│   │
│   └── mobile_app/              # Flutter cross-platform app (Android/iOS)
│
├── energy/                      # Power system design
│   ├── solar_sizing/            # PV system calculations
│   └── load_analysis/           # Energy audit & daily load profile
│
├── fertilization/               # Organic input management
│   ├── compost_plan/            # Compost pile designs & schedules
│   ├── biogas_design/           # Fixed-dome digester specs
│   └── nutrient_budget/         # Annual N/P/K budget per crop
│
├── research/                    # Scientific research outputs
│   ├── experiments/             # Experimental treatment data (MPC vs PID vs manual)
│   ├── analysis/                # Statistical analysis scripts
│   └── papers/                  # Publication drafts
│
├── scripts/                     # Utility scripts
│   ├── setup/
│   │   ├── install.sh           # Install all Python dependencies
│   │   └── setup_rpi.sh         # Raspberry Pi first-time configuration
│   └── utils/                   # Helper utilities
│
└── tests/                       # Unit and integration tests
    ├── test_mpc.py
    ├── test_sensors.py
    └── test_et0.py
```

---

## 🚀 Quick Start

### 1. Clone and install
```bash
git clone https://github.com/YOUR_USERNAME/smart-agri-togo.git
cd smart-agri-togo
pip install -r requirements.txt
```

### 2. Start weather data collection (no hardware needed)
```bash
cd software/data_logger
python weather_logger.py --lat 6.137 --lon 1.212 --location "Lome_Togo"
```

### 3. Run the MPC simulation
```bash
cd software/edge_controller
python main.py --mode simulation
```

---

## 📦 Hardware Requirements

| Component | Model | Qty | Cost (XOF) |
|-----------|-------|-----|------------|
| Microcontroller | Raspberry Pi 4B (4GB) | 1 | 75,000 |
| Arduino + relay | Arduino Mega + 8-ch relay | 4 | 100,000 |
| Soil moisture sensors | Capacitive v1.2 | 25 | 125,000 |
| Solenoid valves | 12V DC, 1/2" | 25 | 200,000 |
| Weather station | Ecowitt HP2550 | 1 | 120,000 |
| GSM module | SIM7600 4G HAT | 1 | 40,000 |
| Solar panels | 375Wp monocrystalline | 3 | 360,000 |
| Battery bank | 200Ah LiFePO4 48V | 1 | 600,000 |
| MPPT controller | Victron SmartSolar 60A | 1 | 180,000 |
| Inverter | 2kVA pure sine 48V | 1 | 250,000 |
| Drip irrigation kit | 25m × 25m system | 1 | 150,000 |

**Total hardware: ~2,200,000 XOF (~USD 3,600)**

---

## 📊 Economic Projection (1 ha scale)

| Scenario | Revenue/season | Operating costs | Net margin |
|----------|---------------|-----------------|------------|
| Conservative (–30%) | 3,700,000 XOF | 1,200,000 XOF | 2,500,000 XOF |
| Baseline | 5,300,000 XOF | 1,200,000 XOF | 4,100,000 XOF |
| Optimistic (+20%) | 6,600,000 XOF | 1,200,000 XOF | 5,400,000 XOF |

**Payback period: < 1 season**

---

## 🔬 Research Phase (Phase 1)

The pilot is designed as a scientific experiment:
- **Treatment T1**: MPC controller (9 cells)
- **Treatment T2**: PID controller (9 cells)
- **Treatment T3**: Manual farmer control (7 cells)

Target publication: *Agricultural Water Management* or *Computers and Electronics in Agriculture*

---

## 🌿 Organic Inputs

| Source | Annual supply | N provided |
|--------|--------------|------------|
| Composted cow manure | 15 t/ha | 112 kg N |
| Biogas digestate | 5 t/ha | 80 kg N |
| Stored urine | 2.7 t/ha | 97 kg N |
| Vermicompost | 1 t/ha | 18 kg N |

Zero synthetic fertilisers. All inputs locally sourced. Products certified bio.

---

## ⚡ Energy System

- **Solar PV**: 3 × 375 Wp = 1.125 kWp
- **Battery**: 200 Ah / 48V LiFePO4 (2-day autonomy)
- **Daily generation**: ~4.9 kWh/day
- **Daily demand**: ~3.82 kWh/day
- **LCOE**: 62 XOF/kWh (vs 560 XOF/kWh for diesel)

---

## 👨‍🔬 Author

**Ounimborbitibou DJABON**  
MSc student — MPFA-PT (Physique Théorique), Université de Lomé  
AgroLab Africa Team, AIMS Ghana  

---

## 📄 License

MIT License — see [LICENSE](LICENSE)

---

## 📚 Documentation

- [Full Project Report (PDF)](docs/report/smart_agri_togo_report.pdf)
- [Technical Course — Math, Irrigation, Fertilization, Energy (PDF)](docs/course/smart_agri_togo_course.pdf)
- [Live Farm Simulation](docs/images/smart_agri_simulation.html)
