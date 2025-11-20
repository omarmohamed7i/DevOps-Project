# Infra-level outputs (use module outputs where appropriate)

output "cluster_name" {
  value = module.gke.cluster_name
  description = "Name of the GKE cluster (from gke module)"
}

output "region" {
  value       = var.region
  description = "Region used for resources"
}

output "project_id" {
  value       = var.project_id
  description = "GCP project id"
}

output "gke_endpoint" {
  value       = module.gke.endpoint
  description = "GKE endpoint (API server)"
}

output "gke_ca_cert" {
  value     = module.gke.cluster_ca_certificate
  sensitive = true
  description = "Base64 cluster CA certificate"
}

output "db_namespace" {
  value       = module.db.namespace
  description = "Namespace where Postgres was deployed"
}

output "bucket_name" {
  value       = google_storage_bucket.static.name
  description = "Name of the storage bucket for static files/logs"
}
