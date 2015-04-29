#########
Tutorials
#########


*****************************
Launching your first instance
*****************************

This tutorial assumes you have installed the OpenStack command line tools and
sourced an openrc file, as explained on :ref:`command-line-tools`.

Network Requirements
====================

Before spawning an instance, it is necessary to have some network resources in
place. These may have already been created for you.

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

Creating Required Network Elements
==================================

If a router and network/subnet don't already exist, create them. Keep any
network requirements in mind when choosing addressing for your networks,
in case you want to build a tunnel-mode VPN in the future. ::

 $ neutron router-create border-router
 Created a new router:
 +-----------------------+--------------------------------------+
 | Field                 | Value                                |
 +-----------------------+--------------------------------------+
 | admin_state_up        | True                                 |
 | external_gateway_info |                                      |
 | id                    | ROUTER_ID                            |
 | name                  | border-router                        |
 | status                | ACTIVE                               |
 | tenant_id             | TENANT_ID                            |
 +-----------------------+--------------------------------------+

 $ neutron router-gateway-set border-router public-net
 Set gateway for router border-router

 $ neutron net-create  10.0.0.0/24
 Created a new network:
 +----------------+--------------------------------------+
 | Field          | Value                                |
 +----------------+--------------------------------------+
 | admin_state_up | True                                 |
 | id             | NETWORK_ID                           |
 | name           | 10.0.0.0/24                          |
 | shared         | False                                |
 | status         | ACTIVE                               |
 | subnets        |                                      |
 | tenant_id      | TENANT_ID                            |
 +----------------+--------------------------------------+

 $  neutron subnet-create --name 10.0.0.0/24 --allocation-pool \
     start=10.0.0.10,end=10.0.0.200 --dns-nameserver NAMESERVER_1 \
     --dns-nameserver NAMESERVER_2 --dns-nameserver NAMESERVER_3 \
     --enable-dhcp 10.0.0.0/24 10.0.0.0/24
 Created a new subnet:
 +------------------+---------------------------------------------+
 | Field            | Value                                       |
 +------------------+---------------------------------------------+
 | allocation_pools | {"start": "10.0.0.10", "end": "10.0.0.200"} |
 | cidr             | 10.0.0.0/24                                 |
 | dns_nameservers  | NAMESERVER_1                                |
 |                  | NAMESERVER_2                                |
 |                  | NAMESERVER_3                                |
 | enable_dhcp      | True                                        |
 | gateway_ip       | 10.0.0.1                                    |
 | host_routes      |                                             |
 | id               | SUBNET_ID                                   |
 | ip_version       | 4                                           |
 | name             | 10.0.0.0/24                                 |
 | network_id       | NETWORK_ID                                  |
 | tenant_id        | TENANT_ID                                   |
 +------------------+---------------------------------------------+

 $ neutron router-interface-add border-router 10.0.0.0/24
 Added interface INTERFACE_ID to router border-router.

Choosing a Flavor
=================

The flavor of an instance is the disk, cpu, and memory specifications of an
instance.  Use 'nova flavor-list' to get a list.  Catalyst flavors are named
'cX.cY.cZ', where X is the 'compute generation', Y is the number of vCPUs,
and Z is the number of gigabytes of memory. ::

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

Let's make a small c1.c1r1 instance. (id: 3931e022-24e7-4678-bc3f-ee86ec129819)
Note: These IDs will be different in each region.

Choosing an Image
=================

In order to create an instance, you will need to have a pre-built Operating
System in the form of an Image.  Images are stored in the Glance service.
Catalyst provide a set of images for general use.  If none of those are
sufficient, custom images can be uploaded to Glance by anyone. Here is an
example of how to locate a suitable image.

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

Let's use the ubuntu image for to create this instance.
(id: 0368593a-60ef-48a3-885a-add8dfefe569)  Note: These IDs will be different
in each region. Further, images are periodically updated.  The ID of an Ubuntu
image will change over time.

Uploading an SSH key
====================

