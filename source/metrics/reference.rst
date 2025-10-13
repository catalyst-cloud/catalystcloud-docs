.. _metrics-reference:

#########################
Resource/Metric Reference
#########################

Documented below are all resource types and metrics
available on the Catalyst Cloud Metrics Service.

.. contents::
    :local:
    :depth: 2
    :backlinks: none

.. _metrics-instances:

*********
Instances
*********

:ref:`Compute <compute>` instances are tracked using the ``instance`` resource type.

Attributes
==========

The following resource attributes are available for instances.

.. list-table::
   :width: 75%
   :widths: 20 20 60
   :header-rows: 1

   * - Attribute
     - Type
     - Description
   * - ``display_name``
     - ``string``
     - The name of the instance.
   * - ``flavor_id``
     - ``string``
     - The ID of the :ref:`flavour <instance-types>` the instance is currently running as.
   * - ``flavor_name``
     - ``string``
     - The name of the :ref:`flavour <instance-types>` the instance is currently running as.
   * - ``image_ref``
     - ``string`` | ``null``
     - The ID of the image the instance was originally launched from,
       for image-backed instances.

       **NOTE**: Not set for volume-backed instances.
   * - ``server_group``
     - ``string`` | ``null``
     - The server group the instance belongs to, if it is part of one.

       **NOTE:** Requires the ``metering.server_group`` metadata attribute
       to be defined on the instance. For more information, see :ref:`anti-affinity`.
   * - ``os_type``
     - ``string`` | ``null``
     - The type of operating system the instance is running.
   * - ``os_distro``
     - ``string`` | ``null``
     - The operating system distribution the instance is running.

Metrics
=======

The following metrics are available for instance resources.

.. list-table::
   :widths: 23 30 14 13 10 10
   :header-rows: 1

   * - Metric
     - Description
     - Unit
     - :ref:`Collection Type <metrics-collection-types>`
     - :ref:`Metric Type <metrics-metric-types>`
     - :ref:`Frequency <metrics-frequency>`
   * - ``instance``
     - The status of the instance.
     - ``instance``
     - Notification, Polling [1]_
     - Status
     - Long
   * - ``vcpus``
     - The number of vCPUs allocated to an instance.
     - ``vcpu``
     - Notification, Polling [2]_
     - Gauge
     - High
   * - ``memory``
     - The amount of memory allocated to an instance.
     - ``MiB`` (mebibytes)
     - Notification, Polling [2]_
     - Gauge
     - High
   * - ``disk.root.size``
     - The size of the root disk for an image-backed instance. [5]_
     - ``GiB`` (gibibytes)
     - Notification, Polling [2]_
     - Gauge
     - High
   * - ``compute.instance.booting.time``
     - The amount of time it took for the
       instance to launch after being created.
     - ``sec`` (seconds)
     - Notification [3]_
     - Gauge
     - High
   * - ``cpu``
     - The amount of CPU time consumed by an instance across all vCPUs.
     - ``ns`` (nanoseconds)
     - Polling [4]_
     - Cumulative
     - High
   * - ``memory.available``
     - The amount of usable memory available within the instance. [6]_
     - ``MiB`` (mebibytes)
     - Polling [4]_
     - Gauge
     - High
   * - ``memory.usage``
     - The amount of memory the instance is currently using. [6]_
     - ``MiB`` (mebibytes)
     - Polling [4]_
     - Gauge
     - High
   * - ``memory.swap.in``
     - The amount of data swapped into memory over a given period. [6]_
     - ``MiB`` (mebibytes)
     - Polling [4]_
     - Cumulative
     - High
   * - ``memory.swap.out``
     - The amount of data swapped out of memory over a given period. [6]_
     - ``MiB`` (mebibytes)
     - Polling [4]_
     - Cumulative
     - High

.. rubric:: **Footnotes**

.. [1]
  Polling only available when an instance
  is provisioned to a hypervisor (running, paused,
  suspended, shut-off). When an instance is shelved,
  measures are only published from notifications.

.. [2]
  Polling only available when an instance is running.
  When an instance is shut-off or shelved, measures are
  only published from notifications.

