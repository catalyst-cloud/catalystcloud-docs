.. _managing_database:

#######################
Managing your databases
#######################

This section covers the ways that you are able to manage the different aspects
of your database instances. These include configuring who has access to your
databases, managing the size and flavor of your instances and how to activate
and track the logging of your instances. This section follows on from the
previous example in 'creating your database.' It references the instance that
was made in that example.

.. Warning::

  In the examples below; Commands that use the "openstack database ``user`` or
  ``db`` parameters are not supported for PostgreSQL instances and will not
  work at this time.

******************
Configuring access
******************

Before we continue, when talking about access for your database, it is important
to know the distinction between access to your database and access to your
database *instance*. In this section we discuss how to create users and
add them to your database so that they are able to perform operations on it.
These users only exist in the context of the ``database`` and have no ability to
make changes to, nor interact with the underlying ``database instance``.

Using the root user
===================

If a user was not specified when the instance was created, the only
user account that will exist on the database is the ``root`` user. As mentioned
in the previous section, when creating your database instance the ``password``
field will be returned in the output of your ``create`` command. This is the
root user password and is necessary to interact with your database as the root
user.

We can confirm our root user exists using:

.. code-block:: bash

  $ openstack database root show db-instance-1
  +-----------------+-------+
  | Field           | Value |
  +-----------------+-------+
  | is_root_enabled | True  |
  +-----------------+-------+

If you ever need to reset the root password then you can run the following
command against your database instance:

.. code-block:: bash


  $ openstack database root enable db-instance-1
  +----------+--------------------------------------+
  | Field    | Value                                |
  +----------+--------------------------------------+
  | name     | root                                 |
  | password | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |
  +----------+--------------------------------------+

Since we are using a MySQL database, we can check that our root user is working
if we are able to access the database and run the following query.
In order for the following command to reach our database, it must be made from
a location that can 'see' our database instance. For this example, we did not
create a database instance accessible from the public and so you will need to
create a ``jumpbox`` on your project in order for this command to reach your
database instance:

.. code-block:: bash

  # From your jumpbox instance:
  $   mysql -h 10.0.0.83 -u root -p -e 'SELECT USER()'
  Enter password:
  +----------------+
  | USER()         |
  +----------------+
  | root@10.0.0.83 |
  +----------------+


Creating new users
==================

While it is possible to create a database user when launching your database
instance (using the ``--users <username>:<password>`` argument) it is more than
likely that further users will need to be added over time.

This can be done using the OpenStack command line. Below we can see two examples
of how we can add a new user to our *myDB* database. One example creates a
user that can access the database from any location. This is the same behaviour
that is displayed when the user is created as part of the initial database
instance creation.

The other example uses the ``--host`` argument which creates a user that can
only connect from a specified IP address.

.. code-block:: bash

  $ openstack database user create db-instance-1 newuser userpass --databases myDB

  $ openstack database user list db-instance-1
  +---------+-----------+-----------+
  | Name    | Host      | Databases |
  +---------+-----------+-----------+
  | dbusr   | %         | myDB      |
  | newuser | %         | myDB      |
  +---------+-----------+-----------+

  $ openstack database user create db-instance-1 newuser2 userpass2 --host 10.0.0.80 --databases myDB

  $ openstack database user list db-instance-1
  +----------+-----------+-----------+
  | Name     | Host      | Databases |
  +----------+-----------+-----------+
  | dbusr    | %         | myDB      |
  | newuser  | %         | myDB      |
  | newuser2 | 10.0.0.80 | myDB      |
  +----------+-----------+-----------+

Managing user access
====================

Now that we are aware of how to create new users for a database, and we have
previously discussed having multiple databases on our *database instance* we
can discuss how to add or revoke user access to different databases.

Going off of the examples we had before, we created a secondary database named
*myDB2*. The following code block is constructed so that it will allow access
to the database *mydb2* for *newuser2*

.. code-block:: bash

  $ openstack database user grant access db-instance-1 newuser2 myDB2

  # if we now show the access for our user, we will see it has been given access to myDB2
  $ openstack database user show access db-instance-1 newuser2
  +--------+
  | Name   |
  +--------+
  | myDB   |
  | myDB2  |
  +--------+

If we now try to access myDB2 using newuser2 then we should successfully be
able to reach it.

.. code-block:: bash

  $ mysql -h IP_ADDRESS -u newuser2 -p myDB2
  Enter password:

