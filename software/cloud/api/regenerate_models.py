"""
SmartFarm Togo - Model Regeneration Script
==========================================
Regenerates Model 3 (Yield Random Forest) from FAO-56 Stewart simulation.
Called by start.sh on Railway if the model file is missing.
Takes ~30 seconds. Results are deterministic (same seed = same model).
"""
import json
import sys
from pathlib import Path

import numpy as np
import joblib
from sklearn.ensemble import RandomForestRegressor

print("Regenerating Model 3 (Yield Random Forest)...")
np.random.seed(42)

CROPS = {
    "Oignon":  {"Ym_kgm2": 4.5, "stages": [
        {"days": 15, "Kc": 0.50, "Ky": 0.45},
        {"days": 25, "Kc": 0.75, "Ky": 0.70},
        {"days": 70, "Kc": 1.05, "Ky": 0.80},
        {"days": 40, "Kc": 0.75, "Ky": 0.30},
    ]},
    "Carotte": {"Ym_kgm2": 3.5, "stages": [
        {"days": 20, "Kc": 0.70, "Ky": 0.35},
        {"days": 30, "Kc": 0.95, "Ky": 0.60},
        {"days": 50, "Kc": 1.10, "Ky": 0.80},
        {"days": 30, "Kc": 0.85, "Ky": 0.40},
    ]},
    "Laitue":  {"Ym_kgm2": 3.0, "stages": [
        {"days": 20, "Kc": 0.70, "Ky": 0.45},
        {"days": 25, "Kc": 0.95, "Ky": 0.60},
        {"days": 30, "Kc": 1.00, "Ky": 0.95},
    ]},
    "Mais":    {"Ym_kgm2": 0.8, "stages": [
        {"days": 20, "Kc": 0.40, "Ky": 0.30},
        {"days": 35, "Kc": 0.80, "Ky": 0.30},
        {"days": 40, "Kc": 1.15, "Ky": 1.25},
        {"days": 30, "Kc": 0.70, "Ky": 0.50},
    ]},
}

TREATMENTS = {
    "MPC":    {"Ks_mean": 0.91, "Ks_std": 0.06, "Ks_min": 0.75},
    "PID":    {"Ks_mean": 0.78, "Ks_std": 0.12, "Ks_min": 0.55},
    "Manuel": {"Ks_mean": 0.65, "Ks_std": 0.18, "Ks_min": 0.30},
}

FEATURE_COLS = (
    [f"Ks_mean_s{i}" for i in range(1, 5)] +
    [f"Ks_min_s{i}"  for i in range(1, 5)] +
    [f"Ks_std_s{i}"  for i in range(1, 5)] +
    [f"stress_days_s{i}"   for i in range(1, 5)] +
    [f"severe_stress_s{i}" for i in range(1, 5)] +
    ["Ks_mean_season", "Ks_min_season", "Ks_std_season",
     "Ks_p10_season", "stress_days_total", "season_length",
     "crop_encoded", "treatment_encoded", "stewart_estimate"]
)


