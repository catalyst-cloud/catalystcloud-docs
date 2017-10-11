###############
Network service
###############

The network service allows you to create your own private networks, subnets,
routers, security groups and site-to-site VPNs.


***************
Public networks
***************

Catalyst operates a public network in each region. These public networks
provide you with connectivity to the Internet and allow you to allocate
floating IPs (public IPs that can be associated to your compute instances) from
a pool managed by Catalyst.

Our public networks are listed on the table below:

+----------+--------------------------------------+
|  Region  | ID                                   |
+==========+======================================+
| nz-por-1 | 849ab1e9-7ac5-4618-8801-e6176fbbcf30 |
+----------+--------------------------------------+
| nz_wlg_2 | e0ba6b88-5360-492c-9c3d-119948356fd3 |
+----------+--------------------------------------+
| nz-hlz-1 | f10ad6de-a26d-4c29-8c64-2a7418d47f8f |
+----------+--------------------------------------+

***********
DNS servers
***********

Catalyst operates a number of recursive DNS servers in each cloud region for
use by Catalyst Cloud instances, free of charge. They are:

+----------+------------------------------------------------+
|  Region  | DNS Servers                                    |
+==========+================================================+
| nz-por-1 | 202.78.247.197, 202.78.247.198, 202.78.247.199 |
+----------+------------------------------------------------+
| nz_wlg_2 | 202.78.240.213, 202.78.240.214, 202.78.240.215 |
+----------+------------------------------------------------+
| nz-hlz-1 | 202.78.244.85, 202.78.244.86, 202.78.244.87    |
+----------+------------------------------------------------+

****************
Adding a network
****************

By default all new Catalyst Cloud projects in the Porirua region (nz-por-1)
are created with a router and network. If you have removed this, or simply
wish to create additional networks, then the following guide will show you
the steps required to achieve this.

.. _creating_networks:

Creating the required network elements
======================================

We need to create a router and network/subnet.

Navigate to the "Routers" section and click "Create Router":

.. image:: _static/fi-router-create.png
   :align: center

|

Name the router "border-router", select admin state "UP" and select
"public-net" as the external network:

.. image:: _static/fi-router-name.png
   :align: center

|

Navigate to the "Networks" section and click "Create Network":

.. image:: _static/fi-network-create.png
   :align: center

|

Name your network "private-net", select create subnet and click "Next":

.. image:: _static/fi-network-create-name.png
   :align: center

|

Name your subnet "private-subnet", choose an address for your subnet in CIDR
notation and click "Next":

.. image:: _static/fi-network-address.png
   :align: center

|

The Subnet Details page is normally, by default, empty. This example sets
additional attributes for the subnet including:

- enabling DHCP
- defining a DHCP ip address allocation pool
- specifying the :ref:`DNS Name Servers <name_servers>` for the required region

.. image:: _static/fi-network-detail.png
   :align: center

|

Click on the router name in the router list:

.. image:: _static/fi-router-detail.png
   :align: center

|

Select the "Interfaces" tab and click "+Add Interface":

.. image:: _static/fi-router-interface-add.png
   :align: center

|

Select the correct subnet:

.. image:: _static/fi-router-interface-subnet.png
   :align: center

|

You should now have a network topology that looks like this:

.. image:: _static/fi-network-topology.png
   :align: center


.. _deleting_networks:

******************
Deleting a network
******************

There are some dependencies that exist between the various infrastructure
elements that get created in the cloud. While this is necessary in order to
have things work correctly, it does cause the occasional problem when trying to
delete unwanted items.

Deleting an entire network
==========================

One area where this crops up from time to time is while removing network elements,
so here is the recommended process for deleting an entire network and
associated parts.

- first ensure that there are no instances connected to the network in question
- remove the interface from the router
- delete the router
- delete the network

If you had security groups that were only required by the network just deleted
you could also remove these at this stage.

Deleting specific network elements
==================================

If you are looking to only remove certain elements, then you would have to
ensure that all dependencies on that network are removed first. In some
cases, these dependencies might be nested, meaning that the obvious
dependency may also have less obvious dependencies.

An example - finding the dependency problem
===========================================

One example of this would be trying to remove a network that is connected
to a router but also still in use by a VPN. If you try and remove the router
interface through the dashboard, you would get a non-specific error indicating
that removing the interface failed.

At this point it may be quite challenging to determine what the exact cause
of the error is. The best way to diagnose the problem is to use the OpenStack
command line tools.

To start, get the IDs of your router, subnet and router port.

.. code-block:: bash

  $ openstack router list -c ID -c Name
  +--------------------------------------+---------------+
  | ID                                   | Name          |
  +--------------------------------------+---------------+
  | 6be77df7-fa23-4eaa-8542-a0620fba68f8 | border-router |
  +--------------------------------------+---------------+

  $ openstack network list
  +--------------------------------------+-------------+--------------------------------------+
  | ID                                   | Name        | Subnets                              |
  +--------------------------------------+-------------+--------------------------------------+
  | e0ba6b88-5360-492c-9c3d-119948356fd3 | public-net  | 8b88f8c7-0a5c-483b-9e55-f9a8c2ca93b4 |
  | 6fe1b0b8-37ba-4e79-84ff-7799b6ccd7b3 | private-net | c5145b18-26f1-4053-bac4-d8d0bdc77b48 |
  +--------------------------------------+-------------+--------------------------------------+

  openstack port list --router border-router -c ID
  +--------------------------------------+
  | ID                                   |
  +--------------------------------------+
  | 44f6d507-2969-4e8f-b03c-e7361d13109d |
  +--------------------------------------+

