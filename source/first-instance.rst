.. _launching-your-first-instance:

#############################
Launching your first instance
#############################


********
Overview
********

This section will demonstrate how to build an Ubuntu 14.04 server in an empty
OpenStack tenant. After you have completed the steps you will be able to log
on to the server via SSH from anywhere on the internet using an SSH key.

This section assumes that you have already setup a Catalyst Cloud account and
have been assigned a tenant and a user in that tenant who has permissions to
create the required resources.

We will document the steps required to get an instance setup, the steps are:

1. Create a Network and Subnet
2. Create a Router
3. Upload an SSH keypair
4. Create a security group
5. Launch an instance
6. Associate a floating ip
7. Log in to your instance

There are a number of different ways to provision resources on the Catalyst
Cloud. We will show you how to complete these steps using the dashboard and the
command line tools. If you are starting out it will be easiest to use the
dashboard. As you become more familiar with the Catalyst Cloud it is worth
learning how to provision resources programmatically.

You are free to use whichever method suits you, you can use these methods in
isolation or they can be combined. If you do not use the dashboard to launch
the compute instance, it can still be useful to make use of it to verify the
stack that you have created via another method.

Network Requirements
====================

Before launching an instance, it is necessary to have some network resources in
place. These may have already been created for you. In this documentation we
are going to assume your are starting from an un-configured tenant so we will
be demonstrating how to set these up from scratch.

The requirements are:

* A Network
* A Subnet with addressing and DHCP/DNS servers configured
* A Router with a gateway set and an interface in a virtual network

Catalyst operate a number of recursive DNS servers in each cloud region for
use by Catalyst Cloud instances, free of charge. They are:

+----------+------------------------------------------------+
|  Region  | DNS Servers                                    |
+==========+================================================+
| nz-por-1 | 202.78.247.197, 202.78.247.198, 202.78.247.199 |
+----------+------------------------------------------------+
| nz_wlg_2 | 202.78.240.213, 202.78.240.214, 202.78.240.215 |
+----------+------------------------------------------------+

When creating a router and network/subnet keep any network requirements in mind
when choosing addressing for your networks. You may want to build a tunnel-mode
VPN in the future to connect your OpenStack private network to another private
network. Choosing a unique subnet now will ensure you will not experience
collisions that require renumbering in the future.

Compute Flavors
===============

The flavor of an instance is the CPU, memory and disk specifications of a
compute instance. Catalyst flavors are named 'cX.cYrZ', where X is the
'compute generation', Y is the number of vCPUs, and Z is the number of
gigabytes of memory.

.. note::

  Flavour names are identical across all regions, but the flavour IDs will
  vary.

Operating System Images
=======================

In order to create an instance, you will need to have a pre-built operating
system in the form of an Image.  Images are stored in the Image service
(Glance). The Catalyst Cloud provide a set of images for general use and also
allows you to upload your own images.

.. note::

 Image IDs for the same operating system will be different in each region.
 Further, images are periodically updated receiving new IDs over time. You
 should always look up for an image based on its name and then retrieve the ID
 for it.

Uploading an SSH key
====================

When an instance is created, OpenStack will pass an ssh key to the instance
which can be used for shell access. By default, Ubuntu will install this key
for the 'ubuntu' user. Other operating systems have different default users, as
listed here: :ref:`images`

Tip: name your key using information like the username and host on which the
ssh key was generated so that it is easy to identify later.

Keypairs must be created in each region being used.

Security Groups
===============

Security groups are akin to a virtual firewall. All new instances are put in
the 'default' security group. When unchanged, the default security group allows
all egress (outbound) traffic, but will drop all ingress (inbound) traffic. In
order to allow inbound access to our instance via SSH a security group rule is
required.

While we could create security group rules within the default group to allow
access to our instance it is sensible to create a new group to hold the rules
specific to our instance.  This is a useful way to group the rules associated
with our instance and provides a convenient way to delete all rules for an
instance when we need to cleanup resources. It is also a useful way to assign
the same rules to subsequent instances that you may create.

.. warning::

  Note that by using the CIDR 0.0.0.0/0 as a remote, you are allowing access
  from any IP to your compute instance on the port and protocol selected. This
  is often desirable when exposing a web server (eg: allow HTTP and HTTPs
  access from the Internet), but is insecure when exposing other protocols,
  such as SSH, Telnet and FTP. We strongly recommend you to limit the exposure
  of your compute instances and services to IP addresses or subnets that are
  trusted.

Floating IPs
============

In order to connect to our instance, we will need to allocate a floating IP
to the instance. Alternately, one could create a VPN and save some money by
avoiding floating IPs altogether. VPNs are not feasible when the instance
will be offering a service to the greater internet.


************************************************
Launching your first instance from the dashboard
************************************************

Log in to the dashboard at https://dashboard.cloud.catalyst.net.nz/

Creating the required network elements
======================================

We need to create a router and network/subnet.

Navigate to the "Routers" section and click "Create Router":

.. image:: _static/fi-router-create.png
   :align: center

Name the router "border-router", select admin state "UP" and select
"public-net" as the external network:

.. image:: _static/fi-router-name.png
   :align: center

Navigate to the "Networks" section and click "Create Network":

.. image:: _static/fi-network-create.png
   :align: center

Name your network "private-net", select create subnet and click "Next":

.. image:: _static/fi-network-create-name.png
   :align: center

Name your subnet "private-subnet", choose an address for your subnet in CIDR
notation and click "Next":

.. image:: _static/fi-network-address.png
   :align: center

Specify additional attributes for the subnet including enabling DHCP,
specifying the DNS servers for your region and optionally defining an
allocation pool:

.. image:: _static/fi-network-detail.png
   :align: center

Click on the router name in the router list:

.. image:: _static/fi-router-detail.png
   :align: center

Select the "Interfaces" tab and click "+Add Interface":

.. image:: _static/fi-router-interface-add.png
   :align: center

Select the correct subnet:

.. image:: _static/fi-router-interface-subnet.png
   :align: center

You should now have a network topology this looks like this:

.. image:: _static/fi-network-topology.png
   :align: center

Uploading an SSH key
====================

You can either import an existing public key or have OpenStack create a key for
you, we document how to import an existing key here.

Select "Import Key Pair":

.. image:: _static/fi-key-pair-import-1.png
   :align: center

Enter your key pair name and paste your public key into the box:

.. image:: _static/fi-key-pair-import-2.png
   :align: center

Configure Instance Security Group
=================================

We need to create a security group and rule for our instance.

Navigate to the "Security Groups" tab of the "Access & Security" section and
click "Create Security Group":

.. image:: _static/fi-security-group-create-1.png
   :align: center

Enter a name and description and click "Create Security Group":

.. image:: _static/fi-security-group-create-2.png
   :align: center

Now click on "Manage Rules" for the group we have created:

.. image:: _static/fi-security-group-rules-manage.png
   :align: center

Click on “Add Rule”:

.. image:: _static/fi-security-group-rule-add.png
   :align: center

Enter 22 for the port number (this is the TCP port the SSH service listens on).
You can use the default values for the remainder of the options. Click "Add":

.. image:: _static/fi-security-group-rule-add-add.png
   :align: center

|

