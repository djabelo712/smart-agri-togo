"""
SmartFarm Togo - Yield Prediction Service
Model 3: Random Forest yield prediction
"""
import json
import logging
from typing import Optional

import joblib
import numpy as np
from sklearn.ensemble import RandomForestRegressor

from config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()

# ── Module-level cache ────────────────────────────────────────────────────
_rf_model: Optional[RandomForestRegressor] = None
_crop_params: Optional[dict] = None
_feature_cols: Optional[list] = None


def load_model():
    """Load Model 3 artifacts into memory. Called once at API startup."""
    global _rf_model, _crop_params, _feature_cols
    try:
        _rf_model = joblib.load(settings.MODEL3_PATH)
        with open(settings.MODEL3_PARAMS_PATH) as f:
            params = json.load(f)
        _crop_params   = params["CROPS"]
        _feature_cols  = params["FEATURE_COLS"]
        logger.info(f"Model 3 loaded: {len(_feature_cols)} features")
    except Exception as e:
        logger.error(f"Could not load Model 3: {e}")


# ── Prediction function ───────────────────────────────────────────────────

def predict_yield(
    crop_name: str,
    ks_daily: list,
    treatment_name: str,
) -> dict:
    """
    Predict final yield for one crop zone.

    Parameters
    ----------
    crop_name      : str   -- 'Oignon', 'Carotte', 'Laitue', 'Mais'
    ks_daily       : list  -- daily Ks values from soil moisture sensors
    treatment_name : str   -- 'MPC', 'PID', 'Manuel'

    Returns
    -------
    dict with predicted_yield_kgm2, confidence_interval, status
    """
    if _rf_model is None or _crop_params is None:
        raise RuntimeError("Model 3 not loaded. Call load_model() first.")

    if crop_name not in _crop_params:
        raise ValueError(f"Unknown crop: {crop_name}. "
                         f"Valid: {list(_crop_params.keys())}")

    crop   = _crop_params[crop_name]
    stages = crop["stages"]
    Ym     = crop["Ym_kgm2"]
    ks_arr = np.array(ks_daily, dtype=np.float32)

    crop_enc      = {"Oignon": 0, "Carotte": 1, "Laitue": 2, "Mais": 3}
    treatment_enc = {"MPC": 0, "PID": 1, "Manuel": 2}

    features       = {}
    idx            = 0
    yield_stewart  = 1.0

    for i, stage in enumerate(stages):
        n    = min(stage["days"], max(0, len(ks_arr) - idx))
        ks_s = ks_arr[idx: idx + n] if n > 0 else np.array([1.0])
        idx += n

        features[f"Ks_mean_s{i+1}"]      = float(np.mean(ks_s))
        features[f"Ks_min_s{i+1}"]       = float(np.min(ks_s))
        features[f"Ks_std_s{i+1}"]       = float(np.std(ks_s))
        features[f"stress_days_s{i+1}"]  = float(np.sum(ks_s < 0.75))
        features[f"severe_stress_s{i+1}"]= float(np.sum(ks_s < 0.50))
        yield_stewart *= (1 - stage["Ky"] * (1 - float(np.mean(ks_s))))

    # Fill missing stages
    for i in range(len(stages), 4):
        features[f"Ks_mean_s{i+1}"]      = 1.0
        features[f"Ks_min_s{i+1}"]       = 1.0
        features[f"Ks_std_s{i+1}"]       = 0.0
        features[f"stress_days_s{i+1}"]  = 0.0
        features[f"severe_stress_s{i+1}"]= 0.0

    features["Ks_mean_season"]    = float(np.mean(ks_arr))
    features["Ks_min_season"]     = float(np.min(ks_arr))
    features["Ks_std_season"]     = float(np.std(ks_arr))
    features["Ks_p10_season"]     = float(np.percentile(ks_arr, 10))
    features["stress_days_total"] = float(np.sum(ks_arr < 0.75))
    features["season_length"]     = float(len(ks_arr))
    features["crop_encoded"]      = float(crop_enc.get(crop_name, 0))
    features["treatment_encoded"] = float(treatment_enc.get(treatment_name, 2))
    features["stewart_estimate"]  = float(np.clip(yield_stewart, 0.0, 1.0))

    X = np.array([[features[c] for c in _feature_cols]], dtype=np.float32)

    yield_ratio = float(np.clip(_rf_model.predict(X)[0], 0.0, 1.0))

    # Confidence interval from individual trees
    tree_preds = np.array([t.predict(X)[0] for t in _rf_model.estimators_])
    ci_low     = float(np.percentile(tree_preds, 10))
    ci_high    = float(np.percentile(tree_preds, 90))

    if yield_ratio >= 0.90:  status = "Excellent"
    elif yield_ratio >= 0.75: status = "Bon"
    elif yield_ratio >= 0.55: status = "Moyen"
    else:                     status = "Faible"

    return {
        "crop":                crop_name,
        "treatment":           treatment_name,
        "yield_ratio":         round(yield_ratio, 3),
        "predicted_yield_kgm2": round(yield_ratio * Ym, 3),
        "confidence_interval": [round(ci_low * Ym, 3), round(ci_high * Ym, 3)],
        "stewart_estimate_kgm2": round(float(np.clip(yield_stewart, 0, 1)) * Ym, 3),
        "Ym_kgm2":             Ym,
        "status":              status,
    }


def predict_full_field(ks_sensors: dict, cell_crops: dict, cell_treatments: dict) -> dict:
    """Predict yield for all 25 zones."""
    results = {}
    for cell_id, ks_daily in ks_sensors.items():
        crop  = cell_crops.get(cell_id, "Oignon")
        treat = cell_treatments.get(cell_id, "Manuel")
        try:
            results[cell_id] = predict_yield(crop, ks_daily, treat)
        except Exception as e:
            logger.error(f"Yield prediction failed for {cell_id}: {e}")
            results[cell_id] = {"error": str(e)}
    return results