.. [3] Measure published only when an instance is created.

.. [4] Measures published only when an instance is running.

.. [5]
  Does not apply to volume-backed instances.
  To get the size of the root disk for volume-backed
  instances, use the ``volume.size`` metric instead.

.. [6]
  Windows instances require additional drivers to be installed
  for this metric to work. For more information, see
  :ref:`metrics-tutorials-memory-usage-metrics-on-windows`.

Status Values
=============

Here is a table mapping ``instance`` metric values to their corresponding instance states.

.. list-table::
   :width: 20%
   :header-rows: 1

   * - Value
     - Status
   * - ``0``
     - ``BUILDING``
   * - ``1``
     - ``ACTIVE``
   * - ``2``
     - ``PAUSED``
   * - ``3``
     - ``SUSPENDED``
   * - ``4``
     - ``STOPPED``
   * - ``5``
     - ``RESCUED``
   * - ``6``
     - ``RESIZED``
   * - ``7``
     - ``SOFT_DELETED``
   * - ``8``
     - ``DELETED``
   * - ``9``
     - ``ERROR``
   * - ``10``
     - ``SHELVED``
   * - ``11``
     - ``SHELVED_OFFLOADED``
   * - ``12``
     - ``ERROR``

*******
Volumes
*******

:ref:`Block Storage <block-storage-intro>` volumes are tracked using the ``volume`` resource type.

Attributes
==========

The following resource attributes are available for volumes.

.. list-table::
   :width: 75%
   :widths: 20 20 60
   :header-rows: 1

   * - Attribute
     - Type
     - Description
   * - ``display_name``
     - ``string`` | ``null``
     - The name of the volume, if one is set.
   * - ``volume_type``
     - ``string``
     - The :ref:`volume type <block-storage-volume-tiers>` this volume uses.

Metrics
=======

The following metrics are available for volume resources.

.. list-table::
   :widths: 23 30 15 15 10 10
   :header-rows: 1

   * - Metric
     - Description
     - Unit
     - :ref:`Collection Type <metrics-collection-types>`
     - :ref:`Metric Type <metrics-metric-types>`
     - :ref:`Frequency <metrics-frequency>`
   * - ``volume.size``
     - The size of the volume.
     - ``GiB`` (gibibytes)
     - Polling
     - Gauge
     - Medium

****************
Volume Snapshots
****************

Block storage :ref:`volume snapshots <using_snapshots>` are tracked using the ``volume_snapshot`` resource type.

Attributes
==========

The following resource attributes are available for volume snapshots.

.. list-table::
   :width: 75%
   :widths: 20 20 60
   :header-rows: 1

   * - Attribute
     - Type
     - Description
   * - ``display_name``
     - ``string`` | ``null``
     - The name of the volume snapshot, if one is set.
   * - ``volume_id``
     - ``string``
     - The ID of the volume this snapshot was created from.

Metrics
========

The following metrics are available for volume snapshot resources.

.. list-table::
   :widths: 23 30 15 15 10 10
   :header-rows: 1

   * - Metric
     - Description
     - Unit
     - :ref:`Collection Type <metrics-collection-types>`
     - :ref:`Metric Type <metrics-metric-types>`
     - :ref:`Frequency <metrics-frequency>`
   * - ``volume.snapshot.size``
     - The size of the volume snapshot.
     - ``GiB`` (gibibytes)
     - Notification, Polling
     - Gauge
     - Medium

**************
Volume Backups
**************

Block storage :ref:`volume backups <backups>` are tracked using the ``volume_backup`` resource type.

Attributes
==========

The following resource attributes are available for volume backups.

.. list-table::
   :width: 75%
   :widths: 20 20 60
   :header-rows: 1

   * - Attribute
     - Type
     - Description
   * - ``display_name``
     - ``string`` | ``null``
     - The name of the volume backup, if one is set.
   * - ``volume_id``
     - ``string``
     - The ID of the volume this backup was created from.
   * - ``snapshot_id``
     - ``string`` | ``null``
     - The ID of the volume snapshot that was backed up,
       if this backup was created from a snapshot.

Metrics
=======

The following metrics are available for volume backup resources.

