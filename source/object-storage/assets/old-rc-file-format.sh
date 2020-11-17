#!/usr/bin/env bash
# This file contains all of the environment variables you need to set in order to interact with the
# swift API. You will need to change the placeholder values which are indicated by the "<>" brackets.
# By default, this file is set up to work with the porirua region, if you want to change this region,
# then you will need to change the OS_AUTH_URL and the OS_REGION_NAME.
export OS_AUTH_URL=https://api.nz-por-1.catalystcloud.io:5000/v3
export OS_PROJECT_ID=<INSERT PROJECT ID>
export OS_PROJECT_NAME="<INSERT PROJECT NAME>"
export OS_USER_DOMAIN_NAME="Default"
if [ -z "$OS_USER_DOMAIN_NAME" ]; then unset OS_USER_DOMAIN_NAME; fi
export OS_PROJECT_DOMAIN_ID="default"
if [ -z "$OS_PROJECT_DOMAIN_ID" ]; then unset OS_PROJECT_DOMAIN_ID; fi
# unset v2.0 items in case set
unset OS_TENANT_ID
unset OS_TENANT_NAME
# In addition to the owning entity (tenant), OpenStack stores the entity
# performing the action as the **user**.
export OS_USERNAME="<INSERT YOUR USERNAME HERE>"
# With Keystone you pass the keystone password.
echo "Please enter your OpenStack Password for project $OS_PROJECT_NAME as user $OS_USERNAME: "
read -sr OS_PASSWORD_INPUT
export OS_PASSWORD=$OS_PASSWORD_INPUT
export OS_REGION_NAME="nz-por-1"
# Don't leave a blank variable. If the region was not provider we unset it.
if [ -z "$OS_REGION_NAME" ]; then unset OS_REGION_NAME; fi
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3
