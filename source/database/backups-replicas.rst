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
  | datastore_version_id | 8f2c5796-e1e1-4275-9917-4e3a61cbb76d |
  | description          | None                                 |
  | id                   | bd358777-2c29-4672-a10a-da342e0701ac |
  | instance_id          | 3bc0c29d-b6bc-4729-b6a8-b312fca5d3fc |
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
  | bd358777-2c29-4672-a10a-da342e0701ac | 3bc0c29d-b6bc-4729-b6a8-b312fca5d3fc | db1-backup | COMPLETED | None      | 2020-06-25T00:05:47 |
  +--------------------------------------+--------------------------------------+------------+-----------+-----------+---------------------+

Destroy the instance and create a new one using the backup as a source:

.. code-block:: bash

  $ openstack database instance delete db-instance-1     # wait for it to be deleted...

  $ openstack database instance create db-instance-1-rebuild \
  --flavor e3feb785-af2e-41f7-899b-6bbc4e0b526e \
  --size 5 \
  --datastore mysql \
  --datastore-version 5.7.29 \
  --databases myDB \
  --users dbusr:dbpassword \
  --volume-type b1.standard \
  --backup db1-backup \
  --nic net-id=908816f1-933c-4ff2-8595-f0f57c689e48

  $ openstack database instance list
  +--------------------------------------+-----------------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | ID                                   | Name                  | Datastore | Datastore Version | Status | Flavor ID                            | Size | Region |
  +--------------------------------------+-----------------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | fadf1e7f-8e72-4eba-9bf3-517547afccfd | db-instance-1-rebuild | mysql     | 5.7.29            | BUILD  | e3feb785-af2e-41f7-899b-6bbc4e0b526e |    5 | test-1 |
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

In addition to creating individual backups, you can also use the database
service to create incremental backups. This means you can chain together
backups without needing to create an entirely new source backup each time you
want to save changes. When restoring from an incremental backup, the process
is the same as for a normal backup; The database service handles the
complexity of applying the incremental changes.

To create a new incremental backup we use the following command

.. code-block:: bash

  $ openstack database backup create DATABASE_ID backup1.1 --incremental


For the purposes of this example I have named the incremental backup
*backup1.1*. For any subsequent backups, you would name them 1.2, 1.3 etc.

# In these instances when you have to specify the parent ID, you would use the ID
# number of your previous incremental backup. In this case backup1.1

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
    --flavor e3feb785-af2e-41f7-899b-6bbc4e0b526e \
    --size 5 \
    --volume-type b1.standard  \
    --datastore mysql \
    --datastore-version 5.7.29 \
    --nic net-id=908816f1-933c-4ff2-8595-f0f57c689e48 \
    --replica-of db-instance-1

  $ openstack database instance list
  +--------------------------------------+---------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | ID                                   | Name          | Datastore | Datastore Version | Status | Flavor ID                            | Size | Region |
  +--------------------------------------+---------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | 6bd114d1-7251-42d6-9426-db598c085472 | db-instance-1 | mysql     | 5.7.29            | ACTIVE | e3feb785-af2e-41f7-899b-6bbc4e0b526e |    5 | test-1 |
  | 8ddd73b2-939c-496d-906a-4eab4000fff0 | db-replica-1  | mysql     | 5.7.29            | ACTIVE | e3feb785-af2e-41f7-899b-6bbc4e0b526e |    5 | test-1 |
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
   | 6f4e35e6-58fa-4812-a075-3a20a29edd0b | db-replica-1          | mysql     | 5.7.29            | PROMOTE |           | e3feb785-af2e-41f7-899b-6bbc4e0b526e |    5 | test-1 | replica |
   | 96c3497f-2af4-442a-b5c5-da79b035cc09 | db-instance-1-rebuild | mysql     | 5.7.29            | PROMOTE |           | e3feb785-af2e-41f7-899b-6bbc4e0b526e |    5 | test-1 |         |
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
