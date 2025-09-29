from fastapi import APIRouter

router = APIRouter(prefix="/health", tags=["health"])


@router.get("/live")
def liveness():
    return {"status": "live"}


@router.get("/ready")
def readiness():
    return {"status": "ready"}
