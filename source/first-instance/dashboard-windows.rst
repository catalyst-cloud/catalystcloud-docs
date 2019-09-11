****************************************
Windows instance using the web interface
****************************************

Log in to the dashboard at https://dashboard.cloud.catalyst.net.nz/

As a new user to the Catalyst Cloud, your initial cloud project will come
with a pre-configured private network and a router connected to the internet.
If you have deleted this, or would like to create additional networks then
please see :ref:`creating_networks` for details on how to do that.
In addition, before trying to create a windows instance you should make sure
that a windows image exists on the server you're trying to create and instance
on. At the moment we only have our Windows images on our Porirua server.

Otherwise, let's proceed with building a windows instance.

.. Note::
  Some of the following pictures, have
  files or various servers/security groups etc. That are not standard on the
  catalyst cloud. Do not worry about their absence on your system, they will
  not affect this tutorial.

Configure Instance Security Group
=================================

You will add  a security group and a rule for your instance so that it can be
accessed using SSH.

Navigate to the "Security Groups" tab of the left sidebar under the "Network"
section. From there, in the upper right of the screen, click the "Create
Security Group" button.

.. image:: dashboard_assets/windows-dashboard/Security-groups.png
   :align: center


Enter a name and description and click "Create Security Group":

.. image:: dashboard_assets/windows-dashboard/create-security-group.png
   :align: center


Now click on "Manage Rules" for the group you have created

.. image:: ../_static/fi-security-group-rules-manage.png
   :align: center


Click on “Add Rule”:

.. image:: ../_static/fi-security-group-rule-add.png
   :align: center


Create a rule to allow RDP access. This can be selected from the Rule drop down
menu, leave the defaults for the other fields. Click "Add".

.. image:: dashboard_assets/windows-dashboard/Add-rules.png
   :align: center


.. warning::

  Note that by using the CIDR 0.0.0.0/0 as a remote, you are allowing access
  from any IP to your compute instance on the port and protocol selected. This
  is often desirable when exposing a web server (eg: allow HTTP and HTTPs
  access from the Internet), but is insecure when exposing other protocols,
  such as RDP, SSH, Telnet and FTP. We strongly recommend you limit the exposure
  of your compute instances and services to IP addresses or subnets that are
  trusted.


Booting an Instance
===================

We are now ready to launch your first instance. Select launch instance from the
instances list:

.. image:: dashboard_assets/windows-dashboard/instance-overview.png
   :align: center

First thing that we do when creating this instance, is give it a name. For this
example we will use fi-windows. An important thing to note here also is that
at the moment our windows images are only available in certain regions. This
demonstration uses the nz-por-1a region.

.. image:: dashboard_assets/windows-dashboard/name-instance-screen.png
   :align: center

When creating a Windows instance you need to select the
``windows-server-2016r2-x86_64`` image from the image list first. The volume
size should automatically update to what is needed to run this image.

.. image:: dashboard_assets/windows-dashboard/windows-image.png
   :align: center

Next we pick the flavor.
We recommended a minimum flavor of ``c1.c2r2`` for our Windows instances.
Select this from the list and click "Next":

.. image:: dashboard_assets/windows-dashboard/flavors.png
   :align: center


Select the ``private-net`` network from the list and click "Next":

.. image:: dashboard_assets/windows-dashboard/networks.png
   :align: center


Select the ``first-instance-sg`` security group from the list and click "Next":

.. image:: dashboard_assets/windows-dashboard/instance-security-group.png
   :align: center


No key pair is required for a Windows instance. Click "Next":



It will take a few seconds for your instance to build. You will see the Status,
Task and Power State change during this process. When complete, the status will
be "Active". You now have a running instance, but there are a few more steps
required before you can log in.


Allocate a Floating IP
======================

To associate a floating IP with your instance, you need to navigate to the
"Floating IPs" tab of the "Access & Security" section.

If an IP address has not yet been allocated, click on "Allocate IP to Project"
to obtain a public IP. Then, select an IP that is not currently mapped and
click on "Associate":

.. image:: dashboard_assets/windows-dashboard/floating-ip.png
   :align: center


Select the port you wish to be associated with the floating IP. Ports are
equivalent to virtual network interfaces of compute instances, and are named
after the compute instance that owns them.

In this example, select the "first-instance" port and click "Associate":

.. image:: dashboard_assets/windows-dashboard/manage-floating-ip.png
   :align: center


Connect to the new Instance
===========================
First you must set the Administrator password. To do this, go to the
"Instances" section, click on first-instance under "Instance Name" and select
the "Console" tab.

Once the following screen loads, click on OK to continue.

Firewall rules required to allow access to the console in the cloud dashboard
-----------------------------------------------------------------------------

.. note::

  If the console shown in the image below fails to load or you see errors on
  this page please ensure that your local machine and/or corporate firewall is
  allowing the following traffic.

port
^^^^
- 6080 (TCP)

for the following Catalyst Cloud API hosts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- nz-por-1: 202.78.247.202
- nz-hlz-1: 202.78.244.90
- nz_wlg_2: 202.78.240.218 & 2404:130:20:2::218


.. image:: ../_static/fi-windows-login.png
   :align: center


You will then be prompted by the following screen to create a new administrator
password.

.. image:: ../_static/fi-windows-login-2.png
   :align: center


Upon completion of this step, it will be possible to connect to this
instance with an RDP application. Connect via the floating public IP that you
associated with your instance in the previous step. This address is visible in
the Instances list and under the Floating IPs tab in Access & Security.
