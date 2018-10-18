########
Overview
########

*************
Storage tiers
*************


b1.standard
===========

The ``b1.standard`` tier combines SSDs with spinning drives to provide a good
balance between performance and cost. Writes are always done to SSDs first and
then flushed to HDDs later behind the scenes. Reads are likely to be cached by
the aggregate memory of all our storage nodes combined, but will hit a HDD when
the data is not cached.

Data stored on the ``b1.standard`` storage tier is replicated on three
different storage nodes on the same region.

Each ``b1.standard`` volume is limited to 500 IOPS. You can stripe multiple
volumes together (using RAID 0) to achieve higher IOPS.

Additional storage tiers
========================

Catalyst is prepared to introduce additional storage tiers and is currently
waiting for demand from customers to introduce a faster tier backed purely by
SSDs. If you are interested and would like to see this available as soon as
possible, please contact your account manager.

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
