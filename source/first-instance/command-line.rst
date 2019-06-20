.. _using-the-command-line-interface:

********************************
Using the command line interface
********************************

The following is assumed:

* You have installed the OpenStack command line tools
* You have sourced an OpenRC file

If you haven't done the above, please refer to the
:ref:`command-line-interface` section for details on how to do so.

The following steps are broken down to show you how each individual part is
done. Even if you already have the required elements to create an
instance, we recommend going through all these steps and completing them to
give you a full view of how the individual pieces work together.

.. note::

 This documentation refers to values using placeholders (such as ``<PRIVATE_SUBNET_ID>``)
 in example command output. The majority of these values will be displayed as UUIDs
 in your output. Many of these values will be stored in bash variables prefixed with
 ``CC_`` so you do not have to cut and paste them. The prefix ``CC_`` (Catalyst Cloud)
 is used to  distinguish these variables from the ``OS_`` (OpenStack) variables obtained
 from an OpenRC file.


Creating the required network elements
======================================

Create a router called "border-router" with a gateway to "public-net".
Also create what will be a private network, called "private-net":

.. note::
 If you have completed one of the other tutorials, make sure that when you create
 your networks and routers with a different name to the ones in the previous tutorials.

.. code-block:: bash

 $ openstack router create border-router
 +-----------------------+--------------------------------------+
 | Field                 | Value                                |
 +-----------------------+--------------------------------------+
 | admin_state_up        | UP                                   |
 | external_gateway_info | null                                 |
 | headers               |                                      |
 | id                    | <BORDER_ROUTER_ID>                   |
 | name                  | border-router                        |
 | project_id            | <PROJECT_ID>                         |
 | routes                |                                      |
 | status                | ACTIVE                               |
 +-----------------------+--------------------------------------+

 $ openstack router set border-router --external-gateway public-net

 $ openstack network create private-net
 +-----------------+--------------------------------------+
 | Field           | Value                                |
 +-----------------+--------------------------------------+
 | admin_state_up  | UP                                   |
 | headers         |                                      |
 | id              | <PRIVATE_NETWORK_ID>                 |
 | mtu             | 0                                    |
 | name            | private-net                          |
 | project_id      | <PROJECT_ID>                         |
 | router:external | Internal                             |
 | shared          | False                                |
 | status          | ACTIVE                               |
 | subnets         |                                      |
 +-----------------+--------------------------------------+


Set your :ref:`DNS Name Servers <name_servers>` variables. Then create a subnet
of the "private-net" network, assigning the appropriate DNS server to that subnet.

.. code-block:: bash

 $ if [[ $OS_REGION_NAME == "nz_wlg_2" ]]; then export CC_NAMESERVER_1=202.78.240.213 CC_NAMESERVER_2=202.78.240.214 CC_NAMESERVER_3=202.78.240.215; \
 elif [[ $OS_REGION_NAME == "nz-por-1" ]]; then export CC_NAMESERVER_1=202.78.247.197 CC_NAMESERVER_2=202.78.247.198 CC_NAMESERVER_3=202.78.247.199; \
 elif [[ $OS_REGION_NAME == "nz-hlz-1" ]]; then export CC_NAMESERVER_1=202.78.244.85 CC_NAMESERVER_2=202.78.244.86 CC_NAMESERVER_3=202.78.244.87; \
 else echo 'please set OS_REGION_NAME'; fi;

 $ openstack subnet create --allocation-pool start=10.0.0.10,end=10.0.0.200 --dns-nameserver $CC_NAMESERVER_1 --dns-nameserver $CC_NAMESERVER_2 \
 --dns-nameserver $CC_NAMESERVER_3 --dhcp --network private-net --subnet-range 10.0.0.0/24 private-subnet
 +-------------------+------------------------------------------------+
 | Field             | Value                                          |
 +-------------------+------------------------------------------------+
 | allocation_pools  | 10.0.0.10-10.0.0.200                           |
 | cidr              | 10.0.0.0/24                                    |
 | dns_nameservers   | <NAMESERVER_1>,<NAMESERVER_2>,<NAMESERVER_3>   |
 | enable_dhcp       | True                                           |
 | gateway_ip        | 10.0.0.1                                       |
 | headers           |                                                |
 | host_routes       |                                                |
 | id                | <PRIVATE_SUBNET_ID>                            |
 | ip_version        | 4                                              |
 | ipv6_address_mode | None                                           |
 | ipv6_ra_mode      | None                                           |
 | name              | private-subnet                                 |
 | network_id        | <PRIVATE_NETWORK_ID>                           |
 | project_id        | <PROJECT_ID>                                   |
 | subnetpool_id     | None                                           |
 +-------------------+------------------------------------------------+


