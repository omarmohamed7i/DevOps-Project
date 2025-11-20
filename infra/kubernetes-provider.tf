# Kubernetes provider configuration for database deployment
# This provider is configured after GKE cluster creation

# Configure kubernetes provider using GKE module outputs
# This provider is configured after GKE cluster creation
provider "kubernetes" {
  host  = "https://${module.gke.endpoint}"
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  token = data.google_client_config.default.access_token
}