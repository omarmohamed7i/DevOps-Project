# DevOps Assessment Infrastructure

This Terraform configuration provisions a complete GCP infrastructure stack for the DevOps technical assessment, including a GKE cluster, PostgreSQL database, and storage bucket.

## Module Structure

```
infra/
├── main.tf                    # Root module orchestration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── backend.tf                 # Remote state configuration
├── providers.tf               # Provider configuration
├── terraform.tfvars.example   # Example variables
├── terraform.tfvars.autoscaling # Autoscaling configuration
└── modules/
    ├── gke/                   # GKE cluster module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── db/                    # PostgreSQL database module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Features

### ✅ **Core Requirements Met**
- ✅ GKE Kubernetes cluster with configurable nodes
- ✅ PostgreSQL database as Kubernetes workload (not managed service)
- ✅ GCS storage bucket for static files and logs
- ✅ Modular Terraform structure with reusable modules
- ✅ Remote state backend configuration
- ✅ Variable configuration with sensitive data handling

### 🏗️ **Infrastructure Components**

#### GKE Cluster (`modules/gke/`)
- **Version**: 1.31.13-gke.1377000 (pinned for stability)
- **Networking**: Custom VPC with separate subnets for pods and services
- **Node Pool**: Configurable machine type and count (exactly 2 nodes)
- **Security**: Private cluster with no public IPs on worker nodes
- **Deployment**: Zonal deployment (us-central1-a) for cost efficiency

#### PostgreSQL Database (`modules/db/`)
- **Deployment**: Kubernetes StatefulSet for data persistence
- **Storage**: Persistent Volume Claims with configurable storage class (8Gi)
- **Security**: Credentials stored as Kubernetes secrets
- **Networking**: Headless service for cluster communication
- **Resources**: Configurable CPU/memory requests and limits
- **Fix**: PGDATA environment variable to avoid lost+found directory issues

#### Storage Bucket
- **Purpose**: Static assets and application logs
- **Features**: Versioning enabled for data protection
- **Naming**: `{project_id}-static-files` convention

## Prerequisites

1. **GCP Project** with required APIs enabled:
   - `container.googleapis.com` (GKE)
   - `compute.googleapis.com` (VPC/Compute)
   - `storage.googleapis.com` (GCS)

2. **Required Tools**:
   ```bash
   # Terraform >= 1.0
   terraform version

   # GCP CLI
   gcloud version

   # Kubectl
   kubectl version --client
   ```

3. **Authentication**:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-key.json"
   gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
   gcloud config set project YOUR_PROJECT_ID
   ```

## Quick Start

### 1. Clone and Navigate
```bash
cd infra/
```

### 2. Configure Variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Plan and Apply
```bash
terraform plan
terraform apply
```

```bash

module.gke.google_container_node_pool.primary_nodes: Still creating... [1m30s elapsed]
module.gke.google_container_node_pool.primary_nodes: Still creating... [1m40s elapsed]
module.gke.google_container_node_pool.primary_nodes: Still creating... [1m50s elapsed]
module.gke.google_container_node_pool.primary_nodes: Creation complete after 1m56s [id=projects/devops-candidate-1/locations/us-central1-a/clusters/devops-gke/nodePools/devops-gke-pool]
module.db.kubernetes_namespace.db: Creating...
module.db.kubernetes_namespace.db: Creation complete after 1s [id=db]
module.db.kubernetes_secret.postgres: Creating...
module.db.kubernetes_service.postgres_headless: Creating...
module.db.kubernetes_secret.postgres: Creation complete after 1s [id=db/postgres-credentials]
module.db.kubernetes_service.postgres_headless: Creation complete after 1s [id=db/postgres]
module.db.kubernetes_stateful_set.postgres: Creating...
module.db.kubernetes_stateful_set.postgres: Still creating... [10s elapsed]
module.db.kubernetes_stateful_set.postgres: Still creating... [20s elapsed]
module.db.kubernetes_stateful_set.postgres: Still creating... [30s elapsed]
module.db.kubernetes_stateful_set.postgres: Still creating... [40s elapsed]
module.db.kubernetes_stateful_set.postgres: Still creating... [50s elapsed]
module.db.kubernetes_stateful_set.postgres: Still creating... [1m0s elapsed]
module.db.kubernetes_stateful_set.postgres: Still creating... [1m10s elapsed]
module.db.kubernetes_stateful_set.postgres: Creation complete after 1m18s [id=db/postgres]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

bucket_name = "devops-candidate-1-static-files"
cluster_name = "devops-gke"
db_namespace = "db"
gke_ca_cert = <sensitive>
gke_endpoint = "34.42.147.124"
project_id = "devops-candidate-1"
region = "us-central1"

omar@Alaswar:~/Music/pikado-task/infra$ 

```


