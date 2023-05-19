####################################################
Deploying highly available instances with keepalived
####################################################

This tutorial assumes you have installed the OpenStack command line tools and
sourced an openrc file, as explained at :ref:`command-line-interface`. We also
assume that you have uploaded an SSH key, as explained
:ref:`here<uploading-an-ssh-key>`.

************
Introduction
************

In this tutorial, you will learn how to deploy a highly available instance pair
using VRRP. This tutorial is largely based on a `blog post`_ by Aaron O'Rosen
with modifications appropriate for the Catalyst Cloud. Networks and names have
been kept largely compatible with the source material.

.. _blog post: https://medium.com/@aaronorosen/implementing-high-availability-instances-with-neutron-using-vrrp-cb6db6f8578

You will be using two different methods to set up this stack. Initially you
will use the ``openstack`` command line tool to complete the setup
manually. You will then replicate the manual configuration using a ``heat``
template to instantiate the same stack automatically.

**********************************
Virtual router redundancy protocol
**********************************

`VRRP`_ provides hardware redundancy and automatic failover for routers. It
allows specifying a virtual router which maps to two or more physical routers.
Individual VRRP router instances share an IP address, but at any time, only one
of the instances is the master (active); the other instances are backups and
will not respond using the virtual address. If the master fails, one of the
backups is elected as the new master and will begin to respond on the virtual
address.

Instances use priorities from 1 (lowest) to 255 (highest). Devices running
VRRP dynamically elect master and backup routers based on their respective
priorities. Only the router that is acting as the master sends out VRRP
advertisements at any given point in time. The master router sends
advertisements to backup routers at regular intervals (default is every
second). If a backup router does not receive an advertisement for a set period,
the backup router with the next highest priority takes over as master and
begins forwarding packets.

VRRP instances communicate using packets with multicast IP address 224.0.0.18
and IP protocol number 112. The protocol is defined in `RFC3768`_.

.. _VRRP: https://en.wikipedia.org/wiki/Virtual_Router_Redundancy_Protocol

.. _RFC3768: https://en.wikipedia.org/wiki/Virtual_Router_Redundancy_Protocol

