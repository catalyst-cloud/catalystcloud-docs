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

  cluster-name: 718439c2-933c-4288-abc7-c3e6ba617663
  dry-run: false
  cloud-provider: openstack
  repair-delay-after-add: 3m
  openstack:
    user-id: 937509608ad344d0b226f5946f64d23b
    password: "password"
    auth-url: http://192.168.200.200/identity
    region: RegionOne
    project-id: d40141b0d5604fbdabfa65dbe8eceb7a
  kubernetes:
      api-host:
      kubeconfig: /home/feilong/config
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
