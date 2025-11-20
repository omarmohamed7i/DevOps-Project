output "cluster_name" {
  value = google_container_cluster.primary.name
  description = "Name of the GKE cluster"
}

output "endpoint" {
  value = google_container_cluster.primary.endpoint
  description = "GKE cluster endpoint"
}

output "cluster_ca_certificate" {
  value = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
  description = "Cluster CA certificate"
}