.. list-table::
   :widths: 23 30 15 15 10 10
   :header-rows: 1

   * - Metric
     - Description
     - Unit
     - :ref:`Collection Type <metrics-collection-types>`
     - :ref:`Metric Type <metrics-metric-types>`
     - :ref:`Frequency <metrics-frequency>`
   * - ``volume.backup.size``
     - The size of the volume backup.
     - ``GiB`` (gibibytes)
     - Notification, Polling
     - Gauge
     - Medium

******
Images
******

:ref:`Images <images>` are tracked using the ``image`` resource type.

Attributes
==========

The following resource attributes are available for images.

.. list-table::
   :width: 75%
   :widths: 20 20 60
   :header-rows: 1

   * - Attribute
     - Type
     - Description
   * - ``name``
     - ``string``
     - The name of the image.
   * - ``container_format``
     - ``string`` | ``null``
     - The container format of the image, if configured.
   * - ``disk_format``
     - ``string`` | ``null``
     - The disk format of the image, if configured.

Metrics
=======

The following metrics are available for image resources.

.. list-table::
   :widths: 23 30 15 15 10 10
   :header-rows: 1

   * - Metric
     - Description
     - Unit
     - :ref:`Collection Type <metrics-collection-types>`
     - :ref:`Metric Type <metrics-metric-types>`
     - :ref:`Frequency <metrics-frequency>`
   * - ``image.size``
     - The size of the image.
     - ``B`` (bytes)
     - Notification, Polling
     - Gauge
     - Medium

********
Networks
********

:ref:`Networks <networks>` are tracked using the ``network`` resource type.

Attributes
==========

The following resource attributes are available for networks.

.. list-table::
   :width: 75%
   :widths: 20 20 60
   :header-rows: 1

   * - Attribute
     - Type
     - Description
   * - ``name``
     - ``string``
     - The name of the network.

Metrics
=======

The following metrics are available for network resources.

.. list-table::
   :widths: 23 30 15 15 10 10
   :header-rows: 1

   * - Metric
     - Description
     - Unit
     - :ref:`Collection Type <metrics-collection-types>`
     - :ref:`Metric Type <metrics-metric-types>`
     - :ref:`Frequency <metrics-frequency>`
   * - ``network``
     - The status of the network.
     - ``network``
     - Notification, Polling
     - Status
     - Long

Status Values
=============

Here is a table mapping ``network`` metric values to their corresponding network states.

.. list-table::
   :width: 20%
   :header-rows: 1

   * - Value
     - Status
   * - ``0``
     - ``BUILD``
   * - ``1``
     - ``ACTIVE``
   * - ``2``
     - ``DOWN``
   * - ``3``
     - ``ERROR``

*******
Routers
*******

Routers are tracked using the ``router`` resource type.

Attributes
==========

The following resource attributes are available for routers.

.. list-table::
   :width: 75%
   :widths: 20 20 60
   :header-rows: 1

   * - Attribute
     - Type
     - Description
   * - ``name``
     - ``string``
     - The name of the router.

Metrics
=======

The following metrics are available for router resources.

.. list-table::
   :widths: 28 30 15 15 10 10
   :header-rows: 1

   * - Metric
     - Description
     - Unit
     - :ref:`Collection Type <metrics-collection-types>`
     - :ref:`Metric Type <metrics-metric-types>`
     - :ref:`Frequency <metrics-frequency>`
   * - ``router``
     - The status of the router.
     - ``router``
     - Notification, Polling
     - Status
     - Long
   * - ``router.traffic.inbound.interregion``
     - Inbound inter-region network traffic.
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``router.traffic.inbound.reannz``
     - Inbound REANNZ Cloud Connect network traffic
       (``nz-hlz-1`` only).
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``router.traffic.inbound.internet``
     - Inbound Internet network traffic.
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``router.traffic.outbound.interregion``
     - Outbound inter-region network traffic.
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``router.traffic.outbound.reannz``
     - Outbound REANNZ Cloud Connect network traffic
       (``nz-hlz-1`` only).
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``router.traffic.outbound.internet``
     - Outbound Internet network traffic.
     - ``B`` (bytes)
     - Push
     - Delta
     - High

