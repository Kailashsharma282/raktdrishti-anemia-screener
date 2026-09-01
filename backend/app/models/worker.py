import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from backend.app.database import Base

class Worker(Base):
    __tablename__ = "workers"

    id = Column(String(64), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(64), ForeignKey("users.id"), nullable=False, unique=True)
    worker_code = Column(String(50), unique=True, index=True, nullable=False)
    full_name = Column(String(100), nullable=False)
    phone = Column(String(20), nullable=True)
    role_type = Column(String(50), default="ASHA")  # ASHA, ANM, Anganwadi, MO
    village = Column(String(100), nullable=True)
    district = Column(String(100), nullable=True)
    state = Column(String(100), default="Uttar Pradesh")
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="worker_profile")
    patients = relationship("Patient", back_populates="worker")
    screenings = relationship("Screening", back_populates="worker")
    referrals = relationship("Referral", back_populates="worker")
    sync_events = relationship("SyncEvent", back_populates="worker")
