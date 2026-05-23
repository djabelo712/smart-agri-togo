"""
SmartFarm Togo - ET0 Inference Service
Model 1: XGBoost same-day ET0 estimator
Model 2: 7-day ET0 + Rain forecast (XGBoost + Open-Meteo NWP)
"""
import math
import logging
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional

import joblib
import numpy as np
import pandas as pd
import requests
from xgboost import XGBRegressor

from config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()


# ── Module-level model cache (loaded once at startup) ─────────────────────
_model1: Optional[XGBRegressor] = None
_feature_cols: Optional[list] = None


def load_models():
    """Load Model 1 artifacts into memory. Called once at API startup."""
    global _model1, _feature_cols
    try:
        _model1 = XGBRegressor()
        _model1.load_model(settings.MODEL1_PATH)
        _feature_cols = joblib.load(settings.FEATURE_COLS_PATH)
        logger.info(f"Model 1 loaded: {len(_feature_cols)} features")
    except Exception as e:
        logger.error(f"Could not load Model 1: {e}")


# ── FAO-56 helper functions ───────────────────────────────────────────────

def compute_Ra(doy: int, lat_deg: float = settings.LAT_DEG) -> float:
    lat = math.radians(lat_deg)
    dr = 1 + 0.033 * math.cos(2 * math.pi * doy / 365)
    ds = 0.409 * math.sin(2 * math.pi * doy / 365 - 1.39)
    ws = math.acos(max(-1.0, min(1.0, -math.tan(lat) * math.tan(ds))))
    Ra = (24 * 60 / math.pi) * 0.0820 * dr * (
        ws * math.sin(lat) * math.sin(ds)
        + math.cos(lat) * math.cos(ds) * math.sin(ws)
    )
    return float(Ra)


def compute_ET0_scalar(
    Tmax: float, Tmin: float, Tmean: float,
    RH: float, Wind: float, Rs: float,
    Ra: float, elev_m: float = settings.ELEV_M
) -> float:
    """FAO-56 Penman-Monteith ET0 for a single day."""
    es_max = 0.6108 * math.exp(17.27 * Tmax / (Tmax + 237.3))
    es_min = 0.6108 * math.exp(17.27 * Tmin / (Tmin + 237.3))
    es = (es_max + es_min) / 2
    ea = es * RH / 100
    vpd = max(es - ea, 0.0)
    Delta = 4098 * (0.6108 * math.exp(17.27 * Tmean / (Tmean + 237.3))) / (Tmean + 237.3) ** 2
    gamma = 0.000665 * 101.3 * ((293 - 0.0065 * elev_m) / 293) ** 5.26
    Rso = (0.75 + 2e-5 * elev_m) * Ra
    Rns = 0.77 * Rs
    RsRso = max(0.25, min(1.0, Rs / max(Rso, 0.001)))
    Rnl = (
        4.903e-9
        * ((Tmax + 273.16) ** 4 + (Tmin + 273.16) ** 4) / 2
        * (0.34 - 0.14 * math.sqrt(max(ea, 0)))
        * (1.35 * RsRso - 0.35)
    )
    Rn = Rns - Rnl
    num = 0.408 * Delta * Rn + gamma * (900 / (Tmean + 273)) * Wind * vpd
    den = Delta + gamma * (1 + 0.34 * Wind)
    return float(max(0.0, min(15.0, num / den)))


