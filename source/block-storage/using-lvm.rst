##########################
Volumes using LVM
##########################

************
What is LVM?
************

The Logical Volume Manager (LVM) is a user-space tool set designed to provide a
higher level management of disk storage on a linux system than the traditional
approach of disks and partitions. This is achieved by creating a software
abstraction of those physical devices.

This virtualization of the disks provides the following benefits:

-  The ability to create single logical volumes from multiple physical
   volumes or entire disks.
-  Management of large disk clusters by allowing hot swappable disks to be
   added and replaced without service downtime.
-  Allows for easy filesystem resizing without having to migrate data.
-  Create filesystem backups by taking snapshots of logical volumes.


Working with logical volumes
============================

While it is possible to create a logical volume using an un-partitioned disk we
recommend that you use a partitioned one, if for no other reason than to inform
software such as partitioning utilities that the disk is being used. This
avoids the possibility of someone firing up a partitioning program, seeing an
un-partitioned disk and attempting to use it for some other purpose.

******************************************
Creating a logical volume
******************************************
The first thing to do is identify the disks available for use, to do this
use ``lvmdiskscan`` while on a **compute instance**; and while having ``Sudo``
privileges.

.. code-block:: shell

  root@lvm-test:~# lvmdiskscan
    /dev/vda1 [      11.00 GiB]
    /dev/vdb  [      10.00 GiB]
    /dev/vdc  [      10.00 GiB]
    2 disks
    1 partition
    0 LVM physical volume whole disks
    0 LVM physical volumes

This shows us that there are currently three disks available.

- /dev/vda1, which is a partition on the disk /dev/vda
- /dev/vdb and /dev/vdc, which are un-partitioned disks

For this example /dev/vdb will be used to create the logical volume.

There are several tools available for creating disk partitions, these include
tools such as fdisk, parted and the GNU parted. This example will use gdisk
and the steps are as follows:

- load gdisk and select the disk to partition
- type **n** to create a new partition
- accept the defaults for partition number, first sector and last sector
- type **L** to list the available partition types
- type **8e00** to select Linux LVM
- type **p** to view the partition information
- type **v** to verify the integrity of the changes
- type **w** to write the changes to disk

