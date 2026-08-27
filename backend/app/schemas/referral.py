from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field

class ReferralCreate(BaseModel):
    id: Optional[str] = None
    screening_id: str
    patient_id: str
    referral_facility: str = Field(..., min_length=2, max_length=150)
    urgency: str = Field(default="high", pattern="^(routine|high|immediate)$")
    notes: Optional[str] = None

class ReferralUpdate(BaseModel):
    status: Optional[str] = Field(None, pattern="^(Pending|Referred|Lab Test Completed|Follow-up Required)$")
    referral_facility: Optional[str] = None
    urgency: Optional[str] = None
    lab_confirmed_hb: Optional[float] = Field(None, ge=1.0, le=25.0)
    clinical_notes: Optional[str] = None
    prescribed_treatment: Optional[str] = None

class ReferralResponse(BaseModel):
    id: str
    screening_id: str
    patient_id: str
    patient_name: Optional[str] = None
    patient_code: Optional[str] = None
    patient_age: Optional[int] = None
    patient_gender: Optional[str] = None
    worker_id: Optional[str] = None
    worker_name: Optional[str] = None
    risk_category: Optional[str] = None
    screening_date: Optional[datetime] = None
    screening_location: Optional[str] = None
    
    referral_facility: str
    urgency: str
    status: str
    lab_confirmed_hb: Optional[float] = None
    clinical_notes: Optional[str] = None
    prescribed_treatment: Optional[str] = None
    sync_status: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class ReferralListResponse(BaseModel):
    total: int
    page: int
    limit: int
    items: List[ReferralResponse]