When an instance is created, OpenStack pass an ssh key to the instance
which can be used for shell access.  By default, Ubuntu will install
this key for the 'ubuntu' user.  Other operating systems behave differently.
Use 'nova keypair-add' to upload your Public SSH key.  Tip: name you key
using information like the username and host on which the ssh key was
generated so that it is easy to identify later. ::

 $ nova keypair-add --pub-key ~/.ssh/id_rsa.pub username-hostname
 $ nova keypair-list
 +-------------------+-------------------------------------------------+
 | Name              | Fingerprint                                     |
 +-------------------+-------------------------------------------------+
 | username-hostname | 8c:fb:ca:fd:1e:a8:90:8b:a4:a7:fb:17:7c:cc:3c:5c |
 +-------------------+-------------------------------------------------+

Note: These keypairs must be created in each region being used.

Choosing a Network
==================

Use Neutron to locate the correct network to use. ::

 $ neutron net-list
 +--------------------------------------+------------+--------------------------+
 | id                                   | name       | subnets                  |
 +--------------------------------------+------------+--------------------------+
 | PUBLIC_NETWORK_ID                    | public-net | PUBLIC_SUBNET_ID         |
 | MY_NETWORK_ID                        | mynetwork  | MY_SUBNET_ID 10.0.0.0/24 |
 +--------------------------------------+------------+--------------------------+

The 'public-net' is used by routers to access the Internet.  Instances
may not be booted on this network.  Let's use mynetwork to boot our instance.
(id: MY_NETWORK_ID) Note: These IDs will be different in each region.

Booting an Instance
===================

Use the 'nova boot' command and supply the information we gathered in previous
steps, being sure to replace FLAVOR, IMAGE, KEY_NAME, MY_NETWORK_ID, and
INSTANCE_NAME with appropriate values.  ::

 nova boot --flavor FLAVOR --image IMAGE --key-name KEY_NAME --nic net-id=MY_NETWORK_ID INSTANCE_NAME

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
 | adminPass                            | ADMIN_PASS                                                 |
 | config_drive                         |                                                            |
 | created                              | 2015-01-14T21:16:28Z                                       |
 | flavor                               | c1.c1r1 (FLAVOR_ID)                                        |
 | hostId                               |                                                            |
 | id                                   | INSTANCE_ID                                                |
 | image                                | ubuntu-14.04-x86_64 (IMAGE_ID)                             |
 | key_name                             | username-hostname                                          |
 | metadata                             | {}                                                         |
 | name                                 | INSTANCE_NAME                                              |
 | os-extended-volumes:volumes_attached | []                                                         |
 | progress                             | 0                                                          |
 | security_groups                      | default                                                    |
 | status                               | BUILD                                                      |
 | tenant_id                            | TENANT_ID                                                  |
 | updated                              | 2015-01-14T21:16:28Z                                       |
 | user_id                              | USER_ID                                                    |
 +--------------------------------------+------------------------------------------------------------+

Note that the status is 'BUILD.'  Catalyst Cloud instances build very
quickly, but it still takes a few seconds.  Wait a few seconds and ask for
the status of this instance using the ID or name(if unique) of this instance.::

 $ nova show INSTANCE_ID
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
 | flavor                               | c1.c1r1 (FLAVOR_ID)                                        |
 | hostId                               | HOSTID                                                     |
 | id                                   | INSTANCE_ID                                                |
 | image                                | ubuntu-14.04-x86_64 (IMAGE_ID)                             |
 | key_name                             | username-key                                               |
 | metadata                             | {}                                                         |
 | name                                 | INSTANCE_NAME                                              |
 | os-extended-volumes:volumes_attached | []                                                         |
 | progress                             | 0                                                          |
 | security_groups                      | default                                                    |
 | status                               | ACTIVE                                                     |
 | tenant_id                            | TENANT_ID                                                  |
 | testing network                      | 10.0.0.6                                                   |
 | updated                              | 2015-01-14T21:16:49Z                                       |
 | user_id                              | USER_ID                                                    |
 +--------------------------------------+------------------------------------------------------------+

Allocate a Floating IP
======================

In order to connect to our instance, we will need to allocate a floating IP
to the instance.  Alternately, one could create a VPN and save some money by
avoiding floating IPs altogether.  VPNs are not feasible when the instance
will be offering a service to the greater internet.  Use the id of
public-net (found via 'neutron net-list') and request a new floating IP. ::

 $ neutron floatingip-create PUBLIC_NETWORK_ID
 Created a new floatingip:
 +---------------------+----------------------------+
 | Field               | Value                      |
 +---------------------+----------------------------+
 | fixed_ip_address    |                            |
 | floating_ip_address | PUBLIC_IP                  |
 | floating_network_id | PUBLIC_NETWORK_ID          |
 | id                  | FLOATING_IP_ID             |
 | port_id             |                            |
 | router_id           |                            |
 | status              | DOWN                       |
 | tenant_id           | TENANT_ID                  |
 +---------------------+----------------------------+

