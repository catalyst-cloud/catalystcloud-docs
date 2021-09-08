################################
Creating a backup
################################

The purpose of this section is to show you how to use different tools to create
a volume backup on the Catalyst Cloud.

Before you continue with the examples below, there are a few assumptions
that are made which you will need to consider before jumping in further:

1)
 You are familiar with the Linux command line and Openstack CLI tools.
2)
 You have installed the OpenStack command line tools and sourced an openrc
 file, as explained in :ref:`command-line-interface`.


***********************
Using the Openstack CLI
***********************

To create a backup using the openstack command line tools, we first need to
find the original volume we are trying to back up. To show a list of the
currently available volumes, you can use the following code snippet:

.. code-block:: bash

    $ openstack volume list


The command for creating a backup using the openstack CLI is:

.. code-block:: bash

    $ openstack volume backup create [--incremental] [--force] <VOLUME>

Where ``<VOLUME>`` is the name of the original volume you wish to back up.

.. include:: duplicity.rst