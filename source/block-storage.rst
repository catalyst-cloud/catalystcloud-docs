#############
Block storage
#############


********
Overview
********

Our block storage service is provided by a fully distributed storage system,
with no single points of failure and scalable to the exabyte level. The system
is self-healing and self-managing. Data is seamlessly replicated on three
different servers, making it fault tolerant and resilient. The loss of a node
or a disk leads to the data being quickly recovered on another disk or node.

The system runs frequent CRC checks to protect data from soft corruption. The
corruption of a single bit can be detected and automatically restored to a
healthy state.

Storage tiers
=============

Currently the Catalyst Cloud provides a single storage tier called
``b1.standard``, which combines SSDs with spinning drives to provide a good
balance between performance and cost. Data stored on the ``b1.standard``
storage tier is replicated on three different storage nodes on the same region.
In the future more storage tiers will be provided, offering options in terms of
cost and performance.

*************************
Attaching an empty volume
*************************

A common use case for volumes is to provide extra disk space for an instance.
This section demonstrates how to do this on an existing Ubuntu 16.04 instance.

Use the ``nova volume-create`` command to create a new volume:

.. code-block:: bash

 $ nova volume-create --display-name 'extra-disk' --display-description 'Extra diskspace for our instance' 50
 +---------------------+--------------------------------------+
 | Property            | Value                                |
 +---------------------+--------------------------------------+
 | attachments         | []                                   |
 | availability_zone   | nz-por-1a                            |
 | bootable            | false                                |
 | created_at          | 2016-05-04T04:49:07.633072           |
 | display_description | Extra diskspace for our instance     |
 | display_name        | extra-disk                           |
 | encrypted           | False                                |
 | id                  | 4c52fa4b-c1a0-493f-9672-a06feda81d7f |
 | metadata            | {}                                   |
 | multiattach         | false                                |
 | size                | 50                                   |
 | snapshot_id         | -                                    |
 | source_volid        | -                                    |
 | status              | creating                             |
 | volume_type         | b1.standard                          |
 +---------------------+--------------------------------------+

Now use the ``nova volume-attach`` command to attach the volume to an instance:

.. code-block:: bash

 $ nova volume-attach example-instance ec1a31ad-1a20-4f60-bef2-69b35d67483f
 +----------+--------------------------------------+
 | Property | Value                                |
 +----------+--------------------------------------+
 | device   | /dev/vdb                             |
 | id       | ec1a31ad-1a20-4f60-bef2-69b35d67483f |
 | serverId | 2586b9ce-cbe3-481d-9f43-b93df21e525e |
 | volumeId | ec1a31ad-1a20-4f60-bef2-69b35d67483f |
 +----------+--------------------------------------+

.. note::

 There are many different ways to configure block storage up in a Linux environment, this documentation is not intended as a guide for Linux filesystems and partitioning. The example given here is for a creating a single ext4 formated partition on a volume. Please consult you distributions documentation for more information about configuring file systems on Linux.

Check that the disk is recognised by the OS on the instance using ``fdisk``:

.. code-block:: bash

 $ sudo fdisk -l /dev/vdb
 Disk /dev/vdb: 50 GiB, 53687091200 bytes, 104857600 sectors
 Units: sectors of 1 * 512 = 512 bytes
 Sector size (logical/physical): 512 bytes / 512 bytes
 I/O size (minimum/optimal): 512 bytes / 512 bytes

Now use ``fdisk`` to create a partition on the disk:

.. code-block:: bash

 $ sudo fdisk /dev/vdb

 Welcome to fdisk (util-linux 2.27.1).
 Changes will remain in memory only, until you decide to write them.
 Be careful before using the write command.

 Device does not contain a recognized partition table.
 Created a new DOS disklabel with disk identifier 0x1552cd32.

 Command (m for help): n
 Partition type
    p   primary (0 primary, 0 extended, 4 free)
    e   extended (container for logical partitions)
 Select (default p): p
 Partition number (1-4, default 1): 1
 First sector (2048-104857599, default 2048):
 Last sector, +sectors or +size{K,M,G,T,P} (2048-104857599, default 104857599):

 Created a new partition 1 of type 'Linux' and of size 50 GiB.

 Command (m for help): w
 The partition table has been altered.
 Calling ioctl() to re-read partition table.
 Syncing disks.

Check the partition using ``lsblk``:

.. code-block:: bash

 NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
 vda    253:0    0  10G  0 disk
 └─vda1 253:1    0  10G  0 part /
 vdb    253:16   0  50G  0 disk
 └─vdb1 253:17   0  50G  0 part

Make a new filesystem on the partition:

.. code-block:: bash

 $ sudo mkfs.ext4 /dev/vdb1
 mke2fs 1.42.13 (17-May-2015)
 Creating filesystem with 5242624 4k blocks and 1310720 inodes
 Filesystem UUID: 7dec7fb6-ff38-453b-9335-0c240d179262
 Superblock backups stored on blocks:
     32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
     4096000

 Allocating group tables: done
 Writing inode tables: done
 Creating journal (32768 blocks): done
 Writing superblocks and filesystem accounting information: done

Create a directory where you wish to mount this file system:

.. code-block:: bash

 $ sudo mkdir /mnt/extra-disk

Mount the file system:

.. code-block:: bash

 $ sudo mount /dev/vdb1 /mnt/extra-disk

Optionally label the partition:

.. code-block:: bash

 $ sudo tune2fs -L 'extra-disk' /dev/vdb1
 tune2fs 1.42.13 (17-May-2015)
 $ sudo blkid
 /dev/vda1: LABEL="cloudimg-rootfs" UUID="98c51306-83a2-49da-94a9-2a841c9f27b0" TYPE="ext4" PARTUUID="8cefe526-01"
 /dev/vdb1: LABEL="extra-disk" UUID="7dec7fb6-ff38-453b-9335-0c240d179262" TYPE="ext4" PARTUUID="235ac0e4-01"

If you want the new file system to be mounted when the system reboots then you
should add an entry to ``/etc/fstab``, for example:

.. code-block:: bash

 $ cat /etc/fstab
 LABEL=cloudimg-rootfs /               ext4    defaults    0 1
 LABEL=extra-disk      /mnt/extra-disk ext4    defaults    0 2

