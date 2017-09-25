#!/usr/bin/env python2

import shade
import os_client_config
import os
from subprocess import check_output
import socket

# Variables that you may wish to change
network_prefix = '10.10.0'
# add a string like foo- in order to add a prefix to all named resources
name_prefix = ''
image_name = 'ubuntu-16.04-x86_64'
flavor_name = 'c1.c1r1'
# Variables that you are less likely to wish to change
private_network_name = name_prefix + 'private-net'
private_subnet_name = name_prefix + 'private-subnet'
router_name = name_prefix + 'router'
security_group_name = name_prefix + 'sg'
instance_name = name_prefix + 'instance'
keypair_name = name_prefix + 'keypair'
pub_key_file = os.environ['HOME'] + '/.ssh/id_rsa.pub'
restricted_cidr_range = '0.0.0.0/32'

# set restricted_cidr_range to our external address if we can
# comment the following block if you wish to hard code a CIDR range
try:
    external_ip = check_output(
        ['dig', '+short', 'myip.opendns.com', '@resolver1.opendns.com']
    ).rstrip()
    try:
        socket.inet_aton(external_ip)
        restricted_cidr_range = external_ip + '/32'
    except socket.error:
        pass
except:
    pass

# Toggle Debug logging
shade.simple_logging(debug=True)

# Toggel Dump resources
dump_resources = True


def create_resources(config):

    # Create the private network
    private_network = cloud.create_network(private_network_name)
    dump(private_network)

    # Create the private subnet
    network_cidr = network_prefix + '.0/24'
    network_allocations = [
        {
            "start": network_prefix + '.10',
            "end": network_prefix + '.100',
        }
    ]
    nameserver_lookup = {
        'nz-por-1': ['202.78.247.197', '202.78.247.198', '202.78.247.199'],
        'nz_wlg_2': ['202.78.240.213', '202.78.240.214', '202.78.240.215'],
        'nz-hlz-1': ['202.78.244.85', '202.78.244.86', '202.78.244.87'],
    }
    network_dns = nameserver_lookup[config['region_name']]
    private_subnet = cloud.create_subnet(
        private_network_name,
        cidr=network_cidr,
        subnet_name=private_subnet_name,
        allocation_pools=network_allocations,
        dns_nameservers=network_dns,
        enable_dhcp=True,
    )
    dump(private_subnet)

    # Find the external net
    external_net = cloud.get_network('public-net')

    # Create the router
    router = cloud.create_router(
        name=router_name,
        ext_gateway_net_id=external_net.id,
    )
    dump(router)
    private_router_interface = cloud.add_router_interface(
        router,
        subnet_id=private_subnet.id,
    )

    # Create a security group
    security_group = cloud.create_security_group(
        security_group_name,
        'First instance security group',
    )
    # Add a rule for SSH ingress
    cloud.create_security_group_rule(
        security_group.id,
        protocol='tcp',
        port_range_min=22,
        port_range_max=22,
        remote_ip_prefix=restricted_cidr_range,
    )

    # Upload a public key for SSH access
    public_key = open(pub_key_file).read()
    cloud.create_keypair(keypair_name, public_key)

    # Get the flavour for this region
    flavor = cloud.get_flavor(flavor_name)

    # Get the image id in this region
    image = cloud.get_image(image_name)

    # Create the instance
    server = cloud.create_server(
        name=instance_name,
        image=image.id,
        wait=True,
        auto_ip=False,
        flavor=flavor.id,
        security_groups=[security_group.id, 'default'],
        network=private_network.id,
        key_name=keypair_name,
    )
    dump(server)

    # Assign a floating ip to the server
    floating_ip_address = cloud.add_auto_ip(
        server,
        wait=True,
    )

    print('Access your server at ubuntu@{}'.format(
        floating_ip_address,
    ))


def dump(data):
    """Pretty Dump the data"""

    if dump_resources:
        cloud.pprint(data)


if __name__ == '__main__':

    cloud_config = os_client_config.OpenStackConfig().get_one_cloud()
    cloud = os_client_config.make_shade()
    dump(cloud_config.config)

    create_resources(cloud_config.config)
