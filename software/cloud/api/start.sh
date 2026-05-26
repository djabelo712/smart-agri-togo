#!/bin/bash
# SmartFarm Togo - Railway Startup Script
# Runs before uvicorn starts. Regenerates ML models and downloads
# weather data if not present (happens on first deploy).

set -e
echo "=== SmartFarm Togo - Startup ==="

# ── Model 3: Yield Random Forest ─────────────────────────────────────────────
MODEL3_PATH="../../ml_models/yield_model/yield_rf_model.pkl"
PARAMS3_PATH="../../ml_models/yield_model/yield_model_params.json"

if [ ! -f "$MODEL3_PATH" ]; then
    echo "Model 3 not found. Regenerating from FAO-56 Stewart simulation..."
    python3 regenerate_models.py
    echo "Model 3 regenerated."
else
    echo "Model 3 found."
fi

# ── NASA POWER CSV ────────────────────────────────────────────────────────────
NASA_CSV="../../data/weather/raw/nasa_power_lome.csv"
PROCESSED_CSV="../../data/weather/processed/Lome_Togo_daily.csv"

if [ ! -f "$NASA_CSV" ]; then
    echo "NASA POWER CSV not found."
    if [ -f "$PROCESSED_CSV" ]; then
        echo "Using processed CSV as raw..."
        mkdir -p ../../data/weather/raw
        cp "$PROCESSED_CSV" "$NASA_CSV"
    else
        echo "Downloading weather data from NASA POWER..."
        python3 download_weather.py
    fi
else
    echo "Weather data found."
fi

# ── Firebase credentials from environment variable ───────────────────────────
if [ ! -f "firebase-credentials.json" ] && [ -n "$FIREBASE_CREDENTIALS_JSON" ]; then
    echo "Writing Firebase credentials from environment..."
    echo "$FIREBASE_CREDENTIALS_JSON" > firebase-credentials.json
    echo "Firebase credentials written."
fi

echo "=== Startup complete. Starting API... ==="
exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
