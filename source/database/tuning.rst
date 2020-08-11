####################
Tuning your database
####################

While our database instances are pre-tuned to make use of resources,
there will still be times when select configuration parameters need to be
amended for specific workloads or use cases for your database.

The auto-tuned default parameters are:

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

Changing the default parameters
===============================

There are some trade offs with changing these default parameters. Increasing
some of the values can lead to longer wait times if you need to recover from a
backup due to some unrelated issue with the database. Before committing to
these changes, you could test how long a backup restore would take by using a
:ref:`replica<database_replica>` and performing the restore process,
after it has been fully warmed up.

For write heave workloads, the parameters to look at changing would be:

.. code-block:: bash

   innodb_log_file_size  512MB -2GB

   innodb_log_buffer_size 32MB

   innodb_io_capacity_max [increase from current value if flushing not keeping up]

For read heavy workloads, you could take a look at:

.. code-block:: bash

   sort_buffer_size (a few MB is typical for complex SELECT queries)
   # Be careful as this can be allocated in each connection.
   # You will run out of memory if you make it too big)!


While these are the parameters that affect the read/write commands to the
database, there are some other actions you can take to improve general
performance of your database:

- Use volume type NVMe for workloads that are very intensive.
- In the event that you do manage to run out of memory, you can increase the
  flavor (RAM in particular) of your instance to meet the new demand.
