#!/bin/bash
set -e
echo "=== SmartFarm Togo - Startup ==="

# Chemins absolus depuis la racine du projet sur Render
PROJECT_ROOT="/opt/render/project/src"
MODEL3_PATH="$PROJECT_ROOT/software/ml_models/yield_model/yield_rf_model.pkl"
NASA_CSV="$PROJECT_ROOT/data/weather/raw/nasa_power_lome.csv"
PROCESSED_CSV="$PROJECT_ROOT/data/weather/processed/Lome_Togo_daily.csv"

# Créer les dossiers nécessaires
mkdir -p "$PROJECT_ROOT/software/ml_models/yield_model"
mkdir -p "$PROJECT_ROOT/data/weather/raw"

# Model 3
if [ ! -f "$MODEL3_PATH" ]; then
    echo "Regenerating Model 3..."
    python3 regenerate_models.py
fi

# Weather CSV
if [ ! -f "$NASA_CSV" ]; then
    if [ -f "$PROCESSED_CSV" ]; then
        cp "$PROCESSED_CSV" "$NASA_CSV"
    fi
fi

# Firebase credentials
if [ ! -f "firebase-credentials.json" ] && [ -n "$FIREBASE_CREDENTIALS_JSON" ]; then
    echo "$FIREBASE_CREDENTIALS_JSON" > firebase-credentials.json
fi

echo "=== Starting API on port ${PORT:-8000} ==="
exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
