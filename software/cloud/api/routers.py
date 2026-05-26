"""
SmartFarm Togo - API Routers
auth / ml / control / field
"""
from datetime import datetime
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

from auth import (
    LoginRequest, TokenResponse,
    authenticate_user, create_access_token,
    get_current_user, TokenData,
)
from config import get_settings
import services.et0_service    as et0_svc
import services.yield_service  as yield_svc
import services.hardware_service as hw_svc

settings = get_settings()


# ════════════════════════════════════════════════════════════════
# AUTH ROUTER
# ════════════════════════════════════════════════════════════════
auth_router = APIRouter(prefix="/auth", tags=["Authentication"])


@auth_router.post("/login", response_model=TokenResponse)
def login(body: LoginRequest):
    """
    Authenticate with email and password.
    Returns a JWT token valid for 24 hours.
    All /control endpoints require this token.
    """
    user = authenticate_user(body.email, body.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email ou mot de passe incorrect",
        )
    token = create_access_token({"sub": user})
    return TokenResponse(
        access_token=token,
        expires_in=settings.ACCESS_TOKEN_EXPIRE_HOURS * 3600,
    )


@auth_router.get("/me")
def get_me(current_user: TokenData = Depends(get_current_user)):
    """Return the currently authenticated user."""
    return {"email": current_user.email, "authenticated": True}


# ════════════════════════════════════════════════════════════════
# ML ROUTER
# ════════════════════════════════════════════════════════════════
ml_router = APIRouter(prefix="/ml", tags=["ML Predictions"])


class ET0TodayResponse(BaseModel):
    et0_mm_day: float
    generated_at: str


class ET0ForecastResponse(BaseModel):
    dates:        List[str]
    et0_7days:    List[float]
    rain_7days:   List[float]
    generated_at: str


class YieldRequest(BaseModel):
    crop_name:      str = Field(..., example="Oignon")
    ks_daily:       List[float] = Field(..., min_length=10)
    treatment_name: str = Field(..., example="MPC")


class FullFieldYieldRequest(BaseModel):
    ks_sensors: dict  # {cell_id: [ks_values]}


