# Create the Fluentd daemon set.
resource "kubernetes_daemon_set_v1" "fluentd" {
  metadata {
    name      = "fluentd"
    namespace = kubernetes_namespace_v1.logging.metadata[0].name
    labels = {
      "k8s-app"                         = "fluentd"
      "addonmanager.kubernetes.io/mode" = "Reconcile"
    }
  }

  spec {
    selector {
      match_labels = {
        name = "fluentd"
      }
    }

    template {
      metadata {
        labels = {
          name = "fluentd"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.fluentd.metadata[0].name

        toleration {
          key    = "node-role.kubernetes.io/control-plane"
          effect = "NoSchedule"
        }

        container {
          name  = "fluentd"
          # To avoid breaking changes, pin the image to a specific version:
          # https://hub.docker.com/r/fluent/fluentd-kubernetes-daemonset
          image = "fluent/fluentd-kubernetes-daemonset:v1-debian-s3"

          # Required on Catalyst Cloud Kubernetes Service.
          # For other Kubernetes clusters, this may need to be set to `json`
          # if containerd is configured to use the `json-file` log driver.
          env {
            name  = "FLUENT_CONTAINER_TAIL_PARSER_TYPE"
            value = "/^(?<time>.+) (?<stream>stdout|stderr) [^ ]* (?<log>.*)$/"
          }
          # Optional values:
          #  * S3_PATH - Add prefix to the log files in the target container/bucket.
          #  * S3_OBJECT_KEY_FORMAT - Format string for the log file path.
          #  * S3_TIMEKEY - Interval for log files, in seconds. Default is 3600 seconds (1 hour).
          #  * S3_CHUNK_LIMIT_SIZE - Maximum size limit for chunks. Default is '256m' (256MB).
          env {
            name  = "S3_BUCKET_NAME"
            value = openstack_objectstorage_container_v1.fluentd.name
          }
          env {
            name  = "S3_ENDPOINT_URL"
            value = "https://object-storage.${openstack_objectstorage_container_v1.fluentd.region}.catalystcloud.io"
          }
          env {
            name  = "S3_BUCKET_REGION"
            value = "us-east-1"
          }
          env {
            name  = "S3_FORCE_PATH_STYLE"
            value = "true"
          }
          env {
            name = "AWS_ACCESS_KEY_ID"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.fluentd.metadata[0].name
                key  = "aws_access_key_id"
              }
            }
          }
          env {
            name = "AWS_SECRET_ACCESS_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.fluentd.metadata[0].name
                key  = "aws_secret_access_key"
              }
            }
          }
          env {
            name  = "FLUENT_UID"
            value = "0"
          }

          resources {
            limits = {
              memory = "200Mi"
            }
            requests = {
              cpu    = "1000m"
              memory = "200Mi"
            }
          }

          volume_mount {
            name       = "var-log"
            mount_path = "/var/log"
          }
          volume_mount {
            name       = "var-lib-docker-containers"
            mount_path = "/var/lib/docker/containers"
          }
          volume_mount {
            name       = "fluent-conf"
            mount_path = "/fluentd/etc/fluent.conf"
            sub_path   = "fluent.conf"
            read_only  = true
          }
        }

        termination_grace_period_seconds = 30

        volume {
          name = "var-log"
          host_path {
            path = "/var/log"
          }
        }
        volume {
          name = "var-lib-docker-containers"
          host_path {
            path = "/var/lib/docker/containers"
          }
        }
        volume {
          name = "fluent-conf"
          config_map {
            name = kubernetes_config_map_v1.fluentd.metadata[0].name
          }
        }
      }
    }
  }
}