.. note::

  There is an extension to VRRP that uses IPSEC-AH (IP protocol 51) for
  integrity (see https://www.keepalived.org/draft-ietf-vrrp-ipsecah-spec-00.txt).
  This tutorial will demonstrate using standard VRRP. See this `article`_ for
  more information on securing VRRP.

.. _article: https://louwrentius.com/configuring-attacking-and-securing-vrrp-on-linux.html

*********************
Allowed address pairs
*********************

Allowed Address Pairs is a Neutron Extension that extends the port attribute to
enable you to specify arbitrary ``mac_address/ip_address(cidr)`` pairs that are
allowed to pass through a port, regardless of the subnet associated with the
network.

Let's double check that this extension is available on the Catalyst Cloud:

.. code-block:: bash

  $ openstack extension list --network -c Name -c Alias
  +-----------------------------------------------+-----------------------+
  | Name                                          | Alias                 |
  +-----------------------------------------------+-----------------------+
  | DNS Integration                               | dns-integration       |
  | Neutron L3 Configurable external gateway mode | ext-gw-mode           |
  | Port Binding                                  | binding               |
  | agent                                         | agent                 |
  | Subnet Allocation                             | subnet_allocation     |
  | L3 Agent Scheduler                            | l3_agent_scheduler    |
  | Neutron external network                      | external-net          |
  | Neutron Service Flavors                       | flavors               |
  | Network MTU                                   | net-mtu               |
  | Quota management support                      | quotas                |
  | HA Router extension                           | l3-ha                 |
  | Provider Network                              | provider              |
  | Multi Provider Network                        | multi-provider        |
  | VPN service                                   | vpnaas                |
  | Neutron Extra Route                           | extraroute            |
  | Neutron Extra DHCP opts                       | extra_dhcp_opt        |
  | Neutron Service Type Management               | service-type          |
  | security-group                                | security-group        |
  | DHCP Agent Scheduler                          | dhcp_agent_scheduler  |
  | RBAC Policies                                 | rbac-policies         |
  | Neutron L3 Router                             | router                |
  | Allowed Address Pairs                         | allowed-address-pairs |
  | Distributed Virtual Router                    | dvr                   |
  +-----------------------------------------------+-----------------------+

As you can see, the Allowed Address Pairs extension is available.

.. _clone-orchestration-repo:

**********************************
Clone orchestration git repository
**********************************

Before you start you should check out the
https://github.com/catalyst/catalystcloud-orchestration git repository. You will
be using some scripts and Heat templates from this repository in this tutorial.

.. code-block:: bash

  $ git clone https://github.com/catalyst/catalystcloud-orchestration.git && ORCHESTRATION_DIR="$(pwd)/catalystcloud-orchestration" && echo $ORCHESTRATION_DIR

*************
Network setup
*************

First, create a network called ``vrrp-net`` where you can run your highly
available hosts:

.. code-block:: bash

  $ openstack network create vrrp-net
  +---------------------------+--------------------------------------+
  | Field                     | Value                                |
  +---------------------------+--------------------------------------+
  | admin_state_up            | UP                                   |
  | availability_zone_hints   | None                                 |
  | availability_zones        | None                                 |
  | created_at                | None                                 |
  | description               | None                                 |
  | dns_domain                | None                                 |
  | id                        | cb6c2c3a-c088-44ca-b80f-xxxxxxxxxxxx |
  | ipv4_address_scope        | None                                 |
  | ipv6_address_scope        | None                                 |
  | is_default                | None                                 |
  | is_vlan_transparent       | None                                 |
  | mtu                       | 0                                    |
  | name                      | vrrp-net                             |
  | port_security_enabled     | False                                |
  | project_id                | None                                 |
  | provider:network_type     | None                                 |
  | provider:physical_network | None                                 |
  | provider:segmentation_id  | None                                 |
  | qos_policy_id             | None                                 |
  | revision_number           | None                                 |
  | router:external           | Internal                             |
  | segments                  | None                                 |
  | shared                    | False                                |
  | status                    | ACTIVE                               |
  | subnets                   |                                      |
  | tags                      | None                                 |
  | updated_at                | None                                 |
  +---------------------------+--------------------------------------+

Next, set up a subnet of the network you have just created. You are going to
do this so you can use part of the ``vrrp-net`` as a dynamically assigned pool
of addresses and reserve the rest of the addresses for manual assignment. In
this case, the pool addresses are in the range 2-200, while the remainder of the
``/24`` will be statically assigned.

.. code-block:: bash

  $ openstack subnet create --network vrrp-net --allocation-pool start=10.0.0.2,end=10.0.0.200 --subnet-range 10.0.0.0/24 vrrp-subnet
  +-------------------+--------------------------------------+
  | Field             | Value                                |
  +-------------------+--------------------------------------+
  | allocation_pools  | 10.0.0.2-10.0.0.200                  |
  | cidr              | 10.0.0.0/24                          |
  | created_at        | None                                 |
  | description       | None                                 |
  | dns_nameservers   |                                      |
  | enable_dhcp       | True                                 |
  | gateway_ip        | 10.0.0.1                             |
  | host_routes       |                                      |
  | id                | 2919a9ff-d44c-480e-bc0f-xxxxxxxxxxxx |
  | ip_version        | 4                                    |
  | ipv6_address_mode | None                                 |
  | ipv6_ra_mode      | None                                 |
  | name              | vrrp-subnet                          |
  | network_id        | cb6c2c3a-c088-44ca-b80f-xxxxxxxxxxxx |
  | project_id        | <PROJECT_ID>     |
  | revision_number   | None                                 |
  | segment_id        | None                                 |
  | service_types     | None                                 |
  | subnetpool_id     | None                                 |
  | tags              | None                                 |
  | updated_at        | None                                 |
  +-------------------+--------------------------------------+

Now you will create a router. You will give this router an interface on your
new subnet and set its gateway as your public network:

.. code-block:: bash

  $ openstack router create vrrp-router
  +-------------------------+--------------------------------------+
  | Field                   | Value                                |
  +-------------------------+--------------------------------------+
  | admin_state_up          | UP                                   |
  | availability_zone_hints | None                                 |
  | availability_zones      | None                                 |
  | created_at              | None                                 |
  | description             | None                                 |
  | distributed             | False                                |
  | external_gateway_info   | None                                 |
  | flavor_id               | None                                 |
  | ha                      | False                                |
  | id                      | 79a6c45a-abf7-4e0a-9495-xxxxxxxxxxxx |
  | name                    | vrrp-router                          |
  | project_id              | <PROJECT_ID>     |
  | revision_number         | None                                 |
  | routes                  |                                      |
  | status                  | ACTIVE                               |
  | tags                    | None                                 |
  | updated_at              | None                                 |
  +-------------------------+--------------------------------------+

  $ openstack router add subnet vrrp-router vrrp-subnet

  Set gateway for router vrrp-router
  $ openstack router set --external-gateway public-net vrrp-router

.. note::

  * If you look at the ports created at this point using the ``openstack port list -c ID -c 'Fixed IP Addresses'`` command you will notice three interfaces have been created. The IP 10.0.0.1 is the gateway address while 10.0.0.2 and 10.0.0.3 provide DHCP for this network.
  * Note the DNS nameservers, gateway address, subnet mask and allocation pool of the subnet from the ``openstack subnet create`` command.

Next you will create ports with a fixed IP for your new Keepalived instances:

To find the correct subnet and network ID use the following commands

.. code-block:: bash

  $ VRRP_SUBNET_ID=$( openstack subnet show vrrp-subnet -f value -c id ) && echo $VRRP_SUBNET_ID
  cd376d6f-42f4-46c2-8988-xxxxxxxxxxxx

  $ VRRP_NET_ID=$( openstack network show vrrp-net -f value -c id ) && echo $VRRP_NET_ID
  98ec34ba-b25e-4720-ae5e-xxxxxxxxxxxx

Then create the ports with your preferred IP addresses

.. code-block:: bash

  $ openstack port create --fixed-ip subnet=$VRRP_SUBNET_ID,ip-address=10.0.0.4 --network $VRRP_NET_ID vrrp_master_server_port
  +-----------------------+---------------------------------------------------------------------------------------+
  | Field                 | Value                                                                                 |
  +-----------------------+---------------------------------------------------------------------------------------+
  | admin_state_up        | UP                                                                                    |
  | allowed_address_pairs |                                                                                       |
  | binding_host_id       | None                                                                                  |
  | binding_profile       | None                                                                                  |
  | binding_vif_details   | None                                                                                  |
  | binding_vif_type      | None                                                                                  |
  | binding_vnic_type     | normal                                                                                |
  | created_at            | None                                                                                  |
  | data_plane_status     | None                                                                                  |
  | description           | None                                                                                  |
  | device_id             |                                                                                       |
  | device_owner          |                                                                                       |
  | dns_assignment        | fqdn='host-10-0-0-4.openstacklocal.', hostname='host-10-0-0-4', ip_address='10.0.0.4' |
  | dns_name              |                                                                                       |
  | extra_dhcp_opts       | None                                                                                  |
  | fixed_ips             | ip_address='10.0.0.4', subnet_id='2919a9ff-d44c-480e-bc0f-xxxxxxxxxxxx'               |
  | id                    | 6bd99608-774c-41ba-ab88-xxxxxxxxxxxx                                                  |
  | ip_address            | None                                                                                  |
  | mac_address           | fa:16:3e:da:c1:19                                                                     |
  | name                  | vrrp_master_server_port                                                               |
  | network_id            | cb6c2c3a-c088-44ca-b80f-xxxxxxxxxxxx                                                  |
  | option_name           | None                                                                                  |
  | option_value          | None                                                                                  |
  | port_security_enabled | False                                                                                 |
  | project_id            | <PROJECT_ID>                                                      |
  | qos_policy_id         | None                                                                                  |
  | revision_number       | None                                                                                  |
  | security_group_ids    | 1df52ef7-23d3-44ed-9a7d-xxxxxxxxxxxx                                                  |
  | status                | DOWN                                                                                  |
  | subnet_id             | None                                                                                  |
  | tags                  | None                                                                                  |
  | trunk_details         | None                                                                                  |
  | updated_at            | None                                                                                  |
  +-----------------------+---------------------------------------------------------------------------------------+

  $ openstack port create --fixed-ip subnet=$VRRP_SUBNET_ID,ip-address=10.0.0.5 --network $VRRP_NET_ID vrrp_backup_server_port
  +-----------------------+---------------------------------------------------------------------------------------+
  | Field                 | Value                                                                                 |
  +-----------------------+---------------------------------------------------------------------------------------+
  | admin_state_up        | UP                                                                                    |
  | allowed_address_pairs |                                                                                       |
  | binding_host_id       | None                                                                                  |
  | binding_profile       | None                                                                                  |
  | binding_vif_details   | None                                                                                  |
  | binding_vif_type      | None                                                                                  |
  | binding_vnic_type     | normal                                                                                |
  | created_at            | None                                                                                  |
  | data_plane_status     | None                                                                                  |
  | description           | None                                                                                  |
  | device_id             |                                                                                       |
  | device_owner          |                                                                                       |
  | dns_assignment        | fqdn='host-10-0-0-5.openstacklocal.', hostname='host-10-0-0-5', ip_address='10.0.0.5' |
  | dns_name              |                                                                                       |
  | extra_dhcp_opts       | None                                                                                  |
  | fixed_ips             | ip_address='10.0.0.5', subnet_id='2919a9ff-d44c-480e-bc0f-xxxxxxxxxxxx'               |
  | id                    | 30a60e68-8311-4098-8236-xxxxxxxxxxxx                                                  |
  | ip_address            | None                                                                                  |
  | mac_address           | fa:16:3e:a5:62:2a                                                                     |
  | name                  | vrrp_backup_server_port                                                               |
  | network_id            | cb6c2c3a-c088-44ca-b80f-xxxxxxxxxxxx                                                  |
  | option_name           | None                                                                                  |
  | option_value          | None                                                                                  |
  | port_security_enabled | False                                                                                 |
  | project_id            | <PROJECT_ID>                                                      |
  | qos_policy_id         | None                                                                                  |
  | revision_number       | None                                                                                  |
  | security_group_ids    | 1df52ef7-23d3-44ed-9a7d-xxxxxxxxxxxx                                                  |
  | status                | DOWN                                                                                  |
  | subnet_id             | None                                                                                  |
  | tags                  | None                                                                                  |
  | trunk_details         | None                                                                                  |
  | updated_at            | None                                                                                  |
  +-----------------------+---------------------------------------------------------------------------------------+

********************
Security group setup
********************

Now create the ``vrrp-sec-group`` security group with rules to
allow HTTP, SSH and ICMP ingress:

.. code-block:: bash

  $ openstack security group create --description 'VRRP security group' vrrp-sec-group
  +-----------------+---------------------------------------------------------------------------------+
  | Field           | Value                                                                           |
  +-----------------+---------------------------------------------------------------------------------+
  | created_at      | None                                                                            |
  | description     | VRRP security group                                                             |
  | id              | 6b82f642-aa10-456a-a060-xxxxxxxxxxxx                                            |
  | name            | vrrp-sec-group                                                                  |
  | project_id      | <PROJECT_ID>                                                |
  | revision_number | None                                                                            |
  | rules           | direction='egress', ethertype='IPv4', id='dc8a5cc8-6dfd-4582-97f9-xxxxxxxxxxxx' |
  |                 | direction='egress', ethertype='IPv6', id='db77df48-fd33-4eba-a53b-xxxxxxxxxxxx' |
  | updated_at      | None                                                                            |
  +-----------------+---------------------------------------------------------------------------------+

  $ openstack security group rule create --ingress --protocol icmp vrrp-sec-group
  +-------------------+--------------------------------------+
  | Field             | Value                                |
  +-------------------+--------------------------------------+
  | created_at        | None                                 |
  | description       | None                                 |
  | direction         | ingress                              |
  | ether_type        | IPv4                                 |
  | id                | 05c2ef77-51f6-4829-a834-xxxxxxxxxxxx |
  | name              | None                                 |
  | port_range_max    | None                                 |
  | port_range_min    | None                                 |
  | project_id        | <PROJECT_ID>     |
  | protocol          | icmp                                 |
  | remote_group_id   | None                                 |
  | remote_ip_prefix  | 0.0.0.0/0                            |
  | revision_number   | None                                 |
  | security_group_id | 6b82f642-aa10-456a-a060-xxxxxxxxxxxx |
  | updated_at        | None                                 |
  +-------------------+--------------------------------------+

  $ openstack security group rule create --ingress --protocol tcp --dst-port 80 vrrp-sec-group
  +-------------------+--------------------------------------+
  | Field             | Value                                |
  +-------------------+--------------------------------------+
  | created_at        | None                                 |
  | description       | None                                 |
  | direction         | ingress                              |
  | ether_type        | IPv4                                 |
  | id                | ab6732ce-413b-4637-9d55-xxxxxxxxxxxx |
  | name              | None                                 |
  | port_range_max    | 80                                   |
  | port_range_min    | 80                                   |
  | project_id        | <PROJECT_ID>     |
  | protocol          | tcp                                  |
  | remote_group_id   | None                                 |
  | remote_ip_prefix  | 0.0.0.0/0                            |
  | revision_number   | None                                 |
  | security_group_id | 6b82f642-aa10-456a-a060-xxxxxxxxxxxx |
  | updated_at        | None                                 |
  +-------------------+--------------------------------------+

  $ openstack security group rule create --ingress --protocol tcp --dst-port 22 vrrp-sec-group
  +-------------------+--------------------------------------+
  | Field             | Value                                |
  +-------------------+--------------------------------------+
  | created_at        | None                                 |
  | description       | None                                 |
  | direction         | ingress                              |
  | ether_type        | IPv4                                 |
  | id                | 95f8e7be-e6e0-4cd1-b166-xxxxxxxxxxxx |
  | name              | None                                 |
  | port_range_max    | 22                                   |
  | port_range_min    | 22                                   |
  | project_id        | <PROJECT_ID>     |
  | protocol          | tcp                                  |
  | remote_group_id   | None                                 |
  | remote_ip_prefix  | 0.0.0.0/0                            |
  | revision_number   | None                                 |
  | security_group_id | 6b82f642-aa10-456a-a060-xxxxxxxxxxxx |
  | updated_at        | None                                 |
  +-------------------+--------------------------------------+


Next you will add a rule to allow your Keepalived instances to communicate with
each other via VRRP broadcasts:

.. code-block:: bash

  $ openstack security group rule create --protocol 112 --remote-group vrrp-sec-group vrrp-sec-group
  +-------------------+--------------------------------------+
  | Field             | Value                                |
  +-------------------+--------------------------------------+
  | created_at        | None                                 |
  | description       | None                                 |
  | direction         | ingress                              |
  | ether_type        | IPv4                                 |
  | id                | bef20d57-eef5-41b1-98e6-xxxxxxxxxxxx |
  | name              | None                                 |
  | port_range_max    | None                                 |
  | port_range_min    | None                                 |
  | project_id        | <PROJECT_ID>     |
  | protocol          | 112                                  |
  | remote_group_id   | 6b82f642-aa10-456a-a060-xxxxxxxxxxxx |
  | remote_ip_prefix  | None                                 |
  | revision_number   | None                                 |
  | security_group_id | 6b82f642-aa10-456a-a060-xxxxxxxxxxxx |
  | updated_at        | None                                 |
  +-------------------+--------------------------------------+

*****************
Instance creation
*****************

The next step is to boot two instances where you will run Keepalived and
Apache. You will be using the Ubuntu 14.04 image and ``c1.c1r1`` flavor. You
will assign these instances to the ``vrrp-sec-group`` security group. You will
also provide the name of your SSH key so you can log in to these machines via
SSH once they are created:

.. note::
 You will need to substitute the name of your SSH key.

To find the correct IDs you can use the following commands:

.. code-block:: bash

 $ VRRP_IMAGE_ID=$( openstack image show ubuntu-14.04-x86_64 -f value -c id ) && echo $VRRP_IMAGE_ID
 a7e6d3b5-9980-4ae0-a5b7-xxxxxxxxxxxx

 $ VRRP_FLAVOR_ID=$( openstack flavor show c1.c1r1 -f value -c id ) && echo $VRRP_FLAVOR_ID
 28153197-6690-4485-9dbc-xxxxxxxxxxxx

 $ VRRP_NET_ID=$( openstack network show vrrp-net -f value -c id ) && echo $VRRP_NET_ID
 cb6c2c3a-c088-44ca-b80f-xxxxxxxxxxxx

 $ VRRP_MASTER_PORT=$(openstack port show vrrp_master_server_port -f value -c id) && echo $VRRP_MASTER_PORT
 6bd99608-774c-41ba-ab88-xxxxxxxxxxxx

 $ VRRP_BACKUP_PORT=$(openstack port show vrrp_backup_server_port -f value -c id) && echo $VRRP_BACKUP_PORT
 1736183d-8beb-4131-bb60-xxxxxxxxxxxx


 $ openstack keypair list
 +------------------+-------------------------------------------------+
 | Name             | Fingerprint                                     |
 +------------------+-------------------------------------------------+
 | vrrp-demo-key    | <SSH_KEY_FINGERPRINT>                           |
 +------------------+-------------------------------------------------+

You will be passing a script to our instance boot command using the
``--user-data`` flag. This script sets up Keepalived and Apache on your master
and backup instances. This saves you from having to execute these commands manually.
This script is located in the git repository you cloned previously at
:ref:`clone-orchestration-repo`.

.. code-block:: bash

 $ cat "$ORCHESTRATION_DIR/hot/ubuntu-14.04/vrrp-basic/vrrp-setup.sh"
 #!/bin/bash

 HOSTNAME=$(hostname)

 if [ "$HOSTNAME" == "vrrp-master" ]; then
     KEEPALIVED_STATE='MASTER'
     KEEPALIVED_PRIORITY=100
 elif [ "$HOSTNAME" == "vrrp-backup" ]; then
     KEEPALIVED_STATE='BACKUP'
     KEEPALIVED_PRIORITY=50
 else
     echo "invalid hostname $HOSTNAME for install script $0";
     exit 1;
 fi

 IP=$(ip addr | grep inet | grep eth0 | grep -v secondary | awk '{ print $2 }' | awk -F'/' '{ print $1 }')

 echo "$IP $HOSTNAME" >> /etc/hosts

 apt-get update
 apt-get -y install keepalived

 echo "vrrp_instance vrrp_group_1 {
     state $KEEPALIVED_STATE
     interface eth0
     virtual_router_id 1
     priority $KEEPALIVED_PRIORITY
     authentication {
         auth_type PASS
         auth_pass password
     }
     virtual_ipaddress {
         10.0.0.201/24 brd 10.0.0.255 dev eth0
     }
 }" > /etc/keepalived/keepalived.conf

 apt-get -y install apache2
 echo "$HOSTNAME" > /var/www/html/index.html
 service keepalived restart


