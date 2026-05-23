"""
SmartFarm Togo - Daily Weather Data Logger
==========================================
Collects daily weather data for two locations via Open-Meteo API:
  - Lome     (6.1375 N, 1.2123 E) -- project deployment site
  - Bangeli  (9.2488 N, 0.7685 E) -- original research site

Each location gets its own CSV file. The script is incremental:
it only downloads the days that are missing since the last run.

Usage:
  python weather_logger.py            # update both locations
  python weather_logger.py --once     # same, used for cron/GitHub Actions
  python weather_logger.py --backfill # download full history from 2015-01-01

The script is safe to run multiple times -- it never duplicates records.
"""

import argparse
import sys
import time
from datetime import date, datetime, timedelta
from pathlib import Path

import pandas as pd
import requests

# ── Location definitions ──────────────────────────────────────────────────────
LOCATIONS = {
    "Lome": {
        "lat":      6.1375,
        "lon":      1.2123,
        "elev_m":   10,
        "timezone": "Africa/Lome",
        "csv":      "data/weather/processed/Lome_Togo_daily.csv",
    },
    "Bangeli": {
        "lat":      9.2488,
        "lon":      0.7685,
        "elev_m":   333,
        "timezone": "Africa/Lome",
        "csv":      "data/weather/processed/Bangeli_Bassar_Togo_daily.csv",
    },
}

# ── Variables to collect ──────────────────────────────────────────────────────
DAILY_VARS = [
    "temperature_2m_max",
    "temperature_2m_min",
    "temperature_2m_mean",
    "relative_humidity_2m_mean",
    "wind_speed_10m_mean",
    "shortwave_radiation_sum",
    "precipitation_sum",
    "et0_fao_evapotranspiration",   # Open-Meteo's own ET0 (cross-check)
    "precipitation_hours",
]

COLUMN_RENAME = {
    "temperature_2m_max":          "T_max_C",
    "temperature_2m_min":          "T_min_C",
    "temperature_2m_mean":         "T_mean_C",
    "relative_humidity_2m_mean":   "RH_mean_pct",
    "wind_speed_10m_mean":         "wind_2m_ms",
    "shortwave_radiation_sum":     "Rs_MJm2day",
    "precipitation_sum":           "precip_mm",
    "et0_fao_evapotranspiration":  "ET0_OM_mm_day",
    "precipitation_hours":         "precip_hours",
}

# ── Default start date for backfill ───────────────────────────────────────────
BACKFILL_START = "2015-01-01"

# ── Open-Meteo API endpoints ──────────────────────────────────────────────────
ARCHIVE_URL  = "https://archive-api.open-meteo.com/v1/archive"
FORECAST_URL = "https://api.open-meteo.com/v1/forecast"


# ── Core functions ────────────────────────────────────────────────────────────

def fetch_weather(lat: float, lon: float, timezone: str,
                  start: str, end: str) -> pd.DataFrame:
    """
    Fetch daily weather from Open-Meteo for the given date range.
    Uses the archive API for past dates and forecast API for recent days.
    Returns a DataFrame indexed by date.
    """
    today = date.today().isoformat()
    end   = min(end, today)          # never request future dates

    if start > end:
        return pd.DataFrame()        # nothing to fetch

    # Open-Meteo archive covers everything up to a few days ago
    params = {
        "latitude":   lat,
        "longitude":  lon,
        "start_date": start,
        "end_date":   end,
        "daily":      ",".join(DAILY_VARS),
        "wind_speed_unit": "ms",
        "timezone":   timezone,
    }

    try:
        resp = requests.get(ARCHIVE_URL, params=params, timeout=30)
        resp.raise_for_status()
        data = resp.json()
    except requests.exceptions.HTTPError as e:
        # Archive may not cover the last 1-5 days -- fall back to forecast API
        if resp.status_code == 400:
            params_fc = {
                "latitude":  lat,
                "longitude": lon,
                "daily":     ",".join(DAILY_VARS),
                "past_days": 7,
                "wind_speed_unit": "ms",
                "timezone":  timezone,
            }
            resp2 = requests.get(FORECAST_URL, params=params_fc, timeout=30)
            resp2.raise_for_status()
            data = resp2.json()
        else:
            raise e

    daily   = data["daily"]
    dates   = pd.to_datetime(daily.pop("time"))
    df      = pd.DataFrame(daily, index=dates)
    df.index.name = "date"
    df.rename(columns=COLUMN_RENAME, inplace=True)

    # Convert radiation kJ/m2/day -> MJ/m2/day if needed
    if "Rs_MJm2day" in df.columns:
        if df["Rs_MJm2day"].max() > 100:
            df["Rs_MJm2day"] = df["Rs_MJm2day"] / 1000.0

    return df