Now try to delete the port from the router.

.. code-block:: bash

  $ openstack port delete 44f6d507-2969-4e8f-b03c-e7361d13109d
  Failed to delete port with name or ID '44f6d507-2969-4e8f-b03c-e7361d13109d':
  HttpException: Conflict (HTTP 409) (Request-ID: req-9b31b77a-36a7-4025-8e53-59b94aef2b26),
  Port 44f6d507-2969-4e8f-b03c-e7361d13109d cannot be deleted directly via the port
  API: has device owner network:router_interface
  1 of 1 ports failed to delete.

OK, so while that wasn't successful, at least you got a bit more information
telling you that there is some kind of dependency associated with
the router interface.

This time, try to remove the subnet from the router, as that would
remove the interface.

.. code-block:: bash

  $ openstack router remove subnet 6be77df7-fa23-4eaa-8542-a0620fba68f8  c5145b18-26f1-4053-bac4-d8d0bdc77b48
  HttpException: Conflict (HTTP 409) (Request-ID: req-a0821a75-e616-4e9a-a1a3-0f64574e07dc),
  Subnet c5145b18-26f1-4053-bac4-d8d0bdc77b48 is used by VPNService 478073d3-a347-4d1a-8653-609788064147

Success: now you can see what the problem is. It appears that your subnet is
associated with a VPN. If you were to go ahead and remove the VPN, you would
be able to delete the network as you initially set out to do.


.. _security-groups:

***************
Security groups
***************

A security group is a virtual firewall that controls network traffic to and
from compute instances. Your project comes with a default security group, which
cannot be deleted, and you can create additional security groups.

Security groups are made of security rules. You can add or modify security
rules at any time. When you modify a security group, the new rules are
automatically applied to all compute instances associated with it.

You can associate one or more security groups with your compute instances.

.. note::

  While it is possible to assign many security groups to a compute instance, we
  recommend you consolidate your security groups and rules as much as
  possible.

Creating a security group
=========================

The default behaviour of security groups is to deny all traffic. Rules added to
security groups are all "allow" rules.

.. note::

  Failing to set up the appropriate security group rules is a common mistake
  that prevents users from reaching their compute instances, or compute
  instances from communicating with each other.


************************
Virtual Private Networks
************************

VPN as a Service is an OpenStack Networking (Neutron) extension that provides
VPN services for your project. Currently this service is restricted to IPsec
based VPNs.

Requirements
============

In order to setup a VPN, you need to know a number of parameters:

* Project (previously Tenant) ID
* Router ID
* Router IP Address
* Subnet ID
* Subnet CIDR Range
* Remote Peer Router IP
* Remote Peer Subnet CIDR Range
* A Secret Pre Shared Key

.. note::
 IPSec relies on symmetrical encryption where both sides use the same private
 key. This key is known as a Pre Shared Key (PSK). You should ensure that you
 manage this key appropriately, so for example be sure that it is not commited
 to your configuration management system source control in plain text.

VPN Setup from the Command Line
===============================

In order to find these parameters you first need to know the name of the router
you wish to use and a subnet connected to that router.

You can use the following commands to find these:

.. code-block:: bash

 $ openstack router list
 $ openstack subnet list

To find the Project ID, Router ID and Router IP Address, you can issue the
following command using the name of the router you found previously:

.. code-block:: bash

 $ openstack router show example-router
 +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | Field                 | Value                                                                                                                                                                                      |
 +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | admin_state_up        | True                                                                                                                                                                                       |
 | external_gateway_info | {"network_id": "849ab1e9-7ac5-4618-8801-e6176fbbcf30", "enable_snat": true, "external_fixed_ips": [{"subnet_id": "aef23c7c-6c53-4157-8350-d6879c43346c", "ip_address": "150.242.41.212"}]} |
 | id                    | 1e715c96-e92a-487a-a0e9-7877ed357194                                                                                                                                                       |
 | name                  | example-router                                                                                                                                                                             |
 | routes                |                                                                                                                                                                                            |
 | status                | ACTIVE                                                                                                                                                                                     |
 | tenant_id             | 0cb6b9b744594a619b0b7340f424858b                                                                                                                                                           |
 +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

The Router IP Address is the value associated with the "ip_address" key within
the external_gateway_info JSON data.

To find the Subnet ID and Subnet CIDR Range, issue the following command using
the subnet name you found previously:

.. code-block:: bash

 $ openstack subnet show example-subnet
 +-------------------+-----------------------------------------------+
 | Field             | Value                                         |
 +-------------------+-----------------------------------------------+
 | allocation_pools  | {"start": "10.0.20.10", "end": "10.0.20.200"} |
 | cidr              | 10.0.20.0/24                                  |
 | dns_nameservers   | 202.78.247.197                                |
 |                   | 202.78.247.198                                |
 |                   | 202.78.247.199                                |
 | enable_dhcp       | True                                          |
 | gateway_ip        | 10.0.20.1                                     |
 | host_routes       |                                               |
 | id                | 46fb98d1-d9d2-458f-8245-28b3dcf574b7          |
 | ip_version        | 4                                             |
 | ipv6_address_mode |                                               |
 | ipv6_ra_mode      |                                               |
 | name              | example-subnet                                |
 | network_id        | 3599a1dc-e712-4b4c-9208-76566b76a118          |
 | project_id        | 3d5d40b4a6904e6db4dc5321f53d4f39              |
 | subnetpool_id     | None                                          |
 +-------------------+-----------------------------------------------+

