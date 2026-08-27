from fastapi import APIRouter
from datetime import datetime
from backend.app.config import settings

router = APIRouter(tags=["Health & Telemetry"])

@router.get("/health")
def healthcheck():
    """Healthcheck endpoint for Docker orchestration and load balancers."""
    return {
        "status": "healthy",
        "app_name": settings.APP_NAME,
        "environment": settings.ENVIRONMENT,
        "model_version": settings.MODEL_VERSION,
        "timestamp": datetime.utcnow().isoformat()
    }
