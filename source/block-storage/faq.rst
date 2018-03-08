###
FAQ
###

****************************
How to grow a cinder volume?
****************************

So you have been successfully using OpenStack, and now one of your volumes has
started filling up. What is the best, quickest and safest way to grow the
size of your volume?

Well, as always, that depends.

************
Boot Volumes
************

This is difficult in OpenStack, as there is not an easy and obvious choice.

Create New Instance
===================

The best method is to spin up a new instance with a new volume and use
the configuration management tool of your choice to make sure it is as you
want it. Terminate the old instance and attach all the data volumes to the
new instance.

This assumes there is no permanent data stored on the boot volume that is
outside the configuration management tool control.

Use a Volume Snapshot
=====================

Another method which is quick and safe is to perform a volume snapshot.

The process is as follows:

* Shut down the instance.
* Take a volume snapshot.
* Create volume from snapshot.
* Boot instance from volume.

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

Old Fashioned Method
====================

Finally, there is the old fashioned method that involves:

* Create a new bootable volume.
* Shut down instance and detach boot volume.
* Attach the new volume and the original to another instance.
* Perform a copy using tools like dd.

Non-boot Volumes
================

The way to go is:

* Detach the volume from the instance
* Extend the volume
* Attach the volume to the instance
* Adjust the disk within the OS as you would normally
