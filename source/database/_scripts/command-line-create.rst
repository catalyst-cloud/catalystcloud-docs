.. raw:: html

  <h3> Gathering necessary information </h3>

In order to launch a new database instance we need to first decide on a few
options, these include:

* The **datastore type** which defines the type of database to be deployed.
  For this instance we are using MySQL.
* The **database version** which is informed by your datastore type.
* The **flavor**, which determines the vCPU and RAM assigned to the
  instance.
* You will also need to source an OpenRC file in the correct region

.. Note::
  It is also necessary to have an existing network on the project that you
  wish to deploy the database instance to.

First, lets determine what datastore types are available to us.

.. code-block:: bash

  $ openstack datastore list
  +--------------------------------------+-------+
  | ID                                   | Name  |
  +--------------------------------------+-------+
  | c681e699-5493-4599-9d9c-08eb7d21c2de | mysql |
  +--------------------------------------+-------+


Now lets see what versions of MySQL we can use. We can do this a
couple of ways, either by looking at the full description of the datastore type
or by explicitly querying the version of a particular datastore type:

.. code-block:: bash

  $ openstack datastore show mysql
  +---------------+-----------------------------------------------+
  | Field         | Value                                         |
  +---------------+-----------------------------------------------+
  | id            | c681e699-5493-4599-9d9c-08eb7d21c2de          |
  | name          | mysql                                         |
  | versions (id) | 5.7.29 (8f2c5796-e1e1-4275-9917-4e3a61cbb76d) |
  +---------------+-----------------------------------------------+

  $ openstack datastore version list mysql
  +--------------------------------------+--------+
  | ID                                   | Name   |
  +--------------------------------------+--------+
  | 8f2c5796-e1e1-4275-9917-4e3a61cbb76d | 5.7.29 |
  +--------------------------------------+--------+

Next we need to decide on the resource requirements for our database instance.
We do this by picking a flavor from the available list:

.. code-block:: bash

  $ openstack flavor list
  # results truncated for brevity
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
  | ...                                  |                  |               |      |           |
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

.. raw:: html

  <h3> Launching the new database instance </h3>

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

  $ openstack database instance create db-instance-1\
  e3feb785-af2e-41f7-899b-6bbc4e0b526e \ # this is the flavor ID for your instance
  --size 5 \
  --datastore mysql \
  --datastore_version 5.7.29 \
  --databases myDB \
  --users dbusr:dbpassword \
  --volume_type b1.standard \
  --nic net-id=908816f1-933c-4ff2-8595-f0f57c689e48

  +------------------------+--------------------------------------+
  | Field                  | Value                                |
  +------------------------+--------------------------------------+
  | created                | 2020-08-03T23:02:16                  |
  | datastore              | mysql                                |
  | datastore_version      | 5.7.29                               |
  | flavor                 | e3feb785-af2e-41f7-899b-6bbc4e0b526e |
  | id                     | 8546dd23-4f5e-4151-9b33-db708dfd469a |
  | name                   | db-instance-1                        |
  | region                 | nz_wlg_1                             |
  | service_status_updated | 2020-08-03T23:02:16                  |
  | status                 | BUILD                                |
  | updated                | 2020-08-03T23:02:16                  |
  | volume                 | 5                                    |
  +------------------------+--------------------------------------+

We have to wait while the instance builds. Keep checking on the status of the
new instance, once it is ``ACTIVE`` we can continue.

.. code-block:: bash

  $ openstack database instance list
  +--------------------------------------+---------------+-----------+-------------------+--------+-----------+--------------------------------------+------+--------+------+
  | ID                                   | Name          | Datastore | Datastore Version | Status | Addresses | Flavor ID                            | Size | Region | Role |
  +--------------------------------------+---------------+-----------+-------------------+--------+-----------+--------------------------------------+------+--------+------+
  | 8546dd23-4f5e-4151-9b33-db708dfd469a | db-instance-1 | mysql     | 5.7.29            | BUILD  |           | e3feb785-af2e-41f7-899b-6bbc4e0b526e |    5 | test-1 |      |
  +--------------------------------------+---------------+-----------+-------------------+--------+-----------+--------------------------------------+------+--------+------+

Now let's view the details of our instance so that we can find the IP address
that has been assigned to it.

.. code-block:: bash

  $ openstack database instance show db-instance-1
  +------------------------+--------------------------------------+
  | Field                  | Value                                |
  +------------------------+--------------------------------------+
  | created                | 2020-08-03T23:02:16                  |
  | datastore              | mysql                                |
  | datastore_version      | 5.7.29                               |
  | flavor                 | e3feb785-af2e-41f7-899b-6bbc4e0b526e |
  | id                     | 8546dd23-4f5e-4151-9b33-db708dfd469a |
  | ip                     | 10.0.0.83                            |
  | name                   | db-instance-1                        |
  | region                 | test-1                               |
  | service_status_updated | 2020-08-03T23:04:22                  |
  | status                 | ACTIVE                               |
  | updated                | 2020-08-03T23:02:30                  |
  | volume                 | 5                                    |
  | volume_used            | 0.13                                 |
  +------------------------+--------------------------------------+

The final step in this section is to see what databases we have running within
this instance.

.. code-block:: bash

  $ openstack database db list db-instance-1
  +------+
  | Name |
  +------+
  | myDB |
  +------+

.. raw:: html

  <h3>Adding and deleting databases</h3>


Once you have a database instance deployed it is fairly simple to add and
remove databases from it.

.. code-block:: bash

  $ openstack database db create db-instance-1 myDB2

To check that our database was created we can use the following command:

.. code-block:: bash

  $ openstack database db list db-instance-1
  +-------+
  | Name  |
  +-------+
  | myDB  |
  | myDB2 |
  +-------+

.. raw:: html

  <h3>Creating a public database</h3>


By default the database instances that you create will only be available via
your internal network on the cloud. If you are wanting to have your database
open to a wider audience then you will need to expose it to the internet.

The following example shows how to create a database instance that
is publicly available, but only from the specific cidr range: 202.37.199.1/24

.. code-block:: bash

  $ openstack database instance create db-instance-1 \
  e3feb785-af2e-41f7-899b-6bbc4e0b526e \
  --size 5 \
  --datastore mysql \
  --datastore_version 5.7.29 \
  --databases myDB \
  --users dbusr:dbpassword \
  --volume_type b1.standard \
  --nic net-id=908816f1-933c-4ff2-8595-f0f57c689e48 \
  --is-public \
  --allowed-cidr 202.37.199.1/24 \
