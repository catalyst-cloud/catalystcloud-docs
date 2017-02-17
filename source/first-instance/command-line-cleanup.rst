***************************************
Resource cleanup using the command line
***************************************

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
