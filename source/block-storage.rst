#############
Block storage
#############


********
Overview
********

Block volumes are similar to virtual disks that can be attached to any compute
instance in a region to provide additional storage. They are highly available
and extremely resilient.

Our block storage service is provided by a fully distributed storage system,
with no single points of failure and scalable to the exabyte level. The system
is self-healing and self-managing. Data is seamlessly replicated on three
different servers in the same region, making it fault tolerant and resilient.

The loss of a node or a disk leads to the data being quickly recovered on
another disk or node. The system runs frequent CRC checks to protect data from
soft corruption. The corruption of a single bit can be detected and
automatically restored to a healthy state.

Storage tiers
=============

b1.standard
-----------

The ``b1.standard`` tier combines SSDs with spinning drives to provide a good
balance between performance and cost. Writes are always done to SSDs first and
then flushed to HDDs later behind the scenes. Reads are likely to be cached by
the aggregate memory of all our storage nodes combined, but will hit a HDD when
the data is not cached.

Data stored on the ``b1.standard`` storage tier is replicated on three
different storage nodes on the same region.

Each ``b1.standard`` volume is limited to 1000 IOPS. You can stripe multiple
volumes together (using RAID 0) to achieve higher IOPS.

Additional storage tiers
------------------------

Catalyst is prepared to introduce additional storage tiers and is currently
waiting for demand from customers to introduce a faster tier backed purely by
SSDs. If you are interested and would like to see this available as soon as
possible, please contact your account manager.

Best practices
==============

The root volume of your compute instance should only be used for operating
system data. It is recommended to add additional volumes to your compute
instances to persist application data. For example: when running a MySQL
database, you should add at least one additional volume with enough space to
hold your database and mount it on ``/var/lib/mysql``.

While block volumes can be formatted and used independently, it is highly
recommended to use a logical volume management layer, such as LVM, in
production environments. By using LVM you will be able to add additional
volumes and resize file-systems without downtime. Please consult the
documentation of your operating system for information on how to use LVM.

If you are using volumes independently (without LVM, in a development
scenario), then you must label your partitions to ensure they will be mounted
correctly. The order of the devices (sdb, sdc, etc) may change and, when
unlabelled, may result in them being mounted incorrectly.



***********
Via the CLI
***********

Create a new volume
===================

Use the ``openstack volume create`` command to create a new volume:

.. code-block:: bash

  $ openstack volume create --description 'database volume' --size 50 db-vol-01
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | attachments         | []                                   |
  | availability_zone   | nz-por-1a                            |
  | bootable            | false                                |
  | consistencygroup_id | None                                 |
  | created_at          | 2016-08-18T23:08:40.021641           |
  | description         | database volume                      |
  | encrypted           | False                                |
  | id                  | 7e94a2f6-b4d2-47f1-83f7-a200e963404a |
  | multiattach         | False                                |
  | name                | db-vol-01                            |
  | properties          |                                      |
  | replication_status  | disabled                             |
  | size                | 50                                   |
  | snapshot_id         | None                                 |
  | source_volid        | None                                 |
  | status              | creating                             |
  | type                | b1.standard                          |
  | updated_at          | None                                 |
  | user_id             | 4b934c44d8b24e60acad9609b641bee3     |
  +---------------------+--------------------------------------+

Attach a volume to a compute instance
=====================================

Use the ``openstack server add volume`` command to attach the volume to an
instance:

.. code-block:: bash

  $ openstack server add volume INSTANCE_NAME VOLUME_NAME

The command above assumes that your volume name is unique. If you have volumes
with duplicate names, you will need to use the volume ID to attach it to a
compute instance.


*************
Using volumes
*************

Once attached to a compute instance, a block volume behaves like a raw
unformatted disk.

On Linux
========

The example below illustrates the use of a volume without LVM.

.. warning::

  Please note that this configuration is not suitable for production servers,
  but rather a demonstration that block volumes behave like regular disk drives
  attached to a server.

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

Label the partition:

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

.. note::

  When referring to block devices in ``/etc/fstab`` it is recommended that UUID
  or volume label is used instead of using the device name explicitly. It is
  possible for device names to change after a reboot particularity when there are
  multiple attached volumes.

*********************************************
Best Practice for maximising disk performance
*********************************************

I/O Readahead
=============
One of the recommended ways in which to improve disk perfomance on a virtual
server is by increasing the I/O readahead value. This parameter determines the
number of kilobytes that the kernel will read ahead during a sequential read
operation.

The default value for this is 128KB but it is possible to increase this up to
around 2048KB. This should drastically improve sequential read performance, and
can be done using a script in /etc/udev/rules.d/.

