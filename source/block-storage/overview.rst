########
Overview
########

*************
Storage tiers
*************
Catalyst provides several tiers of storage to suit the varying needs of our
customers. All data regardless of the storage tier is replicated on three
different storage nodes on the same region.


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

The ``performance`` tier makes sole use of direct NVMe SSD drive access for
both read and write operations. This tier offers three options for IO
throughput, which provide a burstable limit of 1000, 2500 and 5000 IOPS.

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
     - NVMe
     - 1000
   * - b1.sr-r3-nvme-2000
     - Single region
     - 3
     - NVMe
     - 2000
   * - b1.sr-r3-nvme-5000
     - Single region
     - 3
     - NVMe
     - 5000

[1] Please note that the IOPS described on the table above are not guaranteed
or provisioned IOPS, but rather the burst limit (ceiling) that each volume can
reach from time to time.

Migrating data between tiers
============================

If you are interested in moving data from a volume in the standard tier to an
NVMe volume please checkout :ref:`migrating-volumes`


Creating an instance with an NVMe root disk
===========================================

If you want to launch an instance using an NVMe root volume check out
:ref:`boot-with-nvme-volume` for more information.

*******
Backups
*******

As a precaution, it is important to create backups that secure your data in the
event of some catastrophe. Whether this is from a natural disaster, user error
or some other unfortunate event, you want to ensure that the data you have
is saved in a secure fashion. We highly recommended that you create backups of
all of your volumes after you have created them. You can follow the guides
found in the :ref:`backups<backups>` section of the documentation to create and automate
your backup tasks.