.. code-block:: shell

  root@lvm-test:~# gdisk
  GPT fdisk (gdisk) version 1.0.1

  Type device filename, or press <Enter> to exit: /dev/vdb
  Partition table scan:
    MBR: not present
    BSD: not present
    APM: not present
    GPT: not present

  Creating new GPT entries.

  Command (? for help): n
  Partition number (1-128, default 1):
  First sector (34-20971486, default = 2048) or {+-}size{KMGTP}:
  Last sector (2048-20971486, default = 20971486) or {+-}size{KMGTP}:
  Current type is 'Linux filesystem'
  Hex code or GUID (L to show codes, Enter = 8300): L
  0700 Microsoft basic data  0c01 Microsoft reserved    2700 Windows RE
  3000 ONIE boot             3001 ONIE config           3900 Plan 9
  4100 PowerPC PReP boot     4200 Windows LDM data      4201 Windows LDM metadata
  4202 Windows Storage Spac  7501 IBM GPFS              7f00 ChromeOS kernel
  7f01 ChromeOS root         7f02 ChromeOS reserved     8200 Linux swap
  8300 Linux filesystem      8301 Linux reserved        8302 Linux /home
  8303 Linux x86 root (/)    8304 Linux x86-64 root (/  8305 Linux ARM64 root (/)
  8306 Linux /srv            8307 Linux ARM32 root (/)  8400 Intel Rapid Start
  8e00 Linux LVM             a500 FreeBSD disklabel     a501 FreeBSD boot
  a502 FreeBSD swap          a503 FreeBSD UFS           a504 FreeBSD ZFS
  a505 FreeBSD Vinum/RAID    a580 Midnight BSD data     a581 Midnight BSD boot
  a582 Midnight BSD swap     a583 Midnight BSD UFS      a584 Midnight BSD ZFS
  a585 Midnight BSD Vinum    a600 OpenBSD disklabel     a800 Apple UFS
  a901 NetBSD swap           a902 NetBSD FFS            a903 NetBSD LFS
  a904 NetBSD concatenated   a905 NetBSD encrypted      a906 NetBSD RAID
  ab00 Recovery HD           af00 Apple HFS/HFS+        af01 Apple RAID
  af02 Apple RAID offline    af03 Apple label           af04 AppleTV recovery
  af05 Apple Core Storage    bc00 Acronis Secure Zone   be00 Solaris boot
  bf00 Solaris root          bf01 Solaris /usr & Mac Z  bf02 Solaris swap
  bf03 Solaris backup        bf04 Solaris /var          bf05 Solaris /home
  bf06 Solaris alternate se  bf07 Solaris Reserved 1    bf08 Solaris Reserved 2
  Press the <Enter> key to see more codes: 8e00
  bf09 Solaris Reserved 3    bf0a Solaris Reserved 4    bf0b Solaris Reserved 5
  c001 HP-UX data            c002 HP-UX service         ea00 Freedesktop $BOOT
  eb00 Haiku BFS             ed00 Sony system partitio  ed01 Lenovo system partit
  ef00 EFI System            ef01 MBR partition scheme  ef02 BIOS boot partition
  f800 Ceph OSD              f801 Ceph dm-crypt OSD     f802 Ceph journal
  f803 Ceph dm-crypt journa  f804 Ceph disk in creatio  f805 Ceph dm-crypt disk i
  fb00 VMWare VMFS           fb01 VMWare reserved       fc00 VMWare kcore crash p
  fd00 Linux RAID
  Hex code or GUID (L to show codes, Enter = 8300): 8e00
  Changed type of partition to 'Linux LVM'

  Command (? for help): p
  Disk /dev/vdb: 20971520 sectors, 10.0 GiB
  Logical sector size: 512 bytes
  Disk identifier (GUID): 53C22F21-ABBF-4478-B0F9-xxxxxxxxxxxx
  Partition table holds up to 128 entries
  First usable sector is 34, last usable sector is 20971486
  Partitions will be aligned on 2048-sector boundaries
  Total free space is 2014 sectors (1007.0 KiB)

  Number  Start (sector)    End (sector)  Size       Code  Name
     1            2048        20971486   10.0 GiB    8E00  Linux LVM

  Command (? for help): v

  No problems found. 2014 free sectors (1007.0 KiB) available in 1
  segments, the largest of which is 2014 (1007.0 KiB) in size.

  Command (? for help): w

  Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
  PARTITIONS!!

  Do you want to proceed? (Y/N): y
  OK; writing new GUID partition table (GPT) to /dev/vdb.
  The operation has completed successfully.

Now checking the disk status should show that there is a new partition

.. code-block:: shell

  root@lvm-test:~# lvmdiskscan
    /dev/vda1 [      11.00 GiB]
    /dev/vdb1 [      10.00 GiB]
    /dev/vdc  [      10.00 GiB]
    1 disk
    2 partitions
    0 LVM physical volume whole disks
    0 LVM physical volumes

In order to use a storage device in a logical volume the disks must first be
labelled as LVM physical volumes, this can be done this using **pvcreate**.
While there is only /dev/vdb1 being added at this time it is possible to pass
multiple devices at once.

.. warning::

  Using the pvcreate command will wipe any data that already exists on your
  volume. Only use this command on an empty volume if you do not want to lose
  any existing data.

The **pvs** (or **pvdisplay**) command can then be used to confirm the status
of the available physical volumes.

.. code-block:: shell

  root@lvm-test:~# pvcreate /dev/vdb1
  Physical volume "/dev/vdb1" successfully created

  root@lvm-test:~# pvs
  PV         VG   Fmt  Attr PSize  PFree
  /dev/vdb1       lvm2 ---  10.00g 10.00g

The next step is to create a volume group. Once again, though only a single
initial physical volume is being added it is possible to add multiple physical
volumes at a time.

It is possible to use a single volume group per server to create a pool of LVM
managed storage, and then allocate all logical volumes from that. Some possible
scenarios where multiple volume groups are necessary are:

- to achieve a sense of separation between operating system and user disks.
- a need for disks with different extent sizes.
- isolating data for performance reasons

Multiple volume groups also require separate physical groups as they cannot be
shared across volume groups.

Using **vgcreate**, create the volume group. If no value is provided for the
extents it will use the default of 4MiB. Volume group status can be confirmed
using vgs (or vgdisplay).

.. code-block:: shell

  root@lvm-test:~# vgcreate vg_data /dev/vdb1
  Volume group "vg_data" successfully created

  root@lvm-test:~# vgs
  VG      #PV #LV #SN Attr   VSize  VFree
  vg_data   1   0   0 wz--n- 10.00g 10.00g

The final step is to create a new logical volume using the **lvcreate** command
, we will call it 'data' and create it in the volume group 'vg_data'.

In the output above it shows that the volume group has 10GB available. That
means that a logical volume could be created with any size up to that limit.
To create a 5GB partition for instance, specify the the size argument ``-l 5G``
. For this example the new volume will use all of the available free space with
the following parameter ``-l 100%FREE``.

.. code-block:: shell

  root@lvm-test:~# lvcreate -l 100%FREE -n data vg_data
    Logical volume "test" created.

  root@lvm-test:~# lvdisplay
    --- Logical volume ---
    LV Path                /dev/vg_data/data
    LV Name                test
    VG Name                vg_data
    LV UUID                LECR2H-OKRK-lPCG-voU1-HCWw-fdTZ-JXcAHc
    LV Write Access        read/write
    LV Creation host, time lvm-test, 2018-02-07 00:21:10 +0000
    LV Status              available
    # open                 0
    LV Size                10.00 GiB
    Current LE             2559
    Segments               1
    Allocation             inherit
    Read ahead sectors     auto
    - currently set to     256
    Block device           252:0

Running **lvmdiskscan** now should show that the new LVM volume is present.

.. code-block:: shell

    root@lvm-test:~# lvmdiskscan
      /dev/vg_data/test [      10.00 GiB]
      /dev/vda1         [      11.00 GiB]
      /dev/vdb1         [      10.00 GiB] LVM physical volume
      /dev/vdc          [      10.00 GiB]
      2 disks
      1 partition
      0 LVM physical volume whole disks
      1 LVM physical volume

All that remains to be done now is to add a filesystem to the LVM and
you will have a functional LVM. Once this is done you will need to follow the
next section on how to mount your new volume.

.. code-block:: shell

  root@lvm-test:~# mkfs.ext4 /dev/vg_data/data
  mke2fs 1.42.13 (17-May-2015)
  Creating filesystem with 2620416 4k blocks and 655360 inodes
  Filesystem UUID: 7551809b-9164-4ae4-ace3-xxxxxxxxxxxx
  Superblock backups stored on blocks:
  32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

  Allocating group tables: done
  Writing inode tables: done
  Creating journal (32768 blocks): done
  Writing superblocks and filesystem accounting information: done

***************************
Mounting a logical volume
***************************

Once you have created a new LVM you will need to mount it before you are able
to access the storage space it has. The following guide will cover how to mount
your existing LVM onto your instance.

.. Note::

  If you are using an existing volume from a previous instance, you will need
  to attach your volume to the new instance first. You can use
  ``openstack server add volume <INSTANCE_NAME> <VOLUME_NAME>`` to do this.

First, we need to find the name of our LVM. The following code will show you
which volumes are present:

.. code-block:: shell

  root@lvm-test:~# lvmdiskscan
  /dev/vg_data/test [      10.00 GiB]
  /dev/vda1         [      11.00 GiB]
  /dev/vdb1         [      10.00 GiB] LVM physical volume
  /dev/vdc          [      10.00 GiB]
  2 disks
  1 partition
  0 LVM physical volume whole disks
  1 LVM physical volume

From the previous section we know that ``/dev/vg_data/test`` is our LVM.
Once we have our volume, we then have to create a mount point and update our
fstab file with the information on our LVM and our newly created folder.
We update the fstab file so that whenever the server starts up, it mounts our
LVM automatically on our folder.

.. code-block:: shell

  # We will create a folder called 'data' to serve as our mount point
  root@lvm-test:~# mkdir /data

  # We then update our fstab file to have our LVM mount on our '/data' folder.
  root@lvm-test:~# cat /etc/fstab
  LABEL=cloudimg-rootfs	/	 ext4	defaults	0 0
  /dev/vg_data/data   	/data    ext4	defaults	0 0

  # Once this is done, we use the following command to force all volumes listed in the fstab to mount:
  root@lvm-test:~# mount -a

Finally, once we have updated our fstab and forced our LVM to mount, we can
view the mount information of our volumes using the following:

.. code-block:: shell

  # Output truncated for brevity
  root@lvm-test:~# mount
  ...
  /dev/mapper/vg_data-data on /data type ext4 (rw,relatime,data=ordered)

Once this is done, you should be able to access your LVM from your mount point.
