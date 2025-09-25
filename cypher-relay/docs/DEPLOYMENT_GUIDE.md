# Cypher Relay Deployment Guide

## Table of Contents
1. [Overview](#overview)
2. [Infrastructure Requirements](#infrastructure-requirements)
3. [Development Deployment](#development-deployment)
4. [Staging Deployment](#staging-deployment)
5. [Production Deployment](#production-deployment)
6. [Mobile App Deployment](#mobile-app-deployment)
7. [Monitoring & Maintenance](#monitoring--maintenance)
8. [Security Checklist](#security-checklist)

## Overview

This guide provides step-by-step instructions for deploying the Cypher Relay system across different environments. The deployment consists of:

- Smart contracts on multiple blockchains
- Backend API with PostgreSQL database
- iOS and Android mobile applications
- Infrastructure monitoring and security

## Infrastructure Requirements

### Minimum Requirements (Development)
- 1 server with 2 CPU cores, 4GB RAM
- PostgreSQL 14+
- Node.js 18+
- SSL certificate (Let's Encrypt)
- Domain name

### Recommended Requirements (Production)
- 3+ API servers (4 CPU, 8GB RAM each)
- Managed PostgreSQL with read replicas
- Redis cluster for caching
- CDN (CloudFlare/CloudFront)
- Load balancer with auto-scaling
- Container orchestration (ECS/Kubernetes)

## Development Deployment

### 1. Local Development Setup

```bash
# Clone the repository
git clone https://github.com/your-org/cypher-relay.git
cd cypher-relay

# Run the deployment script
./scripts/deploy.sh local
```

### 2. Deploy to Development Server

```bash
# SSH into your development server
ssh user@dev.cypherrelay.com

# Install dependencies
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs postgresql postgresql-contrib nginx

# Clone and setup
git clone https://github.com/your-org/cypher-relay.git
cd cypher-relay

# Setup environment variables
cp backend/.env.example backend/.env
nano backend/.env  # Configure your settings

# Install and build
cd backend
npm install
npm run build

# Setup database
sudo -u postgres createdb cypher_relay
npm run migrate

# Start with PM2
npm install -g pm2
pm2 start src/index.js --name cypher-relay-api
pm2 save
pm2 startup

# Configure Nginx
sudo nano /etc/nginx/sites-available/cypher-relay
```

Nginx configuration:
```nginx
server {
    listen 80;
    server_name dev-api.cypherrelay.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Enable site and SSL
sudo ln -s /etc/nginx/sites-available/cypher-relay /etc/nginx/sites-enabled/
sudo certbot --nginx -d dev-api.cypherrelay.com
sudo nginx -t
sudo systemctl restart nginx
```

## Staging Deployment

### 1. Using Docker Compose

Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:14-alpine
    environment:
      POSTGRES_DB: cypher_relay
      POSTGRES_USER: cypher_user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - cypher-network

  redis:
    image: redis:7-alpine
    networks:
      - cypher-network

  api:
    build: ./backend
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: staging
      DATABASE_URL: postgresql://cypher_user:${DB_PASSWORD}@postgres:5432/cypher_relay
      REDIS_URL: redis://redis:6379
    depends_on:
      - postgres
      - redis
    networks:
      - cypher-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - api
    networks:
      - cypher-network

volumes:
  postgres_data:

networks:
  cypher-network:
```

### 2. Deploy Smart Contracts to Testnets

```bash
cd contracts

# Deploy to Polygon Mumbai
npx hardhat run scripts/deploy.js --network polygonMumbai

# Deploy to Arbitrum Goerli
npx hardhat run scripts/deploy.js --network arbitrumGoerli

# Verify contracts
npx hardhat verify --network polygonMumbai <CONTRACT_ADDRESS>
```

## Production Deployment

### 1. AWS Infrastructure with Terraform

Create `terraform/main.tf`:
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "cypher-relay-terraform-state"
    key    = "production/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "cypher-relay-production"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier     = "cypher-relay-db"
  engine         = "postgres"
  engine_version = "14.7"
  instance_class = "db.r6g.large"
  
  allocated_storage     = 100
  max_allocated_storage = 1000
  storage_encrypted     = true
  
  db_name  = "cypher_relay"
  username = "cypher_admin"
  password = random_password.db_password.result
  
  backup_retention_period = 30
  deletion_protection     = true
  
  tags = {
    Name        = "cypher-relay-db"
    Environment = "production"
  }
}
```

### 2. Kubernetes Deployment

Create `k8s/deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cypher-relay-api
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: cypher-relay-api
  template:
    metadata:
      labels:
        app: cypher-relay-api
    spec:
      containers:
      - name: api
        image: cypherrelay/api:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: cypher-relay-secrets
              key: database-url
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: cypher-relay-api
  namespace: production
spec:
  selector:
    app: cypher-relay-api
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: cypher-relay-api-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: cypher-relay-api
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### 3. Deploy Smart Contracts to Mainnet

```bash
# CRITICAL: Ensure you have audited contracts before mainnet deployment!

cd contracts

# Deploy to Polygon Mainnet
npx hardhat run scripts/deploy.js --network polygon

# Deploy to Arbitrum One
npx hardhat run scripts/deploy.js --network arbitrum

# Verify contracts
npx hardhat verify --network polygon <CONTRACT_ADDRESS>

# Transfer ownership to multisig
npx hardhat run scripts/transferOwnership.js --network polygon
```

## Mobile App Deployment

### iOS Deployment

1. **Prepare for App Store**
```bash
cd mobile/ios/RelayVault

# Update version and build number
agvtool new-marketing-version 1.0.0
agvtool next-version -all

# Archive the app
xcodebuild -workspace RelayVault.xcworkspace \
  -scheme RelayVault \
  -configuration Release \
  -archivePath build/RelayVault.xcarchive \
  archive

# Export for App Store
xcodebuild -exportArchive \
  -archivePath build/RelayVault.xcarchive \
  -exportPath build \
  -exportOptionsPlist ExportOptions.plist
```

2. **Upload to App Store Connect**
```bash
# Using Transporter
xcrun altool --upload-app \
  -f build/RelayVault.ipa \
  -u your-apple-id@email.com \
  -p @keychain:APP_SPECIFIC_PASSWORD
```

### Android Deployment

1. **Build Release APK**
```bash
cd mobile/android/RelayVault

# Generate signed APK
./gradlew assembleRelease

# Or generate App Bundle
./gradlew bundleRelease
```

2. **Upload to Google Play**
```bash
# Using fastlane
fastlane supply --aab app/build/outputs/bundle/release/app-release.aab
```

## Monitoring & Maintenance

### 1. Setup Monitoring Stack

```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    volumes:
      - grafana_data:/var/lib/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}

  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - ./loki-config.yaml:/etc/loki/local-config.yaml

  promtail:
    image: grafana/promtail:latest
    volumes:
      - /var/log:/var/log
      - ./promtail-config.yaml:/etc/promtail/config.yml

volumes:
  prometheus_data:
  grafana_data:
```

### 2. Setup Alerts

Create `alerts.yml`:
```yaml
groups:
  - name: cypher-relay
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: High error rate detected
          
      - alert: DatabaseConnectionFailure
        expr: pg_up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: Database connection lost
          
      - alert: LowDiskSpace
        expr: node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"} < 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: Low disk space on server
```

## Security Checklist

### Pre-Deployment
- [ ] Smart contracts audited by reputable firm
- [ ] Penetration testing completed
- [ ] All dependencies updated and scanned
- [ ] Environment variables secured in vault
- [ ] Database backups configured and tested
- [ ] SSL/TLS certificates valid
- [ ] Rate limiting configured
- [ ] DDoS protection enabled

### Infrastructure Security
- [ ] Firewalls configured (only required ports open)
- [ ] VPC and security groups properly configured
- [ ] Secrets management (AWS Secrets Manager/Vault)
- [ ] Database encryption at rest and in transit
- [ ] API keys rotated regularly
- [ ] Multi-factor authentication for all admin access

### Monitoring
- [ ] Application performance monitoring (APM)
- [ ] Error tracking (Sentry/Rollbar)
- [ ] Security monitoring (WAF logs)
- [ ] Blockchain monitoring (Tenderly)
- [ ] Uptime monitoring (StatusPage)
- [ ] Alert escalation configured

### Disaster Recovery
- [ ] Automated backups running
- [ ] Backup restoration tested
- [ ] Runbook documented
- [ ] On-call rotation established
- [ ] Incident response plan created

## Post-Deployment Steps

1. **Verify all systems**
```bash
# Check API health
curl https://api.cypherrelay.com/health

# Verify smart contracts
npx hardhat verify-deployment --network polygon

# Test card redemption flow
npm run test:e2e
```

2. **Monitor initial metrics**
- Response times
- Error rates
- Database performance
- Blockchain gas usage

3. **Gradual rollout**
- Start with 10% of traffic
- Monitor for 24 hours
- Increase to 50%, then 100%

4. **Documentation**
- Update API documentation
- Record deployment versions
- Update runbooks

## Support

For deployment support:
- Email: devops@cypherrelay.com
- Slack: #deployment-support
- On-call: +1-XXX-XXX-XXXX