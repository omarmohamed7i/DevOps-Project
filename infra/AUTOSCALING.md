# 🚀 Kubernetes Autoscaling Configuration

This document explains the autoscaling capabilities built into the DevOps assessment infrastructure.

## Types of Autoscaling

### 1. **Cluster Node Autoscaling** (Worker Node Scaling)

Automatically adds or removes worker nodes based on pod resource requirements.

#### Configuration
```hcl
# terraform.tfvars
enable_autoscaling = true
min_node_count    = 1
max_node_count    = 5
node_count        = 2  # Initial size
```

#### How it Works
- **Scale Up**: When pods can't be scheduled due to insufficient resources
- **Scale Down**: When nodes are underutilized for a sustained period
- **Cooldown Period**: 10-15 minutes between scaling operations

#### Enable Autoscaling
```bash
# Apply with autoscaling enabled
terraform apply -var="enable_autoscaling=true" -var="min_node_count=1" -var="max_node_count=5"
```

#### Monitor Autoscaling
```bash
# Check autoscaler logs
kubectl logs -n kube-system -l k8s-app=cluster-autoscaler

# Check node pool status
gcloud container node-pools describe devops-gke-pool --zone=us-central1-a

# View autoscaling events
kubectl get events --field-selector reason=FailedScheduling
```

### 2. **Horizontal Pod Autoscaling (HPA)** (Pod Scaling)

Automatically scales the number of PostgreSQL replicas based on CPU and memory usage.

#### Configuration
```yaml
# HPA Metrics
- CPU: 70% utilization target
- Memory: 80% utilization target
- Min Replicas: 1
- Max Replicas: 3
```

#### Enable HPA
```bash
# Apply HPA configuration
terraform apply

# Verify HPA status
kubectl get hpa -n db

# Check current metrics
kubectl top pods -n db
```

#### HPA Commands
```bash
# View HPA details
kubectl describe hpa postgres-hpa -n db

# View resource usage
kubectl top nodes
kubectl top pods -n db

# Simulate load (for testing)
kubectl run stress-test --image=polinux/stress --rm -it -- /bin/bash -c "stress --cpu 1 --timeout 30s"
```

### 3. **Manual Scaling Operations**

#### Scale Nodes Manually
```bash
# Update node count
terraform apply -var="node_count=3"

# Or using gcloud directly
gcloud container clusters resize devops-gke --zone=us-central1-a --node-pool=devops-gke-pool --num-nodes=3
```

#### Scale Pods Manually
```bash
# Scale PostgreSQL replicas
kubectl scale statefulset postgres --replicas=3 -n db

# Check replica status
kubectl get pods -n db -w
```

## Autoscaling Scenarios

### 📈 **Scale-Up Triggers**
1. **High CPU/Memory**: Average utilization exceeds thresholds
2. **Pending Pods**: New pods can't be scheduled due to resource constraints
3. **Increased Load**: Sudden traffic spikes requiring more capacity

### 📉 **Scale-Down Triggers**
1. **Low Utilization**: Nodes under 50% utilization for 10+ minutes
2. **Reduced Load**: Applications need fewer resources
3. **Cost Optimization**: Scale down during off-peak hours

## Best Practices

### ✅ **Recommended Settings**
```hcl
# For production workloads
min_node_count = 2          # High availability
max_node_count = 10         # Controlled scaling
enable_autoscaling = true   # Cost efficiency
```

### ⚠️ **Important Considerations**
- **PostgreSQL**: StatefulSet scaling is complex - ensure proper volume management
- **Cost Control**: Set appropriate max_node_count to prevent cost overruns
- **Monitoring**: Use Cloud Monitoring to track autoscaling events
- **Testing**: Test autoscaling in staging before production deployment

### 🔧 **Monitoring Autoscaling**
```bash
# Install metrics server (if needed)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Check metrics server
kubectl get pods -n kube-system -l k8s-app=metrics-server

# Monitor HPA metrics
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/namespaces/db/pods" | jq .
```

## Cost Estimation

### 💰 **Node Autoscaling Costs**
- **Minimum**: 2 × e2-medium = ~$52/month
- **Maximum**: 5 × e2-medium = ~$130/month
- **Average**: 3 × e2-medium = ~$78/month

### 💡 **Cost Optimization Tips**
1. Use `e2-standard-2` for better performance per dollar
2. Enable cluster autoscaling only when needed
3. Set conservative max_node_count limits
4. Monitor utilization regularly

## Testing Autoscaling

### 🧪 **Load Testing**
```bash
# Deploy a test application
kubectl create namespace test
kubectl run load-test --image=nginx --replicas=10 -n test

# Watch HPA scale events
kubectl get hpa -w -n db

# Clean up test
kubectl delete namespace test
```

### 📊 **Performance Testing**
```bash
# Generate CPU load
kubectl run cpu-stress --image=polinux/stress --rm -it -- \
  stress --cpu 2 --timeout 60s

# Generate memory load
kubectl run memory-stress --image=polinux/stress --rm -it -- \
  stress --vm 2 --vm-bytes 256M --timeout 60s
```

## Troubleshooting

### 🔍 **Common Issues**

#### Autoscaling Not Working
```bash
# Check autoscaler is running
kubectl get pods -n kube-system -l k8s-app=cluster-autoscaler

# Check node pool configuration
gcloud container node-pools describe devops-gke-pool --zone=us-central1-a

# Check for scheduling conflicts
kubectl get events --field-selector reason=FailedScheduling
```

#### HPA Not Scaling
```bash
# Check metrics server
kubectl get deployment metrics-server -n kube-system

# Check resource requests/limits
kubectl describe statefulset postgres -n db

# Check current metrics
kubectl top pod postgres-0 -n db
```

### 📋 **Helpful Commands**
```bash
# Full cluster status
kubectl cluster-info

# Node resource usage
kubectl top nodes

# Pod resource usage
kubectl top pods --all-namespaces

# Autoscaling events
kubectl get events --sort-by='.lastTimestamp' | grep -i scale
```

---

**Note**: Autoscaling provides cost-effective scaling but requires proper monitoring and testing for production workloads.