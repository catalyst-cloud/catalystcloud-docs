# Creates a router called "border-router" with a gateway to "public-net"

export CC_ROUTER_NAME=border-router
export CC_PRIVATE_NET=private-network
export CC_PRIVATE_SUBNET=private-subnet

$ openstack router create $CC_ROUTER_NAME
$ openstack router set $CC_ROUTER_NAME --external-gateway public-net
$ openstack network create $CC_PRIVATE_NET


