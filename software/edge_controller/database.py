"""
============================================================
 Smart Agri-Togo — Data Logging Module
 File   : software/edge_controller/database.py
 Author : Ounimborbitibou DJABON

 Storage strategy:
   Primary   : SQLite (local, on RPi SD card)
               → No internet required, zero config, fast
               → All data safe even without connectivity
   Secondary : Firebase Realtime Database (cloud sync)
               → Enables mobile app dashboard
               → Synced in background every N minutes
               → Stub ready — add credentials to activate

 Database schema (SQLite):
   Table: sensor_readings
     id, timestamp, cell_id, row, col,
     moisture, voltage, temperature, fault

   Table: valve_events
     id, timestamp, row, action (OPEN/CLOSE),
     duration_s, water_volume_l

   Table: mpc_decisions
     id, timestamp, controller (MPC/PID),
     cost_j, solve_time_s, valve_states (JSON)

   Table: weather_data
     id, timestamp, t_max, t_min, rh_mean,
     wind_2m, rs_mjm2, precip_mm, et0_mm

   Table: harvest_records
     id, date, cell_id, crop, yield_kg, notes
============================================================
"""

import os
import json
import time
import logging
import sqlite3
import threading
from pathlib import Path
from typing import Optional, List, Dict, Any

log = logging.getLogger("database")

# ── Paths ─────────────────────────────────────────────────────
BASE_DIR = Path(__file__).resolve().parent.parent.parent
DB_PATH  = BASE_DIR / "data" / "field_data.sqlite"
DB_PATH.parent.mkdir(parents=True, exist_ok=True)

# ── Firebase (optional) ───────────────────────────────────────
FIREBASE_SYNC_INTERVAL_S = 300   # sync every 5 minutes
try:
    import firebase_admin
    from firebase_admin import credentials, db as firebase_db
    FIREBASE_AVAILABLE = True
except ImportError:
    FIREBASE_AVAILABLE = False


# ── Database manager ──────────────────────────────────────────

