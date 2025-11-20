# Web Application Helm Chart

This Helm chart deploys the DevOps sample web application to Kubernetes.

## Features

- **Deployment**: Kubernetes Deployment with 2 replicas by default
- **Service**: ClusterIP service for internal communication
- **Ingress**: Optional ingress with cert-manager support (disabled by default)
- **TLS**: Automatic SSL certificate management with Let's Encrypt (disabled by default)
- **Resources**: Configurable CPU/memory limits and requests
- **Health Checks**: Liveness and readiness probes

## Installation

### Basic Installation

```bash
helm install webapp ./helm/webapp --namespace web-app --create-namespace
```

### With Custom Values

```bash
helm install webapp ./helm/webapp \
  --namespace web-app \
  --set image.tag=v1.0.0 \
  --set replicaCount=3
```

## Configuration

### Ingress with SSL/TLS

To enable HTTPS with automatic SSL certificates:

1. **Install cert-manager**:
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

2. **Deploy with ingress enabled**:
```bash
helm upgrade webapp ./helm/webapp \
  --namespace web-app \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=yourdomain.com \
  --set certManager.enabled=true \
  --set certManager.clusterIssuer.email=your-email@example.com
```

### Values Reference

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `image.repository` | Docker image repository | `omaralaswar/devops-sample-app` |
| `image.tag` | Docker image tag | `latest` |
| `service.port` | Service port | `80` |
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `gce` |
| `certManager.enabled` | Enable cert-manager | `false` |
| `certManager.clusterIssuer.type` | Cluster issuer type | `letsencrypt-prod` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `64Mi` |

### Custom Values File

Create a `my-values.yaml`:

```yaml
ingress:
  enabled: true
  className: "gce"
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: myapp-tls
      hosts:
        - myapp.example.com

certManager:
  enabled: true
  clusterIssuer:
    name: "letsencrypt-prod"
    email: "admin@example.com"

resources:
  limits:
    cpu: 500m
    memory: 256Mi
  requests:
    cpu: 250m
    memory: 128Mi
```

Then install with:
```bash
helm install webapp ./helm/webapp -f my-values.yaml --namespace web-app
```

## Uninstallation

```bash
helm uninstall webapp --namespace web-app
```

## Application Endpoints

Once deployed:

- **Main App**: `/` - Returns greeting message
- **Health Check**: `/health` - Health status
- **Metrics**: `/metrics` - Prometheus metrics

## Monitoring

The application exposes Prometheus metrics on port 8080 at the `/metrics` endpoint.

Available metrics:
- `http_requests_total` - Total number of HTTP requests