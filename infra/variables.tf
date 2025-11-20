variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "GKE Cluster Name"
  type        = string
  default     = "dev-gke-cluster"
}

variable "node_count" {
  description = "Number of GKE nodes"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-medium"
}



variable "app_name" {
  description = "Application name (optional)"
  type        = string
  default     = "webapp"
}

# DB variables
variable "db_username" {
  type      = string
  default   = "pguser"
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
  description = "Postgres password (sensitive). Provide in tfvars or env."
}

variable "db_database" {
  type    = string
  default = "appdb"
}

variable "db_storage_class" {
  type    = string
  default = "" # leave empty to use cluster default storage class
}

variable "state_bucket_name" {
  description = "GCS bucket name for Terraform state storage"
  type        = string
  default     = ""
}

variable "gke_version" {
  description = "GKE Kubernetes version"
  type        = string
  default     = "1.31.13-gke.1377000"
}

# Autoscaling variables
variable "min_node_count" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 5
}

variable "enable_autoscaling" {
  description = "Enable cluster autoscaling"
  type        = bool
  default     = false
}