.. warning::

  Note that by using the CIDR 0.0.0.0/0 as a remote, you are allowing access
  from any IP to your compute instance on the port and protocol selected. This
  is often desirable when exposing a web server (eg: allow HTTP and HTTPs
  access from the Internet), but is insecure when exposing other protocols,
  such as SSH, Telnet and FTP. We strongly recommend you to limit the exposure
  of your compute instances and services to IP addresses or subnets that are
  trusted.

Booting an Instance
===================

We are now ready to launch our first instance, select launch instance from the
instances list:

.. image:: _static/fi-instance-launch.png
   :align: center

Enter an instance name, use the default instance count of one.  Select "Image"
as the boot source and "No" for create new volume. Select the
``ubuntu-14.04-x86_64`` from the image list. Then click "Next":

.. image:: _static/fi-launch-instance-source.png
   :align: center

Select the ``c1.c1r1`` flavor from the list and click "Next":

.. image:: _static/fi-launch-instance-flavor.png
   :align: center

Select the ``private-net`` network from the list and click "Next":

.. image:: _static/fi-launch-instance-networks.png
   :align: center

Select the ``first-instance`` security group from the list and click "Next":

.. image:: _static/fi-launch-instance-security-groups.png
   :align: center

Select the ``first-instance-key`` key pair from the list and click "Next":

.. image:: _static/fi-launch-instance-key-pair.png
   :align: center

Your instance will now be built, you will see the Status, Task and Power State
change during this process which will take a few seconds. When the process is
complete the status will be "Active". We now have a running instance but there
are a few more steps required before we can login.

Allocate a Floating IP
======================

To associate a floating IP you need to navigate to the "Floating IPs" tab of
the "Access & Security" section.

If you do not have an IP allocated, first click on "Allocate IP to Project" to
obtain a public IP. Then, select an IP that is not currently mapped and click
on "Associate":

.. image:: _static/fi-floating-ip.png
   :align: center

Select the port you wish to be associated with the floating IP. Ports are
equivalent to virtual network interfaces of compute instances, and are named
after the compute instance that owns it.

In this example, select the "first-instance" port and click "Associate":

.. image:: _static/fi-floating-ip-associate.png
   :align: center

Connect to the new Instance
===========================

We can now connect to the SSH service using the floating public IP that we
associated with our instance in the previous step. This address is visible in
the Instances list or under the Floating IPs tab in Access & Security.

.. code-block:: bash

 $ ssh ubuntu@PUBLIC_IP

You should be able to interact with this instance as you would any Ubuntu
server.

***************************************************
Launching your first instance from the command line
***************************************************

This section assumes you have installed the OpenStack command line tools and
sourced an openrc file, as explained in :ref:`command-line-tools`.

.. note::

 This documentation displays values like ``<PRIVATE_SUBNET_ID>`` in command output, the majority of these will be displayed as UUIDs in your output. We will store many of these values in bash variables prefixed with ``CC_`` so you do not have to cut and paste them. The prefix ``CC_`` (Catalyst Cloud) is used to distinguish these varibles from the ``OS_`` variables derived from an openrc file.

Creating the required network elements
======================================

Lets create a router and network:

.. code-block:: bash

 $ neutron router-create border-router
 Created a new router:
 +-----------------------+--------------------------------------+
 | Field                 | Value                                |
 +-----------------------+--------------------------------------+
 | admin_state_up        | True                                 |
 | external_gateway_info |                                      |
 | id                    | <BORDER_ROUTER_ID>                   |
 | name                  | border-router                        |
 | status                | ACTIVE                               |
 | tenant_id             | <TENANT_ID>                          |
 +-----------------------+--------------------------------------+

 $ neutron router-gateway-set border-router public-net
 Set gateway for router border-router

 $ neutron net-create private-net
 Created a new network:
 +----------------+--------------------------------------+
 | Field          | Value                                |
 +----------------+--------------------------------------+
 | admin_state_up | True                                 |
 | id             | <PRIVATE_NETWORK_ID>                 |
 | name           | private-net                          |
 | shared         | False                                |
 | status         | ACTIVE                               |
 | subnets        |                                      |
 | tenant_id      | <TENANT_ID>                          |
 +----------------+--------------------------------------+

Now lets set our nameservers and create a subnet of the network we have just
created:

.. code-block:: bash

 $ if [[ $OS_REGION_NAME == "nz_wlg_2" ]]; then export CC_NAMESERVER_1=202.78.240.213 CC_NAMESERVER_2=202.78.240.214 CC_NAMESERVER_3=202.78.240.215; \
   elif [[ $OS_REGION_NAME == "nz-por-1" ]]; then export CC_NAMESERVER_1=202.78.247.197 CC_NAMESERVER_2=202.78.247.198 CC_NAMESERVER_3=202.78.247.199; \
   else echo 'please set OS_REGION_NAME'; fi;

 $ neutron subnet-create --name private-subnet --allocation-pool start=10.0.0.10,end=10.0.0.200 --dns-nameserver $CC_NAMESERVER_1 \
   --dns-nameserver $CC_NAMESERVER_2 --dns-nameserver $CC_NAMESERVER_3 --enable-dhcp private-net 10.0.0.0/24
 Created a new subnet:
 +------------------+---------------------------------------------+
 | Field            | Value                                       |
 +------------------+---------------------------------------------+
 | allocation_pools | {"start": "10.0.0.10", "end": "10.0.0.200"} |
 | cidr             | 10.0.0.0/24                                 |
 | dns_nameservers  | <NAMESERVER_1>                              |
 |                  | <NAMESERVER_2>                              |
 |                  | <NAMESERVER_3>                              |
 | enable_dhcp      | True                                        |
 | gateway_ip       | 10.0.0.1                                    |
 | host_routes      |                                             |
 | id               | <PRIVATE_SUBNET_ID>                         |
 | ip_version       | 4                                           |
 | name             | private-subnet                              |
 | network_id       | <PRIVATE_NETWORK_ID>                        |
 | tenant_id        | <TENANT_ID>                                 |
 +------------------+---------------------------------------------+

Now create a router interface on the subnet:

.. code-block:: bash

 $ neutron router-interface-add border-router private-subnet
 Added interface <INTERFACE_ID> to router border-router.

Choosing a Flavor
=================

The flavor of an instance is the disk, CPU, and memory specifications of an
instance.  Use 'nova flavor-list' to get a list.  Catalyst flavors are named
'cX.cY.cZ', where X is the 'compute generation', Y is the number of vCPUs, and
Z is the number of gigabytes of memory. We will export an environment variable
with the flavour id for later use.