### 5. Configure kubectl
```bash
gcloud container clusters get-credentials devops-gke --zone=us-central1-a
kubectl get nodes
```



### 5. Configure kubectl
```bash
omar@Alaswar:~/Music/pikado-task/infra$ gcloud container clusters get-credentials devops-gke --zone=us-central1-a
Fetching cluster endpoint and auth data.
kubeconfig entry generated for devops-gke.
omar@Alaswar:~/Music/pikado-task/infra$ kubectl get nodes
NAME                                           STATUS   ROLES    AGE   VERSION
gke-devops-gke-devops-gke-pool-81619d82-5b13   Ready    <none>   21m   v1.31.13-gke.1377000
gke-devops-gke-devops-gke-pool-81619d82-jmw8   Ready    <none>   21m   v1.31.13-gke.1377000
omar@Alaswar:~/Music/pikado-task/infra$ kubectl get nodes -o wide
NAME                                           STATUS   ROLES    AGE   VERSION                INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                             KERNEL-VERSION   CONTAINER-RUNTIME
gke-devops-gke-devops-gke-pool-81619d82-5b13   Ready    <none>   21m   v1.31.13-gke.1377000   10.0.0.14     <none>        Container-Optimized OS from Google   6.6.111+         containerd://1.7.28
gke-devops-gke-devops-gke-pool-81619d82-jmw8   Ready    <none>   21m   v1.31.13-gke.1377000   10.0.0.13     <none>        Container-Optimized OS from Google   6.6.111+         containerd://1.7.28
omar@Alaswar:~/Music/pikado-task/infra$ 
omar@Alaswar:~/Music/pikado-task/infra$ kubectl get ns
NAME                          STATUS   AGE
db                            Active   20m
default                       Active   32m
gke-managed-cim               Active   30m
gke-managed-system            Active   29m
gke-managed-volumepopulator   Active   29m
gmp-public                    Active   29m
gmp-system                    Active   29m
kube-node-lease               Active   32m
kube-public                   Active   32m
kube-system                   Active   32m
omar@Alaswar:~/Music/pikado-task/infra$ kubectl get pod -A
NAMESPACE         NAME                                                      READY   STATUS    RESTARTS      AGE
db                postgres-0                                                1/1     Running   0             20m
gke-managed-cim   kube-state-metrics-0                                      2/2     Running   0             27m
gmp-system        collector-8tlvf                                           2/2     Running   0             21m
gmp-system        collector-fmgrw                                           2/2     Running   0             21m
gmp-system        gmp-operator-7479dc949b-n6hwl                             1/1     Running   0             27m
kube-system       event-exporter-gke-787cd5d885-vzlv7                       2/2     Running   0             27m
kube-system       fluentbit-gke-59h5c                                       3/3     Running   0             21m
kube-system       fluentbit-gke-xcg7p                                       3/3     Running   0             21m
kube-system       gke-metrics-agent-kn9vk                                   3/3     Running   0             21m
kube-system       gke-metrics-agent-lkngv                                   3/3     Running   0             21m
kube-system       konnectivity-agent-5d776584bb-5pgm8                       2/2     Running   0             21m
kube-system       konnectivity-agent-5d776584bb-ztd6h                       2/2     Running   0             27m
kube-system       konnectivity-agent-autoscaler-6f86876954-65pml            1/1     Running   0             27m
kube-system       kube-dns-autoscaler-55f9d78bc7-fdj8s                      1/1     Running   0             27m
kube-system       kube-dns-b976dcd97-6w94c                                  5/5     Running   0             27m
kube-system       kube-dns-b976dcd97-z74vt                                  5/5     Running   0             21m
kube-system       kube-proxy-gke-devops-gke-devops-gke-pool-81619d82-5b13   1/1     Running   0             20m
kube-system       kube-proxy-gke-devops-gke-devops-gke-pool-81619d82-jmw8   1/1     Running   0             21m
kube-system       l7-default-backend-7bb8dc99b8-znr79                       1/1     Running   0             27m
kube-system       metrics-server-v1.31.0-5c85cd97dd-spwmf                   1/1     Running   0             27m
kube-system       pdcsi-node-dpmd9                                          2/2     Running   0             21m
kube-system       pdcsi-node-nw7nc                                          2/2     Running   1 (20m ago)   21m

omar@Alaswar:~/Music/pikado-task/infra$ 


```