Here is an example of what this script might look like.

# cat /etc/udev/rules.d/read-ahead-kb.rules
SUBSYSTEM=="block", KERNEL=="vd[a-z]" ACTION=="add|change",
ATTR{queue/read_ahead_kb}="1024"

This change is highly recommended if your workload is doing a lot of large streaming
reads.

|

Striping Volumes and RAID0
==========================
These techniques provide improved I/O performance by distributing I/O requests across multiple
disks. While the implementation differs between the two options the resulting setups provide the
same benefits.

Due to the nature of the way block storage is implemented on Catalyst Cloud it is already
using distributed IO and coupled with the recent raising of the IOPS cap from 500 to 1000 this
change may not have as much impact on performance as it would have previously.

That being said there has been cases where a noticeable increase was seen, especially with Windows
as the operating system on the VM. So for the sake of completeness



RAID0 with LVM
--------------
Of the two approaches outlined here, this would be the preferred option. This example will use
`md`_ the Multiple Device driver aka Linux Software RAID and the associated tool `mdadm`_ to create
a software defined RAID device and then `LVM`_ adds a logical volume on top of that.

First find the details of the two disks we will use in the RAID array, in this example they will be
/dev/vdb and /dev/vdc.

.. _md: https://linux.die.net/man/4/md
.. _mdadm: https://raid.wiki.kernel.org/index.php/RAID_setup
.. _LVM: https://wiki.ubuntu.com/Lvm


.. code-block:: bash

  $ fdisk -l
  Disk /dev/vda: 10 GiB, 10737418240 bytes, 20971520 sectors
  Units: sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes
  Disklabel type: dos
  Disk identifier: 0x0cd82097

  Device     Boot Start      End  Sectors Size Id Type
  /dev/vda1  *     2048 20971486 20969439  10G 83 Linux


  Disk /dev/vdb: 10 GiB, 10737418240 bytes, 20971520 sectors
  Units: sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes


  Disk /dev/vdc: 10 GiB, 10737418240 bytes, 20971520 sectors
  Units: sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes

check that the devices in question have no previous RAID configuration present

.. code-block:: bash

  $ mdadm --examine /dev/vd[b-c]
  mdadm: No md superblock detected on /dev/vdb.
  mdadm: No md superblock detected on /dev/vdc.

using fdisk create a RAID partition on each device, the steps are as follow:

- type **n** to create a new partition
- type **p** for primary partition
- type **1** as the partition number
- press **Enter** twice to select the default values for first and last sector
- type **l** to list all available types.
- type **t** to choose the partition type
- type **fd** for `Linux raid auto` and press `Enter` to apply.
- type **w** to write the changes.

