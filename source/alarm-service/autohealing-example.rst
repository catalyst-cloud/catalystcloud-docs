.. _autohealing-on-catalyst-cloud:

*******************
Autohealing example
*******************

Prerequisites
-------------

- You must have the ``Heat Stack Owner`` role in your project
- You must have ``aodhclient`` installed via ``pip``

Overview
--------

- Create a heat stack with two loadbalanced web servers.
- Create a ``loadbalancer_member_health`` alarm
- Induce failure to one or more of the web servers.
- Observe as the alarm is triggered and the `errored` server is replaced.

Process
-------

To get started clone our example heat stack template. Our template creates all
the resources required for this demo including an isolated network and router
so none of your existing resources will be impacted.

.. code-block:: bash

    $ git clone https://github.com/catalyst-cloud/catalystcloud-orchestration
    $ cd catalystcloud-orchestration/hot/autohealing

Create a stack. You will need the ``Heat Stack Owner`` role in your project.

.. code-block:: bash

    $ openstack stack create autohealing-stack -t stack.yaml

List the stack's resources and wait for all of the resources in the stack to reach
the ``CREATE_COMPLETE`` status.

.. code-block:: bash

    $ openstack stack resource list autohealing-stack

    +------------------------+------------------------------------------------+------------------------------+--------------------+
    | resource_name          | physical_resource_id                           | resource_type                | resource_status    |
    +------------------------+------------------------------------------------+------------------------------+--------------------+
    | loadbalancer_public_ip | b97f763e-d947-47b4-8f31-38a43134e072           | OS::Neutron::FloatingIP      | CREATE_COMPLETE    |
    | webserver_network      | a7170497-e9db-4a86-b56e-9f0ac9f7cac0           | OS::Neutron::Net             | CREATE_COMPLETE    |
    | autoscaling_group      | 8cb9c561-d694-4fe8-b4f9-fe4e2c34db83           | OS::Heat::AutoScalingGroup   | CREATE_COMPLETE    |
    | router_interface       | 301e6ed8-cd1b-4933-9469-8a7cf76aca85:          | OS::Neutron::RouterInterface | CREATE_COMPLETE    |
    |                        | subnet_id=8663461c-20f8-42e6-85c7-f813c2d93426 |                              |                    |
    | listener               | 06d36030-721f-4d70-8200-99e6930a18c3           | OS::Octavia::Listener        | CREATE_COMPLETE    |
    | loadbalancer_pool      | 5d6e89cf-898a-4598-b6ac-9c5c19ff1f8a           | OS::Octavia::Pool            | CREATE_COMPLETE    |
    | router                 | 301e6ed8-cd1b-4933-9469-8a7cf76aca85           | OS::Neutron::Router          | CREATE_COMPLETE    |
    | security_group         | 7a127385-4e8d-483c-ad29-f2672e3f93b3           | OS::Neutron::SecurityGroup   | CREATE_COMPLETE    |
    | subnet                 | 8663461c-20f8-42e6-85c7-f813c2d93426           | OS::Neutron::Subnet          | CREATE_COMPLETE    |
    | loadbalancer           | 61d63ef5-1c6f-4ca4-b4e0-4ab922cafff1           | OS::Octavia::LoadBalancer    | CREATE_COMPLETE    |
    +------------------------+------------------------------------------------+------------------------------+--------------------+

.. note::

    A common reason for resources failing to be created is due to quota limits
    being exceeded. In case of any ``CREATE_FAILED`` statuses you can
    interrogate heat for the reasons why with the following command.

    .. code-block:: bash

        $ openstack stack failures list autohealing-stack

    Address any actionable error messages then delete the stack and try again.

Assign the physical_resource_id's of ``loadbalancer_pool`` and
``autoscaling_group`` to variables for convenience. We'll need to refer to them
several times throughout the rest of the demo.

.. code-block:: bash

  $pool_id=5d6e89cf-898a-4598-b6ac-9c5c19ff1f8a
  $autoscaling_group_id=8cb9c561-d694-4fe8-b4f9-fe4e2c34db83

Our service is exposed via a loadbalancer with a public IP address which can
be found in the output values of the stack.

.. code-block:: shell

    $ openstack stack output show autohealing-stack --all

    +--------------------------+-----------------------------------------+
    | Field                    | Value                                   |
    +--------------------------+-----------------------------------------+
    | loadbalancer_floating_ip | {                                       |
    |                          |   "output_value": "150.242.43.208",     |
    |                          |   "output_key": "lb_ip",                |
    |                          |   "description": "No description given" |
    |                          | }                                       |
    +--------------------------+-----------------------------------------+

