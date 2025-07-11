############################
Database creation and access
############################

In this section we will work through the steps required to create a new
database instance, how to add and remove databases from your instance, and how
to expose a database instance to the public.

.. Warning::

  There are may be multiple versions of a database available for use. Whenever
  possible you should use the latest version available.

*********************************
Prerequisites
*********************************

Configuring your command line
=============================

To interact with the database service on the cloud, you must have the
following:

- Your :ref:`openstack CLI<command-line-interface>` set up.
- You must have :ref:`Sourced an openRC file<configuring-the-cli>` on your
  current command line environment
- You must have installed the `python trove-client tools
  <https://pypi.org/project/python-troveclient/5.1.1/>`_.

Once you have the necessary tools installed and your environment ready, you can
proceed with the next step:

Gathering necessary information
===============================

In order to launch a new database instance we need to first decide on a few
options, these include:

* The **datastore type** which defines the type of database to be deployed.
* The **database version** which is informed by your datastore type.
* The **flavor**, which determines the vCPU and RAM assigned to the instance.
* You will also need to source an OpenRC file in the correct region
* It is also necessary to have an **existing network**,  which is attached to a
  router and has a working subnet, on the project that you wish to deploy the
  database instance to. The network that you create the database instance in
  **must** have access to the internet, as it is required to download the
  support files to start the database.

.. Warning::

  When choosing a size for the volume you attach to your database instance
  there is a limit of 200GB per volume. There is also a limit of 800GB per
  region for the collective amount of volumes you have attached to your
  database instances.

  For this example we will be using a 5GB volume for our database instance.

First, lets determine what datastore types are available to us.

.. code-block:: bash

  $ openstack datastore list
  +--------------------------------------+------------+
  | ID                                   | Name       |
  +--------------------------------------+------------+
  | 93b40b75-5a44-4926-aa3c-xxxxxxxxxxxx | postgresql |
  | b1452789-1e33-4eb1-866e-xxxxxxxxxxxx | mysql      |
  +--------------------------------------+------------+

.. Note::

  The openstack commands that are used in this tutorial should be the same
  regardless of the datastore that you choose. The only differences will be
  the datastore type, datastore version version and the maximum length of
  the initial username assigned during database instance creation.

  Maximum initial username length by datastore type:

  * MySQL: 16 characters
  * Postgres: 63 characters.

For this example we are going to use MySQL.

Next we need to see what versions of MySQL we can use. We can do this in a
couple of ways. Either by looking at the full description of the datastore type,
or by explicitly querying the version of a particular datastore:

.. code-block:: bash

  # Getting the full description of our datastore
  $ openstack datastore show mysql
  +---------------+-----------------------------------------------+
  | Field         | Value                                         |
  +---------------+-----------------------------------------------+
  | id            | c681e699-5493-4599-9d9c-xxxxxxxxxxxx          |
  | name          | mysql                                         |
  | versions (id) | 5.7.29 (8f2c5796-e1e1-4275-9917-xxxxxxxxxxxx) |
  +---------------+-----------------------------------------------+

  # Querying the version of our datastore
  $ openstack datastore version list mysql
  +--------------------------------------+--------+
  | ID                                   | Name   |
  +--------------------------------------+--------+
  | 8f2c5796-e1e1-4275-9917-xxxxxxxxxxxx | 5.7.29 |
  +--------------------------------------+--------+

Next we need to decide on the resource requirements for our database instance.
We do this by picking a flavor from the available list:

.. code-block:: bash

  $ openstack flavor list
  # results truncated for brevity
  +--------------------------------------+------------------+-------+-------+------+-----------+
  | ID                                   | Name             |   RAM | vCPUs | Disk | Ephemeral |
  +--------------------------------------+------------------+-------+-------+------+-----------+
  | 01b42bbc-347f-43e8-9a07-xxxxxxxxxxxx | c1.c8r8          |  8192 |     8 |   10 |         0 |
  | 0c7dc485-e7cc-420d-b118-xxxxxxxxxxxx | c1.c2r8          |  8192 |     2 |   10 |         0 |
  | 1750075c-cd8a-4c87-bd06-xxxxxxxxxxxx | c1.c1r2          |  2048 |     1 |   10 |         0 |
  | 1d760238-67a7-4415-ab7b-xxxxxxxxxxxx | c1.c8r32         | 32768 |     8 |   10 |         0 |
  | 3931e022-24e7-4678-bc3f-xxxxxxxxxxxx | c1.c1r1          |  1024 |     1 |    8 |         0 |
  | 3d11be79-5788-4d70-9058-xxxxxxxxxxxx | c1.c1r05         |   512 |     1 |   10 |         0 |
  | 45060aa3-3400-4da0-bd9d-xxxxxxxxxxxx | c1.c4r8          |  8192 |     4 |   10 |         0 |
  | 4efb43da-132e-4b50-a9d9-xxxxxxxxxxxx | c1.c2r16         | 16384 |     2 |   10 |         0 |
  | 62473bef-f73b-4265-a136-xxxxxxxxxxxx | c1.c4r4          |  4096 |     4 |   10 |         0 |
  | 746b8230-b763-41a6-954c-xxxxxxxxxxxx | c1.c1r4          |  4096 |     1 |   10 |         0 |
  | 7b74c2c5-f131-4981-90ef-xxxxxxxxxxxx | c1.c8r16         | 16384 |     8 |   10 |         0 |
  | a197eac1-9565-4052-8199-xxxxxxxxxxxx | c1.c8r4          |  4096 |     8 |   10 |         0 |
  | a80af444-9e8a-4984-9f7f-xxxxxxxxxxxx | c1.c4r2          |  2048 |     4 |   10 |         0 |
  | b152339e-e624-4705-9116-xxxxxxxxxxxx | c1.c4r16         | 16384 |     4 |   10 |         0 |
  | b4a3f931-dc86-480c-b7a7-xxxxxxxxxxxx | c1.c4r32         | 32768 |     4 |   10 |         0 |
  | c093745c-a6c7-4792-9f3d-xxxxxxxxxxxx | c1.c2r4          |  4096 |     2 |   10 |         0 |
  | e3feb785-af2e-41f7-899b-xxxxxxxxxxxx | c1.c2r2          |  2048 |     2 |   10 |         0 |
  | ...                                  |                  |               |      |           |
  +--------------------------------------+------------------+-------+-------+------+-----------+


***********************************
Launching the new database instance
***********************************

Based on the information we gathered in the previous section we are now
able to create our database instance. This will require a private network that
has already been created on your project, that we can attach the database
instance to.

.. code-block:: bash

  $ openstack network list
  +--------------------------------------+---------------------+--------------------------------------+
  | ID                                   | Name                | Subnets                              |
  +--------------------------------------+---------------------+--------------------------------------+
  | 908816f1-933c-4ff2-8595-xxxxxxxxxxxx | database-network    | af0f251c-0a36-4bde-b3bc-xxxxxxxxxxxx |
  +--------------------------------------+---------------------+--------------------------------------+

After finding a suitable network to host our database. We take the network ID,
alongside the information on our preferred flavor and we construct
the following command to create our new instance:

.. code-block:: bash

  $ openstack database instance create db-instance-1\
  --flavor e3feb785-af2e-41f7-899b-xxxxxxxxxxxx \ # this is the flavor ID for your instance
  --size 5 \
  --datastore mysql \
  --datastore-version 5.7.29 \
  --databases myDB \
  --users dbusr:dbpassword \
  --volume-type b1.standard \
  --nic net-id=908816f1-933c-4ff2-8595-xxxxxxxxxxxx

  +--------------------------+--------------------------------------+
  | Field                    | Value                                |
  +--------------------------+--------------------------------------+
  | allowed_cidrs            | []                                   |
  | created                  | 2020-08-03T23:02:16                  |
  | datastore                | mysql                                |
  | datastore_version        | 5.7.29                               |
  | datastore_version_number | None                                 |
  | flavor                   | e3feb785-af2e-41f7-899b-xxxxxxxxxxxx |
  | id                       | 8546dd23-4f5e-4151-9b33-xxxxxxxxxxxx |
  | name                     | db-instance-1                        |
  | password                 | Q3jjBGIsD4eGBqFsZ5xxxxxxxxxxxxxxxxxx |
  | public                   | False                                |
  | region                   | nz-por-1                             |
  | service_status_updated   | 2020-08-03T23:02:16                  |
  | status                   | BUILD                                |
  | updated                  | 2020-08-03T23:02:16                  |
  | volume                   | 5                                    |
  +--------------------------+--------------------------------------+

