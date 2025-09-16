#!/bin/bash

# Cypher Relay Deployment Script
# This script helps deploy the entire Cypher Relay infrastructure

set -e

echo "🚀 Cypher Relay Deployment Script"
echo "================================="

# Check environment
if [ -z "$1" ]; then
    echo "Usage: ./deploy.sh <environment>"
    echo "Environments: local, testnet, mainnet"
    exit 1
fi

ENVIRONMENT=$1

# Function to check prerequisites
check_prerequisites() {
    echo "📋 Checking prerequisites..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js is not installed"
        exit 1
    fi
    
    # Check PostgreSQL
    if ! command -v psql &> /dev/null; then
        echo "❌ PostgreSQL is not installed"
        exit 1
    fi
    
    # Check environment files
    if [ ! -f "backend/.env" ]; then
        echo "❌ Backend .env file not found"
        echo "   Please copy backend/.env.example to backend/.env and configure"
        exit 1
    fi
    
    if [ ! -f "contracts/.env" ]; then
        echo "❌ Contracts .env file not found"
        echo "   Please copy contracts/.env.example to contracts/.env and configure"
        exit 1
    fi
    
    echo "✅ All prerequisites met"
}

# Function to deploy smart contracts
deploy_contracts() {
    echo "📜 Deploying smart contracts..."
    cd contracts
    npm install
    
    if [ "$ENVIRONMENT" = "local" ]; then
        echo "Starting local Hardhat node..."
        npx hardhat node &
        HARDHAT_PID=$!
        sleep 5
        
        echo "Deploying to local network..."
        npm run deploy:local
        
        echo "Local deployment complete. Hardhat node PID: $HARDHAT_PID"
    elif [ "$ENVIRONMENT" = "testnet" ]; then
        echo "Deploying to testnets..."
        npm run deploy:polygon-mumbai
        npm run deploy:arbitrum-goerli
    elif [ "$ENVIRONMENT" = "mainnet" ]; then
        echo "⚠️  WARNING: About to deploy to mainnet!"
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            npm run deploy:polygon
            npm run deploy:arbitrum
        else
            echo "Mainnet deployment cancelled"
            exit 0
        fi
    fi
    
    cd ..
    echo "✅ Smart contracts deployed"
}

# Function to setup database
setup_database() {
    echo "🗄️  Setting up database..."
    cd backend
    
    # Create database if it doesn't exist
    createdb cypher_relay 2>/dev/null || echo "Database already exists"
    
    # Run migrations
    npm run migrate
    
    cd ..
    echo "✅ Database setup complete"
}

# Function to start backend
start_backend() {
    echo "🖥️  Starting backend server..."
    cd backend
    npm install
    
    if [ "$ENVIRONMENT" = "local" ]; then
        npm run dev &
        BACKEND_PID=$!
        echo "Backend running on http://localhost:3000 (PID: $BACKEND_PID)"
    else
        echo "For production deployment, use PM2 or similar process manager:"
        echo "  pm2 start src/index.js --name cypher-relay-api"
    fi
    
    cd ..
}

# Function to build mobile apps
build_mobile_apps() {
    echo "📱 Building mobile apps..."
    
    # iOS
    echo "Building iOS app..."
    cd mobile/ios/RelayVault
    if command -v xcodebuild &> /dev/null; then
        swift package resolve
        echo "iOS dependencies installed. Open in Xcode to build."
    else
        echo "Xcode not found. Please build iOS app manually."
    fi
    cd ../../..
    
    # Android
    echo "Building Android app..."
    cd mobile/android/RelayVault
    if command -v gradle &> /dev/null; then
        ./gradlew assembleDebug
        echo "Android APK built: app/build/outputs/apk/debug/"
    else
        echo "Gradle not found. Please build Android app manually."
    fi
    cd ../../..
}

# Function to generate test cards
generate_test_cards() {
    if [ "$ENVIRONMENT" = "local" ]; then
        echo "🎫 Generating test cards..."
        cd backend
        node scripts/generateCards.js --count 10 --value 25
        cd ..
        echo "✅ Test cards generated"
    fi
}

# Main deployment flow
main() {
    check_prerequisites
    
    echo ""
    echo "🚀 Starting deployment for environment: $ENVIRONMENT"
    echo ""
    
    deploy_contracts
    setup_database
    start_backend
    
    if [ "$ENVIRONMENT" = "local" ]; then
        generate_test_cards
    fi
    
    echo ""
    echo "🎉 Deployment complete!"
    echo ""
    echo "Next steps:"
    echo "1. Update backend .env with deployed contract addresses"
    echo "2. Build and deploy mobile apps"
    echo "3. Configure API endpoints in mobile apps"
    echo "4. Set up monitoring and logging"
    echo ""
    
    if [ "$ENVIRONMENT" = "local" ]; then
        echo "Local services running:"
        echo "- Hardhat node: PID $HARDHAT_PID"
        echo "- Backend API: PID $BACKEND_PID (http://localhost:3000)"
        echo ""
        echo "To stop services:"
        echo "  kill $HARDHAT_PID $BACKEND_PID"
    fi
}

# Run main function
main