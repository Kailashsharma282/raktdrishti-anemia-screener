import uuid
from datetime import datetime
from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from backend.app.database import Base

class Referral(Base):
    __tablename__ = "referrals"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    screening_id = Column(String(36), ForeignKey("screenings.id"), nullable=False, unique=True)
    patient_id = Column(String(36), ForeignKey("patients.id"), nullable=False, index=True)
    worker_id = Column(String(36), ForeignKey("workers.id"), nullable=True)
    
    referral_facility = Column(String(150), nullable=False)  # CHC, PHC, District Hospital
    urgency = Column(String(20), default="high")  # routine, high, immediate
    status = Column(String(30), default="Pending")  # Pending, Referred, Lab Test Completed, Follow-up Required
    
    # Lab Confirmation Outcome (when test is complete)
    lab_confirmed_hb = Column(Float, nullable=True)  # in g/dL
    clinical_notes = Column(Text, nullable=True)
    prescribed_treatment = Column(String(255), nullable=True)  # IFA, IV Iron, Diet
    
    sync_status = Column(String(20), default="SYNCED")  # PENDING, SYNCING, SYNCED, FAILED
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    screening = relationship("Screening", back_populates="referral")
    patient = relationship("Patient", back_populates="referrals")
    worker = relationship("Worker", back_populates="referrals")
