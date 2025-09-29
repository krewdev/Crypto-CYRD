Cypher Relay - Monorepo
=======================

This repository contains the source code for Cypher Relay (Relay Vault mobile apps, backend API, smart contracts, and deployment tooling). Work in progress.

Structure
---------

- `backend/` FastAPI service (Python) for QR redemption, pathways, push notifications, and chain interactions
- `contracts/evm/` EVM smart contracts (Solidity) for $CYRD (ERC-20) and Redemption
- `contracts/solana/` Solana programs (Anchor) for redemption logic and SPL token integration
- `mobile/android/` Android app (Kotlin + Jetpack Compose)
- `mobile/ios/` iOS app (SwiftUI)
- `infra/` Docker Compose and environment templates

See `infra/README.md` for setup instructions once scaffolding is complete.

Quickstart
----------

- Backend: `cd backend && python -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt && uvicorn app.main:app --reload`
- Android: Open `mobile/android` in Android Studio; run app
- iOS: Open `mobile/ios` in Xcode (SwiftPM), run `RelayVaultApp`
- Contracts (EVM): `cd contracts/evm && npm install && npm run build`