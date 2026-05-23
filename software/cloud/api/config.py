"""
SmartFarm Togo - FastAPI Configuration
All sensitive values come from .env -- never hardcoded.
"""
import os
from pathlib import Path
from functools import lru_cache
from pydantic_settings import BaseSettings


# Project root (two levels up from software/cloud/api/)
PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent.parent


class Settings(BaseSettings):
    # ── App ───────────────────────────────────────────────────────────────
    APP_NAME: str = "SmartFarm Togo API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False

    # ── Security ──────────────────────────────────────────────────────────
    SECRET_KEY: str = "change-this-in-production-use-openssl-rand-hex-32"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_HOURS: int = 24

    # ── Admin credentials (change in .env) ────────────────────────────────
    ADMIN_EMAIL: str = "admin@smartfarmtogo.org"
    ADMIN_PASSWORD: str = "change-this-password"

    # ── Firebase ──────────────────────────────────────────────────────────
    FIREBASE_CREDENTIALS_PATH: str = ""
    FIREBASE_DATABASE_URL: str = ""

    # ── Hardware ──────────────────────────────────────────────────────────
    # Set to True on Raspberry Pi, False on cloud server
    HARDWARE_MODE: bool = False
    ARDUINO_PORT: str = "/dev/ttyUSB0"
    ARDUINO_BAUDRATE: int = 115200

    # ── ML Models ─────────────────────────────────────────────────────────
    MODEL1_PATH: str = str(
        PROJECT_ROOT / "software" / "ml_models" / "et0_lstm" / "xgb_et0_model.json"
    )
    FEATURE_COLS_PATH: str = str(
        PROJECT_ROOT / "software" / "ml_models" / "et0_lstm" / "feature_cols.pkl"
    )
    MODEL3_PATH: str = str(
        PROJECT_ROOT / "software" / "ml_models" / "yield_model" / "yield_rf_model.pkl"
    )
    MODEL3_PARAMS_PATH: str = str(
        PROJECT_ROOT / "software" / "ml_models" / "yield_model" / "yield_model_params.json"
    )

    # ── Data ──────────────────────────────────────────────────────────────
    NASA_CSV_PATH: str = str(
        PROJECT_ROOT / "data" / "weather" / "raw" / "nasa_power_lome.csv"
    )
    SQLITE_PATH: str = str(
        PROJECT_ROOT / "data" / "smartfarm.db"
    )

    # ── Location ──────────────────────────────────────────────────────────
    LAT_DEG: float = 6.1375
    LON_DEG: float = 1.2123
    ELEV_M: float = 10.0

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache()
def get_settings() -> Settings:
    return Settings()