def simulate(crop_name, treatment_name, seed):
    rng = np.random.RandomState(seed)
    crop = CROPS[crop_name]
    t    = TREATMENTS[treatment_name]
    stages = crop["stages"]
    alpha = max(0.5, t["Ks_mean"] * (t["Ks_mean"]*(1-t["Ks_mean"])/t["Ks_std"]**2 - 1))
    beta  = max(0.5, (1-t["Ks_mean"]) * (t["Ks_mean"]*(1-t["Ks_mean"])/t["Ks_std"]**2 - 1))

    all_ks, stage_ks, yield_ratio = [], [], 1.0
    for stage in stages:
        n   = stage["days"]
        ks  = t["Ks_min"] + (1-t["Ks_min"]) * rng.beta(alpha, beta, n)
        n_s = rng.poisson(1.5*(1-t["Ks_mean"]))
        for _ in range(n_s):
            s = rng.randint(0, max(1, n-3))
            d = rng.randint(1, 4)
            ks[s:s+d] *= rng.uniform(0.5, 0.8)
        ks = np.clip(ks, 0.05, 1.0)
        all_ks.extend(ks); stage_ks.append(ks)
        yield_ratio *= (1 - stage["Ky"] * (1 - float(np.mean(ks))))

    yield_ratio = float(np.clip(yield_ratio, 0.0, 1.0))
    all_ks_arr  = np.array(all_ks)
    feat = {}
    for i, (stage, ks_arr) in enumerate(zip(stages, stage_ks)):
        feat[f"Ks_mean_s{i+1}"]      = float(np.mean(ks_arr))
        feat[f"Ks_min_s{i+1}"]       = float(np.min(ks_arr))
        feat[f"Ks_std_s{i+1}"]       = float(np.std(ks_arr))
        feat[f"stress_days_s{i+1}"]  = float(np.sum(ks_arr < 0.75))
        feat[f"severe_stress_s{i+1}"]= float(np.sum(ks_arr < 0.50))
    for i in range(len(stages), 4):
        feat[f"Ks_mean_s{i+1}"]      = 1.0
        feat[f"Ks_min_s{i+1}"]       = 1.0
        feat[f"Ks_std_s{i+1}"]       = 0.0
        feat[f"stress_days_s{i+1}"]  = 0.0
        feat[f"severe_stress_s{i+1}"]= 0.0
    feat["Ks_mean_season"]    = float(np.mean(all_ks_arr))
    feat["Ks_min_season"]     = float(np.min(all_ks_arr))
    feat["Ks_std_season"]     = float(np.std(all_ks_arr))
    feat["Ks_p10_season"]     = float(np.percentile(all_ks_arr, 10))
    feat["stress_days_total"] = float(np.sum(all_ks_arr < 0.75))
    feat["season_length"]     = float(len(all_ks_arr))
    feat["crop_encoded"]      = float(["Oignon","Carotte","Laitue","Mais"].index(crop_name))
    feat["treatment_encoded"] = float(["MPC","PID","Manuel"].index(treatment_name))
    feat["stewart_estimate"]  = yield_ratio
    feat["yield_ratio"]       = yield_ratio
    return feat


N = 10000
records = []
crop_names  = list(CROPS.keys())
treat_names = list(TREATMENTS.keys())
for i in range(N):
    crop  = crop_names[i % len(crop_names)]
    treat = np.random.choice(treat_names)
    records.append(simulate(crop, treat, seed=i))

import pandas as pd
df = pd.DataFrame(records)
X  = df[FEATURE_COLS].values.astype(np.float32)
y  = df["yield_ratio"].values.astype(np.float32)

rf = RandomForestRegressor(
    n_estimators=500, min_samples_leaf=3,
    max_features="sqrt", random_state=42,
    oob_score=True, n_jobs=-1,
)
rf.fit(X, y)
print(f"OOB R2: {rf.oob_score_:.4f}")

# Save
import os
MODEL_DIR = Path(os.environ.get("PROJECT_ROOT", "/opt/render/project/src")) / "software" / "ml_models" / "yield_model"
MODEL_DIR.mkdir(parents=True, exist_ok=True)
joblib.dump(rf, MODEL_DIR / "yield_rf_model.pkl")

params = {
    "CROPS": CROPS, "TREATMENTS": TREATMENTS,
    "FEATURE_COLS": FEATURE_COLS,
    "CELL_CROPS": {f"C{r}{c}": ["Oignon","Oignon","Carotte","Laitue","Mais"][r]
                   for r in range(5) for c in range(5)},
    "CELL_TREATMENTS": {f"C{r}{c}": ("MPC" if c < 3 else "PID") if r < 3 else "Manuel"
                        for r in range(5) for c in range(5)},
}
with open(MODEL_DIR / "yield_model_params.json", "w") as f:
    json.dump(params, f, indent=2)

print(f"Model 3 saved to {MODEL_DIR}")
