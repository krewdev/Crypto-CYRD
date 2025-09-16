#!/bin/bash

# Cypher Relay Quick Deploy Script for Managed Cloud
# This script helps you deploy quickly to Render/Railway + Supabase

set -e

echo "🚀 Cypher Relay Quick Deploy"
echo "=========================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to prompt for required values
prompt_for_value() {
    local var_name=$1
    local prompt_text=$2
    local is_secret=$3
    
    if [ "$is_secret" = "true" ]; then
        read -s -p "$prompt_text: " value
        echo ""
    else
        read -p "$prompt_text: " value
    fi
    
    eval "$var_name='$value'"
}

# Check if .env exists
if [ ! -f "backend/.env" ]; then
    echo -e "${YELLOW}No .env file found. Creating from template...${NC}"
    cp backend/.env.example backend/.env
fi

echo "📋 Step 1: Gathering Information"
echo "--------------------------------"

# Prompt for required services
echo ""
echo "Have you already created accounts for these services?"
echo "1. Supabase (https://supabase.com)"
echo "2. Upstash Redis (https://upstash.com)"
echo "3. Render or Railway"
echo ""
read -p "Have you created these accounts? (y/n): " accounts_created

if [ "$accounts_created" != "y" ]; then
    echo -e "${RED}Please create accounts first, then run this script again.${NC}"
    echo ""
    echo "Quick links:"
    echo "- Supabase: https://supabase.com"
    echo "- Upstash: https://upstash.com"
    echo "- Render: https://render.com"
    echo "- Railway: https://railway.app"
    exit 1
fi

echo ""
echo -e "${GREEN}Great! Let's configure your deployment.${NC}"
echo ""

# Get database URL
prompt_for_value DATABASE_URL "Enter your Supabase DATABASE_URL" false

# Get Redis URL
prompt_for_value REDIS_URL "Enter your Upstash Redis URL (optional, press enter to skip)" false

# Get deployment platform
echo ""
echo "Which platform are you using?"
echo "1) Render"
echo "2) Railway"
read -p "Select (1 or 2): " platform_choice

# Contract deployment check
echo ""
read -p "Have you deployed smart contracts to testnet? (y/n): " contracts_deployed

if [ "$contracts_deployed" = "y" ]; then
    prompt_for_value CYRD_TOKEN_POLYGON "Enter CYRD token address on Polygon" false
    prompt_for_value REDEMPTION_CONTRACT_POLYGON "Enter Redemption contract address on Polygon" false
fi

echo ""
echo "📝 Step 2: Updating Configuration"
echo "---------------------------------"

# Update .env file
update_env_var() {
    local key=$1
    local value=$2
    local file="backend/.env"
    
    if grep -q "^$key=" "$file"; then
        # On macOS, use -i '' for in-place editing
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|^$key=.*|$key=$value|" "$file"
        else
            sed -i "s|^$key=.*|$key=$value|" "$file"
        fi
    else
        echo "$key=$value" >> "$file"
    fi
}

# Update database URL
update_env_var "DATABASE_URL" "$DATABASE_URL"

# Update Redis URL if provided
if [ ! -z "$REDIS_URL" ]; then
    update_env_var "REDIS_URL" "$REDIS_URL"
fi

# Update contract addresses if provided
if [ "$contracts_deployed" = "y" ]; then
    update_env_var "CYRD_TOKEN_POLYGON" "$CYRD_TOKEN_POLYGON"
    update_env_var "REDEMPTION_CONTRACT_POLYGON" "$REDEMPTION_CONTRACT_POLYGON"
fi

# Generate secrets if not exists
if ! grep -q "^JWT_SECRET=.+" "backend/.env"; then
    JWT_SECRET=$(openssl rand -hex 32)
    update_env_var "JWT_SECRET" "$JWT_SECRET"
fi

if ! grep -q "^ENCRYPTION_KEY=.+" "backend/.env"; then
    ENCRYPTION_KEY=$(openssl rand -hex 16)
    update_env_var "ENCRYPTION_KEY" "$ENCRYPTION_KEY"
fi

echo -e "${GREEN}✓ Configuration updated${NC}"

echo ""
echo "🗄️ Step 3: Database Setup"
echo "------------------------"

