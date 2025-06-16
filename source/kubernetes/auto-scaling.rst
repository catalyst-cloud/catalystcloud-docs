
.. _auto-scaling:

############
Auto Scaling
############

The demands on any application vary over time. Whether it's the daily changes
in traffic volume on an online shopping platform or massive load from
processing large sets of data, applications and their underlying
infrastructure must be able to cope with changes in demand. It is important
to both avoid downtime when demand increases as well as to avoid the high
costs of running many machines when demand decreases.

It is not always easy or possible to predict what kind of resources will be
necessary when creating a Kubernetes cluster. The decision one must make is
whether to choose fewer nodes and risk downtime when the website is busy or
choose more nodes and risk paying for unused resources.

To assist with these scenarios, Catalyst Cloud Kubernetes Service provides a
feature called **cluster auto-scaling**. Cluster auto-scaling enables a
Kubernetes cluster to automatically increase or decrease the number of
working nodes in response to changes in resource demand. In this section we
will explore how you can use auto-scaling in your Kubernetes cluster.

.. _k8s-auto-scaling-enable:

*********************
Enabling auto scaling
*********************

To enable cluster auto-scaling, the labels below must be defined at
cluster creation time:

* ``auto_scaling_enabled=true``
* ``min_node_count=${minimum}``
* ``max_node_count=${maximum}``

This enables the initial values for auto scaling for all worker nodegroups,
to change these min and max values see :ref:`autoscaling-modifying-minmax`.

.. note::

   Cluster auto-scaling only scales worker nodes. Control plane
   nodes are not subject to auto-scaling.

.. tabs::

   .. tab:: Command Line

      Create cluster with auto-scaling in the command line.

      .. code-block:: console

        openstack coe cluster create my-cluster \
        --cluster-template kubernetes-v1.28.9-20240416 \
        --master-count=3 \
        --node-count=1 \
        --merge-labels \
        --labels auto_scaling_enabled=true,min_node_count=1,max_node_count=10


   .. tab:: Web UI

      Create cluster with auto-scaling in the web dashboard.

      .. image:: _containers_assets/k8s-auto-scaling-web-ui.png


.. note::

   Auto-scaling does not use the current CPU and memory usage as metrics to
   resize the cluster, but rather looks for Pending pods that cannot be
   scheduled and uses the CPU and memory reservation (resource requests) in
   the pod specification to determine the required number of worker nodes for
   each nodegroup.


The value for ``min_node_count`` **must** be greater than zero. The value for
``max_node_count`` must be greater than the value for ``min_node_count`` for
autoscaling to be enabled. If they are set to the same value, no autoscaling
will take place for that nodegroup.

When autoscaling is enabled, the value for ``min_node_count`` overrides the
``--node-count`` argument.

.. note::

   When auto-scaling is enabled, the value displayed for **node count** in the
   dashboard and command line may not reflect the actual number of worker nodes
   if the auto-scaler has made changes.

   This is a bug and we are working to address this soon.

The auto-scaling feature requires the use of resource `requests` for CPU and
memory in the pod specification. The following pod specification
illustrates the use of resource requests:

.. code-block:: yaml
  :emphasize-lines: 9,10,11,12

  apiVersion: v1
  kind: Pod
  metadata:
    name: webserver
  spec:
    containers:
    - name: webserver-ctr
      image: nginx
      resources:
        requests:
          memory: "128Mi"
          cpu: "0.5"

The conditions that trigger a cluster resize are explained below:

* **Scale out**: a worker node is added to a nodegroup when the Kubernetes
    scheduler is unable to assign a pod to any existing worker node due to
    insufficient capacity. The nodegroup chosen to expand is determined by
    the `least-waste` algorithm.
* **Scale in**: a worker node is removed from the cluster when the cluster
    resource usage drops below the defined threshold (by default 50%) for a
    period of time (by default 10 minutes).

**********************
Auto scaling in action
**********************

The following example assumes:

* You have created a Catalyst Cloud Kubernetes Service cluster as demonstrated
  :ref:`earlier <k8s-auto-scaling-enable>`.
* You are authenticated as a user with one of the :ref:`Kubernetes RBAC roles
  <k8s-rbac-roles>` which allow you to create resources on a
  cluster.


First, create a file called ``scalingdeployment.yaml`` with the following
content.

.. note::

    We use the ``nginx`` image below to highlight that it's not current usage
    of CPU or memory but the resource requests that triggers node
    auto-scaling.

    ie. More website visits will not trigger the scaling, but changing
    replicas of a deployment, or adding deployments may.


.. code-block:: yaml

    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      creationTimestamp: null
      labels:
        app: scalingdeployment
      name: scalingdeployment
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: scalingdeployment
      strategy: {}
      template:
        metadata:
          creationTimestamp: null
          labels:
            app: scalingdeployment
        spec:
          containers:
          - image: nginx
            name: webserver
            resources:
              limits:
                memory: 256Mi
              requests:
                cpu: "1"
                memory: 128Mi