**Expected Output:**
```
NAME                                           STATUS   ROLES    AGE   VERSION
gke-devops-gke-devops-gke-pool-xxxxx-xxxxx   Ready    <none>   XXm   v1.31.13-gke.1377000
gke-devops-gke-devops-gke-pool-xxxxx-xxxxx   Ready    <none>   XXm   v1.31.13-gke.1377000
```

### 6. Verify Database Deployment
```bash
kubectl get pods -n db
kubectl get svc -n db
```


```bash
omar@Alaswar:~/Music/pikado-task/infra$ kubectl get pods -n db
kubectl get svc -n db

NAME         READY   STATUS    RESTARTS   AGE
postgres-0   1/1     Running   0          31m

NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
postgres   ClusterIP   None         <none>        5432/TCP   31m

omar@Alaswar:~/Music/pikado-task/infra$ 

```


## Storage Usage

The GCS bucket can be accessed for storing static files:

```bash
# List bucket
gsutil ls gs://$(terraform output -raw bucket_name)

# Upload files
gsutil cp ./static/* gs://$(terraform output -raw bucket_name)/static/
```


### Infrastructure Backup
```bash
# State is automatically backed up in GCS
# Export current configuration
terraform plan -out=infrastructure.plan
```



### Debug Commands
```bash
# Terraform validation
terraform validate
terraform fmt -check

# Kubernetes diagnostics
kubectl cluster-info
kubectl top nodes
kubectl get events --all-namespaces

```

## Autoscaling Configuration

The infrastructure supports cluster node autoscaling to optimize costs and handle varying workloads.

### 🔧 **Cluster Node Autoscaling**

**Current Configuration:**
- **Min nodes**: 1
- **Max nodes**: 5
- **Current nodes**: 2
- **Status**: ✅ Enabled

**How it Works:**
- **Scale Up**: When pods can't be scheduled due to insufficient resources
- **Scale Down**: When nodes are underutilized for 10+ minutes
- **Cooldown**: 10-15 minutes between scaling operations

**Enable Autoscaling:**
```bash
# Configure autoscaling in terraform.tfvars
enable_autoscaling = true
min_node_count    = 1
max_node_count    = 5

# Apply changes
terraform apply
```

**Monitor Autoscaling:**
```bash
# Check autoscaler logs
kubectl logs -n kube-system -l k8s-app=cluster-autoscaler

# Check node pool status
gcloud container node-pools describe devops-gke-pool --cluster=devops-gke --zone=us-central1-a

# View current nodes
kubectl get nodes
```

**Cost Estimation:**
- **Minimum**: 1 × e2-medium = ~$26/month
- **Maximum**: 5 × e2-medium = ~$130/month
- **Current**: 2 × e2-medium = ~$52/month

### Vertical Scaling
```bash
# Update machine type
terraform apply -var="machine_type=e2-standard-4"
```