Status Values
=============

Here is a table mapping ``router`` metric values to their corresponding router states.

.. list-table::
   :width: 20%
   :header-rows: 1

   * - Value
     - Status
   * - ``0``
     - ``ALLOCATING``
   * - ``1``
     - ``ACTIVE``
   * - ``2``
     - ``DOWN``
   * - ``3``
     - ``ERROR``

************
Floating IPs
************

Floating IPs are tracked using the ``floating_ip`` resource type.

Attributes
==========

The following resource attributes are available for floating IPs.

.. list-table::
   :width: 75%
   :widths: 20 20 60
   :header-rows: 1

   * - Attribute
     - Type
     - Description
   * - ``floating_ip_address``
     - ``string``
     - The allocated floating IP address.

Metrics
=======

The following metrics are available for floating IP resources.

.. list-table::
   :widths: 32 30 15 15 10 10
   :header-rows: 1

   * - Metric
     - Description
     - Unit
     - :ref:`Collection Type <metrics-collection-types>`
     - :ref:`Metric Type <metrics-metric-types>`
     - :ref:`Frequency <metrics-frequency>`
   * - ``ip.floating``
     - The status of the floating IP.
     - ``ip``
     - Notification, Polling
     - Status
     - Long
   * - ``ip.floating.traffic.inbound.interregion``
     - Inbound inter-region network traffic.
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``ip.floating.traffic.inbound.reannz``
     - Inbound REANNZ Cloud Connect network traffic
       (``nz-hlz-1`` only).
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``ip.floating.traffic.inbound.internet``
     - Inbound Internet network traffic.
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``ip.floating.traffic.outbound.interregion``
     - Outbound inter-region network traffic.
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``ip.floating.traffic.outbound.reannz``
     - Outbound REANNZ Cloud Connect network traffic
       (``nz-hlz-1`` only).
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``ip.floating.traffic.outbound.internet``
     - Outbound Internet network traffic.
     - ``B`` (bytes)
     - Push
     - Delta
     - High

Status Values
=============

Here is a table mapping ``ip.floating`` metric values to their corresponding floating IP states.

.. list-table::
   :width: 20%
   :header-rows: 1

   * - Value
     - Status
   * - ``0``
     - ``INACTIVE``
   * - ``1``
     - ``ACTIVE``
   * - ``2``
     - ``PENDING_CREATE``
   * - ``3``
     - ``DOWN``
   * - ``4``
     - ``CREATED``
   * - ``5``
     - ``PENDING_UPDATE``
   * - ``6``
     - ``PENDING_DELETE``
   * - ``7``
     - ``ERROR``

****
VPNs
****

:ref:`VPN-as-a-Service VPNs <vpn>` are tracked using the ``vpn`` resource type.

Attributes
==========

The following resource attributes are available for VPNs.

.. list-table::
   :width: 75%
   :widths: 20 20 60
   :header-rows: 1

   * - Attribute
     - Type
     - Description
   * - ``name``
     - ``string``
     - The name of the VPN.

Metrics
=======

The following metrics are available for VPN resources.

.. list-table::
   :widths: 23 30 15 15 10 10
   :header-rows: 1

   * - Metric
     - Description
     - Unit
     - :ref:`Collection Type <metrics-collection-types>`
     - :ref:`Metric Type <metrics-metric-types>`
     - :ref:`Frequency <metrics-frequency>`
   * - ``network.services.vpn``
     - The status of the VPN.
     - ``vpnservice``
     - Polling
     - Status
     - Long


Status Values
=============

Here is a table mapping ``network.services.vpn`` metric values to their corresponding VPN states.

.. list-table::
   :width: 20%
   :header-rows: 1

   * - Value
     - Status
   * - ``0``
     - ``INACTIVE``
   * - ``1``
     - ``ACTIVE``
   * - ``2``
     - ``PENDING_CREATE``
   * - ``3``
     - ``DOWN``
   * - ``4``
     - ``CREATED``
   * - ``5``
     - ``PENDING_UPDATE``
   * - ``6``
     - ``PENDING_DELETE``
   * - ``7``
     - ``ERROR``

