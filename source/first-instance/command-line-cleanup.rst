**************************************
Resource cleanup from the command line
**************************************

At this point you may want to cleanup the OpenStack resources that have been
created. Running the following commands should remove all networks, routers,
ports, security groups and instances. These commands will work regardless of
the method you used to create the resources. Note that the order you delete
resources is important.

.. warning::

 The following commands will delete all the resources you have created
 including networks and routers, do not run these commands unless you wish to
 delete all these resources.

.. code-block:: bash

 # delete the instances
 $ nova delete first-instance

 # delete instance ports
 $ for port_id in $(neutron port-list | grep 10.0.0 | grep -v '10.0.0.1"' | awk '{ print $2 }'); do neutron port-delete $port_id; done

 # delete router interface
 $ neutron router-interface-delete border-router $(neutron subnet-list | grep private-subnet | awk '{ print $2 }')
 Removed interface from router border-router.

 # delete router
 $ neutron router-delete border-router
 Deleted router: border-router

 # delete subnet
 $ neutron subnet-delete private-subnet
 Deleted subnet: private-subnet

 # delete network
 $ neutron net-delete private-net
 Deleted network: private-net

 # delete security group
 $ neutron security-group-delete first-instance-sg
 Deleted security_group: first-instance-sg

 # delete ssh key
 $ nova keypair-delete first-instance-key
