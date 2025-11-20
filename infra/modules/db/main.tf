locals {
  ns = var.namespace
}

# Namespace
resource "kubernetes_namespace" "db" {
  metadata {
    name = local.ns
  }
}

# Secret for DB credentials
resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "postgres-credentials"
    namespace = kubernetes_namespace.db.metadata[0].name
  }

  data = {
    username = base64encode(var.db_username)
    password = base64encode(var.db_password)
    database = base64encode(var.db_database)
  }

  type = "Opaque"
}

# Headless Service
resource "kubernetes_service" "postgres_headless" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.db.metadata[0].name
    labels = {
      app = "postgres"
    }
  }

  spec {
    cluster_ip = "None"
    selector = {
      app = "postgres"
    }

    port {
      name        = "postgres"
      port        = 5432
      target_port = 5432
    }
  }
}

# StatefulSet
resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.db.metadata[0].name
    labels = {
      app = "postgres"
    }
  }

  spec {
    service_name = kubernetes_service.postgres_headless.metadata[0].name
    replicas     = var.replicas

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = var.image

          port {
            container_port = 5432
            name           = "postgres"
          }

          env {
            name = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres.metadata[0].name
                key  = "database"
              }
            }
          }

          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }

          volume_mount {
            name       = "pgdata"
            mount_path = "/var/lib/postgresql/data"
          }
        } # container
      } # spec
    } # template

    volume_claim_template {
      metadata {
        name = "pgdata"
      }

      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = var.storage_size
          }
        }

        storage_class_name = var.storage_class_name == "" ? null : var.storage_class_name
      }
    }
  }
}
