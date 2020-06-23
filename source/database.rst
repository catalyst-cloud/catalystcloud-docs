.. _database_page:

############################
Database creation and access
############################

In this section we will work through the steps required to create a new
database instance and cover different common topics to do with the database
service.

*********************************
Gathering necessary information
*********************************

In order to launch a new database instance we need to first decide on a few
options, these include:

* The **datastore type** which defines the type of database to be deployed.
  In this instance we are using mySQL.
* The datastore type will in turn define the  **database version** we are able
  to pick.
* The **database flavor**, which determines the vCPU and RAM assigned to the
  instance.

.. Note::
  It is also necessary to have an existing network on the project that you
  wish to deploy the database instance to.

First, lets determine what datastore types and versions are available to us.

.. code-block:: bash

  $ openstack datastore list
  +--------------------------------------+-------+
  | ID                                   | Name  |
  +--------------------------------------+-------+
  | c681e699-5493-4599-9d9c-08eb7d21c2de | mysql |
  +--------------------------------------+-------+


Now lets see what versions of mysql are available to us. We can do this a
couple of ways, either by looking at the full description of the datastore type
or by explicitly querying the version of a particular datastore type:

.. code-block:: bash

  $ openstack datastore show mysql
  +---------------+-------------------------------------------------+
  | Field         | Value                                           |
  +---------------+-------------------------------------------------+
  | id            | c681e699-5493-4599-9d9c-08eb7d21c2de            |
  | name          | mysql                                           |
  | versions (id) | 5.7 (0b845a75-a0cf-4354-b7a5-7bfdd7c1e758)      |
  |               | 5.7-10.0 (2e1eca24-e365-4229-835e-76537220be81) |
  |               | 5.7.11 (43a4c919-b03e-4534-a92a-c9cb10471ac3)   |
  +---------------+-------------------------------------------------+

  $ openstack datastore version list mysql
  +--------------------------------------+----------+
  | ID                                   | Name     |
  +--------------------------------------+----------+
  | 0b845a75-a0cf-4354-b7a5-7bfdd7c1e758 | 5.7      |
  | 2e1eca24-e365-4229-835e-76537220be81 | 5.7-10.0 |
  | 43a4c919-b03e-4534-a92a-c9cb10471ac3 | 5.7.11   |
  +--------------------------------------+----------+

Next we need to decide on the resource requirements for our database instance.
We do this by picking a flavor from the available list:

.. code-block:: bash

  $ openstack database flavor list
  +--------------------------------------+------------------+-------+-------+------+-----------+
  | ID                                   | Name             |   RAM | vCPUs | Disk | Ephemeral |
  +--------------------------------------+------------------+-------+-------+------+-----------+
  | 01b42bbc-347f-43e8-9a07-0a51105a5527 | c1.c8r8          |  8192 |     8 |   10 |         0 |
  | 0c7dc485-e7cc-420d-b118-021bbafa76d7 | c1.c2r8          |  8192 |     2 |   10 |         0 |
  | 1750075c-cd8a-4c87-bd06-a907db83fec6 | c1.c1r2          |  2048 |     1 |   10 |         0 |
  | 1d760238-67a7-4415-ab7b-24a88a49c117 | c1.c8r32         | 32768 |     8 |   10 |         0 |
  | 3931e022-24e7-4678-bc3f-ee86ec129819 | c1.c1r1          |  1024 |     1 |    8 |         0 |
  | 3d11be79-5788-4d70-9058-4ccd20c750ee | c1.c1r05         |   512 |     1 |   10 |         0 |
  | 45060aa3-3400-4da0-bd9d-9559e172f678 | c1.c4r8          |  8192 |     4 |   10 |         0 |
  | 4efb43da-132e-4b50-a9d9-b73e827938a9 | c1.c2r16         | 16384 |     2 |   10 |         0 |
  | 62473bef-f73b-4265-a136-e3ae87e7f1e2 | c1.c4r4          |  4096 |     4 |   10 |         0 |
  | 746b8230-b763-41a6-954c-b11a29072e52 | c1.c1r4          |  4096 |     1 |   10 |         0 |
  | 7b74c2c5-f131-4981-90ef-e1dc1ae51a8f | c1.c8r16         | 16384 |     8 |   10 |         0 |
  | a197eac1-9565-4052-8199-dfd8f31e5553 | c1.c8r4          |  4096 |     8 |   10 |         0 |
  | a80af444-9e8a-4984-9f7f-b46532052a24 | c1.c4r2          |  2048 |     4 |   10 |         0 |
  | b152339e-e624-4705-9116-da9e0a6984f7 | c1.c4r16         | 16384 |     4 |   10 |         0 |
  | b4a3f931-dc86-480c-b7a7-c34b2283bfe7 | c1.c4r32         | 32768 |     4 |   10 |         0 |
  | c093745c-a6c7-4792-9f3d-085e7782eca6 | c1.c2r4          |  4096 |     2 |   10 |         0 |
  | e3feb785-af2e-41f7-899b-6bbc4e0b526e | c1.c2r2          |  2048 |     2 |   10 |         0 |
  +--------------------------------------+------------------+-------+-------+------+-----------+

