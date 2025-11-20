output "namespace" {
  value = kubernetes_namespace.db.metadata[0].name
}
