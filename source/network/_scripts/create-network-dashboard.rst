
Creating the required network elements
======================================


We need to create a router and network/subnet.

Navigate to the "Routers" section and click "Create Router":

.. image:: /network/_static/router-main-page.png
   :align: center

|

For this example we will name our router "border-router", this is an
arbitrary name, you could use whatever you would like.
Then select the admin state check-box and select
"public-net" as the external network:

.. image:: /network/_static/router-create.png
   :align: center

|

Navigate to the "Networks" section and click "Create Network":

.. image:: /network/_static/network-main-page.png
   :align: center

|

We will name our network "private-net", we choose this name
so that we do not confuse it with the "public-net". You should
also select create subnet and click "Next":

.. image:: /network/_static/network-create.png
   :align: center

|

Name your subnet "private-subnet". Here you can either select a network address you
would want to use for your subnet, you can allow one to be assigned for you,
or you can disable the gateway all together. For this tutorial we will apply a
simple address and click "Next":

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
