"""
SmartFarm Togo - FastAPI Application
Entry point for the REST API server.

Run locally:
    uvicorn main:app --reload --host 0.0.0.0 --port 8000

Run on Raspberry Pi:
    uvicorn main:app --host 0.0.0.0 --port 8000

Interactive docs available at:
    http://localhost:8000/docs
"""
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from config import get_settings
from routers import auth_router, ml_router, control_router, field_router
import services.et0_service    as et0_svc
import services.yield_service  as yield_svc
import services.hardware_service as hw_svc

# ── Logging ───────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(name)s  %(message)s",
)
logger = logging.getLogger(__name__)
settings = get_settings()


# ── Startup / shutdown lifecycle ──────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Load ML models and initialize hardware once at startup."""
    logger.info("SmartFarm Togo API starting...")
    logger.info(f"Hardware mode : {settings.HARDWARE_MODE}")

    # Load ML models into memory
    et0_svc.load_models()
    yield_svc.load_model()

    # Initialize hardware connection (no-op in simulation mode)
    hw_svc.init_hardware()

    logger.info("API ready.")
    yield
    logger.info("API shutting down.")


# ── FastAPI app ───────────────────────────────────────────────────────────
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description=(
        "REST API for the SmartFarm Togo intelligent irrigation system. "
        "Provides ML predictions (ET0, yield) and field control endpoints "
        "(valves, pump, controller mode)."
    ),
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)


# ── CORS (allow Flutter app and Raspberry Pi) ─────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],      # Restrict to your domains in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Include routers ───────────────────────────────────────────────────────
app.include_router(auth_router)
app.include_router(ml_router)
app.include_router(control_router)
app.include_router(field_router)


# ── Root endpoint ─────────────────────────────────────────────────────────
@app.get("/", include_in_schema=False)
def root():
    return {
        "project": "SmartFarm Togo",
        "version": settings.APP_VERSION,
        "docs":    "/docs",
        "health":  "/field/health",
    }


# ── Global error handler ──────────────────────────────────────────────────
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    logger.error(f"Unhandled error: {exc}")
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error. Check the API logs."},
    )