.. Note::

  Take note of the 'password' field here. This will become relevant when we start to interact with
  our database later on in the :ref:`managing our database<managing_database>` section and the password is only
  visible when initially creating your database instance.

Once we have run the previous command, we have to wait while the instance
builds. Keep checking on the status of the new instance; once it is ``HEALTHY``
we can continue.

.. code-block:: bash

  $ openstack database instance list
  +--------------------------------------+---------------+-----------+-------------------+--------+-----------+--------------------------------------+------+----------+------+
  | ID                                   | Name          | Datastore | Datastore Version | Status | Addresses | Flavor ID                            | Size | Region   | Role |
  +--------------------------------------+---------------+-----------+-------------------+--------+-----------+--------------------------------------+------+----------+------+
  | 8546dd23-4f5e-4151-9b33-xxxxxxxxxxxx | db-instance-1 | mysql     | 5.7.29            | BUILD  |           | e3feb785-af2e-41f7-899b-xxxxxxxxxxxx |    5 | nz-por-1 |      |
  +--------------------------------------+---------------+-----------+-------------------+--------+-----------+--------------------------------------+------+----------+------+

Now let's view the details of our instance so that we can find the IP address
that has been assigned to it.

.. code-block:: bash

  $ openstack database instance show db-instance-1
  +------------------------+----------------------------------------------------+
  | Field                  | Value                                              |
  +------------------------+----------------------------------------------------+
  | addresses                | [{'address': '10.0.0.83 ', 'type': 'private'}]   |
  | allowed_cidrs            | []                                               |
  | created                  | 2020-08-03T23:02:16                              |
  | datastore                | mysql                                            |
  | datastore_version        | 5.7.29                                           |
  | datastore_version_number | None                                             |
  | flavor                   | e3feb785-af2e-41f7-899b-xxxxxxxxxxxx             |
  | id                       | 8546dd23-4f5e-4151-9b33-xxxxxxxxxxxx             |
  | ip                       | 10.0.0.83                                        |
  | public                   | False                                            |
  | name                     | db-instance-1                                    |
  | region                   | nz-por-1                                         |
  | service_status_updated   | 2020-08-03T23:04:22                              |
  | status                   | HEALTHY                                          |
  | updated                  | 2020-08-03T23:02:30                              |
  | volume                   | 5                                                |
  | volume_used              | 0.13                                             |
  +--------------------------+--------------------------------------------------+

The final step in this section is to see what databases we have running within
this instance.

.. Note::

  Currently the support for this command will only work with databases using the
  MySQL datastore image.

.. code-block:: bash

  $ openstack database db list db-instance-1
  +------+
  | Name |
  +------+
  | myDB |
  +------+

*****************************
Adding and deleting databases
*****************************

.. Note::

  The following commands are only relevant for the MySQL datastore.

Once you have a database instance deployed it is fairly simple to add and
remove databases from it.

.. code-block:: bash

  $ openstack database db create db-instance-1 myDB2

To check our command worked we use the following command:

.. code-block:: bash

  $ openstack database db list db-instance-1
  +-------+
  | Name  |
  +-------+
  | myDB  |
  | myDB2 |
  +-------+

To delete a database, you can use the following command:

.. code-block:: bash

  $ openstack database instance delete myDB2
  # wait until the console returns, it will reply with a message saying your database was deleted.


**************************
Creating a public database
**************************

By default the database instances that you create will only be available via
your internal network on the cloud. If you are wanting to have your database
open to a wider audience then you will need to expose it to the internet.

The following example shows how to create a database instance that
is publicly available, but only from the specific cidr range: 202.37.199.1/24

.. code-block:: bash

  $ openstack database instance create db-instance-1 \
  e3feb785-af2e-41f7-899b-xxxxxxxxxxxx \
  --size 5 \
  --datastore mysql \
  --datastore_version 5.7.29 \
  --databases myDB \
  --users dbusr:dbpassword \
  --volume_type b1.standard \
  --nic net-id=908816f1-933c-4ff2-8595-xxxxxxxxxxxx \
  --is-public \
  --allowed-cidr 202.37.199.1/24 \
