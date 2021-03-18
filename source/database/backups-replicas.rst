.. _backups-for-databases:

********************
Working with backups
********************

The following is an example of how to set up and recreate an instance using a
backup as a source. You can do this with the database you have already created
during this guide, or create another one for the purposes of testing (since we
will be deleting the database to test the recovery process)

.. code-block:: bash

  # Create a backup of your database instance.
  $ openstack database backup create db-instance-1 db1-backup

  +----------------------+--------------------------------------+
  | Field                | Value                                |
  +----------------------+--------------------------------------+
  | created              | 2020-08-05T22:24:14                  |
  | datastore            | mysql                                |
  | datastore_version    | 5.7.29                               |
  | datastore_version_id | 8f2c5796-e1e1-4275-9917-xxxxxxxxxxxx |
  | description          | None                                 |
  | id                   | bd358777-2c29-4672-a10a-xxxxxxxxxxxx |
  | instance_id          | 3bc0c29d-b6bc-4729-b6a8-xxxxxxxxxxxx |
  | locationRef          | None                                 |
  | name                 | db1-backup                           |
  | parent_id            | None                                 |
  | size                 | None                                 |
  | status               | NEW                                  |
  | updated              | 2020-08-05T22:24:14                  |
  +----------------------+--------------------------------------+

  $ openstack database backup list
  +--------------------------------------+--------------------------------------+------------+-----------+-----------+---------------------+
  | ID                                   | Instance ID                          | Name       | Status    | Parent ID | Updated             |
  +--------------------------------------+--------------------------------------+------------+-----------+-----------+---------------------+
  | bd358777-2c29-4672-a10a-xxxxxxxxxxxx | 3bc0c29d-b6bc-4729-b6a8-xxxxxxxxxxxx | db1-backup | COMPLETED | None      | 2020-06-25T00:05:47 |
  +--------------------------------------+--------------------------------------+------------+-----------+-----------+---------------------+

Destroy the instance and create a new one using the backup as a source:

.. code-block:: bash

  $ openstack database instance delete db-instance-1     # wait for it to be deleted...

  $ openstack database instance create db-instance-1-rebuild \
  e3feb785-af2e-41f7-899b-xxxxxxxxxxxx \
  --size 5 \
  --datastore mysql \
  --datastore_version 5.7.29 \
  --databases myDB \
  --users dbusr:dbpassword \
  --volume_type b1.standard \
  --backup db1-backup \
  --nic net-id=908816f1-933c-4ff2-8595-xxxxxxxxxxxx

  $ openstack database instance list
  +--------------------------------------+-----------------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | ID                                   | Name                  | Datastore | Datastore Version | Status | Flavor ID                            | Size | Region |
  +--------------------------------------+-----------------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | fadf1e7f-8e72-4eba-9bf3-xxxxxxxxxxxx | db-instance-1-rebuild | mysql     | 5.7.29            | BUILD  | e3feb785-af2e-41f7-899b-xxxxxxxxxxxx |    5 | test-1 |
  +--------------------------------------+-----------------------+-----------+-------------------+--------+--------------------------------------+------+--------+

  Connect and check data in there:

  $ mysql -h db-instance-1-rebuild -uusr -p db
  Enter password:

  mysql> SELECT count(*) FROM sbtest1;
  +----------+
  | count(*) |
  +----------+
  |  2000000 |
  +----------+
  1 row in set (0.41 sec)

Incremental backups
===================

In addition to creating a single backup, you can also use the database
service to create incremental backups. This means you can chain together
backups without needing to create an entirely new source backup each time you
want to save changes. When restoring from an incremental backup, the process
is the same as for a normal backup; The database service handles the
complexity of applying the incremental changes.

To create a new incremental backup we use the following command:


.. code-block:: bash

  $ openstack database backup create DATABASE_ID backup1.1 --incremental


For the purposes of this example I have named the incremental backup
*backup1.1*. For any subsequent backups, you would name them 1.2, 1.3 etc.

If we were to go ahead and create a few more backups, we will see how each of
the backups is related to the previous one, using the Parent_ID field:

.. code-block:: bash

  $ openstack database backup list
  +--------------------------------------+--------------------------------------+------------+-----------+--------------------------------------+---------------------+
  | ID                                   | Instance ID                          | Name       | Status    | Parent ID                            | Updated             |
  +--------------------------------------+--------------------------------------+------------+-----------+--------------------------------------+---------------------+
  | bd187812-7f2c-4df1-8d9a-xxxxxxxxxxxx | ac59dcd2-646c-41c7-bfc5-xxxxxxxxxxxx | backup1.2  | COMPLETED | 234682c5-e2b8-4708-9988-xxxxxxxxxxxx | 2020-09-29T02:05:08 |
  | 234682c5-e2b8-4708-9988-xxxxxxxxxxxx | ac59dcd2-646c-41c7-bfc5-xxxxxxxxxxxx | backup1.1  | COMPLETED | eb4a16f7-7663-4ddd-990a-xxxxxxxxxxxx | 2020-09-21T22:42:41 |
  | eb4a16f7-7663-4ddd-990a-xxxxxxxxxxxx | ac59dcd2-646c-41c7-bfc5-xxxxxxxxxxxx | original   | COMPLETED | None                                 | 2020-09-21T22:41:53 |
  +--------------------------------------+--------------------------------------+------------+-----------+--------------------------------------+---------------------+

