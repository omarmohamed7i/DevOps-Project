variable "namespace" {
  type    = string
  default = "db"
}

variable "db_username" {
  type      = string
  default   = "pguser"
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_database" {
  type    = string
  default = "appdb"
}

variable "storage_class_name" {
  type    = string
  default = ""
}

variable "image" {
  type    = string
  default = "postgres:15.3"
}

variable "storage_size" {
  type    = string
  default = "8Gi"
}

variable "replicas" {
  type    = number
  default = 1
}