If you are creating a VPN that connects your projects between Catalyst Cloud
Regions, then the Remote Peer Router IP and Remote Peer Subnet CIDR Range will
be the values associated with the subnet and router in the other region. You
can determine these in the same way as shown above while connected to the other
region. If you are setting up a VPN to a different peer, then the Peer Router IP
will be the publicly accessible IPv4 address of that router, while the Remote
Peer Subnet CIDR Range will be the subnet behind that router whose traffic you
wish to route via the VPN to access the local subnet.

.. note::
 If you are connecting to a remote peer that is not a Catalyst Cloud router,
 you may need to modify some of the parameters used in the following steps.

By now you should have the required values so you can proceed to create a VPN.
There are four steps to creating a VPN:

* Create a VPN Service
* Create a VPN IKE Policy
* Create a VPN IPSec Policy
* Create a VPN IPSec Site Connection

Firstly create a VPN Service:

.. code-block:: bash

 $ neutron vpn-service-create --name "VPN" \
   --tenant-id TENANT_ID ROUTER_ID SUBNET_ID
 Created a new vpnservice:
 +----------------+--------------------------------------+
 | Field          | Value                                |
 +----------------+--------------------------------------+
 | admin_state_up | True                                 |
 | description    |                                      |
 | id             | b29a384f-d6a5-475d-ba39-8391f0989af2 |
 | name           | VPN                                  |
 | router_id      | 457525c5-4d94-4b62-b956-3883f7004992 |
 | status         | PENDING_CREATE                       |
 | subnet_id      | f068ece6-57a4-442c-bbee-533c3bc33fdb |
 | tenant_id      | e5bab53f56c14767bc44d2868ff317ae     |
 +----------------+--------------------------------------+

Then create a VPN IKE Policy:

.. code-block:: bash

 $ neutron vpn-ikepolicy-create --tenant-id TENANT_ID \
   --auth-algorithm sha1 --encryption-algorithm aes-256 --phase1-negotiation-mode main \
   --ike-version v1 --pfs group14 --lifetime units=seconds,value=14400 "IKE Policy"

   Created a new ikepolicy:
   +-------------------------+--------------------------------------+
   | Field                   | Value                                |
   +-------------------------+--------------------------------------+
   | auth_algorithm          | sha1                                 |
   | description             |                                      |
   | encryption_algorithm    | aes-256                              |
   | id                      | d68a5e62-b643-4ea3-8b2c-b83824c0e61e |
   | ike_version             | v1                                   |
   | lifetime                | {"units": "seconds", "value": 14400} |
   | name                    | IKE Policy                           |
   | pfs                     | group14                              |
   | phase1_negotiation_mode | main                                 |
   | tenant_id               | e5bab53f56c14767bc44d2868ff317ae     |
   +-------------------------+--------------------------------------+

Then create a VPN IPSec Policy:

.. code-block:: bash

 $ neutron vpn-ipsecpolicy-create --tenant-id TENANT_ID --transform-protocol esp \
   --auth-algorithm sha1 --encryption-algorithm aes-256 --encapsulation-mode tunnel --pfs group14 \
   --lifetime units=seconds,value=3600 "IPsec Policy"

   created a new ipsecpolicy:
   +----------------------+--------------------------------------+
   | Field                | Value                                |
   +----------------------+--------------------------------------+
   | auth_algorithm       | sha1                                 |
   | description          |                                      |
   | encapsulation_mode   | tunnel                               |
   | encryption_algorithm | aes-256                              |
   | id                   | c3f5bc60-0959-4c4f-ba1d-2a15e68de62f |
   | lifetime             | {"units": "seconds", "value": 3600}  |
   | name                 | IPsec Policy                         |
   | pfs                  | group14                              |
   | tenant_id            | e5bab53f56c14767bc44d2868ff317ae     |
   | transform_protocol   | esp                                  |
   +----------------------+--------------------------------------+

Lastly create a VPN IPSec Site Connection. This command makes use of the
resources created in the last three steps. You will need to take note of these
IDs to use within this command.

.. code-block:: bash

 $ neutron ipsec-site-connection-create --tenant-id TENANT_ID --name  "VPN" \
   --initiator bi-directional --vpnservice-id b29a384f-d6a5-475d-ba39-8391f0989af2 \
   --ikepolicy-id d68a5e62-b643-4ea3-8b2c-b83824c0e61e \
   --ipsecpolicy-id c3f5bc60-0959-4c4f-ba1d-2a15e68de62f \
   --dpd action=restart,interval=15,timeout=150
   --peer-address REMOTE_IP \
   --peer-id REMOTE_IP --peer-cidr 192.168.0.0/24 \
   --psk supersecretpsk

   created a new ipsec_site_connection:
   +----------------+------------------------------------------------------------------+
   | Field          | Value                                                            |
   +----------------+------------------------------------------------------------------+
   | admin_state_up | True                                                             |
   | auth_mode      | psk                                                              |
   | description    |                                                                  |
   | dpd            | {"action": "restart", "interval": 15, "timeout": 150}            |
   | id             | aafb6249-0750-4f62-a3e7-2b5e3c6b33c1                             |
   | ikepolicy_id   | d68a5e62-b643-4ea3-8b2c-b83824c0e61e                             |
   | initiator      | bi-directional                                                   |
   | ipsecpolicy_id | c3f5bc60-0959-4c4f-ba1d-2a15e68de62f                             |
   | mtu            | 1500                                                             |
   | name           | VPN                                                              |
   | peer_address   | REMOTE_PEER_IP                                                   |
   | peer_cidrs     | 192.168.0.0/24                                                   |
   | peer_id        | REMOTE_PEER_IP                                                   |
   | psk            | supersecretpsk                                                   |
   | route_mode     | static                                                           |
   | status         | PENDING_CREATE                                                   |
   | tenant_id      | e5bab53f56c14767bc44d2868ff317ae                                 |
   | vpnservice_id  | d61b180f-41cf-4fbe-94e9-bdfa0330d6eb                             |
   +----------------+------------------------------------------------------------------+

