from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from backend.app.database import get_db
from backend.app.models.user import User
from backend.app.models.worker import Worker
from backend.app.schemas.auth import Token, LoginRequest, UserResponse
from backend.app.auth.security import verify_password, create_access_token
from backend.app.auth.dependencies import get_current_user

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/login", response_model=Token)
def login(login_data: LoginRequest, db: Session = Depends(get_db)):
    """Authenticates user and returns JWT Bearer token."""
    user = db.query(User).filter(User.username == login_data.username).first()
    if not user or not verify_password(login_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    worker = db.query(Worker).filter(Worker.user_id == user.id).first()
    token = create_access_token(subject=user.id, role=user.role)
    
    user_info = {
        "id": user.id,
        "username": user.username,
        "email": user.email,
        "role": user.role,
        "worker_id": worker.id if worker else None,
        "worker_code": worker.worker_code if worker else None,
        "full_name": worker.full_name if worker else user.username,
        "village": worker.village if worker else None,
        "district": worker.district if worker else None
    }
    
    return Token(
        access_token=token,
        token_type="bearer",
        expires_in=86400,
        user=user_info
    )

@router.post("/verify")
def verify_token(current_user: User = Depends(get_current_user)):
    """Verifies token validity."""
    return {"valid": True, "user_id": current_user.id, "role": current_user.role}

@router.get("/me", response_model=UserResponse)
def get_current_user_profile(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Returns profile of authenticated user."""
    worker = db.query(Worker).filter(Worker.user_id == current_user.id).first()
    return UserResponse(
        id=current_user.id,
        username=current_user.username,
        email=current_user.email,
        role=current_user.role,
        is_active=current_user.is_active,
        worker_id=worker.id if worker else None,
        full_name=worker.full_name if worker else current_user.username,
        village=worker.village if worker else None,
        district=worker.district if worker else None
    )