Now create a router interface on the "private-subnet" subnet:

.. code-block:: bash

 $ openstack router add subnet border-router private-subnet




Choosing a Flavor
=================

The Flavor of an instance specifies the disk, CPU, and memory allocated to  an
instance. Use ``openstack flavor list`` to see a list of available
configurations.

.. note::

  Catalyst flavors are named 'cX.cYrZ', where X is the "compute generation", Y is
  the number of vCPUs, and Z is the number of gigabytes of memory.

Choose a Flavor ID, assign it to an environment variable, then export for later
use:

.. code-block:: bash

 $ openstack flavor list
 +--------------------------------------+-----------+-------+------+-----------+-------+-----------+
 | ID                                   | Name      |   RAM | Disk | Ephemeral | VCPUs | Is Public |
 +--------------------------------------+-----------+-------+------+-----------+-------+-----------+
 | 01b42bbc-347f-43e8-9a07-0a51105a5527 | c1.c8r8   |  8192 |   10 |         0 |     8 | True      |
 | 0c7dc485-e7cc-420d-b118-021bbafa76d7 | c1.c2r8   |  8192 |   10 |         0 |     2 | True      |
 | 0f3be84b-9d6e-44a8-8c3d-8a0dfe226674 | c1.c16r16 | 16384 |   10 |         0 |    16 | True      |
 | 1750075c-cd8a-4c87-bd06-a907db83fec6 | c1.c1r2   |  2048 |   10 |         0 |     1 | True      |
 | 1d760238-67a7-4415-ab7b-24a88a49c117 | c1.c8r32  | 32768 |   10 |         0 |     8 | True      |
 | 28153197-6690-4485-9dbc-fc24489b0683 | c1.c1r1   |  1024 |   10 |         0 |     1 | True      |
 | 45060aa3-3400-4da0-bd9d-9559e172f678 | c1.c4r8   |  8192 |   10 |         0 |     4 | True      |
 | 4efb43da-132e-4b50-a9d9-b73e827938a9 | c1.c2r16  | 16384 |   10 |         0 |     2 | True      |
 | 62473bef-f73b-4265-a136-e3ae87e7f1e2 | c1.c4r4   |  4096 |   10 |         0 |     4 | True      |
 | 6a16e03f-9127-427c-99aa-3bdbdd58471a | c1.c16r8  |  8192 |   10 |         0 |    16 | True      |
 | 746b8230-b763-41a6-954c-b11a29072e52 | c1.c1r4   |  4096 |   10 |         0 |     1 | True      |
 | 7b74c2c5-f131-4981-90ef-e1dc1ae51a8f | c1.c8r16  | 16384 |   10 |         0 |     8 | True      |
 | 7cd52d7f-9272-47c9-a3ea-e8d7bc30a0bd | c1.c8r64  | 65536 |   10 |         0 |     8 | True      |
 | 88597cff-9503-492c-b005-98736f0bd705 | c1.c16r64 | 65536 |   10 |         0 |    16 | True      |
 | 92e03684-53d0-4f1e-9222-cf4fbb8ef15d | c1.c16r32 | 32768 |   10 |         0 |    16 | True      |
 | a197eac1-9565-4052-8199-dfd8f31e5553 | c1.c8r4   |  4096 |   10 |         0 |     8 | True      |
 | a80af444-9e8a-4984-9f7f-b46532052a24 | c1.c4r2   |  2048 |   10 |         0 |     4 | True      |
 | b152339e-e624-4705-9116-da9e0a6984f7 | c1.c4r16  | 16384 |   10 |         0 |     4 | True      |
 | b4a3f931-dc86-480c-b7a7-c34b2283bfe7 | c1.c4r32  | 32768 |   10 |         0 |     4 | True      |
 | c093745c-a6c7-4792-9f3d-085e7782eca6 | c1.c2r4   |  4096 |   10 |         0 |     2 | True      |
 | e3feb785-af2e-41f7-899b-6bbc4e0b526e | c1.c2r2   |  2048 |   10 |         0 |     2 | True      |
 +--------------------------------------+-----------+-------+------+-----------+-------+-----------|

 $ export CC_FLAVOR_ID=$( openstack flavor show c1.c1r1 -f value -c id )

