####################################################################
Creating an instance with interfaces on different networks with Heat
####################################################################

This tutorial assumes the following:

* You have created a basic network setup in Catalyst Cloud.
* You have installed the OpenStack command line tools and sourced an
  openrc file, as explained at :ref:`command-line-interface`.
* You have a basic understanding of Heat templates as shown at
  :ref:`launching-your-first-instance-using-heat`.

************
Introduction
************

In this tutorial, you will find out how to create an additional network in a
project that already has a private network, and then create a server that has
interfaces on the existing private network and the newly created one.

You will need to delve into the mysteries of 'cloud-init' a little to achieve
this. You'll also learn how to perform another useful customisation -
changing who the default user is for an instance.

*************
Heat template
*************

We need to create a network, and a subnet - and then boot an instance using
these plus an already existing private network. Unfortunately, it is not
sufficient simply to create networks and provide these to the instance at
creation time - only the first network is properly configured if this approach
is taken (this could be viewed as a bug). This can be worked around using the
the user_data property along with cloud-init:

.. code-block:: yaml

  #
  # Deploying a network and a compute instance using Heat
  #
  heat_template_version: 2013-05-23

  description: >
    Deploying new network, subnet and a server using Heat.

  parameters:
    key_name:
      type: string
      description: Name of an existing key pair to use for the server
      default: your-user-key
      constraints:
        - custom_constraint: nova.keypair
    flavor:
      type: string
      description: Flavor for the server to be created
      default: c1.c2r2
      constraints:
        - custom_constraint: nova.flavor
    image:
      type: string
      description: Image ID or image name to use for the server
      default: ubuntu-14.04-x86_64
      constraints:
        - custom_constraint: glance.image
    user:
      type: string
      description: Default user
      default: myuser
    net1:
      type: string
      description: (existing) network for the server to be created
      default: private-net1
      constraints:
        - custom_constraint: neutron.network
    net2:
      type: string
      description: (New) network for the server to be created
      default: private-net2
    subnetcidr:
      type: string
      description: Subnet cidr
      default: 10.0.99.0/24
    subnetstart:
      type: string
      description: Start of subnet address
      default: 10.0.99.10
    subnetend:
      type: string
      description: End of subnet address
      default: 10.0.99.100

  resources:
    private_net:
      type: OS::Neutron::Net
      properties:
        name: { get_param: net2 }
    private_subnet:
      type: OS::Neutron::Subnet
      properties:
        name: { get_param: net2 }
        network_id: { get_resource: private_net }
        cidr: { get_param: subnetcidr }
        allocation_pools:
          - start: { get_param: subnetstart }
            end: { get_param:  subnetend }

    server:
      type: OS::Nova::Server
      properties:
        name: server1
        key_name: { get_param: key_name }
        image: { get_param: image }
        flavor: { get_param: flavor }
        networks:
          - network: {get_param: net1}
          - network: {get_resource: private_net}
        user_data:
          str_replace:
            template: |
              #cloud-config
              bootcmd:
               - "ifdir='/etc/network/interfaces.d'; for iface in $(ip -o link | cut -d: -f2 | tr -d ' ' | grep ^eth); do if [ ! -e ${ifdir}'/'${iface}'.cfg' ]; then echo 'Creating iface file for '${iface}; echo 'auto '${iface}'\niface '${iface}' inet dhcp\n' > $ifdir'/'$iface'.cfg'; ifup ${iface}; fi; done"
              runcmd:
               - "echo 'Complete' > /var/log/cloud-init-complete.txt"
              system_info:
                default_user:
                  name: $USER
                  shell: /bin/bash
            params:
             $USER: {get_param: user}
        user_data_format: RAW

  outputs:
    server_networks:
      description: The networks of the deployed server
      value: { get_attr: [server, networks] }