.. note::
 You can provide multiple ``--peer-cidr`` arguments if you want to tunnel more
 than one CIDR range.

You have now stood up one end of the VPN. This process should be repeated at
the other end using the same configuration options and PSK. Once both sides of
the VPN are configured, the peers should automatically detect each other and
bring up the VPN. When the VPN is up, the status will change to ``ACTIVE``.

VPN Setup using a bash script
=============================

The Catalyst Cloud team have created a bash script that simplifies the
procedure for creating a VPN. In the case of a region to region VPN, all you
need to know is the router and subnet names for each region. When one peer is
not a Catalyst Cloud router, you will need to know the peer router IP address
and the remote peer CIDR range.

This script will require no modification when setting up region to region VPNs.
If you are using it to connect a Catalyst Cloud router to a non Catalyst Cloud
router, you may need to change some configuration options.

This script currently only supports single CIDR ranges. If you are wanting to
tunnel multiple ranges then it will require some modification.

.. note::
 This script makes used of the `jq`_ command line utility for parsing JSON.
 You will need to install it before using the script.

 .. _jq: https://stedolan.github.io/jq/

You can download the latest version of this script using the following command:

.. code-block:: bash

 $ wget https://raw.githubusercontent.com/catalyst/catalystcloud-docs/master/scripts/create-vpn.sh

Below is an example of the script being used to create a region to region VPN
on the Catalyst Cloud:

