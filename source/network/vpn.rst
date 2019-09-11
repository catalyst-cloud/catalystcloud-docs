.. _vpn:

########################
Virtual Private Networks
########################

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
 manage this key appropriately, so for example be sure that it is not committed
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
 This script makes use of the `jq`_ command line utility for parsing JSON.
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

.. literalinclude:: ../_scripts/create-vpn.sh
  :language: bash
