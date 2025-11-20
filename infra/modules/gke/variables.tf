variable "project_id" {}
variable "region" {}
variable "cluster_name" {}
variable "node_count" {}
variable "machine_type" {}
variable "gke_version" {}

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