.. code-block:: bash

 $ ./create-vpn.sh
 ---------------------------------------------
 This script will set up a VPN in your project.
 You can select either one or both regions.
 If you select both regions this script will
 set up a site to site VPN for you.
 ---------------------------------------------
 Please select the region(s):

 1) Wellington
 2) Porirua
 3) Both
 Selection: 3

 Please enter the name of your Wellington router:
 wlg-router
 Please enter the name of your Wellington subnet:
 wlg-subnet
 Please enter the name of your Porirua router:
 por-router
 Please enter the name of your Porirua subnet:
 por-subnet
 Please enter your pre shared key
 supersecretpsk
 --------------------------------------------------------
 Proceeding to create VPN with the following credentials:
 por_router_id = 1e715c96-e92a-487a-a0e9-7877ed357194
 por_subnet_id = 46fb98d1-d9d2-458f-8245-28b3dcf574b7
 por_router_ip = 150.242.41.212
 por_subnet = 10.0.20.0/24
 por_peer_router_ip = 103.254.157.166
 por_peer_subnet = 10.0.21.0/24
 wlg_router_id = 6c4cf781-8396-4731-8728-df2d860f6fbd
 wlg_subnet_id = d7beddd6-c182-4e0a-a37c-019d8ee7077e
 wlg_router_ip = 103.254.157.166
 wlg_subnet = 10.0.21.0/24
 wlg_peer_router_ip = 150.242.41.212
 wlg_peer_subnet = 10.0.20.0/24
 tenant_id = 0cb6b9b744594a619b0b7340f424858b
 pre_shared_key = XXXXXXXXXXXXXXXXXXX
 --------------------------------------------------------
 Created a new vpnservice:
 +----------------+--------------------------------------+
 | Field          | Value                                |
 +----------------+--------------------------------------+
 | admin_state_up | True                                 |
 | description    |                                      |
 | id             | 22f365e2-9826-47c1-922c-5b7670266f8d |
 | name           | VPN                                  |
 | router_id      | 1e715c96-e92a-487a-a0e9-7877ed357194 |
 | status         | PENDING_CREATE                       |
 | subnet_id      | 46fb98d1-d9d2-458f-8245-28b3dcf574b7 |
 | tenant_id      | 0cb6b9b744594a619b0b7340f424858b     |
 +----------------+--------------------------------------+
 Created a new ikepolicy:
 +-------------------------+--------------------------------------+
 | Field                   | Value                                |
 +-------------------------+--------------------------------------+
 | auth_algorithm          | sha1                                 |
 | description             |                                      |
 | encryption_algorithm    | aes-256                              |
 | id                      | 30092274-b87a-4dfe-b83d-c4fa09b938a0 |
 | ike_version             | v1                                   |
 | lifetime                | {"units": "seconds", "value": 14400} |
 | name                    | IKE Policy                           |
 | pfs                     | group14                              |
 | phase1_negotiation_mode | main                                 |
 | tenant_id               | 0cb6b9b744594a619b0b7340f424858b     |
 +-------------------------+--------------------------------------+
 Created a new ipsecpolicy:
 +----------------------+--------------------------------------+
 | Field                | Value                                |
 +----------------------+--------------------------------------+
 | auth_algorithm       | sha1                                 |
 | description          |                                      |
 | encapsulation_mode   | tunnel                               |
 | encryption_algorithm | aes-256                              |
 | id                   | 316b5ef1-8b7f-45fd-893c-85610dbbdfe7 |
 | lifetime             | {"units": "seconds", "value": 3600}  |
 | name                 | IPsec Policy                         |
 | pfs                  | group14                              |
 | tenant_id            | 0cb6b9b744594a619b0b7340f424858b     |
 | transform_protocol   | esp                                  |
 +----------------------+--------------------------------------+
 Created a new ipsec_site_connection:
 +----------------+-------------------------------------------------------+
 | Field          | Value                                                 |
 +----------------+-------------------------------------------------------+
 | admin_state_up | True                                                  |
 | auth_mode      | psk                                                   |
 | description    |                                                       |
 | dpd            | {"action": "restart", "interval": 15, "timeout": 150} |
 | id             | ea331e3b-2a41-4c93-8634-c0238d639d5d                  |
 | ikepolicy_id   | 30092274-b87a-4dfe-b83d-c4fa09b938a0                  |
 | initiator      | bi-directional                                        |
 | ipsecpolicy_id | 316b5ef1-8b7f-45fd-893c-85610dbbdfe7                  |
 | mtu            | 1500                                                  |
 | name           | VPN                                                   |
 | peer_address   | 103.254.157.166                                       |
 | peer_cidrs     | 10.0.21.0/24                                          |
 | peer_id        | 103.254.157.166                                       |
 | psk            | supersecretpsk                                        |
 | route_mode     | static                                                |
 | status         | PENDING_CREATE                                        |
 | tenant_id      | 0cb6b9b744594a619b0b7340f424858b                      |
 | vpnservice_id  | 22f365e2-9826-47c1-922c-5b7670266f8d                  |
 +----------------+-------------------------------------------------------+
 Created a new vpnservice:
 +----------------+--------------------------------------+
 | Field          | Value                                |
 +----------------+--------------------------------------+
 | admin_state_up | True                                 |
 | description    |                                      |
 | id             | aebcd84a-8440-4c76-9f80-19e547615a79 |
 | name           | VPN                                  |
 | router_id      | 6c4cf781-8396-4731-8728-df2d860f6fbd |
 | status         | PENDING_CREATE                       |
 | subnet_id      | d7beddd6-c182-4e0a-a37c-019d8ee7077e |
 | tenant_id      | 0cb6b9b744594a619b0b7340f424858b     |
 +----------------+--------------------------------------+
 Created a new ikepolicy:
 +-------------------------+--------------------------------------+
 | Field                   | Value                                |
 +-------------------------+--------------------------------------+
 | auth_algorithm          | sha1                                 |
 | description             |                                      |
 | encryption_algorithm    | aes-256                              |
 | id                      | 428eca9c-3713-4596-a9df-b700695ef64f |
 | ike_version             | v1                                   |
 | lifetime                | {"units": "seconds", "value": 14400} |
 | name                    | IKE Policy                           |
 | pfs                     | group14                              |
 | phase1_negotiation_mode | main                                 |
 | tenant_id               | 0cb6b9b744594a619b0b7340f424858b     |
 +-------------------------+--------------------------------------+
 Created a new ipsecpolicy:
 +----------------------+--------------------------------------+
 | Field                | Value                                |
 +----------------------+--------------------------------------+
 | auth_algorithm       | sha1                                 |
 | description          |                                      |
 | encapsulation_mode   | tunnel                               |
 | encryption_algorithm | aes-256                              |
 | id                   | bce31d9f-304b-4572-9a69-5815a89ab235 |
 | lifetime             | {"units": "seconds", "value": 3600}  |
 | name                 | IPsec Policy                         |
 | pfs                  | group14                              |
 | tenant_id            | 0cb6b9b744594a619b0b7340f424858b     |
 | transform_protocol   | esp                                  |
 +----------------------+--------------------------------------+
 Created a new ipsec_site_connection:
 +----------------+-------------------------------------------------------+
 | Field          | Value                                                 |
 +----------------+-------------------------------------------------------+
 | admin_state_up | True                                                  |
 | auth_mode      | psk                                                   |
 | description    |                                                       |
 | dpd            | {"action": "restart", "interval": 15, "timeout": 150} |
 | id             | 5d1310c1-38ec-4668-9c62-e68ca01ff5b3                  |
 | ikepolicy_id   | 428eca9c-3713-4596-a9df-b700695ef64f                  |
 | initiator      | bi-directional                                        |
 | ipsecpolicy_id | bce31d9f-304b-4572-9a69-5815a89ab235                  |
 | mtu            | 1500                                                  |
 | name           | VPN                                                   |
 | peer_address   | 150.242.41.212                                        |
 | peer_cidrs     | 10.0.20.0/24                                          |
 | peer_id        | 150.242.41.212                                        |
 | psk            | supersecretpsk                                        |
 | route_mode     | static                                                |
 | status         | PENDING_CREATE                                        |
 | tenant_id      | 0cb6b9b744594a619b0b7340f424858b                      |
 | vpnservice_id  | aebcd84a-8440-4c76-9f80-19e547615a79                  |
 +----------------+-------------------------------------------------------+
 Your VPN has been created, note that you will need to create appropriate security group rules.

The script source is included below for reference:

.. literalinclude:: _scripts/create-vpn.sh
  :language: bash

***
FAQ
***

