#!/usr/bin/env python2

import shade
import os_client_config

# Name variables
name_prefix = ''
private_network_name = name_prefix + 'private-net'
private_subnet_name = name_prefix + 'private-subnet'
router_name = name_prefix + 'router'
security_group_name = name_prefix + 'sg'
keypair_name = name_prefix + 'keypair'
instance_name = name_prefix + 'instance'

# Toggle Debug logging
shade.simple_logging(debug=False)


def delete_all_resources():

    # delete instances
    for server in cloud.list_servers():
        if server.name == instance_name:
            print('Deleting instance {} ({})'.format(server.name, server.id))
            cloud.delete_server(server.id, wait=True)

    # delete keypairs
    for keypair in cloud.list_keypairs():
        if keypair.name == keypair_name:
            print('Deleting keypair {} ({})'.format(
                keypair.name,
                keypair.fingerprint,
            ))
            cloud.delete_keypair(keypair_name)

    # delete security groups
    for security_group in cloud.list_security_groups(filters={'name': security_group_name}):
        print('Deleting security group {} ({})'.format(
            security_group.name,
            security_group.id,
        ))
        cloud.delete_security_group(security_group.id)

    # delete routers and any associated networks
    for router in cloud.list_routers(filters={'name': router_name}):
        for interface in cloud.list_router_interfaces(router, interface_type=None):
            private_network = cloud.get_network(interface.network_id)
            print('Deleting inteface with id {}'.format(interface.id))
            cloud.remove_router_interface(router, port_id=interface.id)
            print('Deleting network {} ({})'.format(
                private_network.name,
                private_network.id,
            ))
            cloud.delete_network(private_network.id)
        print('Deleting router {} ({})'.format(router.name, router.id))
        cloud.delete_router(router.id)

    # delete any orphan networks
    for private_network in cloud.list_networks(filters={'name': private_network_name}):
        print('Deleting network {} ({})'.format(
            private_network.name,
            private_network.id,
        ))
        cloud.delete_network(private_network.id)


if __name__ == '__main__':

    cloud = shade.openstack_cloud()
    delete_all_resources()
