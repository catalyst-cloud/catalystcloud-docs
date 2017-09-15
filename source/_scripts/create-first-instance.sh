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
POOL_START_OCT="10"
POOL_END_OCT="200"
FLAVOR_NAME="c1.c1r1"
IMAGE_NAME="ubuntu-16.04-x86_64"
SSH_PUBLIC_KEY=~/.ssh/id_rsa.pub

# valid ip function
valid_ip() {
    regex="\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b"
    echo "$1" | egrep "$regex" &>/dev/null
    return $?
}

# Var so we can exit if required after all checks
EXIT=0;

# Check the required OS_ env vars exist
if [ -z "$OS_REGION_NAME" ]; then
    echo OS_REGION_NAME not set please ensure you have sourced an OpenStack RC file.
    EXIT=1;
fi

if [ -z "$OS_AUTH_URL" ]; then
    echo OS_AUTH_URL not set please ensure you have sourced an OpenStack RC file.
    EXIT=1;
fi

if [ -z "$OS_TENANT_NAME" ]; then
    echo OS_TENANT_NAME not set please ensure you have sourced an OpenStack RC file.
    EXIT=1;
fi

if [ -z "$OS_USERNAME" ]; then
    echo OS_USERNAME not set please ensure you have sourced an OpenStack RC file.
    EXIT=1;
fi

if [ -z "$OS_PASSWORD" ]; then
    echo OS_PASSWORD not set please ensure you have sourced an OpenStack RC file.
    EXIT=1;
fi

# check the openstack command is available
hash openstack 2>/dev/null || {
    echo "Openstack command line client is not available, please install it before proceeding";
    EXIT=1;
}

# Checks
if [ ! -f $SSH_PUBLIC_KEY ]; then
    echo "Cannot find an ssh public key, please set SSH_PUBLIC_KEY to point at a valid key";
    EXIT=1;
fi

if [[ $OS_REGION_NAME == "nz_wlg_2" ]]; then
    CC_NAMESERVER_1=202.78.240.213
    CC_NAMESERVER_2=202.78.240.214
    CC_NAMESERVER_3=202.78.240.215
elif [[ $OS_REGION_NAME == "nz-por-1" ]]; then
    CC_NAMESERVER_1=202.78.247.197
    CC_NAMESERVER_2=202.78.247.198
    CC_NAMESERVER_3=202.78.247.199
elif [[ $OS_REGION_NAME == "nz-hlz-1" ]]; then
    CC_NAMESERVER_1=202.78.244.85
    CC_NAMESERVER_2=202.78.244.86
    CC_NAMESERVER_3=202.78.244.87
else
    echo "OS_REGION_NAME does not point at a valid region";
    EXIT=1;
fi;

# check that resources do not already exist
if openstack server list | grep -q "$INSTANCE_NAME"; then
    echo "Instance $INSTANCE_NAME exists, please delete all first instance resources before running this script";
    EXIT=1;
fi

if openstack router list | grep -q "$ROUTER_NAME"; then
    echo "Router $ROUTER_NAME exists, please delete all first instance resources before running this script";
    EXIT=1;
fi

if openstack subnet list | grep -q "$PRIVATE_SUBNET_NAME"; then
    echo "Subnet $PRIVATE_SUBNET_NAME exists, please delete all first instance resources before running this script";
    EXIT=1;
fi

if openstack network list | grep -q "$PRIVATE_NETWORK_NAME"; then
    echo "Network $PRIVATE_NETWORK_NAME exists, please delete all first instance resources before running this script";
    EXIT=1;
fi

if openstack security group list | grep -q "$SECURITY_GROUP_NAME"; then
    echo "Security group $SECURITY_GROUP_NAME exists, please delete all first instance resources before running this script";
    EXIT=1;
fi

if openstack keypair list | grep -q "$SSH_KEY_NAME"; then
    echo "Keypair $SSH_KEY_NAME exists, please delete all first instance resources before running this script";
    EXIT=1;
fi

if [ "$EXIT" -eq 1 ]; then
    exit 1;
fi

echo Finding your external ip:
hash dig 2>/dev/null && {
    CC_REMOTE_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
}
for curl_ip in http://ipinfo.io/ip http://ifconfig.me/ip http://curlmyip.com; do
    CC_REMOTE_IP=$( curl -s $curl_ip )
    if valid_ip "$CC_REMOTE_IP"; then
        break
    fi
