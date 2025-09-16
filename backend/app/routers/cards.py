from fastapi import APIRouter, Depends, Header, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from hashlib import sha256
from datetime import datetime
import uuid

from app.deps import get_db
from app.db.models import Card
from app.core.config import settings


router = APIRouter(prefix="/cards", tags=["cards"])


class CreateCardRequest(BaseModel):
    value_cyrd: int
    native_chain: str
    token_type: str = "CYRD"


class CardResponse(BaseModel):
    card_id: str
    qr_code: str
    value_cyrd: int
    native_chain: str
    is_redeemed: bool


def _hash_qr(qr_code: str) -> str:
    return sha256((qr_code + settings.qr_signing_secret).encode()).hexdigest()


@router.post("", response_model=CardResponse)
def create_card(
    payload: CreateCardRequest,
    db: Session = Depends(get_db),
    x_admin_token: str | None = Header(default=None, alias="X-Admin-Token"),
):
    if x_admin_token != settings.jwt_secret:
        raise HTTPException(status_code=401, detail="Unauthorized")

    raw_code = str(uuid.uuid4())
    qr_hash = _hash_qr(raw_code)
    card = Card(
        card_id=str(uuid.uuid4()),
        qr_code_hash=qr_hash,
        value_cyrd=payload.value_cyrd,
        token_type=payload.token_type,
        native_chain=payload.native_chain,
        is_redeemed=False,
        redeemed_at=None,
    )
    db.add(card)
    db.commit()
    return CardResponse(
        card_id=card.card_id,
        qr_code=raw_code,
        value_cyrd=card.value_cyrd,
        native_chain=card.native_chain,
        is_redeemed=card.is_redeemed,
    )


@router.get("/{card_id}", response_model=CardResponse)
def get_card(card_id: str, db: Session = Depends(get_db), x_admin_token: str | None = Header(default=None, alias="X-Admin-Token")):
    if x_admin_token != settings.jwt_secret:
        raise HTTPException(status_code=401, detail="Unauthorized")
    card = db.query(Card).filter_by(card_id=card_id).first()
    if card is None:
        raise HTTPException(status_code=404, detail="Not found")
    # QR code value cannot be retrieved; respond with placeholder
    return CardResponse(
        card_id=card.card_id,
        qr_code="REDACTED",
        value_cyrd=card.value_cyrd,
        native_chain=card.native_chain,
        is_redeemed=card.is_redeemed,
    )