.. code-block:: bash

  $ fdisk /dev/vdb

  Welcome to fdisk (util-linux 2.27.1).
  Changes will remain in memory only, until you decide to write them.
  Be careful before using the write command.

  Device does not contain a recognized partition table.
  Created a new DOS disklabel with disk identifier 0x9b91736a.

  Command (m for help): n
  Partition type
     p   primary (0 primary, 0 extended, 4 free)
     e   extended (container for logical partitions)
  Select (default p): p
  Partition number (1-4, default 1):
  First sector (2048-20971519, default 2048):
  Last sector, +sectors or +size{K,M,G,T,P} (2048-20971519, default 20971519):

  Created a new partition 1 of type 'Linux' and of size 10 GiB.

  Command (m for help): l

   0  Empty           24  NEC DOS         81  Minix / old Lin bf  Solaris
   1  FAT12           27  Hidden NTFS Win 82  Linux swap / So c1  DRDOS/sec (FAT-
   2  XENIX root      39  Plan 9          83  Linux           c4  DRDOS/sec (FAT-
   3  XENIX usr       3c  PartitionMagic  84  OS/2 hidden or  c6  DRDOS/sec (FAT-
   4  FAT16 <32M      40  Venix 80286     85  Linux extended  c7  Syrinx
   5  Extended        41  PPC PReP Boot   86  NTFS volume set da  Non-FS data
   6  FAT16           42  SFS             87  NTFS volume set db  CP/M / CTOS / .
   7  HPFS/NTFS/exFAT 4d  QNX4.x          88  Linux plaintext de  Dell Utility
   8  AIX             4e  QNX4.x 2nd part 8e  Linux LVM       df  BootIt
   9  AIX bootable    4f  QNX4.x 3rd part 93  Amoeba          e1  DOS access
   a  OS/2 Boot Manag 50  OnTrack DM      94  Amoeba BBT      e3  DOS R/O
   b  W95 FAT32       51  OnTrack DM6 Aux 9f  BSD/OS          e4  SpeedStor
   c  W95 FAT32 (LBA) 52  CP/M            a0  IBM Thinkpad hi ea  Rufus alignment
   e  W95 FAT16 (LBA) 53  OnTrack DM6 Aux a5  FreeBSD         eb  BeOS fs
   f  W95 Ext'd (LBA) 54  OnTrackDM6      a6  OpenBSD         ee  GPT
  10  OPUS            55  EZ-Drive        a7  NeXTSTEP        ef  EFI (FAT-12/16/
  11  Hidden FAT12    56  Golden Bow      a8  Darwin UFS      f0  Linux/PA-RISC b
  12  Compaq diagnost 5c  Priam Edisk     a9  NetBSD          f1  SpeedStor
  14  Hidden FAT16 <3 61  SpeedStor       ab  Darwin boot     f4  SpeedStor
  16  Hidden FAT16    63  GNU HURD or Sys af  HFS / HFS+      f2  DOS secondary
  17  Hidden HPFS/NTF 64  Novell Netware  b7  BSDI fs         fb  VMware VMFS
  18  AST SmartSleep  65  Novell Netware  b8  BSDI swap       fc  VMware VMKCORE
  1b  Hidden W95 FAT3 70  DiskSecure Mult bb  Boot Wizard hid fd  Linux raid auto
  1c  Hidden W95 FAT3 75  PC/IX           bc  Acronis FAT32 L fe  LANstep
  1e  Hidden W95 FAT1 80  Old Minix       be  Solaris boot    ff  BBT

  Command (m for help): t
  Selected partition 1
  Partition type (type L to list all types): fd
  Changed type of partition 'Linux' to 'Linux raid autodetect'.

  Command (m for help): w
  The partition table has been altered.
  Calling ioctl() to re-read partition table.
  Syncing disks.

confirm that both devices now have a partion of type **fd**

.. code-block:: bash

  $ mdadm --examine /dev/vd[b-c]
  /dev/vdb:
     MBR Magic : aa55
  Partition[0] :     20969472 sectors at         2048 (type fd)
  /dev/vdc:
     MBR Magic : aa55
  Partition[0] :     20969472 sectors at         2048 (type fd)

now create the raid device with the following parameters:

- raid device called /dev/mdo (-C /dev/md0)
- using RAID type 0 (-l raid0)
- using 2 disks (-n 2 /dev/vd[b-c]1)


.. code-block:: bash

  $ mdadm -C /dev/md0 -l raid0 -n 2 /dev/vd[b-c]1
  mdadm: Defaulting to version 1.2 metadata
  mdadm: array /dev/md0 started.

checking /proc/mdstat will show a snapshot of the kernel's RAID/md state which should show there is
now an active RAID0 device

.. code-block:: bash

  cat /proc/mdstat
  Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
  md0 : active raid0 vdc1[1] vdb1[0]
        20953088 blocks super 1.2 512k chunks

to get a more detailed view use `mdadm`

.. code-block:: bash

  $ mdadm --detail /dev/md0
  /dev/md0:
          Version : 1.2
    Creation Time : Wed Aug  9 02:50:55 2017
       Raid Level : raid0
       Array Size : 20953088 (19.98 GiB 21.46 GB)
     Raid Devices : 2
    Total Devices : 2
      Persistence : Superblock is persistent

      Update Time : Wed Aug  9 02:50:55 2017
            State : clean
   Active Devices : 2
  Working Devices : 2
   Failed Devices : 0
    Spare Devices : 0

       Chunk Size : 512K

             Name : raidtest:0  (local to host raidtest)
             UUID : b243a02d:4acc1b05:22c9e97c:ca23747d
           Events : 0

      Number   Major   Minor   RaidDevice State
         0     253       17        0      active sync   /dev/vdb1
         1     253       33        1      active sync   /dev/vdc1

Now create a new logical volume using the raid device. Below is an outline of the steps required to
do this and the following example also contains more complete information on these steps.

.. code-block:: bash

  $ pvcreate /dev/md0
    Physical volume "/dev/md0" successfully created

  $ vgcreate raid0-vg /dev/md0
    Volume group "raid0-vg" successfully created

  $ lvcreate -L19G -n raid0-lvm raid0-vg
    Logical volume "raid0-lvm" created.

  $ lvs
    LV        VG       Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
    raid0-lvm raid0-vg -wi-a----- 19.00g

Finally add a filesystem to the device and mount is so that it is useable.

.. code-block:: bash

    mkfs.ext4 /dev/raid0-vg/raid0-lvm
    mount /dev/raid0-vg/raid0-lvm  /mnt/<mount_point>/


Creating a striped logical volume
---------------------------------
While LVM striping does achieve a very similar outcome to the RAID0 setup outlined above it should
be noted that changing the number of stripes in sync with the number of disks is an unnecessary
overheard and why the previous approach is preferred.

This example will use 3 volumes to create the striped volume. Once logged into the server use
lvmdiskscan to confirm that there are 3 (unpartitioned) disks, in this case */dev/vdc*, */dev/dvd*
and */dev/vde*.

.. code-block:: bash

  $ sudo lvmdiskscan
    /dev/vda1 [      10.00 GiB]
    /dev/vdb1 [      20.00 GiB]
    /dev/vdc  [      20.00 GiB]
    /dev/vdd  [      20.00 GiB]
    /dev/vde  [      20.00 GiB]
    3 disks
    2 partitions
    0 LVM physical volume whole disks
    0 LVM physical volumes

Now we need to create a new physical volumes for all of the newly added disks.

.. code-block:: bash

  $ sudo pvcreate /dev/vdc /dev/vdd /dev/vde

A rescan with lvmdiskscan shows us that those disks have now been tagged as LVM volumes.

.. code-block:: bash

  $ sudo lvmdiskscan
    /dev/vda1 [      10.00 GiB]
    /dev/vdb1 [      20.00 GiB]
    /dev/vdc  [      20.00 GiB] LVM physical volume
    /dev/vdd  [      20.00 GiB] LVM physical volume
    /dev/vde  [      20.00 GiB] LVM physical volume
    0 disks
    2 partitions
    3 LVM physical volume whole disks
    0 LVM physical volumes

Now create a volume group called lvm_volume_group from the physical volumes created above.

.. code-block:: bash

  $ sudo vgcreate lvm_volume_group /dev/vdc /dev/vdd /dev/vde
    Volume group "lvm_volume_group" successfully created

  $ sudo vgs
    VG               #PV #LV #SN Attr   VSize  VFree
    lvm_volume_group   3   0   0 wz--n- 59.99g 59.99g


The final step is to create the actual striped logical volume. Here we are creating it with the
following parameters:

- three stripes (-i3)
- stripe size of 4KiB (-I4)
- useable size of 20GB (-L20G)
- called striped_vol (-n striped_vol)

this will be created on the volume group lvm_volume_group

.. code-block:: bash

  $ sudo lvcreate --type striped -i3 -I4 -L20G -n striped_vol lvm_volume_group
    Rounding size 20.00 GiB (5120 extents) up to stripe boundary size 20.00 GiB (5121 extents).
    Wiping ext4 signature on /dev/lvm_volume_group/striped_vol.
    Logical volume "striped_vol" created.

  $ sudo lvs
    LV          VG               Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
    striped_vol lvm_volume_group -wi-a----- 20g


Once the striped LV has been successfully created it will need to have a file system added and be
mounted as a useable disk.

.. code-block:: bash

  mkfs.ext4 /dev/lvm_volume_group/striped_vol
  mount /dev/lvm_volume_group/striped_vol /mnt/<mount_point>/
=======
***
FAQ
***

How to grow a cinder volume?
============================

So you have been succesfully using OpenStack and now one of your volumes has
started filling up.  What is the best, quickest and safest way to grow the
size of your volume?

Well, as always, that depends.

Boot Volumes
============

This is difficult in OpenStack as there is not an easy and obvious choice.

Create New Instance
-------------------

The best method is to spin up a new instance with a new volume and use
the configuration management tool of your choice to make sure it is as you
want it.  Terminate the old instance and attach all the data volumes to the
new instance.

This assumes there is no permanent data stored on the boot volume that is
outside the configuration managment tool control.

Use a Volume Snapshot
---------------------

Another method which is quick and safe is to perform a volume snapshot.

The process is as follows:

* Shutdown the instance.
* Take a volume snapshot.
* Create volume from snapshot.
* Boot instance from volume.

This sequence can be performed either through the API/commands or the
dashboard.

A reason to like this method is that the original volume is maintained, it is
quick and cloud-init grows the new instance filesystem to the new volume size
on first boot.

The reasons not to like this method are:

* The host gets new keys which may upset some applications.
* The original volume and the snapshot can not be deleted until the newly
  created volume is deleted.
* You will be charged for these cinder volumes and the snapshot.

Old Fashioned Method
--------------------

Finally, there is the old fashioned methods that involves:

* Create a new bootable volume.
* Shutdown instance and detach boot volume.
* Attach the new volume and the original to another instance.
* Perform a copy using tools like dd.

Non-boot Volumes
================

The way to go is:

* Detach the volume from the instance
* Extend the volume
* Attach the volume to the instance
* Adjust the disk within the OS as you would normally
