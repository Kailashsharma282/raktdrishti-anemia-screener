import sqlalchemy as sa
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from backend.app.config import settings
from backend.app.database import engine, Base, SessionLocal
from backend.app.models import *
from backend.app.routers import (
    auth_router,
    workers_router,
    patients_router,
    screenings_router,
    referrals_router,
    sync_router,
    dashboard_router,
    demo_router,
    health_router
)
from backend.app.utils.seed_data import seed_initial_data

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: create tables
    Base.metadata.create_all(bind=engine)

    # If running on PostgreSQL (e.g. Render), ensure column lengths are at least VARCHAR(64)
    # in case tables were pre-created with VARCHAR(36) in an earlier deployment attempt.
    try:
        if engine.dialect.name == "postgresql":
            with engine.connect() as conn:
                alter_stmts = [
                    "ALTER TABLE users ALTER COLUMN id TYPE VARCHAR(64);",
                    "ALTER TABLE workers ALTER COLUMN id TYPE VARCHAR(64);",
                    "ALTER TABLE workers ALTER COLUMN user_id TYPE VARCHAR(64);",
                    "ALTER TABLE patients ALTER COLUMN id TYPE VARCHAR(64);",
                    "ALTER TABLE patients ALTER COLUMN worker_id TYPE VARCHAR(64);",
                    "ALTER TABLE patients ALTER COLUMN location_id TYPE VARCHAR(64);",
                    "ALTER TABLE patients ALTER COLUMN created_by TYPE VARCHAR(64);",
                    "ALTER TABLE locations ALTER COLUMN id TYPE VARCHAR(64);",
                    "ALTER TABLE screenings ALTER COLUMN id TYPE VARCHAR(64);",
                    "ALTER TABLE screenings ALTER COLUMN patient_id TYPE VARCHAR(64);",
                    "ALTER TABLE screenings ALTER COLUMN worker_id TYPE VARCHAR(64);",
                    "ALTER TABLE screening_images ALTER COLUMN id TYPE VARCHAR(64);",
                    "ALTER TABLE screening_images ALTER COLUMN screening_id TYPE VARCHAR(64);",
                    "ALTER TABLE screening_predictions ALTER COLUMN id TYPE VARCHAR(64);",
                    "ALTER TABLE screening_predictions ALTER COLUMN screening_id TYPE VARCHAR(64);",
                    "ALTER TABLE referrals ALTER COLUMN id TYPE VARCHAR(64);",
                    "ALTER TABLE referrals ALTER COLUMN screening_id TYPE VARCHAR(64);",
                    "ALTER TABLE referrals ALTER COLUMN patient_id TYPE VARCHAR(64);",
                    "ALTER TABLE referrals ALTER COLUMN worker_id TYPE VARCHAR(64);",
                    "ALTER TABLE sync_events ALTER COLUMN id TYPE VARCHAR(64);",
                    "ALTER TABLE sync_events ALTER COLUMN worker_id TYPE VARCHAR(64);",
                    "ALTER TABLE audit_logs ALTER COLUMN id TYPE VARCHAR(64);",
                    "ALTER TABLE audit_logs ALTER COLUMN user_id TYPE VARCHAR(64);",
                    "ALTER TABLE audit_logs ALTER COLUMN entity_id TYPE VARCHAR(64);"
                ]
                for stmt in alter_stmts:
                    try:
                        conn.execute(sa.text(stmt))
                    except Exception:
                        pass
                conn.commit()
    except Exception as e:
        print(f"[Warning] Column widening check bypassed: {e}")

    # Seed initial demo dataset (protected with rollback to ensure server startup succeeds)
    db = SessionLocal()
    try:
        seed_initial_data(db, reset=False)
    except Exception as e:
        print(f"[Warning] Seeding demo data encountered an error: {e}")
        db.rollback()
    finally:
        db.close()
    yield
    # Shutdown: cleanups if necessary

app = FastAPI(
    title="RaktDrishti Backend API",
    description="""
    ## Non-Invasive Anemia Risk Screening Platform API
    **Omnikon National Hackathon 2026** — *Omni_BioTech_2: Non-Invasive Anemia Screening*
    
    ### Key Highlights:
    - **Offline-First Synchronization Engine** (`/api/v1/sync`)
    - **Multi-Site Screening Management** (`/api/v1/screenings`)
    - **Patient Directory & Longitudinal Tracking** (`/api/v1/patients`)
    - **Laboratory Referral Workflow** (`/api/v1/referrals`)
    - **Health Authority Dashboard & Geospatial Analytics** (`/api/v1/dashboard/`)
    - **Demo Mode Controls** (`/api/v1/demo/reset`)
    
    *Disclaimer: RaktDrishti is an engineering triage aid, not a diagnostic medical device.*
    """,
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS for Dashboard and Mobile Web/Clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Permits local dashboard and mobile dev servers
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global Exception Handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"detail": f"An internal server error occurred: {str(exc)}"}
    )

# Include Routers under API v1 prefix
app.include_router(health_router, prefix=settings.API_V1_PREFIX)
app.include_router(auth_router, prefix=settings.API_V1_PREFIX)
app.include_router(workers_router, prefix=settings.API_V1_PREFIX)
app.include_router(patients_router, prefix=settings.API_V1_PREFIX)
app.include_router(screenings_router, prefix=settings.API_V1_PREFIX)
app.include_router(referrals_router, prefix=settings.API_V1_PREFIX)
app.include_router(sync_router, prefix=settings.API_V1_PREFIX)
app.include_router(dashboard_router, prefix=settings.API_V1_PREFIX)
app.include_router(demo_router, prefix=settings.API_V1_PREFIX)

@app.get("/")
def root_redirect():
    return {
        "message": "Welcome to RaktDrishti Non-Invasive Anemia Screening API",
        "docs": "/docs",
        "health": f"{settings.API_V1_PREFIX}/health"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.app.main:app", host="0.0.0.0", port=8000, reload=True)
