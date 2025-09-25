# Cypher Relay Quick Deploy Guide - Managed Cloud

This guide will help you deploy Cypher Relay to production in under 3 hours using managed services.

## 🚀 Services We'll Use

- **Backend API**: Render.com or Railway
- **Database**: Supabase (PostgreSQL)
- **Redis**: Upstash (Serverless Redis)
- **Smart Contracts**: Polygon & Arbitrum Testnets → Mainnet
- **File Storage**: Cloudinary or S3
- **Monitoring**: Sentry + Render metrics

Total Cost: ~$200-500/month

## 📋 Pre-Deployment Checklist

- [ ] GitHub repository ready
- [ ] Domain name purchased (optional for start)
- [ ] Testnet ETH/MATIC for contract deployment
- [ ] Credit card for service signups

---

## Step 1: Database Setup (Supabase) - 15 minutes

### 1.1 Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign in with GitHub
4. Create new project:
   - Project name: `cypher-relay-prod`
   - Database Password: (save this securely!)
   - Region: Choose closest to your users
   - Plan: Free tier to start

### 1.2 Get Connection String

1. Go to Settings → Database
2. Copy the "Connection string" - URI format
3. It looks like: `postgresql://postgres:[password]@[host]:5432/postgres`

### 1.3 Run Database Migrations

```bash
cd backend

# Install dependencies first
npm install

# Set the database URL
export DATABASE_URL="your-supabase-connection-string"

# Create tables
npm run migrate
```

---

## Step 2: Redis Setup (Upstash) - 10 minutes

### 2.1 Create Upstash Account

