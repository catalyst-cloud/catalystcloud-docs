###################
Cluster Autoscaling
###################

************
Introduction
************

The Kubernetes service on the Catalyst Cloud has an optional feature called
``cluster auto-scaling`` capable of dynamically increasing or reducing the
number of worker nodes, according their current resource allocation.

.. note::

   Auto-scaling does not use the current CPU and memory usage as metrics to
   resize the cluster, but rather the CPU and memory reservation
   (resource requests) in the pod specification to determine if the
   capacity allocated to a worker node.

In order to enable this functionality the labels below must be defined at
 cluster creation time (with minimum and maximum node count be adjusted
 accordingly):

* ``auto_scaling_enabled=true``
* ``min_node_count=${minimum}``
* ``max_node_count=${maximum}``

The minimum number of nodes must be greater than zero and lower than the
maximum. The maximum number of nodes must be greater than the minimum.

The auto-scaling feature requires the use of resource requests for CPU and
memory in the pod specification. The following deployment template illustrates
the use of resource requests:

.. code-block:: yaml

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

* **Scale out**: a worker node is added to the cluster when the Kubernetes
  scheduler is unable to allocate a pod to any existing worker node due to
  insufficient capacity.
* **Scale in**: a worker node is removed from the cluster when the cluster
  resource usage drops below the defined threshold (by default 50%) for a
  period of time.

*****************
A working example
*****************

Let's see how this works in practice by launching a new cluster that has
cluster-autoscaling enabled.

Preparation
===========

The first thing we need to do is get a list of the current labels associated
with a template we wish to deploy from. To do this run the following command.

.. code-block:: bash

    $ openstack coe cluster template show <template_name> -c labels -f yaml
    labels:
    cloud_provider_enabled: 'true'
    cloud_provider_tag: 1.14.0-catalyst
    container_infra_prefix: docker.io/catalystcloud/
    heat_container_agent_tag: stein-dev
    ingress_controller: octavia
    kube_tag: v1.12.7
    octavia_ingress_controller_tag: 1.14.0-catalyst

.. note::

    When adding or altering a label it is necessary, at the current time, to
    supply all of the other labels that are present in the template.

We now need to convert the list of labels obtained in the previous step, to a
comma separated list of key value pairs that include
``auto_scaling_enabled``, ``,min_node_count`` and ``max_node_count``

.. code-block:: console

  auto_scaling_enabled=true,min_node_count=1,max_node_count=2,cloud_provider_enabled=true,cloud_provider_tag=1.14.0-catalyst,... <output truncated>

Cluster creation
================

These are then passed as the label parameter to our cluster create command as
shown here.

.. code-block:: bash

  $ openstack coe cluster create my-cluster \
  --cluster-template kubernetes-v1.12.7-prod-20190403 \
  --keypair mykey \
  --master-count 3 \
  --node-count 3 \
  --labels auto_scaling_enabled=true,min_node_count=1,max_node_count=2,<existing-labels>

Tuning cluster-autoscaler parameters
====================================

There are several parameters that could change the auto-scaling behaviour,
such as:

* ``scale-down-utilization-threshold``  This is the Node utilization level,
  which is defined as the sum of requested resources divided by capacity,
  below which a node can be considered for scale down. By default this is
  **0.5**.
* ``scale-down-unneeded-time``  This is how long a node should be unneeded
  before it is eligible to be scaled down.By default this is **10 minutes**.

To change the scale down parameters we need to edit the cluster-autoscaler's
current deployment settings. We can do this using ``kubectl``.

.. code-block:: bash

  kubectl -n kube-system edit deployment cluster-autoscaler

This will open the corresponding YAML file in an editor. Locate the ``command``
section as shown below.

.. code-block:: bash

    spec:
      containers:
      - command:
        - ./cluster-autoscaler
        - --alsologtostderr
        - --cloud-provider=magnum
        - --cluster-name=cad28c31-cf1c-40a7-b8c8-b9fff91a1113
        - --cloud-config=/config/cloud-config
        - --nodes=1:4:default-worker
        - --scale-down-unneeded-time=10m
        - --scale-down-delay-after-failure=3m
        - --scale-down-delay-after-add=10m
        image: docker.io/catalystcloud/cluster-autoscaler:v1.0

If we wanted to change an existing vlue, simply edit it in place. If you need
to override one of the default values that may not display be default, add it
above the ``image:`` line making sure to match the indenting and formatting
exactly.

In the example below we have changed the following:

* The ``scale-down-unneeded-time`` parameter has been reduced to 8 minutes.
* The ``scale-down-utilization-threshold`` has been added in, with a value of
  0.4 (40%).

.. code-block:: bash

    spec:
      containers:
      - command:
        - ./cluster-autoscaler
        - --alsologtostderr
        - --cloud-provider=magnum
        - --cluster-name=cad28c31-cf1c-40a7-b8c8-b9fff91a1113
        - --cloud-config=/config/cloud-config
        - --nodes=1:4:default-worker
        - --scale-down-unneeded-time=8m
        - --scale-down-delay-after-failure=3m
        - --scale-down-delay-after-add=10m
        - --scale-down-utilization-threshold=0.4
        image: docker.io/catalystcloud/cluster-autoscaler:v1.0

Once the required changes have been made save the file and exit. This will
cause the deployment to create a new ``cluster-autoscaler pod`` and once it is
``RUNNING`` it will remove the original one .

For more detailed information about the Cluster Autoscaler please take a look
at the `FAQ`_ .

.. _`FAQ`: https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md
