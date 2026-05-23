# SmartFarm Togo — FastAPI Backend

REST API for the SmartFarm Togo intelligent irrigation system.
Provides ML predictions and hardware control endpoints.

## Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/auth/login` | No | Get JWT token |
| GET | `/field/health` | No | API health check |
| GET | `/field/status` | No | Field snapshot |
| GET | `/ml/et0-today` | No | ET0 today (Model 1) |
| GET | `/ml/et0-forecast` | No | 7-day ET0+Rain (Model 2) |
| POST | `/ml/yield-forecast` | No | Yield one zone (Model 3) |
| POST | `/ml/yield-forecast/full-field` | No | Yield all 25 zones |
| POST | `/control/valve` | JWT | Open/close valve |
| POST | `/control/valve/close-all` | JWT | Emergency close all |
| POST | `/control/pump` | JWT | Start/stop pump |
| POST | `/control/mode` | JWT | Set MPC/PID/Manuel |
| GET | `/control/mode` | JWT | Get current mode |

## Setup

### 1. Create virtual environment

```bash
cd software/cloud/api
python -m venv venv
source venv/bin/activate   # Linux/Mac
venv\Scripts\activate      # Windows
pip install -r requirements.txt
```

### 2. Configure environment

```bash
cp .env.example .env
# Edit .env with your real values
```

### 3. Run locally (development)

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Open http://localhost:8000/docs for the interactive API documentation.

### 4. Run on Raspberry Pi

```bash
# Set HARDWARE_MODE=True in .env
uvicorn main:app --host 0.0.0.0 --port 8000
```

### 5. Deploy to Railway (cloud)

```bash
# Install Railway CLI
npm install -g @railway/cli
railway login
railway init
railway up
```

## Authentication

All /control endpoints require a JWT token:

```bash
# Get token
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@smartagritogo.org", "password": "your-password"}'

# Use token
curl -X POST http://localhost:8000/control/valve \
  -H "Authorization: Bearer <your-token>" \
  -H "Content-Type: application/json" \
  -d '{"cell": "C23", "action": "open", "duration_min": 15}'
```

## Security notes

- Never commit `.env` to GitHub (already in `.gitignore`)
- Change `SECRET_KEY` and `ADMIN_PASSWORD` before deployment
- In production, restrict CORS `allow_origins` to your Flutter app domain
- All control actions are logged with timestamp and user
