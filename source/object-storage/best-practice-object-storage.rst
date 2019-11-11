#################################
Best-practices for object storage
#################################

Follow standard security precautions
====================================

Under the :ref:`best-practices` there are a number of security precautions that
we recommended you follow when conducting any work on your cloud projects. The
important ones to consider for storage are :ref:`access_control`, and password
protection/strength. Following these and the other security best practices will
help to ensure your projects are as safe as possible.

Data Location
=============

When using object storage normally you would endeavour to have the files
you upload into storage kept in the same region closest physically to you,
so that the speed to access them is as fast as possible.
While this is usually the case, because of Catalyst Cloud's data replication
across our regions for our object storage the time it takes to access any
storage object from any geographical location should be consistent.

Logging access
==============

Another best practice when dealing with security for your storage is making
sure you log access and actions taken on the object storage objects; as well
as who committed these actions. This is useful for auditing purposes.

Backup data locally not just on the cloud
=========================================

It is a best practice to backup data of your project. This pertains more to
highly important data that you cannot afford to lose, as opposed to backing up
all data present on the cloud. Because of our high availability and
geographic diversity, data backup for storage in the large majority of cases
will not be an issue. It is still however a best practice in the industry to
create physical backups locally in the event of a catastrophe across the
country.

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