class DataLogger:
    """
    Handles all data persistence for Smart Agri-Togo.

    Writes to local SQLite immediately (never loses data).
    Syncs to Firebase Realtime DB in background (when configured).

    Thread-safe: uses a dedicated SQLite connection per thread
    and a separate sync thread for Firebase.

    Example
    -------
    db = DataLogger()
    db.log_sensor_snapshot(snapshot)
    db.log_valve_event(row=2, action="OPEN")
    db.log_mpc_decision(controller="MPC", cost=2.34, solve_s=8.1, states=[...])
    """

    def __init__(
        self,
        db_path:          Path = DB_PATH,
        enable_firebase:  bool = False,
        firebase_url:     str  = "",
        firebase_keyfile: str  = "",
    ):
        self.db_path         = db_path
        self.enable_firebase = enable_firebase and FIREBASE_AVAILABLE
        self._local          = threading.local()  # thread-local DB connections
        self._firebase_db    = None
        self._valve_open_times: Dict[int, float] = {}  # row → open timestamp

        self._create_tables()

        if self.enable_firebase:
            self._init_firebase(firebase_url, firebase_keyfile)
            self._start_sync_thread()

        log.info(f"DataLogger initialised → {db_path}")

    # ── SQLite connection ─────────────────────────────────────

    @property
    def _conn(self) -> sqlite3.Connection:
        """Thread-local SQLite connection (one per thread)."""
        if not hasattr(self._local, "conn"):
            self._local.conn = sqlite3.connect(
                self.db_path,
                check_same_thread=False,
            )
            self._local.conn.row_factory = sqlite3.Row
            self._local.conn.execute("PRAGMA journal_mode=WAL")  # write-ahead log
            self._local.conn.execute("PRAGMA synchronous=NORMAL") # balanced safety
        return self._local.conn

    def _execute(self, sql: str, params: tuple = ()) -> sqlite3.Cursor:
        """Execute SQL and commit. Reconnects on error."""
        try:
            cur = self._conn.execute(sql, params)
            self._conn.commit()
            return cur
        except sqlite3.Error as exc:
            log.error(f"SQLite error: {exc}\nSQL: {sql}")
            raise

    def _create_tables(self) -> None:
        """Create all tables if they do not exist."""
        ddl_statements = [

            # ── Sensor readings ──────────────────────────
            """CREATE TABLE IF NOT EXISTS sensor_readings (
                id          INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp   REAL    NOT NULL,
                cell_id     INTEGER NOT NULL,
                row         INTEGER NOT NULL,
                col         INTEGER NOT NULL,
                moisture    REAL,
                voltage     REAL,
                temperature REAL,
                fault       INTEGER DEFAULT 0,
                fault_reason TEXT DEFAULT ''
            )""",

            """CREATE INDEX IF NOT EXISTS idx_sensor_ts
               ON sensor_readings (timestamp)""",

            """CREATE INDEX IF NOT EXISTS idx_sensor_cell
               ON sensor_readings (cell_id, timestamp)""",

            # ── Valve events ─────────────────────────────
            """CREATE TABLE IF NOT EXISTS valve_events (
                id          INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp   REAL    NOT NULL,
                row         INTEGER NOT NULL,
                action      TEXT    NOT NULL,   -- 'OPEN' or 'CLOSE'
                duration_s  REAL    DEFAULT 0,  -- only for CLOSE events
                water_vol_l REAL    DEFAULT 0   -- estimated litres delivered
            )""",

            # ── MPC/PID decisions ─────────────────────────
            """CREATE TABLE IF NOT EXISTS control_decisions (
                id           INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp    REAL NOT NULL,
                controller   TEXT NOT NULL,     -- 'MPC', 'PID', or 'MANUAL'
                cost_j       REAL,
                solve_time_s REAL,
                valve_states TEXT,              -- JSON array [true/false ×5]
                i_opt        TEXT               -- JSON array of 25 values [mm/h]
            )""",

            # ── Weather data ──────────────────────────────
            """CREATE TABLE IF NOT EXISTS weather_data (
                id         INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp  REAL    NOT NULL,
                date       TEXT,
                t_max_c    REAL,
                t_min_c    REAL,
                rh_mean    REAL,
                wind_2m    REAL,
                rs_mjm2day REAL,
                precip_mm  REAL,
                et0_api    REAL,
                et0_pm     REAL
            )""",

            # ── Harvest records ───────────────────────────
            """CREATE TABLE IF NOT EXISTS harvest_records (
                id         INTEGER PRIMARY KEY AUTOINCREMENT,
                date       TEXT NOT NULL,
                cell_id    INTEGER,
                crop       TEXT,
                yield_kg   REAL,
                quality    TEXT,   -- 'commercial', 'non-commercial', 'loss'
                notes      TEXT
            )""",
        ]

        for ddl in ddl_statements:
            self._execute(ddl)
        log.debug("Database tables ready.")

    # ── Logging methods ───────────────────────────────────────

    def log_sensor_snapshot(self, snapshot) -> None:
        """
        Log all 25 cell readings from a SensorSnapshot to SQLite.

        Parameters
        ----------
        snapshot : SensorSnapshot object from sensors.py
        """
        rows = [
            (
                snapshot.timestamp,
                r.cell_id, r.row, r.col,
                r.moisture, r.voltage, r.temperature,
                int(r.fault), r.fault_reason,
            )
            for r in snapshot.readings
        ]
        self._conn.executemany(
            """INSERT INTO sensor_readings
               (timestamp, cell_id, row, col,
                moisture, voltage, temperature, fault, fault_reason)
               VALUES (?,?,?,?,?,?,?,?,?)""",
            rows,
        )
        self._conn.commit()
        log.debug(f"Logged {len(rows)} sensor readings at t={snapshot.timestamp:.0f}")

    def log_valve_open(self, row: int) -> None:
        """Record a valve OPEN event."""
        ts = time.time()
        self._valve_open_times[row] = ts
        self._execute(
            "INSERT INTO valve_events (timestamp, row, action) VALUES (?,?,?)",
            (ts, row, "OPEN"),
        )

    def log_valve_close(self, row: int, flow_rate_lph: float = 2880.0) -> None:
        """
        Record a valve CLOSE event with duration and water volume.

        Parameters
        ----------
        row           : row index 0–4
        flow_rate_lph : pump flow rate [L/h], used to compute water volume
        """
        ts       = time.time()
        open_ts  = self._valve_open_times.get(row, ts)
        duration = ts - open_ts
        water_l  = (duration / 3600.0) * flow_rate_lph

        self._execute(
            """INSERT INTO valve_events
               (timestamp, row, action, duration_s, water_vol_l)
               VALUES (?,?,?,?,?)""",
            (ts, row, "CLOSE", duration, water_l),
        )
        log.info(
            f"Valve row {row} closed: duration={duration:.1f}s, "
            f"water={water_l:.1f}L"
        )

    def log_control_decision(
        self,
        controller:   str,
        cost_j:       float,
        solve_time_s: float,
        valve_states: List[bool],
        i_opt:        Optional[List[float]] = None,
    ) -> None:
        """
        Log a control decision (MPC or PID).

        Parameters
        ----------
        controller   : 'MPC', 'PID', or 'MANUAL'
        cost_j       : MPC cost function value J
        solve_time_s : time taken to solve QP
        valve_states : list of 5 booleans
        i_opt        : optimal irrigation vector (25 values) or None
        """
        self._execute(
            """INSERT INTO control_decisions
               (timestamp, controller, cost_j, solve_time_s,
                valve_states, i_opt)
               VALUES (?,?,?,?,?,?)""",
            (
                time.time(),
                controller,
                cost_j,
                solve_time_s,
                json.dumps([bool(v) for v in valve_states]),
                json.dumps([float(x) for x in i_opt]) if i_opt is not None else None,
            ),
        )

    def log_weather(self, weather_row: dict) -> None:
        """
        Log one day of weather data (from weather_logger.py output).

        Parameters
        ----------
        weather_row : dict with keys matching weather CSV columns
        """
        self._execute(
            """INSERT OR REPLACE INTO weather_data
               (timestamp, date, t_max_c, t_min_c, rh_mean,
                wind_2m, rs_mjm2day, precip_mm, et0_api, et0_pm)
               VALUES (?,?,?,?,?,?,?,?,?,?)""",
            (
                time.time(),
                str(weather_row.get("date", "")),
                weather_row.get("T_max_C"),
                weather_row.get("T_min_C"),
                weather_row.get("RH_mean_pct"),
                weather_row.get("wind_2m_ms"),
                weather_row.get("Rs_MJm2day"),
                weather_row.get("precip_mm"),
                weather_row.get("ET0_API_mm_day"),
                weather_row.get("ET0_PM_mm_day"),
            ),
        )

    def log_harvest(
        self,
        cell_id:  int,
        crop:     str,
        yield_kg: float,
        quality:  str = "commercial",
        notes:    str = "",
    ) -> None:
        """Record harvest yield for a single cell."""
        import datetime
        self._execute(
            """INSERT INTO harvest_records
               (date, cell_id, crop, yield_kg, quality, notes)
               VALUES (?,?,?,?,?,?)""",
            (
                datetime.date.today().isoformat(),
                cell_id, crop, yield_kg, quality, notes,
            ),
        )
        log.info(f"Harvest logged: cell {cell_id} {crop} → {yield_kg:.2f} kg")

    # ── Query methods ─────────────────────────────────────────

    def get_latest_moisture(self) -> Optional[Dict[int, float]]:
        """
        Return the most recent moisture reading for each cell.

        Returns
        -------
        dict {cell_id: moisture} or None if no data
        """
        rows = self._conn.execute(
            """SELECT cell_id, moisture
               FROM sensor_readings
               WHERE timestamp = (
                   SELECT MAX(timestamp) FROM sensor_readings
               )"""
        ).fetchall()
        if not rows:
            return None
        return {r["cell_id"]: r["moisture"] for r in rows}

    def get_total_water_used_l(self) -> float:
        """Total water delivered by all valves since logging started."""
        result = self._conn.execute(
            "SELECT COALESCE(SUM(water_vol_l), 0) FROM valve_events WHERE action='CLOSE'"
        ).fetchone()
        return float(result[0])

    def get_season_summary(self) -> dict:
        """Return a summary of the current season's data."""
        n_readings = self._conn.execute(
            "SELECT COUNT(*) FROM sensor_readings"
        ).fetchone()[0]
        n_decisions = self._conn.execute(
            "SELECT COUNT(*) FROM control_decisions"
        ).fetchone()[0]
        water_l = self.get_total_water_used_l()
        n_faults = self._conn.execute(
            "SELECT COUNT(*) FROM sensor_readings WHERE fault=1"
        ).fetchone()[0]

        return {
            "n_sensor_readings": n_readings,
            "n_control_decisions": n_decisions,
            "total_water_l": round(water_l, 1),
            "total_water_m3": round(water_l / 1000, 3),
            "n_sensor_faults": n_faults,
        }

    # ── Firebase sync (stub) ──────────────────────────────────

    def _init_firebase(self, url: str, keyfile: str) -> None:
        """Initialise Firebase Admin SDK."""
        try:
            cred = credentials.Certificate(keyfile)
            firebase_admin.initialize_app(cred, {"databaseURL": url})
            self._firebase_db = firebase_db
            log.info("Firebase connection established.")
        except Exception as exc:
            log.warning(f"Firebase init failed: {exc} — cloud sync disabled.")
            self.enable_firebase = False

    def _sync_to_firebase(self) -> None:
        """
        Push latest sensor readings and valve states to Firebase.
        Called periodically by the sync thread.
        This powers the real-time mobile app dashboard.
        """
        if not self.enable_firebase or not self._firebase_db:
            return
        try:
            moisture_dict = self.get_latest_moisture()
            if moisture_dict:
                self._firebase_db.reference("/field/moisture").set(moisture_dict)
            summary = self.get_season_summary()
            self._firebase_db.reference("/field/summary").set(summary)
            log.debug("Firebase sync complete.")
        except Exception as exc:
            log.warning(f"Firebase sync error: {exc}")

    def _start_sync_thread(self) -> None:
        """Start background thread for periodic Firebase sync."""
        def _loop():
            while True:
                time.sleep(FIREBASE_SYNC_INTERVAL_S)
                self._sync_to_firebase()
        t = threading.Thread(target=_loop, daemon=True)
        t.start()
        log.info(f"Firebase sync thread started (every {FIREBASE_SYNC_INTERVAL_S}s).")


# ── Standalone test ───────────────────────────────────────────
if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s"
    )
    import tempfile, numpy as np
    from pathlib import Path

    # Use a temp DB for testing
    tmp = Path(tempfile.mktemp(suffix=".sqlite"))
    db  = DataLogger(db_path=tmp)

    # Simulate logging a control decision
    db.log_control_decision(
        controller="MPC",
        cost_j=2.34,
        solve_time_s=8.2,
        valve_states=[True, False, True, False, False],
        i_opt=list(np.random.uniform(0, 2, 25)),
    )

    db.log_valve_open(0)
    time.sleep(0.1)
    db.log_valve_close(0)

    summary = db.get_season_summary()
    print(f"\nDatabase test summary: {summary}")
    tmp.unlink()
    print("✓ DataLogger test passed.")
