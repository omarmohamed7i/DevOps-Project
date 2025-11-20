# CI/CD Pipeline - GitHub Actions

This project includes a comprehensive CI/CD pipeline using GitHub Actions to automate testing, building, and deployment.

## Pipeline Overview

```
┌─────────────┐    ┌─────────────┐    ┌────────────────┐    ┌─────────────┐    ┌─────────────┐
│    Test     │───▶│    Build    │───▶│   Monitoring   │───▶│  Deploy     │───▶│   Scan      │
│  (Node.js)  │    │   (Docker)  │    │ (Prom+Grafana) │    │   (GKE)     │    │ (Security)  │
└─────────────┘    └─────────────┘    └────────────────┘    └─────────────┘    └─────────────┘
```

## Pipeline Jobs

### 1. Test Job
**Trigger**: All pushes and pull requests
- **Node.js 18**: Setup with npm caching
- **Linting**: ESLint code quality checks
- **Tests**: Run `npm test`
- **Docker Build Test**: Verify Dockerfile syntax

### 2. Build Job
**Trigger**: Main branch pushes only
- **Docker Build**: Multi-stage build with Buildx
- **Push to Docker Hub**: Tagged with branch, SHA, and latest
- **Caching**: GitHub Actions cache for faster builds

### 3. Deploy Monitoring Stack Job
**Trigger**: Main branch pushes only
- **Monitoring Namespace**: Create dedicated monitoring namespace
- **Prometheus Deployment**: Deploy with custom alert rules
- **Grafana Deployment**: Deploy with pre-configured datasources
- **Health Verification**: Test monitoring stack accessibility
- **Parallel Execution**: Runs simultaneously with build job for efficiency

### 4. Deploy Application Job
**Trigger**: Main branch pushes only (depends on build + monitoring)
- **GKE Authentication**: Using service account
- **Helm Deployment**: Production configuration with autoscaling
- **Health Checks**: Verify deployment health and endpoints
- **Monitoring Integration**: Verify Prometheus metrics scraping
- **Rollback**: Automatic rollback on failure

### 5. Security Scan Job
**Trigger**: Main branch pushes only
- **Trivy Scanner**: Container vulnerability scanning
- **SARIF Export**: Upload results to GitHub Security tab

## Required GitHub Secrets

### 🔐 **Setup Required Secrets**

In your GitHub repository, go to **Settings > Secrets and variables > Actions** and add:

#### Docker Hub Secrets:
```
DOCKER_USERNAME=omaralaswar
DOCKER_PASSWORD=your_docker_access_token
```

#### GCP Secrets:
```
GCP_SA_KEY=your_gcp_service_account_key_json
GCP_PROJECT_ID=devops-candidate-1
GKE_CLUSTER_NAME=devops-gke
GKE_CLUSTER_ZONE=us-central1-a
```

#### Optional:
```
SLACK_WEBHOOK_URL=your_slack_webhook_url
```

## Branch Strategy

### 🌟 **Main Branch** (`main`)
- ✅ Full pipeline execution
- ✅ Docker image build and push
- ✅ Monitoring stack deployment (Prometheus + Grafana)
- ✅ Production deployment to GKE
- ✅ Monitoring integration verification
- ✅ Security scanning
- ✅ Image tagged as `latest`

### 🔧 **Development Branch** (`develop`)
- ✅ Testing only
- ❌ No deployment
- ❌ No Docker push (for cost efficiency)

### 🔄 **Pull Requests**
- ✅ Full testing pipeline
- ❌ No deployment
- ✅ Validation before merge

## Deployment Configuration

### Production Settings:
- **Replicas**: 3 pods
- **Autoscaling**: 2-10 pods, 70% CPU target
- **Resources**: Optimized for production
- **Rollback**: Automatic on failure
- **Health Checks**: 30 timeout, 10 retries

