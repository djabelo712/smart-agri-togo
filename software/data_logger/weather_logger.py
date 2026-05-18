"""
============================================================
 Smart Agri-Togo — Weather Data Logger
 File   : software/data_logger/weather_logger.py
 Author : Ounimborbitibou DJABON
 Purpose: Collect hourly weather data from Open-Meteo API
          and compute FAO-56 Penman-Monteith ET₀.
          Saves to CSV + optionally pushes to Firebase.
 Run    : python weather_logger.py --location "Lome_Togo"
          python weather_logger.py --help
============================================================
"""

import os
import math
import time
import json
import logging
import argparse
from datetime import datetime, timezone
from pathlib import Path

import requests
import pandas as pd

# ── Logging setup ──────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger("weather_logger")

# ── Constants ──────────────────────────────────────────────
BASE_DIR     = Path(__file__).resolve().parent.parent.parent
RAW_DIR      = BASE_DIR / "data" / "weather" / "raw"
PROC_DIR     = BASE_DIR / "data" / "weather" / "processed"
RAW_DIR.mkdir(parents=True, exist_ok=True)
PROC_DIR.mkdir(parents=True, exist_ok=True)

OPEN_METEO_URL = "https://api.open-meteo.com/v1/forecast"

# Default coordinates: Lomé, Togo
DEFAULT_LAT = 9.2488
DEFAULT_LON = 0.7685
DEFAULT_LOC = "Bangeli_Bassar_Togo"

# ── Penman-Monteith ET₀ (FAO-56) ──────────────────────────

def saturation_vapour_pressure(T_celsius: float) -> float:
    """
    Saturation vapour pressure [kPa] at temperature T [°C].
    FAO-56 Eq. 11.
    """
    return 0.6108 * math.exp((17.27 * T_celsius) / (T_celsius + 237.3))


def slope_vapour_pressure_curve(T_celsius: float) -> float:
    """
    Slope of saturation vapour pressure curve Δ [kPa/°C].
    FAO-56 Eq. 13.
    """
    es = saturation_vapour_pressure(T_celsius)
    return (4098 * es) / ((T_celsius + 237.3) ** 2)


def psychrometric_constant(altitude_m: float = 50.0) -> float:
    """
    Psychrometric constant γ [kPa/°C] at given altitude.
    FAO-56 Eq. 8.  Lomé altitude ≈ 20 m.
    """
    P_atm = 101.3 * ((293 - 0.0065 * altitude_m) / 293) ** 5.26
    return 0.000665 * P_atm


def ET0_Penman_Monteith(
    T_max: float,
    T_min: float,
    RH_mean: float,
    u2: float,
    Rs: float,
    altitude_m: float = 333.0,
    G: float = 0.0,
) -> float:
    """
    FAO-56 Penman-Monteith reference evapotranspiration.

    Parameters
    ----------
    T_max    : daily maximum air temperature [°C]
    T_min    : daily minimum air temperature [°C]
    RH_mean  : mean relative humidity [%]
    u2       : wind speed at 2 m height [m/s]
    Rs       : incoming solar radiation [MJ/m²/day]
    altitude_m: site elevation above sea level [m]
    G        : soil heat flux [MJ/m²/day] (≈ 0 for daily calculations)

    Returns
    -------
    ET0 [mm/day]
    """
    T_mean = (T_max + T_min) / 2.0

    # Saturation and actual vapour pressures
    es_max = saturation_vapour_pressure(T_max)
    es_min = saturation_vapour_pressure(T_min)
    es     = (es_max + es_min) / 2.0
    ea     = es * (RH_mean / 100.0)

    # Slope and psychrometric constant
    delta  = slope_vapour_pressure_curve(T_mean)
    gamma  = psychrometric_constant(altitude_m)

    # Net radiation (simplified: assume albedo=0.23, net longwave ≈ 3.5 MJ/m²/d)
    # For a more accurate Rn, we'd need sunshine hours and cloud cover.
    alpha  = 0.23                          # grass albedo
    Rns    = (1 - alpha) * Rs              # net shortwave
    Rnl    = 3.5                           # net longwave (approximate for Togo)
    Rn     = Rns - Rnl

    # Penman-Monteith numerator and denominator
    numerator   = (0.408 * delta * (Rn - G)
                   + gamma * (900.0 / (T_mean + 273.0)) * u2 * (es - ea))
    denominator = delta + gamma * (1.0 + 0.34 * u2)

    ET0 = numerator / denominator
    return max(0.0, ET0)   # physical lower bound


