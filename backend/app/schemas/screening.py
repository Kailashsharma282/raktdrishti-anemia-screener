from typing import Optional, List, Dict, Any
from datetime import datetime
from pydantic import BaseModel, Field

class ScreeningImageCreate(BaseModel):
    id: Optional[str] = None
    site_type: str = Field(..., pattern="^(conjunctiva|nail|palm)$")
    local_path: Optional[str] = None
    cloud_path: Optional[str] = None
    quality_score: float = 0.0
    calibration_detected: bool = True
    illumination_gain: float = 1.0
    color_features: Optional[Dict[str, Any]] = None

class ScreeningImageResponse(BaseModel):
    id: str
    site_type: str
    local_path: Optional[str] = None
    cloud_path: Optional[str] = None
    quality_score: float
    calibration_detected: bool
    illumination_gain: float
    color_features: Optional[Dict[str, Any]] = None
    created_at: datetime

    class Config:
        from_attributes = True

class ScreeningCreate(BaseModel):
    id: Optional[str] = None  # Client UUID
    patient_id: str
    screening_date: Optional[datetime] = None
    device_id: Optional[str] = None
    
    conjunctiva_quality: float = Field(default=80.0, ge=0.0, le=100.0)
    nail_quality: float = Field(default=80.0, ge=0.0, le=100.0)
    palm_quality: float = Field(default=80.0, ge=0.0, le=100.0)
    overall_quality: Optional[float] = None
    
    final_risk_category: str = Field(..., pattern="^(NORMAL|MILD|MODERATE|SEVERE)$")
    risk_score: float = Field(..., ge=0.0, le=1.0)
    confidence: float = Field(..., ge=0.0, le=1.0)
    model_version: str = "v1.0.0-mvp-demo"
    
    images: Optional[List[ScreeningImageCreate]] = None
    prediction_details: Optional[Dict[str, Any]] = None

class ScreeningResponse(BaseModel):
    id: str
    patient_id: str
    patient_name: Optional[str] = None
    patient_code: Optional[str] = None
    patient_age: Optional[int] = None
    patient_gender: Optional[str] = None
    worker_id: Optional[str] = None
    screening_date: datetime
    device_id: Optional[str] = None
    
    conjunctiva_quality: float
    nail_quality: float
    palm_quality: float
    overall_quality: float
    
    final_risk_category: str
    risk_score: float
    confidence: float
    model_version: str
    status: str
    sync_status: str
    
    images: List[ScreeningImageResponse] = []
    referral_id: Optional[str] = None
    referral_status: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True

class ScreeningListResponse(BaseModel):
    total: int
    page: int
    limit: int
    items: List[ScreeningResponse]
