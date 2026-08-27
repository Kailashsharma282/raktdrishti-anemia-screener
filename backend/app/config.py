import os
from typing import List
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    APP_NAME: str = "RaktDrishti"
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    API_V1_PREFIX: str = "/api/v1"
    
    # Database
    DATABASE_URL: str = "sqlite:///./raktdrishti.db"
    
    # JWT Security
    JWT_SECRET: str = "raktdrishti_super_secure_jwt_secret_key_change_in_production_2026"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440  # 24 hours
    
    # CORS
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:5173",
        "http://localhost:8080",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8000",
        "*"
    ]
    
    # ML & Quality thresholds
    IMAGE_QUALITY_THRESHOLD: float = 60.0
    CALIBRATION_CONFIDENCE_THRESHOLD: float = 0.70
    MODEL_VERSION: str = "v1.0.0-mvp-demo"
    
    class Config:
        env_file = ".env"
        extra = "allow"

settings = Settings()
