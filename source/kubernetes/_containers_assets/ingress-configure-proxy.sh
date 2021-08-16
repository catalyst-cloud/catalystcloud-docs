cat <<EOF > nginx-ingress-controller-helm-values.yaml
  controller:
      publishService:
          enabled: true
      config:
          use-forward-headers: "true"
          compute-full-forward-for: "true"
          use-proxy-protocol: "true"
      service:
          annotations:
            loadbalancer.openstack.org/proxy-protocol: "true"
  EOF