As you can see, the backups are all related to the same instance, but their
*parent ID* matches the previous incremental backup's *ID*. This shows you the
connection between each of your incremental backups and helps you keep track
of the order, if for some reason your naming convention is changed or isn't
followed.


.. _database_replica:


*****************
Creating replicas
*****************

Replicating a database instance allows you to make a copy of an instance and,
by default, have it run alongside the original. You can also setup a replica
to perform a variety of different tasks. You could have it run on standby
and periodically update to keep up to date with the master. Or you could use
it to run your queries so that the master isn't burdened with the load of large
operations. There are many different uses for having a replica.

While similar to a backup, a replica has some key differences.
The main difference between the two is that, a backup takes what is essentially
a snapshot, of your current database and stores away a list of commands and
values able to restore a new instance to that snapshot's point in time.
While a replica will be a full copy of your database when created and
from there it becomes an independent database instance. It can then be set up
to receive updates or perform a number of functions as mentioned earlier.

The command to create a replica is:

.. code-block:: bash

  $ openstack database instance create db-replica-1
    e3feb785-af2e-41f7-899b-xxxxxxxxxxxx \
    --size 5 \
    --volume_type b1.standard  \
    --datastore mysql \
    --datastore_version 5.7.29 \
    --nic net-id=908816f1-933c-4ff2-8595-xxxxxxxxxxxx \
    --replica_of db-instance-1

  $ openstack database instance list
  +--------------------------------------+---------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | ID                                   | Name          | Datastore | Datastore Version | Status | Flavor ID                            | Size | Region |
  +--------------------------------------+---------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | 6bd114d1-7251-42d6-9426-xxxxxxxxxxxx | db-instance-1 | mysql     | 5.7.29            | ACTIVE | e3feb785-af2e-41f7-899b-xxxxxxxxxxxx |    5 | test-1 |
  | 8ddd73b2-939c-496d-906a-xxxxxxxxxxxx | db-replica-1  | mysql     | 5.7.29            | ACTIVE | e3feb785-af2e-41f7-899b-xxxxxxxxxxxx |    5 | test-1 |
  +--------------------------------------+---------------+-----------+-------------------+--------+--------------------------------------+------+--------+

Once you have a replica up and running, there will be a relationship between
the original, primary database and the secondary, replica database. You are
able to change this relationship by promoting the replica to the primary
database. You may wish to do this after performing some upgrades or tests with
your replica, and now you want it to take over as the primary database. The
process for this is detailed below:

.. Note::

   This method can also be used for failover between your database instances.

.. code-block:: bash

   $ openstack database instance promote db-replica-1

   $ openstack database instance list
   +--------------------------------------+-----------------------+-----------+-------------------+---------+-----------+--------------------------------------+------+--------+---------+
   | ID                                   | Name                  | Datastore | Datastore Version | Status  | Addresses | Flavor ID                            | Size | Region | Role    |
   +--------------------------------------+-----------------------+-----------+-------------------+---------+-----------+--------------------------------------+------+--------+---------+
   | 6f4e35e6-58fa-4812-a075-xxxxxxxxxxxx | db-replica-1          | mysql     | 5.7.29            | PROMOTE |           | e3feb785-af2e-41f7-899b-xxxxxxxxxxxx |    5 | test-1 | replica |
   | 96c3497f-2af4-442a-b5c5-xxxxxxxxxxxx | db-instance-1-rebuild | mysql     | 5.7.29            | PROMOTE |           | e3feb785-af2e-41f7-899b-xxxxxxxxxxxx |    5 | test-1 |         |
   +--------------------------------------+-----------------------+-----------+-------------------+---------+-----------+--------------------------------------+------+--------+---------+

   # wait for status to change to ACTIVE

And once the status reaches active you should be able to see the relationship
between the two has changed by querying the database itself.

.. code-block::

   $ mysql -h IP_ADDRESS_OF_db-replica-1 -uroot -p

   mysql> SHOW SLAVE STATUS\G
   Empty set (0.00 sec)

   $ mysql -h IP_ADDRESS_OF_db-instance-1-rebuild -uroot -p

   mysql> SHOW SLAVE STATUS\G
  *************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 10.0.0.91
                  Master_User: slave_ff70425d
                  Master_Port: 3306
                  ...

   (i.e. db-replica-1 is master and db-instance-1-rebuild is the slave now.)
