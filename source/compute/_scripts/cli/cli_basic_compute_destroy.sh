export VOLUMEID=$(openstack server show $CC_SERVERNAME -c volumes_attached -f value | awk -F"\'" '{ print $2}') && echo $VOLUMEID
openstack server delete $CC_SERVERNAME
openstack volume delete $VOLUMEID
openstack floating ip delete $CC_FLOATING_IP_ID
openstack security group delete $CC_SEC_GROUP_NAME
