from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.deps import get_db
from app.db.models import PathwayProgress


router = APIRouter(prefix="/pathways", tags=["pathways"])


class PathwayStatus(BaseModel):
    pathway_id: str
    status: str


class PathwayUpdateRequest(BaseModel):
    user_id: str
    pathway_id: str
    status: str


@router.get("/{user_id}", response_model=list[PathwayStatus])
def get_pathways(user_id: str, db: Session = Depends(get_db)):
    rows = db.query(PathwayProgress).filter_by(user_id=user_id).all()
    return [PathwayStatus(pathway_id=r.pathway_id, status=r.status) for r in rows]


@router.post("/update", response_model=PathwayStatus)
def update_pathway(payload: PathwayUpdateRequest, db: Session = Depends(get_db)):
    if payload.status not in {"locked", "unlocked"}:
        raise HTTPException(status_code=400, detail="Invalid status")
    row = (
        db.query(PathwayProgress)
        .filter_by(user_id=payload.user_id, pathway_id=payload.pathway_id)
        .first()
    )
    if row is None:
        row = PathwayProgress(user_id=payload.user_id, pathway_id=payload.pathway_id, status=payload.status)
        db.add(row)
    else:
        row.status = payload.status
    db.commit()
    db.refresh(row)
    return PathwayStatus(pathway_id=row.pathway_id, status=row.status)
