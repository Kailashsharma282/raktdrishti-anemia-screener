from typing import Dict, List, Any, Optional
from pydantic import BaseModel

class DashboardSummaryResponse(BaseModel):
    total_patients: int
    total_screenings: int
    normal_count: int
    mild_count: int
    moderate_count: int
    high_count: int  # severe
    pending_referrals: int
    completed_referrals: int
    pending_sync_count: int

class RiskDistributionResponse(BaseModel):
    NORMAL: int
    MILD: int
    MODERATE: int
    SEVERE: int
    percentages: Dict[str, float]

class LocationSummaryItem(BaseModel):
    village: str
    district: str
    total_screenings: int
    high_risk_count: int
    moderate_risk_count: int
    mild_risk_count: int
    normal_count: int
    high_risk_percentage: float

class DemographicsSummaryResponse(BaseModel):
    age_groups: Dict[str, Dict[str, int]]  # e.g., "0-5": {"NORMAL": 10, "MODERATE": 4, ...}
    pregnancy_breakdown: Dict[str, Dict[str, int]]  # "pregnant", "not_pregnant", "not_applicable"
    gender_breakdown: Dict[str, int]
    timeline: List[Dict[str, Any]]