How do I find the external IP address of my instance?
=====================================================

There are scenarios where you may need to know the external IP address that
instances in your project are using. For example, you may wish to allow traffic
from your Catalyst Cloud instances to access a service that has firewalling or
other IP based access control in place.

For instances that have a floating IP you simply need to find the floating IP.
For instances that do not have a floating IP address, the external IP address
will be the external address of the router they are using to access the
``public-net``.

There are a number of methods you can use to find the IP address:

Using DNS on an instance
------------------------

From a cloud instance run the following command:

.. code-block:: bash

 ubuntu@my-instance:~$ dig +short myip.opendns.com @resolver1.opendns.com
 150.242.43.13

Using HTTP on an instance
-------------------------

From a cloud instance run the following command:

.. code-block:: bash

 ubuntu@my-instance:~$ curl http://ipinfo.io/ip
 150.242.43.13

Using a bash script on an instance
----------------------------------

You can use a bash script we have written for this purpose:

.. literalinclude:: _scripts/whats-my-ip.sh
  :language: bash

You can download and run this script on an instance:

.. code-block:: bash

 $ wget -q https://raw.githubusercontent.com/catalyst/catalystcloud-docs/master/scripts/whats-my-ip.sh
 $ chmod 744 whats-my-ip.sh
 $ ./whats-my-ip.sh
 finding your external ip ...
 Your external IP address is: 150.242.43.13

Using the OpenStack Command Line Tools
======================================

The method you use to find the external IP address will depend on whether the
instance has a floating IP address or not:

For an instance with a floating IP
----------------------------------

You can find the Floating IP of an instance in the instances list on the
dashboard. From the command line you can use the following command:

.. code-block:: bash

 $ openstack server show useful-machine -f value -c addresses | awk '{ print $2 }'
 150.242.43.13

For an instance without a floating IP
-------------------------------------

From a host where you have the OpenStack command line clients installed run the
following command:

.. code-block:: bash

 $ openstack router show border-router -f value -c external_gateway_info
 | external_gateway_info | {"network_id": "849ab1e9-7ac5-4618-8801-e6176fbbcf30", "enable_snat": true, "external_fixed_ips": [{"subnet_id": "aef23c7c-6c53-4157-8350-d6879c43346c", "ip_address": "150.242.40.120"}]} |

The address is the value associated with ``ip_address`` in
``external_fixed_ips``.

If you have ``jq`` installed you can run the following command:

.. code-block:: bash

 $ openstack router show border-router -f value -c external_gateway_info | jq -r '.external_fixed_ips[].ip_address'
 150.242.43.12


Why can't I SSH to my instance?
===============================

The standard way to SSH to an instance is to simply do so directly using an SSH
client like this:

.. code-block:: bash

  $ ssh ubuntu@103.254.156.248

.. note::

  The OpenStack command line client has an SSH option. This is not a
  recommended method for logging into an instance. This command
  currently has a bug where it cannot find the public address
  for an instance that does have a valid floating IP.

If you cannot SSH to an instance, there are two common root causes and one
less common one:

* Network issues connecting to the SSH Daemon on your instance
* Authentication issues after connecting to the SSH Daemon
* Issues with your instance such that the SSH Daemon is not available

Connection issues are generally caused by Security Group misconfiguration.
Authentication issues are generally caused by the use of incorrect users or SSH
keys.

If you are encountering a ``Connection timed out`` error then you have a
connection issue. If you are encountering a ``Permission denied (publickey).``
error then you have an authentication issue. If you are encountering a
different SSH error, then it is likely there is an issue with your instance.

Network issues
--------------

If you are encountering a ``Connection timed out`` error from your SSH client
then you have a network connection issue. The most common reason for this is a
Security Group misconfiguration. If you are experiencing this issue check the
following:

* Are you using the correct floating IP address when connecting?
* Do you have a security group that has a rule that allows incoming connections to port 22?
* Is your instance a member of the security group that allows SSH access?
* Is your source IP address within the CIDR IP range defined in the security group rule?

You can check your floating IP address with the following command:

.. code-block:: bash

  $ openstack server show example-instance | grep private-net
  | private-net network                  | 10.0.0.10, 150.242.40.180                                  |

You can check you have a security group rule for SSH access with the following
command:

.. code-block:: bash

  $ openstack security group rule list example-instance-sg
  +-------------+-----------+---------+------------+--------------+
  | IP Protocol | From Port | To Port | IP Range   | Source Group |
  +-------------+-----------+---------+------------+--------------+
  | tcp         | 22        | 22      | 1.2.3.4/32 |              |
  +-------------+-----------+---------+------------+--------------+

You can check which security groups your instances is a member of with the
following command:

.. code-block:: bash

  $ openstack server show example-instance | grep security_groups
  | security_groups                      | example-instance-sg, default

You can check what your public source IP address is using one of the following
commands:

.. code-block:: bash

  $ dig +short myip.opendns.com @resolver1.opendns.com
  $ curl http://ipinfo.io/ip

There are also numerous web sites that provide this information:
https://www.google.co.nz/search?q=whats%20my%20ip.

Security Group setup for SSH access
===================================

Assuming you have already assigned a floating IP address to your instance,
you will also need to create a security group and associate it with the
instance. Then create a rule within this group that will allow inbound SSH
access to your public IP address.

Create a new security group with this command:

.. code-block:: bash

  $ openstack security group create <name> <description>

For example, create a new security group called test-security-group:

.. code-block:: bash

  $ openstack security group create test-security-group --description "security group for test instance"

Add a new rule to the security group to allow access with the following:

.. code-block:: bash

  $ openstack security group rule create --ingress --protocol <ip-proto> --dst-port <to-port> --src-ip <cidr> <secgroup>

For example allow SSH access from 1.2.3.4

.. code-block:: bash

  $ openstack security group rule create --ingress --protocol tcp --dst-port 22 --src-ip  1.2.3.4/32 test-security-group

Finally, associate the new security group with the instance:

.. code-block:: bash

  $ server add security group <server> <securitygroup>

For example associate test-security-group with the instance first-instance

.. code-block:: bash

  $ server add security group first-instance test-security-group

Now test your access: you should be able to connect to your instance.

The same outcome can be achieved via the Cloud dashboard.

Create a new security group under ``Access & Security → Security Groups →
Create Security Group``. Once the new group is created go to ``Manage Rules →
Add Rule`` and create the appropriate inbound access rule.

Return to the instance page, from the Actions drop-down menu on the right
select ``Edit Security Groups``. Click the plus on your new security group and
ensure it now appears as one of the Instance Security Groups.

Testing Network Access
======================

If you want to test you have set up security groups properly for SSH access, you
can check port 22 on the floating IP for an SSH banner using telnet or netcat:

.. code-block:: bash

  $ nc 103.254.157.197 22
  SSH-2.0-OpenSSH_6.6.1p1 Ubuntu-2ubuntu2.6
  ^C

If you do not see an SSH banner, then it is likely you have not configured your
security group rules appropriately.

Authentication issues
---------------------

If you are encountering a ``Permission denied (publickey).`` error from your
SSH client then you have an authentication issue. If you are getting this error
then check the following:

* Are you using the correct user?
* Are you using the correct SSH key pair?
* Did you specify a key pair when you created the instance?

.. _ssh-user:

SSH User
========

As stated previously a typical SSH connection command looks like this:

.. code-block:: bash

  $ ssh ubuntu@103.254.156.248

Note the use of the ubuntu username, this is the default user for Ubuntu,
change this as required for the distribution you are using as explained at
:ref:`images`.

.. _ssh_keypairs:

SSH Key Pairs
=============

SSH key pairs are required for SSH access to instances. You can either import
an existing key pair or you can have a key pair created for you.

A key pair consists of two files: one contains the private key and the other
contains the public key. The private key will remain on your local machine and
should be kept private and secure. The public key is uploaded to your project
and will be injected into the authorised keys (``~/.ssh/authorized_keys``) for
the default user of the cloud image you are using (see :ref:`ssh-user`) when
your instance is created.

Default Key Pair
----------------

If you have imported a default SSH key pair (eg ``~/.ssh/id_rsa*``), then you
should be able to SSH using the standard SSH command:

.. code-block:: bash

  $ ssh ubuntu@103.254.156.248

Alternate Key Pair
------------------

If your SSH key pair is not in the standard location, you will need to use
the ``-i`` flag to SSH to indicate the key you wish to use.

.. code-block:: bash

  $ ssh -i ~/alt-key.pem ubuntu@103.254.157.197

.. note::

  The ``-i`` flag should reference the private key.

Created Key Pair
----------------

If you selected ``+ Create Key Pair`` from the dashboard, your browser
should have downloaded and saved the private key file for you. This will be
located in the default download location on your local machine (e.g.
``~/Downloads/keyname.pem``).

Before you can use this file you will need to change the permissions. If you do
not do so you will receive a warning entitled ``WARNING: UNPROTECTED PRIVATE
KEY FILE!`` and the key will be ignored which will result in a ``Permission
denied (publickey).`` error when connecting.

Do the following to secure this key:

.. code-block:: bash

  $ mv ~/Downloads/keyname.pem ~/.ssh/
  $ chmod 400 ~/.ssh/keyname.pem

When you use this option only the private key is downloaded to your machine. If
you need to know the public key (e.g. if you wish to use it elsewhere) you can
retrieve it using one of the following commands:

.. code-block:: bash

  $ openstack keypair show --public-key keyname
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCXX4g2e95XRH42zNN0rU+82e4UuND/5qjjMWeB/U7wm+kqPHHQpT98UJmDWMsyiJ93fpC+0vd9Hu2DAkycPhd0Tp4y8g/MagwaHj+hJrvUeCXnfHwHgPwcHQR3BoIXGBl0h/+BRELRBfyQAoN7+InlFlqp3lnhNQm9X6CKlfMNo7x1T0VWRUh64WdWrcjQOVU9EFFIL8xCHut7/eZY5l+X7NxIK8rALw+6Lo7AGAaWVo3Msi0DmE6y0y48OzGmOrXbZWUyS3mX7Tg0RsA9ynm2cJ2VM2GWpc7AMdxCv7VZu0J445MDj2ueJna4r8+qq4y6nJZ2JPJG3Su+51Vp4U93FtA0a90smTOGccOx6OMCly19sGEmQhUrUEevx0lrRHoDujZ+P7JD8mVR6cog/1n+OBqUMAa8dHgIGg0/KgcZ5ilDeyeqgELAcZoyRQLXu7eiQyH/hEc/Hh9xpXWwAK4kYe0HNXlJ0pB8j3aaY9Xrkk1s7xbCgZuoFZ2q1S+rEVMh9k1cflNurYwT8V5Iv9YuvX/rK7bSpmnFN6TtCEvJSBoqF3YXcxLjMCC7JMmhtXlNhWaethIdGz1iatjrVmKKe+r43N7IGBQX2iThi9sg6Uv6jeayjx5sUlPfimzFjnVB2/g/WKpiEFzA+nsfY8mKQzeLmRuuVQqlryWmCY0FIQ==
  $ ssh-keygen -f ~/.ssh/keyname.pem -y
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCDqJg/ijZsMk0AW33YOtGEmxatyakgEqOCE72hDy/MLyEiRPuInYPTJH9WhfjFQA8JgV/Wwt7iJqvosWWN65Sal8Vdqux2tVQtUHNTyllbh0JhlgNuRvQuPSLFN7IyRTlFSyUBztvDMLCBfR8785f8qwI4lNQ1LQyUWqAfXJ8sxYV0RO1puG3dIq6ME0MseQTxXB+G/ceiW17isUQ7zCK71KDECOhPF76sUgJaS/xBrKUFAwaXnHUmLxs7vLCChag0EGaMAo3yAAEy+Ptpfser+tdfK2xf54MvH4ebgQU+yZwPI8DpidbLmcuIOGimzqCG/MQUrCgY6jwT9CRlBsR

