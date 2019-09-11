###################
Connection draining
###################

When needing to perform maintenance tasks on an active pool member it is
preferable to be able to remove that member from the pool in a graceful manner
which does not abruptly terminate client connections. The usual approach to
this is a process known as connection draining, where a member's state is set
so that it will no longer accept new connections requests. This allows for any
existing connections to complete their current tasks and close, then once there
are no remaining connections the member server can be worked on safely.

To achieve this on the Catalyst Cloud Load Balancer service set the ``weight``
for the target member to 0.

.. code-block:: bash

  $ openstack loadbalancer member set http_pool login.example.com --weight 0

Once the member is ready to go back in to the pool simply reset its weight
value back the the same as the other members in the pool.

To check the weight values for existing pool members run

.. code-block:: bash

  $ openstack loadbalancer member list http_pool_2 -c name -c weight
  +------------------+--------+
  | name             | weight |
  +------------------+--------+
  | shop.example.com |      1 |
  +------------------+--------+
