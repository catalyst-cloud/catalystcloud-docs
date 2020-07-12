export CC_SEC_GROUP_NAME=first-instance-sg
export CC_SERVERNAME=first-instance
export CC_PUBLIC_NETWORK_ID=e0ba6b88-5360-492c-9c3d-119948356fd3

# Porirua public net = 849ab1e9-7ac5-4618-8801-e6176fbbcf30
# Hamilton public net = f10ad6de-a26d-4c29-8c64-2a7418d47f8f
# Wellington public net = e0ba6b88-5360-492c-9c3d-119948356fd3

$ openstack security group create $CC_SEC_GROUP_NAME

$ openstack security group rule create \
--remote-ip 0.0.0.0/0 \
--ethertype ipv4 \
--protocol tcp \
--ingress \
--dst-port 22 \
$CC_SEC_GROUP_NAME

$ openstack server create --flavor $CC_FLAVOR_ID \
--image $CC_IMAGE_ID \
--key-name $CC_KEY_NAME \
--security-group default \
--security-group first-instance-sg \
--network $CC_PRIVATE_NET  \
--boot-from-volume 10 \
$CC_SERVERNAME

$ openstack floating ip create $CC_PUBLIC_NETWORK_ID

$ export CC_FLOATING_IP_ID=$( openstack floating ip list -f value | grep -m 1 'None None' | awk '{ print $1 }' )
$ export CC_PUBLIC_IP=$( openstack floating ip show $CC_FLOATING_IP_ID -f value -c floating_ip_address )

$ openstack server add floating ip first-instance $CC_PUBLIC_IP
