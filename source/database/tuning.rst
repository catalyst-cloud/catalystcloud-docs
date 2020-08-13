####################
Tuning your database
####################

While our database instances are pre-tuned to make use of resources,
there will still be times when select configuration parameters need to be
amended for specific workloads or use cases for your database.

The auto-tuned parameters are:

.. code-block:: bash

   key_buffer_size = {{ (50 * flavor['ram']/512)|int }}M
   max_allowed_packet = {{ (1024 * flavor['ram']/512)|int }}K
   thread_cache_size = {{ (4 * flavor['ram']/512)|int }}
   query_cache_size = {{ (8 * flavor['ram']/512)|int }}M
   innodb_buffer_pool_size = {{ (150 * flavor['ram']/512)|int }}M
   tmp_table_size = {{ (16 * flavor['ram']/512)|int }}M
   max_heap_table_size = {{ (16 * flavor['ram']/512)|int }}M
   table_open_cache = {{ (256 * flavor['ram']/512)|int }}
   table_definition_cache = {{ (256 * flavor['ram']/512)|int }}
   open_files_limit = {{ (512 * flavor['ram']/512)|int }}
   max_user_connections = {{ (100 * flavor['ram']/512)|int }}
   max_connections = {{ (100 * flavor['ram']/512)|int }}

For most instances, these parameters will suite your needs. However, if you
have particularly heavy read or write workloads, you are able to change these
parameters to achieve a better performance.

.. Note::

   Not all of the parameters that you are able to change are present in our
   list of auto-defined parameters.

What parameters to change?
==========================

The previous list is only what we auto-tune for a basic database instance. You
are able to tune your database to have specifications that fit your needs. In
the following section we will discuss what the common parameters are for
configuring your instance to deal with heavy workloads for both reading and
writing operations.

There are some trade offs with changing some of these parameters. For example;
increasing some of the values can lead to longer wait times if you need to
recover from a backup, while the change itself will increase your write speed.
Before committing to changing any of these parameters on you main database, you
can test the behaviour of your new configuration by using a
:ref:`replica<database_replica>`.

That being said, for write heave workloads, the parameters to look at changing
would be:

.. code-block:: bash

   innodb_log_file_size  512MB -2GB

   innodb_log_buffer_size 32MB

   innodb_io_capacity_max [increase from current value if flushing not keeping up]

For read heavy workloads, you could take a look at:

.. code-block:: bash

   sort_buffer_size (a few MB is typical for complex SELECT queries)
   # Be careful as this can be allocated in each connection.
   # You will run out of memory if you make it too big)!


How to change parameters
========================

Now that we know what we are looking at changing, next we'll cover the process
of implementing these changes. We go about this, by creating a configuration
format, attaching it to our instance, and restarting the database. To begin,
we need to create our new config file with our new parameters. In this example,
we are going to be increasing the innodb_buffer_pool_size:

.. code-block:: bash

  $ openstack database configuration create conf1 '{"innodb_buffer_pool_size" : 1073741824}' --datastore mysql --datastore_version 5.7.29
  +------------------------+-----------------------------------------+
  | Field                  | Value                                   |
  +------------------------+-----------------------------------------+
  | created                | 2020-08-13T00:55:08                     |
  | datastore_name         | mysql                                   |
  | datastore_version_name | 5.7.29                                  |
  | description            | None                                    |
  | id                     | acef615c-81a1-4f60-85e9-b7787ceb57dd    |
  | instance_count         | 0                                       |
  | name                   | conf1                                   |
  | updated                | 2020-08-13T00:55:08                     |
  | values                 | {"innodb_buffer_pool_size": 1073741824} |
  +------------------------+-----------------------------------------+

Once this is done, we then have to attach the configuration to our database and
restart the instance:

.. code-bloack:: bash

  $ openstack database configuration attach db-instance-1 conf1

  $ openstack database instance restart db1

Now we can test on our instance that the parameter we wanted to update has
changed:

.. code-block:: bash

  $ mysql -h db-instance-1 -uusr -p db -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size'"
  +-------------------------+------------+
  | Variable_name           | Value      |
  +-------------------------+------------+
  | innodb_buffer_pool_size | 1073741824 |
  +-------------------------+------------+

Additional notes
================

While these are the parameters that affect the read/write commands to the
database, there are some other actions you can take to improve general
performance of your database:

- Use volume type NVMe for workloads that are very intensive.
- In the event that you do manage to run out of memory, you can increase the
  flavor (RAM in particular) of your instance to meet the new demand.

  - you can do this using the ``openstack database instance resize flavor`` command