.. code-block:: bash

 $ nova flavor-list
 +--------------------------------------+------------------+-----------+------+-----------+------+-------+-------------+-----------+
 | ID                                   | Name             | Memory_MB | Disk | Ephemeral | Swap | VCPUs | RXTX_Factor | Is_Public |
 +--------------------------------------+------------------+-----------+------+-----------+------+-------+-------------+-----------+
 | 01b42bbc-347f-43e8-9a07-0a51105a5527 | c1.c8r8          | 8192      | 10   | 0         |      | 8     | 1.0         | True      |
 | 0c7dc485-e7cc-420d-b118-021bbafa76d7 | c1.c2r8          | 8192      | 10   | 0         |      | 2     | 1.0         | True      |
 | 1750075c-cd8a-4c87-bd06-a907db83fec6 | c1.c1r2          | 2048      | 10   | 0         |      | 1     | 1.0         | True      |
 | 1d760238-67a7-4415-ab7b-24a88a49c117 | c1.c8r32         | 32768     | 10   | 0         |      | 8     | 1.0         | True      |
 | 3931e022-24e7-4678-bc3f-ee86ec129819 | c1.c1r1          | 1024      | 8    | 0         |      | 1     | 1.0         | True      |
 | 45060aa3-3400-4da0-bd9d-9559e172f678 | c1.c4r8          | 8192      | 10   | 0         |      | 4     | 1.0         | True      |
 | 4efb43da-132e-4b50-a9d9-b73e827938a9 | c1.c2r16         | 16384     | 10   | 0         |      | 2     | 1.0         | True      |
 | 62473bef-f73b-4265-a136-e3ae87e7f1e2 | c1.c4r4          | 4096      | 10   | 0         |      | 4     | 1.0         | True      |
 | 746b8230-b763-41a6-954c-b11a29072e52 | c1.c1r4          | 4096      | 10   | 0         |      | 1     | 1.0         | True      |
 | 7b74c2c5-f131-4981-90ef-e1dc1ae51a8f | c1.c8r16         | 16384     | 10   | 0         |      | 8     | 1.0         | True      |
 | a197eac1-9565-4052-8199-dfd8f31e5553 | c1.c8r4          | 4096      | 10   | 0         |      | 8     | 1.0         | True      |
 | a80af444-9e8a-4984-9f7f-b46532052a24 | c1.c4r2          | 2048      | 10   | 0         |      | 4     | 1.0         | True      |
 | b152339e-e624-4705-9116-da9e0a6984f7 | c1.c4r16         | 16384     | 10   | 0         |      | 4     | 1.0         | True      |
 | b4a3f931-dc86-480c-b7a7-c34b2283bfe7 | c1.c4r32         | 32768     | 10   | 0         |      | 4     | 1.0         | True      |
 | c093745c-a6c7-4792-9f3d-085e7782eca6 | c1.c2r4          | 4096      | 10   | 0         |      | 2     | 1.0         | True      |
 | e3feb785-af2e-41f7-899b-6bbc4e0b526e | c1.c2r2          | 2048      | 10   | 0         |      | 2     | 1.0         | True      |
 +--------------------------------------+------------------+-----------+------+-----------+------+-------+-------------+-----------+
 $ export CC_FLAVOR_ID=$( nova flavor-list | grep c1.c1r1 | awk '{ print $2 }' )

In this tutorial we have chosen to use a c1.c1r1 instance.

.. note::
 These IDs will be different in each region.

Choosing an Image
=================

In order to create an instance, you will need to have a pre-built Operating
System in the form of an Image.  Images are stored in the Glance service.
Catalyst provide a set of images for general use.  If none of those are
sufficient, custom images can be uploaded to Glance by anyone. Here is an
example of how to locate a suitable image. We will export an environment
variable with the image id for later use.

.. code-block:: bash

 $ glance image-list --owner 94b566de52f9423fab80ceee8c0a4a23 --is-public True
 +--------------------------------------+-----------------------+-------------+------------------+------------+--------+
 | ID                                   | Name                  | Disk Format | Container Format | Size       | Status |
 +--------------------------------------+-----------------------+-------------+------------------+------------+--------+
 | db7bff4e-0e9c-46e3-8284-341464132492 | centos-7.0-x86_64     | raw         | bare             | 8589934592 | active |
 | 05cfb4f0-b2a8-411a-8d57-c3317e6c31be | cirros-0.3.1-x86_64   | raw         | bare             | 41126400   | active |
 | f5b1388b-107e-4c91-8e84-8371e4bf3672 | coreos-494.4.0-x86_64 | raw         | bare             | 9116319744 | active |
 | 0368593a-60ef-48a3-885a-add8dfefe569 | ubuntu-14.04-x86_64   | raw         | bare             | 2361393152 | active |
 +--------------------------------------+-----------------------+-------------+------------------+------------+--------+
 $ export CC_IMAGE_ID=$( glance image-list --name 'ubuntu-14.04-x86_64' | grep ubuntu-14.04-x86_64 | awk '{ print $2 }' )

Let's use the ubuntu image to create this instance. Note that these IDs will be
different in each region. Furthermore, images are periodically updated so the
ID of an Ubuntu image will change over time.

.. _uploading-an-ssh-key:

Uploading an SSH key
====================

When an instance is created, OpenStack passes an SSH key to the instance which
can be used for shell access. By default, Ubuntu will install this key for the
'ubuntu' user. Other operating systems have a different default user, as listed
here: :ref:`images`

Use ``nova keypair-add`` to upload your Public SSH key.

.. tip::
 You can name your key using information like the username and host on which the ssh key
 was generated so that it is easy to identify later.

.. code-block:: bash

 $ nova keypair-add --pub-key ~/.ssh/id_rsa.pub first-instance-key
 $ nova keypair-list
 +--------------------+-------------------------------------------------+
 | Name               | Fingerprint                                     |
 +--------------------+-------------------------------------------------+
 | first-instance-key | <SSH_KEY_FINGERPRINT>                           |
 +--------------------+-------------------------------------------------+

.. note::
 These keypairs must be created in each region being used.

Choosing a Network
==================

Use Neutron to locate the correct network to use. We will export an environment
variable with the network id for later use.

.. code-block:: bash

 $ neutron net-list
 +--------------------------------------+-------------+----------------------------+
 | id                                   | name        | subnets                    |
 +--------------------------------------+-------------+----------------------------+
 | <PUBLIC_NETWORK_ID>                  | public-net  | <PUBLIC_SUBNET_ID>         |
 | <PRIVATE_NETWORK_ID>                 | private-net | <MY_SUBNET_ID> 10.0.0.0/24 |
 +--------------------------------------+-------------+----------------------------+
 $ export CC_PUBLIC_NETWORK_ID=$( neutron net-list | grep public-net | awk '{ print $2 }' )
 $ export CC_PRIVATE_NETWORK_ID=$( neutron net-list | grep private-net | awk '{ print $2 }' )

The `public-net` is used by routers to access the Internet. Instances may not
be booted on this network. We will use private-net to boot our instance.

.. note::
 These IDs will be different in each region.

Configure Instance Security Group
=================================

We need to create a security group and rule for our instance.

