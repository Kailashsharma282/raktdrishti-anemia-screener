import uuid
from typing import Optional, List, Tuple
from sqlalchemy.orm import Session
from sqlalchemy import or_, desc
from backend.app.models.patient import Patient
from backend.app.models.screening import Screening
from backend.app.models.referral import Referral
from backend.app.schemas.patient import PatientCreate, PatientUpdate

class PatientService:
    @staticmethod
    def get_patients(
        db: Session,
        page: int = 1,
        limit: int = 20,
        search: Optional[str] = None,
        village: Optional[str] = None
    ) -> Tuple[int, List[dict]]:
        query = db.query(Patient)
        if search:
            search_filter = f"%{search}%"
            query = query.filter(
                or_(
                    Patient.name.ilike(search_filter),
                    Patient.patient_code.ilike(search_filter),
                    Patient.phone.ilike(search_filter)
                )
            )
        if village:
            query = query.filter(Patient.village == village)
        
        total = query.count()
        patients = query.order_by(desc(Patient.created_at)).offset((page - 1) * limit).limit(limit).all()
        
        items = []
        for p in patients:
            # fetch latest screening
            latest_screening = db.query(Screening).filter(Screening.patient_id == p.id).order_by(desc(Screening.screening_date)).first()
            screenings_count = db.query(Screening).filter(Screening.patient_id == p.id).count()
            active_ref = db.query(Referral).filter(Referral.patient_id == p.id).order_by(desc(Referral.created_at)).first()
            
            p_dict = {
                "id": p.id,
                "patient_code": p.patient_code,
                "name": p.name,
                "age": p.age,
                "gender": p.gender,
                "pregnancy_status": p.pregnancy_status,
                "phone": p.phone,
                "village": p.village,
                "notes": p.notes,
                "worker_id": p.worker_id,
                "location_id": p.location_id,
                "sync_status": p.sync_status,
                "created_at": p.created_at,
                "updated_at": p.updated_at,
                "latest_risk_category": latest_screening.final_risk_category if latest_screening else None,
                "latest_risk_score": latest_screening.risk_score if latest_screening else None,
                "latest_screening_date": latest_screening.screening_date if latest_screening else None,
                "screenings_count": screenings_count,
                "active_referral": {
                    "id": active_ref.id,
                    "status": active_ref.status,
                    "facility": active_ref.referral_facility
                } if active_ref else None
            }
            items.append(p_dict)
            
        return total, items

    @staticmethod
    def get_patient_by_id(db: Session, patient_id: str) -> Optional[dict]:
        p = db.query(Patient).filter(Patient.id == patient_id).first()
        if not p:
            return None
        latest_screening = db.query(Screening).filter(Screening.patient_id == p.id).order_by(desc(Screening.screening_date)).first()
        screenings_count = db.query(Screening).filter(Screening.patient_id == p.id).count()
        active_ref = db.query(Referral).filter(Referral.patient_id == p.id).order_by(desc(Referral.created_at)).first()
        
        return {
            "id": p.id,
            "patient_code": p.patient_code,
            "name": p.name,
            "age": p.age,
            "gender": p.gender,
            "pregnancy_status": p.pregnancy_status,
            "phone": p.phone,
            "village": p.village,
            "notes": p.notes,
            "worker_id": p.worker_id,
            "location_id": p.location_id,
            "sync_status": p.sync_status,
            "created_at": p.created_at,
            "updated_at": p.updated_at,
            "latest_risk_category": latest_screening.final_risk_category if latest_screening else None,
            "latest_risk_score": latest_screening.risk_score if latest_screening else None,
            "latest_screening_date": latest_screening.screening_date if latest_screening else None,
            "screenings_count": screenings_count,
            "active_referral": {
                "id": active_ref.id,
                "status": active_ref.status,
                "facility": active_ref.referral_facility
            } if active_ref else None
        }

    @staticmethod
    def create_patient(db: Session, patient_in: PatientCreate, worker_id: Optional[str] = None) -> Patient:
        # Check if already exists (for sync idempotency)
        if patient_in.id:
            existing = db.query(Patient).filter(Patient.id == patient_in.id).first()
            if existing:
                return existing

        # Generate unique code if not provided
        patient_code = patient_in.patient_code
        if not patient_code:
            count = db.query(Patient).count() + 1
            patient_code = f"RD-2026-{count:04d}"

        patient = Patient(
            id=patient_in.id or str(uuid.uuid4()),
            patient_code=patient_code,
            worker_id=worker_id,
            name=patient_in.name,
            age=patient_in.age,
            gender=patient_in.gender,
            pregnancy_status=patient_in.pregnancy_status,
            phone=patient_in.phone,
            village=patient_in.village,
            location_id=patient_in.location_id,
            notes=patient_in.notes,
            sync_status="SYNCED"
        )
        db.add(patient)
        db.commit()
        db.refresh(patient)
        return patient
