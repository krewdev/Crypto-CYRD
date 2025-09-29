from pydantic import BaseModel
import os


class Settings(BaseModel):
    environment: str = os.getenv("ENVIRONMENT", "development")
    database_url: str = os.getenv("DATABASE_URL", "postgresql+psycopg://relay:relaypw@localhost:5432/relay")
    jwt_secret: str = os.getenv("JWT_SECRET", "change_me")
    qr_signing_secret: str = os.getenv("QR_SIGNING_SECRET", "change_me_qr")
    log_level: str = os.getenv("LOG_LEVEL", "INFO")
    evm_enabled: bool = os.getenv("EVM_ENABLED", "false").lower() == "true"
    evm_polygon_rpc: str | None = os.getenv("EVM_POLYGON_RPC")
    evm_arbitrum_rpc: str | None = os.getenv("EVM_ARBITRUM_RPC")
    evm_backend_private_key: str | None = os.getenv("EVM_BACKEND_PRIVATE_KEY")
    evm_redemption_address_polygon: str | None = os.getenv("EVM_REDEMPTION_ADDRESS_POLYGON")
    evm_redemption_address_arbitrum: str | None = os.getenv("EVM_REDEMPTION_ADDRESS_ARBITRUM")


settings = Settings()