The service running on each server simply responds with a short message
including the private IP address of the current server so we can tell which
server has responded to our request. We can interact with the service by
making ``curl`` requests to the public IP address.

.. code-block:: shell

    $ while true; do curl 150.242.43.208; sleep 2; done
    Welcome to 192.168.0.5
    Welcome to 192.168.0.6
    Welcome to 192.168.0.5
    Welcome to 192.168.0.6

The loadbalncer is alternating traffic between the two servers on every request
resulting in a corresponding pattern of alternating responses.

To keep our service up and rning and make it resilient to failure,
we can create a ``loadbalancer_member_health`` alarm. The alarm's function is
to watch for an ``ERROR`` status on any of the loadbalancer members in the pool
and initiate an autohealing action on them.

.. code-block:: bash

    $ openstack alarm create \
        --name autohealing_alarm \
        --type loadbalancer_member_health \
        --alarm-action trust+heat:// \
        --repeat-actions false \
        --autoscaling-group-id $autoscaling_group_id \
        --pool-id $pool_id \
        --stack-id autohealing-stack

Below is a brief explanation of the various arguments we have constructed the
alarm with.

- ``--pool-id`` is the loadbalancer pool that the alarm will monitor for
  unhealthy members.
- ``--alarm-action trust+heat://`` tells the alarm to notify heat when the
  alarm transitions to the ``alarm`` state. This is what initiates the healing action.
- ``--stack-id`` is the name or ID of the stack which the alarm will initiate
  an update on.
- ``--autoscaling-group-id`` is the autoscaling group which the resources
  belong to.

The newly created alarm will start off in the ``insufficient_data`` state
before moving to the ``ok`` state shortly after.

.. code-block:: bash

    $ openstack alarm list

    +--------------------------------------+----------------------------+-------------------+-------------------+----------+
    | alarm_id                             | type                       | name              | state             | severity |
    +--------------------------------------+----------------------------+-------------------+-------------------+----------+
    | fb8c58ef-433f-4583-819d-16c189305869 | loadbalancer_member_health | autohealing_alarm | ok                | low      |
    +--------------------------------------+----------------------------+-------------------+-------------------+----------+

Now that the alarm is in place we can test it out by simulating the failure of
one of our application servers.

To find one of the servers that belongs to the stack we can drill down through
the stack resource list starting from the ``autoscaling_group``.

.. code-block:: bash

  $ openstack resource list $autoscaling_group_id

  +---------------+-----------------------------+-----------------------------+-----------------+----------------------+
  | resource_name | physical_resource_id        | resource_type               | resource_status | updated_time         |
  +---------------+-----------------------------+-----------------------------+-----------------+----------------------+
  | y5r7jqvlne4q  | 69ffd108-3e58-4e6d-a8bb-d12 | file:///home/user/Developm  | CREATE_COMPLETE | 2020-01-28T04:15:05Z |
  |               | b1913e3ed                   | ent/catalystcloud-orchestra |                 |                      |
  |               |                             | tion/hot/autohealing/loadba |                 |                      |
  |               |                             | lanced_webserver.yaml       |                 |                      |
  | 35bklfd62pia  | 0dcbd113-0a03-40d4-ad5d-c53 | file:///home/user/Developm  | CREATE_COMPLETE | 2020-01-28T04:15:06Z |
  |               | d363509ce                   | ent/catalystcloud-orchestra |                 |                      |
  |               |                             | tion/hot/autohealing/loadba |                 |                      |
  |               |                             | lanced_webserver.yaml       |                 |                      |
  +---------------+-----------------------------+-----------------------------+-----------------+----------------------+

Repeat the command again, this time using the ``physical_resource_id`` of
either of the items in the table as the argument.

.. code-block:: bash

  $ openstack resource list 69ffd108-3e58-4e6d-a8bb-d12b1913e3ed

  +------------------+---------------------------+-------------------------+-----------------+----------------------+
  | resource_name    | physical_resource_id      | resource_type           | resource_status | updated_time         |
  +------------------+---------------------------+-------------------------+-----------------+----------------------+
  | pool_member      | 222c740e-68b6-4c3e-a805-f | OS::Octavia::PoolMember | CREATE_COMPLETE | 2020-01-28T03:09:13Z |
  |                  | 278f72b5b5d               |                         |                 |                      |
  | server           | 5e386ada-e838-49a8-b193-7 | OS::Nova::Server        | CREATE_COMPLETE | 2020-01-28T03:09:13Z |
  |                  | ec77789aaac               |                         |                 |                      |
  +------------------+---------------------------+-------------------------+-----------------+----------------------+

Now that we have found the id of one of the servers we can emulate
failure by simply stopping the server.

.. code-block:: bash

  $ openstack server stop 5e386ada-e838-49a8-b193-7ec77789aaac