**************
Load Balancers
**************

:ref:`Load balancers <load-balancer-intro>` are tracked using the ``loadbalancer`` resource type.

Attributes
==========

The following resource attributes are available for load balancers.

.. list-table::
   :width: 75%
   :widths: 20 20 60
   :header-rows: 1

   * - Attribute
     - Type
     - Description
   * - ``name``
     - ``string``
     - The name of the load balancer.

Metrics
=======

The following metrics are available for load balancer resources.

.. list-table::
   :widths: 30 30 15 15 10 10
   :header-rows: 1

   * - Metric
     - Description
     - Unit
     - :ref:`Collection Type <metrics-collection-types>`
     - :ref:`Metric Type <metrics-metric-types>`
     - :ref:`Frequency <metrics-frequency>`
   * - ``network.services.octavia.loadbalancer``
     - The provisioning status of the load balancer.
     - ``loadbalancer``
     - Polling
     - Status
     - Long

Status Values
=============

Here is a table mapping ``network.services.octavia.loadbalancer``
metric values to their corresponding load balancer states.

.. list-table::
   :width: 20%
   :header-rows: 1

   * - Value
     - Status
   * - ``0``
     - ``INACTIVE``
   * - ``1``
     - ``ACTIVE``
   * - ``2``
     - ``PENDING_CREATE``
   * - ``3``
     - ``DOWN``
   * - ``4``
     - ``CREATED``
   * - ``5``
     - ``PENDING_UPDATE``
   * - ``6``
     - ``PENDING_DELETE``
   * - ``7``
     - ``ERROR``

*******************
Kubernetes Clusters
*******************

:ref:`Catalyst Cloud Kubernetes Service (CCKS) <kubernetes>` clusters are tracked using the ``coe_cluster`` resource type.

Attributes
==========

The following resource attributes are available for Kubernetes clusters.

.. list-table::
   :width: 75%
   :widths: 20 20 60
   :header-rows: 1

   * - Attribute
     - Type
     - Description
   * - ``name``
     - ``string``
     - The name of the cluster.
   * - ``master_flavor``
     - ``string``
     - The name of the :ref:`flavour <instance-types>` of the control plane nodes.
   * - ``node_flavor``
     - ``string``
     - The name of the :ref:`flavour <instance-types>` of the worker nodes in the default node group.
   * - ``docker_volume_size``
     - ``number``
     - The size of the container filesystem on the cluster nodes, in gigabytes.
   * - ``coe_version``
     - ``string`` | ``null``
     - The version of Kubernetes running in the cluster, if available.
   * - ``stack_id``
     - ``string`` | ``null``
     - The prefix used to generate names for cloud resources (e.g. instances, networks)
       created by this cluster, if available.

Metrics
=======

The following metrics are available for cluster resources.

.. list-table::
   :widths: 23 30 15 15 10 10
   :header-rows: 1

   * - Metric
     - Description
     - Unit
     - :ref:`Collection Type <metrics-collection-types>`
     - :ref:`Metric Type <metrics-metric-types>`
     - :ref:`Frequency <metrics-frequency>`
   * - ``cim.coe.cluster``
     - The status of the cluster.
     - ``cluster``
     - Notification, Polling
     - Status
     - Long
   * - ``cim.coe.cluster.masters``
     - The number of control plane nodes running in the cluster.
     - ``node``
     - Notification, Polling
     - Gauge
     - Medium
   * - ``cim.coe.cluster.workers``
     - The number of worker nodes running in the cluster,
       across **all** node groups.
     - ``node``
     - Notification, Polling
     - Gauge
     - Medium

Status Values
=============

Here is a table mapping ``cim.coe.cluster`` metric values to their corresponding cluster states.