Here is a table of the minimum requirements for databases based on their type:

+---------+----------+-----------+-------+
|Database | RAM (MB) | Disk (GB) | VCPUs |
+=========+==========+===========+=======+
|MySQL    |512       | 5         |1      |
+---------+----------+-----------+-------+
|Cassandra|2048      | 5         |1      |
+---------+----------+-----------+-------+
|MongoDB  |1024      | 5         |1      |
+---------+----------+-----------+-------+
|Redis    |512       | 5         |1      |
+---------+----------+-----------+-------+

***********************************
Launching the new database instance
***********************************

Based on the information we gathered in the previous section we are now
able to create our database instance. This will require a private network from
your project, that we can attach the database instance to.

.. code-block:: bash

  $ openstack network list
  +--------------------------------------+---------------------+--------------------------------------+
  | ID                                   | Name                | Subnets                              |
  +--------------------------------------+---------------------+--------------------------------------+
  | 908816f1-933c-4ff2-8595-f0f57c689e48 | database-network    | af0f251c-0a36-4bde-b3bc-e6167eda3d1e |
  +--------------------------------------+---------------------+--------------------------------------+

After finding a suitable network to host our database. We take the network ID,
alongside the information on our preferred flavor and we construct
the following command to create our new instance:

.. code-block:: bash

  $ openstack database instance create db-instance-1 c1.c1r4 \
  --size 3 \
  --datastore mysql \
  --datastore_version 5.7 \
  --databases myDB \
  --users dbusr:dbpassword \
  --volume_type b1.standard \
  --nic net-id=908816f1-933c-4ff2-8595-f0f57c689e48

  +-------------------+--------------------------------------+
  | Field             | Value                                |
  +-------------------+--------------------------------------+
  | created           | 2019-04-13T23:34:20                  |
  | datastore         | mysql                                |
  | datastore_version | 5.7                                  |
  | flavor            | 746b8230-b763-41a6-954c-b11a29072e52 |
  | id                | b14d5ed3-b4d0-4906-b68d-58d882f2cd09 |
  | name              | db-instance-1                        |
  | region            | test-1                               |
  | status            | BUILD                                |
  | updated           | 2019-04-13T23:34:20                  |
  | volume            | 3                                    |
  +-------------------+--------------------------------------+

We have to wait while the instance builds. Keep checking on the status of the
new instance, once it is ``ACTIVE`` we can continue.

.. code-block:: bash

  $ openstack database instance list
  +--------------------------------------+---------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | ID                                   | Name          | Datastore | Datastore Version | Status | Flavor ID                            | Size | Region |
  +--------------------------------------+---------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | b14d5ed3-b4d0-4906-b68d-58d882f2cd09 | db-instance-1 | mysql     | 5.7               | BUILD  | 746b8230-b763-41a6-954c-b11a29072e52 |    3 | test-1 |
  +--------------------------------------+---------------+-----------+-------------------+--------+--------------------------------------+------+--------+

Now let's view the details of our instance so that we can find the IP address
that has been assigned to it.

.. code-block:: bash

  $ openstack database instance show db-instance-1
  +-------------------+--------------------------------------+
  | Field             | Value                                |
  +-------------------+--------------------------------------+
  | created           | 2019-04-13T23:34:20                  |
  | datastore         | mysql                                |
  | datastore_version | 5.7                                  |
  | flavor            | 746b8230-b763-41a6-954c-b11a29072e52 |
  | id                | b14d5ed3-b4d0-4906-b68d-58d882f2cd09 |
  | ip                | 10.0.0.16                            |
  | name              | db-instance-1                        |
  | region            | test-1                               |
  | status            | BUILD                                |
  | updated           | 2019-04-13T23:35:13                  |
  | volume            | 3                                    |
  +-------------------+--------------------------------------+

