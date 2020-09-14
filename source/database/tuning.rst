####################
Tuning your database
####################

Tuning your database is an important part of database management and is
essential to getting the best performance out of your resources. The following
section covers some of the basic information around tuning, what auto-tuning we
have for default databases, and jumping off points for more information on the
tuning process.

To start, by default our databases have some auto-tuned parameters that are
set up when you first create your instance. This auto-tuning makes
use of the database resources in a way which suits a variety of general
use cases. This means that there will still be times when specific
configuration parameters can be changed to optimize your resources for high
performance workloads; but we will discuss how to do this later on.

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

The above calculations are supposed to take the amount of RAM you receive
from your flavor and return a value, in MB, for each parameter. For example,
if we were to use the c1.c2r2 flavor which has 2048 MB of RAM and plug it into
one of the equations, we would find that:

.. code-block:: bash

   key_buffer_size = 50 * [2048] / 512 = 200MB

Paired with the right flavor, these parameters will suit most of your needs.
However, if you have particularly heavy read or write workloads, you are able
to change these parameters to achieve a better performance.

.. Note::

   Not all of the parameters that you are able to change are present in our
   list of auto-defined parameters.

**************************
What parameters to change?
**************************

The previous list is only what we auto-tune for a basic database instance. You
are able to tune your database to have specifications that fit your needs. In
the following section we will discuss some of the common parameters to change
when wanting to improve performance with read/write operations.
These are only some of the **common** parameters
and a more comprehensive list is available from the `MySQL docs`_.

The MySQL documents have a much more in depth explanation of how tuning works
and how to go about tuning your database. If you are considering tuning your
database heavily to suite your needs at a very specific level, then reading
through those documents will be a necessity.

.. Note::

  Another good resource to read when looking for more information on tuning and
  how it works can be found on this `percona`_ blog about tuning.

.. _`MySQL docs`: https://dev.mysql.com/doc/
.. _`percona`: https://www.percona.com/blog/2017/10/18/chose-mysql-innodb_log_file_size/

<<<<<<< HEAD

For write heavy workloads, the parameters to look at changing would be:
=======
For write heave workloads, the parameters to look at changing would be:
>>>>>>> 7e555eb... Small update to format of tuning (#272)

.. code-block:: bash

   innodb_log_file_size  512MB -2GB

   innodb_log_buffer_size 32MB

For read heavy workloads, you could take a look at:

.. code-block:: bash

   sort_buffer_size (a few MB is typical for complex SELECT queries)
   # Be careful as this can be allocated in each connection. You will run out of memory if you make it too big)!

************************
How to change parameters
************************

Now that we know what we are looking at changing, next we will cover the
process of implementing these changes. We go about this, by creating a
configuration format, attaching it to our instance, and restarting the
database. To begin, we need to create our new config file with our new
parameters. In this example, we are going to be increasing the
innodb_buffer_pool_size:

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

.. code-block:: bash

  $ openstack database configuration attach db-instance-1 conf1

  $ openstack database instance restart db1

Now we can test that our instance has the parameter we wanted to update:

.. code-block:: bash

  $ mysql -h db-instance-1 -uusr -p db -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size'"
  +-------------------------+------------+
  | Variable_name           | Value      |
  +-------------------------+------------+
  | innodb_buffer_pool_size | 1073741824 |
  +-------------------------+------------+

.. Note::

   Before committing to changing any of these parameters on your main database,
   you can test the behaviour of your new configuration by using a
   :ref:`replica<database_replica>`.

****************
Additional notes
****************

While tuning is an important part of database performance and management,
there are some other actions you can take to improve the general performance of
your database:

- Use volume type NVMe for workloads that are very intensive.
- In the event that you do manage to run out of memory, you can increase the
  flavor (RAM in particular) of your instance to meet the new demand.

  - you can do this using the ``openstack database instance resize flavor`` command
