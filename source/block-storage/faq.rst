###
FAQ
###

.. _migrating-volumes:

*********************************************
How to migrate between different volume types
*********************************************

At the current time, support for changing volume type on an existing
volume is not supported. However, by creating a new volume with
the desired type, and copying data, we can switch between them.

For the purpose of this example we will assume:

* The operating system involved in Linux, and we recommend doing this
  on a system which is not booted from the original volume
* there is an existing volume attached to the instance and mounted on
  ``/data``
* a new volume of the desired new type has been attached to the instance
  and

  - has been partitioned
  - has a file system created
  - is mounted on ``/mnt/data_new``

We will be using `rsync`_ to perform the transfer as it allows us to maintain
the volumes thin provisioned nature, and preserve the nature of any sparse
files that may exist on the original disk.

The following code block is a template for you to fill in with your
requirements:

.. code-block:: bash

  rsync -avxHAXSW --numeric-ids --info=progress2 /data/ /mnt/data_new/

Where the options are:

.. code-block:: text

  -a  : all files, with permissions, etc..
  -v  : verbose, mention files
  -x  : stay on one file system
  -H  : preserve hard links (not included with -a)
  -A  : preserve ACLs/permissions (not included with -a)
  -X  : preserve extended attributes (not included with -a)
  -S  : handle sparse files, such as virtual disks, efficiently
  -W  : copy files whole (w/o delta-xfer algorithm)
  --info=progress2 : will show the overall progress info and transfer speed
  --numeric-ids : don't map uid/gid values by user/group name

.. _`rsync`: https://rsync.samba.org

****************************
How to grow a cinder volume?
****************************

So you have been successfully using OpenStack, and now one of your volumes has
started filling up. What is the best, quickest and safest way to grow the
size of your volume?

Well, as always, that depends.

============
Boot volumes
============

There are a number of different options, the best option for you to use will
depend on your circumstances.

Create new instance
===================

The best method is to spin up a new instance with a new volume and use
the configuration management tool of your choice to make sure it is as you
want it. Terminate the old instance and attach all the data volumes to the
new instance.

This assumes there is no permanent data stored on the boot volume that is
outside the configuration management tool control.

Use a volume snapshot
=====================

Another method which is quick and safe is to perform a volume snapshot.

The process is as follows:

1. Shut down the instance.
2. Take a volume snapshot.
3. Create volume from snapshot.
4. Boot instance from volume.

This sequence can be performed either through the API/commands or the
dashboard.

A reason to like this method is that the original volume is maintained,
it is quick and cloud-init grows the new instance filesystem to the new
volume size on first boot.

The reasons not to like this method are:

* The host gets new keys, which may upset some applications.
* The original volume and the snapshot cannot be deleted until the newly
  created volume is deleted.
* You will be charged for these cinder volumes and the snapshot.

Old fashioned method
====================

Finally, there is the old fashioned method that involves:

* Create a new bootable volume.
* Shut down instance and detach boot volume.
* Attach the new volume and the original to another instance.
* Perform a copy using tools like dd.

================
Non-boot volumes
================

The way to go is:

* Detach the volume from the instance
* Extend the volume
* Attach the volume to the instance
* Adjust the disk within the OS as you would normally
