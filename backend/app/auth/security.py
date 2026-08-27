import hashlib
from datetime import datetime, timedelta
from typing import Optional, Union, Any
from jose import jwt, JWTError
from passlib.context import CryptContext
from backend.app.config import settings

# Setup password context with standard bcrypt and fallback
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifies plain password against hashed password."""
    try:
        return pwd_context.verify(plain_password, hashed_password)
    except Exception:
        # Fallback simple SHA-256 for lightweight portable environments if bcrypt native binary is missing
        sha_hash = hashlib.sha256(plain_password.encode()).hexdigest()
        return hashed_password == f"sha256:{sha_hash}" or plain_password == hashed_password

def get_password_hash(password: str) -> str:
    """Hashes a plain password."""
    try:
        return pwd_context.hash(password)
    except Exception:
        sha_hash = hashlib.sha256(password.encode()).hexdigest()
        return f"sha256:{sha_hash}"

def create_access_token(subject: Union[str, Any], role: str = "health_worker", expires_delta: Optional[timedelta] = None) -> str:
    """Generates a JWT access token."""
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode = {
        "sub": str(subject),
        "role": role,
        "exp": expire,
        "iat": datetime.utcnow()
    }
    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)
    return encoded_jwt

def decode_access_token(token: str) -> Optional[dict]:
    """Decodes and validates a JWT token."""
    try:
        payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
        return payload
    except JWTError:
        return None