Run the boot command (you will need to substitute your SSH key name and
path to the ``vrrp-setup.sh`` script):

.. code-block:: bash

  $ openstack server create --image $VRRP_IMAGE_ID --flavor $VRRP_FLAVOR_ID --nic port-id=$VRRP_MASTER_PORT \
  --security-group vrrp-sec-group --user-data vrrp-setup.sh --key-name vrrp-demo-key vrrp-master

  +-----------------------------+------------------------------------------------------------+
  | Field                       | Value                                                      |
  +-----------------------------+------------------------------------------------------------+
  | OS-DCF:diskConfig           | MANUAL                                                     |
  | OS-EXT-AZ:availability_zone |                                                            |
  | OS-EXT-STS:power_state      | NOSTATE                                                    |
  | OS-EXT-STS:task_state       | scheduling                                                 |
  | OS-EXT-STS:vm_state         | building                                                   |
  | OS-SRV-USG:launched_at      | None                                                       |
  | OS-SRV-USG:terminated_at    | None                                                       |
  | accessIPv4                  |                                                            |
  | accessIPv6                  |                                                            |
  | addresses                   |                                                            |
  | adminPass                   | 2X2Jao8nqk5G                                               |
  | config_drive                |                                                            |
  | created                     | 2018-01-10T20:48:02Z                                       |
  | flavor                      | c1.c1r1 (28153197-6690-4485-9dbc-xxxxxxxxxxxx)             |
  | hostId                      |                                                            |
  | id                          | c8a2c1ec-73f2-4f6b-8107-xxxxxxxxxxxx                       |
  | image                       | ubuntu-14.04-x86_64 (a7e6d3b5-9980-4ae0-a5b7-xxxxxxxxxxxx) |
  | key_name                    | glxxxxxxes                                                 |
  | name                        | vrrp-master                                                |
  | progress                    | 0                                                          |
  | project_id                  | <PROJECT_ID>                           |
  | properties                  |                                                            |
  | security_groups             | name='6b82f642-aa10-456a-a060-xxxxxxxxxxxx'                |
  | status                      | BUILD                                                      |
  | updated                     | 2018-01-10T20:48:02Z                                       |
  | user_id                     | b80eb08f12c34717xxxxxxe1eff9f501                           |
  | volumes_attached            |                                                            |
  +-----------------------------+------------------------------------------------------------+

  $ openstack server create --image $VRRP_IMAGE_ID --flavor $VRRP_FLAVOR_ID --nic port-id=$VRRP_BACKUP_PORT \
  --security-group vrrp-sec-group --user-data vrrp-setup.sh --key-name vrrp-demo-key vrrp-backup

  +-----------------------------+------------------------------------------------------------+
  | Field                       | Value                                                      |
  +-----------------------------+------------------------------------------------------------+
  | OS-DCF:diskConfig           | MANUAL                                                     |
  | OS-EXT-AZ:availability_zone |                                                            |
  | OS-EXT-STS:power_state      | NOSTATE                                                    |
  | OS-EXT-STS:task_state       | None                                                       |
  | OS-EXT-STS:vm_state         | building                                                   |
  | OS-SRV-USG:launched_at      | None                                                       |
  | OS-SRV-USG:terminated_at    | None                                                       |
  | accessIPv4                  |                                                            |
  | accessIPv6                  |                                                            |
  | addresses                   |                                                            |
  | adminPass                   | UHeDaT2qtVSp                                               |
  | config_drive                |                                                            |
  | created                     | 2018-01-10T20:49:20Z                                       |
  | flavor                      | c1.c1r1 (28153197-6690-4485-9dbc-xxxxxxxxxxxx)             |
  | hostId                      |                                                            |
  | id                          | 338bbb2c-3d63-4079-90d1-xxxxxxxxxxxx                       |
  | image                       | ubuntu-14.04-x86_64 (a7e6d3b5-9980-4ae0-a5b7-xxxxxxxxxxxx) |
  | key_name                    | glxxxxxxes                                                 |
  | name                        | vrrp-backup                                                |
  | progress                    | 0                                                          |
  | project_id                  | <PROJECT_ID>                           |
  | properties                  |                                                            |
  | security_groups             | name='6b82f642-aa10-456a-a060-xxxxxxxxxxxx'                |
  | status                      | BUILD                                                      |
  | updated                     | 2018-01-10T20:49:21Z                                       |
  | user_id                     | b80eb08f12c34717xxxxxxe1eff9f501                           |
  | volumes_attached            |                                                            |
  +-----------------------------+------------------------------------------------------------+

