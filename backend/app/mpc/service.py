import uuid
from sqlalchemy.orm import Session
from app.db.models import MPCWallet, MPCKeyShare


class MPCService:
    def __init__(self, db: Session):
        self.db = db

    def ensure_wallet(self, user_id: str) -> MPCWallet:
        wallet = self.db.query(MPCWallet).filter_by(user_id=user_id).first()
        if wallet:
            return wallet
        wallet = MPCWallet(wallet_id=str(uuid.uuid4()), user_id=user_id)
        self.db.add(wallet)
        self.db.flush()
        # Simulate generating key shares (device/cloud/server), encrypted placeholders
        for kind in ("device", "cloud", "server"):
            share = MPCKeyShare(wallet_id=wallet.wallet_id, share_type=kind, provider=None, share_encrypted=f"enc:{uuid.uuid4()}")
            self.db.add(share)
        self.db.commit()
        return wallet
