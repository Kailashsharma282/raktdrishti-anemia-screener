from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from backend.app.database import get_db
from backend.app.utils.seed_data import seed_initial_data

router = APIRouter(prefix="/demo", tags=["Hackathon Demo Controls"])

@router.post("/reset", status_code=status.HTTP_200_OK)
def reset_demo_data(db: Session = Depends(get_db)):
    """
    Demo Reset Endpoint:
    Resets the database and restores the standard baseline synthetic demo dataset.
    Intended for seamless repeat presentations during hackathon judging rounds.
    """
    seed_initial_data(db, reset=True)
    return {
        "status": "success",
        "message": "Demo database successfully reset with standard synthetic records."
    }
