########
Appendix
########

.. _k8s-cluster-labels:

**************
Cluster Labels
**************

.. TODO(travis): Document machine_count_min and machine_count_max when these are supported

Kubernetes clusters can have one or more **labels** applied to them,
to control how your cluster is configured, and what gets installed into it.

Labels can only be applied to a cluster when it is created.

.. _k8s-cluster-labels-table:

Available cluster labels
========================

.. list-table::
   :widths: 35 15 10 20 30
   :header-rows: 1

   * - Label
     - Type
     - Default Value
     - Accepted Values / Examples
     - Description
   * - ``master_lb_floating_ip_enabled``
     - Boolean
     - ``false``
     - ``true`` or ``false``
     - Assign a floating IP to the Kubernetes API load balancer,
       to allow access to the Kubernetes API via the public Internet.
   * - ``api_master_lb_allowed_cidrs``
     - IPv4/IPv6 CIDR
     - ``0.0.0.0/0``
     - ``192.0.2.1/32``
     - Specify a set of CIDR ranges that should be allowed to access the Kubernetes API.

       Multiple values can be defined (see :ref:`kubernetes-labels-multiple-values`).
   * - ``extra_network_name``
     - String
     - ``null``
     - Network Name
     - Optional additional network to attach to cluster worker nodes.

       Useful for allowing access to external networks from the workers.
   * - ``csi_cinder_reclaim_policy``
     - Enumeration
     - ``Retain``
     - ``Retain`` or ``Delete``
     - Policy for reclaiming dynamically created persistent volumes.

       For more information, see :ref:`kubernetes-persistent-volume-retention`.
   * - ``csi_cinder_fstype``
     - Enumeration
     - ``ext4``
     - ``ext4``
     - Filesystem type for persistent volumes.
   * - ``csi_cinder_allow_volume_expansion``
     - Boolean
     - ``true``
     - ``true`` or ``false``
     - Allows for expansion of volumes by editing the corresponding
       ``PersistentVolumeClaim`` object.
   * - ``kube_dashboard_enabled``
     - Boolean
     - ``true``
     - ``true`` or ``false``
     - Install the Kubernetes Dashboard into the cluster.
   * - ``boot_volume_size``
     - Integer
     - ``20``
     - Greater than 0
     - The size (in GiB) to create the boot volume for Control Plane and Worker nodes.

       Currently, this is the only disk attached to nodes.
   * - ``boot_volume_type``
     - Enumeration
     - ``b1.sr-r3-nvme-1000``
     - See :ref:`block-storage-volume-tiers` for a list of volume type names
     - The Block Storage volume type name to use for the boot volume.
   * - ``auto_scaling_enabled``
     - Boolean
     - ``false``
     - ``true`` or ``false``
     - Enable Worker node auto scaling in the cluster.

       When set to ``true``, ``min_node_count`` and ``max_node_count`` must also be set.
   * - ``min_node_count``
     - Integer
     - ``null``
     - Greater than 0
     - Minimum number of Worker nodes for auto scaling.

       This value is required if ``auto_scaling_enabled`` is ``true``.
   * - ``max_node_count``
     - Integer
     - ``null``
     - Greater than ``min_node_count``
     - Maximum number of Worker nodes to scale out to, if auto scaling is enabled.

       This value is required if ``auto_scaling_enabled`` is ``true``.
   * - ``auto_healing_enabled``
     - Boolean
     - ``true``
     - ``true`` or ``false``
     - Enable auto-healing on control plane and worker nodes.

       With auto-healing enabled, if nodes become ``NotReady`` for an extended duration they will be
       replaced.

       Note: Control plane machines will only be remediated one at a time. Worker nodes will not be remediated
       if 40% are considered unhealthy, preventing some cascading failures.

   * - ``keystone_auth_enabled``
     - Boolean
     - ``true``
     - ``true`` or ``false``
     - With this option enabled, a deployment will be installed into your cluster allowing the use
       of Role-Based Access Control with Catalyst Cloud's authentication system.

       For more information see :ref:`k8s-rbac-roles`.

       With this option disabled, the :ref:`admin kubeconfig<retrieving-admin-kubeconfig>` is still available as well as `Kubernetes API Access Control <https://kubernetes.io/docs/reference/access-authn-authz/>`_.


Applying labels when creating a cluster
=======================================

Labels may be set on a cluster at **creation time** either via the API or in the dashboard.

.. tabs::

   .. group-tab:: CLI

      When running ``openstack coe cluster create``, set the ``--labels`` option
      to define custom labels.

      Each label should be provided in a comma-separated list of key-value pairs.

      .. note::

        Make sure to also define the ``--merge-labels`` option
        when defining custom labels.

      Here is an example of setting a few custom labels:

      .. code-block:: bash

         openstack coe cluster create my-cluster-name \
         --cluster-template kubernetes-v1.28.9-20240416 \
         ...
         --merge-labels \
         --labels csi_cinder_reclaim_policy=Retain,kube_dashboard_enabled=true,master_lb_floating_ip_enabled=false

      .. note::

        It is not possible to modify labels on a cluster in-place after it has been created.

   .. group-tab:: Dashboard

      Custom labels can be defined using the **Labels -> Additional Labels** field
      in the **Advanced** tab of the **Create New Cluster** window.

      .. image:: _containers_assets/k8s-override-cluster-labels.png

      .. note::

        It is not possible to modify labels on a cluster in-place after it has been created.

   .. group-tab:: Terraform

      When defining the `openstack_containerinfra_cluster_v1`_ resource,
      use the ``labels`` attribute to define a label key-value mapping.

      .. note::

        Make sure to also set the ``merge_labels`` attribute to ``true``
        when defining custom labels.

      Here is an example of setting a few custom labels:

      .. code-block:: terraform

        resource "openstack_containerinfra_cluster_v1" "my-cluster-name" {
          name                = "my-cluster-name"
          cluster_template_id = "b9a45c5c-cd03-4958-82aa-b80bf93cb922"
          ...
          merge_labels        = true
          labels = {
            csi_cinder_reclaim_policy     = "Retain"
            kube_dashboard_enabled        = "true"
            master_lb_floating_ip_enabled = "false"
          }
        }

      .. warning::

        It is not possible to modify labels on a cluster in-place after it has been created.

        If the labels are modified in Terraform **after** a cluster has been created,
        **the cluster will be re-created**, so be careful not to modify them unintentionally.

      .. _`openstack_containerinfra_cluster_v1`: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/containerinfra_cluster_v1

