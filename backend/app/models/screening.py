import uuid
from datetime import datetime
from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Text, JSON, Boolean
from sqlalchemy.orm import relationship
from backend.app.database import Base

class Screening(Base):
    __tablename__ = "screenings"

    id = Column(String(64), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = Column(String(64), ForeignKey("patients.id"), nullable=False, index=True)
    worker_id = Column(String(64), ForeignKey("workers.id"), nullable=True, index=True)
    screening_date = Column(DateTime, default=datetime.utcnow, nullable=False)
    device_id = Column(String(100), nullable=True)
    
    # Image Quality Scores (0.0 to 100.0)
    conjunctiva_quality = Column(Float, default=0.0)
    nail_quality = Column(Float, default=0.0)
    palm_quality = Column(Float, default=0.0)
    overall_quality = Column(Float, default=0.0)
    
    # Risk Predictions
    final_risk_category = Column(String(30), nullable=False)  # NORMAL, MILD, MODERATE, SEVERE
    risk_score = Column(Float, nullable=False)  # 0.0 to 1.0
    confidence = Column(Float, nullable=False)  # 0.0 to 1.0
    model_version = Column(String(50), default="v1.0.0-mvp-demo")
    
    # Metadata & Sync
    status = Column(String(30), default="completed")
    sync_status = Column(String(20), default="SYNCED")  # PENDING, SYNCING, SYNCED, FAILED
    retry_count = Column(Float, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    patient = relationship("Patient", back_populates="screenings")
    worker = relationship("Worker", back_populates="screenings")
    images = relationship("ScreeningImage", back_populates="screening", cascade="all, delete-orphan")
    prediction = relationship("ScreeningPrediction", back_populates="screening", uselist=False, cascade="all, delete-orphan")
    referral = relationship("Referral", back_populates="screening", uselist=False, cascade="all, delete-orphan")


class ScreeningImage(Base):
    __tablename__ = "screening_images"

    id = Column(String(64), primary_key=True, default=lambda: str(uuid.uuid4()))
    screening_id = Column(String(64), ForeignKey("screenings.id"), nullable=False, index=True)
    site_type = Column(String(30), nullable=False)  # conjunctiva, nail, palm
    local_path = Column(String(255), nullable=True)
    cloud_path = Column(String(255), nullable=True)
    quality_score = Column(Float, default=0.0)
    calibration_detected = Column(Boolean, default=True)
    illumination_gain = Column(Float, default=1.0)
    color_features = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    screening = relationship("Screening", back_populates="images")


class ScreeningPrediction(Base):
    __tablename__ = "screening_predictions"

    id = Column(String(64), primary_key=True, default=lambda: str(uuid.uuid4()))
    screening_id = Column(String(64), ForeignKey("screenings.id"), nullable=False, unique=True)
    model_name = Column(String(100), default="RaktDrishti-Fusion-Demo")
    model_version = Column(String(50), default="v1.0.0-mvp-demo")
    inference_timestamp = Column(DateTime, default=datetime.utcnow)
    
    conjunctiva_score = Column(Float, nullable=True)
    nail_score = Column(Float, nullable=True)
    palm_score = Column(Float, nullable=True)
    
    final_score = Column(Float, nullable=False)
    risk_category = Column(String(30), nullable=False)
    confidence = Column(Float, nullable=False)
    
    feature_vector = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    screening = relationship("Screening", back_populates="prediction")
