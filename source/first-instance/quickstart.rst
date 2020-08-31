****************************
Creating your first instance
****************************

Now that we know what resources are required for a compute instance to run, we
have to go about creating the instance. There are a number of different methods
that you can use to create your instance, these range from using the dashboard,
using the command line, or using an orchestration engine to manage all of the
resources you require.

The following sections will cover the different programs or methods you can use
to create your first instance:

Via the dashboard
=================

.. include:: dashboard.rst

Command line methods
====================


.. tabs::

    .. tab:: Openstack CLI

        .. include:: command-line.rst

    .. tab:: Bash Script

        .. include:: bash-script.rst

    .. tab:: Orchestration

        .. include:: heat.rst

    .. tab:: Ansible

        .. include:: ansible.rst

    .. tab:: Terraform

        .. include:: terraform.rst

    .. tab:: Openstack SDK

        .. include:: openstack-sdk.rst


Resource cleanup using the command line
=======================================

At this point you may want to clean up the OpenStack resources that have been
created. Running the following commands should remove all networks, routers,
ports, security groups and instances. These commands will work regardless of
the method you used to create the resources. Note that the order in which you
delete resources is important.

.. warning::

 The following commands will delete all the resources you have created
 including networks and routers. Do not run these commands unless you wish to
 delete all these resources.

.. code-block:: bash

 # delete the instances
 $ openstack server delete first-instance

 # delete router interface
 $ openstack router remove port border-router $( openstack port list -f value -c ID --router border-router )

 # delete router
 $ openstack router delete border-router

 # delete network
 $ openstack network delete private-net

 # delete security group
 $ openstack security group delete first-instance-sg

 # delete ssh key
 $ openstack keypair delete first-instance-key

Creating a windows instance
===========================

.. include:: dashboard-windows.rst