def build_model1_features(
    df_history: pd.DataFrame,
    weather_today: dict,
    target_date: datetime,
) -> np.ndarray:
    """Build the 26-feature vector for Model 1."""
    if _feature_cols is None:
        raise RuntimeError("Model 1 not loaded. Call load_models() first.")

    doy = target_date.timetuple().tm_yday
    Ra = compute_Ra(doy)

    Tmax  = float(weather_today["Tmax"])
    Tmin  = float(weather_today["Tmin"])
    Tmean = float(weather_today["Tmean"])
    RH    = float(weather_today["RH"])
    Wind  = float(weather_today["Wind"])
    Rs    = float(weather_today["Rs"])
    Rain  = float(weather_today.get("Rain", 0.0) or 0.0)

    es_max = 0.6108 * math.exp(17.27 * Tmax / (Tmax + 237.3))
    es_min = 0.6108 * math.exp(17.27 * Tmin / (Tmin + 237.3))
    vpd = max(((es_max + es_min) / 2) * (1 - RH / 100), 0.0)

    et0_buf   = df_history["ET0"].values
    tmean_buf = df_history["Tmean"].values
    tmax_buf  = df_history["Tmax"].values
    rh_buf    = df_history["RH"].values
    rs_buf    = df_history["Rs"].values

    feat = {
        "Tmax":       Tmax,
        "Tmin":       Tmin,
        "Tmean":      Tmean,
        "RH":         RH,
        "Wind":       Wind,
        "Rs":         Rs,
        "Rain":       Rain,
        "Tdelta":     Tmax - Tmin,
        "VPD":        vpd,
        "Ra":         Ra,
        "doy_sin":    math.sin(2 * math.pi * doy / 365),
        "doy_cos":    math.cos(2 * math.pi * doy / 365),
        "month":      float(target_date.month),
        "ET0_lag1":   float(et0_buf[-1]),
        "ET0_lag2":   float(et0_buf[-2]),
        "ET0_lag7":   float(et0_buf[-7]),
        "Tmean_lag1": float(tmean_buf[-1]),
        "Tmean_lag7": float(tmean_buf[-7]),
        "ET0_roll7":  float(et0_buf[-7:].mean()),
        "ET0_roll30": float(et0_buf[-30:].mean()),
        "Tmax_roll7": float(tmax_buf[-7:].mean()),
        "Tmax_roll30":float(tmax_buf[-30:].mean()),
        "RH_roll7":   float(rh_buf[-7:].mean()),
        "RH_roll30":  float(rh_buf[-30:].mean()),
        "Rs_roll7":   float(rs_buf[-7:].mean()),
        "Rs_roll30":  float(rs_buf[-30:].mean()),
    }
    return np.array([[feat[c] for c in _feature_cols]], dtype=np.float32)


# ── Model 1: today's ET0 ──────────────────────────────────────────────────

def predict_et0_today(weather_today: dict) -> float:
    """Predict ET0 for today using Model 1."""
    if _model1 is None:
        raise RuntimeError("Model 1 not loaded.")

    df_hist = _load_recent_history(days=35)
    target_date = datetime.utcnow()
    X = build_model1_features(df_hist, weather_today, target_date)
    et0 = float(np.clip(_model1.predict(X)[0], 0.5, 15.0))
    return round(et0, 3)


# ── Model 2: 7-day forecast ───────────────────────────────────────────────

def get_nwp_forecast() -> dict:
    """Fetch 7-day NWP weather forecast from Open-Meteo (ECMWF)."""
    resp = requests.get(
        "https://api.open-meteo.com/v1/forecast",
        params={
            "latitude":        settings.LAT_DEG,
            "longitude":       settings.LON_DEG,
            "daily":           [
                "temperature_2m_max", "temperature_2m_min",
                "temperature_2m_mean", "relative_humidity_2m_mean",
                "wind_speed_10m_mean", "shortwave_radiation_sum",
                "precipitation_sum",
            ],
            "forecast_days":   7,
            "wind_speed_unit": "ms",
            "timezone":        "Africa/Lome",
        },
        timeout=15,
    )
    resp.raise_for_status()
    d = resp.json()["daily"]
    return {
        "dates": d["time"],
        "Tmax":  [float(v) if v is not None else 30.0 for v in d["temperature_2m_max"]],
        "Tmin":  [float(v) if v is not None else 22.0 for v in d["temperature_2m_min"]],
        "Tmean": [float(v) if v is not None else 26.0 for v in d["temperature_2m_mean"]],
        "RH":    [float(v) if v is not None else 75.0 for v in d["relative_humidity_2m_mean"]],
        "Wind":  [float(v) if v is not None else 3.0  for v in d["wind_speed_10m_mean"]],
        "Rs":    [float(v) / 1000.0 if v is not None else 15.0 for v in d["shortwave_radiation_sum"]],
        "Rain":  [float(v) if v is not None else 0.0  for v in d["precipitation_sum"]],
    }