This example assigns a c1.c1r1 flavor to the instance.

.. note::

 Flavor IDs will be different in each region. Remember always to check what is available
 using ``openstack flavor list``.


Choosing an Image
=================

In order to create an instance, you will use a pre-built Operating System
known as an Image. Images are stored in the Glance service.

.. note::

  Catalyst provides a number of popular images for general use. If your preferred image
  is not available, you may upload a custom image to Glance.

Choose an Image ID, assign it to an environment variable, then export for later
use:

.. code-block:: bash

 $ openstack image list --public
 +--------------------------------------+---------------------------------+--------+
 | ID                                   | Name                            | Status |
 +--------------------------------------+---------------------------------+--------+
 | 5892a80a-abc4-46f0-b39a-ecb4c0cb5d36 | ubuntu-18.04-x86_64             | active |
 | 49fb1409-c88e-4750-a394-56ddea80231d | ubuntu-16.04-x86_64             | active |
 | c75df558-7d84-4f97-9a5d-6eb58aeadcce | ubuntu-12.04-x86_64             | active |
 | cab9f3f4-a3a5-488b-885e-892873c15f53 | ubuntu-14.04-x86_64             | active |
 | f595d7ed-69c0-46b7-a688-a9d12d1e52dc | debian-8-x86_64                 | active |
 | 64ce626e-d1c6-41f3-805e-a283e83e4d85 | centos-6.6-x86_64               | active |
 | d46fde0f-01b4-4c21-b5a0-0d05df927c49 | centos-7.0-x86_64               | active |
 | bfbc68e4-afd6-4384-8790-ecf0ac3dd6a3 | atomic-7-x86_64                 | active |
 | b941a846-8cec-4f59-a39e-3720a25823cc | coreos-1068.8.0-x86_64          | active |
 | c14d3623-8912-4502-b2cc-0487d9913686 | ubuntu-14.04-x86_64-20160803    | active |
 | 08dd4b82-bea9-4f58-8351-6958fe7aae23 | ubuntu-12.04-x86_64-20160803    | active |
 | 37b45c3a-2ce4-4a21-980b-d835512eb35a | ubuntu-16.04-x86_64-20160803    | active |
 | 881fab19-35c6-410d-8d46-70e7f4db8c89 | centos-7.0-x86_64-20160802      | active |
 | bee47bef-78f9-41e5-bc0d-786786fad388 | centos-6.6-x86_64-20160802      | active |
 | c1e1cd17-1de4-4100-b280-1d10ee4aa8c0 | atomic-7-x86_64-20160802        | active |
 | 3d7b214f-1b67-4c89-bac7-01d449101c76 | debian-8-x86_64-20160802        | active |
 | 8c431b2b-1d89-4137-8b79-f288bfe65c9a | windows-server-2012r2-x86_64    | active |
 | 98123ffa-18ea-454b-9509-74fc4abee95d | debian-8-x86_64-20160620        | active |
 | 2e6ec1de-553b-4fa8-9997-d8366019ac68 | coreos-1010.5.0-x86_64-20160802 | active |
 | 0f9a3680-25d6-4efa-b202-32f26b4030e4 | centos-6.6-x86_64-20160620      | active |
 | 9e52bf38-addf-4391-8005-224be9113a0f | centos-7.0-x86_64-20160620      | active |
 | d3901dfa-1d19-48f9-bfea-163cebeb62d0 | ubuntu-16.04-x86_64-20160621    | active |
 | 4edfdb20-3af9-4880-a135-6d5971078460 | ubuntu-12.04-x86_64-20160622    | active |
 | ffee7150-70de-48bb-99b9-6cf5666b368c | atomic-7-x86_64-20160620        | active |
 | 661b2022-0f50-4783-b398-62113efd6bb2 | ubuntu-14.04-x86_64-20160624    | active |
 | f641e7f8-c8ac-4667-9a84-8653716fc1ad | centos-6.5-x86_64               | active |
 +--------------------------------------+---------------------------------+--------+

 $ export CC_IMAGE_ID=$( openstack image show ubuntu-18.04-x86_64 -f value -c id )

