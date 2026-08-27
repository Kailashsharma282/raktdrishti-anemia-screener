from backend.app.routers.auth import router as auth_router
from backend.app.routers.workers import router as workers_router
from backend.app.routers.patients import router as patients_router
from backend.app.routers.screenings import router as screenings_router
from backend.app.routers.referrals import router as referrals_router
from backend.app.routers.sync import router as sync_router
from backend.app.routers.dashboard import router as dashboard_router
from backend.app.routers.demo import router as demo_router
from backend.app.routers.health import router as health_router

__all__ = [
    "auth_router",
    "workers_router",
    "patients_router",
    "screenings_router",
    "referrals_router",
    "sync_router",
    "dashboard_router",
    "demo_router",
    "health_router"
]