def update_location(name: str, cfg: dict, start_override: str = None) -> dict:
    """
    Load existing CSV, detect the last date, download missing days,
    append and save. Returns a summary dict.
    """
    csv_path = Path(cfg["csv"])
    csv_path.parent.mkdir(parents=True, exist_ok=True)

    # Load existing data
    if csv_path.exists():
        df_existing = pd.read_csv(csv_path, index_col="date", parse_dates=True)
        last_date   = df_existing.index.max().date()
        start_date  = (last_date + timedelta(days=1)).isoformat()
        n_existing  = len(df_existing)
    else:
        df_existing = pd.DataFrame()
        start_date  = start_override or BACKFILL_START
        n_existing  = 0

    # Override start if backfill requested
    if start_override:
        start_date = start_override
        df_existing = pd.DataFrame()
        n_existing  = 0

    end_date = date.today().isoformat()

    print(f"\n{'='*55}")
    print(f" Location : {name}  ({cfg['lat']}N, {cfg['lon']}E)")
    print(f" CSV      : {csv_path}")
    print(f" Existing : {n_existing:,} rows")
    print(f" Fetching : {start_date}  ->  {end_date}")

    if start_date > end_date:
        print(f" Status   : already up to date -- nothing to download")
        return {
            "location":    name,
            "new_records": 0,
            "total":       n_existing,
            "status":      "up_to_date",
        }

    # Fetch new records in 2-year chunks to avoid API timeout
    chunk_start  = datetime.strptime(start_date, "%Y-%m-%d").date()
    chunk_end_dt = date.today()
    all_new      = []

    while chunk_start <= chunk_end_dt:
        chunk_end   = min(chunk_start + timedelta(days=730), chunk_end_dt)
        print(f" Chunk    : {chunk_start}  ->  {chunk_end}")
        try:
            chunk_df = fetch_weather(
                cfg["lat"], cfg["lon"], cfg["timezone"],
                chunk_start.isoformat(), chunk_end.isoformat(),
            )
            if not chunk_df.empty:
                all_new.append(chunk_df)
        except Exception as e:
            print(f" WARNING  : chunk failed -- {e}")
        chunk_start = chunk_end + timedelta(days=1)
        time.sleep(0.5)      # be polite to the API

    if not all_new:
        print(f" Status   : no new data available")
        return {
            "location":    name,
            "new_records": 0,
            "total":       n_existing,
            "status":      "no_new_data",
        }

    df_new = pd.concat(all_new)
    df_new = df_new[~df_new.index.duplicated(keep="last")]

    # Merge with existing
    if not df_existing.empty:
        df_all = pd.concat([df_existing, df_new])
        df_all = df_all[~df_all.index.duplicated(keep="last")]
        df_all.sort_index(inplace=True)
    else:
        df_all = df_new.sort_index()

    df_all.to_csv(csv_path)
    n_new = len(df_new)
    print(f" New rows : {n_new:,}")
    print(f" Total    : {len(df_all):,} rows  ({df_all.index[0].date()} to {df_all.index[-1].date()})")
    print(f" Saved    : {csv_path}")

    return {
        "location":    name,
        "new_records": n_new,
        "total":       len(df_all),
        "status":      "updated",
        "last_date":   df_all.index[-1].date().isoformat(),
    }


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="SmartFarm Togo Weather Logger")
    parser.add_argument("--once",     action="store_true",
                        help="Run once and exit (for cron / GitHub Actions)")
    parser.add_argument("--backfill", action="store_true",
                        help=f"Re-download full history from {BACKFILL_START}")
    parser.add_argument("--location", type=str, default=None,
                        help="Only update one location: Lome or Bangeli")
    args = parser.parse_args()

    start_override = BACKFILL_START if args.backfill else None

    locations_to_run = LOCATIONS
    if args.location:
        if args.location not in LOCATIONS:
            print(f"Unknown location: {args.location}. Valid: {list(LOCATIONS.keys())}")
            sys.exit(1)
        locations_to_run = {args.location: LOCATIONS[args.location]}

    print("=" * 55)
    print(" SmartFarm Togo -- Daily Weather Logger")
    print(f" Run date : {datetime.now().isoformat()}")
    print(f" Backfill : {args.backfill}")
    print("=" * 55)

    results = []
    for name, cfg in locations_to_run.items():
        try:
            result = update_location(name, cfg, start_override)
            results.append(result)
        except Exception as e:
            print(f"\nERROR updating {name}: {e}")
            results.append({"location": name, "status": "error", "error": str(e)})

    # Summary
    print("\n" + "=" * 55)
    print(" SUMMARY")
    print("=" * 55)
    total_new = 0
    for r in results:
        status = r.get("status", "unknown")
        new    = r.get("new_records", 0)
        total  = r.get("total", 0)
        last   = r.get("last_date", "N/A")
        total_new += new
        print(f" {r['location']:<10}  status={status:<12}  "
              f"new={new:>4}  total={total:>6}  last={last}")

    print()
    if total_new > 0:
        print(f" {total_new} new records added across all locations.")
    else:
        print(" All locations are already up to date.")
    print("=" * 55)

    # Exit code: 0 = success, 1 = error
    if any(r.get("status") == "error" for r in results):
        sys.exit(1)


if __name__ == "__main__":
    main()
