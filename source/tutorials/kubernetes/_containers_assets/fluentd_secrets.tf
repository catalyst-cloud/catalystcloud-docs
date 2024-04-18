# Create secrets for Fluentd.
resource "kubernetes_secret_v1" "fluentd" {
  metadata {
    name      = "fluentd"
    namespace = kubernetes_namespace_v1.logging.metadata[0].name
  }

  data = {
    aws_access_key_id     = openstack_identity_ec2_credential_v3.fluentd.access
    aws_secret_access_key = openstack_identity_ec2_credential_v3.fluentd.secret
  }
}