.. list-table::
   :width: 20%
   :header-rows: 1

   * - Value
     - Status
   * - ``0``
     - ``CREATE_IN_PROGRESS``
   * - ``1``
     - ``CREATE_COMPLETE``
   * - ``2``
     - ``CREATE_FAILED``
   * - ``3``
     - ``UPDATE_IN_PROGRESS``
   * - ``4``
     - ``UPDATE_FAILED``
   * - ``5``
     - ``UPDATE_COMPLETE``
   * - ``6``
     - ``DELETE_IN_PROGRESS``
   * - ``7``
     - ``DELETE_FAILED``
   * - ``8``
     - ``DELETE_COMPLETE``
   * - ``9``
     - ``RESUME_COMPLETE``
   * - ``10``
     - ``RESUME_FAILED``
   * - ``11``
     - ``RESTORE_COMPLETE``
   * - ``12``
     - ``ROLLBACK_IN_PROGRESS``
   * - ``13``
     - ``ROLLBACK_FAILED``
   * - ``14``
     - ``ROLLBACK_COMPLETE``
   * - ``15``
     - ``SNAPSHOT_COMPLETE``
   * - ``16``
     - ``CHECK_COMPLETE``
   * - ``17``
     - ``ADOPT_COMPLETE``

******************
Database Instances
******************

:ref:`Database instances <database_page>` are tracked using the ``database_instance`` resource type.

Attributes
==========

The following resource attributes are available for database instances.

.. list-table::
   :width: 75%
   :widths: 20 20 60
   :header-rows: 1

   * - Attribute
     - Type
     - Description
   * - ``name``
     - ``string``
     - The name of the database instance.
   * - ``flavor_id``
     - ``string``
     - The ID of the :ref:`flavour <instance-types>` the database instance is currently running as.
   * - ``flavor_name``
     - ``string``
     - The name of the :ref:`flavour <instance-types>` the database instance is currently running as.
   * - ``datastore_type``
     - ``string``
     - The type of database software the instance uses (e.g. ``mysql``, ``postgresql``).
   * - ``datastore_version``
     - ``string``
     - The version of the database software being used
       (e.g. ``5.7.36`` for MySQL, ``12.4`` for PostgreSQL).
   * - ``volume_type``
     - ``string`` | ``null``
     - The :ref:`volume type <block-storage-volume-tiers>`
       of the volume backing the database instance, if the backing volume exists.

Metrics
=======

The following metrics are available for database instance resources.

.. list-table::
   :widths: 23 30 15 15 10 10
   :header-rows: 1

   * - Metric
     - Description
     - Unit
     - :ref:`Collection Type <metrics-collection-types>`
     - :ref:`Metric Type <metrics-metric-types>`
     - :ref:`Frequency <metrics-frequency>`
   * - ``database.instance``
     - The status of the database instance.
     - ``instance``
     - Polling
     - Status
     - Long
   * - ``database.volume.size``
     - The size of the volume backing the database instance.
     - ``GiB`` (gibibytes)
     - Polling
     - Gauge
     - Medium

Status Values
=============

Here is a table mapping ``database.instance`` metric values to their corresponding instance states.

.. list-table::
   :width: 20%
   :header-rows: 1

   * - Value
     - Status
   * - ``0``
     - ``NEW``
   * - ``1``
     - ``ACTIVE``
   * - ``2``
     - ``BUILD``
   * - ``3``
     - ``HEALTHY``
   * - ``4``
     - ``BLOCKED``
   * - ``5``
     - ``REBOOT``
   * - ``6``
     - ``RESIZE``
   * - ``7``
     - ``UPGRADE``
   * - ``8``
     - ``RESTART_REQUIRED``
   * - ``9``
     - ``PROMOTE``
   * - ``10``
     - ``EJECT``
   * - ``11``
     - ``DETACH``
   * - ``12``
     - ``SHUTDOWN``
   * - ``13``
     - ``BACKUP``
   * - ``14``
     - ``ERROR``
   * - ``15``
     - ``RESTARTING``

.. _metrics-containers:

**********
Containers
**********

:ref:`Object Storage <object-storage>` containers are tracked using the ``swift_account`` resource type.

.. _metrics-container-resource-ids:

Resource IDs
============

For most Catalyst Cloud services, the UUID provided by the original service
can be used directly to reference the object in the Metrics Service.
Object storage containers work differently.

Since object storage containers are only known by names, the Metrics Service generates a
UUID for the resource based on the project ID and the name of the container. A reference
to the project and the container name is stored inside the resource using the
``original_resource_id`` field, in the format ``{project_id}_{container}``.

