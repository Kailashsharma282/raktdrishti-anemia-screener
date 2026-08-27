from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from sqlalchemy import desc
from backend.app.database import get_db
from backend.app.models.user import User
from backend.app.models.patient import Patient
from backend.app.models.screening import Screening
from backend.app.models.referral import Referral
from backend.app.models.worker import Worker
from backend.app.schemas.referral import ReferralUpdate, ReferralListResponse, ReferralResponse
from backend.app.auth.dependencies import get_current_user

router = APIRouter(prefix="/referrals", tags=["Referrals"])

@router.get("", response_model=ReferralListResponse)
def list_referrals(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    status_filter: Optional[str] = Query(None, alias="status"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Retrieves paginated referrals list with patient details."""
    query = db.query(Referral)
    if status_filter:
        query = query.filter(Referral.status == status_filter)
        
    total = query.count()
    refs = query.order_by(desc(Referral.created_at)).offset((page - 1) * limit).limit(limit).all()
    
    items = []
    for r in refs:
        p = db.query(Patient).filter(Patient.id == r.patient_id).first()
        s = db.query(Screening).filter(Screening.id == r.screening_id).first()
        w = db.query(Worker).filter(Worker.id == r.worker_id).first()
        
        items.append(
            ReferralResponse(
                id=r.id,
                screening_id=r.screening_id,
                patient_id=r.patient_id,
                patient_name=p.name if p else "Unknown",
                patient_code=p.patient_code if p else None,
                patient_age=p.age if p else None,
                patient_gender=p.gender if p else None,
                worker_id=r.worker_id,
                worker_name=w.full_name if w else "Health Worker",
                risk_category=s.final_risk_category if s else None,
                screening_date=s.screening_date if s else None,
                screening_location=p.village if p else None,
                referral_facility=r.referral_facility,
                urgency=r.urgency,
                status=r.status,
                lab_confirmed_hb=r.lab_confirmed_hb,
                clinical_notes=r.clinical_notes,
                prescribed_treatment=r.prescribed_treatment,
                sync_status=r.sync_status,
                created_at=r.created_at,
                updated_at=r.updated_at
            )
        )
        
    return ReferralListResponse(total=total, page=page, limit=limit, items=items)

@router.patch("/{referral_id}", response_model=ReferralResponse)
def update_referral_status(
    referral_id: str,
    referral_update: ReferralUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Updates referral status, facility, or lab confirmation Hb outcome."""
    ref = db.query(Referral).filter(Referral.id == referral_id).first()
    if not ref:
        raise HTTPException(status_code=404, detail="Referral record not found")
        
    if referral_update.status is not None:
        ref.status = referral_update.status
    if referral_update.referral_facility is not None:
        ref.referral_facility = referral_update.referral_facility
    if referral_update.urgency is not None:
        ref.urgency = referral_update.urgency
    if referral_update.lab_confirmed_hb is not None:
        ref.lab_confirmed_hb = referral_update.lab_confirmed_hb
    if referral_update.clinical_notes is not None:
        ref.clinical_notes = referral_update.clinical_notes
    if referral_update.prescribed_treatment is not None:
        ref.prescribed_treatment = referral_update.prescribed_treatment
        
    db.commit()
    db.refresh(ref)
    
    p = db.query(Patient).filter(Patient.id == ref.patient_id).first()
    s = db.query(Screening).filter(Screening.id == ref.screening_id).first()
    w = db.query(Worker).filter(Worker.id == ref.worker_id).first()
    
    return ReferralResponse(
        id=ref.id,
        screening_id=ref.screening_id,
        patient_id=ref.patient_id,
        patient_name=p.name if p else "Unknown",
        patient_code=p.patient_code if p else None,
        patient_age=p.age if p else None,
        patient_gender=p.gender if p else None,
        worker_id=ref.worker_id,
        worker_name=w.full_name if w else "Health Worker",
        risk_category=s.final_risk_category if s else None,
        screening_date=s.screening_date if s else None,
        screening_location=p.village if p else None,
        referral_facility=ref.referral_facility,
        urgency=ref.urgency,
        status=ref.status,
        lab_confirmed_hb=ref.lab_confirmed_hb,
        clinical_notes=ref.clinical_notes,
        prescribed_treatment=ref.prescribed_treatment,
        sync_status=ref.sync_status,
        created_at=ref.created_at,
        updated_at=ref.updated_at
    )
