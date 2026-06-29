.. _database_upgrades:

##############################
Upgrading the database version
##############################

Currently our Database service supports limited in-place version upgrades.  The upgrade path depends on the
datastore, the current version and the target version.

*****
MySQL
*****

For the MySQL datastore in place upgrades are supported between minor or patch versions.  For example an upgrade from
5.7.29 to 5.7.36 can be perform in place as the change is only between patch versions.

Currently an in-place upgrade can only be triggered via the command line:

.. code-block:: shell

    $ openstack database instance upgrade mydb 5.7.36

Note that there will be a short downtime while the database datastore is upgraded.

Major version upgrades will require raising a support request so that our engineering team can perform the upgrade for
you.

**********
PostgreSQL
**********

Currently in-place upgrades are not supported for PostgreSQL data stores.

Upgrades of databases using the PostgreSQL data store will require a support request.