This example uses the Ubuntu image to create an instance.

.. note::

  The amount of images that Catalyst Provides can be quiete large, if you know what Operating System you want for your
  image you can use the command ``opentsack image list -- public | grep <OPERATING SYSTEM>``
  to find it quicker than looking through this list. Another thing to note is that;
  Image IDs will be different in each region. Furthermore, images are periodically updated so
  Image IDs will change over time. Remember always to check what is available
  using ``openstack image list --public``.


.. _uploading-an-ssh-key:

Uploading an SSH key
====================

When an instance is created, OpenStack places an SSH key on the instance which
can be used for shell access. By default, Ubuntu will install this key for the
"ubuntu" user. Other operating systems have a different default user, as listed
here: :ref:`images`

Use ``openstack keypair create`` to upload your Public SSH key.

.. tip::

 Name the key using information such as your username and the hostname on which the
 ssh key was generated. This makes the key easy to identify at a later stage.

.. code-block:: bash

 $ openstack keypair create --public-key ~/.ssh/id_rsa.pub first-instance-key
 +-------------+-------------------------------------------------+
 | Field       | Value                                           |
 +-------------+-------------------------------------------------+
 | fingerprint | <SSH_KEY_FINGERPRINT>                           |
 | name        | first-instance-key                              |
 | user_id     | <USER_ID>                                       |
 +-------------+-------------------------------------------------+

 $ openstack keypair list
 +--------------------+-------------------------------------------------+
 | Name               | Fingerprint                                     |
 +--------------------+-------------------------------------------------+
 | first-instance-key | <SSH_KEY_FINGERPRINT>                           |
 +------------+---------------------------------------------------------+

.. note::

 Keypairs must be created in each region being used.


Choosing a Network
==================

List the available networks and choose the appropriate network to use.
Assign the Network ID to an environment variable and export it for later use.

.. code-block:: bash

 $ openstack network list
 +--------------------------------------+-------------+----------------------------+
 | ID                                   | Name           | Subnets                 |
 +--------------------------------------+-------------+----------------------------+
 | <PUBLIC_NETWORK_ID>                  | public-net  | <PUBLIC_SUBNET_ID>         |
 | <PRIVATE_NETWORK_ID>                 | private-net | <PRIVATE_SUBNET_ID>        |
 +--------------------------------------+-------------+----------------------------+

 $ export CC_PUBLIC_NETWORK_ID=$( openstack network show public-net -f value -c id )
 $ export CC_PRIVATE_NETWORK_ID=$( openstack network show private-net -f value -c id )

The `public-net` is used by routers to access the Internet. Instances may not
be booted on this network. Choose "private-net" when assigning a network to the instance.

.. note::

  Network IDs will be different in each region. Remember to always check what is available
  using ``openstack network list``.


Configure Instance Security Group
=================================

Create a security group called "first-instance-sg".

.. code-block:: bash

 $ openstack security group create --description 'Network access for our first instance.' first-instance-sg
 +-------------+---------------------------------------------------------------------------------+
 | Field       | Value                                                                           |
 +-------------+---------------------------------------------------------------------------------+
 | description | Network access for our first instance.                                          |
 | headers     |                                                                                 |
 | id          | <SECURITY_GROUP_ID>                                                             |
 | name        | first-instance-sg                                                               |
 | project_id  | <PROJECT_ID>                                                                    |
 | rules       | direction='egress', ethertype='IPv4', id='afc19e4d-a3d3-467f-8da3-3a07d3d59acc' |
 |             | direction='egress', ethertype='IPv6', id='e027c9b3-f59b-40bb-b4ea-d44a0f057d7f' |
 +-------------+---------------------------------------------------------------------------------+


Create a rule within the "first-instance-sg" security group.

Issue the ``openstack security group list`` command to find the
``SECURITY_GROUP_ID``. Assign the Security Group ID to an environment variable
and export it for later use.

