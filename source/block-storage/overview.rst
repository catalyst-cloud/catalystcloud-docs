########
Overview
########

*************
Storage tiers
*************
Catalyst provides several tiers of storage to suit the varying needs of our
customers.

Data stored on the storage tiers is replicated on three different storage
nodes on the same region.


The standard tier
=================

The ``standard tier`` combines SSDs with spinning drives to provide a good
balance between performance and cost. Writes are always done to SSDs first and
then flushed to HDDs later behind the scenes. Reads are likely to be cached by
the aggregate memory of all our storage nodes combined, but will hit a HDD when
the data is not cached.

Due to the performance overheads imposed by the use of spinning drives the IOPS
limits are limited to choices of 100, 250 or 500 IOPS. If a higher IO
throughput is required then you will need to take a look at the ``performance
tier``.

Data stored on the ``standard`` storage tier is replicated on three
different storage nodes on the same region.

.. list-table::
   :widths: 20 20 10 16 11
   :header-rows: 1

   * - Storage type
     - Replication domain
     - Replicas
     - Disk
     - IOPS  \ :sup:`[1]` \
   * - b1.standard
     - Single region
     - 3
     - HDDs and SSDs
     - 500
   * - b1.sr-r2-hdd-100 \ :sup:`[2]` \
     - Single region
     - 2
     - HDDs and SSDs
     - 100
   * - b1.sr-r3-hdd-250
     - Single region
     - 3
     - HDDs and SSDs
     - 250
   * - b1.sr-r3-hdd-500
     - Single region
     - 3
     - HDDs and SSDs
     - 500

[1] Please note that the IOPS described on the table above are not guaranteed
or provisioned IOPS, but rather the burst limit (ceiling) that each volume can
reach from time to time.

[2] The storage type b1.sr-r2-hdd-100 is not recommended for production use.
It is designed for development, test and ephemeral workloads

The performance tier
====================

The ``performance`` tier makes sole use of direct NVME SSD drive access for both
read and write operations. This tier offers three options for IO throughput,
which provide a burstable limit of 1000, 2500 and 5000 IOPS.

All options in this tier provide 3 replicas in a single region.

.. list-table::
   :widths: 20 20 10 16 11
   :header-rows: 1

   * - Storage type
     - Replication domain
     - Replicas
     - Disk
     - IOPS  \ :sup:`[1]` \
   * - b1.sr-r3-nvme-1000
     - Single region
     - 3
     - NVME
     - 1000
   * - b1.sr-r3-nvme-2000
     - Single region
     - 3
     - NVME
     - 2000
   * - b1.sr-r3-nvme-5000
     - Single region
     - 3
     - NVME
     - 5000

[1] Please note that the IOPS described on the table above are not guaranteed
or provisioned IOPS, but rather the burst limit (ceiling) that each volume can
reach from time to time.

Migrating data between tiers
============================

If you are interested in moving data from a volume in the standard tier to an
NVME volume please checkout :ref:`migrating-volumes`


**************
Best practices
**************

The root volume of your compute instance should only be used for operating
system data. We recommend you add additional volumes to your compute
instances to persist application data. For example: when running a MySQL
database, you should add at least one additional volume with enough space to
hold your database and mount it on ``/var/lib/mysql``.

While block volumes can be formatted and used independently, we highly
recommend you use a logical volume management layer, such as LVM, in
production environments. By using LVM you will be able to add additional
volumes and resize file-systems without downtime. Please consult the
documentation of your operating system for information on how to use LVM.

If you are using volumes independently (without LVM, in a development
scenario), then you must label your partitions to ensure they will be mounted
correctly. The order of the devices (sdb, sdc, etc) may change and, when
unlabelled, may result in them being mounted incorrectly.
