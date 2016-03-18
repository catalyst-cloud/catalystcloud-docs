#!/bin/bash

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

if [ "$EXIT" -eq 1 ]; then
    exit 1;
fi

region='both'
prompt="Selection:"
options=("Wellington" "Porirua" "Both")

echo "---------------------------------------------"
echo "This script will setup a VPN in your project."
echo "You can select either one or both regions."
echo "If you select both regions this script will"
echo "setup a site to site VPN for you."
echo "---------------------------------------------"
echo "Please select the region(s):"
echo
PS3="$prompt "
select opt in "${options[@]}"; do

    case "$REPLY" in

    1 ) region='wlg';break;;
    2 ) region='por';break;;
    3 ) region='both';break;;

    *) echo "Invalid option. Please select 1, 2 or 3.";continue;;

    esac

done

echo

if [[ $region == "wlg" || $region == "both" ]]
then
    OS_REGION_NAME="nz_wlg_2"
    echo "Please enter the name of your Wellington router:";
    read -r wlg_router_name;
    if neutron router-show "$wlg_router_name" 2>&1 /dev/null | grep -q 'Unable to find router with name'
    then
        echo "Unable to find router with name $wlg_router_name"
        echo please ensure you have created the required routers before running this script
        exit;
    fi

    echo "Please enter the name of your Wellington subnet:";
    read -r wlg_subnet_name;
    if neutron subnet-show "$wlg_subnet_name" 2>&1 /dev/null | grep -q 'Unable to find subnet with name'
    then
        echo "Unable to find subnet with name $wlg_subnet_name"
        echo please ensure you have created the required subnets before running this script
        exit;
    fi
    wlg_router_id=$( neutron router-show "$wlg_router_name" -f shell --variable id | awk -F '"' '{ print $2 }' )
    wlg_subnet_id=$( neutron subnet-show "$wlg_subnet_name" -f shell --variable id | awk -F '"' '{ print $2 }' )
    wlg_router_ip=$( neutron router-show "$wlg_router_name" | grep external_gateway_info | awk -F'|' '{ print $3 }' | jq -r '.external_fixed_ips[0].ip_address' )
    wlg_subnet=$( neutron subnet-show "$wlg_subnet_name" -f shell --variable cidr | awk -F '"' '{ print $2 }' )
fi

if [[ $region == "por" || $region == "both" ]]
then
    OS_REGION_NAME="nz-por-1"
    echo "Please enter the name of your Porirua router:";
    read -r por_router_name;
    if neutron router-show "$por_router_name" 2>&1 /dev/null | grep -q 'Unable to find router with name'
    then
        echo "Unable to find router with name $por_router_name"
        echo please ensure you have created the required routers before running this script
        exit;
    fi

    echo "Please enter the name of your Porirua subnet:";
    read -r por_subnet_name;
    if neutron subnet-show "$por_subnet_name" 2>&1 /dev/null | grep -q 'Unable to find subnet with name'
    then
        echo "Unable to find subnet with name $por_subnet_name"
        echo please ensure you have created the required subnets before running this script
        exit;
    fi
    por_router_id=$( neutron router-show "$por_router_name" -f shell --variable id | awk -F '"' '{ print $2 }' )
    por_subnet_id=$( neutron subnet-show "$por_subnet_name" -f shell --variable id | awk -F '"' '{ print $2 }' )
    por_router_ip=$( neutron router-show "$por_router_name" | grep external_gateway_info | awk -F'|' '{ print $3 }' | jq -r '.external_fixed_ips[0].ip_address' )
    por_subnet=$( neutron subnet-show "$por_subnet_name" -f shell --variable cidr | awk -F '"' '{ print $2 }' )
fi

tenant_id=$( nova credentials --wrap 200 | grep tenant | awk -F'|' '{ print $3 }' | jq -r '.id' )
echo "Please enter you pre shared key:";
read -r pre_shared_key;

if [[ $region == "wlg" ]]
then
    echo "Please enter the peer router ip address";
    read -r wlg_peer_router_ip;
    echo "Please enter the peer CIDR range";
    read -r wlg_peer_subnet;
elif [[ $region == "por" ]]
then
    echo "Please enter the peer router ip address";
    read -r por_peer_router_ip;
    echo "Please enter the peer CIDR range";
    read -r por_peer_subnet;
elif [[ $region == "both" ]]
then
    por_peer_router_ip=$wlg_router_ip
    por_peer_subnet=$wlg_subnet
    wlg_peer_router_ip=$por_router_ip
    wlg_peer_subnet=$por_subnet
fi

echo --------------------------------------------------------
echo Proceeding to create VPN with the following credentials:

