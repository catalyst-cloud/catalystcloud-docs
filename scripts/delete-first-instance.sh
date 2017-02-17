#!/bin/bash

# VARS, change these if required
# Set a prefix if you wish all names to have a unique prefix
#PREFIX='myprefix-'
PREFIX=''
ROUTER_NAME="${PREFIX}border-router"
PRIVATE_NETWORK_NAME="${PREFIX}private-net"
SSH_KEYPAIR_NAME="${PREFIX}first-instance-key"
INSTANCE_NAME="${PREFIX}first-instance"
SECURITY_GROUP_NAME="${PREFIX}first-instance-sg"

echo Deleting instance.
openstack server delete $INSTANCE_NAME

echo Deleting router interface.
openstack router remove port $ROUTER_NAME "$( openstack port list -f value -c ID --router $ROUTER_NAME )"

echo Deleting router.
openstack router delete $ROUTER_NAME

echo Deleting network.
openstack network delete $PRIVATE_NETWORK_NAME

echo Deleting security group.
openstack security group delete $SECURITY_GROUP_NAME

echo Deleting ssh keypair.
openstack keypair delete $SSH_KEYPAIR_NAME