@ml_router.get("/et0-today", response_model=ET0TodayResponse)
def et0_today():
    """
    Predict ET0 for today using Model 1 (XGBoost, R2=0.9643).
    Weather comes from the latest NASA POWER cached data.
    No authentication required -- read-only.
    """
    try:
        # Ensure model is loaded
        if et0_svc._model1 is None:
            et0_svc.load_models()
        # Use latest row from historical data as today's weather proxy
        import pandas as pd
        RENAME = {
            "T_max_C":     "Tmax",
            "T_min_C":     "Tmin",
            "T_mean_C":    "Tmean",
            "RH_mean_pct": "RH",
            "wind_2m_ms":  "Wind",
            "Rs_MJm2day":  "Rs",
            "precip_mm":   "Rain",
        }
        df = pd.read_csv(settings.NASA_CSV_PATH, index_col="date", parse_dates=True)
        df = df.rename(columns=RENAME).replace(-999.0, float("nan")).ffill()
        latest = df.iloc[-1]
        weather = {k: float(latest[k]) for k in ["Tmax","Tmin","Tmean","RH","Wind","Rs","Rain"]}
        et0 = et0_svc.predict_et0_today(weather)
        return ET0TodayResponse(
            et0_mm_day=et0,
            generated_at=datetime.utcnow().isoformat(),
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@ml_router.get("/et0-forecast", response_model=ET0ForecastResponse)
def et0_forecast():
    """
    7-day ET0 and rain forecast.
    Uses Model 1 (XGBoost) + Open-Meteo ECMWF NWP forecast.
    No authentication required -- read-only.
    """
    try:
        if et0_svc._model1 is None:
            et0_svc.load_models()
        result = et0_svc.predict_et0_7days()
        return ET0ForecastResponse(**result)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@ml_router.post("/yield-forecast")
def yield_forecast(body: YieldRequest):
    """
    Predict yield for one crop zone given its Ks history.
    No authentication required -- read-only.
    """
    try:
        return yield_svc.predict_yield(
            body.crop_name, body.ks_daily, body.treatment_name
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@ml_router.post("/yield-forecast/full-field")
def yield_forecast_full_field(body: FullFieldYieldRequest):
    """
    Predict yield for all 25 zones at once.
    Requires ks_sensors dict: {cell_id: [daily_ks_values]}.
    """
    # Default cell layouts
    CELL_CROPS = {
        **{f"C0{c}": "Oignon"  for c in range(5)},
        **{f"C1{c}": "Oignon"  for c in range(5)},
        **{f"C2{c}": "Carotte" for c in range(5)},
        **{f"C3{c}": "Laitue"  for c in range(5)},
        **{f"C4{c}": "Mais"    for c in range(5)},
    }
    CELL_TREATMENTS = {
        **{f"C{r}{c}": "MPC"    for r in range(3) for c in range(3)},
        **{f"C{r}{c}": "PID"    for r in range(3) for c in range(3, 5)},
        **{f"C{r}{c}": "Manuel" for r in range(3, 5) for c in range(5)},
    }
    try:
        return yield_svc.predict_full_field(
            body.ks_sensors, CELL_CROPS, CELL_TREATMENTS
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ════════════════════════════════════════════════════════════════
# CONTROL ROUTER  (JWT required for all endpoints)
# ════════════════════════════════════════════════════════════════
control_router = APIRouter(
    prefix="/control",
    tags=["Field Control"],
    dependencies=[Depends(get_current_user)],
)


class ValveRequest(BaseModel):
    cell:         str = Field(..., example="C23")
    action:       str = Field(..., example="open")   # open | close
    duration_min: int = Field(15, ge=1, le=120)


class PumpRequest(BaseModel):
    action:       str = Field(..., example="start")  # start | stop
    duration_min: int = Field(30, ge=1, le=180)


class ModeRequest(BaseModel):
    mode: str = Field(..., example="MPC")            # MPC | PID | Manuel


@control_router.post("/valve")
def control_valve(body: ValveRequest):
    """
    Open or close one irrigation valve.
    Requires JWT token. All actions are logged.
    """
    cell = body.cell.upper()
    if not (len(cell) == 3 and cell[0] == "C"
            and cell[1].isdigit() and cell[2].isdigit()):
        raise HTTPException(status_code=400, detail="Invalid cell ID. Format: C00 to C44")
    if body.action not in ("open", "close"):
        raise HTTPException(status_code=400, detail="Action must be 'open' or 'close'")

    if body.action == "open":
        return hw_svc.open_valve(cell, body.duration_min)
    else:
        return hw_svc.close_valve(cell)


@control_router.post("/valve/close-all")
def close_all_valves():
    """Emergency: close all 25 valves immediately. Requires JWT."""
    return hw_svc.close_all_valves()


@control_router.post("/pump")
def control_pump(body: PumpRequest):
    """
    Start or stop the main irrigation pump.
    Requires JWT token.
    """
    if body.action not in ("start", "stop"):
        raise HTTPException(status_code=400, detail="Action must be 'start' or 'stop'")
    if body.action == "start":
        return hw_svc.start_pump(body.duration_min)
    else:
        return hw_svc.stop_pump()


@control_router.post("/mode")
def set_mode(body: ModeRequest):
    """
    Switch controller mode: MPC | PID | Manuel.
    Requires JWT token.
    """
    try:
        return hw_svc.set_controller_mode(body.mode)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@control_router.get("/mode")
def get_mode():
    """Get current controller mode. Requires JWT."""
    return {"mode": hw_svc.get_controller_mode()}


# ════════════════════════════════════════════════════════════════
# FIELD ROUTER  (read-only, no JWT required)
# ════════════════════════════════════════════════════════════════
field_router = APIRouter(prefix="/field", tags=["Field Status"])


@field_router.get("/status")
def field_status():
    """
    Return a snapshot of the current field state.
    In production, this reads from Firebase / SQLite.
    Returns mock data when no real sensor data is available.
    """
    return {
        "timestamp":           datetime.utcnow().isoformat(),
        "controller_mode":     hw_svc.get_controller_mode(),
        "hardware_mode":       settings.HARDWARE_MODE,
        "pump_running":        False,
        "active_valves_count": 0,
        "note": (
            "Real sensor data available after field installation. "
            "Connect Firebase to get live readings."
        ),
    }


@field_router.get("/health")
def health_check():
    """API health check. No auth required."""
    return {
        "status":   "ok",
        "version":  settings.APP_VERSION,
        "models": {
            "model1_loaded": et0_svc._model1 is not None,
            "model3_loaded": yield_svc._rf_model is not None,
        },
        "hardware_mode": settings.HARDWARE_MODE,
        "timestamp": datetime.utcnow().isoformat(),
    }
