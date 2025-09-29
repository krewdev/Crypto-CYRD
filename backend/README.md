Cypher Relay Backend (FastAPI)
-----------------------------

Run locally:

1. `python -m venv .venv && source .venv/bin/activate`
2. `pip install -r requirements.txt`
3. Set env vars or copy `.env.example` to `.env`
4. Run: `uvicorn app.main:app --reload`

Migrations:

- Configure `alembic.ini` URL or set `DATABASE_URL`
- `alembic upgrade head`

API Outline:
- `GET /health/live|ready`
- `POST /cards` (admin; returns QR secret value)
- `GET /cards/{card_id}` (admin)
- `POST /redeem` { device_id, qr_code, chain }
- `GET /pathways/{user_id}` / `POST /pathways/update`
