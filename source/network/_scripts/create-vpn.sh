#!/bin/bash

#------------------------------------------------------------------------------
# Parameters
#------------------------------------------------------------------------------

# set the default VPN creation mode
DEFAULT_MENU_PROMPT="Select the option you require or type 'q' to quit: "
ARR_REGIONS=(Hamilton Porirua)
VPN_MODE=""
REGION_1=""
REGION_2=""

# colour data for message prompt
GREEN="\033[92m" # for success output
YELLOW="\033[93m" # for debug output
RED="\033[91m" # for error output
NC='\033[0m' # remove colour from output

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

usage() {
  echo
  cat <<USAGE_DOC
  Usage: ./$(basename $0) [-h]
  This script will assist in the creation of a VPN endpoint or endpoints on the Catalyst Cloud.
  The default behaviour is to create a single VPN endpoint using the selected region.

  -h Print this usage guide
USAGE_DOC
}

parse_args(){
  while getopts mh OPTION; do
    case "$OPTION" in
      # m)
      #   # build a VPN between two regions of a cloud project
      #   MODE="multi"
      #   ;;
      h)
        usage
        exit 0 ;;
      ?)
        usage
        exit 1 ;;
    esac
  done
}

handle_interruptions() {
  exit 130
}

check_credentials() {
  # Look for $OS_* environment variables. If not defined, prompt the user to source
  # their openrc file

  if [[ ${OS_PROJECT_ID} && ${OS_TOKEN} ]] || [[ ${OS_USERNAME} && ${OS_PASSWORD} && ${OS_PROJECT_ID} ]]; then
    OPENRC="True"
  else
    MSG="No cloud credentials found in the current shell session, please source your openrc file."
    echo -e "${RED}${MSG}${NC}"
    exit 1
  fi
}

create_menu() {
  MENU_PROMPT="${1}"
  shift
  arrsize=$1
  shift
  arr=$1
  ret_val=""
  PS3="${MENU_PROMPT}"
  select option in "${@}"
  do
    if [ "$REPLY" == "q" ] || [ "$REPLY" == "Q" ]
    then
      echo "Exiting..."
      break;
    elif [ 1 -le "$REPLY" ] && [ "$REPLY" -le $((arrsize)) ]
    then
      # echo "You have selected :  $option"
      echo
      ret_val=$option
      break;
    else
      echo "Incorrect Input: Select a number 1-$arrsize"
    fi
  done
}

