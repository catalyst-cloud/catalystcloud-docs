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

Now lets set our :ref:`DNS Name Servers <name_servers>` and create a subnet
of the network we have just created:

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

 $ neutron security-group-create --description 'Network access for our first instance.' first-instance-sg
 Created a new security_group:
 +----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | Field                | Value                                                                                                                                                                                                                                                                                                                         |
 +----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | description          | network access for our first instance.                                                                                                                                                                                                                                                                                        |
 | id                   | f0c68b05-edcf-48f6-bfc8-b5537ab255fe                                                                                                                                                                                                                                                                                          |
 | name                 | first-instance-sg                                                                                                                                                                                                                                                                                                             |
 | security_group_rules | {"remote_group_id": null, "direction": "egress", "remote_ip_prefix": null, "protocol": null, "tenant_id": "0cb6b9b744594a619b0b7340f424858b", "port_range_max": null, "security_group_id": "f0c68b05-edcf-48f6-bfc8-b5537ab255fe", "port_range_min": null, "ethertype": "IPv4", "id": "a93fff5c-9cd6-40d4-9dd5-6cc6eba1b134"} |
 |                      | {"remote_group_id": null, "direction": "egress", "remote_ip_prefix": null, "protocol": null, "tenant_id": "0cb6b9b744594a619b0b7340f424858b", "port_range_max": null, "security_group_id": "f0c68b05-edcf-48f6-bfc8-b5537ab255fe", "port_range_min": null, "ethertype": "IPv6", "id": "fe2a202a-6bc1-4064-8499-88401196899b"} |
 | tenant_id            | 0cb6b9b744594a619b0b7340f424858b                                                                                                                                                                                                                                                                                              |
 +----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

We can now create a rule within our group. You can issue the ``neutron
security-group-list`` command to find the ``SECURITY_GROUP_ID``. We will export
an environment variable with the security group id for later use.

.. code-block:: bash

 $ neutron security-group-list
 +--------------------------------------+-------------------+----------------------------------------+
 | id                                   | name              | description                            |
 +--------------------------------------+-------------------+----------------------------------------+
 | 687512ab-f197-4f07-ae51-788c559883b9 | default           | default                                |
 | f0c68b05-edcf-48f6-bfc8-b5537ab255fe | first-instance-sg | network access for our first instance. |
 +--------------------------------------+-------------------+----------------------------------------+
 $ export CC_SECURITY_GROUP_ID=$(neutron security-group-list | grep first-instance-sg | awk '{ print $2 }' )

Next we will set an environment variable with our local external IP address:

.. code-block:: bash

 $ export CC_REMOTE_CIDR_NETWORK="$( dig +short myip.opendns.com @resolver1.opendns.com )/32"
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

 $ nova boot --flavor $CC_FLAVOR_ID --image $CC_IMAGE_ID --key-name first-instance-key --security-groups default,first-instance-sg --nic net-id=$CC_PRIVATE_NETWORK_ID first-instance

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
 | security_groups                      | default, first-instance-sg                                 |
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