Check the instances have been created:

.. code-block:: bash

  $ openstack server list
  +--------------------------------------+-------------+--------+------------------------------------------+---------------------+---------+
  | ID                                   | Name        | Status | Networks                                 | Image               | Flavor  |
  +--------------------------------------+-------------+--------+------------------------------------------+---------------------+---------+
  | 338bbb2c-3d63-4079-90d1-xxxxxxxxxxxx | vrrp-backup | ACTIVE | vrrp-net=10.0.0.5                        | ubuntu-14.04-x86_64 | c1.c1r1 |
  | c8a2c1ec-73f2-4f6b-8107-xxxxxxxxxxxx | vrrp-master | ACTIVE | vrrp-net=10.0.0.4                        | ubuntu-14.04-x86_64 | c1.c1r1 |
  +--------------------------------------+-------------+--------+------------------------------------------+---------------------+---------+

*********************
Virtual address setup
*********************

The next step is to create the IP address that will be used by your virtual
router:

.. code-block:: bash

  $ openstack port create --network vrrp-net --fixed-ip ip-address=10.0.0.201 vrrp-port
  +-----------------------+---------------------------------------------------------------------------------------------+
  | Field                 | Value                                                                                       |
  +-----------------------+---------------------------------------------------------------------------------------------+
  | admin_state_up        | UP                                                                                          |
  | allowed_address_pairs |                                                                                             |
  | binding_host_id       | None                                                                                        |
  | binding_profile       | None                                                                                        |
  | binding_vif_details   | None                                                                                        |
  | binding_vif_type      | None                                                                                        |
  | binding_vnic_type     | normal                                                                                      |
  | created_at            | None                                                                                        |
  | data_plane_status     | None                                                                                        |
  | description           | None                                                                                        |
  | device_id             |                                                                                             |
  | device_owner          |                                                                                             |
  | dns_assignment        | fqdn='host-10-0-0-201.openstacklocal.', hostname='host-10-0-0-201', ip_address='10.0.0.201' |
  | dns_name              |                                                                                             |
  | extra_dhcp_opts       | None                                                                                        |
  | fixed_ips             | ip_address='10.0.0.201', subnet_id='2919a9ff-d44c-480e-bc0f-xxxxxxxxxxxx'                   |
  | id                    | 45c3aadb-b4fe-41ab-84cf-xxxxxxxxxxxx                                                        |
  | ip_address            | None                                                                                        |
  | mac_address           | fa:16:3e:26:7c:03                                                                           |
  | name                  | vrrp-port                                                                                   |
  | network_id            | cb6c2c3a-c088-44ca-b80f-xxxxxxxxxxxx                                                        |
  | option_name           | None                                                                                        |
  | option_value          | None                                                                                        |
  | port_security_enabled | False                                                                                       |
  | project_id            | <PROJECT_ID>                                                            |
  | qos_policy_id         | None                                                                                        |
  | revision_number       | None                                                                                        |
  | security_group_ids    | 1df52ef7-23d3-44ed-9a7d-xxxxxxxxxxxx                                                        |
  | status                | DOWN                                                                                        |
  | subnet_id             | None                                                                                        |
  | tags                  | None                                                                                        |
  | trunk_details         | None                                                                                        |
  | updated_at            | None                                                                                        |
  +-----------------------+---------------------------------------------------------------------------------------------+

