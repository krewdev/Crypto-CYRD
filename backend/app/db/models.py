from sqlalchemy import Column, String, Integer, Boolean, DateTime, Text
from sqlalchemy.sql import func
from app.db import Base


class Card(Base):
    __tablename__ = "cards"

    card_id = Column(String, primary_key=True, index=True)
    qr_code_hash = Column(String, nullable=False, unique=True, index=True)
    value_cyrd = Column(Integer, nullable=False)
    token_type = Column(String, nullable=False, default="CYRD")
    native_chain = Column(String, nullable=False)
    is_redeemed = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    redeemed_at = Column(DateTime(timezone=True), nullable=True)


class User(Base):
    __tablename__ = "users"

    user_id = Column(String, primary_key=True, index=True)
    device_id = Column(String, nullable=False, index=True)
    wallet_address_polygon = Column(String, nullable=True)
    wallet_address_arbitrum = Column(String, nullable=True)
    wallet_address_solana = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())


class PathwayProgress(Base):
    __tablename__ = "pathways_progress"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(String, nullable=False, index=True)
    pathway_id = Column(String, nullable=False)
    status = Column(String, nullable=False, default="locked")
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())


class TransactionLog(Base):
    __tablename__ = "transaction_logs"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(String, nullable=False, index=True)
    chain = Column(String, nullable=False)
    tx_type = Column(String, nullable=False)
    amount_cyrd = Column(Integer, nullable=False)
    tx_hash = Column(String, nullable=True)
    note = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())


class MPCWallet(Base):
    __tablename__ = "mpc_wallets"

    wallet_id = Column(String, primary_key=True, index=True)
    user_id = Column(String, nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())


class MPCKeyShare(Base):
    __tablename__ = "mpc_key_shares"

    id = Column(Integer, primary_key=True, autoincrement=True)
    wallet_id = Column(String, nullable=False, index=True)
    share_type = Column(String, nullable=False)  # device|cloud|server
    provider = Column(String, nullable=True)  # icloud|gdrive|...
    share_encrypted = Column(Text, nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())


class TrustedContact(Base):
    __tablename__ = "trusted_contacts"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, nullable=False, index=True)
    name = Column(String, nullable=False)
    method = Column(String, nullable=False)  # sms|email|app
    value = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())


class RecoveryRequest(Base):
    __tablename__ = "recovery_requests"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, nullable=False, index=True)
    status = Column(String, nullable=False, default="pending")  # pending|approved|completed|cancelled
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