Now, get the port id of the instance's interface and associate the floating ip
with it. ::

 $ nova interface-list INSTANCE_NAME
 +------------+-------------+-----------------+--------------+-------------------+
 | Port State | Port ID     | Net ID          | IP addresses | MAC Addr          |
 +------------+-------------+-----------------+--------------+-------------------+
 | ACTIVE     | PORT_ID     | MY_NETWORK_ID   | 10.0.0.6     | fa:16:3e:0c:89:14 |
 +------------+-------------+-----------------+--------------+-------------------+

 $ neutron floatingip-associate FLOATING_IP_ID PORT_ID
 Associated floating IP FLOATING_IP_ID

Configure Instance Security Groups
==================================

At this point, the instance is on the Internet, with a routable IP address of
PUBLIC_IP.  By default, instances are put in the 'default' security group.
By default, this security group will drop all inbound traffic.  A security
group rule is required if inbound access is desired. ::

 $ neutron security-group-list
 +--------------------+-------------+--------------+
 | id                 | name        | description  |
 +--------------------+-------------+--------------+
 | SECURITY_GROUP_ID  | default     | default      |
 +--------------------+-------------+--------------+
 $ neutron security-group-rule-create --direction ingress \
        --protocol tcp --port-range-min 22 --port-range-max 22 \
        --remote-ip-prefix YOUR_CIDR_NETWORK SECURITY_GROUP_ID

If you are unsure of what YOUR_CIDR_NETWORK should be, ask your network admin,
or visit http://ifconfig.me and get your IP address.  Use "IP_ADDRESS/32" as
YOUR_CIDR_NETWORK to allow traffic only from your current effective IP.

Connect to the new Instance
===========================

This should be as easy as: ::

 ssh ubuntu@PUBLIC_IP


****************************************
Downloading compute instance's volume(s)
****************************************

Volumes can be copied from the block storage service to the image service and
downloaded using the glance client.

This tutorial assumes you have installed the OpenStack command line tools and
sourced an openrc file, as explained on :ref:`command-line-tools`.

Identifying the volume(s)
=========================

The ``cinder list`` command can be used to list all volumes available.

The ``nova show`` command can be used to identity the volumes that are attached
to a given compute instance:

.. code-block:: bash

  nova show <instance-name-or-id> | grep "volumes_attached"

Uploading the volume
====================

The procedure the upload a volume will vary depending on whether the volume is
attached to an instance (active) or not.

Uploading a detached (inactive) volume
--------------------------------------

A detached volume can be uploaded to the image service using the following
command:

.. code-block:: bash

  cinder upload-to-image <volume-name-or-id> <image-name>

Uploading an attached (active) volume
-------------------------------------

To upload an active volume (a volume that is currently attached to a compute
instance and in use), you must first take a snapshot of the volume using the
``cinder volume-snapshot`` command and then create a new (inactive) volume from
it using the ``cinder volume-create`` command.

To take a snapshot of an active volume:

.. code-block:: bash

  cinder snapshot-create <volume-name-or-id> --display-name <snapshot-name> --force True

To show a list of all snapshots:

.. code-block:: bash

  cinder snapshot-list

The command below can be used to create a new volume based on a snapshot.
Please note that the volume size should match the snapshot size.

.. code-block:: bash

  cinder create --snapshot-id <snapshot-id> --display-name <new-volume-name> <size>

A detached volume can be uploaded to the image service using the command below:

.. code-block:: bash

  cinder upload-to-image <volume-name-or-id> <image-name>

Downloading the image
=====================

Copying a volume from the block storage service to the image service can take
some time (depends on volume size). First, you should confirm that the upload
has finished (status shown as active), using the command below:

.. code-block:: bash

  glance image-show <image-name-or-id>

If the status of the image is active, you can download the image using the
following command:

.. code-block:: bash

  glance image-download <image-name-or-id> --file <file-name> --progress

The downloaded file is the raw image (a bare container) that can be uploaded
back to other cloud regions, other clouds or imported into a hypervisor for
local use.
