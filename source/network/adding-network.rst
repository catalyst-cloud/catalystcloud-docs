################
Adding a network
################

By default all new Catalyst Cloud projects in the Porirua region (nz-por-1)
are created with a router and network. If you have removed this, or simply
wish to create additional networks, then the following guide will show you
the steps required to achieve this.

.. _creating_networks:

Creating the required network elements
======================================

We need to create a router and network/subnet.

Navigate to the "Routers" section and click "Create Router":

.. image:: ../_static/fi-router-create.png
   :align: center

|

Name the router "border-router", select admin state "UP" and select
"public-net" as the external network:

.. image:: ../_static/fi-router-name.png
   :align: center

|

Navigate to the "Networks" section and click "Create Network":

.. image:: ../_static/fi-network-create.png
   :align: center

|

Name your network "private-net", select create subnet and click "Next":

.. image:: ../_static/fi-network-create-name.png
   :align: center

|

Name your subnet "private-subnet", choose an address for your subnet in CIDR
notation and click "Next":

.. image:: ../_static/fi-network-address.png
   :align: center

|

The Subnet Details page is normally, by default, empty. However you can define
the different fields however you'd like. Specifications like:

- enabling DHCP
   - Dynamic Host Configuration Protocol. Allows you to assign IP's dynamically
     to devices on your network.
- defining a DHCP ip address allocation pool.
   - This is the range of IP's that you are going to be allocating. For example
     from 10.0.0.10 to 10.0.0.200
- specifying the :ref:`DNS Name Servers <name_servers>` for the required region

At the moment if you leave the DNS field blank the dashboard will automatically
allocate it to the catalyst cloud DNS. So it is entirely optional.

.. image:: ../_static/Create-network-subnetdetails.png
   :align: center

|

Click on the router name in the router list:

.. image:: ../_static/fi-router-detail.png
   :align: center

|

Select the "Interfaces" tab and click "+Add Interface":

.. image:: ../_static/fi-router-interface-add.png
   :align: center

|

Select the correct subnet:

.. image:: ../_static/fi-router-interface-subnet.png
   :align: center

|

You should now have a network topology that looks like this:

.. image:: ../_static/fi-network-topology.png
   :align: center

|

Using the CLI
===============

You are also able to create a network using the CLI. If you look through
:ref:`this <using-the-command-line-interface>` section of the documentation.
While it talks about setting up your first instance there are steps at the
beginning showing you how to create routers and networks using the CLI.
