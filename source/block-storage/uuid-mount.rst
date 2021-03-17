.. _using-volume-uuid:

#######################################
Mounting a volume using a UUID
#######################################

*****************************
Creating a volume via the CLI
*****************************

Unlike our previous example, we are going to be creating and attaching a
volume using its **UUID**, rather than a unique volume name. This process is
only uniquely different for the openstack CLI, if you wish to use another
method to create and attach your instance; you can follow the examples on the
:ref:`using-volumes` page.

For this example we start off with creating a new volume:

.. code-block:: console

  $ openstack volume create --description 'database volume' --size 50 db-vol-02
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | attachments         | []                                   |
  | availability_zone   | nz-por-1a                            |
  | bootable            | false                                |
  | consistencygroup_id | None                                 |
  | created_at          | 2020-05-18T23:08:40.021641           |
  | description         | database volume                      |
  | encrypted           | False                                |
  | id                  | 29375489-2399-4065-bae0-0b7fc9bd795e |
  | multiattach         | False                                |
  | name                | db-vol-02                            |
  | properties          |                                      |
  | replication_status  | disabled                             |
  | size                | 50                                   |
  | snapshot_id         | None                                 |
  | source_volid        | None                                 |
  | status              | creating                             |
  | type                | b1.standard                          |
  | updated_at          | None                                 |
  | user_id             | 53b94a52e9dcxxxxxxx0079a9a3d6434     |
  +---------------------+--------------------------------------+

Attaching a volume to a compute instance
========================================

Use the ``openstack server add volume`` command to attach the volume to an
instance. For this example we are going to use the volume ID, which we can find
in the output of our previous command:

.. code-block:: console

  $ openstack server add volume INSTANCE_NAME VOLUME_UUID

In this example, we are using the specific UUID of our volume to attach it to
our instance. This is because we do not want our command potentially failing
due to volumes with conflicting labels or names trying to be attached to our
instance.

*****************************************************************
Configuring and mounting your volume on a Linux system using UUID
*****************************************************************

The example below illustrates the use of a volume without LVM that we assign
to our instance using its UUID. The reason you would want to do this
is to guarantee that there will be no conflicts when mounting volumes
on your file system. Using the UUID, you can ensure that even if you have
multiple volumes with the same name, each of them will be mounted in the
correct location.

.. warning::

  Please note that this configuration is not suitable for production servers,
  but rather a demonstration that block volumes behave like regular disk drives
  attached to a server.

Once we have a command line that is connected via ssh to our instance, we check
that our disk is recognized by the OS using ``fdisk``:

.. code-block:: console

  $ sudo fdisk -l /dev/vdb
    Disk /dev/vdb: 50 GiB, 53687091200 bytes, 104857600 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes

Now use ``fdisk`` to create a partition on the disk:

.. code-block:: console

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

.. code-block:: console

  $ lsblk
  NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
  vda    253:0    0  10G  0 disk
  └─vda1 253:1    0  10G  0 part /
  vdb    253:16   0  50G  0 disk
  └─vdb1 253:17   0  50G  0 part

Make a new filesystem on the partition:

.. code-block:: console

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

.. code-block:: console

  $ sudo mkdir /mnt/extra-disk

Find the UUID of your volume, in this case we are looking at /dev/vdb1:

.. code-block:: console

  $ sudo blkid
  /dev/vda1: LABEL="cloudimg-rootfs" UUID="2fb27efc-e5c6-4cdf-9cad-adbceb790835" TYPE="ext4" PARTUUID="409e6e06-500e-4dc1-ba69-7ce4c4e28f48"
  /dev/vda15: LABEL="UEFI" UUID="24F2-64AC" TYPE="vfat" PARTUUID="82f225d4-5e76-448c-842f-c873c9067338"
  /dev/vda14: PARTUUID="ef5a7630-67ef-4c9d-b1af-315ce5f495e2"
  /dev/vdb1: UUID="02bea4be-22c7-4e34-ad2f-a7a42848c38d" TYPE="ext4" PARTUUID="c5cedbe1-01"

Mount the file system:

.. code-block:: console

  $ sudo mount UUID=02bea4be-22c7-4e34-ad2f-a7a42848c38d /mnt/extra-disk

If you want the new file system to be mounted when the system reboots then you
should add an entry to ``/etc/fstab``. For example, making sure you have sudo
privilege:

.. code-block:: console

  $ cat /etc/fstab
  LABEL=cloudimg-rootfs /               ext4    defaults    0 1
  LABEL=extra-disk      /mnt/extra-disk ext4    defaults    0 2

  #use vim or nano to open up the fstab file and put the following code block inside
  $ vim /etc/fstab

  UUID=ID_OF_YOUR_VOLUME /mnt/extra-disk ext4    defaults   0 0


