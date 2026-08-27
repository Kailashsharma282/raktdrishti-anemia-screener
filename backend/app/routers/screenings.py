from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from backend.app.database import get_db
from backend.app.models.user import User
from backend.app.models.worker import Worker
from backend.app.schemas.screening import ScreeningCreate, ScreeningResponse, ScreeningListResponse
from backend.app.schemas.referral import ReferralCreate, ReferralResponse
from backend.app.services.screening_service import ScreeningService
from backend.app.auth.dependencies import get_current_user
from backend.app.models.referral import Referral
import uuid

router = APIRouter(prefix="/screenings", tags=["Screenings"])

@router.get("", response_model=ScreeningListResponse)
def list_screenings(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    patient_id: Optional[str] = None,
    risk_category: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Retrieves paginated list of non-invasive screenings."""
    total, items = ScreeningService.get_screenings(
        db, page=page, limit=limit, patient_id=patient_id, risk_category=risk_category
    )
    return ScreeningListResponse(total=total, page=page, limit=limit, items=items)

@router.post("", response_model=dict, status_code=status.HTTP_201_CREATED)
def create_screening(
    screening_in: ScreeningCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Submits a new multi-site anemia screening."""
    worker = db.query(Worker).filter(Worker.user_id == current_user.id).first()
    worker_id = worker.id if worker else None
    
    screening = ScreeningService.create_screening(db, screening_in, worker_id=worker_id)
    _, items = ScreeningService.get_screenings(db, page=1, limit=1, patient_id=screening.patient_id)
    return items[0] if items else {"id": screening.id, "status": "created"}

@router.get("/{screening_id}", response_model=dict)
def get_screening(
    screening_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Retrieves full details of a specific screening."""
    _, items = ScreeningService.get_screenings(db, page=1, limit=100)
    for it in items:
        if it["id"] == screening_id:
            return it
    raise HTTPException(status_code=404, detail="Screening record not found")

@router.post("/{screening_id}/referral", response_model=dict, status_code=status.HTTP_201_CREATED)
def create_referral_for_screening(
    screening_id: str,
    referral_in: ReferralCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Creates a lab referral for this screening."""
    worker = db.query(Worker).filter(Worker.user_id == current_user.id).first()
    worker_id = worker.id if worker else None
    
    existing = db.query(Referral).filter(Referral.screening_id == screening_id).first()
    if existing:
        existing.referral_facility = referral_in.referral_facility
        existing.urgency = referral_in.urgency
        existing.clinical_notes = referral_in.notes
        db.commit()
        return {"id": existing.id, "status": existing.status, "facility": existing.referral_facility}
        
    ref = Referral(
        id=referral_in.id or str(uuid.uuid4()),
        screening_id=screening_id,
        patient_id=referral_in.patient_id,
        worker_id=worker_id,
        referral_facility=referral_in.referral_facility,
        urgency=referral_in.urgency,
        status="Pending",
        clinical_notes=referral_in.notes,
        sync_status="SYNCED"
    )
    db.add(ref)
    db.commit()
    db.refresh(ref)
    return {"id": ref.id, "status": ref.status, "facility": ref.referral_facility}