If we poke our service again we can see that ``192.168.0.5`` has stopped
responding to our request and the one remaining server is recieving all the
traffic.

.. code-block:: shell

  $ while true; do curl 150.242.43.208; sleep 2; done
  Welcome to 192.168.0.6
  Welcome to 192.168.0.6
  Welcome to 192.168.0.6
  Welcome to 192.168.0.6

Querying the members of our loadbalancer pool also shows that one of the
members is now reporting an operating status of ``ERROR``.

.. code-block:: shell

  $ openstack loadbalancer member list $pool_id

  +---------------+------+---------------+---------------------+--------------+---------------+------------------+--------+
  | id            | name | project_id    | provisioning_status | address      | protocol_port | operating_status | weight |
  +---------------+------+---------------+---------------------+--------------+---------------+------------------+--------+
  | 222c740e-68b6 |      | 5fed500024ad4 | ACTIVE              | 192.168.0.5  |            80 | ERROR            |      1 |
  | -4c3e-a805-f2 |      | 267bb4b33952a |                     |              |               |                  |        |
  | 78f72b5b5d    |      | 19fee3        |                     |              |               |                  |        |
  | 3cf31bfe-44ee |      | 5fed500024ad4 | ACTIVE              | 192.168.0.6  |            80 | ONLINE           |      1 |
  | -4af7-b4cc-1a |      | 267bb4b33952a |                     |              |               |                  |        |
  | bde8fee18f    |      | 19fee3        |                     |              |               |                  |        |
  +---------------+------+---------------+---------------------+--------------+---------------+------------------+--------+

Now that at least one member of the loadbalancer pool is reporting an
operating status of ``ERROR``, the conditions for the alarm to be triggered
are satisfied and the alarm has transitioned from ``ok`` to ``alarm``.

.. code-block:: bash

    $ openstack alarm list

    +--------------------------------------+----------------------------+-------------------+-------------------+----------+
    | alarm_id                             | type                       | name              | state             | severity |
    +--------------------------------------+----------------------------+-------------------+-------------------+----------+
    | fb8c58ef-433f-4583-819d-16c189305869 | loadbalancer_member_health | autohealing_alarm | alarm             | low      |
    +--------------------------------------+----------------------------+-------------------+-------------------+----------+

For the loadbalancer member health alarm the ``trust+heat://`` alarm action
will mark the failed server as an unhealthy stack resource and then initiate
a stack update.

.. code-block:: bash

    $ openstack stack list

    +------------------------------------+-------------------+--------------------+----------------------+----------------------+
    | ID                                 | Stack Name        | Stack Status       | Creation Time        | Updated Time         |
    +------------------------------------+-------------------+--------------------+----------------------+----------------------+
    | 349a32a1-f260-4785-a1fe-0a8de4c482 | autohealing-stack | UPDATE_IN_PROGRESS | 2020-01-28T03:07:50Z | 2020-01-28T04:14:59Z |
    | bc                                 |                   |                    |                      |                      |
    +------------------------------------+-------------------+--------------------+----------------------+----------------------+

The heat stack update will take care of the rest, purging the unhealthy
resource and provisioning a new resource as per the stack template.

.. code-block:: bash

    $ openstack stack list

    +------------------------------------+-------------------+-----------------+----------------------+----------------------+
    | ID                                 | Stack Name        | Stack Status    | Creation Time        | Updated Time         |
    +------------------------------------+-------------------+-----------------+----------------------+----------------------+
    | 349a32a1-f260-4785-a1fe-0a8de4c482 | autohealing-stack | UPDATE_COMPLETE | 2020-01-28T03:07:50Z | 2020-01-28T04:14:59Z |
    | bc                                 |                   |                 |                      |                      |
    +------------------------------------+-------------------+-----------------+----------------------+----------------------+

When the stack update is complete the new server will start responding with the
private IP address it was assigned by the private networks DHCP server.

.. code-block:: shell

  $ while true; do curl 150.242.43.208; sleep 2; done
  Welcome to 192.168.0.6
  Welcome to 192.168.0.7
  Welcome to 192.168.0.6
  Welcome to 192.168.0.7

That's it. Now every time one of our loadbalancer members reaches an ``ERROR``
state we can rest assured that our ``loadbalancer_member_health`` alarm will
replace it with a new healthy instance.

.. warning::

  **Don't forget to cleanup your stack to avoid any unnecessary charges.**

  .. code-block:: bash

      $ openstack stack delete autohealing-stack

For more information on the Alarm service, you can visit `the openstack
documentation on aodh`_

.. _`the openstack documentation on aodh`: https://docs.openstack.org/aodh/latest/admin/telemetry-alarms.html
