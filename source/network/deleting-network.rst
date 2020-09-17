##################
Deleting a network
##################

There are some dependencies that exist between the various infrastructure
elements that get created in the cloud. While this is necessary in order to
have things work correctly, it does cause the occasional problem when trying to
delete unwanted items.

**************************
Deleting an entire network
**************************

One area where this crops up from time to time is while removing network
elements, so here is the recommended process for deleting an entire network and
associated parts.

- first ensure that there are no instances connected to the network in question
- remove the interface from the router
- delete the router
- delete the network

If you had security groups that were only required by the network just deleted
you could also remove these at this stage. This process is most easily done via
the Dashboard in the network section as it shows you in the topology what the
dependencies are via the lines to one another.

**********************************
Deleting specific network elements
**********************************

If you are looking to only remove certain elements, then you would have to
ensure that all dependencies on that network are removed first. In some
cases, these dependencies might be nested, meaning that the obvious
dependency may also have less obvious dependencies.

*******************************************
An example - finding the dependency problem
*******************************************

One example of this would be trying to remove a network that is connected
to a router but also still in use by a VPN. If you try and remove the router
interface through the dashboard, you would get a non-specific error indicating
that removing the interface failed.

At this point it may be quite challenging to determine what the exact cause
of the error is. The best way to diagnose the problem is to use the OpenStack
command line tools.

To start, get the IDs of your router, subnet and router port.

.. code-block:: bash

  $ openstack router list -c ID -c Name
  +--------------------------------------+---------------+
  | ID                                   | Name          |
  +--------------------------------------+---------------+
  | 6be77df7-fa23-4eaa-8542-a0620fba68f8 | border-router |
  +--------------------------------------+---------------+

  $ openstack network list
  +--------------------------------------+-------------+--------------------------------------+
  | ID                                   | Name        | Subnets                              |
  +--------------------------------------+-------------+--------------------------------------+
  | e0ba6b88-5360-492c-9c3d-119948356fd3 | public-net  | 8b88f8c7-0a5c-483b-9e55-f9a8c2ca93b4 |
  | 6fe1b0b8-37ba-4e79-84ff-7799b6ccd7b3 | private-net | c5145b18-26f1-4053-bac4-d8d0bdc77b48 |
  +--------------------------------------+-------------+--------------------------------------+

  openstack port list --router border-router -c ID
  +--------------------------------------+
  | ID                                   |
  +--------------------------------------+
  | 44f6d507-2969-4e8f-b03c-e7361d13109d |
  +--------------------------------------+

Now try to delete the port from the router.

.. code-block:: bash

  $ openstack port delete 44f6d507-2969-4e8f-b03c-e7361d13109d
  Failed to delete port with name or ID '44f6d507-2969-4e8f-b03c-e7361d13109d':
  HttpException: Conflict (HTTP 409) (Request-ID: req-9b31b77a-36a7-4025-8e53-59b94aef2b26),
  Port 44f6d507-2969-4e8f-b03c-e7361d13109d cannot be deleted directly via the port
  API: has device owner network:router_interface
  1 of 1 ports failed to delete.

OK, so while that wasn't successful, at least you got a bit more information
telling you that there is some kind of dependency associated with
the router interface.

This time, try to remove the subnet from the router, as that would
remove the interface.

.. code-block:: bash

  $ openstack router remove subnet 6be77df7-fa23-4eaa-8542-a0620fba68f8  c5145b18-26f1-4053-bac4-d8d0bdc77b48
  HttpException: Conflict (HTTP 409) (Request-ID: req-a0821a75-e616-4e9a-a1a3-0f64574e07dc),
  Subnet c5145b18-26f1-4053-bac4-d8d0bdc77b48 is used by VPNService 478073d3-a347-4d1a-8653-609788064147

Success: now you can see what the problem is. It appears that your subnet is
associated with a VPN. If you were to go ahead and remove the VPN, you would
be able to delete the network as you initially set out to do.
