from pydantic import BaseModel
import os


class Settings(BaseModel):
    environment: str = os.getenv("ENVIRONMENT", "development")
    database_url: str = os.getenv("DATABASE_URL", "postgresql+psycopg://relay:relaypw@localhost:5432/relay")
    jwt_secret: str = os.getenv("JWT_SECRET", "change_me")
    qr_signing_secret: str = os.getenv("QR_SIGNING_SECRET", "change_me_qr")
    log_level: str = os.getenv("LOG_LEVEL", "INFO")


settings = Settings()