# ── Open-Meteo API fetch ───────────────────────────────────

def fetch_weather(lat: float, lon: float, days_back: int = 1) -> dict:
    """
    Fetch hourly weather data from Open-Meteo for the past `days_back` days.
    Returns raw JSON dict.  Free API — no key required.
    """
    params = {
        "latitude":  lat,
        "longitude": lon,
        "hourly": [
            "temperature_2m",
            "relative_humidity_2m",
            "wind_speed_10m",
            "shortwave_radiation",
            "precipitation",
            "et0_fao_evapotranspiration",   # Open-Meteo also provides ET0 directly
        ],
        "wind_speed_unit": "ms",
        "timezone": "Africa/Lome",
        "past_days": days_back,
        "forecast_days": 3,                 # get 3-day forecast too
    }

    log.info(f"Fetching weather from Open-Meteo (lat={lat}, lon={lon}) ...")
    response = requests.get(OPEN_METEO_URL, params=params, timeout=30)
    response.raise_for_status()
    data = response.json()
    log.info("✓ Weather data received successfully.")
    return data


def parse_hourly(raw: dict) -> pd.DataFrame:
    """
    Parse Open-Meteo hourly JSON into a clean DataFrame.
    Also computes FAO-56 ET₀ independently for validation.
    """
    hourly = raw["hourly"]
    df = pd.DataFrame({
        "timestamp":    pd.to_datetime(hourly["time"]),
        "T_air_C":      hourly["temperature_2m"],
        "RH_pct":       hourly["relative_humidity_2m"],
        "wind_10m_ms":  hourly["wind_speed_10m"],
        "Rs_Wm2":       hourly["shortwave_radiation"],
        "precip_mm":    hourly["precipitation"],
        "ET0_API_mm":   hourly["et0_fao_evapotranspiration"],
    })

    # Convert wind from 10 m to 2 m height (FAO-56 Eq. 47)
    df["wind_2m_ms"] = df["wind_10m_ms"] * (
        math.log(2 / 0.000123) / math.log(10 / 0.000123)
    )

    # Convert shortwave radiation from W/m² to MJ/m²/h (1 W/m² = 0.0036 MJ/m²/h)
    df["Rs_MJm2h"] = df["Rs_Wm2"] * 0.0036

    # Compute daily sums (resample to daily for ET₀ calculation)
    df.set_index("timestamp", inplace=True)
    daily = df.resample("D").agg({
        "T_air_C":    ["max", "min", "mean"],
        "RH_pct":     "mean",
        "wind_2m_ms": "mean",
        "Rs_MJm2h":   "sum",     # sum to get MJ/m²/day
        "precip_mm":  "sum",
        "ET0_API_mm": "sum",     # daily sum of hourly ET0
    })
    daily.columns = [
        "T_max_C", "T_min_C", "T_mean_C",
        "RH_mean_pct", "wind_2m_ms", "Rs_MJm2day",
        "precip_mm", "ET0_API_mm_day",
    ]

    # Compute our own ET₀ for validation and research
    daily["ET0_PM_mm_day"] = daily.apply(
        lambda r: ET0_Penman_Monteith(
            T_max=r["T_max_C"],
            T_min=r["T_min_C"],
            RH_mean=r["RH_mean_pct"],
            u2=r["wind_2m_ms"],
            Rs=r["Rs_MJm2day"],
        ),
        axis=1,
    )

    daily["ET0_diff_mm"] = daily["ET0_PM_mm_day"] - daily["ET0_API_mm_day"]
    daily.reset_index(inplace=True)
    daily.rename(columns={"timestamp": "date"}, inplace=True)
    return daily


def save_raw(raw: dict, location: str) -> Path:
    """Save raw JSON response with timestamp."""
    ts  = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    out = RAW_DIR / f"{location}_{ts}.json"
    with open(out, "w") as f:
        json.dump(raw, f, indent=2)
    log.info(f"Raw data saved → {out}")
    return out


