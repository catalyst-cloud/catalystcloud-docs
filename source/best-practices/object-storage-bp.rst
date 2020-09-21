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

*************
Data location
*************

When using object storage, the normal practice for where to hold your data is
the region closest to your physical location. This is so that the
speed it takes to access your data is the quickest it can possibly be.
However because of Catalyst Cloud's data replication across our regions the
time it takes to access any storage object from across any of our regions
should be consistent. That means you won't have to worry about where to
upload your data, it will always be available to you with no drop in access
speed regardless of where you are.

**************
Logging access
**************

For both security and auditing reasons, logging who has accessed your storage
objects and what actions the took on them is a standard best practice.

************************************
Schedule actions to not slow traffic
************************************

If many different users are trying to upload or download to/from the same
container in object storage; the multiple actions will slow each other down. If
you are uploading/downloading large amounts of data then it is a best practice
to schedule these actions, so that the overall performance is not affected.

*****************
Deletion policies
*****************

There are a number of polices that you may wish to use when it comes to dealing
with deleting data from your storage options. The following are some of the
more common policies.

- Retention policy: This policy dictates that a volume/object cannot be deleted
  until it reaches a certain age.
- Object lock policy: The storage object is 'locked' and a specific user holds
  the 'key' to the instance and only they can choose to delete data from
  the instance or the instance itself.
- Versioning policy: Whenever your volume is changed a new version is created
  and the previous state of the storage object is saved. Should your newest
  version suffer some failure, you have the option to reload the previous
  saved state. This is a mixture of a delete and backup policy.
- Role policy: Only users that have the correct permissions may see, use,
  access or delete objects in the container (or the container itself) more
  information on this can be found under the :ref:`object-storage-access`
  section.
