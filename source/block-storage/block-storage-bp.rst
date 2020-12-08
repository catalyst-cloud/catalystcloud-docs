################################
Block storage best practices
################################

We run a distributed storage system that by default retains three copies of
your data on different servers spread across a region (a datacenter).
We can afford to lose many disks and multiple storage nodes without losing any
data. As soon as a disk or storage node fails, our storage solution begins
recovering the data from an existing copy, always ensuring that three replicas
are present.

The storage solution is self managing and self healing, constantly placing
your data in optimal locations for data survival and resiliency. It runs
automated error checks in the background that can detect and recover a single
bit of incorrect data (bit rot), by comparing the three copies of the data and
ensuring they are identical.

The solution is designed and implemented with very high availability and data
resiliency in mind. It has no single points of failure.

***********************************
When to use each type of volume
***********************************

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

*****************************
Volume names should be unique
*****************************

All volumes have a UUID that differentiate between them, however these are not
very easy to read for human users. Therefore it is a best practice to make sure
that you name your volumes uniquely. This is to avoid a situation
where you have multiple volumes with the same name (or UUIDs that you don't
recognise) which you plan to attach to different instance, but you are not able
to tell which volume holds which data.

.. note::

  Your names should never include any information on user IDs, emails, project
  information etc. You also need to avoid using '/' in your naming, instead you
  should use '-'

.. _maximising-disk-performance:

*********************************************
Best practice for maximising disk performance
*********************************************

When you are running workloads where I/O speed and consistency matter you will
probably want a volume that is performant in terms of it's IO access. To ensure
that this is the case the target volume should be created using one of the
NVMe storage tiers. There are three options available depending on the level
of IOPS cap you require.

It is also important to note that block storage volumes are are
**thin provisioned** ( also known as **sparse volumes** ). This means that the
actual disk space is only allocated as it is used and as such may become
fragmented or allocated in a sub-optimal manner. This in turn can possibly
impact the ability of a volume to make full use of it's IOPS capability.

For volumes where IO performance is critical it is possible to minimise this
impact by pre-allocating the storage. This is achieved by writing zeroes to
the disk after it is created but before creating the filesystem, thus ensuring
that a more optimal allocation is done on the storage layer.

Once the volume is partitioned and **before** the filesystem has been created,
run the following command to pre-allocate the storage.

.. code:: shell

   $ dd if=dev/zero of=/dev/vdx bs=1M

Once this has completed create the files system as usual; for example if were
creating an ext4 filesystem we c

.. code:: shell

   $ mkfs.ext4 /dev/vdx

.. _io-readahead:

I/O Readahead
=============

It is recommended to increase the I/O readahead value for the volume to improve
performance. This parameter determines the number of kilobytes that the kernel
will read ahead during a sequential read operation.

The default value for this is 128KB but it is possible to increase this up to
around 2048KB. This should drastically improve sequential read performance, and
can be done using a script in /etc/udev/rules.d/.

Here is an example of what this script might look like.

.. code-block:: console

  $ sudo cat /etc/udev/rules.d/read-ahead-kb.rules
  SUBSYSTEM=="block", KERNEL=="vd[a-z]" ACTION=="add|change",
  ATTR{queue/read_ahead_kb}="1024"

This change is highly recommended if your workload is doing a lot of large
streaming reads.
