# Monitoring Stack - Prometheus + Grafana

This directory contains the monitoring stack setup for the DevOps assessment project.

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Web App       │    │   Prometheus     │    │    Grafana      │
│ (Port 8080)     │───▶│ (Port 9090)      │───▶│ (Port 3000)     │
│  /metrics       │    │  Scrapes metrics │    │  Dashboards     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Components

### 1. Prometheus
- **Purpose**: Metrics collection and storage
- **Port**: 9090
- **Config**: `/prometheus/prometheus.yaml`
- **Scrapes**:
  - Web application (`/metrics` endpoint)
  - Kubernetes API Server
  - Node metrics
  - Pod metrics

### 2. Grafana
- **Purpose**: Visualization and dashboards
- **Port**: 3000
- **Config**: `/grafana/grafana.yaml`
- **Credentials**: `admin / admin123` (CHANGE IN PRODUCTION!)
- **Features**:
  - Pre-built web application dashboard
  - Prometheus datasource auto-configured
  - Alert management

## Deployment

### Quick Start
```bash
# Create namespace
kubectl create namespace monitoring

# Deploy Prometheus
kubectl apply -f prometheus/prometheus.yaml

# Deploy Grafana
kubectl apply -f grafana/grafana.yaml
```

### Access Services

#### Port Forwarding (Recommended for testing)
```bash
# Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000
```

#### Verify Services
```bash
# Check pods
kubectl get pods -n monitoring

# Check services
kubectl get svc -n monitoring

# Check logs
kubectl logs -n monitoring deployment/prometheus
kubectl logs -n monitoring deployment/grafana
```

## Metrics Available

### Web Application Metrics
- `http_requests_total` - Total HTTP requests (counter)
- Custom metrics can be added to `app/server.js`

### Kubernetes Metrics
- Container CPU usage
- Container memory usage
- Pod restarts
- Node metrics

### Prometheus Metrics
- Target scraping status
- Prometheus performance metrics

## Alerts

Prometheus is configured with alerting rules:

1. **WebAppHighErrorRate** - Error rate > 10%
2. **WebAppPodRestart** - Pod restarts detected
3. **WebAppDown** - Service unavailable for >1 minute

**Alert Configuration**: `/prometheus/prometheus.yaml` under `alert_rules.yml`

## Grafana Dashboard

### Pre-built Dashboard: "Web Application Dashboard"

Metrics included:
- HTTP request rate
- Error rate percentage
- Service uptime
- CPU usage
- Memory usage
- Response time (if histogram metrics added)

**Login**: `http://localhost:3000` (after port-forward)
**Username**: `admin`
**Password**: `admin123`

## Custom Metrics

To add custom metrics to the web application:

1. Update `app/server.js` with prom-client metrics
2. Expose metrics at `/metrics` endpoint
3. Update Prometheus scrape config if needed
4. Add to Grafana dashboard

Example additional metrics for `app/server.js`:
```javascript
const responseTime = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});
```

## Security Notes

⚠️ **PRODUCTION SECURITY CHANGES REQUIRED**:

1. **Grafana Password**: Change from default `admin123`
2. **Network Policies**: Restrict access between services
3. **RBAC**: Implement proper permissions
4. **TLS**: Enable HTTPS for Grafana/Prometheus
5. **Authentication**: Set up proper auth mechanisms

## Scaling

### High Availability
- Deploy Prometheus with remote storage
- Configure Grafana with persistent storage
- Set up alertmanager for notifications

### Performance
- Adjust `storage.tsdb.retention.time` in Prometheus
- Configure resource limits based on metrics volume
- Consider external metric storage for long-term data

## Troubleshooting

### Common Issues

1. **Prometheus not scraping targets**:
   ```bash
   kubectl logs -n monitoring deployment/prometheus
   # Check targets: http://localhost:9090/targets
   ```

2. **Grafana can't connect to Prometheus**:
   ```bash
   # Check datasources in Grafana UI
   # Verify Prometheus service: kubectl get svc -n monitoring
   ```

3. **High memory usage**:
   - Reduce retention period in Prometheus config
   - Adjust resource limits
   - Implement metric pruning

### Logs
```bash
# Prometheus logs
kubectl logs -n monitoring -l app=prometheus

# Grafana logs
kubectl logs -n monitoring -l app=grafana
```

## Clean Up
```bash
kubectl delete -f grafana/grafana.yaml
kubectl delete -f prometheus/prometheus.yaml
kubectl delete namespace monitoring
```