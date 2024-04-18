# Create the fluent.conf config map.
resource "kubernetes_config_map_v1" "fluentd" {
  metadata {
    name      = "fluentd"
    namespace = kubernetes_namespace_v1.logging.metadata[0].name
  }

  data = {
    "fluent.conf" = "${file("${path.module}/fluent.conf")}"
  }
}
