############################
Database creation and access
############################

In this section we cover several different methods for creating database
instances. Each of the tutorials below will work through the steps required to:
create a new database instance, add and remove databases from that instance,
and (where available) the configuration settings you need to allow access to
your database from the internet.

*********************************
Prerequisites
*********************************

Configuring your command line environment
=========================================

Before we begin, you will need to have the following prerequisites set up to be
able to interact with the database service from your command line. All of the
following examples require these prerequisites, so you will need to have them
prepared no matter which example you are going to follow:

- You must have your :ref:`openstack CLI<command-line-interface>` set up.
- You must have :ref:`sourced an openRC file<configuring-the-cli>` on your
  current command line environment
- You must have installed the `python trove-client tools
  <https://pypi.org/project/python-troveclient/3.3.2/>`_.

  - This tutorial is written to work with the 3.3.2 version of the client tools.
    We are looking at upgrading to a newer version in the near future.

********************************************
Creation using programmatic methods
********************************************

Once you have the necessary tools installed and you have your environment
ready, you can proceed with one of the following methods:

.. tabs::

  .. tab:: Openstack CLI

    .. include:: _scripts/command-line-create.rst

  .. tab:: Heat

    .. include:: heat-create.rst

  .. tab:: Terraform

    .. include:: terraform-create.rst

**********************************
Deleting database instances
**********************************

The method for deleting a database instance will vary depending on which method
you used to create it. However, the following is the manual method in which you
can delete database instances, should you experience issues with one of the
other methods of deletion shown in a tutorial:

.. code-block:: bash

  $ openstack database instance delete <my-database-name>
  # wait until the console returns, it will reply with a message saying your database was deleted.
