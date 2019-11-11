#################################
Best-practices for object storage
#################################

Follow standard security precautions
====================================

Under the :ref:`best-practice` there are a number of security precautions that
we recommended you follow when conducting any work on your cloud projects.
The important ones to consider for storage are :ref:`access_control`,
and password protection/strength. Following these and the other
security best practices will help to ensure your projects are as safe as
possible.

Data Location
=============

When using object storage normally you would have to make sure that the files
you upload to storage are kept in the same region you wish to access them.
While this is usually the case, because of our data replication across our
regions this issue is taken care of.

Logging access
==============

Another best practice when dealing with security for your storage is making
sure you log all access and actions taken to the storage object and more
importantly who took those actions. This is useful for auditing purposes and
for accountability.

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
container in object storage the multiple actions will slow each other down. If
you are uploading/downloading large amounts of data then it is a best practice
to schedule these actions, so that the overall performance is not affected.

Deletion policies
=================


There are a number of polices that you may wish to use when it comes to dealing
with deleting data from your storage options. The following are three of the
more common policies.

- Retention policy: This policy dictates that a volume/object cannot be deleted
  until it reaches a certain age.
- Object lock policy: A specific user holds the 'key' to the object and only
  they can choose to delete the instance.
- Versioning policy: when updating a volume it creates a previous 'version' of
  your volume and therefore should your volume become corrupt or be deleted,
  you'll have the old version.

Additionally for object storage, you are able to give different users
permissions for your containers.

- Role policy: Only users that have the correct permissions may see, use,
  access or delete objects in the container (or the container itself) more
  information on this can be found under the :ref:`object-storage-access`
  section.