Now you need to create a floating IP and point it to your virtual router IP
using its port ID:

.. code-block:: bash

  $ VRRP_VR_PORT_ID=$(openstack port list | grep 10.0.0.201 | awk '{ print $2 }') && echo $VRRP_VR_PORT_ID
  45c3aadb-b4fe-41ab-84cf-xxxxxxxxxxxx

  $ openstack floating ip create --port $VRRP_VR_PORT_ID public-net
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | created_at          | None                                 |
  | description         | None                                 |
  | fixed_ip_address    | 10.0.0.201                           |
  | floating_ip_address | 150.242.41.83                        |
  | floating_network_id | 849ab1e9-7ac5-4618-8801-xxxxxxxxxxxx |
  | id                  | 34b3e6ac-1e79-415d-8f05-xxxxxxxxxxxx |
  | name                | 150.242.41.83                        |
  | port_id             | 45c3aadb-b4fe-41ab-84cf-xxxxxxxxxxxx |
  | project_id          | <PROJECT_ID>     |
  | revision_number     | None                                 |
  | router_id           | 79a6c45a-abf7-4e0a-9495-xxxxxxxxxxxx |
  | status              | DOWN                                 |
  | updated_at          | None                                 |
  +---------------------+--------------------------------------+


Next, you update the ports associated with each instance to allow the virtual
router IP as an ``allowed-address-pair``. This will allow them to send traffic
using this address.

.. code-block:: bash

  $ VRRP_MASTER_PORT=$(openstack port list | grep '10.0.0.4' | awk '{ print $2 }') && echo $VRRP_MASTER_PORT
  6bd99608-774c-41ba-ab88-xxxxxxxxxxxx

  $ VRRP_BACKUP_PORT=$(openstack port list | grep '10.0.0.5' | awk '{ print $2 }') && echo $VRRP_BACKUP_PORT
  30a60e68-8311-4098-8236-xxxxxxxxxxxx

  $ openstack port set --allowed-address ip-address=10.0.0.201 $VRRP_MASTER_PORT

  $ openstack port set --allowed-address ip-address=10.0.0.201 $VRRP_BACKUP_PORT


Check that the virtual router address is associated with this port under
``allowed_address_pairs``:

.. code-block:: bash

  $ openstack port show $VRRP_MASTER_PORT
  +-----------------------+---------------------------------------------------------------------------------------+
  | Field                 | Value                                                                                 |
  +-----------------------+---------------------------------------------------------------------------------------+
  | admin_state_up        | UP                                                                                    |
  | allowed_address_pairs | ip_address='10.0.0.201', mac_address='fa:16:3e:da:c1:19'                              |
  | binding_host_id       | None                                                                                  |
  | binding_profile       | None                                                                                  |
  | binding_vif_details   | None                                                                                  |
  | binding_vif_type      | None                                                                                  |
  | binding_vnic_type     | normal                                                                                |
  | created_at            | None                                                                                  |
  | data_plane_status     | None                                                                                  |
  | description           | None                                                                                  |
  | device_id             | c8a2c1ec-73f2-4f6b-8107-xxxxxxxxxxxx                                                  |
  | device_owner          | compute:None                                                                          |
  | dns_assignment        | fqdn='host-10-0-0-4.openstacklocal.', hostname='host-10-0-0-4', ip_address='10.0.0.4' |
  | dns_name              |                                                                                       |
  | extra_dhcp_opts       |                                                                                       |
  | fixed_ips             | ip_address='10.0.0.4', subnet_id='2919a9ff-d44c-480e-bc0f-xxxxxxxxxxxx'               |
  | id                    | 6bd99608-774c-41ba-ab88-xxxxxxxxxxxx                                                  |
  | ip_address            | None                                                                                  |
  | mac_address           | fa:16:3e:da:c1:19                                                                     |
  | name                  | vrrp_master_server_port                                                               |
  | network_id            | cb6c2c3a-c088-44ca-b80f-xxxxxxxxxxxx                                                  |
  | option_name           | None                                                                                  |
  | option_value          | None                                                                                  |
  | port_security_enabled | False                                                                                 |
  | project_id            | <PROJECT_ID>                                                      |
  | qos_policy_id         | None                                                                                  |
  | revision_number       | None                                                                                  |
  | security_group_ids    | 1df52ef7-23d3-44ed-9a7d-xxxxxxxxxxxx                                                  |
  | status                | ACTIVE                                                                                |
  | subnet_id             | None                                                                                  |
  | tags                  | None                                                                                  |
  | trunk_details         | None                                                                                  |
  | updated_at            | None                                                                                  |
  +-----------------------+---------------------------------------------------------------------------------------+

