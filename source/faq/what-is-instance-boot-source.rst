#############################
What is Instance Boot Source?
#############################

When creating a new instance via the dashboard you are asked to select an
Instance Boot Source. This is the template used to create an instance. You can
use a snapshot of an existing instance, an image, or a volume (if enabled). You
can also choose to use persistent storage by creating a new volume.

Lets clarify these terms.

Images
======

These are pre-configured operating system images that are available for
selection as a boot source. Images are provided by the OpenStack service known
as Glance. When booting from an image you can elect to create a new volume from
the image. If you choose to create a new volume you need to decide if you want
to the volume deleted on instance termination.

Volumes
=======

Volumes are block devices provided by the Cinder service that can be attached
to instances. Volumes can be used as a boot source provided they contain an
appropriate operating system.

Instance Snapshot
=================

Instances that have been snapshotted can be selected as a boot source. Instance
snapshots are Images of the type "Snapshot".

Volume Snapshot
===============

Volumes that have been snapshotted can be selected as a boot source.


Ephemeral vs Persistent
=======================

Ephemeral storage is only available for the lifetime of the instance so when
the instance is terminated, any data that was stored on it is lost. It is
stored in the same block storage as persistent data to allow instances to
retain their ephemeral storage if the instance is live migrated to another
physical hypervisor.

Persistent storage on the other hand will persist when instances are rebooted.

Select the boot source
======================

+--------------------+-----------------------------------+------------+
| Boot Source        | Description                       | Type       |
|                    |                                   |            |
+====================+===================================+============+
| Image, do not      | This option allows a user to      | Ephemeral  |
| create new volume  | specify an image from the Glance  |            |
|                    | repository to copy into an        |            |
|                    | ephemeral disk.                   |            |
+--------------------+-----------------------------------+------------+
| Image,             | This option allows a user to      | Persistent |
| create new volume, | specify an image from the Glance  |            |
| do not delete      | repository to copy into a         |            |
| volume on terminate| persistent volume.                |            |
+--------------------+-----------------------------------+------------+
| Image,             | This option allows a user to      | Ephemeral  |
| create new volume, | specify an image from the Glance  |            |
| delete volume on   | repository to copy into a         |            |
| terminate          | volume which will be deleted on   |            |
|                    | termination.                      |            |
+--------------------+-----------------------------------+------------+
| Instance Snapshot  | This option allows a user to      | Ephemeral  |
|                    | specify an instance snapshot to   |            |
|                    | use as the root disk; the         |            |
|                    | disk is ephemeral.                |            |
+--------------------+-----------------------------------+------------+
| Volume, do not     | This option allows a user to      | Persistent |
| delete on terminate| specify a Cinder volume (by name  |            |
|                    | or UUID) that should be directly  |            |
|                    | attached to the instance as the   |            |
|                    | root disk; any content stored in  |            |
|                    | volume will persist on instance   |            |
|                    | termination.                      |            |
+--------------------+-----------------------------------+------------+
| Volume,            | This option allows a user to      | Ephemeral  |
| delete on terminate| specify a Cinder volume (by name  |            |
|                    | or UUID) that should be directly  |            |
|                    | attached to the instance as the   |            |
|                    | root disk; the volume will be     |            |
|                    | deleted on termination.           |            |
+--------------------+-----------------------------------+------------+
| Volume Snapshot,   | This option allows a user to      | Persistent |
| do not delete on   | specify a Cinder volume snapshot  |            |
| terminate          | (by name or UUID) that should be  |            |
|                    | directly attached to the instance |            |
|                    | as the root disk; the volume will |            |
|                    | persist on instance termination.  |            |
+--------------------+-----------------------------------+------------+
| Volume Snapshot,   | This option allows a user to      | Ephemeral  |
| delete on terminate| specify a Cinder volume snapshot  |            |
|                    | (by name or UUID) that should be  |            |
|                    | directly attached to the instance |            |
|                    | as the root disk; the volume will |            |
|                    | be deleted on termination.        |            |
+--------------------+-----------------------------------+------------+