.. code-block:: bash

 $ openstack security group list
 +--------------------------------------+-------------------+----------------------------------------+----------------------------------+
 | ID                                   | Name              | Description                            | Project                          |
 +--------------------------------------+-------------------+----------------------------------------+----------------------------------+
 | 14aeedb8-5e9c-4617-8cf9-6e072bb41886 | first-instance-sg | Network access for our first instance. | 0cb6b9b744594a619b0b7340f424858b |
 | 687512ab-f197-4f07-ae51-788c559883b9 | default           | default                                | 0cb6b9b744594a619b0b7340f424858b |
 +--------------------------------------+-------------------+----------------------------------------+----------------------------------+

 $ export CC_SECURITY_GROUP_ID=$( openstack security group show first-instance-sg -f value -c id )


Assign the local external IP address to an environment variable and export it
for later use:

.. code-block:: bash

 $ export CC_REMOTE_CIDR_NETWORK="$( dig +short myip.opendns.com @resolver1.opendns.com )/32"
 $ echo $CC_REMOTE_CIDR_NETWORK

.. note::

 Ensure that this variable is correctly set and if not, set it manually. If you are unsure of
 what ``CC_REMOTE_CIDR_NETWORK`` should be, ask your network administrator, or visit
 http://ifconfig.me to find your IP address. Use "<IP_ADDRESS>/32" as ``CC_REMOTE_CIDR_NETWORK``
 to allow traffic only from your current effective IP.


Create a rule to restrict SSH access to your instance to the current public IP
address:

.. code-block:: bash

 $ openstack security group rule create --ingress --protocol tcp --dst-port 22 --remote-ip $CC_REMOTE_CIDR_NETWORK $CC_SECURITY_GROUP_ID
 +-------------------+--------------------------------------+
 | Field             | Value                                |
 +-------------------+--------------------------------------+
 | direction         | ingress                              |
 | ethertype         | IPv4                                 |
 | headers           |                                      |
 | id                | <SECURITY_GROUP_RULE_ID>             |
 | port_range_max    | 22                                   |
 | port_range_min    | 22                                   |
 | project_id        | <PROJECT_ID>                         |
 | protocol          | tcp                                  |
 | remote_group_id   | None                                 |
 | remote_ip_prefix  | <REMOTE_CIDR_NETWORK>                |
 | security_group_id | 14aeedb8-5e9c-4617-8cf9-6e072bb41886 |
 +-------------------+--------------------------------------+


Booting an Instance
===================

Use the ``openstack server create`` command, supplying the information
obtained in previous steps and exported as environment variables.

Ensure you have appropriate values set for
``CC_FLAVOR_ID``, ``CC_IMAGE_ID`` and ``CC_PRIVATE_NETWORK_ID``.

.. code-block:: bash

 $ env | grep CC_

 $ openstack server create --flavor $CC_FLAVOR_ID --image $CC_IMAGE_ID --key-name first-instance-key \
 --security-group default --security-group first-instance-sg --nic net-id=$CC_PRIVATE_NETWORK_ID first-instance


As the Instance builds, its details will be provided. This includes its ID
(represented by ``<INSTANCE_ID>``) below.

.. code-block:: bash

 +--------------------------------------+------------------------------------------------------------+
 | Field                                | Value                                                      |
 +--------------------------------------+------------------------------------------------------------+
 | OS-DCF:diskConfig                    | MANUAL                                                     |
 | OS-EXT-AZ:availability_zone          |                                                            |
 | OS-EXT-STS:power_state               | NOSTATE                                                    |
 | OS-EXT-STS:task_state                | scheduling                                                 |
 | OS-EXT-STS:vm_state                  | building                                                   |
 | OS-SRV-USG:launched_at               | None                                                       |
 | OS-SRV-USG:terminated_at             | None                                                       |
 | accessIPv4                           |                                                            |
 | accessIPv6                           |                                                            |
 | addresses                            |                                                            |
 | adminPass                            | <ADMIN_PASS>                                               |
 | config_drive                         |                                                            |
 | created                              | 2016-08-17T23:35:32Z                                       |
 | flavor                               | c1.c1r1 (28153197-6690-4485-9dbc-fc24489b0683)             |
 | hostId                               |                                                            |
 | id                                   | <INSTANCE_ID>                                              |
 | image                                | ubuntu-14.04-x86_64 (cab9f3f4-a3a5-488b-885e-892873c15f53) |
 | key_name                             | glyndavies                                                 |
 | name                                 | first-instance                                             |
 | os-extended-volumes:volumes_attached | []                                                         |
 | progress                             | 0                                                          |
 | project_id                           | <PROJECT_ID>                                               |
 | properties                           |                                                            |
 | security_groups                      | [{u'name': u'default'}, {u'name': u'first-instance-sg'}]   |
 | status                               | BUILD                                                      |
 | updated                              | 2016-08-17T23:35:33Z                                       |
 | user_id                              | <USER_ID>                                                  |
 +--------------------------------------+------------------------------------------------------------+