You should now have a stack that looks something like this:

.. image:: ../_static/vrrp-network.png
   :align: center

.. _updating-instance:

************************************************
Updating existing VRRP instances to use fixed IP
************************************************

To update **existing** VRRP instances to use fixed IP on their interfaces,
obtain the port ID of the instances and update the port:

.. code-block:: bash

 $ VRRP_SUBNET_ID=$( openstack subnet show vrrp-subnet -f value -c id ) && echo $VRRP_SUBNET_ID
 2919a9ff-d44c-480e-bc0f-xxxxxxxxxxxx

 $ VRRP_NET_ID=$( openstack network show vrrp-net -f value -c id ) && echo $VRRP_NET_ID
 cb6c2c3a-c088-44ca-b80f-xxxxxxxxxxxx

 $ VRRP_MASTER_ID=$(openstack server list | grep 'vrrp-master' | awk '{print $2}') && echo $VRRP_MASTER_ID
 c8a2c1ec-73f2-4f6b-8107-xxxxxxxxxxxx

 $ VRRP_MASTER_PORT=$(openstack port list --server $VRRP_MASTER_ID | grep '10.0.0.4' | awk '{print $2}') && echo $VRRP_MASTER_PORT
 6bd99608-774c-41ba-ab88-xxxxxxxxxxxx

 $ openstack port set --fixed-ip subnet=$VRRP_SUBNET_ID,ip_address=10.0.0.4 $VRRP_MASTER_PORT

 $ VRRP_BACKUP_ID=$(openstack server list | grep 'vrrp-backup' | awk '{print $2}') && echo $VRRP_BACKUP_ID
 d920fa78-a463-4e17-90de-xxxxxxxxxxxx

 $ VRRP_BACKUP_PORT=$(openstack port list --server $VRRP_BACKUP_ID | grep '10.0.0.5' | awk '{print $2}') && echo $VRRP_BACKUP_PORT

 $ openstack port set --fixed-ip $VRRP_SUBNET_ID,ip_address=10.0.0.5 $VRRP_BACKUP_PORT

Then log in to the instances and edit their network interfaces and resolv.conf
files:

.. code-block:: bash

 $ sudo vi /etc/network/interfaces.d/eth0.cfg
 auto eth0
 iface eth0 inet static
    address 10.0.0.4
    netmask 255.255.255.0
    broadcast 10.0.0.255
    gateway  10.0.0.1

 $ sudo apt-get -y --purge remove resolvconf

 $ sudo vi /etc/resolv.conf
 nameserver 202.78.247.197
 nameserver 202.78.247.198
 nameserver 202.78.247.199
 search openstacklocal

 $ sudo service networking reload

.. _vrrp-testing:

************
VRRP testing
************

You should now have a working VRRP setup, so try it out! You should be able
to curl the floating IP associated with your virtual router:

.. code-block:: bash

 $ VRRP_FLOATING_IP=$(openstack floating ip list | grep 10.0.0.201 | awk '{ print $4 }') && echo $VRRP_FLOATING_IP
 150.242.40.121
 $ curl $VRRP_FLOATING_IP
 vrrp-master

As you can see, you are hitting the master instance. Take down the port the
virtual router address is configured on on the master to test that you failover
to the backup:

.. code-block:: bash

 $ openstack port set $VRRP_MASTER_PORT --disable

Curl again:

.. code-block:: bash

 $ curl $VRRP_FLOATING_IP
 vrrp-backup

.. _instance-access:

***************
Instance access
***************

If you want to take a closer look at what is happening when you switch between
VRRP hosts, you need to SSH to the instances. You won't use the floating IP
associated with your virtual router, as that will be switching between
instances, which will make our SSH client unhappy. Consequently, we will assign
a floating IP to each instance for SSH access.

.. code-block:: bash

  $ openstack floating ip create --port $VRRP_MASTER_PORT public-net
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | created_at          | None                                 |
  | description         | None                                 |
  | fixed_ip_address    | 10.0.0.4                             |
  | floating_ip_address | 150.242.40.55                        |
  | floating_network_id | 849ab1e9-7ac5-4618-8801-xxxxxxxxxxxx |
  | id                  | 418211d3-2c4f-4a36-a96c-xxxxxxxxxxxx |
  | name                | 150.242.40.55                        |
  | port_id             | 6bd99608-774c-41ba-ab88-xxxxxxxxxxxx |
  | project_id          | <PROJECT_ID>     |
  | revision_number     | None                                 |
  | router_id           | 79a6c45a-abf7-4e0a-9495-xxxxxxxxxxxx |
  | status              | DOWN                                 |
  | updated_at          | None                                 |
  +---------------------+--------------------------------------+


  $ openstack floating ip create --port $VRRP_BACKUP_PORT public-net
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | created_at          | None                                 |
  | description         | None                                 |
  | fixed_ip_address    | 10.0.0.5                             |
  | floating_ip_address | 150.242.40.6                         |
  | floating_network_id | 849ab1e9-7ac5-4618-8801-xxxxxxxxxxxx |
  | id                  | f8eab0fd-1550-479f-bd6e-xxxxxxxxxxxx |
  | name                | 150.242.40.6                         |
  | port_id             | 30a60e68-8311-4098-8236-xxxxxxxxxxxx |
  | project_id          | <PROJECT_ID>     |
  | revision_number     | None                                 |
  | router_id           | 79a6c45a-abf7-4e0a-9495-xxxxxxxxxxxx |
  | status              | DOWN                                 |
  | updated_at          | None                                 |
  +---------------------+--------------------------------------+


Now you can SSH to your instances. You will connect using the default
``ubuntu`` user that is configured on Ubuntu cloud images. You will need to
substitute the correct floating IP address.

You can tail syslog in order to see what Keepalived is doing. For example, here
you can see the backup instance switch from backup to master state:

.. code-block:: bash

  $ tail -f /var/log/syslog
  Aug 26 05:17:47 vrrp-backup kernel: [ 4807.732605] IPVS: ipvs loaded.
  Aug 26 05:17:47 vrrp-backup Keepalived_vrrp[2980]: Opening file '/etc/keepalived/keepalived.conf'.
  Aug 26 05:17:47 vrrp-backup Keepalived_vrrp[2980]: Configuration is using : 60109 Bytes
  Aug 26 05:17:47 vrrp-backup Keepalived_healthcheckers[2979]: Opening file '/etc/keepalived/keepalived.conf'.
  Aug 26 05:17:47 vrrp-backup Keepalived_healthcheckers[2979]: Configuration is using : 4408 Bytes
  Aug 26 05:17:47 vrrp-backup Keepalived_vrrp[2980]: Using LinkWatch kernel netlink reflector...
  Aug 26 05:17:47 vrrp-backup Keepalived_vrrp[2980]: VRRP_Instance(vrrp_group_1) Entering BACKUP STATE
  Aug 26 05:17:47 vrrp-backup Keepalived_healthcheckers[2979]: Using LinkWatch kernel netlink reflector...
  Aug 26 05:22:21 vrrp-backup Keepalived_vrrp[2980]: VRRP_Instance(vrrp_group_1) Transition to MASTER STATE
  Aug 26 05:22:22 vrrp-backup Keepalived_vrrp[2980]: VRRP_Instance(vrrp_group_1) Entering MASTER STATE