.. code-block:: console

  $ openstack metric resource show --type swift_account cc5d7d7c-c9c0-5b02-b7d1-cd6cc432358a
  +-----------------------+------------------------------------------------------------------------------+
  | Field                 | Value                                                                        |
  +-----------------------+------------------------------------------------------------------------------+
  | id                    | cc5d7d7c-c9c0-5b02-b7d1-cd6cc432358a                                         |
  | creator               | 42dcfd23b04a4006b9e2b08c0a835aeb:ceecc421f7994cc397380fae5e495179            |
  | started_at            | 2025-05-19T03:14:58.321610+00:00                                             |
  | revision_start        | 2025-05-19T03:14:58.321619+00:00                                             |
  | ended_at              | None                                                                         |
  | user_id               | None                                                                         |
  | project_id            | 9864e20f92ef47238becfe06b869d2ac                                             |
  | original_resource_id  | 9864e20f92ef47238becfe06b869d2ac_test-container                              |
  | type                  | swift_account                                                                |
  | storage_policy        | nz--o1--mr-r3                                                                |
  | revision_end          | None                                                                         |
  | metrics               | storage.containers.objects.size: f226f01f-fd2f-4ff8-9848-2fb7b4f1d7dc        |
  |                       | storage.objects.download.size.internet: 22956258-cbe1-40a8-aace-5c954995b4af |
  |                       | storage.objects.upload.size.internet: b364abff-4c95-4c2d-8d05-59ea955c2c01   |
  | created_by_user_id    | 42dcfd23b04a4006b9e2b08c0a835aeb                                             |
  | created_by_project_id | ceecc421f7994cc397380fae5e495179                                             |
  +-----------------------+------------------------------------------------------------------------------+

To find out how to get the Metrics Service resource UUID for an object storage container,
see :ref:`metrics-get-container-resource`.

If a container is deleted and later recreated under the same name, the corresponding
:ref:`resource <metrics-resources>` in the Metrics Service will be reused if it already
exists. If the resource has already been marked as "ended", it will be restored as an
active resource. If the old resource for a container has already expired, a new resource
object will be created with the same UUID.

This means that the resource UUID for a container in the Metrics Service
**always** corresponds with any container with that name within the project,
even if containers get deleted and recreated.

Attributes
==========

The following resource attributes are available for containers.

.. list-table::
   :width: 75%
   :widths: 20 20 60
   :header-rows: 1

   * - Attribute
     - Type
     - Description
   * - ``storage_policy``
     - ``string``
     - The name of the :ref:`storage policy <object-storage-storage-policies>` (replication policy)
       this container currently uses.

Metrics
=======

The following metrics are available for container resources.

.. list-table::
   :widths: 32 30 15 15 10 10
   :header-rows: 1

   * - Metric
     - Description
     - Unit
     - :ref:`Collection Type <metrics-collection-types>`
     - :ref:`Metric Type <metrics-metric-types>`
     - :ref:`Frequency <metrics-frequency>`
   * - ``storage.containers.objects.size``
     - The total amount of space being consumed by the container.
     - ``B`` (bytes)
     - Polling
     - Gauge
     - Low
   * - ``storage.objects.upload.size.local``
     - Inbound region-local object storage traffic.
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``storage.objects.upload.size.interregion``
     - Inbound inter-region object storage traffic.
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``storage.objects.upload.size.reannz``
     - Inbound REANNZ Cloud Connect object storage traffic
       (``nz-hlz-1`` only).
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``storage.objects.upload.size.internet``
     - Inbound Internet object storage traffic.
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``storage.objects.download.size.local``
     - Outbound region-local object storage traffic.
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``storage.objects.download.size.interregion``
     - Outbound inter-region object storage traffic.
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``storage.objects.download.size.reannz``
     - Outbound REANNZ Cloud Connect object storage traffic
       (``nz-hlz-1`` only).
     - ``B`` (bytes)
     - Push
     - Delta
     - High
   * - ``storage.objects.download.size.internet``
     - Outbound Internet object storage traffic.
     - ``B`` (bytes)
     - Push
     - Delta
     - High
