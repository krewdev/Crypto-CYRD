from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routers import health, redeem, pathways, notifications, cards, wallet

app = FastAPI(title="Cypher Relay Backend", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(redeem.router)
app.include_router(pathways.router)
app.include_router(notifications.router)
app.include_router(cards.router)
app.include_router(wallet.router)

@app.get("/")
def root():
    return {"service": "relay-backend", "status": "ok"}
