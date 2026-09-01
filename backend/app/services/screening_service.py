import uuid
from typing import Optional, List, Tuple
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy import desc
from backend.app.models.screening import Screening, ScreeningImage, ScreeningPrediction
from backend.app.models.patient import Patient
from backend.app.models.referral import Referral
from backend.app.schemas.screening import ScreeningCreate
from backend.app.utils.heuristics import calculate_risk_category

class ScreeningService:
    @staticmethod
    def get_screenings(
        db: Session,
        page: int = 1,
        limit: int = 20,
        patient_id: Optional[str] = None,
        risk_category: Optional[str] = None
    ) -> Tuple[int, List[dict]]:
        query = db.query(Screening)
        if patient_id:
            query = query.filter(Screening.patient_id == patient_id)
        if risk_category:
            query = query.filter(Screening.final_risk_category == risk_category)
            
        total = query.count()
        screenings = query.order_by(desc(Screening.screening_date)).offset((page - 1) * limit).limit(limit).all()
        
        items = []
        for s in screenings:
            p = db.query(Patient).filter(Patient.id == s.patient_id).first()
            ref = db.query(Referral).filter(Referral.screening_id == s.id).first()
            
            s_dict = {
                "id": s.id,
                "patient_id": s.patient_id,
                "patient_name": p.name if p else "Unknown",
                "patient_code": p.patient_code if p else None,
                "patient_age": p.age if p else None,
                "patient_gender": p.gender if p else None,
                "worker_id": s.worker_id,
                "screening_date": s.screening_date,
                "device_id": s.device_id,
                "conjunctiva_quality": s.conjunctiva_quality,
                "nail_quality": s.nail_quality,
                "palm_quality": s.palm_quality,
                "overall_quality": s.overall_quality,
                "final_risk_category": s.final_risk_category,
                "risk_score": s.risk_score,
                "confidence": s.confidence,
                "model_version": s.model_version,
                "status": s.status,
                "sync_status": s.sync_status,
                "images": [
                    {
                        "id": img.id,
                        "site_type": img.site_type,
                        "local_path": img.local_path,
                        "cloud_path": img.cloud_path,
                        "quality_score": img.quality_score,
                        "calibration_detected": img.calibration_detected,
                        "illumination_gain": img.illumination_gain,
                        "color_features": img.color_features,
                        "created_at": img.created_at
                    } for img in s.images
                ],
                "referral_id": ref.id if ref else None,
                "referral_status": ref.status if ref else None,
                "created_at": s.created_at
            }
            items.append(s_dict)
            
        return total, items

    @staticmethod
    def create_screening(db: Session, screening_in: ScreeningCreate, worker_id: Optional[str] = None) -> Screening:
        # Check idempotency for offline sync
        if screening_in.id:
            existing = db.query(Screening).filter(Screening.id == screening_in.id).first()
            if existing:
                return existing

        # Resolve patient_id if client passed patient_code or custom identifier
        patient = db.query(Patient).filter(
            (Patient.id == screening_in.patient_id) | (Patient.patient_code == screening_in.patient_id)
        ).first()
        if patient:
            resolved_patient_id = patient.id
        else:
            new_patient = Patient(
                id=str(uuid.uuid4()),
                patient_code=screening_in.patient_id if screening_in.patient_id.startswith("RD-") else f"RD-{str(uuid.uuid4())[:8]}",
                worker_id=worker_id,
                name="Frontline Beneficiary",
                age=25,
                gender="female",
                pregnancy_status="unknown",
                village="Screening Camp"
            )
            db.add(new_patient)
            db.flush()
            resolved_patient_id = new_patient.id

        overall_quality = screening_in.overall_quality or round(
            (screening_in.conjunctiva_quality + screening_in.nail_quality + screening_in.palm_quality) / 3.0, 1
        )
        
        screening = Screening(
            id=screening_in.id or str(uuid.uuid4()),
            patient_id=resolved_patient_id,
            worker_id=worker_id or (patient.worker_id if patient else None),
            screening_date=screening_in.screening_date or datetime.utcnow(),
            device_id=screening_in.device_id,
            conjunctiva_quality=screening_in.conjunctiva_quality,
            nail_quality=screening_in.nail_quality,
            palm_quality=screening_in.palm_quality,
            overall_quality=overall_quality,
            final_risk_category=screening_in.final_risk_category,
            risk_score=screening_in.risk_score,
            confidence=screening_in.confidence,
            model_version=screening_in.model_version,
            status="completed",
            sync_status="SYNCED"
        )
        db.add(screening)
        db.flush()

        # Add images if provided
        if screening_in.images:
            for img_in in screening_in.images:
                img = ScreeningImage(
                    id=img_in.id or str(uuid.uuid4()),
                    screening_id=screening.id,
                    site_type=img_in.site_type,
                    local_path=img_in.local_path,
                    cloud_path=img_in.cloud_path,
                    quality_score=img_in.quality_score,
                    calibration_detected=img_in.calibration_detected,
                    illumination_gain=img_in.illumination_gain,
                    color_features=img_in.color_features
                )
                db.add(img)

        # Automatically create referral recommendation if high or moderate risk
        if screening_in.final_risk_category in ["MODERATE", "SEVERE"]:
            existing_ref = db.query(Referral).filter(Referral.screening_id == screening.id).first()
            if not existing_ref:
                facility = "Community Health Centre (CHC) Shivpur" if screening_in.final_risk_category == "MODERATE" else "District Hospital Varanasi"
                urgency = "high" if screening_in.final_risk_category == "MODERATE" else "immediate"
                ref = Referral(
                    id=str(uuid.uuid4()),
                    screening_id=screening.id,
                    patient_id=screening.patient_id,
                    worker_id=worker_id,
                    referral_facility=facility,
                    urgency=urgency,
                    status="Pending",
                    clinical_notes=f"Automated referral generated due to {screening_in.final_risk_category} risk score ({screening_in.risk_score:.2f}).",
                    sync_status="SYNCED"
                )
                db.add(ref)

        db.commit()
        db.refresh(screening)
        return screening
