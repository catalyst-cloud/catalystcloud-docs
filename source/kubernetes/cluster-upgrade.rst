.. _cluster-upgrade:

###############
Cluster Upgrade
###############

You can upgrade the version of a running Kubernetes cluster with minimal impact
to running applications.

As long as the application deployment best practices described in
`Avoiding application downtime`_ are followed, running applications
should have no downtime during the upgrade as pods drained from each node
will be scheduled to another.

When an upgrade is triggered, the **control plane** (master) and **worker** nodes
are replaced with new nodes containing upgraded Operating Systems and Kubernetes.
The replacement follows standard Kubernetes rollout prodedures, and replaces one
node at a time.

When each node is deleted, the following actions take place:

1. **Cordon**: The node becomes unavailable to schedule new workloads.
2. **Drain**: All workloads are evicted from the node.
3. **Delete**: The node is removed from the cluster and deleted.

.. note::

  Cluster upgrades are not supported for clusters running Kubernetes 1.27 and below.

  Please build a replacement cluster running on the latest available version.
  Once this has been done, you will be able to use the cluster upgrade API
  for future upgrades.

******************************
Rebuilding vs in-place upgrade
******************************

When you have a cluster running with Catalyst Cloud Kubernetes Service, you have two options for
upgrading:

1. Build a new cluster and migrate workloads to the new cluster.
2. Upgrade the running cluster in-place using Catalyst Cloud's cluster upgrade API.

Upgrading a running cluster is especially useful for Kubernetes patch version and
base operating system security updates. The risk of breaking changes to your workloads
is low, as there are few feature changes.

There are good reasons to choose to build a new cluster, migrate workloads, and delete the old cluster entirely.
This process allows you to fully test all deployed resources, jump more than one minor Kuberenetes version and
provides a fallback option if the upgrade does not go as planned.

You may also benefit from having tested your backup, restore and cutover procedures.

Catalyst Cloud and upstream Kubernetes do not typically introduce API or ``kube-system`` version changes
into patch or regular template builds, but this may be done for minor Kubernetes versions. While
we expect this to be non-impacting, this represents a change to components you may be relying upon.

*****************************
Avoiding application downtime
*****************************

When performing an in-place upgrade, it is possible to reduce or remove percieved downtime to
applications. To do so, the best practices below should be followed:

1. The application must be deployed and managed by a controller
   (such as a ``Deployment`` or ``ReplicaSet``) with multiple replicas (replicas > 1).
2. An ``Ingress`` or ``LoadBalancer`` should be used in front of the application, and it must
   take into account readiness state of pods.
3. A `pod disruption budget`_ must be applied, and it must define the minimum
   number of pods required for the application to function properly
   (such as ``minAvailable`` > 1).
4. The container definition must have a **liveness probe** defined, to ensure the
   pod disruption budget is accounting for healthy replicas only.
5. The container definition must have a **readiness probe** defined,
   preventing pods from being re-introduced to the load balancer before the
   pod is ready to respond to requests.
6. The application should support the ``SIGTERM`` signal for graceful
   shutdown, or alternatively a ``preStop`` hook should be defined.

.. _`pod disruption budget`: https://kubernetes.io/docs/concepts/workloads/pods/disruptions

*******************
Upgrading a cluster
*******************

Identify the cluster that needs to be upgraded
==============================================

The following command will list all Kubernetes clusters in your project, so you can identify the UUID
of the cluster to be upgraded:

.. code-block:: console

    $ openstack coe cluster list
    +--------------------------------------+--------------+---------+------------+--------------+-----------------+---------------+
    | uuid                                 | name         | keypair | node_count | master_count | status          | health_status |
    +--------------------------------------+--------------+---------+------------+--------------+-----------------+---------------+
    | 1fa44912-54e6-4421-a633-e2a831c38f60 | dev-cluster1 | None    |          5 |            3 | UPDATE_COMPLETE | HEALTHY       |
    +--------------------------------------+--------------+---------+------------+--------------+-----------------+---------------+

Identify the Cluster Template to upgrade to
===========================================

When choosing the target Cluster Template, the following rules must be followed:

1. Catalyst Cloud does **not** support upgrading clusters of version v1.27 or below. These must be
   rebuilt to a new version.
2. Clusters must be upgraded to a later version only. Downgrading is not supported.
3. In accordance with the `Kubernetes Version Skew Policy`_, clusters must be upgraded
   by one minor version at a time.
   This means that, for example, a v1.28.x cluster must be upgraded to v1.29.x first,
   before being upgraded to v1.30.x.

.. _`Kubernetes Version Skew Policy`: https://kubernetes.io/releases/version-skew-policy

The following command will list the Kubernetes Cluster Template versions
available, so you can choose the version you want to upgrade to:

.. code-block:: console

  $ openstack coe cluster template list
  +--------------------------------------+-----------------------------------+---------------------------------------------------------------------------------+
  | uuid                                 | name                              | tags                                                                            |
  +--------------------------------------+-----------------------------------+---------------------------------------------------------------------------------+
  | 456a5390-67c3-4a89-b1e8-ba8dbf529506 | kubernetes-v1.26.14-prod-20240218 | environment:prod,build_id:20240218,pipeline_id:40826,created_at:20240218T183133 |
  | b922a741-099a-4987-bc32-d5f3e3a4beed | kubernetes-v1.27.11-prod-20240218 | environment:prod,build_id:20240218,pipeline_id:40827,created_at:20240218T183254 |
  | dafe4576-8de0-4024-a12a-1bc5197b474f | kubernetes-v1.28.9-20240416       | None                                                                            |
  +--------------------------------------+-----------------------------------+---------------------------------------------------------------------------------+

Upgrade a running Kubernetes cluster
====================================

Before upgrading, confirm the status of the cluster is ``CREATE_COMPLETE`` or ``UPDATE_COMPLETE``
using the following command:

.. code-block:: console

  $ openstack coe cluster show dev-cluster1 -c status -c coe_version -c cluster_template_id
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | status              | UPDATE_COMPLETE                      |
  | cluster_template_id | dafe4576-8de0-4024-a12a-1bc5197b474f |
  | coe_version         | v1.28.9                              |
  +---------------------+--------------------------------------+

Then, upgrade to the new Cluster Template using the following command:

.. code-block:: console

  $ openstack coe cluster upgrade dev-cluster1 kubernetes-v1.29.3-20240416
  Request to upgrade cluster dev-cluster1 has been accepted.


The cluster control plane and all node groups will then upgraded, following the rollout strategy.


.. code-block:: console

  $ openstack coe cluster show dev-cluster1 -c status -c coe_version -c cluster_template_id
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | status              | UPDATE_COMPLETE                      |
  | cluster_template_id | 6cb63ff2-521d-4f0f-8352-5c858009d85f |
  | coe_version         | v1.29.3                              |
  +---------------------+--------------------------------------+

And Kubernetes will show that the upgrade has replaced all nodes:

.. code-block:: console

  $ kubectl get nodes -o wide
  NAME                                                      STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                                             KERNEL-VERSION   CONTAINER-RUNTIME
  dev-cluster1-47ctpuwqwfsi-control-plane-85b643e9-6w9w9    Ready    control-plane   17m   v1.29.3   10.0.0.30     <none>        Flatcar Container Linux by Kinvolk 3815.2.0 (Oklo)   6.1.77-flatcar   containerd://1.7.13
  dev-cluster1-47ctpuwqwfsi-control-plane-85b643e9-hhwq4    Ready    control-plane   14m   v1.29.3   10.0.0.25     <none>        Flatcar Container Linux by Kinvolk 3815.2.0 (Oklo)   6.1.77-flatcar   containerd://1.7.13
  dev-cluster1-47ctpuwqwfsi-control-plane-85b643e9-n6fcf    Ready    control-plane   22m   v1.29.3   10.0.0.26     <none>        Flatcar Container Linux by Kinvolk 3815.2.0 (Oklo)   6.1.77-flatcar   containerd://1.7.13
  dev-cluster1-47ctpuwqwfsi-default-worker-e7b42e0e-dcclm   Ready    <none>          18m   v1.29.3   10.0.0.11     <none>        Flatcar Container Linux by Kinvolk 3815.2.0 (Oklo)   6.1.77-flatcar   containerd://1.7.13
  dev-cluster1-47ctpuwqwfsi-default-worker-e7b42e0e-whsnl   Ready    <none>          21m   v1.29.3   10.0.0.4      <none>        Flatcar Container Linux by Kinvolk 3815.2.0 (Oklo)   6.1.77-flatcar   containerd://1.7.13
  dev-cluster1-47ctpuwqwfsi-default-worker-e7b42e0e-zxzn6   Ready    <none>          20m   v1.29.3   10.0.0.23     <none>        Flatcar Container Linux by Kinvolk 3815.2.0 (Oklo)   6.1.77-flatcar   containerd://1.7.13
  dev-cluster1-47ctpuwqwfsi-larger-pool2-8fe8717f-fjv97     Ready    <none>          22m   v1.29.3   10.0.0.27     <none>        Flatcar Container Linux by Kinvolk 3815.2.0 (Oklo)   6.1.77-flatcar   containerd://1.7.13
  dev-cluster1-47ctpuwqwfsi-larger-pool2-8fe8717f-vrdzm     Ready    <none>          19m   v1.29.3   10.0.0.17     <none>        Flatcar Container Linux by Kinvolk 3815.2.0 (Oklo)   6.1.77-flatcar   containerd://1.7.13