The final step in this section is to see what databases we have running within
this instance.

.. code-block:: bash

  $ openstack database db list db-instance-1
  +------+
  | Name |
  +------+
  | myDB |
  | sys  |
  +------+


******************
Configuring access
******************

If a user was not added when the instance was created then the only
user account that exists is the ``root`` user. However this is disabled by
default.

We can confirm this is the case by doing the following:

.. code-block:: bash

  $ openstack database root show db-instance-1
  +-----------------+-------+
  | Field           | Value |
  +-----------------+-------+
  | is_root_enabled | False |
  +-----------------+-------+

To enable the root login, run the following command against your database
instance.

.. code-block:: bash

  $ openstack database root enable db-instance-1
  +----------+--------------------------------------+
  | Field    | Value                                |
  +----------+--------------------------------------+
  | name     | root                                 |
  | password | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |
  +----------+--------------------------------------+

.. Note::

  A random password will be generated for the root user, this will need to be
  noted down as it cannot be retrieved again. If the password is misplaced the
  only option is to re-run the enable command which will generate a new
  random password.

To confirm the root account is now enabled, simply re-run the same command as
above.

.. code-block:: bash

  $ openstack database root show db-instance-1
  +-----------------+-------+
  | Field           | Value |
  +-----------------+-------+
  | is_root_enabled | True  |
  +-----------------+-------+

We can check that this has worked if we are able to access the database and run
the following query:

.. code-block:: bash

  $ mysql -h 10.0.0.16 -u root -p -e 'SELECT USER()'
  Enter password:
  +----------------+
  | USER()         |
  +----------------+
  | root@10.0.0.16 |
  +----------------+

Creating new users
==================

While it is possible to create a database user when launching your database
instance (using the ``--users <username>:<password>`` argument) it is more than
likely that further users will need to be added over time.

This can be done using the openstack commandline. Below we can see two example
of how we can add a new user to our myDB database. One example creates a
user that can access the database from any location. This is the same behaviour
that is displayed when the user is created as part of the initial database
instance creation.

The other example uses the ``--host`` argument which allows a user to be
created that can only connect from the specified IP address.

.. code-block:: bash

  $ openstack database user create db-instance-1 newuser userpass --databases myDB

  $ openstack database user list db-instance-1
  +---------+-----------+-----------+
  | Name    | Host      | Databases |
  +---------+-----------+-----------+
  | dbusr   | %         | myDB      |
  | newuser | %         | myDB      |
  +---------+-----------+-----------+


  $ openstack database user create db-instance-1 newuser2 userpass2 --host 10.0.0.15 --databases myDB

  $ openstack database user list db-instance-1
  +----------+-----------+-----------+
  | Name     | Host      | Databases |
  +----------+-----------+-----------+
  | dbusr    | %         | myDB      |
  | newuser  | %         |           |
  | newuser2 | 10.0.0.15 | myDB      |
  +----------+-----------+-----------+

Before moving on let's remove our new test users.

.. code-block:: bash

  $ openstack database user delete db-instance-1 newuser

  $ openstack database user delete db-instance-1 newuser2

*****************************
Adding and deleting databases
*****************************

Once you have a database instance deployed it is fairly simple to add and
remove databases from it.

.. code-block:: bash

  $ openstack database db create db-instance-1 myDB2

To check the results we use the following command:

.. code-block:: bash

  $ openstack database db list db-instance-1
  +-------+
  | Name  |
  +-------+
  | myDB  |
  | myDB2 |
  | sys   |
  +-------+

To delete a database, you can use the following command:

.. code-block:: bash

  $ openstack database instance delete db1
  # wait until the console returns, it will reply with a message saying your database was deleted.

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

  $ openstack database backup list
  +--------------------------------------+--------------------------------------+------------+-----------+-----------+---------------------+
  | ID                                   | Instance ID                          | Name       | Status    | Parent ID | Updated             |
  +--------------------------------------+--------------------------------------+------------+-----------+-----------+---------------------+
  | 09e93fcd-c384-4be1-b9ec-c6101d960f45 | bfe87861-5780-4a4a-af4b-47b045400de6 | db1-backup | COMPLETED | None      | 2019-03-28T00:22:42 |
  +--------------------------------------+--------------------------------------+------------+-----------+-----------+---------------------+

Destroy the instance and create a new one using the backup as a source:

.. code-block:: bash

  $ openstack database instance delete db-instance-1     # wait for it to be deleted...
  $ openstack database instance create db-instance-1-rebuild c1.c1r4 \
    --size 3 \
    --volume_type b1.standard \
    --databases myDB \
    --users dbusr:dbpassword \
    --datastore mysql \
    --datastore_version 5.7 \
    --backup db1-backup \
    --nic net-id=908816f1-933c-4ff2-8595-f0f57c689e48

  $ openstack database instance list
  +--------------------------------------+------------------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | ID                                   | Name                   | Datastore | Datastore Version | Status | Flavor ID                            | Size | Region |
  +--------------------------------------+------------------------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | 6bd114d1-7251-42d6-9426-db598c085472 | db-instance-1-rebuild  | mysql     | 5.7               | ACTIVE | e3feb785-af2e-41f7-899b-6bbc4e0b526e |    4 | test-1 |
  +--------------------------------------+------------------------+-----------+-------------------+--------+--------------------------------------+------+--------+

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
  | 6bd114d1-7251-42d6-9426-db598c085472 | db-instance-1 | mysql     | 5.7               | ACTIVE | e3feb785-af2e-41f7-899b-6bbc4e0b526e |    4 | test-1 |
  | 8ddd73b2-939c-496d-906a-4eab4000fff0 | db-replica-1  | mysql     | 5.7               | ACTIVE | e3feb785-af2e-41f7-899b-6bbc4e0b526e |    4 | test-1 |
  +--------------------------------------+---------------+-----------+-------------------+--------+--------------------------------------+------+--------+

************
Viewing logs
************

Logging is important for keeping a well maintained database. In the following
example we will explain how to publish a slow_query log. These are a
performance log that consists of SQL statements that have taken longer than
the specified long_query_time to execute.

The first thing we have to do is check whether we have logging enabled on our
instance or not.

.. code-block:: bash

  $ openstack database log list db-instance-1
  +------------+------+----------+-----------+---------+-----------+--------+
  | Name       | Type | Status   | Published | Pending | Container | Prefix |
  +------------+------+----------+-----------+---------+-----------+--------+
  | slow_query | USER | Disabled |         0 |       0 | None      | None   |
  | general    | USER | Disabled |         0 |       0 | None      | None   |
  +------------+------+----------+-----------+---------+-----------+--------+

At the moment our, database instance does not have logging enabled. The
following shows how to enable slow_query specifically.

.. code-block:: bash

  $ openstack database log enable db-instance-1 slow_query
  +-----------+----------------------------------------------------------------+
  | Field     | Value                                                          |
  +-----------+----------------------------------------------------------------+
  | container | None                                                           |
  | metafile  | 6bd114d1-7251-42d6-9426-db598c085472/mysql-slow_query_metafile |
  | name      | slow_query                                                     |
  | pending   | 182                                                            |
  | prefix    | None                                                           |
  | published | 0                                                              |
  | status    | Ready                                                          |
  | type      | USER                                                           |
  +-----------+----------------------------------------------------------------+

  # Check to confirm this action

  $ openstack database log list db1
  +------------+------+----------+-----------+---------+-----------+--------+
  | Name       | Type | Status   | Published | Pending | Container | Prefix |
  +------------+------+----------+-----------+---------+-----------+--------+
  | slow_query | USER | Ready    |         0 |     182 | None      | None   |
  | general    | USER | Disabled |         0 |       0 | None      | None   |
  +------------+------+----------+-----------+---------+-----------+--------+

Finally we publish the log using:

.. code-block:: bash

  $ trove log-publish db1 slow_query
  +-----------+----------------------------------------------------------------+
  | Property  | Value                                                          |
  +-----------+----------------------------------------------------------------+
  | container | database_logs                                                  |
  | metafile  | 6bd114d1-7251-42d6-9426-db598c085472/mysql-slow_query_metafile |
  | name      | slow_query                                                     |
  | pending   | 0                                                              |
  | prefix    | 6bd114d1-7251-42d6-9426-db598c085472/mysql-slow_query/         |
  | published | 182                                                            |
  | status    | Published                                                      |
  | type      | USER                                                           |
  +-----------+----------------------------------------------------------------+

  $ openstack object list database_logs
  +--------------------------------------------------------------------------------------+
  | Name                                                                                 |
  +--------------------------------------------------------------------------------------+
  | 6bd114d1-7251-42d6-9426-db598c085472/mysql-slow_query/log-2019-03-28T01:25:32.259223 |
  | 6bd114d1-7251-42d6-9426-db598c085472/mysql-slow_query_metafile                       |
  +--------------------------------------------------------------------------------------+