.. _kubernetes-labels-multiple-values:

Specifying multiple label values
================================

Some labels can have multiple values set for them.

.. tabs::

   .. group-tab:: CLI

      Using the CLI, you can specify multiple copies of the label key-value pair,
      each with their own unique value.

      For example, to define multiple CIDRs for ``api_master_lb_allowed_cidrs``:

      .. code-block:: bash

        openstack coe cluster create my-cluster-name \
        --cluster-template kubernetes-v1.28.9-20240416 \
        ...
        --merge-labels \
        --labels master_lb_floating_ip_enabled=true,api_master_lb_allowed_cidrs=192.0.2.1/32,api_master_lb_allowed_cidrs=192.0.2.2/32

   .. group-tab:: Dashboard

    .. note::

      Specifying multiple values for labels is currently not supported by the dashboard.

      When specifying labels using the **Labels -> Additional Labels** field
      in the **Advanced** tab, if multiple key-value pairs with the same label
      are defined, only the **first defined value** will be used.

      If you would like to specify multiple label values when creating
      a cluster, please create the cluster using the CLI or Terraform.

   .. group-tab:: Terraform

      When defining the `openstack_containerinfra_cluster_v1`_ resource,
      define the label value as a comma-separated string, with all values listed.

      For example, to define multiple CIDRs for ``api_master_lb_allowed_cidrs``:

      .. code-block:: terraform

        resource "openstack_containerinfra_cluster_v1" "my-cluster-name" {
          name                = "my-cluster-name"
          cluster_template_id = "b9a45c5c-cd03-4958-82aa-b80bf93cb922"
          ...
          merge_labels        = true
          labels = {
            master_lb_floating_ip_enabled = "true"
            api_master_lb_allowed_cidrs   = "192.0.2.1/32,192.0.2.2/32"
          }
        }

      .. _`openstack_containerinfra_cluster_v1`: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/containerinfra_cluster_v1

.. _k8s-kubelet-reserved:

*******************
Reserved Resources
*******************

For Kubernetes to function, the system daemons consume some vCPU time and
memory. When Kubernetes schedules pods, it will only allow them to be placed
on nodes that have available capacity.

A fully packed node needs to take into account the resource consumption of the
system daemons as well as the pod limits. For this reason, we reserve some
resources (both vCPU and memory) for the system daemons.

When choosing node flavors and viewing node capacity in Kubernetes you will
notice a difference between the allocated and reported available capacity.

We reserve vCPU and memory as a reducing percentage the more resources the
node has. Example node sizes and the current kubeReserved algorithm are
provided in the table below to give approximate values for available
capacity. These are subject to change, consult your node details within your
cluster for the actual available capacity to the Kubernetes scheduler.

Reserved vCPU capacity values for select example compute flavours:

.. list-table::
   :header-rows: 1

   * - Example Flavor name
     - vCPU in Flavor (cores)
     - Reserved vCPU (millicore)
     - Kubernetes Available vCPU (millicore)
     - Percentage reserved
   * - c1.c1r2
     - 1
     - 60 millicore
     - 940 millicore
     - 6%
   * - c1.c2r2
     - 2
     - 70 millicore
     - 1930 millicore
     - 3.5%
   * - c1.c4r4
     - 4
     - 80 millicore
     - 3920 millicore
     - 2%
   * - c1.c8r8
     - 8
     - 90 millicore
     - 7910 millicore
     - 1.13%
   * - c1.c16r16
     - 16
     - 110 millicore
     - 15890 millicore
     - 0.68%
   * - c1.c32r16
     - 32
     - 150 millicore
     - 31850 millicore
     - 0.47%

And the corresponding reserved memory values for the same example flavours:

.. list-table::
   :header-rows: 1

   * - Example Flavor name
     - Memory in Flavor (MiB)
     - Memory Reserved (MiB)
     - Kubernetes Available Memory (MiB)
     - Percentage reserved
   * - c1.c1r2
     - 2048
     - 512
     - 1536
     - 25%
   * - c1.c2r2
     - 2048
     - 512
     - 1536
     - 25%
   * - c1.c4r4
     - 4096
     - 1024
     - 3072
     - 25%
   * - c1.c8r8
     - 8192
     - 1844
     - 6348
     - 22.5%
   * - c1.c16r16
     - 16384
     - 2664
     - 13720
     - 16.25%
   * - c1.c32r32
     - 32768
     - 3648
     - 29120
     - 11.13%