You can also watch the VRRP traffic on the wire with this command:

.. code-block:: bash

  $ sudo tcpdump -n -i eth0 proto 112
  05:28:23.651795 IP 10.0.0.5 > 224.0.0.18: VRRPv2, Advertisement, vrid 1, prio 50, authtype simple, intvl 1s, length 20
  05:28:24.652909 IP 10.0.0.5 > 224.0.0.18: VRRPv2, Advertisement, vrid 1, prio 50, authtype simple, intvl 1s, length 20

You can see the VRRP advertisements every second.

If you bring the master port back up at this point, you will be able to see the
master node switch from the backup instance to the master instance:

.. code-block:: bash

  $ openstack port set $VRRP_MASTER_PORT --enable


on ``vrrp-backup``:

.. code-block:: bash

  $ sudo tcpdump -n -i eth0 proto 112
  05:30:11.773655 IP 10.0.0.5 > 224.0.0.18: VRRPv2, Advertisement, vrid 1, prio 50, authtype simple, intvl 1s, length 20
  05:30:11.774311 IP 10.0.0.4 > 224.0.0.18: VRRPv2, Advertisement, vrid 1, prio 100, authtype simple, intvl 1s, length 20
  05:30:12.775156 IP 10.0.0.4 > 224.0.0.18: VRRPv2, Advertisement, vrid 1, prio 100, authtype simple, intvl 1s, length 20

At this point you have successfully set up Keepalived with automatic failover
between instances. If this is all that you require for your setup, you can
stop here.

****************
Resource cleanup
****************

At this point many people will want to clean up the OpenStack resources you
have been using in this tutorial. Running the following commands should remove
all networks, routers, ports, security groups and instances. Note that the
order in which you delete resources is important.

.. code-block:: bash

  # delete the instances
  $ openstack server delete vrrp-master
  $ openstack server delete vrrp-backup

  # delete instance ports
  $ for port_id in $(openstack port list | grep 10.0.0 | grep -v 10.0.0.1 | awk '{ print $2 }'); do openstack port delete $port_id; done

  # delete router interface
  $ openstack router remove subnet vrrp-router $(openstack subnet list | grep vrrp-subnet | awk '{ print $2 }')

  # delete router
  $ openstack router delete vrrp-router

  # delete subnet
  $ openstack subnet delete vrrp-subnet

  # delete network
  $ openstack network delete vrrp-net

  # delete security group
  $ openstack security group delete vrrp-sec-group

**************************
Setup using heat templates
**************************

Up to this point in this tutorial, you have been using the Nova and Neutron
command line clients to set up our system. You have needed to run a large number
of different commands in the right order. It would be nice if you could define
the entire setup in one configuration file and ask OpenStack to create that
setup based on your blueprint.

OpenStack provides just such an orchestration system, known as Heat. In
this section, you will run Heat, in order to recreate with a single command
the stack you previously created manually.

It is beyond the scope of this tutorial to explain the syntax of writing Heat
templates, thus you will make use of a predefined example from the
cloud-orchestration repository. For more information on writing Heat templates
please consult the documentation at :ref:`cloud-orchestration`.

That said, there are a number of parts of the Heat template you should have a
look at in more detail. The template is located in the
``catalystcloud-orchestration`` repository we cloned earlier.

.. code-block:: bash

  $ cat "$ORCHESTRATION_DIR/hot/ubuntu-14.04/vrrp-basic/vrrp.yaml"

The first thing to note is the Security Group rule for VRRP traffic:

.. code-block:: yaml

  - direction: ingress
   protocol: 112
   remote_group_id:
   remote_mode: remote_group_id

Note that the ``remote_mode`` is set to ``remote_group_id`` and
``remote_group_id`` is not set. If no value is set, then the rule uses the
current security group (`heat documentation`_).

.. _heat documentation: https://docs.openstack.org/heat/latest/template_guide/openstack.html#OS::Neutron::SecurityGroup

The next code block demonstrates how to configure the port and floating IP that
will be shared between the VRRP instances.

.. code-block:: yaml

  vrrp_shared_port:
   type: OS::Neutron::Port
   properties:
     network_id: { get_resource: private_net }
     fixed_ips:
       - ip_address: { get_param: vrrp_shared_ip }

  vrrp_shared_floating_ip:
   type: OS::Neutron::FloatingIP
   properties:
     floating_network_id: { get_param: public_net_id }
     port_id: { get_resource: vrrp_shared_port }
   depends_on: router_interface

Finally, let's take a look at the Server and Port definition for an instance:

.. code-block:: yaml

  vrrp_master_server:
   type: OS::Nova::Server
   properties:
     name: vrrp-master
     image: { get_param: image }
     flavor: { get_param: servers_flavor }
     key_name: { get_param: key_name }
     user_data_format: RAW
     networks:
       - port: { get_resource: vrrp_master_server_port }
     user_data:
       get_file: vrrp-setup.sh

  vrrp_master_server_port:
   type: OS::Neutron::Port
   properties:
     network_id: { get_resource: private_net }
     allowed_address_pairs:
       - ip_address: { get_param: vrrp_shared_ip }
     fixed_ips:
       - subnet_id: { get_resource: private_subnet }
         ip_address: 10.0.0.4
     security_groups:
        - { get_resource: vrrp_secgroup }

Note the line ``user_data_format: RAW`` in the server properties; this is
required so that cloud init will setup the ``ubuntu`` user correctly (see this
`blog post`__ for details).

__ https://blog.scottlowe.org/2015/04/23/ubuntu-openstack-heat-cloud-init/

The ``allowed_address_pairs`` section associates the shared VRRP address with
the instance port. You are explicitly setting the port IP address to
``10.0.0.4``. This is not required; you are doing it in order to stay consistent
with the manual configuration. If you do not set it, you cannot control which
IPs are assigned to instances and which are assigned for DCHP. If you don't
set these, the assigned addresses will be inconsistent across Heat invocations.

This configuration is mirrored for the backup instance.

********************************************
Building the VRRP stack using heat templates
********************************************

Before we start, check that the template is valid:

.. code-block:: bash

  $ openstack orchestration template validate -t $ORCHESTRATION_DIR/hot/ubuntu-14.04/vrrp-basic/vrrp.yaml

This command will echo the yaml if it succeeds and will return an error if it
does not. Assuming the template validates, build a stack:

