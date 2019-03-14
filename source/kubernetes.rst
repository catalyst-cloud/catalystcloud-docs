##########
Kubernetes
##########

Catalyst Kubernetes Service makes it easy for you to deploy, manage, and scale
Kubernetes clusters to run containerised applications on the Catalyst Cloud.

.. warning::

  This service is in Technical Preview (ALPHA) and is not recommended for
  production workloads yet.

Table of Contents:

.. toctree::
  :maxdepth: 1

  kubernetes/quickstart
  kubernetes/introduction
  kubernetes/clusters
  kubernetes/storage
  kubernetes/network_policies

.. note::

  If working from the commandline with the OpenStack tools please ensure that
  the version of the python-magnumclient is 2.12.0 or above.

******************
Providing feedback
******************

Our goal with this alpha release is to establish a feedback loop and collaborate
with early adopters of the technology, to ensure it meets the unique needs of
our customers in NZ.

At this stage, the service is expected to have some rough edges and bugs. If you
encounter an issue or have a suggestion on how we can improve it, please raise
a ticket via the `Support Centre`_.

.. _`Support Centre`: https://catalystcloud.nz/support/support-centre/

Where possible, when creating support tickets, please include the output of the
following command to assist our support team in helping you to resolve it.

.. code-block:: bash

  $ openstack coe cluster show <cluster_name>

************
Known Issues
************

This is an overview of the issues encountered in the process of testing this
Technical Preview release.


Cluster fails to delete
=======================

When deleting a cluster that has a loadbalancer added subsequent to the actual
cluster deployment action, it will fail due to a resource conflict.

.. code-block:: bash

  Failed to delete cluster because stack delete failed Error: Resource DELETE
  failed: Conflict: resources.network.resources.private_subnet: Unable to
  complete operation on subnet 0b65ff86-13a5-460f-96c3-d3b20377df60.
  One or more ports have an IP allocation from this subnet.

Status
------

The cause of the problem has been identified and a fix is being investigated.

Workaround
----------

Manually delete any loadbalancers within the cluster that were not created as
part of the initial cluster creation.


Cluster is created but pods fail
================================

The cluster create command completes and when examined appears to have done so
successfully. Any attempts to interact with the nodes will fail.

If the current pod state is displayed it can be seen that there are several
containers still sitting in the ``ContainerCreating`` state.

This is not a recoverable error and the cluster will need to be created if
this occurs.

.. code-block:: bash

  $ kubectl get pods --all-namespaces -o wide
  NAMESPACE     NAME                                                   READY     STATUS              RESTARTS   AGE       IP          NODE                                     NOMINATED NODE
  kube-system   ==calico-kube-controllers-54dfc58c64-2xprd==               1/1       Running             0          32m       10.0.0.13   test-prod-z2h4cs73basz-minion-0   <none>
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
------

This is a known Kubernetes issue that is due to some incompatibility between
overlay2 and docker_volume_size. A fix is being investigated.

Workaround
----------

There is currently an interim workaround in place to address the issue.

.. Note::

  Using ``--docker-volume-size`` for the cluster creation, either from the
  dashboard or the cli, will cause the this error state to occur.


Cluster takes a long time to deploy
===================================

Description
-----------

Currently the time taken to deploy a cluster from commandline or dashbard is
in the vicinity of 15-25 minutes.

Status
------

The cause of the problem is known and a fix is being investigated.

Workaround
----------

None.