.. note::

 Observe that the status is ``BUILD`` Catalyst Cloud instances build very quickly,
 but it still takes a few seconds. Wait a few seconds and ask for the status of
 this instance using the ``<INSTANCE_ID>`` or name (if unique) of this instance.


.. code-block:: bash

 $ openstack server show first-instance
 +--------------------------------------+------------------------------------------------------------+
 | Field                                | Value                                                      |
 +--------------------------------------+------------------------------------------------------------+
 | OS-DCF:diskConfig                    | MANUAL                                                     |
 | OS-EXT-AZ:availability_zone          | nz-por-1a                                                  |
 | OS-EXT-STS:power_state               | Running                                                    |
 | OS-EXT-STS:task_state                | None                                                       |
 | OS-EXT-STS:vm_state                  | active                                                     |
 | OS-SRV-USG:launched_at               | 2016-09-02T00:30:13.000000                                 |
 | OS-SRV-USG:terminated_at             | None                                                       |
 | accessIPv4                           |                                                            |
 | accessIPv6                           |                                                            |
 | addresses                            | private-net=10.0.0.12                                      |
 | config_drive                         |                                                            |
 | created                              | 2016-09-02T00:29:44Z                                       |
 | flavor                               | c1.c1r1 (28153197-6690-4485-9dbc-fc24489b0683)             |
 | hostId                               | 4f39b132f41c2ab6113d5bbeedab6e1bc0b1a1095949dd64df815077   |
 | id                                   | <INSTANCE_ID>                                              |
 | image                                | ubuntu-16.04-x86_64 (49fb1409-c88e-4750-a394-56ddea80231d) |
 | key_name                             | first-instance-key                                         |
 | name                                 | first-instance                                             |
 | os-extended-volumes:volumes_attached | []                                                         |
 | progress                             | 0                                                          |
 | project_id                           | <PROJECT_ID>                                               |
 | properties                           |                                                            |
 | security_groups                      | [{u'name': u'default'}, {u'name': u'first-instance-sg'}]   |
 | status                               | ACTIVE                                                     |
 | updated                              | 2016-09-02T00:30:13Z                                       |
 | user_id                              | <USER_ID>                                                  |
 +--------------------------------------+------------------------------------------------------------+


Allocate a Floating IP
======================

In order to connect to the instance, first allocate a Floating IP.
Use the ID of "public-net" (obtained previously with ``openstack network
list``) to request a new Floating IP.

.. code-block:: bash

 $ openstack floating ip create $CC_PUBLIC_NETWORK_ID
 +---------------------+--------------------------------------+
 | Field               | Value                                |
 +---------------------+--------------------------------------+
 | fixed_ip_address    | None                                 |
 | floating_ip_address | <PUBLIC_IP>                          |
 | floating_network_id | <PUBLIC_NETWORK_ID>                  |
 | headers             |                                      |
 | id                  | <FLOATING_IP_ID>                     |
 | port_id             | None                                 |
 | project_id          | <PROJECT_ID>                         |
 | router_id           | None                                 |
 | status              | DOWN                                 |
 +---------------------+--------------------------------------+

.. note::

 This step can be skipped if Floating IPs already exist.
 Check this by issuing the command: ``openstack floating ip list``.

.. code-block:: bash

 $ export CC_FLOATING_IP_ID=$( openstack floating ip list -f value | grep -m 1 'None None' | awk '{ print $1 }' )
 $ export CC_PUBLIC_IP=$( openstack floating ip show $CC_FLOATING_IP_ID -f value -c floating_ip_address )

Associate this Floating IP with the instance:

.. code-block:: bash

 $ openstack server add floating ip first-instance $CC_PUBLIC_IP


Connect to the new Instance
===========================

Connecting to the Instance should be as easy as:

.. code-block:: bash

 $ ssh ubuntu@$CC_PUBLIC_IP


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