### Monitoring Stack Settings:
- **Prometheus**: 15-second scrape interval, 200-hour retention
- **Grafana**: Pre-configured datasources, admin/admin123 access
- **Alerts**: Error rate >10%, pod restarts, service downtime
- **Metrics**: Custom `http_requests_total` counter from web app
- **Namespace**: Dedicated `monitoring` namespace

### Staging Settings (if enabled):
- **Replicas**: 1 pod
- **Namespace**: `staging`
- **Subdomain**: `staging.webapp.local`

## Workflow Triggers

### Automatic Triggers:
- Push to `main` branch → Full pipeline
- Push to `develop` branch → Test only
- Pull request → Test only

### Manual Options:
- GitHub Actions UI allows manual workflow runs
- Environment-specific deployments with approval

## Monitoring and Logs

### Pipeline Status:
- **GitHub Actions Tab**: View workflow runs
- **Real-time Logs**: Each job logs in real-time
- **Artifact Storage**: Build logs and test results

### Deployment Monitoring:
- **GKE Dashboard**: Pod and service status
- **Prometheus**: Application metrics
- **Grafana**: Visualization dashboards

## Security Features

### 🛡️ **Container Security**
- **Trivy Scanner**: Vulnerability detection
- **Base Image Updates**: Regular Node.js Alpine updates
- **Non-root User**: Security context in containers

### 🔒 **Secrets Management**
- **Encrypted Secrets**: GitHub encrypted secrets
- **Least Privilege**: Minimal required permissions
- **No Hardcoded Values**: All sensitive data in secrets

## Cost Optimization

### 💰 **Resource Management**
- **On-demand Pods**: Scale down when not needed
- **Build Caching**: GitHub Actions cache
- **Smart Branching**: Limited Docker pushes
- **Storage Optimization**: Efficient Docker layers

## Troubleshooting

### Common Issues:

#### 1. **Docker Hub Push Fails**
```bash
# Check DOCKER_USERNAME and DOCKER_PASSWORD secrets
# Verify access token permissions
# Ensure Docker Hub repository exists
```

#### 2. **GKE Deployment Fails**
```bash
# Verify GCP_SA_KEY has required permissions
# Check cluster name and zone
# Ensure Helm charts are valid
```

#### 3. **Health Check Fails**
```bash
# Check pod logs: kubectl logs -n web-app deployment/webapp
# Verify service endpoints
# Check resource constraints
```

#### 4. **Security Scan Failures**
```bash
# Review Trivy scan results
# Update base images if needed
# Fix high-severity vulnerabilities
```

## Local Development

### 🧪 **Testing Pipeline Locally**

#### Install Required Tools:
```bash
# Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

#### Run Tests:
```bash
cd app
npm install
npm test
```

#### Build Docker:
```bash
docker build -t test-build ./app
```

#### Test Helm Chart:
```bash
helm template webapp ./helm/webapp --namespace web-app
```

## Performance Metrics

### 📊 **Pipeline Performance**
- **Test Job**: ~2 minutes
- **Build Job**: ~3 minutes
- **Deploy Job**: ~5 minutes
- **Security Scan**: ~2 minutes
- **Total Pipeline**: ~12 minutes

### 📈 **Success Metrics**
- **Uptime**: 99.9%+ SLA target
- **Deployment Time**: <5 minutes
- **Rollback Time**: <2 minutes
- **Test Coverage**: >80% target

## Environment Promotion

### 🔄 **Promotion Process**
1. **Develop → Main**: PR with tests
2. **Test Suite**: Automated validation
3. **Code Review**: Manual approval
4. **Merge**: Triggers deployment
5. **Health Check**: Automatic validation
6. **Monitoring**: Post-deployment checks

### 🚨 **Rollback Process**
- **Automatic**: Helm rollback on failure
- **Manual**: `helm rollback webapp 1 -n web-app`
- **Zero Downtime**: Rolling updates
- **Data Safety**: Database state preserved

---

**This CI/CD pipeline provides enterprise-grade automation with security, monitoring, and reliability built-in.** 🚀