def save_processed(daily: pd.DataFrame, location: str) -> Path:
    """
    Append new daily rows to the master processed CSV.
    Creates the file if it doesn't exist.
    """
    out = PROC_DIR / f"{location}_daily.csv"
    if out.exists():
        existing = pd.read_csv(out, parse_dates=["date"])
        combined = pd.concat([existing, daily], ignore_index=True)
        combined.drop_duplicates(subset="date", keep="last", inplace=True)
        combined.sort_values("date", inplace=True)
    else:
        combined = daily

    combined.to_csv(out, index=False, float_format="%.3f")
    log.info(f"Processed data saved → {out}  ({len(combined)} days total)")
    return out


def print_summary(daily: pd.DataFrame) -> None:
    """Print a human-readable summary of latest data."""
    latest = daily.iloc[-1]
    print("\n" + "=" * 55)
    print(f"  📍 Latest weather summary  ({latest['date'].strftime('%Y-%m-%d')})")
    print("=" * 55)
    print(f"  🌡  T_max / T_min / T_mean : {latest['T_max_C']:.1f} / "
          f"{latest['T_min_C']:.1f} / {latest['T_mean_C']:.1f} °C")
    print(f"  💧  Relative Humidity      : {latest['RH_mean_pct']:.0f} %")
    print(f"  💨  Wind speed (2 m)       : {latest['wind_2m_ms']:.1f} m/s")
    print(f"  ☀  Solar radiation         : {latest['Rs_MJm2day']:.1f} MJ/m²/day")
    print(f"  🌧  Precipitation           : {latest['precip_mm']:.1f} mm")
    print(f"  🌿  ET₀ (our FAO-56)       : {latest['ET0_PM_mm_day']:.2f} mm/day")
    print(f"  🌿  ET₀ (Open-Meteo API)   : {latest['ET0_API_mm_day']:.2f} mm/day")
    print(f"  Δ   Difference             : {latest['ET0_diff_mm']:+.2f} mm/day")
    print("=" * 55 + "\n")


# ── Continuous logging mode ───────────────────────────────

def run_once(lat: float, lon: float, location: str, days_back: int = 1) -> None:
    """Fetch, parse, save and display one cycle of weather data."""
    try:
        raw   = fetch_weather(lat, lon, days_back)
        save_raw(raw, location)
        daily = parse_hourly(raw)
        save_processed(daily, location)
        print_summary(daily)
    except requests.exceptions.ConnectionError:
        log.error("No internet connection. Will retry next cycle.")
    except requests.exceptions.HTTPError as e:
        log.error(f"API HTTP error: {e}")
    except Exception as e:
        log.exception(f"Unexpected error: {e}")


def run_continuous(lat: float, lon: float, location: str,
                   interval_hours: float = 6.0) -> None:
    """
    Run the logger continuously, fetching data every `interval_hours` hours.
    Designed to run 24/7 on the Raspberry Pi.
    """
    interval_s = int(interval_hours * 3600)
    log.info(f"🌱 Smart Agri-Togo Weather Logger started.")
    log.info(f"   Location : {location}  ({lat}°N, {lon}°E)")
    log.info(f"   Interval : every {interval_hours} h  ({interval_s} s)")
    log.info(f"   Data dir : {PROC_DIR}")
    log.info("   Press Ctrl+C to stop.\n")

    while True:
        run_once(lat, lon, location, days_back=1)
        log.info(f"Next fetch in {interval_hours} h. Sleeping ...")
        time.sleep(interval_s)


# ── CLI ───────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Smart Agri-Togo — Weather Data Logger (Open-Meteo + FAO-56 ET₀)"
    )
    parser.add_argument("--lat",      type=float, default=DEFAULT_LAT,
                        help=f"Latitude  (default: {DEFAULT_LAT} — Lomé)")
    parser.add_argument("--lon",      type=float, default=DEFAULT_LON,
                        help=f"Longitude (default: {DEFAULT_LON} — Lomé)")
    parser.add_argument("--location", type=str,   default=DEFAULT_LOC,
                        help="Location name used for file naming")
    parser.add_argument("--days-back", type=int,  default=7,
                        help="Days of past data to fetch on first run (default: 7)")
    parser.add_argument("--interval", type=float, default=6.0,
                        help="Fetch interval in hours for continuous mode (default: 6)")
    parser.add_argument("--once",     action="store_true",
                        help="Fetch once and exit (default: run continuously)")
    args = parser.parse_args()

    if args.once:
        run_once(args.lat, args.lon, args.location, args.days_back)
    else:
        run_continuous(args.lat, args.lon, args.location, args.interval)


if __name__ == "__main__":
    main()
