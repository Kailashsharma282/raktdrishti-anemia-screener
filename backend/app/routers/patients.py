from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from backend.app.database import get_db
from backend.app.models.user import User
from backend.app.models.worker import Worker
from backend.app.schemas.patient import PatientCreate, PatientUpdate, PatientResponse, PatientListResponse
from backend.app.services.patient_service import PatientService
from backend.app.auth.dependencies import get_current_user

router = APIRouter(prefix="/patients", tags=["Patients"])

@router.get("", response_model=PatientListResponse)
def list_patients(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    search: Optional[str] = None,
    village: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Retrieves paginated patient list with search and filters."""
    total, items = PatientService.get_patients(db, page=page, limit=limit, search=search, village=village)
    return PatientListResponse(total=total, page=page, limit=limit, items=items)

@router.post("", response_model=PatientResponse, status_code=status.HTTP_201_CREATED)
def create_patient(
    patient_in: PatientCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Registers a new patient."""
    worker = db.query(Worker).filter(Worker.user_id == current_user.id).first()
    worker_id = worker.id if worker else None
    
    patient = PatientService.create_patient(db, patient_in, worker_id=worker_id)
    patient_dict = PatientService.get_patient_by_id(db, patient.id)
    return patient_dict

@router.get("/{patient_id}", response_model=PatientResponse)
def get_patient(
    patient_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Fetches details and screening history for a specific patient."""
    patient_dict = PatientService.get_patient_by_id(db, patient_id)
    if not patient_dict:
        raise HTTPException(status_code=404, detail="Patient not found")
    return patient_dict