1. Go to [https://upstash.com](https://upstash.com)
2. Sign up (free tier available)
3. Create new Redis database:
   - Name: `cypher-relay-cache`
   - Region: Same as Supabase
   - Enable Eviction

### 2.2 Get Redis Credentials

1. Copy the "Redis URL" (starts with `rediss://`)
2. Save for backend configuration

---

## Step 3: Deploy Smart Contracts - 30 minutes

### 3.1 Testnet Deployment First

```bash
cd contracts

# Install dependencies
npm install

# Create .env file
cat > .env << EOL
PRIVATE_KEY=your-deployer-wallet-private-key
POLYGON_MUMBAI_RPC_URL=https://rpc-mumbai.maticvigil.com
ARBITRUM_GOERLI_RPC_URL=https://goerli-rollup.arbitrum.io/rpc
POLYGONSCAN_API_KEY=your-polygonscan-api-key
ARBISCAN_API_KEY=your-arbiscan-api-key
EOL

# Deploy to testnets
npm run deploy:polygon-mumbai
npm run deploy:arbitrum-goerli

# Save the deployed addresses!
```

### 3.2 Verify Contracts

```bash
# Verify on Polygonscan
npx hardhat verify --network polygonMumbai YOUR_TOKEN_ADDRESS
npx hardhat verify --network polygonMumbai YOUR_REDEMPTION_ADDRESS
```

---

## Step 4: Backend Deployment (Render) - 30 minutes

### 4.1 Prepare for Deployment

1. Create `render.yaml` in backend directory:

```yaml
services:
  - type: web
    name: cypher-relay-api
    env: node
    region: oregon
    plan: starter
    buildCommand: npm install
    startCommand: node src/index.js
    envVars:
      - key: NODE_ENV
        value: production
      - key: PORT
        value: 3000
      - key: DATABASE_URL
        sync: false
      - key: REDIS_URL
        sync: false
      - key: JWT_SECRET
        generateValue: true
      - key: ENCRYPTION_KEY
        generateValue: true
```

### 4.2 Deploy to Render

1. Go to [https://render.com](https://render.com)
2. Sign up/Login with GitHub
3. Click "New +" → "Web Service"
4. Connect your GitHub repo
5. Configure:
   - Name: `cypher-relay-api`
   - Region: Oregon (or closest)
   - Branch: `main`
   - Build Command: `cd backend && npm install`
   - Start Command: `cd backend && node src/index.js`
   - Plan: Starter ($7/month)

### 4.3 Add Environment Variables

In Render dashboard, add these environment variables:

```env
NODE_ENV=production
PORT=3000

# From Supabase
DATABASE_URL=postgresql://...

# From Upstash
REDIS_URL=rediss://...

# Generated
JWT_SECRET=<click-generate>
ENCRYPTION_KEY=<click-generate>

# Blockchain
POLYGON_RPC_URL=https://polygon-rpc.com
ARBITRUM_RPC_URL=https://arb1.arbitrum.io/rpc

# Your deployed contracts (from step 3)
CYRD_TOKEN_POLYGON=0x...
CYRD_TOKEN_ARBITRUM=0x...
REDEMPTION_CONTRACT_POLYGON=0x...
REDEMPTION_CONTRACT_ARBITRUM=0x...

# Backend wallet (create new wallet for this)
BACKEND_PRIVATE_KEY=0x...
```

Click "Save Changes" and Render will automatically deploy!

---

## Step 5: Setup Monitoring (Sentry) - 15 minutes

### 5.1 Create Sentry Account

1. Go to [https://sentry.io](https://sentry.io)
2. Sign up (free tier includes 5k errors/month)
3. Create new project:
   - Platform: Node.js
   - Project name: `cypher-relay-api`

### 5.2 Add to Backend

```bash
cd backend
npm install @sentry/node
```

Add to `src/index.js`:
```javascript
const Sentry = require('@sentry/node');

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
});
```

### 5.3 Add Sentry DSN to Render

Add to environment variables:
```env
SENTRY_DSN=https://...@sentry.io/...
```

---

## Step 6: Test Your Deployment - 20 minutes

### 6.1 Test API Health

```bash
# Your Render URL will be something like:
# https://cypher-relay-api.onrender.com

curl https://your-api-url.onrender.com/health
```

### 6.2 Generate Test Cards

```bash
# SSH into Render console or run locally with production DB
cd backend
node scripts/generateCards.js --count 5 --value 25 --chain polygon
```

### 6.3 Test Card Redemption

Use the generated QR codes to test the full redemption flow.

---

## Step 7: Domain Setup (Optional) - 20 minutes

### 7.1 Add Custom Domain to Render

1. In Render dashboard → Settings → Custom Domain
2. Add `api.cypherrelay.com`
3. Add CNAME record in your DNS:
   ```
   api.cypherrelay.com → cypher-relay-api.onrender.com
   ```

### 7.2 Enable Auto-SSL

Render automatically provisions SSL certificates for custom domains.

---

## Step 8: Mobile App Configuration

### 8.1 Update API Endpoints

In your iOS app, update `APIService.swift`:
```swift
private let baseURL = "https://cypher-relay-api.onrender.com"
// or your custom domain
```

In your Android app, update `APIService.kt`:
```kotlin
private const val BASE_URL = "https://cypher-relay-api.onrender.com"
```

### 8.2 Build and Deploy Apps

**iOS:**
```bash
cd mobile/ios/RelayVault
# Update Info.plist with production values
# Archive and upload to App Store Connect
```

**Android:**
```bash
cd mobile/android/RelayVault
# Update build.gradle with production API
./gradlew bundleRelease
# Upload to Google Play Console
```

---

## 🎉 You're Live!

Your backend is now deployed and ready to handle production traffic. Render will automatically:
- Handle SSL certificates
- Auto-scale based on load
- Restart on crashes
- Provide basic metrics

## 📊 Next Steps

### Immediate (Day 1):
- [ ] Monitor Sentry for any errors
- [ ] Watch Render metrics dashboard
- [ ] Test with real devices
- [ ] Set up status page

### Week 1:
- [ ] Add Cloudflare in front of API
- [ ] Set up database backups
- [ ] Configure rate limiting
- [ ] Add API documentation

### Month 1:
- [ ] Analyze usage patterns
- [ ] Optimize slow queries
- [ ] Consider upgrading Render plan
- [ ] Plan for mainnet deployment

---

## 🚨 Production Checklist

Before accepting real money:
- [ ] Smart contract audit completed
- [ ] Multi-sig wallet configured
- [ ] Terms of Service added
- [ ] Privacy Policy added
- [ ] Support email configured
- [ ] Mainnet contracts deployed
- [ ] KYC provider integrated (if needed)

---

## 💡 Cost Optimization Tips

1. **Start with free tiers:**
   - Supabase: 500MB free
   - Upstash: 10k commands/day free
   - Render: Can start at $7/month

2. **Scale when needed:**
   - Upgrade Render when response times > 500ms
   - Add read replicas when DB CPU > 80%
   - Enable caching when hitting rate limits

3. **Monitor costs:**
   - Set up billing alerts
   - Review usage weekly
   - Optimize before scaling up

---

## 🆘 Troubleshooting

### API returns 500 errors
1. Check Render logs
2. Verify DATABASE_URL is correct
3. Check Sentry for detailed errors

### Slow response times
1. Check Render metrics
2. Add database indexes
3. Enable Redis caching

### Contract calls failing
1. Verify contract addresses in env vars
2. Check backend wallet has ETH/MATIC
3. Verify RPC URLs are working

---

## 📞 Support Resources

- Render Docs: https://render.com/docs
- Supabase Docs: https://supabase.com/docs
- Upstash Docs: https://docs.upstash.com
- Your Discord: [Add your support channel]

---

## 🎯 Success Metrics

You'll know deployment is successful when:
- ✅ Health check returns 200 OK
- ✅ Can redeem test card
- ✅ Response times < 200ms
- ✅ No errors in Sentry
- ✅ Database connections stable

Congratulations! You've deployed Cypher Relay! 🚀