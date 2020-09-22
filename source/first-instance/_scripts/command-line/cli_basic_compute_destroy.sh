$ export VOLUMEID=$(openstack server show $CC_SERVERNAME -c volumes_attached -f value | awk -F"\'" '{ print $2}') && echo $VOLUMEID
$ openstack server delete $CC_SERVERNAME
$ openstack volume delete $VOLUMEID
