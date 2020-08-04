# The order of these commands is important.

# delete the instances
$ openstack server delete first-instance
# delete router interface
$ openstack router remove port border-router $( openstack port list -f value -c ID --router border-router )
# delete router
$ openstack router delete border-router
# delete network
$ openstack network delete private-net
# delete security group
$ openstack security group delete first-instance-sg
# delete ssh key
$ openstack keypair delete first-instance-key