done

if ! valid_ip "$CC_REMOTE_IP"; then
    echo "Could not determine your external IP address, please find it and edit CC_REMOTE_IP before proceeding";
    exit 1;
fi
echo "$CC_REMOTE_IP"
CC_REMOTE_CIDR_NETWORK="$CC_REMOTE_IP/32"

# everything is in order, lets build a stack!
echo Creating a new router:
openstack router create $ROUTER_NAME

echo Setting router gateway.
openstack router set $ROUTER_NAME --external-gateway public-net

echo Creating a new private network:
openstack network create "$PRIVATE_NETWORK_NAME"

echo Creating a private subnet:
openstack subnet create \
--allocation-pool "start=${NETWORK}.${POOL_START_OCT},end=${NETWORK}.${POOL_END_OCT}" \
--dns-nameserver "$CC_NAMESERVER_1" \
--dns-nameserver "$CC_NAMESERVER_2" \
--dns-nameserver "$CC_NAMESERVER_3" \
--dhcp \
--network "$PRIVATE_NETWORK_NAME" \
--subnet-range "$NETWORK.0/24" \
"$PRIVATE_SUBNET_NAME" \

echo Creating a router interface on the subnet.
openstack router add subnet "$ROUTER_NAME" "$PRIVATE_SUBNET_NAME"

echo Selecting a flavour.
CC_FLAVOR_ID=$( openstack flavor show "$FLAVOR_NAME" -f value -c id )

echo Selecting an image.
CC_IMAGE_ID=$( openstack image show "$IMAGE_NAME" -f value -c id )

echo Uploading a key:
openstack keypair create --public-key $SSH_PUBLIC_KEY $SSH_KEY_NAME

echo Getting network ids.
CC_PUBLIC_NETWORK_ID=$( openstack network show public-net -f value -c id )
CC_PRIVATE_NETWORK_ID=$( openstack network show "$PRIVATE_NETWORK_NAME" -f value -c id )

echo Creating security group:
openstack security group create --description 'Network access for our first instance.' $SECURITY_GROUP_NAME

echo Getting security group id.
CC_SECURITY_GROUP_ID=$( openstack security group show "$SECURITY_GROUP_NAME" -f value -c id )

echo Creating security group rule for ssh access:
openstack security group rule create \
--ingress \
--protocol tcp \
--dst-port 22 \
--remote-ip "$CC_REMOTE_CIDR_NETWORK" \
"$CC_SECURITY_GROUP_ID"

echo Booting first instance:
openstack server create \
--flavor "$CC_FLAVOR_ID" \
--image "$CC_IMAGE_ID" \
--key-name "$SSH_KEY_NAME" \
--security-group default \
--security-group "$SECURITY_GROUP_NAME" \
--nic "net-id=$CC_PRIVATE_NETWORK_ID" \
"$INSTANCE_NAME"

INSTANCE_STATUS=$( openstack server show "$INSTANCE_NAME" -f value -c status )

until [ "$INSTANCE_STATUS" == 'ACTIVE' ]
do
    INSTANCE_STATUS=$( openstack server show "$INSTANCE_NAME" -f value -c status )
    sleep 2;
done

echo Getting floating ip id.
CC_FLOATING_IP_ID=$( openstack floating ip list -f value -c ID --status 'DOWN' | head -n 1 )
if [ -z "$CC_FLOATING_IP_ID" ]; then
    echo No floating ip found creating a floating ip:
    openstack floating ip create "$CC_PUBLIC_NETWORK_ID"
    echo Getting floating ip id:
    CC_FLOATING_IP_ID=$( openstack floating ip list -f value -c ID --status 'DOWN' | head -n 1 )
fi

echo Getting public ip.
CC_PUBLIC_IP=$( openstack floating ip show "$CC_FLOATING_IP_ID" -f value -c floating_ip_address )

echo Associating floating ip with instance.
openstack server add floating ip "$INSTANCE_NAME" "$CC_PUBLIC_IP"

echo You can now connect to your instance using the following command:
echo "ssh ubuntu@$CC_PUBLIC_IP"
