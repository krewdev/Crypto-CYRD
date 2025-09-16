from fastapi import APIRouter

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.post("/send-test")
def send_test():
    # Placeholder for push notification integration
    return {"success": True}