.. code-block:: bash

 $ neutron security-group-create --description 'network access for our first instance.' first-instance
 Created a new security_group:
 +----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | Field                | Value                                                                                                                                                                                                                                                                                                                         |
 +----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | description          | network access for our first instance.                                                                                                                                                                                                                                                                                        |
 | id                   | f0c68b05-edcf-48f6-bfc8-b5537ab255fe                                                                                                                                                                                                                                                                                          |
 | name                 | first-instance                                                                                                                                                                                                                                                                                                                |
 | security_group_rules | {"remote_group_id": null, "direction": "egress", "remote_ip_prefix": null, "protocol": null, "tenant_id": "0cb6b9b744594a619b0b7340f424858b", "port_range_max": null, "security_group_id": "f0c68b05-edcf-48f6-bfc8-b5537ab255fe", "port_range_min": null, "ethertype": "IPv4", "id": "a93fff5c-9cd6-40d4-9dd5-6cc6eba1b134"} |
 |                      | {"remote_group_id": null, "direction": "egress", "remote_ip_prefix": null, "protocol": null, "tenant_id": "0cb6b9b744594a619b0b7340f424858b", "port_range_max": null, "security_group_id": "f0c68b05-edcf-48f6-bfc8-b5537ab255fe", "port_range_min": null, "ethertype": "IPv6", "id": "fe2a202a-6bc1-4064-8499-88401196899b"} |
 | tenant_id            | 0cb6b9b744594a619b0b7340f424858b                                                                                                                                                                                                                                                                                              |
 +----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

We can now create a rule within our group. You can issue the ``neutron
security-group-list`` command to find the ``SECURITY_GROUP_ID``. We will export
an environment variable with the security group id for later use.

.. code-block:: bash

 $ neutron security-group-list
 +--------------------------------------+----------------+----------------------------------------+
 | id                                   | name           | description                            |
 +--------------------------------------+----------------+----------------------------------------+
 | 687512ab-f197-4f07-ae51-788c559883b9 | default        | default                                |
 | f0c68b05-edcf-48f6-bfc8-b5537ab255fe | first-instance | network access for our first instance. |
 +--------------------------------------+----------------+----------------------------------------+
 $ export CC_SECURITY_GROUP_ID=$(neutron security-group-list | grep first-instance | awk '{ print $2 }' )

Next we will set an environment variable with our local external IP address:

.. code-block:: bash

 $ export CC_REMOTE_CIDR_NETWORK="$( curl -s http://curlmyip.com )/32"
 $ echo $CC_REMOTE_CIDR_NETWORK

Ensure that this variable is correctly set and if not set it manually. If you
are unsure of what ``CC_REMOTE_CIDR_NETWORK`` should be, ask your network
admin, or visit http://ifconfig.me and get your IP address. Use
"<IP_ADDRESS>/32" as ``CC_REMOTE_CIDR_NETWORK`` to allow traffic only from your
current effective IP.

Now we can create a rule to restrict SSH access to our instance to our current
public IP address:

.. code-block:: bash

 $ neutron security-group-rule-create --direction ingress \
   --protocol tcp --port-range-min 22 --port-range-max 22 \
   --remote-ip-prefix $CC_REMOTE_CIDR_NETWORK $CC_SECURITY_GROUP_ID


Booting an Instance
===================

Use the ``nova boot`` command and supply the information we gathered in
previous steps. Ensure you have appropriate values set for ``CC_FLAVOR_ID``,
``CC_IMAGE_ID`` and ``CC_PRIVATE_NETWORK_ID``.

.. code-block:: bash

 $ env | grep CC_

 $ nova boot --flavor $CC_FLAVOR_ID --image $CC_IMAGE_ID --key-name first-instance-key --security-groups default,first-instance --nic net-id=$CC_PRIVATE_NETWORK_ID first-instance

After issuing that command, details about the new Instance, including its id
will be provided. ::

 +--------------------------------------+------------------------------------------------------------+
 | Property                             | Value                                                      |
 +--------------------------------------+------------------------------------------------------------+
 | OS-DCF:diskConfig                    | MANUAL                                                     |
 | OS-EXT-AZ:availability_zone          | nova                                                       |
 | OS-EXT-STS:power_state               | 0                                                          |
 | OS-EXT-STS:task_state                | scheduling                                                 |
 | OS-EXT-STS:vm_state                  | building                                                   |
 | OS-SRV-USG:launched_at               | -                                                          |
 | OS-SRV-USG:terminated_at             | -                                                          |
 | accessIPv4                           |                                                            |
 | accessIPv6                           |                                                            |
 | adminPass                            | <ADMIN_PASS>                                               |
 | config_drive                         |                                                            |
 | created                              | 2015-01-14T21:16:28Z                                       |
 | flavor                               | c1.c1r1 (<FLAVOR_ID>)                                      |
 | hostId                               |                                                            |
 | id                                   | <INSTANCE_ID>                                              |
 | image                                | ubuntu-14.04-x86_64 (<IMAGE_ID>)                           |
 | key_name                             | username-hostname                                          |
 | metadata                             | {}                                                         |
 | name                                 | first-instance                                             |
 | os-extended-volumes:volumes_attached | []                                                         |
 | progress                             | 0                                                          |
 | security_groups                      | default, first-instance                                    |
 | status                               | BUILD                                                      |
 | tenant_id                            | <TENANT_ID>                                                |
 | updated                              | 2015-01-14T21:16:28Z                                       |
 | user_id                              | <USER_ID>                                                  |
 +--------------------------------------+------------------------------------------------------------+

Note that the status is 'BUILD' Catalyst Cloud instances build very quickly,
but it still takes a few seconds. Wait a few seconds and ask for the status of
this instance using the <INSTANCE_ID> or name (if unique) of this instance.

.. code-block:: bash

 $ nova show first-instance
 +--------------------------------------+------------------------------------------------------------+
 | Property                             | Value                                                      |
 +--------------------------------------+------------------------------------------------------------+
 | OS-DCF:diskConfig                    | MANUAL                                                     |
 | OS-EXT-AZ:availability_zone          | nz-por-1a                                                  |
 | OS-EXT-STS:power_state               | 1                                                          |
 | OS-EXT-STS:task_state                | -                                                          |
 | OS-EXT-STS:vm_state                  | active                                                     |
 | OS-SRV-USG:launched_at               | 2015-01-14T21:16:49.000000                                 |
 | OS-SRV-USG:terminated_at             | -                                                          |
 | accessIPv4                           |                                                            |
 | accessIPv6                           |                                                            |
 | config_drive                         |                                                            |
 | created                              | 2015-01-14T21:16:28Z                                       |
 | flavor                               | c1.c1r1 (<FLAVOR_ID>)                                      |
 | hostId                               | <HOST_ID>                                                  |
 | id                                   | <INSTANCE_ID>                                              |
 | image                                | ubuntu-14.04-x86_64 (<IMAGE_ID>)                           |
 | key_name                             | first-instance-key                                         |
 | metadata                             | {}                                                         |
 | name                                 | first-instance                                             |
 | os-extended-volumes:volumes_attached | []                                                         |
 | progress                             | 0                                                          |
 | security_groups                      | default                                                    |
 | status                               | ACTIVE                                                     |
 | tenant_id                            | <TENANT_ID>                                                |
 | testing network                      | 10.0.0.6                                                   |
 | updated                              | 2015-01-14T21:16:49Z                                       |
 | user_id                              | <USER_ID>                                                  |
 +--------------------------------------+------------------------------------------------------------+

Allocate a Floating IP
======================

In order to connect to our instance, we will need to allocate a floating IP to
the instance. We will use the id of public-net (found via 'neutron net-list')
and request a new floating IP.

