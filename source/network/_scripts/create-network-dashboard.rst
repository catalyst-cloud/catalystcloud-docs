
Creating the required network elements
--------------------------------------

We need to create a router and network/subnet.

Navigate to the "Routers" section and click "Create Router":

.. image:: /network/_static/router-main-page.png
   :align: center

|

Name the router "border-router", select the admin state check-box and select
"public-net" as the external network:

.. image:: /network/_static/router-create.png
   :align: center

|

Navigate to the "Networks" section and click "Create Network":

.. image:: /network/_static/network-main-page.png
   :align: center

|

Name your network "private-net", select create subnet and click "Next":

.. image:: /network/_static/network-create.png
   :align: center

|

Name your subnet "private-subnet", choose an address for your subnet in CIDR
notation and click "Next":

.. image:: /network/_static/subnet-create.png
   :align: center

|

The Subnet Details page is normally, by default, empty. However you can define
the different fields however you'd like. Specifications like:

- enabling DHCP
   - Dynamic Host Configuration Protocol. Allows you to assign IPs dynamically
     to devices on your network.
- defining a DHCP ip address allocation pool.
   - This is the range of IPs that you are going to be allocating. For example
     from 10.0.0.10 to 10.0.0.200
- specifying the :ref:`DNS Name Servers <name_servers>` for the required region

At the moment if you leave the DNS field blank the dashboard will automatically
allocate it to the catalyst cloud DNS. So it is entirely optional.

.. image:: /network/_static/Create-network-subnetdetails.png
   :align: center

|

Click on the router name in the router list:

.. image:: /network/_static/router-status.png
   :align: center

|

Select the "Interfaces" tab and click "+Add Interface":

.. image:: /network/_static/router-add-interface.png
   :align: center

|

Select the correct subnet:

.. image:: /network/_static/router-interface-popup.png
   :align: center

|

You should now have a network topology that looks like this:

.. image:: /network/_static/network-topology.png
   :align: center
