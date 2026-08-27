from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from backend.app.database import get_db
from backend.app.models.user import User
from backend.app.models.worker import Worker
from backend.app.auth.dependencies import get_current_user, require_admin

router = APIRouter(prefix="/workers", tags=["Workers"])

@router.get("/me")
def get_my_worker_profile(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Returns the worker profile associated with logged in user."""
    worker = db.query(Worker).filter(Worker.user_id == current_user.id).first()
    if not worker:
        return {
            "id": None,
            "user_id": current_user.id,
            "worker_code": "ADMIN-001",
            "full_name": current_user.username,
            "role_type": current_user.role,
            "village": "District HQ",
            "district": "Varanasi"
        }
    return {
        "id": worker.id,
        "user_id": worker.user_id,
        "worker_code": worker.worker_code,
        "full_name": worker.full_name,
        "phone": worker.phone,
        "role_type": worker.role_type,
        "village": worker.village,
        "district": worker.district,
        "state": worker.state
    }

@router.get("", response_model=List[dict])
def list_workers(db: Session = Depends(get_db), admin_user: User = Depends(require_admin)):
    """Lists all health workers (Admin only)."""
    workers = db.query(Worker).all()
    return [
        {
            "id": w.id,
            "worker_code": w.worker_code,
            "full_name": w.full_name,
            "phone": w.phone,
            "role_type": w.role_type,
            "village": w.village,
            "district": w.district
        } for w in workers
    ]