.. code-block:: bash

 $ neutron floatingip-create $CC_PUBLIC_NETWORK_ID
 Created a new floatingip:
 +---------------------+----------------------------+
 | Field               | Value                      |
 +---------------------+----------------------------+
 | fixed_ip_address    |                            |
 | floating_ip_address | <PUBLIC_IP>                |
 | floating_network_id | <PUBLIC_NETWORK_ID>        |
 | id                  | <FLOATING_IP_ID>           |
 | port_id             |                            |
 | router_id           |                            |
 | status              | DOWN                       |
 | tenant_id           | <TENANT_ID>                |
 +---------------------+----------------------------+
 $ export CC_FLOATING_IP_ID=$( neutron floatingip-list -c status -c floating_ip_address -c id | grep DOWN | head -1 | awk '{ print $6 }' )
 $ export CC_PUBLIC_IP=$( neutron floatingip-list -c floating_ip_address -c id | grep $CC_FLOATING_IP_ID | awk '{ print $2 }' )

Now, get the port id of the instance's interface and associate the floating IP
with it.

.. code-block:: bash

 $ nova interface-list first-instance
 +------------+---------------+----------------------+--------------+-------------------+
 | Port State | Port ID       | Net ID               | IP addresses | MAC Addr          |
 +------------+---------------+----------------------+--------------+-------------------+
 | ACTIVE     | <PORT_ID>     | <PRIVATE_NETWORK_ID> | 10.0.0.6     | fa:16:3e:0c:89:14 |
 +------------+---------------+----------------------+--------------+-------------------+
 $ export CC_PORT_ID=$( nova interface-list first-instance | grep $CC_PRIVATE_NETWORK_ID | awk '{ print $4 }' )

 $ neutron floatingip-associate $CC_FLOATING_IP_ID $CC_PORT_ID
 Associated floating IP <FLOATING_IP_ID>

Connect to the new Instance
===========================

This should be as easy as:

.. code-block:: bash

 $ ssh ubuntu@$CC_PUBLIC_IP

*************************************************
Launching your first instance using a bash script
*************************************************

This section provides a bash script that runs the commands from the previous
section in a single script.

.. literalinclude:: ../scripts/create-first-instance.sh
  :language: bash

.. _launching-your-first-instance-using-ansible:

*******************************************
Launching your first instance using Ansible
*******************************************

`Ansible`_ is a popular open source configuration management and application
deployment tool. Ansible provides a set of core modules for interacting with
OpenStack. This makes Ansible an ideal tool for providing both OpenStack
orchestration and instance configuration, letting you use a single tool to
setup the underlying infrastructure and configure instances. As such Ansible
can substitute for Heat for OpenStack orchestration and Puppet for instance
configuration.

.. _Ansible: http://www.ansible.com/

Comprehensive documentation of the Ansible OpenStack modules is available at
https://docs.ansible.com/ansible/list_of_cloud_modules.html#openstack

Install Ansible
===============

We have written a script to install the required Ansible and OpenStack
libraries within a Python virtual environment. This script is part of the
`catalystcloud-ansible`_ git repository. Lets clone this repository and run the
install script in order to install Ansible.

.. _catalystcloud-ansible: https://github.com/catalyst/catalystcloud-ansible

.. code-block:: bash

 $ git clone https://github.com/catalyst/catalystcloud-ansible.git && CC_ANSIBLE_DIR="$(pwd)/catalystcloud-ansible" && echo $CC_ANSIBLE_DIR
 $ cd catalystcloud-ansible
 $ ./install-ansible.sh
 Installing stable version of Ansible
 ...
 $ source $CC_ANSIBLE_DIR/ansible/bin/activate
 $ ansible --version
 ansible 2.0.1.0
   config file = /etc/ansible/ansible.cfg
   configured module search path = Default w/o overrides

.. note::

  Catalyst recommends customers use Ansible >= 2.0 and Shade >= 1.4 with the
  Catalyst Cloud.

OpenStack credentials
=====================

Before we can run the playbooks we need to setup our OpenStack credentials, the
easiest way to achieve this is to make use of environment variables. We will
make use of the standard variables provided by an OpenStack RC file as
described at :ref:`source-rc-file`. These variables are read by the Ansible
``os_auth`` module to provide Ansible with permissions to access the Catalyst
Cloud APIs.

.. note::

 If you do not source an OpenStack RC file, you will need to set a few
 mandatory authentication attributes in the playbooks. See the vars section of
 the playbooks for details.

Now we have an Ansible installation that includes the required OpenStack
modules and have setup our OpenStack credentials we can proceed to build our
first instance. We have split the first instance playbooks into two playbook
files, the first playbook ``create-network.yml`` creates the required network
components and the second playbook ``launch-instance.yml`` launches the
instance.

Run the create network playbook
===============================

Lets take a look at what tasks the create network playbook is going to
complete:

.. code-block:: bash

 $ grep ' \- name' create-network.yml
     - name: Connect to the Catalyst Cloud
     - name: Create a network
     - name: Create a subnet
     - name: Create a router
     - name: Create a security group
     - name: Create a security group rule for SSH access
     - name: Import an SSH keypair

We are going to need to provide the path to a valid SSH key in order for this
playbook to work. You can edit ``create-network.yml`` and update the
``ssh_public_key`` variable, or we can override the variable when we run the
playbook as shown below:

.. note::

 Bash does not perform tilde expansion within quotes so you need to provide the
 full path to your SSH public key in the ssh_public_key extra var below.

.. code-block:: bash

 $ ansible-playbook --extra-vars 'ssh_public_key=/home/youruser/.ssh/id_rsa.pub' create-network.yml

 PLAY [Deploy a cloud instance in OpenStack] ************************************

 TASK [setup] *******************************************************************
 ok: [localhost]

 TASK [Connect to the Catalyst Cloud] *******************************************
 ok: [localhost]

 TASK [Create a network] ********************************************************
 changed: [localhost]

 TASK [Create a subnet] *********************************************************
 changed: [localhost]

 TASK [Create a router] *********************************************************
 changed: [localhost]

 TASK [Create a security group] *************************************************
 changed: [localhost]

 TASK [Create a security group rule for SSH access] *****************************
 changed: [localhost]

 TASK [Import an SSH keypair] ***************************************************
 changed: [localhost]

 PLAY RECAP *********************************************************************
 localhost                  : ok=8    changed=6    unreachable=0    failed=0


Run the launch instance playbook
================================

Now we have a network setup we can run the launch instance playbook:

.. code-block:: bash

 $ ansible-playbook launch-instance.yml
 SUDO password:

 PLAY [Deploy a cloud instance in OpenStack] ************************************

 TASK [setup] *******************************************************************
 ok: [localhost]

 TASK [Connect to the Catalyst Cloud] *******************************************
 ok: [localhost]

 TASK [Create a compute instance on the Catalyst Cloud] *************************
 changed: [localhost]

 TASK [Assign a floating IP] ****************************************************
 changed: [localhost]

 TASK [Output floating IP] ******************************************************
 ok: [localhost] => {
     "floating_ip_info.floating_ip.floating_ip_address": "150.242.41.75"
 }

 PLAY RECAP *********************************************************************
 localhost                  : ok=4    changed=2    unreachable=0    failed=1

We can now connect to our new instance via SSH using the IP address output by
the ``Output floating IP`` task:

