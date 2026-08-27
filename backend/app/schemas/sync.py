from typing import List, Optional, Dict, Any
from datetime import datetime
from pydantic import BaseModel
from backend.app.schemas.patient import PatientCreate
from backend.app.schemas.screening import ScreeningCreate
from backend.app.schemas.referral import ReferralCreate

class SyncBatchRequest(BaseModel):
    worker_id: Optional[str] = None
    device_id: Optional[str] = None
    client_timestamp: datetime
    patients: List[PatientCreate] = []
    screenings: List[ScreeningCreate] = []
    referrals: List[ReferralCreate] = []

class SyncBatchResponse(BaseModel):
    status: str = "success"
    synced_patients: int
    synced_screenings: int
    synced_referrals: int
    conflicts_resolved: int = 0
    server_timestamp: datetime
    message: str = "Synchronization completed successfully."