if [[ $region == "por" || $region == "both" ]]
then
    echo "por_router_id = $por_router_id"
    echo "por_subnet_id = $por_subnet_id"
    echo "por_router_ip = $por_router_ip"
    echo "por_subnet = $por_subnet"
    echo "por_peer_router_ip = $wlg_router_ip"
    echo "por_peer_subnet = $wlg_subnet"
fi
if [[ $region == "wlg" || $region == "both" ]]
then
    echo "wlg_router_id = $wlg_router_id"
    echo "wlg_subnet_id = $wlg_subnet_id"
    echo "wlg_router_ip = $wlg_router_ip"
    echo "wlg_subnet = $wlg_subnet"
    echo "wlg_peer_router_ip = $por_router_ip"
    echo "wlg_peer_subnet = $por_subnet"
fi
echo "tenant_id = $tenant_id"
echo "pre_shared_key = XXXXXXXXXXXXXXXXXXX"
echo --------------------------------------------------------

if [[ $region == "por" || $region == "both" ]]
then
    OS_REGION_NAME="nz-por-1"

    neutron vpn-service-create \
        --name "VPN" \
        --tenant-id "$tenant_id" \
        "$por_router_id" "$por_subnet_id"

    neutron vpn-ikepolicy-create \
        --tenant-id "$tenant_id" \
        --auth-algorithm sha1 \
        --encryption-algorithm aes-256 \
        --phase1-negotiation-mode main \
        --ike-version v1 \
        --pfs group5 \
        --lifetime units=seconds,value=28800 \
        "IKE Policy"

    neutron vpn-ipsecpolicy-create \
        --tenant-id "$tenant_id" \
        --transform-protocol esp \
        --auth-algorithm sha1 \
        --encryption-algorithm aes-256 \
        --encapsulation-mode tunnel \
        --pfs group5 \
        --lifetime units=seconds,value=3600 \
        "IPsec Policy"

    por_vpnservice_id=$( neutron vpn-service-list | grep VPN | awk '{ print $2 }' )
    por_ikepolicy_id=$( neutron vpn-ikepolicy-list | grep 'IKE Policy' | awk '{ print $2 }' )
    por_ipsecpolicy_id=$( neutron vpn-ipsecpolicy-list | grep 'IPsec Policy' | awk '{ print $2 }' )

    neutron ipsec-site-connection-create \
        --tenant-id "$tenant_id" \
        --name  "VPN" \
        --initiator bi-directional \
        --vpnservice-id "$por_vpnservice_id" \
        --ikepolicy-id "$por_ikepolicy_id" \
        --ipsecpolicy-id "$por_ipsecpolicy_id" \
        --dpd action=restart,interval=15,timeout=150 \
        --peer-address "$por_peer_router_ip" \
        --peer-id "$por_peer_router_ip" \
        --peer-cidr "$por_peer_subnet" \
        --psk "$pre_shared_key"
fi

if [[ $region == "wlg" || $region == "both" ]]
then
    OS_REGION_NAME="nz_wlg_2"

    neutron vpn-service-create \
        --name "VPN" \
        --tenant-id "$tenant_id" \
        "$wlg_router_id" "$wlg_subnet_id"

    neutron vpn-ikepolicy-create \
        --tenant-id "$tenant_id" \
        --auth-algorithm sha1 \
        --encryption-algorithm aes-256 \
        --phase1-negotiation-mode main \
        --ike-version v1 \
        --pfs group5 \
        --lifetime units=seconds,value=28800 \
        "IKE Policy"

    neutron vpn-ipsecpolicy-create \
        --tenant-id "$tenant_id" \
        --transform-protocol esp \
        --auth-algorithm sha1 \
        --encryption-algorithm aes-256 \
        --encapsulation-mode tunnel \
        --pfs group5 \
        --lifetime units=seconds,value=3600 \
        "IPsec Policy"

    wlg_vpnservice_id=$( neutron vpn-service-list | grep VPN | awk '{ print $2 }' )
    wlg_ikepolicy_id=$( neutron vpn-ikepolicy-list | grep 'IKE Policy' | awk '{ print $2 }' )
    wlg_ipsecpolicy_id=$( neutron vpn-ipsecpolicy-list | grep 'IPsec Policy' | awk '{ print $2 }' )

    neutron ipsec-site-connection-create \
        --tenant-id "$tenant_id" \
        --name  "VPN" \
        --initiator bi-directional \
        --vpnservice-id "$wlg_vpnservice_id" \
        --ikepolicy-id "$wlg_ikepolicy_id" \
        --ipsecpolicy-id "$wlg_ipsecpolicy_id" \
        --dpd action=restart,interval=15,timeout=150 \
        --peer-address "$wlg_peer_router_ip" \
        --peer-id "$wlg_peer_router_ip" \
        --peer-cidr "$wlg_peer_subnet" \
        --psk "$pre_shared_key"
fi

echo Your VPN has been created, note that you will need to create appropriate security group rules.