def predict_et0_7days() -> dict:
    """
    7-day ET0 and rain forecast using Model 1 (rolling) + Open-Meteo NWP.
    """
    if _model1 is None:
        raise RuntimeError("Model 1 not loaded.")

    nwp = get_nwp_forecast()
    df_buffer = _load_recent_history(days=35)
    et0_forecasts = []

    for i in range(7):
        forecast_date = datetime.strptime(nwp["dates"][i], "%Y-%m-%d")
        weather = {
            "Tmax":  nwp["Tmax"][i],
            "Tmin":  nwp["Tmin"][i],
            "Tmean": nwp["Tmean"][i],
            "RH":    nwp["RH"][i],
            "Wind":  nwp["Wind"][i],
            "Rs":    nwp["Rs"][i],
            "Rain":  nwp["Rain"][i],
        }
        X = build_model1_features(df_buffer, weather, forecast_date)
        et0 = float(np.clip(_model1.predict(X)[0], 0.5, 15.0))
        et0_forecasts.append(round(et0, 3))

        # Add predicted day to buffer for next iteration
        doy = forecast_date.timetuple().tm_yday
        Ra = compute_Ra(doy)
        new_row = pd.DataFrame([{
            "Tmax": weather["Tmax"], "Tmin": weather["Tmin"],
            "Tmean": weather["Tmean"], "RH": weather["RH"],
            "Wind": weather["Wind"], "Rs": weather["Rs"],
            "Rain": weather["Rain"], "ET0": et0,
        }], index=[forecast_date])
        df_buffer = pd.concat([df_buffer, new_row])

    return {
        "dates":       nwp["dates"],
        "et0_7days":   et0_forecasts,
        "rain_7days":  [round(r, 1) for r in nwp["Rain"]],
        "generated_at": datetime.utcnow().isoformat(),
    }


# ── Internal: load recent history from NASA POWER CSV ─────────────────────

def _compute_et0_column(df: pd.DataFrame) -> pd.DataFrame:
    """Add ET0 column to a historical dataframe."""
    doy_arr = df.index.dayofyear.values
    Tmax  = df["Tmax"].values; Tmin = df["Tmin"].values
    Tmean = df["Tmean"].values; RH = df["RH"].values
    Wind  = df["Wind"].values; Rs = df["Rs"].values
    lat = math.radians(settings.LAT_DEG)
    et0_vals = []
    for i in range(len(df)):
        Ra = compute_Ra(int(doy_arr[i]))
        et0 = compute_ET0_scalar(
            Tmax[i], Tmin[i], Tmean[i],
            RH[i], Wind[i], Rs[i], Ra
        )
        et0_vals.append(et0)
    df = df.copy()
    df["ET0"] = et0_vals
    return df


def _load_recent_history(days: int = 35) -> pd.DataFrame:
    """Load last N days of weather + ET0 from NASA POWER CSV."""
    RENAME = {
        "T2M": "Tmean", "T2M_MAX": "Tmax", "T2M_MIN": "Tmin",
        "RH2M": "RH", "WS2M": "Wind",
        "ALLSKY_SFC_SW_DWN": "Rs", "PRECTOTCORR": "Rain",
    }
    df = pd.read_csv(settings.NASA_CSV_PATH, index_col="date", parse_dates=True)
    df = df.rename(columns=RENAME)
    df.replace(-999.0, float("nan"), inplace=True)
    df = df.ffill().bfill()
    df = _compute_et0_column(df)
    return df.tail(days)
