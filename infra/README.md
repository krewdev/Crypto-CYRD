Infrastructure
--------------

Prerequisites: Docker and Docker Compose (optional in this environment).

Services:
- Postgres 15 (port 5432)
- FastAPI Backend (port 8000)

Commands:
- Start: `cd infra && docker compose up -d --build`
- Stop: `docker compose down`

Environment files:
- `backend/.env.example` copy to `.env` and adjust secrets
