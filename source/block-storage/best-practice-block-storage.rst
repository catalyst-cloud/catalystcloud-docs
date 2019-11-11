################################
Best-practices for block storage
################################

Follow standard security precautions
====================================

Under the :ref:`best-practice` there are a number of security precautions that
we recommended you follow when conducting any work on your cloud projects.
The important ones to consider for storage are :ref:`access_control`,
and password protection/strength. Following these and the other
security best practices will help to ensure your projects are as safe as
possible.

Volume names should be unique
=============================

All volumes have a UUID, however it is a best practice to make sure that
you also name your volumes uniquely. This is so that you avoid a situation
where you have two volumes with the same name and you mean to attach them to
different instance, but you're not sure which volume holds which data.

.. note::

  Your names should never include any information on user IDs, emails, project
  information etc. You also need to avoid using '/' in your naming, instead you
  should use '-'


Backup data locally not just on the cloud
=========================================

It is a best practice to backup data of your project. This pertains more to
highly important data that you cannot afford to lose, as opposed to backing up
all data present on the cloud. Because of our high availability and
geographic diversity, data backup for storage in the large majority of cases
will not be an issue. It is still however a best practice in the industry to
create physical backups locally in the event of a catastrophe across the
country.

Deletion policies
=================

There are a number of polices that you may wish to use when it comes to dealing
with deleting data from your storage options. The following are three of the
more common policies.

- Retention policy: This policy dictates that a volume/object cannot be deleted
  until it reaches a certain age.
- Object lock policy: A specific user holds the 'key' to the instance and only
  they can choose to delete the instance.
- Versioning policy: when updating a volume it creates a previous 'version' of
  your volume and therefore should your volume become corrupt or be deleted,
  you'll have the old version.
