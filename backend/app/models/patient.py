import uuid
from datetime import datetime
from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from backend.app.database import Base

class Patient(Base):
    __tablename__ = "patients"

    id = Column(String(64), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_code = Column(String(50), unique=True, index=True, nullable=False)
    worker_id = Column(String(64), ForeignKey("workers.id"), nullable=True)
    name = Column(String(100), nullable=False, index=True)
    age = Column(Integer, nullable=False)
    gender = Column(String(20), nullable=False)  # female, male, other
    pregnancy_status = Column(String(30), default="not_applicable")  # not_applicable, pregnant, not_pregnant, unknown
    phone = Column(String(20), nullable=True)
    village = Column(String(100), nullable=True, index=True)
    location_id = Column(String(64), ForeignKey("locations.id"), nullable=True)
    notes = Column(Text, nullable=True)
    sync_status = Column(String(20), default="SYNCED")  # PENDING, SYNCING, SYNCED, FAILED
    created_by = Column(String(64), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    worker = relationship("Worker", back_populates="patients")
    location = relationship("Location", back_populates="patients")
    screenings = relationship("Screening", back_populates="patient", cascade="all, delete-orphan")
    referrals = relationship("Referral", back_populates="patient", cascade="all, delete-orphan")
