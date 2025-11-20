# GKE module (provisions cluster, subnetwork, node pool)
module "gke" {
  source             = "./modules/gke"
  project_id         = var.project_id
  region             = var.region
  cluster_name       = var.cluster_name
  node_count         = var.node_count
  machine_type       = var.machine_type
  gke_version        = var.gke_version
  min_node_count     = var.min_node_count
  max_node_count     = var.max_node_count
  enable_autoscaling = var.enable_autoscaling
}

# DB module deploys namespace, secret, svc, statefulset (Postgres)
module "db" {
  source = "./modules/db"

  namespace          = "db"
  db_username        = var.db_username
  db_password        = var.db_password
  db_database        = var.db_database
  storage_class_name = var.db_storage_class

  depends_on = [module.gke]
}

# Storage bucket for static files / logs
resource "google_storage_bucket" "static" {
  name          = "${var.project_id}-static-files"
  location      = var.region
  force_destroy = true

  versioning {
    enabled = true
  }
}
