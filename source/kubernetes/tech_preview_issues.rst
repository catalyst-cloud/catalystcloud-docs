##############################
Kubernetes Tech Preview Issues
##############################

This is an overview of the issues encountered in the process of testing this
Technical Preview release.


*****************************
Nodes lose their IP addresses
*****************************

Description
===========

This issue initially appears to be related to DNS as the error messages
encountered when running kubectl will normally contain something similar to
the following..

.. code-block:: bash

  error getting address for node <nodename>: no address found for host

The actual problem however is related to the fact that the InternalIP and/or
ExternalIP addresses are lost for some nodes.

Status
======

The cause of the problem has been identified and a fix has been proposed.

Workaround
==========

Run docker restart for the kubelet container.


***********************
Cluster fails to delete
***********************

When deleting a cluster that has a loadbalancer added subsequent to the actual
cluster deployment action, it will fail due to a resource conflict.

.. code-block:: bash

  Failed to delete cluster because stack delete failed Error: Resource DELETE
  failed: Conflict: resources.network.resources.private_subnet: Unable to
  complete operation on subnet 0b65ff86-13a5-460f-96c3-d3b20377df60.
  One or more ports have an IP allocation from this subnet.

Status
======

The cause of the problem has been identified and a fix is being investigated.

Workaround
==========

Manually delete any loadbalancers within the cluster that were not created as
part of the initial cluster creation.


********************************
Cluster is created but pods fail
********************************

The cluster create command completes and when examined appears to have done so
successfully. Any attempts to interact with the nodes will fail.

If the current pod state is displayed it can be seen that there are several
containers still sitting in the ``ContainerCreating`` state.

This is not a recoverable error and the cluster will need to be created if
this occurs.

.. code-block:: bash

  $ kubectl get pods --all-namespaces -o wide
  NAMESPACE     NAME                                                   READY     STATUS              RESTARTS   AGE       IP          NODE                                     NOMINATED NODE
  kube-system   **calico-kube-controllers-54dfc58c64-2xprd**               1/1       Running             0          32m       10.0.0.13   test-prod-z2h4cs73basz-minion-0   <none>
  kube-system   calico-node-95d26                                      2/2       Running             0          32m       10.0.0.12   test-prod-z2h4cs73basz-master-1   <none>
  kube-system   calico-node-hkdzm                                      2/2       Running             0          28m       10.0.0.13   test-prod-z2h4cs73basz-minion-0   <none>
  kube-system   calico-node-ljmxs                                      2/2       Running             0          32m       10.0.0.10   test-prod-z2h4cs73basz-master-0   <none>
  kube-system   calico-node-vdczb                                      2/2       Running             0          32m       10.0.0.11   test-prod-z2h4cs73basz-master-2   <none>
  kube-system   coredns-78df4bf8ff-kp9pk                               0/1       ContainerCreating   0          33m       <none>      test-prod-z2h4cs73basz-minion-0   <none>
  kube-system   heapster-74f98f6489-7ctpn                              0/1       ContainerCreating   0          32m       <none>      test-prod-z2h4cs73basz-minion-0   <none>
  kube-system   kube-dns-autoscaler-986c49747-whkmh                    0/1       ContainerCreating   0          33m       <none>      test-prod-z2h4cs73basz-minion-0   <none>
  kube-system   kubernetes-dashboard-54cb7b5997-2hzzk                  0/1       ContainerCreating   0          32m       <none>      test-prod-z2h4cs73basz-minion-0   <none>
  kube-system   node-exporter-test-prod-z2h4cs73basz-minion-0          0/1       ContainerCreating   0          23m       <none>      test-prod-z2h4cs73basz-minion-0   <none>

Status
======

The cause of the problem has been identified and a fix is being investigated.

Workaround
==========

There is currently an interim workaround in place to address the issue.
