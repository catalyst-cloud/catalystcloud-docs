****************
Adding a network
****************

By default all new Catalyst Cloud projects are created with a router and network. If you have
removed this or simply wish to create additional networks then this guide will show you the steps
required to achieve this.

.. _creating_networks:

Creating the required network elements
======================================

We need to create a router and network/subnet.

Navigate to the "Routers" section and click "Create Router":

.. image:: ../_static/fi-router-create.png
   :align: center

Name the router "border-router", select admin state "UP" and select
"public-net" as the external network:

.. image:: ../_static/fi-router-name.png
   :align: center

Navigate to the "Networks" section and click "Create Network":

.. image:: ../_static/fi-network-create.png
   :align: center

Name your network "private-net", select create subnet and click "Next":

.. image:: ../_static/fi-network-create-name.png
   :align: center

Name your subnet "private-subnet", choose an address for your subnet in CIDR
notation and click "Next":

.. image:: ../_static/fi-network-address.png
   :align: center

Specify additional attributes for the subnet including enabling DHCP,
specifying the :ref:`DNS Name Servers <name_servers>` for your region and
optionally defining an allocation pool:

.. image:: ../_static/fi-network-detail.png
   :align: center

Click on the router name in the router list:

.. image:: ../_static/fi-router-detail.png
   :align: center

Select the "Interfaces" tab and click "+Add Interface":

.. image:: ../_static/fi-router-interface-add.png
   :align: center

Select the correct subnet:

.. image:: ../_static/fi-router-interface-subnet.png
   :align: center

You should now have a network topology this looks like this:

.. image:: ../_static/fi-network-topology.png
   :align: center
