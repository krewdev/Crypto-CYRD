# Cypher Relay - Project Documentation

## Overview

Cypher Relay is a revolutionary Web3 onboarding system designed to bring the next billion users into cryptocurrency through radical simplicity and absolute trust. The system consists of prepaid physical/digital cards loaded with $CYRD tokens and a mobile app (Relay Vault) that allows users to redeem these cards into self-custodial wallets without traditional crypto complexity.

## Project Structure

```
cypher-relay/
├── backend/                 # Node.js API server
│   ├── src/
│   │   ├── api/            # API routes and controllers
│   │   ├── models/         # Sequelize database models
│   │   ├── services/       # Business logic services
│   │   └── utils/          # Utility functions
│   └── package.json
├── contracts/              # Smart contracts
│   ├── src/
│   │   ├── CypherRelayDollar.sol    # $CYRD token contract
│   │   └── CypherRedemption.sol     # Card redemption contract
│   └── hardhat.config.js
├── mobile/
│   ├── ios/               # Native iOS app (SwiftUI)
│   │   └── RelayVault/
│   └── android/           # Native Android app (Kotlin)
│       └── RelayVault/
└── docs/                  # Additional documentation
```

## Key Features

### 1. Zero-Friction Onboarding
- No signup required - just scan a card
- No seed phrases - MPC wallet technology
- No KYC for amounts under $500
- Instant wallet creation upon first scan

### 2. Educational Gateway System ("Pathways")
- Features locked behind 30-60 second micro-lessons
- Interactive tutorials with simple quizzes
- Gradual complexity introduction
- Gamified learning experience

### 3. Multi-Chain Architecture
- Native support for Polygon, Arbitrum, and Solana
- Bridged access to Ethereum, Avalanche, and BSC
- Seamless chain abstraction for users
- Automatic chain detection and management

### 4. Security & Recovery
- Multi-Party Computation (MPC) wallets
- Cloud backup integration (iCloud/Google Drive)
- Social recovery with trusted contacts
- No seed phrase management

## Setup Instructions

### Prerequisites
- Node.js 18+
- PostgreSQL 14+
- iOS: Xcode 15+, Swift 5.9+
- Android: Android Studio, Kotlin 1.9+
- Hardhat for smart contract deployment

### Backend Setup

1. Install dependencies:
```bash
cd backend
npm install
```

2. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. Set up PostgreSQL database:
```bash
createdb cypher_relay
npm run migrate
```

4. Start the server:
```bash
npm run dev  # Development
npm start    # Production
```

### Smart Contract Deployment

1. Install dependencies:
```bash
cd contracts
npm install
```

2. Configure environment:
```bash
cp .env.example .env
# Add your private key and RPC URLs
```

3. Deploy contracts:
```bash
# Deploy to local network
npm run deploy:local

# Deploy to testnets
npm run deploy:polygon-mumbai
npm run deploy:arbitrum-goerli

# Deploy to mainnet (be careful!)
npm run deploy:polygon
npm run deploy:arbitrum
```

4. Verify contracts:
```bash
npx hardhat verify --network polygon <CONTRACT_ADDRESS>
```

### iOS App Setup

1. Install dependencies:
```bash
cd mobile/ios/RelayVault
swift package resolve
```

2. Open in Xcode:
```bash
open RelayVault.xcodeproj
```

3. Configure signing & capabilities:
- Add your development team
- Enable Camera usage
- Enable Keychain sharing
- Configure iCloud capabilities

4. Build and run on simulator or device

### Android App Setup

1. Open in Android Studio:
```bash
cd mobile/android
# Open in Android Studio
```

2. Sync Gradle dependencies

3. Configure signing for release builds

4. Build and run

## API Endpoints

### Card Redemption
- `POST /api/cards/redeem` - Redeem a card
- `GET /api/cards/status/:cardId` - Check card status
- `POST /api/cards/verify` - Verify QR code

### Wallet Management
- `GET /api/wallets/:userId` - Get user wallets
- `POST /api/wallets/balances` - Get wallet balances

### Transactions
- `GET /api/users/:userId/transactions` - Get transaction history
- `POST /api/transactions/send` - Send transaction

### Pathways
- `GET /api/pathways` - Get all pathways
- `GET /api/pathways/progress/:userId` - Get user progress
- `PUT /api/pathways/progress/:userId` - Update progress

## Database Schema

### Core Tables
- `users` - User accounts and settings
- `cards` - Prepaid card information
- `wallets` - User wallet addresses per chain
- `transactions` - Transaction history
- `pathway_progress` - Educational progress tracking

## Security Considerations

1. **Private Keys**: Never stored on server - only MPC key shares
2. **API Security**: Rate limiting, request validation, HTTPS only
3. **Card Security**: One-time use QR codes with cryptographic signatures
4. **Wallet Recovery**: Multi-factor recovery without seed phrases
5. **Compliance**: Tiered KYC system for regulatory compliance

## Deployment

### Backend Deployment (Example with AWS)
```bash
# Build Docker image
docker build -t cypher-relay-api .

# Deploy to ECS/EKS
# Use provided terraform/kubernetes configs
```

### Mobile App Deployment
- iOS: Deploy through App Store Connect
- Android: Deploy through Google Play Console

### Smart Contract Deployment
- Use multi-sig wallet for admin functions
- Implement timelock for critical operations
- Conduct security audit before mainnet deployment

## Testing

### Backend Tests
```bash
cd backend
npm test              # Run all tests
npm run test:unit     # Unit tests only
npm run test:e2e      # End-to-end tests
```

### Smart Contract Tests
```bash
cd contracts
npm test              # Run all tests
npm run coverage      # Test coverage report
```

### Mobile App Tests
- iOS: Run tests in Xcode (⌘U)
- Android: Run tests in Android Studio

## Monitoring & Analytics

- Backend: Integrate with DataDog/New Relic
- Smart Contracts: Use Tenderly for monitoring
- Mobile: Firebase Analytics/Crashlytics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

Copyright (c) 2025 Cypher Relay. All rights reserved.

## Support

For support, email support@cypherrelay.com or join our Discord community.