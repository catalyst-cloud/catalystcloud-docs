#!/bin/bash

# VARS, change these if required
# Set a prefix if you wish all names to have a unique prefix
#PREFIX='myprefix-'
PREFIX=''
ROUTER_NAME="${PREFIX}border-router"
PRIVATE_NETWORK_NAME="${PREFIX}private-net"
PRIVATE_SUBNET_NAME="${PREFIX}private-subnet"
SSH_KEY_NAME="${PREFIX}first-instance-key"
INSTANCE_NAME="${PREFIX}first-instance"
SECURITY_GROUP_NAME="${PREFIX}first-instance-sg"
# Network portion of /24 you wish to use in the subnet
NETWORK="10.0.0"

echo delete the instances:
nova delete $INSTANCE_NAME

echo delete instance ports:
for port_id in $(neutron port-list | grep $NETWORK | grep -v "$NETWORK.1\"" | awk '{ print $2 }'); do
    neutron port-delete "$port_id";
done

echo delete router interface:
neutron router-interface-delete $ROUTER_NAME "$(neutron subnet-list | grep $PRIVATE_SUBNET_NAME | awk '{ print $2 }')"

echo delete router:
neutron router-delete $ROUTER_NAME

echo delete subnet:
neutron subnet-delete $PRIVATE_SUBNET_NAME

echo delete network:
neutron net-delete $PRIVATE_NETWORK_NAME

echo delete security group:
neutron security-group-delete $SECURITY_GROUP_NAME

echo delete ssh key:
nova keypair-delete $SSH_KEY_NAME
