from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from backend.app.database import get_db
from backend.app.models.user import User
from backend.app.models.worker import Worker
from backend.app.schemas.sync import SyncBatchRequest, SyncBatchResponse
from backend.app.services.sync_service import SyncService
from backend.app.auth.dependencies import get_current_user

router = APIRouter(prefix="/sync", tags=["Synchronization"])

@router.post("", response_model=SyncBatchResponse)
def batch_sync(
    batch: SyncBatchRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Offline Synchronization Endpoint:
    Receives local SQLite batch updates (patients, screenings, referrals),
    upserts into PostgreSQL cloud database, and returns synchronized confirmation.
    """
    worker = db.query(Worker).filter(Worker.user_id == current_user.id).first()
    worker_id = worker.id if worker else (batch.worker_id or "default-worker")
    
    return SyncService.process_sync_batch(db, batch, worker_id=worker_id)