get_vpn_choice() {

  echo "----------------------------------------------------------"
  echo " This script will setup a VPN in your project."
  echo " You can select either:"
  echo " a single region that will connect to an external site"
  echo " or"
  echo " a site-to-site vpn between 2 regions for the same project"
  echo "----------------------------------------------------------"
  echo

  myarray=(single site-to-site)
  MENU_PROMPT="Select the VPN option you require or type 'q' to quit: "
  create_menu "${MENU_PROMPT}" ${#myarray[@]} ${myarray[@]}
  VPN_MODE=$ret_val
}

get_vpn_region() {
  if [ $VPN_MODE == "single" ]
  then
    echo "----------------------------------------"
    echo " Select the region for your VPN endpoint"
    echo "----------------------------------------"
    echo

    MENU_PROMPT="Select the VPN option you require or type 'q' to quit: "
    create_menu "${MENU_PROMPT}" ${#ARR_REGIONS[@]} ${ARR_REGIONS[@]}
    REGION_1=$ret_val
  elif [ $VPN_MODE == "site-to-site" ]
  then
    echo "-------------------------------------------------------"
    echo " Select the regions for your site-to-site VPN endpoints"
    echo "-------------------------------------------------------"
    echo

    EXIT="false"
    while [ $EXIT == "false" ]
    do
      for i in 1 2
      do
        MENU_PROMPT="Select region $i for the site-to-site VPN or type 'q' to quit: "
        create_menu "${MENU_PROMPT}" ${#ARR_REGIONS[@]} ${ARR_REGIONS[@]}
        eval REGION_${i}=$ret_val

        if [ $REGION_2 ]
        then
          if [ $REGION_1 != $REGION_2 ]
          then
            EXIT="true"
          else
            echo "error can't use the same region for both endpoints"
          fi
        fi

      done
    done
  else
    echo "ERROR: The VPN mode was not set correctly!"
    exit 1
  fi
}

lookup_region_name() {
  case $1 in
    Hamilton)
      ret_val="nz-hlz-1"
    ;;
    Porirua)
      ret_val="nz-por-1"
    ;;
  esac
}

check_openstack() {
  hash openstack 2>/dev/null || {
    echo "openstack command line client is not available, please install it before proceeding";
    exit 1;
  }
  # check if openstack command works with current credentials
  export TOKENID=$(openstack token issue -c id -f value)
  if [ -z $TOKENID ]; then
    echo "Unable to get openstack token please checkl that you have sourced your openrc file"
    exit 1
  fi
}

build_vpn() {
  if [ $REGION_1 ]
  then
    # define single region or region_1 endpoint
    lookup_region_name $REGION_1
    OS_REGION_NAME=$ret_val

    echo "Please enter the name of your $REGION_1 router:"
    read -r region_1_router_name;
    if openstack router show "$region_1_router_name" 2>&1 | grep -q "No Router found for"
    then
      MSG="Unable to find router with name $region_1_router_name"
      echo -e  "${RED}${MSG}${NC}"
      echo please ensure you have created the required routers before running this script
      exit;
    fi

    echo "Please enter the name of your $REGION_1 subnet:";
    read -r region_1_subnet_name;
    if openstack subnet show "$region_1_subnet_name" 2>&1 /dev/null | grep -q 'Unable to find subnet with name'
    then
      MSG="No Subnet found for $region_1_subnet_name"
      echo -e  "${RED}${MSG}${NC}"
      echo please ensure you have created the required subnets before running this script
      exit;
    fi
  fi

  if [ $REGION_2 ]
  then
    lookup_region_name $REGION_2
    OS_REGION_NAME=$ret_val
    echo $OS_REGION_NAME

    echo "Please enter the name of your $REGION_2 router:";
    read -r region_2_router_name;
    if openstack router show "$region_2_router_name" 2>&1 /dev/null | grep -q 'Unable to find router with name'
    then
        echo "Unable to find router with name $region_2_router_name"
        echo please ensure you have created the required routers before running this script
        exit;
    fi

    echo "Please enter the name of your $REGION_2 subnet:";
    read -r region_2_subnet_name;
    if openstack subnet show "$region_2_subnet_name" 2>&1 /dev/null | grep -q 'Unable to find subnet with name'
    then
        echo "Unable to find subnet with name $region_2_subnet_name"
        echo please ensure you have created the required subnets before running this script
        exit;
    fi
  fi

  echo "Please enter your pre shared key:";
  read -r pre_shared_key;

  if [[ $REGION_1 && $REGION_2 ]] # This is a site-to-site VPN across regions
  then
      echo "Please enter the $REGION_1 router ip address";
      read -r region_1_router_ip;
      echo "Please enter the $REGION_1 CIDR range";
      read -r region_1_subnet;
      echo

      echo "Please enter the $REGION_2 router ip address";
      read -r region_2_router_ip;
      echo "Please enter the $REGION_2 CIDR range";
      read -r region_2_subnet;

      region_1_peer_router_ip=$region_2_router_ip
      region_1_peer_subnet=$region_2_subnet
      region_2_peer_router_ip=$region_1_router_ip
      region_2_peer_subnet=$region_1_subnet

  elif [ -z $REGION_2 ] # This ss a single endpoint VPN to a remote site
  then
      echo "Please enter the remote peer router ip address";
      read -r remote_peer_router_ip;
      echo "Please enter the remote peer CIDR range";
      read -r remote_peer_subnet;

      region_1_peer_router_ip=$remote_peer_router_ip
      region_1_peer_subnet=$remote_peer_subnet

  fi

  echo
  echo --------------------------------------------------------
  MSG="Proceeding to create VPN with the following credentials:"
  echo -e  "${GREEN}${MSG}${NC}"

  if [ $REGION_1 ]
  then
      echo "Region name = $REGION_1"
      echo "region_1_router_name = $region_1_router_name"
      echo "region_1_subnet_name = $region_1_subnet_name"
      echo "region_1_router_ip = $region_1_router_ip"
      echo "region_1_subnet = $region_1_subnet"
      echo "region_1_peer_router_ip = $region_1_peer_router_ip"
      echo "region_1_peer_subnet = $region_1_peer_subnet"
      echo
  fi
  if [ $REGION_2 ]
  then

      echo "Region name = $REGION_2"
      echo "region_2_router_name = $region_2_router_name"
      echo "region_2_subnet_name = $region_2_subnet_name"
      echo "region_2_router_ip = $region_2_router_ip"
      echo "region_2_subnet = $region_2_subnet"
      echo "region_2_peer_router_ip = $region_2_peer_router_ip"
      echo "region_2_peer_subnet = $region_2_peer_subnet"
      echo
  fi
  # echo "tenant_id = $tenant_id"
  echo "pre_shared_key = $pre_shared_key"
  echo --------------------------------------------------------
  echo

  # build the first endpoint
  if [ $REGION_1 ]
  then
    MSG="creating endpoint for $REGION_1"
    echo -e  "${YELLOW}${MSG}${NC}"
    lookup_region_name $REGION_1
    OS_REGION_NAME=$ret_val

    openstack vpn service create \
    --subnet $region_1_subnet_name \
    --router $region_1_router_name \
    vpn_service

    openstack vpn ike policy create \
    --auth-algorithm sha1 \
    --encryption-algorithm aes-256 \
    --phase1-negotiation-mode main \
    --pfs group14 \
    --ike-version v1 \
    --lifetime units=seconds,value=14400 \
    ike_policy

    openstack vpn ipsec policy create \
    --transform-protocol esp \
    --auth-algorithm sha1 \
    --encryption-algorithm aes-256 \
    --encapsulation-mode tunnel \
    --pfs group14 \
    --lifetime units=seconds,value=3600 \
    ipsec_policy

    openstack vpn ipsec site connection create \
    --initiator bi-directional \
    --vpnservice vpn_service \
    --ikepolicy ike_policy \
    --ipsecpolicy ipsec_policy \
    --dpd action=restart,interval=15,timeout=150 \
    --peer-address $region_1_peer_router_ip \
    --peer-id $region_1_peer_router_ip \
    --peer-cidr $region_1_peer_subnet \
    --psk pre_shared_key \
    vpn_site_connection
  fi

  # build the second endpoint if creating an inter-region VPN
  if [ $REGION_2 ]
  then
    MSG="creating endpoint for $REGION_2"
    echo -e  "${YELLOW}${MSG}${NC}"
    lookup_region_name $REGION_2
    OS_REGION_NAME=$ret_val

    openstack vpn service create \
    --subnet $region_2_subnet_name \
    --router $region_2_router_name \
    vpn_service

    openstack vpn ike policy create \
    --auth-algorithm sha1 \
    --encryption-algorithm aes-256 \
    --phase1-negotiation-mode main \
    --pfs group14 \
    --ike-version v1 \
    --lifetime units=seconds,value=14400 \
    ike_policy

    openstack vpn ipsec policy create \
    --transform-protocol esp \
    --auth-algorithm sha1 \
    --encryption-algorithm aes-256 \
    --encapsulation-mode tunnel \
    --pfs group14 \
    --lifetime units=seconds,value=3600 \
    ipsec_policy

    openstack vpn ipsec site connection create \
    --initiator bi-directional \
    --vpnservice vpn_service \
    --ikepolicy ike_policy \
    --ipsecpolicy ipsec_policy \
    --dpd action=restart,interval=15,timeout=150 \
    --peer-address $region_2_peer_router_ip \
    --peer-id $region_2_peer_router_ip \
    --peer-cidr $region_2_peer_subnet \
    --psk pre_shared_key \
    vpn_site_connection
  fi

  MSG="Your VPN has been created, note that you will need to create appropriate security group rules."
  echo
  echo -e  "${GREEN}${MSG}${NC}"
  echo
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

# Handle ctrl-c (SIGINT)
trap handle_interruptions INT

parse_args "$@"

check_credentials
check_openstack
get_vpn_choice
get_vpn_region
build_vpn


