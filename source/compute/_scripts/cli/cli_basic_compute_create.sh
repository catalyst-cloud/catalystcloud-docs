export CC_PRIVATE_NETWORK=private-net
export CC_FLAVOR=c1.c1r1
export CC_IMAGE=ubuntu-20.04-x86_64
export CC_KEYPAIR=<YOUR_KEY_NAME>
export CC_SEC_GROUP_NAME=first-instance-sg
export CC_SERVERNAME=first-instance
export CC_PUBLIC_NETWORK_ID=f10ad6de-a26d-4c29-8c64-xxxxxxxxxxxx

$ openstack security group create $CC_SEC_GROUP_NAME

$ openstack security group rule create \
--remote-ip 0.0.0.0/0 \
--ethertype ipv4 \
--protocol tcp \
--ingress \
--dst-port 22 \
$CC_SEC_GROUP_NAME

$ openstack server create --flavor $CC_FLAVOR \
--image $CC_IMAGE \
--key-name $CC_KEYPAIR \
--security-group default \
--security-group first-instance-sg \
--network $CC_PRIVATE_NETWORK  \
--boot-from-volume 10 \
$CC_SERVERNAME

$ openstack floating ip create $CC_PUBLIC_NETWORK_ID

$ export CC_FLOATING_IP_ID=$( openstack floating ip list -f value | grep -m 1 'None None' | awk '{ print $1 }' )
$ export CC_PUBLIC_IP=$( openstack floating ip show $CC_FLOATING_IP_ID -f value -c floating_ip_address )

$ openstack server add floating ip first-instance $CC_PUBLIC_IP
