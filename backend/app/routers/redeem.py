from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from hashlib import sha256
from datetime import datetime

from app.deps import get_db
from app.db.models import Card, User, TransactionLog
from app.core.config import settings


router = APIRouter(prefix="/redeem", tags=["redeem"])


class RedeemRequest(BaseModel):
    device_id: str
    qr_code: str
    chain: str


class RedeemResponse(BaseModel):
    success: bool
    user_id: str
    wallet_address: str | None
    amount_cyrd: int
    message: str


def _hash_qr(qr_code: str) -> str:
    return sha256((qr_code + settings.qr_signing_secret).encode()).hexdigest()


@router.post("", response_model=RedeemResponse)
def redeem_card(payload: RedeemRequest, db: Session = Depends(get_db)):
    # Hash and verify QR code exists and not redeemed
    qr_hash = _hash_qr(payload.qr_code)
    card: Card | None = db.query(Card).filter_by(qr_code_hash=qr_hash).first()
    if card is None:
        raise HTTPException(status_code=404, detail="Invalid card")
    if card.is_redeemed:
        raise HTTPException(status_code=409, detail="Card already redeemed")

    # Create or get user by device_id
    user = db.query(User).filter_by(device_id=payload.device_id).first()
    if user is None:
        user = User(user_id=payload.device_id, device_id=payload.device_id)
        db.add(user)
        db.flush()

    # TODO: Integrate MPC wallet provisioning and on-chain transfer via redemption contract
    # For now, simulate wallet address storage per chain
    wallet_address_attr = f"wallet_address_{payload.chain.lower()}"
    if not hasattr(user, wallet_address_attr):
        raise HTTPException(status_code=400, detail="Unsupported chain")

    wallet_address = getattr(user, wallet_address_attr)
    if wallet_address is None:
        wallet_address = f"sim-{payload.chain.lower()}-{user.user_id[:8]}"
        setattr(user, wallet_address_attr, wallet_address)

    # Mark card redeemed
    card.is_redeemed = True
    card.redeemed_at = datetime.utcnow()

    # Log transaction
    log = TransactionLog(
        user_id=user.user_id,
        chain=payload.chain.lower(),
        tx_type="redeem",
        amount_cyrd=card.value_cyrd,
        tx_hash=None,
        note="Simulated redemption",
    )
    db.add(log)

    db.commit()

    return RedeemResponse(
        success=True,
        user_id=user.user_id,
        wallet_address=wallet_address,
        amount_cyrd=card.value_cyrd,
        message="Redeemed successfully",
    )
