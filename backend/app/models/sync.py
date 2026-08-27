import uuid
from datetime import datetime
from sqlalchemy import Column, String, Integer, DateTime, ForeignKey, JSON
from sqlalchemy.orm import relationship
from backend.app.database import Base

class SyncEvent(Base):
    __tablename__ = "sync_events"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    worker_id = Column(String(36), ForeignKey("workers.id"), nullable=True)
    device_id = Column(String(100), nullable=True)
    client_timestamp = Column(DateTime, nullable=True)
    
    synced_patients = Column(Integer, default=0)
    synced_screenings = Column(Integer, default=0)
    synced_referrals = Column(Integer, default=0)
    conflicts_resolved = Column(Integer, default=0)
    
    status = Column(String(30), default="SUCCESS")  # SUCCESS, PARTIAL, FAILED
    error_message = Column(String(255), nullable=True)
    payload_summary = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    worker = relationship("Worker", back_populates="sync_events")
