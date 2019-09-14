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
