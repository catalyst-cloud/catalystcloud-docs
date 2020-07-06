export CC_PRIVATE_NETWORK=private-net
export CC_FLAVOR=c1.c1r1
export CC_IMAGE=ubuntu-20.04-x86_64
export CC_KEYPAIR=<YOUR_KEY_NAME>
export CC_SEC_GROUP_NAME=first-instance-sg
export CC_SERVERNAME=first-instance

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
