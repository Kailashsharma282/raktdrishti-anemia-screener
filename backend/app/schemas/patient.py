from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field

class PatientBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    age: int = Field(..., ge=0, le=120)
    gender: str = Field(..., pattern="^(female|male|other)$")
    pregnancy_status: str = Field(default="not_applicable")
    phone: Optional[str] = None
    village: Optional[str] = None
    notes: Optional[str] = None

class PatientCreate(PatientBase):
    id: Optional[str] = None  # Client can supply offline UUID
    patient_code: Optional[str] = None
    location_id: Optional[str] = None

class PatientUpdate(BaseModel):
    name: Optional[str] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    pregnancy_status: Optional[str] = None
    phone: Optional[str] = None
    village: Optional[str] = None
    notes: Optional[str] = None

class PatientResponse(PatientBase):
    id: str
    patient_code: str
    worker_id: Optional[str] = None
    location_id: Optional[str] = None
    sync_status: str
    created_at: datetime
    updated_at: datetime
    latest_risk_category: Optional[str] = None
    latest_risk_score: Optional[float] = None
    latest_screening_date: Optional[datetime] = None
    screenings_count: int = 0
    active_referral: Optional[dict] = None

    class Config:
        from_attributes = True

class PatientListResponse(BaseModel):
    total: int
    page: int
    limit: int
    items: List[PatientResponse]
