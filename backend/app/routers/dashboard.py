from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from backend.app.database import get_db
from backend.app.schemas.dashboard import (
    DashboardSummaryResponse, RiskDistributionResponse, LocationSummaryItem, DemographicsSummaryResponse
)
from backend.app.services.dashboard_service import DashboardService
from backend.app.auth.dependencies import get_current_user
from backend.app.models.user import User

router = APIRouter(prefix="/dashboard", tags=["Dashboard & Analytics"])

@router.get("/summary", response_model=DashboardSummaryResponse)
def get_summary(db: Session = Depends(get_db)):
    """Retrieves high-level KPI metrics for health authorities."""
    return DashboardService.get_summary(db)

@router.get("/risk-distribution", response_model=RiskDistributionResponse)
def get_risk_distribution(db: Session = Depends(get_db)):
    """Retrieves current proportional distribution of anemia risk levels."""
    return DashboardService.get_risk_distribution(db)

@router.get("/location-summary", response_model=List[LocationSummaryItem])
def get_location_summary(db: Session = Depends(get_db)):
    """Retrieves village and district level aggregate screening analytics."""
    return DashboardService.get_location_summary(db)

@router.get("/demographics", response_model=DemographicsSummaryResponse)
def get_demographics(db: Session = Depends(get_db)):
    """Retrieves age bracket, gender, pregnancy status, and screening timeline analytics."""
    return DashboardService.get_demographics_summary(db)
