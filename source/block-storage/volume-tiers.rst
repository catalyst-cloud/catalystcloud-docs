
.. _block-storage-volume-tiers:

############
Volume Tiers
############

Block Storage provides two different performance tiers for different
workloads and use cases you may have.

The two tiers are:

* High Performance, using NVMe backed storage; and
* Standard Performance, using HDD backed storage

High Performance volumes are strongly recommended for most use
cases, particularly operating system disks. Standard Performance, based
on HDD, is recommended only for bulk storage where capacity and price
are more important than performance and latency.

In all cases, the performance specified is the maximum burstable level,
and not a guaranteed minimum level of performance.

.. warning::

  Once a volume has been created the type cannot be changed while it is in use.
  Please follow the process outlined in :ref:`Migrating Volumes
  <migrating-volumes>` to migrate between different volume types.

****************
High Performance
****************

The High Performance tier makes sole use of direct NVMe SSD drives to
back your block storage volume, distributed for performance and
redundancy. It offers low consistent latency and high throughput with
three options for IOPS limits.

.. list-table::
   :widths: 20 13 20 11
   :header-rows: 1

   * - Volume type
     - Disk
     - Replication
     - Peak IOPS  \ :sup:`[1]` \
   * - b1.sr-r3-nvme-1000
     - NVMe
     - Single-site
     - 1000
   * - b1.sr-r3-nvme-2500
     - NVMe
     - Single-site
     - 2500
   * - b1.sr-r3-nvme-5000
     - NVMe
     - Single-site
     - 5000

[1] Please note that the IOPS described on the table above are not
guaranteed or provisioned IOPS, but rather the burst limit (ceiling)
that each volume can reach from time to time.

********************
Standard Performance
********************

Standard Performance block storage volumes are backed by classical
HDD magnetic disks, offering large capacity but with low performance
expectations that vary considerably based on workload and activity.

.. note::

  We do not recommend operating system disks use Standard Performance
  disks, as the low level of performance can interfere with OS
  operations. Always use High Performance disks for any OS disks.

These disks are well suited to bulk storage needs, such as archival
data that must be online, file storage for shared network filesystems,
and other low-demand use cases.

.. list-table::
   :widths: 20 13 20 11
   :header-rows: 1

   * - Volume type
     - Disk
     - Replication
     - Peak IOPS  \ :sup:`[1]` \
   * - b1.standard
     - HDD
     - Single-site
     - 500
   * - b1.sr-r2-hdd-100
     - HDD
     - Single-site, Reduced Reliability \ :sup:`[2]` \
     - 100
   * - b1.sr-r3-hdd-250
     - HDD
     - Single-site
     - 250
   * - b1.sr-r3-hdd-500
     - HDD
     - Single-site
     - 500

[1] Please note that the IOPS described on the table above are not
guaranteed or provisioned IOPS, but rather the burst limit (ceiling)
that each volume can reach from time to time.

[2] The storage type b1.sr-r2-hdd-100 has reduced reliability and is not
recommended for production use. It is designed for development, test
and ephemeral workloads.
