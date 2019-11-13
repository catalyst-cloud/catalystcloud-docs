##############
Object storage
##############

Our object storage service is a fully distributed storage system, with no
single points of failure and scalable to the exabyte level. The system is
self-healing and self-managing. Data stored in object storage is asynchronously
replicated to preserve three replicas of the data in different cloud regions.
The system runs frequent CRC checks to protect data from soft corruption (bit
rot). The corruption of a single bit can be detected and automatically restored
to a healthy state. The loss of a region, server or a disk leads to the data
being quickly recovered from another disk, server or region.

Data Location
=============

When using object storage, the normal practice for where to keep your data
is the region closest to your physical location. This is so that the speed to
access your data is the quickest it can be.
While this is usually the case, because of Catalyst Cloud's data replication
across our regions the time it takes to access any storage object from any
geographical location should be consistent.

Logging access
==============

Logging who has accessed your storage objects and what actions the took on them
is a standard best practice. This is so that you can clearly see who took
these actions and when they took place. This is especially useful for auditing
purposes.

Schedule uploading to not slow traffic
======================================

If many different users are trying to upload or download to/from the same
container in object storage; the multiple actions will slow each other down. If
you are uploading/downloading large amounts of data then it is a best practice
to schedule these actions, so that the overall performance is not affected.

Deletion policies
=================

There are a number of polices that you may wish to use when it comes to dealing
with deleting data from your storage options. The following are some of the
more common policies.

- Retention policy: This policy dictates that a volume/object cannot be deleted
  until it reaches a certain age.
- Object lock policy: A specific user holds the 'key' to the object and only
  they can choose to delete the instance.
- Versioning policy: When updating a volume it creates a previous version.
  Meaning should your volume become corrupt or be deleted unintentionally, you
  will still have the old version so that you haven't lost everything. This is
  a mixture of a delete and backup policy.

Additionally for object storage, you are able to give different users
permissions for your containers.

- Role policy: Only users that have the correct permissions may see, use,
  access or delete objects in the container (or the container itself) more
  information on this can be found under the :ref:`object-storage-access`
  section.
