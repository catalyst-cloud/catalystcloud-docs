############################
What is Instance Boot Source
############################


Ephemeral vs Persistent
=======================

Firstly, lets clarify what this means. Ephemeral storage is that which is provided by the compute instance on the instance. It is only available for the lifetime of the instance so when the instance is terminated or is subject to failure all of the local storage associated with that instance will disappear.

Persistent storage on the other hand means that the resource resides on block (Cinder) or object (Swift) storage and outlives any other resource and is always available, regardless of the state of a running instance.

Select the boot source
======================

+-----------------------------------------------+------------------------------------------------------------+------------+-----------+
| Boot Source                                   | Description                                                | Type       | Backed By |
+===============================================+============================================================+============+===========+
| Boot from image                               | This option allows a user to specify an image              | Ephemeral  | Ceph      |
|                                               | from the Glance repository to copy into an ephemeral disk. |            |           |
+-----------------------------------------------+------------------------------------------------------------+------------+-----------+
| Boot from snapshot                            | This option allows a user to specify an instance snapshot  | Ephemeral  |           |
|                                               | to use as the root disk; the snapshot is copied into an    |            |           |
|                                               | ephemeral disk.                                            |            |           |
+-----------------------------------------------+------------------------------------------------------------+------------+-----------+
| Boot from volume                              | This option allows a user to specify a Cinder volume (by   | Persistent | Ceph      |
|                                               | name or UUID) that should be directly attached to the      |            |           |
|                                               | instance as the root disk; no copy is made into an         |            |           |
|                                               | ephemeral disk and any content stored in the volume is     |            |           |
|                                               | persistent.                                                |            |           |
+-----------------------------------------------+------------------------------------------------------------+------------+-----------+
| Boot from image (create new volume)           | This option allows a user to specify an image from the     | Persistent | Ceph      |
|                                               | Glance repository to be copied into a persistent Cinder    |            |           |
|                                               | volume, which is subsequently attached as the root disk    |            |           |
|                                               | for the instance.                                          |            |           |
+-----------------------------------------------+------------------------------------------------------------+------------+-----------+
| Boot from volume snapshot (create new volume) | This option allows a user to specify a Cinder volume       | Persistent | Ceph      |
|                                               | snapshot (by name or UUID) that should be used as the root |            |           |
|                                               | disk; the snapshot is copied into a new, persistent Cinder |            |           |
|                                               | volume which is subsequently attached as the root disk for |            |           |
|                                               | the instance.                                              |            |           |
+-----------------------------------------------+------------------------------------------------------------+------------+-----------+
