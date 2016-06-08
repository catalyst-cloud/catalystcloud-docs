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
IMAGE_NAME="ubuntu-14.04-x86_64"

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

# check the required commands are available
hash neutron 2>/dev/null || {
    echo "Neutron command line client is not available, please install it before proceeding";
    EXIT=1;
}

hash glance 2>/dev/null || {
    echo "Glance command line client is not available, please install it before proceeding";
    EXIT=1;
}

hash nova 2>/dev/null || {
    echo "Nova command line client is not available, please install it before proceeding";
    EXIT=1;
}

hash curl 2>/dev/null || {
    echo "Curl command line client is not available, please install it before proceeding";
    EXIT=1;
}

# Checks
SSH_PUBLIC_KEY=~/.ssh/id_rsa.pub
if [ ! -f $SSH_PUBLIC_KEY ]; then
    SSH_PUBLIC_KEY=~/.ssh/id_dsa.pub
fi
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
else
    echo "OS_REGION_NAME does not point at a valid region";
    EXIT=1;
fi;

# check that resources do not already exist
if nova list | grep -q "$INSTANCE_NAME"; then
    echo "instance $INSTANCE_NAME exists, please delete all first instance resources before running this script";
    EXIT=1;
fi

if neutron router-list | grep -q "$ROUTER_NAME"; then
    echo "router $ROUTER_NAME exists, please delete all first instance resources before running this script";
    EXIT=1;
fi

if neutron subnet-list | grep -q "$PRIVATE_SUBNET_NAME"; then
    echo "subnet $PRIVATE_SUBNET_NAME exists, please delete all first instance resources before running this script";
    EXIT=1;
fi

if neutron net-list | grep -q "$PRIVATE_NETWORK_NAME"; then
    echo "network $PRIVATE_NETWORK_NAME exists, please delete all first instance resources before running this script";
    EXIT=1;
fi

if neutron security-group-list | grep -q "$SECURITY_GROUP_NAME"; then
    echo "security group $SECURITY_GROUP_NAME exists, please delete all first instance resources before running this script";
    EXIT=1;
fi

if nova keypair-list | grep -q "$SSH_KEY_NAME"; then
    echo "keypair $SSH_KEY_NAME exists, please delete all first instance resources before running this script";
    EXIT=1;
fi

if [ "$EXIT" -eq 1 ]; then
    exit 1;
fi

echo finding your external ip:
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
CC_REMOTE_CIDR_NETWORK="$CC_REMOTE_IP/32"

# everything is in order, lets build a stack!
echo creating a new router:
neutron router-create $ROUTER_NAME

echo setting gateway:
neutron router-gateway-set $ROUTER_NAME public-net

echo creating a new private network:
neutron net-create $PRIVATE_NETWORK_NAME

echo creating a private subnet:
neutron subnet-create \
--name $PRIVATE_SUBNET_NAME \
--allocation-pool start="$NETWORK.$POOL_START_OCT",end="$NETWORK.$POOL_END_OCT" \
--dns-nameserver $CC_NAMESERVER_1 \
--dns-nameserver $CC_NAMESERVER_2 \
--dns-nameserver $CC_NAMESERVER_3 \
--enable-dhcp \
$PRIVATE_NETWORK_NAME \
"$NETWORK.0/24"

echo creating a router interface on the subnet:
neutron router-interface-add $ROUTER_NAME $PRIVATE_SUBNET_NAME

echo selecting a flavour:
CC_FLAVOR_ID=$( nova flavor-list | grep $FLAVOR_NAME | awk '{ print $2 }' )

echo selecting an image:
CC_IMAGE_ID=$( glance image-list --name $IMAGE_NAME | grep $IMAGE_NAME | awk '{ print $2 }' )

echo uploading a key:
nova keypair-add --pub-key $SSH_PUBLIC_KEY $SSH_KEY_NAME

echo getting network ids:
CC_PUBLIC_NETWORK_ID=$( neutron net-list | grep public-net | awk '{ print $2 }' )
CC_PRIVATE_NETWORK_ID=$( neutron net-list | grep $PRIVATE_NETWORK_NAME | awk '{ print $2 }' )

echo creating security group:
neutron security-group-create --description 'Network access for our first instance.' $SECURITY_GROUP_NAME

echo getting security group id:
CC_SECURITY_GROUP_ID=$(neutron security-group-list | grep "$SECURITY_GROUP_NAME" | awk '{ print $2 }' )

echo creating security group rule for ssh access:
neutron security-group-rule-create --direction ingress --protocol tcp --port-range-min 22 --port-range-max 22 \
--remote-ip-prefix "$CC_REMOTE_CIDR_NETWORK" "$CC_SECURITY_GROUP_ID"

echo booting first instance:
nova boot --flavor "$CC_FLAVOR_ID" --image "$CC_IMAGE_ID" --key-name "$SSH_KEY_NAME" \
--security-groups default,"$SECURITY_GROUP_NAME" --nic net-id="$CC_PRIVATE_NETWORK_ID" "$INSTANCE_NAME"

instance_status=$(nova show "$INSTANCE_NAME" | grep status | awk '{ print $4 }')

until [ "$instance_status" == 'ACTIVE' ]
do
    instance_status=$(nova show "$INSTANCE_NAME" | grep status | awk '{ print $4 }')
    sleep 2;
done

echo getting floating ip id:
CC_FLOATING_IP_ID=$( neutron floatingip-list -c status -c floating_ip_address -c id | grep DOWN | head -1 | awk '{ print $6 }' )
if [ -z "$CC_FLOATING_IP_ID" ]; then
    echo no floating ip found creating a floating ip:
    neutron floatingip-create "$CC_PUBLIC_NETWORK_ID"
    echo getting floating ip id:
    CC_FLOATING_IP_ID=$( neutron floatingip-list -c status -c floating_ip_address -c id | grep DOWN | head -1 | awk '{ print $6 }' )
fi

echo getting public ip:
CC_PUBLIC_IP=$( neutron floatingip-list -c floating_ip_address -c id | grep "$CC_FLOATING_IP_ID" | awk '{ print $2 }' )

echo getting instance port id:
CC_PORT_ID=$( nova interface-list "$INSTANCE_NAME" | grep "$CC_PRIVATE_NETWORK_ID" | awk '{ print $4 }' )

neutron floatingip-associate "$CC_FLOATING_IP_ID" "$CC_PORT_ID"

echo you can now connect to your instance using the following command:
echo "ssh ubuntu@$CC_PUBLIC_IP"