.. code-block:: bash

 $ ssh ubuntu@150.242.41.75

We can now write playbooks to configure the instance we have created as
required.

.. _launching-your-first-instance-using-heat:

****************************************
Launching your first instance using Heat
****************************************

Heat is the native OpenStack orchestration tool. This section demonstrates how
to create your first instance using Heat.

It is beyond the scope of this section to explain the syntax of writing heat
templates, thus we will make use of a predefined example from the
`catalystcloud-orchestration`_ git repository. For more information on writing
heat templates please consult the documentation at :ref:`cloud-orchestration`.
The template used in this section can be used as an example template on which
you can build your own templates.

Let's checkout the catalystcloud-orchestration repository which includes the
heat templates we will be using:

.. _catalystcloud-orchestration: https://github.com/catalyst/catalystcloud-orchestration

.. code-block:: bash

 $ git clone https://github.com/catalyst/catalystcloud-orchestration.git && ORCHESTRATION_DIR="$(pwd)/catalystcloud-orchestration" && echo $ORCHESTRATION_DIR

Uploading an SSH key
====================

Heat does not support uploading the key itself so we need to do this step
manually.

When an instance is created, OpenStack passes an SSH key to the instance which
can be used for shell access. By default, Ubuntu will install this key for the
'ubuntu' user. Other operating systems have a different default user, as listed
here: :ref:`images`

Use ``nova keypair-add`` to upload your Public SSH key.

.. code-block:: bash

 $ nova keypair-add --pub-key ~/.ssh/id_rsa.pub first-instance-key
 $ nova keypair-list
 +--------------------+-------------------------------------------------+
 | Name               | Fingerprint                                     |
 +--------------------+-------------------------------------------------+
 | first-instance-key | <SSH_KEY_FINGERPRINT>                           |
 +--------------------+-------------------------------------------------+

Building the First Instance Stack using a HEAT Template
=======================================================

We will use a Heat template from the repository we cloned earlier. Before we
start, check that the template is valid:

.. code-block:: bash

 $ heat template-validate -f $ORCHESTRATION_DIR/hot/ubuntu-14.04/first-instance/first-instance.yaml

This command will echo the yaml if it succeeds and will return an error if it
does not. Assuming the template validates let's build the stack:

.. code-block:: bash

 $ heat stack-create first-instance-stack --template-file $ORCHESTRATION_DIR/hot/ubuntu-14.04/first-instance/first-instance.yaml
 +--------------------------------------+----------------------+--------------------+----------------------+
 | id                                   | stack_name           | stack_status       | creation_time        |
 +--------------------------------------+----------------------+--------------------+----------------------+
 | 18d3a376-ac33-4740-a2d3-19879f4807af | first-instance-stack | CREATE_IN_PROGRESS | 2015-11-12T20:19:42Z |
 +--------------------------------------+----------------------+--------------------+----------------------+

As you can see the creation is in progress. You can use the ``event-list``
command to check the progress of creation process:

.. code-block:: bash

 $ heat event-list first-instance-stack

Check the output of stack show:

.. code-block:: bash

 $ heat stack-show first-instance-stack
 +-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------+
 | Property              | Value                                                                                                                                           |
 +-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------+
 | capabilities          | []                                                                                                                                              |
 | creation_time         | 2016-01-28T03:47:03Z                                                                                                                            |
 | description           | HOT template for building the first instance stack on                                                                                           |
 |                       | the Catalyst Cloud nz-por-1 region.                                                                                                             |
 | disable_rollback      | True                                                                                                                                            |
 | id                    | 12de4178-a638-4b6a-9088-84b588db75e1                                                                                                            |
 | links                 | https://api.nz-por-1.catalystcloud.io:8004/v1/0cb6b9b744594a619b0b7340f424858b/stacks/first-instance-stack/12de4178-a638-4b6a-9088-84b588db75e1 |
 | notification_topics   | []                                                                                                                                              |
 | outputs               | []                                                                                                                                              |
 | parameters            | {                                                                                                                                               |
 |                       |   "OS::project_id": "0cb6b9b744594a619b0b7340f424858b",                                                                                         |
 |                       |   "OS::stack_name": "first-instance-stack",                                                                                                     |
 |                       |   "private_net_cidr": "10.0.0.0/24",                                                                                                            |
 |                       |   "private_subnet_name": "private-subnet",                                                                                                      |
 |                       |   "key_name": "first-instance-key",                                                                                                             |
 |                       |   "image": "ubuntu-14.04-x86_64",                                                                                                               |
 |                       |   "private_net_pool_end": "10.0.0.200",                                                                                                         |
 |                       |   "domain_name": "localdomain",                                                                                                                 |
 |                       |   "OS::stack_id": "12de4178-a638-4b6a-9088-84b588db75e1",                                                                                       |
 |                       |   "private_net_gateway": "10.0.0.1",                                                                                                            |
 |                       |   "public_net": "public-net",                                                                                                                   |
 |                       |   "public_net_id": "849ab1e9-7ac5-4618-8801-e6176fbbcf30",                                                                                      |
 |                       |   "private_net_pool_start": "10.0.0.10",                                                                                                        |
 |                       |   "private_net_dns_servers": "202.78.247.197,202.78.247.198,202.78.247.199",                                                                    |
 |                       |   "private_net_name": "private-net",                                                                                                            |
 |                       |   "secgroup_name": "first-instance",                                                                                                            |
 |                       |   "router_name": "border-router",                                                                                                               |
 |                       |   "servers_flavor": "c1.c1r1",                                                                                                                  |
 |                       |   "host_name": "first-instance"                                                                                                                 |
 |                       | }                                                                                                                                               |
 | parent                | None                                                                                                                                            |
 | stack_name            | first-instance-stack                                                                                                                            |
 | stack_owner           | your@email.net.nz                                                                                                                               |
 | stack_status          | CREATE_COMPLETE                                                                                                                                 |
 | stack_status_reason   | Stack CREATE completed successfully                                                                                                             |
 | stack_user_project_id | 0cb6b9b744594a619b0b7340f424858b                                                                                                                |
 | template_description  | HOT template for building the first instance stack on                                                                                           |
 |                       | the Catalyst Cloud nz-por-1 region.                                                                                                             |
 | timeout_mins          | 60                                                                                                                                              |
 | updated_time          | None                                                                                                                                            |
 +-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------+

Once our stack status is ``CREATE_COMPLETE`` we can SSH to our first instance
using the floating IP:

.. code-block:: bash

 $ export CC_PUBLIC_IP=$( neutron floatingip-list -c status -c floating_ip_address | grep ACTIVE | awk '{ print $4 }' )
 $ ssh ubuntu@$CC_PUBLIC_IP

Deleting the First Instance Stack using Heat
============================================

When working with stacks created by Heat it is generally a good idea to use
Heat to delete resources rather than using the other OpenStack command line
tools. Deleting components of the stack manually can result in resources or
stacks in an inconsistent state.

Lets delete the ``first-instance-stack`` we created previously:

.. code-block:: bash

 $ heat stack-delete first-instance-stack
 +--------------------------------------+----------------------+---------------------+----------------------+
 | id                                   | stack_name           | stack_status        | creation_time        |
 +--------------------------------------+----------------------+---------------------+----------------------+
 | 12de4178-a638-4b6a-9088-84b588db75e1 | first-instance-stack | DELETE_IN_PROGRESS  | 2016-01-28T03:47:03Z |
 +--------------------------------------+----------------------+---------------------+----------------------+

Check that the stack has been deleted properly using the ``heat list``
command. If there is an error or the deletion is taking a long time check the
output of ``heat event-list first-instance-stack``.

*****************************************
Launching your first instance using a SDK
*****************************************

The Catalyst Cloud is built on top of the OpenStack project. There are many
Software Development Kits for a variety of different languages available for
OpenStack. Some of these SDKs are written specifically for OpenStack while
others are multi cloud SDKs that have an OpenStack provider. Some of these
libraries are written to support a particular service like Compute, while
others attempt to provide a unified interface to all services.

You will find an up to date list of recommended SDKs at
http://developer.openstack.org/. A more exhaustive list that includes in
development SDKs is available at https://wiki.openstack.org/wiki/SDKs.

In this section we will use the Apache Libcloud Python library to provision our
first instance. Libcloud is a python library for interacting with many of the
popular cloud service providers using a unified API. For more information see
https://libcloud.apache.org. Documentation for the OpenStack Libcloud driver is
available at
http://libcloud.readthedocs.org/en/latest/compute/drivers/openstack.html.

.. warning::

 Libcloud does not support the OpenStack Networking API.

As libcloud does not support the OpenStack Networking API we will need complete
the following two steps using one of the other documented methods.

1. Create a Network and Subnet
2. Create a Router

After you have setup the networks and router as described above we need to
install and configure libcloud.

Install libcloud
================

The recommended way to install an up to date version of apache libcloud is to
use pythons pip installer. In this example we will do this inside a python
virtual environment.

.. note::

 This document shows how to setup pip and the python virtual environment on
 Ubuntu 14.04. You will need to substitute appropriate steps for other
 operating systems.

Firstly we will install the required python packages:

.. code-block:: bash

 $ sudo apt-get install python-pip python-virtualenv

Next we will configure a python virtual environment:

.. code-block:: bash

 $ mkdir libcloud-first-instance
 $ cd libcloud-first-instance/
 $ virtualenv -p python2.7 .
 $ . bin/activate
 $ pip install apache-libcloud

You should now have libcloud installed, remember that you will need to invoke
your script from a shell that has sourced this virtualenv in order for the
libcloud libraries to be available.

.. code-block:: python

 from libcloud.compute.types import Provider
 from libcloud.compute.providers import get_driver

 provider = get_driver(Provider.OPENSTACK)

OpenStack credentials
=====================

The first step in getting our first instance running is to provide our python
script with the correct credentials and configuration appropriate for our
tenant. The easiest way to achieve this is to make use of environment
variables, we will make use of the standard variables provided by an OpenStack
RC file as described at :ref:`source-rc-file`.

We can reference these from our python script:

.. code-block:: python

 import os

 auth_username = os.environ['OS_USERNAME']
 auth_password = os.environ['OS_PASSWORD']
 auth_url = os.environ['OS_AUTH_URL']
 project_name = os.environ['OS_TENANT_NAME']
 region_name = os.environ['OS_REGION_NAME']

 # strip /v2.0
 if auth_url[-5:] == '/v2.0': auth_url = auth_url[:-5]

 conn = provider(
     auth_username,
     auth_password,
     ex_force_auth_url=auth_url,
     ex_force_auth_version='2.0_password',
     ex_tenant_name=project_name,
     ex_force_service_region=region_name,
 )

Using the interactive interpreter
=================================

.. note::

 This section is optional, if you do not wish to interact with the Catalyst
 Cloud interactively you can safely skip it.

We can use the code above to allow us to interact with the Catalyst Cloud via
the python interactive interpreter. Lets define a connection object called
``conn.py``:

.. code-block:: python

 #!/usr/bin/env python

 from libcloud.compute.types import Provider
 from libcloud.compute.providers import get_driver

 import os

 auth_username = os.environ['OS_USERNAME']
 auth_password = os.environ['OS_PASSWORD']
 auth_url = os.environ['OS_AUTH_URL']
 project_name = os.environ['OS_TENANT_NAME']
 region_name = os.environ['OS_REGION_NAME']

 # strip /v2.0
 if auth_url[-5:] == '/v2.0': auth_url = auth_url[:-5]

 print "creating a connection with the following credentials:"
 print "auth_username = " + auth_username
 print "project_name = " + project_name

 provider = get_driver(Provider.OPENSTACK)
 conn = provider(
     auth_username,
     auth_password,
     ex_force_auth_url=auth_url,
     ex_force_auth_version='2.0_password',
     ex_tenant_name=project_name,
     ex_force_service_region=region_name,
 )

We can then export this script in the ``PYTHONSTARTUP`` environment variable:

.. code-block:: bash

 $ export PYTHONSTARTUP=/path/to/conn.py

Now when we invoke the python interpreter we will have this connection object
available to us:

.. code-block:: bash

 $ python
 Python 2.7.6 (default, Jun 22 2015, 17:58:13)
 [GCC 4.8.2] on linux2
 Type "help", "copyright", "credits" or "license" for more information.
 creating a connection with the following credentials:
 auth_username = <your-username>
 project_name = <your-project-name>
 >>>

Choosing a Flavor
=================

The flavor of an instance is the disk, CPU, and memory specifications of an
instance. Use ``conn.list_sizes()`` to get a list:

.. code-block:: python

 >>> for flavor in conn.list_sizes():
 ...     if flavor.name == "c1.c1r1":
 ...         print(flavor)
 ...
 <OpenStackNodeSize: id=28153197-6690-4485-9dbc-fc24489b0683, name=c1.c1r1, ram=1024, disk=10, bandwidth=None, price=0.0, driver=OpenStack, vcpus=1,  ...>
 >>>

Lets store the flavor id in an environment variable:

.. code-block:: bash

 $ export CC_FLAVOR_ID=28153197-6690-4485-9dbc-fc24489b0683

We can use this variable in our script using the following code:

.. code-block:: python

 flavor_id = os.environ['CC_FLAVOR_ID']
 flavor = conn.ex_get_size(flavor_id)

Choosing an Image
=================

In order to create an instance, you will need to have a pre-built Operating
System in the form of an Image. Use ``conn.list_images()`` to get a list:

.. code-block:: python

 >>> for image in conn.list_images():
 ...     if image.name == "ubuntu-14.04-x86_64":
 ...         print(image)
 ...
 <NodeImage: id=9f2a6a6d-3e68-4914-8e53-b0079d77bb9d, name=ubuntu-14.04-x86_64, driver=OpenStack  ...>
 >>>

Lets store the image id in an environment variable:

.. code-block:: bash

 $ export CC_IMAGE_ID=9f2a6a6d-3e68-4914-8e53-b0079d77bb9d

We can use this variable in our script using the following code:

.. code-block:: python

 image_id = os.environ['CC_IMAGE_ID']
 image = conn.get_image(image_id)

Uploading an SSH key
====================

The following code uploads an SSH key:

.. code-block:: python

 keypair_name = 'first-instance-key'
 pub_key_file = '~/.ssh/id_rsa.pub'
 conn.import_key_pair_from_file(keypair_name, pub_key_file)

Configure Instance Security Group
=================================

The following code will create a security group and a rule within that group:

.. code-block:: python

 first_instance_security_group = conn.ex_create_security_group('first-instance', 'network access for our first instance.')
 conn.ex_create_security_group_rule(first_instance_security_group, 'TCP', 22, 22)

.. warning::

 The code above does not specify a source IP range for this rule, this will
 create a rule with 0.0.0.0/0 as the source, in doing so you are allowing access
 from any IP to your compute instance on the port and protocol selected. This is
 often desirable when exposing a web server (eg: allow HTTP and HTTPs access
 from the Internet), but is insecure when exposing other protocols, such as SSH,
 Telnet and FTP. We strongly recommend you to limit the exposure of your compute
 instances and services to IP addresses or subnets that are trusted.

 See
 http://libcloud.readthedocs.org/en/latest/compute/drivers/openstack.html#libcloud.compute.drivers.openstack.OpenStack_1_1_NodeDriver.ex_create_security_group_rule
 for documentation on setting the source IP range for this rule.

Booting an Instance
===================

The following code will launch an instance using libcloud:

.. code-block:: python

 instance_name = 'first-instance'
 first_instance = conn.create_node(
     name=instance_name,
     image=image,
     size=flavor,
     ex_keyname=keypair_name,
     ex_security_groups=[first_instance_security_group],
 )

 conn.wait_until_running([first_instance])

Allocate a Floating IP
======================

We can associate a floating IP with the following code:

.. code-block:: python

 pool = conn.ex_list_floating_ip_pools()[0]
 unused_floating_ip = pool.create_floating_ip()
 conn.ex_attach_floating_ip_to_node(first_instance, unused_floating_ip)

Complete script
===============

Putting everything together:

.. code-block:: python

 from libcloud.compute.types import Provider
 from libcloud.compute.providers import get_driver
 from libcloud.common.exceptions import BaseHTTPError

 import os

 auth_username = os.environ['OS_USERNAME']
 auth_password = os.environ['OS_PASSWORD']
 auth_url = os.environ['OS_AUTH_URL']
 project_name = os.environ['OS_TENANT_NAME']
 region_name = os.environ['OS_REGION_NAME']

 # strip /v2.0
 if auth_url[-5:] == '/v2.0': auth_url = auth_url[:-5]

 provider = get_driver(Provider.OPENSTACK)
 conn = provider(
     auth_username,
     auth_password,
     ex_force_auth_url=auth_url,
     ex_force_auth_version='2.0_password',
     ex_tenant_name=project_name,
     ex_force_service_region=region_name,
 )

 image_id = os.environ['CC_IMAGE_ID']
 image = conn.get_image(image_id)
 print(image)

 flavor_id = os.environ['CC_FLAVOR_ID']
 flavor = conn.ex_get_size(flavor_id)
 print(flavor)

 print('Checking for existing SSH key pair...')
 keypair_name = 'first-instance-key'
 pub_key_file = '~/.ssh/id_rsa.pub'
 keypair_exists = False
 for keypair in conn.list_key_pairs():
     if keypair.name == keypair_name:
         keypair_exists = True

 if keypair_exists:
     print('Keypair already exists. Skipping import.')
 else:
     print('adding keypair...')
     conn.import_key_pair_from_file(keypair_name, pub_key_file)

 for keypair in conn.list_key_pairs():
     if keypair.name == keypair_name:
         print(keypair)

 security_group_exists = False
 security_group_name = 'first-instance'
 for security_group in conn.ex_list_security_groups():
     if security_group.name == security_group_name:
         first_instance_security_group = security_group
         security_group_exists = True

 if security_group_exists:
     print('Security Group already exists. Skipping creation.')
 else:
     first_instance_security_group = conn.ex_create_security_group(security_group_name, 'network access for our first instance.')
     conn.ex_create_security_group_rule(first_instance_security_group, 'TCP', 22, 22)

 instance_name = 'first-instance'
 print('Creating instance {}'.format(instance_name))
 first_instance = conn.create_node(
     name=instance_name,
     image=image,
     size=flavor,
     ex_keyname=keypair_name,
     ex_security_groups=[first_instance_security_group],
 )

 conn.wait_until_running([first_instance])

 print('Checking for unused Floating IP...')
 unused_floating_ip = None
 for floating_ip in conn.ex_list_floating_ips():
     if not floating_ip.node_id:
         print('found unassociated floating ip:')
         print(floating_ip)
         unused_floating_ip = floating_ip
         break

 # we did not find an unassociated floating ip in our project so we will try and allocate one
 if not unused_floating_ip:
     pool = conn.ex_list_floating_ip_pools()[0]
     print('Retrieving new Floating IP from pool: {}'.format(pool))
     try:
         unused_floating_ip = pool.create_floating_ip()
     except BaseHTTPError, e:
         print('Error creating floating IP: ' + str(e))
     except:
         raise

 if unused_floating_ip:
     if conn.ex_attach_floating_ip_to_node(first_instance, unused_floating_ip):
         print('Allocated new Floating IP: {} to instance {}'.format(unused_floating_ip.ip_address, instance_name))
     else:
         print('Could not attach Floating IP')

     print('Your first instance is available you can ssh to ubuntu@%s' % unused_floating_ip.ip_address)
 else:
     print('Could not find an unused floating ip, please check your quota')


Connect to the new Instance
===========================

We can connect to the SSH service using the floating public IP that has been
associated with our instance. The script will print this address if it succeeds
in associating a floating IP with the newly created instance:

.. code-block:: bash

 Your first instance is available you can ssh to ubuntu@PUBLIC_IP

You should be able to interact with this instance as you would any Ubuntu
server.

**************************************
Resource cleanup from the command line
**************************************

At this point you may want to cleanup the OpenStack resources that have been
created. Running the following commands should remove all networks, routers,
ports, security groups and instances. These commands will work regardless of
the method you used to create the resources. Note that the order you delete
resources is important.

.. warning::

 The following commands will delete all the resources you have created
 including networks and routers, do not run these commands unless you wish to
 delete all these resources.

.. code-block:: bash

 # delete the instances
 $ nova delete first-instance

 # delete instance ports
 $ for port_id in $(neutron port-list | grep 10.0.0 | grep -v '10.0.0.1"' | awk '{ print $2 }'); do neutron port-delete $port_id; done

 # delete router interface
 $ neutron router-interface-delete border-router $(neutron subnet-list | grep private-subnet | awk '{ print $2 }')
 Removed interface from router border-router.

 # delete router
 $ neutron router-delete border-router
 Deleted router: border-router

 # delete subnet
 $ neutron subnet-delete private-subnet
 Deleted subnet: private-subnet

 # delete network
 $ neutron net-delete private-net
 Deleted network: private-net

 # delete security group
 $ neutron security-group-delete first-instance
 Deleted security_group: first-instance

 # delete ssh key
 $ nova keypair-delete first-instance-key

************************************
Resource cleanup using a bash script
************************************

This script includes all the comands from the section above in a single bash
script.

.. literalinclude:: ../scripts/delete-first-instance.sh
  :language: bash