To write the public key to a file you can issue the following command:

.. code-block:: bash

  $ ssh-keygen -f ~/.ssh/keyname.pem -y > ~/.ssh/keyname.pub

Verifying SSH public key fingerprints
=====================================

According to `Wikipedia`_:

"In public-key cryptography, a public key fingerprint is a short sequence of
bytes used to identify a longer public key. Fingerprints are created by
applying a cryptographic hash function to a public key. Since fingerprints are
shorter than the keys they refer to, they can be used to simplify certain key
management tasks."

.. _Wikipedia: https://en.wikipedia.org/wiki/Public_key_fingerprint

Fingerprints are a useful way to verify that you are using the correct key
pair. If you have the public key locally then you can run this command to
generate the fingerprint:

.. code-block:: bash

  $ ssh-keygen -lf ~/.ssh/keyname.pub
  2048 34:de:c7:b7:f1:26:7f:88:d5:e7:10:6c:ab:af:a2:03 you@hostname (RSA)

If you have an OpenStack generated ``pem`` file and do not have the public key
stored locally, you can issue the following command:

.. code-block:: bash

  $ ssh-keygen -lf /dev/stdin <<< $( ssh-keygen -f ~/.ssh/keyname.pem -y )

To check the fingerprint of the key stored in your project, issue the following
command:

.. code-block:: bash

  $  openstack keypair show testkey | grep fingerprint
  | fingerprint | 34:de:c7:b7:f1:26:7f:88:d5:e7:10:6c:ab:af:a2:03 |

To check the key associated with an instance, issue the following
command:

.. code-block:: bash

  $ openstack server show first-instance | grep key_name
  | key_name                             | keyname                                         |

To check the key with the correct fingerprint was correctly injected into the
correct user's authorised keys, issue the following command:

.. code-block:: bash

  $ openstack console log show first-instance | grep 'Authorized keys' -A 5
  ci-info: ++++++Authorized keys from /home/ubuntu/.ssh/authorized_keys for user ubuntu++++++++++
  ci-info: +---------+-------------------------------------------------+---------+--------------+
  ci-info: | Keytype |                Fingerprint (md5)                | Options |  Comment     |
  ci-info: +---------+-------------------------------------------------+---------+--------------+
  ci-info: | ssh-rsa | 34:de:c7:b7:f1:26:7f:88:d5:e7:10:6c:ab:af:a2:03 |    -    | you@hostname |
  ci-info: +---------+-------------------------------------------------+---------+--------------+

Instance issues
===============

No route to host
----------------

If you are encountering a ``No route to host`` error, it is likely there is
an issue with your instance. You should check that the instance is running:

.. code-block:: bash

  $ openstack server show instance-name | grep status
  | status                               | SUSPENDED

The error can be triggered when an instance state is not ``ACTIVE``. In this
case, OpenStack will reply to a SSH connection attempt with a ICMP host
unreachable packet.

Connection refused
------------------

A ``connection refused`` error is caused by a TCP RST packet when attempting to
connect to the SSH port.

The most common reason for this error is misconfigured DNS servers on the
subnet where this instance resides. If DNS resolution is not working during
initialisation of the instance, delays will occur while the instance cloud-init
process waits for DNS. These delays occur before the SSH service is configured.
The service usually becomes available after about 5 minutes. When the SSH
connection becomes available it is often slow to connect. This is also caused
by broken DNS resolution on the instance.

Checking the instance console log can help verify if this is the issue you're
experiencing:

.. code-block:: bash

  $ openstack console log show broken-dns-instance --lines 6
  ci-info: +-------+-------------+-----------+---------------+-----------+-------+
  ci-info: | Route | Destination |  Gateway  |    Genmask    | Interface | Flags |
  ci-info: +-------+-------------+-----------+---------------+-----------+-------+
  ci-info: |   0   |   0.0.0.0   | 10.0.20.1 |    0.0.0.0    |    eth0   |   UG  |
  ci-info: |   1   |  10.0.20.0  |  0.0.0.0  | 255.255.255.0 |    eth0   |   U   |
  ci-info: +-------+-------------+-----------+---------------+-----------+-------+

If you see output similar to that shown above, it is likely the server is
waiting on DNS resolution.
