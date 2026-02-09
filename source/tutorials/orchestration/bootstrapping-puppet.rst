.. _bootstrapping-puppet-from-heat:

##############################
Bootstrapping puppet from heat
##############################

This tutorial assumes the following:

* You have created a basic network setup in Catalyst Cloud.
* You have access to a server that is acting as the Puppet Master.
* You have installed the OpenStack command line tools and sourced an
  OpenRC file, as explained at :ref:`command-line-interface`.
* You have a basic understanding of Heat templates as shown at
  :ref:`launching-your-first-instance-using-heat`.

************
Introduction
************

In this tutorial, you will see how to add a new server to an existing
Catalyst Cloud network and configure it with `Puppet`_ and have it check in to
the Puppet Master.

To achieve this, you will create a ``heat`` template that will handle the
creation of the instance and then run a nested cloud-config script via
`cloud-init`_ that will handle the provisioning of Puppet on the new server.

.. _Puppet: https://www.puppet.com/
.. _cloud-init: https://cloudinit.readthedocs.io/en/latest/index.html

*****
Setup
*****

You will make use of Heat template to deploy a single instance into an existing
network hosted in Catalyst Cloud. In order to make this work, you need to
retrieve the relevant network IDs and add them into the template.

The two networks you will be connecting to are front-end and public-net. To
find these values, you need to run the following OpenStack commands.

.. code-block:: bash

  $ openstack network list -c ID -c Name
  +--------------------------------------+------------+
  | ID                                   | Name       |
  +--------------------------------------+------------+
  | 74be55e6-b303-473c-ac1a-xxxxxxxxxxxx | mgmt-net   |
  | 849ab1e9-7ac5-4618-8801-xxxxxxxxxxxx | public-net |
  | e7adca02-5b8b-4c2e-9946-xxxxxxxxxxxx | front-end  |
  +--------------------------------------+------------+

You also need to know the ID of the front-end network subnet, in order to
create a port and assign a floating IP to the server.

.. code-block:: bash

  $ openstack subnet list -c ID -c Name
  +--------------------------------------+-------------+
  | ID                                   | Name        |
  +--------------------------------------+-------------+
  | 279a71ca-6772-4235-bbb4-xxxxxxxxxxxx | front-end   |
  | 450cb9f7-b297-40fe-a855-xxxxxxxxxxxx | mgmt-subnet |
  +--------------------------------------+-------------+

**************
Implementation
**************

This snippet ( included in the template below ) is responsible for passing
the cloud-config script puppet_bootstrap.yaml to cloud-init

.. code-block:: yaml

  user_data_format: RAW
   user_data:
    get_file: /home/user1/cloud/puppet_bootstrap.yaml

Here is the Heat template that is responsible for creating the new instance.
The network ID values found previously have been added to the relevant
parameters as defaults. It is also possible to pass these values in as
arguments from the command line, as shown `here`_.

.. _here: https://docs.openstack.org/python-openstackclient/latest/cli/plugin-commands/heat.html#stack-create


.. code-block:: yaml

  heat_template_version: 2013-05-23

  description: >
    Heat template to deploy a single server into an existing Neutron tenant
    network, assign a floating IP addresses and ensure it is accessible from
    the public network.

    It also uses a cloud-init script to bootstrap the server with Puppet.

  parameters:
    key_name:
      type: string
      description: Name of keypair to assign to servers
      default: mykey
    image:
      type: string
      description: Name of image to use for servers
      default: ubuntu-14.04-x86_64
    flavor:
      type: string
      description: Flavor to use for servers
      default: c1.c1r1
    public_net_id:
      type: string
      description: >
        ID of public network for which floating IP addresses will be allocated
      default: 849ab1e9-7ac5-4618-8801-xxxxxxxxxxxx
    private_net_id:
      type: string
      description: ID of private network into which servers get deployed
      default: e7adca02-5b8b-4c2e-9946-xxxxxxxxxxxx
    private_subnet_id:
      type: string
      description: ID of private sub network into which servers get deployed
      default: 279a71ca-6772-4235-bbb4-xxxxxxxxxxxx

  resources:
    server1:
      type: OS::Nova::Server
      properties:
        name: server1
        image: { get_param: image }
        flavor: { get_param: flavor }
        key_name: { get_param: key_name }
        networks:
          - port: { get_resource: server1_port }
        user_data_format: RAW
        user_data:
          get_file: /home/user1/cloud/puppet_bootstrap.yaml

    server1_port:
      type: OS::Neutron::Port
      properties:
        network_id: { get_param: private_net_id }
        fixed_ips:
          - subnet_id: { get_param: private_subnet_id }
        security_groups: [{ get_resource: server_security_group }]

    server1_floating_ip:
      type: OS::Neutron::FloatingIP
      properties:
        floating_network_id: { get_param: public_net_id }
        port_id: { get_resource: server1_port }

    server_security_group:
      type: OS::Neutron::SecurityGroup
      properties:
        description: Add security group rules for server
        name: security-group
        rules:
          - remote_ip_prefix: 0.0.0.0/0
            protocol: tcp
            port_range_min: 22
            port_range_max: 22
          - remote_ip_prefix: 0.0.0.0/0
            protocol: icmp

  outputs:
    server1_private_ip:
      description: IP address of server1 in private network
      value: { get_attr: [ server1, first_address ] }
    server1_public_ip:
      description: Floating IP address of server1 in public network
      value: { get_attr: [ server1_floating_ip, floating_ip_address ] }


This is the ``cloud-init`` script that is called via the ``user-data``
command. It ensures that the Puppet package is installed and sets some
basic configuration to ensure that the server can identify itself and
locate the Puppet Master.

It performs the following tasks:

* creates a host entry for the Puppet Master
* adds environment and Puppet Master server variables to puppet.conf
* runs Puppet agent with an optional 120 second wait for the certificate
  request to be signed by the Puppet Master

.. code-block:: yaml

  #cloud-config

  # This is an example of how to have Puppet agent installed and run
  # when the instance boots for the first time.
  # It needs to passed in valid YAML format to user-data when starting
  # the instance.

  # bootcmd required as it runs very early in the boot process
  # add a host entry so server can correctly identify itself
  bootcmd:
    - echo 127.0.0.1 server1.example.co.nz server1 >> /etc/hosts

  # Install additional packages on first boot
  # if packages are specified then apt_update will be set to true and run
  # first
  packages:
   - puppet

  puppet:
   # Every key present in the conf object will be added to puppet.conf:
   # [name]
   # subkey=value
    conf:
      agent:
        server: "puppet.example.co.nz"
        environment: dev

  # add Puppet Master host entry and do initial Puppet run
  runcmd:
    - echo 10.20.40.12 puppet.example.co.nz puppet >> /etc/hosts
    - puppet agent --test --server puppet.example.co.nz --waitforcert 120

  # Capture all subprocess output into a logfile
  # Useful for troubleshooting cloud-init issues
  output: {all: '| tee -a /var/log/cloud-init-output.log'}

*******************
Creating the server
*******************

To create the server, run the following Heat command. This will create a new
server called server1 in a stack named puppet-slave-stack

.. code-block:: bash

  openstack stack create -t /home/user1/cloud/puppet_slave.yaml puppet-slave-stack

Here's how to check the progress of your deployment:

.. code-block:: bash

  openstack console log show server1

**********
Final note
**********

Unless your Puppet Master is configured to automatically sign agent certificate
requests, you will need to sign your new server's cert before the first Puppet
run will complete.
