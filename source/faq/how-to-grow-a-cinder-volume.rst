#############################
How to grow a cinder volume?
#############################

So you have been succesfully using OpenStack and now one of your volumes has
started filling up.  What is the best, quickest and safest way to grow the
size of your volume?

Well, as always, that depends.

Boot Volumes
============

A quick and safe method is

* Shutdown the instance
* Take a snapshot
* Create volume from snapshot
* Boot instance from volume

This sequence can be performed either through the API/commands or the
dashboard.

A reason to like this method is that the original volume is maintained, it is
quick and cloud-init grows the new instance filesystem to the new volume size
on first boot.

Non-boot Volumes
================

The way to go is:

* Detach the volume from the instance
* Extend the volume
* Attach the volume to the instance
* Adjust the disk within the OS as you would normally
