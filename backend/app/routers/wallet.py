from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.deps import get_db
from app.mpc.service import MPCService
from app.db.models import TrustedContact, RecoveryRequest


router = APIRouter(prefix="/wallet", tags=["wallet"])


class InitWalletRequest(BaseModel):
    user_id: str


class InitWalletResponse(BaseModel):
    wallet_id: str


@router.post("/init", response_model=InitWalletResponse)
def init_wallet(payload: InitWalletRequest, db: Session = Depends(get_db)):
    svc = MPCService(db)
    wallet = svc.ensure_wallet(payload.user_id)
    return InitWalletResponse(wallet_id=wallet.wallet_id)


class Contact(BaseModel):
    name: str
    method: str
    value: str


@router.post("/contacts")
def set_contacts(user_id: str, contacts: list[Contact], db: Session = Depends(get_db)):
    db.query(TrustedContact).filter_by(user_id=user_id).delete()
    for c in contacts:
        db.add(TrustedContact(user_id=user_id, name=c.name, method=c.method, value=c.value))
    db.commit()
    return {"success": True}


@router.post("/recovery/start")
def start_recovery(user_id: str, db: Session = Depends(get_db)):
    req = RecoveryRequest(user_id=user_id, status="pending")
    db.add(req)
    db.commit()
    db.refresh(req)
    return {"recovery_id": req.id, "status": req.status}


@router.post("/recovery/approve")
def approve_recovery(recovery_id: int, db: Session = Depends(get_db)):
    req = db.query(RecoveryRequest).filter_by(id=recovery_id).first()
    if req is None:
        return {"success": False}
    req.status = "approved"
    db.commit()
    return {"success": True}