.. code-block:: bash

  $ openstack stack create -t $ORCHESTRATION_DIR/hot/ubuntu-14.04/vrrp-basic/vrrp.yaml vrrp-stack
  +---------------------+---------------------------------------------------------------------------------------------------+
  | Field               | Value                                                                                             |
  +---------------------+---------------------------------------------------------------------------------------------------+
  | id                  | d5096a5e-4934-490e-822b-xxxxxxxxxxxx                                                              |
  | stack_name          | vrrp-stack                                                                                        |
  | description         | HOT template for building a Keepalived/Apache VRRP stack in the Catalyst Cloud (nz-por-1) region. |
  |                     |                                                                                                   |
  | creation_time       | 2016-09-18T23:57:33Z                                                                              |
  | updated_time        | None                                                                                              |
  | stack_status        | CREATE_IN_PROGRESS                                                                                |
  | stack_status_reason | Stack CREATE started                                                                              |
  +---------------------+---------------------------------------------------------------------------------------------------+

As you can see the creation is in progress. You can use the ``openstack stack
event list`` or ``openstack stack resource list`` commands to check the
progress of the creation process:

.. code-block:: bash

  $ openstack stack event list vrrp-stack
  2016-09-19 03:20:05Z [vrrp-stack]: CREATE_IN_PROGRESS  Stack CREATE started
  2016-09-19 03:20:06Z [private_net]: CREATE_IN_PROGRESS  state changed
  2016-09-19 03:20:07Z [vrrp_secgroup]: CREATE_IN_PROGRESS  state changed
  2016-09-19 03:20:09Z [router]: CREATE_IN_PROGRESS  state changed
  2016-09-19 03:20:11Z [private_net]: CREATE_COMPLETE  state changed
  2016-09-19 03:20:11Z [vrrp_secgroup]: CREATE_COMPLETE  state changed
  2016-09-19 03:20:11Z [router]: CREATE_COMPLETE  state changed
  2016-09-19 03:20:11Z [private_subnet]: CREATE_IN_PROGRESS  state changed
  2016-09-19 03:20:14Z [private_subnet]: CREATE_COMPLETE  state changed
  2016-09-19 03:20:14Z [vrrp_master_server_port]: CREATE_IN_PROGRESS  state changed
  2016-09-19 03:20:16Z [vrrp_backup_server_port]: CREATE_IN_PROGRESS  state changed
  2016-09-19 03:20:18Z [vrrp_shared_port]: CREATE_IN_PROGRESS  state changed
  2016-09-19 03:20:19Z [router_interface]: CREATE_IN_PROGRESS  state changed
  2016-09-19 03:20:22Z [vrrp_master_server_port]: CREATE_COMPLETE  state changed
  2016-09-19 03:20:22Z [vrrp_backup_server_port]: CREATE_COMPLETE  state changed
  2016-09-19 03:20:22Z [vrrp_shared_port]: CREATE_COMPLETE  state changed
  2016-09-19 03:20:23Z [router_interface]: CREATE_COMPLETE  state changed
  2016-09-19 03:20:24Z [vrrp_master_server_floating_ip]: CREATE_IN_PROGRESS  state changed
  2016-09-19 03:20:25Z [vrrp_backup_server_floating_ip]: CREATE_IN_PROGRESS  state changed
  2016-09-19 03:20:27Z [vrrp_shared_floating_ip]: CREATE_IN_PROGRESS  state changed
  2016-09-19 03:20:28Z [vrrp_master_server]: CREATE_IN_PROGRESS  state changed
  2016-09-19 03:20:31Z [vrrp_master_server_floating_ip]: CREATE_COMPLETE  state changed
  2016-09-19 03:20:31Z [vrrp_backup_server_floating_ip]: CREATE_COMPLETE  state changed
  2016-09-19 03:20:32Z [vrrp_shared_floating_ip]: CREATE_COMPLETE  state changed
  2016-09-19 03:20:43Z [vrrp_master_server]: CREATE_COMPLETE  state changed
  2016-09-19 03:20:44Z [vrrp_backup_server]: CREATE_IN_PROGRESS  state changed
  2016-09-19 03:21:06Z [vrrp_backup_server]: CREATE_COMPLETE  state changed
  2016-09-19 03:21:06Z [vrrp-stack]: CREATE_COMPLETE  Stack CREATE completed successfully


  $ openstack stack resource list -c resource_name -c resource_type -c resource_status  vrrp-stack
  +--------------------------------+------------------------------+-----------------+
  | resource_name                  | resource_type                | resource_status |
  +--------------------------------+------------------------------+-----------------+
  | vrrp_backup_server_port        | OS::Neutron::Port            | CREATE_COMPLETE |
  | vrrp_backup_server_floating_ip | OS::Neutron::FloatingIP      | CREATE_COMPLETE |
  | vrrp_master_server             | OS::Nova::Server             | CREATE_COMPLETE |
  | router_interface               | OS::Neutron::RouterInterface | CREATE_COMPLETE |
  | vrrp_master_server_port        | OS::Neutron::Port            | CREATE_COMPLETE |
  | vrrp_master_server_floating_ip | OS::Neutron::FloatingIP      | CREATE_COMPLETE |
  | vrrp_secgroup                  | OS::Neutron::SecurityGroup   | CREATE_COMPLETE |
  | private_subnet                 | OS::Neutron::Subnet          | CREATE_COMPLETE |
  | private_net                    | OS::Neutron::Net             | CREATE_COMPLETE |
  | router                         | OS::Neutron::Router          | CREATE_COMPLETE |
  | vrrp_backup_server             | OS::Nova::Server             | CREATE_COMPLETE |
  | vrrp_shared_floating_ip        | OS::Neutron::FloatingIP      | CREATE_COMPLETE |
  | vrrp_shared_port               | OS::Neutron::Port            | CREATE_COMPLETE |
  +--------------------------------+------------------------------+-----------------+

If you prefer to create this stack in the Wellington region, you
can modify the appropriate parameters on the command line:

.. code-block:: bash

  $ OS_REGION_NAME=nz_wlg_2
  $ heat stack-create vrrp-stack --template-file $ORCHESTRATION_DIR/hot/ubuntu-14.04/vrrp-basic/vrrp.yaml /
  --parameters "public_net_id=e0ba6b88-5360-492c-9c3d-xxxxxxxxxxxx;private_net_dns_servers=202.78.240.213,202.78.240.214,202.78.240.215"

The ``stack-show`` and ``resource-list`` commands are useful commands for
viewing the state of your stack. Give them a go:

.. code-block:: bash

  $ openstack stack show vrrp-stack
  $ openstack stack resource list vrrp-stack


Once all resources in your stack are in the ``CREATE_COMPLETE`` state, you are
ready to re-run the tests as described under :ref:`vrrp-testing`. The Neutron
``floatingip-list`` command will give you the IP addresses and port IDs you
need:

.. code-block:: bash

  $ openstack floating ip list

If you wish, you can SSH to the master and backup instances as described under
:ref:`instance-access`.

Once satisfied with the configuration, you can clean up and get back to
your original state:

.. code-block:: bash

  $ openstack stack delete vrrp-stack
  Are you sure you want to delete this stack(s) [y/N]? y

This ends the tutorial on setting up hot swap VRRP instances in the Catalyst
Cloud.