While trying to access this database using *newuser* will result in the
following:

.. code-block:: bash

  $ mysql -h IP_ADDRESS -u newuser -p myDB2
  Enter password:

  ERROR 1044 (42000): Access denied for user 'newuser'@'%' to database 'myDB2'

Now that you know how to add access to a user; How do you revoke access from a
user? The following code block will remove the access we gave to *newuser2* and
show you the response we receive when trying to ping the database afterword:

.. code-block:: bash

  $ openstack database user revoke access db-instance-1 newuser2 myDB2

  $ mysql -h IP_ADDRESS -u newuser2 -p myDB2
  Enter password:

  ERROR 1044 (42000): Access denied for user 'newuser2'@'%' to database 'myDB2'

Before moving on let's remove our test users for now.

.. code-block:: bash

  $ openstack database user delete db-instance-1 newuser

  $ openstack database user delete db-instance-1 newuser2


**********************
Resizing your database
**********************

After you have created your database instance you may find that you need more
storage space or you require a different flavor type. In these cases you do not
have to create a new database; you can update your current one to match your
sizing requirements. The following section will guide you through how to resize
your instances.

.. Warning::

  Before making changes to the flavor of your instance, you should stop your
  instance and restart it after the resizing has been completed.

The following example will resize the flavor of *db-instance-1* to c1.c2r4

.. code-block:: bash

  $ openstack database instance resize flavor db-instance-1 c1.c2r4

This next code block allows you to resize the volume that you have attached to
your instance. The command is formed similarly to the above command, you choose
your instance and then specify the amount in GB you want your volume to be
resized to. Unlike the previous command you **do not** have to stop your
instance and restart it, however there will be a dip in performance until the
resize is complete.

.. code-block:: bash

  $ openstack database instance resize volume db-instance-1 10


.. Note::

  When you upgrade the size of an instance, if it has any replicas; there is an
  option so that they are also upgraded to the same size.

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

At the moment our database instance does not have logging enabled. The
following shows how to enable slow_query specifically.

.. code-block:: bash

  $ openstack database log set --enable db-instance-1 slow_query
  +-----------+----------------------------------------------------------------+
  | Field     | Value                                                          |
  +-----------+----------------------------------------------------------------+
  | container | None                                                           |
  | metafile  | 6f4e35e6-58fa-4812-a075-xxxxxxxxxxxx/mysql-slow_query_metafile |
  | name      | slow_query                                                     |
  | pending   | 182                                                            |
  | prefix    | None                                                           |
  | published | 0                                                              |
  | status    | Ready                                                          |
  | type      | USER                                                           |
  +-----------+----------------------------------------------------------------+

  # Check to confirm this action

  $ openstack database log list db-instance-1

  +------------+------+----------+-----------+---------+-----------+--------+
  | Name       | Type | Status   | Published | Pending | Container | Prefix |
  +------------+------+----------+-----------+---------+-----------+--------+
  | slow_query | USER | Ready    |         0 |     182 | None      | None   |
  | general    | USER | Disabled |         0 |       0 | None      | None   |
  +------------+------+----------+-----------+---------+-----------+--------+

Finally we publish the log using:

.. code-block:: bash

  $ openstack database log set db-instance-1 --publish slow_query
  +-----------+----------------------------------------------------------------+
  | Field     | Value                                                          |
  +-----------+----------------------------------------------------------------+
  | container | database_logs                                                  |
  | metafile  | 6f4e35e6-58fa-4812-a075-xxxxxxxxxxxx/mysql-slow_query_metafile |
  | name      | slow_query                                                     |
  | pending   | 0                                                              |
  | prefix    | 6f4e35e6-58fa-4812-a075-xxxxxxxxxxxx/mysql-slow_query          |
  | published | 404                                                            |
  | status    | Published                                                      |
  | type      | USER                                                           |
  +-----------+----------------------------------------------------------------+

  $ openstack object list database_logs
  +--------------------------------------------------------------------------------------+
  | Name                                                                                 |
  +--------------------------------------------------------------------------------------+
  | 3bc0c29d-b6bc-4729-b6a8-xxxxxxxxxxxx/mysql-slow_query/log-2020-08-05T22:19:09.621839 |
  | 3bc0c29d-b6bc-4729-b6a8-xxxxxxxxxxxx/mysql-slow_query_metafile                       |
  +--------------------------------------------------------------------------------------+

