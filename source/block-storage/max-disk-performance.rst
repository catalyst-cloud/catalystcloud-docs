#############################################
Best Practice for maximising disk performance
#############################################

*************
I/O Readahead
*************

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

This change is highly recommended if your workload is doing a lot of large streaming
reads.

**************************
Striping Volumes and RAID0
**************************

These techniques provide improved I/O performance by distributing I/O requests
across multiple disks. While the implementation differs between the two
options, the resulting setups provide the same benefits.

Due to the way block storage is implemented on Catalyst Cloud, it is already
using distributed IO, and coupled with the recent raising of the IOPS cap
from 500 to 1000, this change may not have as much impact on performance
as it would have had previously.

That being said, there have been cases where a noticeable increase was seen,
especially with Windows as the operating system on the VM.
So for the sake of completeness:



RAID0 with LVM
==============

Of the two approaches outlined here, this would be the preferred option.
This example will use `md`_ the Multiple Device driver aka Linux Software
RAID and the associated tool `mdadm`_ to create a software defined RAID
device and then `LVM`_ adds a logical volume on top of that.

First find the details of the two disks we will use in the RAID array. In
this example they will be /dev/vdb and /dev/vdc.

.. _md: https://linux.die.net/man/4/md
.. _mdadm: https://raid.wiki.kernel.org/index.php/RAID_setup
.. _LVM: https://wiki.ubuntu.com/Lvm


.. code-block:: console

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

.. code-block:: console

  $ mdadm --examine /dev/vd[b-c]
  mdadm: No md superblock detected on /dev/vdb.
  mdadm: No md superblock detected on /dev/vdc.

using fdisk create a RAID partition on each device, the steps are as follows:

- type **n** to create a new partition
- type **p** for primary partition
- type **1** as the partition number
- press **Enter** twice to select the default values for first and last sector
- type **l** to list all available types.
- type **t** to choose the partition type
- type **fd** for `Linux raid auto` and press `Enter` to apply.
- type **w** to write the changes.

.. code-block:: console

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

.. code-block:: console

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


.. code-block:: console

  $ mdadm -C /dev/md0 -l raid0 -n 2 /dev/vd[b-c]1
  mdadm: Defaulting to version 1.2 metadata
  mdadm: array /dev/md0 started.

checking ``/proc/mdstat`` will show a snapshot of the kernel's RAID/md state
which should show there is now an active RAID0 device

.. code-block:: console

  $ cat /proc/mdstat
  Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
  md0 : active raid0 vdc1[1] vdb1[0]
        20953088 blocks super 1.2 512k chunks

to get a more detailed view use ``mdadm``

.. code-block:: console

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

Now create a new logical volume using the raid device. Below is an outline
of the steps required to do this, and the following example also contains
more complete information on these steps.

.. code-block:: console

  $ pvcreate /dev/md0
    Physical volume "/dev/md0" successfully created

  $ vgcreate raid0-vg /dev/md0
    Volume group "raid0-vg" successfully created

  $ lvcreate -L19G -n raid0-lvm raid0-vg
    Logical volume "raid0-lvm" created.

  $ lvs
    LV        VG       Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
    raid0-lvm raid0-vg -wi-a----- 19.00g

Finally add a filesystem to the device and mount it so that it is useable.

.. code-block:: console

  $ mkfs.ext4 /dev/raid0-vg/raid0-lvm
  $ mount /dev/raid0-vg/raid0-lvm  /mnt/<mount_point>/


Creating a striped logical volume
=================================

While LVM striping does achieve a very similar outcome to the RAID0 setup
outlined above, it should be noted that changing the number of stripes
in sync with the number of disks is an unnecessary overheard. This is why
the previous approach is preferred.

This example will use three volumes to create the striped volume. Once logged
in to the server use lvmdiskscan to confirm that there are three
(unpartitioned) disks, in this case */dev/vdc*, */dev/dvd* and */dev/vde*.

.. code-block:: console

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

.. code-block:: console

  $ sudo pvcreate /dev/vdc /dev/vdd /dev/vde

A rescan with lvmdiskscan shows us that those disks have now been tagged as LVM volumes.

.. code-block:: console

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

Now create a volume group called lvm_volume_group from the physical volumes
created above.

.. code-block:: console

  $ sudo vgcreate lvm_volume_group /dev/vdc /dev/vdd /dev/vde
    Volume group "lvm_volume_group" successfully created

  $ sudo vgs
    VG               #PV #LV #SN Attr   VSize  VFree
    lvm_volume_group   3   0   0 wz--n- 59.99g 59.99g


The final step is to create the actual striped logical volume. Here we are
creating it with the following parameters:

- three stripes (-i3)
- stripe size of 4KiB (-I4)
- useable size of 20GB (-L20G)
- called striped_vol (-n striped_vol)

this will be created on the volume group lvm_volume_group

.. code-block:: console

  $ sudo lvcreate --type striped -i3 -I4 -L20G -n striped_vol lvm_volume_group
    Rounding size 20.00 GiB (5120 extents) up to stripe boundary size 20.00 GiB (5121 extents).
    Wiping ext4 signature on /dev/lvm_volume_group/striped_vol.
    Logical volume "striped_vol" created.

  $ sudo lvs
    LV          VG               Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
    striped_vol lvm_volume_group -wi-a----- 20g


Once the striped LV has been successfully created, it will need to have a file system
added and be mounted as a useable disk.

.. code-block:: console

  $ mkfs.ext4 /dev/lvm_volume_group/striped_vol
  $ mount /dev/lvm_volume_group/striped_vol /mnt/<mount_point>/
