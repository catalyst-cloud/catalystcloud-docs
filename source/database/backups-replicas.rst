
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

  $ openstack database backup list
  +--------------------------------------+--------------------------------------+------------+-----------+-----------+---------------------+
  | ID                                   | Instance ID                          | Name       | Status    | Parent ID | Updated             |
  +--------------------------------------+--------------------------------------+------------+-----------+-----------+---------------------+
  | c32c2d72-106e-40ed-8cb6-e4bd445c22fa | 373b1bd0-31c8-4299-bb07-9abfcd57120b | db1-backup | COMPLETED | None      | 2020-06-25T00:05:47 |
  +--------------------------------------+--------------------------------------+------------+-----------+-----------+---------------------+

Destroy the instance and create a new one using the backup as a source:

.. code-block:: bash

  $ openstack database instance delete db-instance-1     # wait for it to be deleted...
  $ openstack database instance create db-instance-1-rebuild c1.c1r4 \
    --size 5 \
    --volume_type b1.standard \
    --databases myDB \
    --users dbusr:dbpassword \
    --datastore mysql \
    --datastore_version 5.7 \
    --backup db1-backup \
    --nic net-id=908816f1-933c-4ff2-8595-f0f57c689e48

  $ openstack database instance list
  +--------------------------------------+-----------------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | ID                                   | Name                  | Datastore | Datastore Version | Status | Flavor ID                            | Size | Region |
  +--------------------------------------+-----------------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | fadf1e7f-8e72-4eba-9bf3-517547afccfd | db-instance-1-rebuild | mysql     | 5.7               | BUILD  | 746b8230-b763-41a6-954c-b11a29072e52 |    5 | test-1 |
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

  $ openstack database instance create db-replica-1 c1.c1r4 --size 3 \
    --volume_type b1.standard  \
    --datastore mysql \
    --datastore_version 5.7 \
    --nic net-id=908816f1-933c-4ff2-8595-f0f57c689e48 \
    --replica_of db-instance-1

  $ openstack database instance list
  +--------------------------------------+---------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | ID                                   | Name          | Datastore | Datastore Version | Status | Flavor ID                            | Size | Region |
  +--------------------------------------+---------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | 6bd114d1-7251-42d6-9426-db598c085472 | db-instance-1 | mysql     | 5.7               | ACTIVE | e3feb785-af2e-41f7-899b-6bbc4e0b526e |    5 | test-1 |
  | 8ddd73b2-939c-496d-906a-4eab4000fff0 | db-replica-1  | mysql     | 5.7               | ACTIVE | e3feb785-af2e-41f7-899b-6bbc4e0b526e |    5 | test-1 |
  +--------------------------------------+---------------+-----------+-------------------+--------+--------------------------------------+------+--------+
