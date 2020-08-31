.. _auto-healing:

############
Auto healing
############

************
Introduction
************

Cluster auto healing is a feature of the Kubernetes service on the Catalyst
Cloud that monitors the health state of the cluster and automatically repairs
Kubernetes' components (for example: etcd, kubelet) or nodes (master or
worker) that are unhealthy. This is distinct and complementary to the
self-healing that Kubernetes performs for pods.

Auto-healing is enabled by default. If desirable, auto-healing can be disabled
at cluster creation time via the label ``auto_healing_enabled=false``.

*****************
How does it work?
*****************

An agent called ``magnum-auto-healer`` is deployed as a daemon set to the
Kubernetes cluster (automatically, during cluster creation time). It monitors
the health state of the following  components:

* For master nodes, it monitors the output of the ``healthz`` API call for
  the health status of ``kube-apiserver`` and ``etcd`` every 30 seconds.
* For all nodes, it monitors if the ``kubelet`` status is ready every 30
  seconds.

A repair action is triggered if any component is unhealthy for more than 3
minutes. The repair procedure rebuilds the unhealthy node from scratch, while
minimising impact to running application workloads as much as possible.

****************************
Support more node conditions
****************************

There are several built-in node conditions supported by Kubernetes except the
Ready condition enabled by Catalyst Cloud Kubernetes service auto healing,
shown as below:

+--------------------+----------------------------------------------------------+
| Node Condition     | Description                                              | 
+====================+==========================================================+
| Ready              | True if the node is healthy and ready to accept pods,    | 
|                    | False if the node is not healthy and is not accepting    |
|                    | pods, and Unknown if the node controller has not heard   |
|                    | from the node in the last node-monitor-grace-period      |
|                    | (default is 40 seconds)                                  |
+--------------------+----------------------------------------------------------+
| DiskPressure       | True if pressure exists on the disk size--that is, if    |
|                    | the disk capacity is low; otherwise False                |
+--------------------+----------------------------------------------------------+
| MemoryPressure     | True if pressure exists on the node memory--that is, if  |
|                    | the node memory is low; otherwise False                  |
+--------------------+----------------------------------------------------------+
| DiskPressure       | True if pressure exists on the disk size--that is, if    |
|                    | the disk capacity is low; otherwise False                |
+--------------------+----------------------------------------------------------+
| PIDPressure        | True if pressure exists on the disk process--that is, if |
|                    | the disk process is low; otherwise False                 |
+--------------------+----------------------------------------------------------+
| NetworkUnavailable | True if the network for the node is not correctly        |
|                    | configured, otherwise False                              |
+--------------------+----------------------------------------------------------+
| KernelDeadlock     | True if the kernel has no deadlock otherwise False       |
+--------------------+----------------------------------------------------------+
		
To support more conditions monitoring and healing, you can just edit the
configmap named ``magnum-auto-healer-config`` shown as below to support additional
node conditions.   							

.. code-block:: yaml

  apiVersion: v1
  data:
    config.yaml: |
      cluster-name: 99d18ecb-7e9a-4837-aeac-0dae82f419bd
      dry-run: false
      monitor-interval: 30s
      check-delay-after-add: 20m
      leader-elect: true
      healthcheck:
        master:
          - type: Endpoint
            params:
              unhealthy-duration: 3m
              protocol: HTTPS
              port: 6443
              endpoints: ["/healthz"]
              ok-codes: [200]
          - type: NodeCondition
            params:
              unhealthy-duration: 3m
              types: ["Ready"]
              ok-values: ["True"]
        worker:
          - type: NodeCondition
            params:
              unhealthy-duration: 3m
              types: ["Ready"]
              ok-values: ["True"]
          - type: NodeCondition
            params:
              unhealthy-duration: 3m
              types: ["DiskPressure"]
              ok-values: ["False"]
      openstack:
        auth-url: http://192.168.202.1/identity/v3
        user-id: 2622d1fa39b0411abb183afcbc70536d
        password: uR2sGAi8wX5Dwgiejx
        trust-id: e08c5190f19e4dc7bcbb72ba0f25bde5
        region: RegionOne
        ca-file: /etc/kubernetes/ca-bundle.crt
  kind: ConfigMap
  metadata:
    creationTimestamp: null
    namespace: kube-system
    name: magnum-auto-healer-config
