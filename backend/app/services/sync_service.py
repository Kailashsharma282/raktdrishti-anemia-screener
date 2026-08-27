import uuid
from datetime import datetime
from sqlalchemy.orm import Session
from backend.app.models.sync import SyncEvent
from backend.app.models.audit import AuditLog
from backend.app.models.patient import Patient
from backend.app.models.screening import Screening
from backend.app.models.referral import Referral
from backend.app.schemas.sync import SyncBatchRequest, SyncBatchResponse
from backend.app.services.patient_service import PatientService
from backend.app.services.screening_service import ScreeningService

class SyncService:
    @staticmethod
    def process_sync_batch(db: Session, batch: SyncBatchRequest, worker_id: str) -> SyncBatchResponse:
        synced_patients = 0
        synced_screenings = 0
        synced_referrals = 0
        conflicts = 0

        # 1. Sync Patients
        for p_in in batch.patients:
            try:
                PatientService.create_patient(db, p_in, worker_id=worker_id)
                synced_patients += 1
            except Exception:
                conflicts += 1

        # 2. Sync Screenings
        for s_in in batch.screenings:
            try:
                ScreeningService.create_screening(db, s_in, worker_id=worker_id)
                synced_screenings += 1
            except Exception:
                conflicts += 1

        # 3. Sync Referrals
        for r_in in batch.referrals:
            try:
                if r_in.id:
                    existing = db.query(Referral).filter(Referral.id == r_in.id).first()
                    if not existing:
                        ref = Referral(
                            id=r_in.id,
                            screening_id=r_in.screening_id,
                            patient_id=r_in.patient_id,
                            worker_id=worker_id,
                            referral_facility=r_in.referral_facility,
                            urgency=r_in.urgency,
                            status="Pending",
                            clinical_notes=r_in.notes,
                            sync_status="SYNCED"
                        )
                        db.add(ref)
                        synced_referrals += 1
            except Exception:
                conflicts += 1

        db.commit()

        # Log sync event
        sync_ev = SyncEvent(
            id=str(uuid.uuid4()),
            worker_id=worker_id,
            device_id=batch.device_id,
            client_timestamp=batch.client_timestamp,
            synced_patients=synced_patients,
            synced_screenings=synced_screenings,
            synced_referrals=synced_referrals,
            conflicts_resolved=conflicts,
            status="SUCCESS",
            payload_summary={
                "patients_count": len(batch.patients),
                "screenings_count": len(batch.screenings),
                "referrals_count": len(batch.referrals)
            }
        )
        db.add(sync_ev)

        # Audit log
        audit = AuditLog(
            id=str(uuid.uuid4()),
            user_id=None,
            action="SYNC_BATCH",
            entity_type="SyncEvent",
            details=f"Synced {synced_patients} patients, {synced_screenings} screenings, {synced_referrals} referrals."
        )
        db.add(audit)
        db.commit()

        return SyncBatchResponse(
            status="success",
            synced_patients=synced_patients,
            synced_screenings=synced_screenings,
            synced_referrals=synced_referrals,
            conflicts_resolved=conflicts,
            server_timestamp=datetime.utcnow(),
            message=f"Sync successful! Processed {synced_patients + synced_screenings + synced_referrals} records."
        )
