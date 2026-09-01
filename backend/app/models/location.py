import uuid
from sqlalchemy import Column, String
from sqlalchemy.orm import relationship
from backend.app.database import Base

class Location(Base):
    __tablename__ = "locations"

    id = Column(String(64), primary_key=True, default=lambda: str(uuid.uuid4()))
    village = Column(String(100), nullable=False, index=True)
    ward = Column(String(50), nullable=True)
    block = Column(String(100), nullable=True)
    district = Column(String(100), nullable=False, index=True)
    state = Column(String(100), default="Uttar Pradesh")

    # Relationships
    patients = relationship("Patient", back_populates="location")