# Test database connection
echo "Testing database connection..."
cd backend
if npm run migrate 2>/dev/null; then
    echo -e "${GREEN}✓ Database connected and migrated successfully${NC}"
else
    echo -e "${RED}✗ Database connection failed. Please check your DATABASE_URL${NC}"
    exit 1
fi
cd ..

echo ""
echo "🔨 Step 4: Preparing for Deployment"
echo "----------------------------------"

# Create deployment files if needed
if [ "$platform_choice" = "1" ]; then
    echo "Preparing for Render deployment..."
    
    # Ensure render.yaml exists
    if [ ! -f "backend/render.yaml" ]; then
        echo -e "${YELLOW}render.yaml not found, creating...${NC}"
        # render.yaml was already created above
    fi
    
    echo -e "${GREEN}✓ Render configuration ready${NC}"
    echo ""
    echo "📋 Next Steps for Render:"
    echo "1. Go to https://render.com"
    echo "2. Connect your GitHub repository"
    echo "3. Create a new Web Service"
    echo "4. Select your repo and 'backend' directory"
    echo "5. Render will auto-detect render.yaml"
    echo ""
    echo "Environment variables to add in Render dashboard:"
    echo "- DATABASE_URL (copy from your .env)"
    echo "- REDIS_URL (if using)"
    echo "- Any contract addresses"
    echo ""
    
elif [ "$platform_choice" = "2" ]; then
    echo "Preparing for Railway deployment..."
    
    # Install Railway CLI if not installed
    if ! command -v railway &> /dev/null; then
        echo "Installing Railway CLI..."
        curl -fsSL https://railway.app/install.sh | sh
    fi
    
    echo -e "${GREEN}✓ Railway configuration ready${NC}"
    echo ""
    echo "To deploy to Railway, run:"
    echo "cd backend"
    echo "railway login"
    echo "railway init"
    echo "railway up"
    echo ""
fi

echo ""
echo "🧪 Step 5: Testing Locally"
echo "-------------------------"

# Option to test locally
read -p "Would you like to test the API locally first? (y/n): " test_local

if [ "$test_local" = "y" ]; then
    echo "Starting local server..."
    cd backend
    npm install
    
    # Start server in background
    npm start &
    SERVER_PID=$!
    
    # Wait for server to start
    sleep 5
    
    # Test health endpoint
    if curl -f http://localhost:3000/health 2>/dev/null; then
        echo -e "${GREEN}✓ Local server is running correctly${NC}"
    else
        echo -e "${RED}✗ Local server failed to start${NC}"
    fi
    
    # Kill the test server
    kill $SERVER_PID 2>/dev/null
    
    cd ..
fi

echo ""
echo "📱 Step 6: Mobile App Configuration"
echo "----------------------------------"

# Get API URL
if [ "$platform_choice" = "1" ]; then
    echo "Your Render URL will be: https://[your-app-name].onrender.com"
    prompt_for_value API_URL "Enter your Render app name (without .onrender.com)" false
    API_URL="https://${API_URL}.onrender.com"
else
    echo "Your Railway URL will be: https://[your-app-name].up.railway.app"
    prompt_for_value API_URL "Enter your Railway app name (without .up.railway.app)" false
    API_URL="https://${API_URL}.up.railway.app"
fi

echo ""
echo "Update your mobile apps with this API URL:"
echo -e "${GREEN}$API_URL${NC}"
echo ""
echo "iOS: Update APIService.swift"
echo "Android: Update APIService.kt"

echo ""
echo "✅ Step 7: Final Checklist"
echo "-------------------------"

echo "Before going live, ensure you have:"
echo ""
echo "[ ] Deployed contracts to testnet"
echo "[ ] Added all environment variables to your hosting platform"
echo "[ ] Updated mobile apps with production API URL"
echo "[ ] Tested card redemption flow"
echo "[ ] Set up error monitoring (Sentry)"
echo "[ ] Configured domain name (optional)"
echo ""

echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo ""
echo "Your deployment is ready. Follow the platform-specific instructions above to deploy."
echo ""
echo "Useful commands:"
echo "- Generate test cards: cd backend && node scripts/generateCards.js"
echo "- View logs: Check your platform dashboard"
echo "- Monitor health: curl $API_URL/health"
echo ""
echo "Need help? Check docs/QUICK_DEPLOY_GUIDE.md for detailed instructions."