Now apply this deployment to your cluster.

.. code-block:: console

   $ kubectl apply -f scalingdeployment.yaml

   deployment.apps/scalingdeployment created

You should now have a single ``Pod`` running from the ``scalingdeployment``
deployment.

.. code-block:: console

  $ kubectl get pods
  NAME                                READY   STATUS    RESTARTS   AGE
  scalingdeployment-cb47cf9fc-nsghc   1/1     Running   0          6s


Scaling up nodes
^^^^^^^^^^^^^^^^

Next, let's scale this deployment up a bit. Increase ``scalingdeployment``
to ten replicas to see what happens:


.. code-block:: console

   $ kubectl scale --replicas=10 deployment/scalingdeployment
   deployment.apps/scalingdeployment scaled


Now we watch the cluster nodes.

.. code-block:: console

    $ kubectl get nodes -w
    NAME                                             STATUS   ROLES           AGE     VERSION
    cluster-rdwcodlwtmuf-control-plane-b4jgx          Ready    control-plane   4d23h   v1.32.1
    cluster-rdwcodlwtmuf-default-worker-ghb8h-fwgmx   Ready    <none>          3d22h   v1.32.1


After a few minutes you should start to see nodes added to the cluster.

.. code-block:: console

    $ kubectl get nodes -w

    NAME                                             STATUS   ROLES           AGE     VERSION
    cluster-rdwcodlwtmuf-control-plane-b4jgx          Ready    control-plane   4d23h   v1.32.1
    cluster-rdwcodlwtmuf-default-worker-ghb8h-4g6q2   Ready    <none>          8m12s   v1.32.1
    cluster-rdwcodlwtmuf-default-worker-ghb8h-f7kq5   Ready    <none>          8m12s   v1.32.1
    cluster-rdwcodlwtmuf-default-worker-ghb8h-fjtkh   Ready    <none>          8m9s    v1.32.1
    cluster-rdwcodlwtmuf-default-worker-ghb8h-fwgmx   Ready    <none>          3d22h   v1.32.1
    cluster-rdwcodlwtmuf-default-worker-ghb8h-srtqj   Ready    <none>          8m10s   v1.32.1




Scaling down nodes
^^^^^^^^^^^^^^^^^^

As you might expect, auto-scaling also works in the other direction too.
Specifically, it will scale the number of nodes back down again when they are
no longer needed by pods for a period of time.

Continuing with the previous example, let's scale the deployment back down
to one and see what happens.


.. code-block:: console

   kubectl scale deployment/scalingdeployment --replicas=1
   deployment.apps/scalingdeployment scaled


.. note::

  The Cluster Autoscaler will apply a taint
  ``DeletionCandidateOfClusterAutoscaler`` to nodes marked for deletion.

  Unless pods explicitly tolerate this taint, the scheduler will avoid
  scheduling new pods to these nodes.


After ten minutes, the candidate nodes will be cordoned, drained and removed from the cluster.

.. code-block:: console

  $ kubectl get nodes
  NAME                                             STATUS   ROLES           AGE     VERSION
  cluster-rdwcodlwtmuf-control-plane-b4jgx          Ready    control-plane   4d23h   v1.32.1
  cluster-rdwcodlwtmuf-default-worker-ghb8h-fwgmx   Ready    <none>          3d22h   v1.32.1



.. _autoscaling-modifying-minmax:

*********************************************
Modifying the Minimum and Maximum node counts
*********************************************

A :ref:`recent release of CCKS <releasenotes-2025-06-16-ccks>` has enabled a
new feature where the minimum and maximum node counts can be modified for a
running cluster.

When creating a cluster or nodegroup, it is typical to provide these values as
labels and the Cluster labels are used by default.

However, there is also a field (or property) on the NodeGroup resource called
``min_node_count`` and ``max_node_count``. These can be updated after
creation time and are used preferentially over labels if they are set.

So, to update the autoscaling values, we should update the fields
``min_node_count`` and ``max_node_count``:


.. tabs::

   .. tab:: Command Line

      Set existing cluster `min_node_count` and `max_node_count` fields in the
      command line.

      .. code-block:: console

        openstack coe nodegroup update my-cluster default-worker replace min_node_count=3 max_node_count=15


   .. tab:: Web UI

      This action cannot be performed in the Web UI currently.

These fields can also be set on a non-default nodegroup in Terraform either at
creation time or on existing resources without triggering replacement of the
nodegroup.


*******
Summary
*******

Auto-scaling is a versatile feature for managing demand on cluster resources.
It enables your Kubernetes cluster to scale up or down when needed in
response to changes in workload. It ensures that your application can cope
with increased demand from deployments, and that you only pay for the
resources you need.
