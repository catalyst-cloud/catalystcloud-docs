############################
Database creation and access
############################


In this section we will work through the steps required to create a new
database instance through the database service.

*********************************
Gathering
*********************************

In order to launch a new database instance we need to first decide on a few
options, these include.

* The ``datastore type`` which defines the type of database to be deployed.
* The datastore type will in turn define the  ``database version`` we are able
  to pick.
* The ``database flavor``, which determines the vCPU and RAM assigned to the
  instance.

It is also necessary to have an existing network in the project and region
that you wish to deploy the database instance to.

First lets determine what datastore types and version are available to us.

.. code-block:: bash

  $ openstack datastore list
  +--------------------------------------+-------+
  | ID                                   | Name  |
  +--------------------------------------+-------+
  | c681e699-5493-4599-9d9c-08eb7d21c2de | mysql |
  +--------------------------------------+-------+


Now lets see what versions of mysql are available to us. We can do this a
couple of ways, either by looking at the full description of the datastore type
or by explicitly querying the version of a particular datastore type

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
First let's view the available database instance flavors.

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

Minimum requirements for databases

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

Based on the information we gathered in the previous section we will now create

This requires a private network.

.. code-block:: bash

  $ openstack network list
  +--------------------------------------+-----------------+--------------------------------------+
  | ID                                   | Name            | Subnets                              |
  +--------------------------------------+-----------------+--------------------------------------+
  | 908816f1-933c-4ff2-8595-f0f57c689e48 | glyn-network    | af0f251c-0a36-4bde-b3bc-e6167eda3d1e |
  +--------------------------------------+-----------------+--------------------------------------+

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


Check on the status os the new instance, once it ia ``ACTIVE`` we can continue.

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

The final step is this section is to see what databases we have running within
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
user account that exists is the ``root`` user. This is disabled by default.

We can confirm this by doing the following.

.. code-block:: bash

  $ openstack database root show db1
  +-----------------+-------+
  | Field           | Value |
  +-----------------+-------+
  | is_root_enabled | False |
  +-----------------+-------+

To enable the root login, run the following command against your database
instance.

.. code-block:: bash

  $ openstack database root enable db1
  +----------+--------------------------------------+
  | Field    | Value                                |
  +----------+--------------------------------------+
  | name     | root                                 |
  | password | yxWY0Ky7punbW1w2HbRb2dUPduAUR0QCicdB |
  +----------+--------------------------------------+

.. Note::

  A random password will be generated for the root user, this will need to be
  noted down as it cannot be retrieved again. If the password is misplaced the
  only option is to re-run the enable command which will generate a new
  random password.

To confirm the the root account is now enabled simply re-run the same command
as above.

.. code-block:: bash

  $openstack database root show db1
  +-----------------+-------+
  | Field           | Value |
  +-----------------+-------+
  | is_root_enabled | True  |
  +-----------------+-------+

.. code-block:: bash

  $ mysql -h 10.0.0.14 -u root -p -e 'SELECT USER()'
  Enter password:
  +----------------+
  | USER()         |
  +----------------+
  | root@10.0.0.16 |
  +----------------+



.. code-block:: bash

  $ openstack database user create db-instance-1 newuser userpass --databases myDB
  $ openstack database user list db-instance-1
  +---------+------+-----------+
  | Name    | Host | Databases |
  +---------+------+-----------+
  | dbusr   | %    | myDB      |
  | newuser | %    | myDB      |
  +---------+------+-----------+


Creating new users
==================

While it is possible to create a database user when launching your database
instance using the ``--users <username>:<password>`` argument it is more than
likely that further users will need to be added over time.

This can be done using the opensrack commandline. Below we can see two example
of how we can add a new user to our myDB databse. The first example creates a
user that access the databse from any location. This is the same behaviour that
is displayed when the user is created as part of the initial database instance
creation.

The second example uses the ``--host`` argument which allows a user to be
created that only can only connect from the specified IP address.

.. code-block:: bash

  $ openstack database user create db-instance-1 newuser userpass --host 10.0.0.15 --databases myDB

  $ openstack database user list db-instance-1
  +---------+-----------+-----------+
  | Name    | Host      | Databases |
  +---------+-----------+-----------+
  | dbusr   | %         | myDB      |
  | newuser | 10.0.0.15 | myDB      |
  +---------+-----------+-----------+

  $ openstack database user create db-instance-1 newuser2 userpass2 myDB

  $ openstack database user list db-instance-1
  +----------+-----------+-----------+
  | Name     | Host      | Databases |
  +----------+-----------+-----------+
  | dbusr    | %         | myDB      |
  | newuser2 | %         |           |
  | newuser  | 10.0.0.15 | myDB      |
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


********************
Working with backups
********************
The following is an
example of how to set up and recreate an instance using a backup as a source.
You can do this with the database you've already created using this guide, or
create another one for the purposes of testing (since we will be deleting a
database to test the backup process)

.. code-block:: bash

  $ openstack database backup create db1 db1-backup

  $ openstack database backup list
  +--------------------------------------+--------------------------------------+------------+-----------+-----------+---------------------+
  | ID                                   | Instance ID                          | Name       | Status    | Parent ID | Updated             |
  +--------------------------------------+--------------------------------------+------------+-----------+-----------+---------------------+
  | 09e93fcd-c384-4be1-b9ec-c6101d960f45 | bfe87861-5780-4a4a-af4b-47b045400de6 | db1-backup | COMPLETED | None      | 2019-03-28T00:22:42 |
  +--------------------------------------+--------------------------------------+------------+-----------+-----------+---------------------+

Destroy instance and recreate using the backup as source:

.. code-block:: bash

  $ openstack database instance delete db1     # wait for it to be deleted...
  $ openstack database instance create --size 4 --volume b1.standard \
      --databases db --users usr:pass  --datastore mysql --datastore_version 5.7 \
      --backup db1-backup \
      --nic net-id=27f9e799-b936-41c5-b136-018616b062f5 db1 c1.c2r2

  $ openstack database instance list
  +--------------------------------------+------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | ID                                   | Name | Datastore | Datastore Version | Status | Flavor ID                            | Size | Region |
  +--------------------------------------+------+-----------+-------------------+--------+--------------------------------------+------+--------+
  | 6bd114d1-7251-42d6-9426-db598c085472 | db1  | mysql     | 5.7               | ACTIVE | e3feb785-af2e-41f7-899b-6bbc4e0b526e |    4 | test-1 |
  +--------------------------------------+------+-----------+-------------------+--------+--------------------------------------+------+--------+

  Connect and check data in there:

  app1 $ mysql -h db1 -uusr -p db
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



************
Viewing logs
************
