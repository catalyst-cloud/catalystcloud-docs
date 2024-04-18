# Create logging namespace.
resource "kubernetes_namespace_v1" "logging" {
  metadata {
    name = "logging"
  }
}

# Create the fluentd ServiceAccount.
resource "kubernetes_service_account_v1" "fluentd" {
  metadata {
    name      = "fluentd"
    namespace = kubernetes_namespace_v1.logging.metadata[0].name
  }
}

# Create a fluentd ClusterRole to access pods and namespaces.
resource "kubernetes_cluster_role_v1" "fluentd" {
  metadata {
    name = "fluentd"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods"]
    verbs      = ["get", "list", "watch"]
  }
}

# Bind the ServiceAccount to the ClusterRole.
resource "kubernetes_cluster_role_binding_v1" "fluentd" {
  metadata {
    name = "fluentd"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.fluentd.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.fluentd.metadata[0].name
    namespace = kubernetes_namespace_v1.logging.metadata[0].name
  }
}
