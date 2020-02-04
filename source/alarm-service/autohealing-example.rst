.. _autohealing-on-catalyst-cloud:

*******************
Autohealing example
*******************

Prerequisites
-------------
- You must have the ``Heat Stack Owner`` role.
- You must have ``aodhclient``, which you can install via ``pip``
- You must have a network set up that can host webservers.
- You must have sourced an RC file on your command line

Bullet point overview
---------------------

- Create a heat stack with two loadbalanced webservers.
- Create a ``loadbalancer_member_health`` alarm
- Induce failure to one or more of the webservers.
- Observe as the alarm is triggered and the `errored` webserver is replaced.

Process
-------

This example will create an alarm that monitors a set of simulated webservers.
We will configure our alarm so that should a webserver go down the alarm will
trigger and inform the heat stack, which created the webservers, to activate an
autohealing feature. The webservers will be simulated by using netcat on an
Ubuntu image in our project, these Ubuntu instances will respond to requests
with the message: "Welcome to my <IP address>".

To get started we need to clone our example templates. These templates
create most of the resources that are required for this example. However, this
example still requires a network already created before hand for the resources
to function.

.. code-block:: bash

  $ git clone https://github.com/catalyst-cloud/catalystcloud-orchestration/
  $ cd catalystcloud-orchestration/hot/autohealing/autohealing-single-server

Next, you will need to change some of the variables in these files. The
``KEY NAME, NETWORK ID, SUBNET ID``, and the ``IMAGE ID`` if you are in a
project outside the hamilton region; All will need to be changed in the
"autohealing.yaml" file. Similarly, the ``KEYNAME, NETWORK ID, and IMAGE ID``
will also need to be changed in the "webserver.yaml"

Once these changes have been made and your yaml files have been saved, we want
to make sure that they are valid for use. To do this, we can use the
openstack commands below.

.. code-block:: bash

  $ openstack orchestration template validate -f yaml -t autohealing.yaml
  $ openstack orchestration template validate -f yaml -t webserver.yaml

If your template is valid the console will output the template, if the
template is invalid the console will return an error message instead.
As long as our templates are valid, we can go to the next step which is
creating the stack.

.. code-block:: bash

  $ openstack stack create autohealing-test -t autohealing.yaml -e env.yaml
  $ export stackid=$(openstack stack show autohealing-test -c id -f value) && echo $stackid

We have now created the stack and exported a variable for repeated use
throughout this example. Next we will want to list the stack resources so we
can see what is being created.

.. code-block:: bash

  $ watch openstack stack resource list $stackid
  +----------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
  | resource_name              | physical_resource_id                 | resource_type              | resource_status | updated_time         |
  +----------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
  | loadbalancer_public_ip     | d54dcfd2-944d-48e3-830f-8cdbc46373a2 | OS::Neutron::FloatingIP    | CREATE_COMPLETE | 2019-10-10T01:26:34Z |
  | autoscaling_group          | 7a4f0dc9-5ff9-40ce-8bb8-e621574501b6 | OS::Heat::AutoScalingGroup | CREATE_COMPLETE | 2019-10-10T01:26:34Z |
  | listener                   | 1a0f2cd2-0d45-42f2-929c-7efd3674dc34 | OS::Octavia::Listener      | CREATE_COMPLETE | 2019-10-10T01:26:35Z |
  | loadbalancer_healthmonitor | 2773d0c1-bdcd-41c1-905d-a0c163e9c74c | OS::Octavia::HealthMonitor | CREATE_COMPLETE | 2019-10-10T01:26:34Z |
  | loadbalancer_pool          | 30129a16-f6b7-434f-9648-09c306d699f8 | OS::Octavia::Pool          | CREATE_COMPLETE | 2019-10-10T01:26:35Z |
  | loadbalancer               | 5f9ea90e-97ae-4844-867e-3de70b32abf3 | OS::Octavia::LoadBalancer  | CREATE_COMPLETE | 2019-10-10T01:26:35Z |
  +----------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
.. note::

  In case of any ``CREATE_FAILED`` statuses you can interrogate the stack for
  the error reasons with the command below.

  .. code-block:: bash

    $ openstack stack failures list autohealing-stack

  A common reason for resources failing to be created is due to quotas being
  exceeded while attempting to create the stack. Address any actionable error
  messages then delete the stack and try again.


Once these resources reach "CREATE_COMPLETE" the stack has finished and we
can move on to testing our webservers.
However before this, we are going to create some variables as we will need to
refer to certain resource IDs many times throughout this example. These are the
'Load balancer ID', 'Autoscaling Group ID', and the 'Load balancer pool ID'

.. code-block:: bash

  $ lbid=$(openstack loadbalancer list | grep webserver_lb | awk '{print $2}');
  $ asgid=$(openstack stack resource list $stackid | grep autoscaling_group | awk '{print $4}');
  $ poolid=$(openstack loadbalancer status show $lbid | jq -r '.loadbalancer.listeners[0].pools[0].id')

Next we are going to test our webservers. The service running on each webserver
simply responds with a short message including the private IP address of the
current server, so we can tell which server has responded to our request. We
can interact with the service by making ``curl`` requests to the public IP
address.

.. code-block:: bash

  $ openstack stack output show $stackid --all
  +--------+-----------------------------------------+
  | Field  | Value                                   |
  +--------+-----------------------------------------+
  | lb_vip | {                                       |
  |        |   "output_value": "10.17.9.145",        |
  |        |   "output_key": "lb_ip",                |
  |        |   "description": "No description given" |
  |        | }                                       |
  | lb_ip  | {                                       |
  |        |   "output_value": "103.254.157.70",     |
  |        |   "output_key": "lb_ip",                |
  |        |   "description": "No description given" |
  |        | }                                       |
  +--------+-----------------------------------------+

  $ export lb_ip=103.254.157.70
  $ while true; do curl $lb_ip; sleep 2; done
  Welcome to my 192.168.2.200
  Welcome to my 192.168.2.201
  Welcome to my 192.168.2.200
  Welcome to my 192.168.2.201

The loadbalancer is alternating the traffic between these two servers on every
request. To keep our service up and running and to make our service resilient
to failure, we are going to create a ``loadbalancer_member_health`` alarm. The
alarms function is to watch for failures in any of the loadbalancer members and
initiate an autohealing action on them.

.. code-block:: bash

  # We check that our loadbalancer members are all healthy before creating our alarm.
  $ openstack loadbalancer member list $poolid
  +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
  | id                                   | name | project_id                       | provisioning_status | address       | protocol_port | operating_status | weight |
  +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
  | 4eeac1a8-7837-41d9-8299-8d8f9f691b69 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.200 |            80 | ONLINE           |      1 |
  | 2acbd21e-39d5-41fe-8fb9-b3d61333f0c9 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.201 |            80 | ONLINE           |      1 |
  +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+

  $ openstack alarm create --name test_lb_alarm \
  --type loadbalancer_member_health \
  --alarm-action trust+heat:// \
  --repeat-actions false \
  --autoscaling-group-id $asgid \
  --pool-id $poolid \
  --stack-id $stackid

  +---------------------------+---------------------------------------+
  | Field                     | Value                                 |
  +---------------------------+---------------------------------------+
  | alarm_actions             | ['trust+heat:']                       |
  | alarm_id                  | 8c701d87-679a-4c27-939b-360ac356de58  |
  | autoscaling_group_id      | 9ec5bb8c-3b7f-4a71-858d-cb73d0d03b4e  |
  | description               | loadbalancer_member_health alarm rule |
  | enabled                   | True                                  |
  | insufficient_data_actions | []                                    |
  | name                      | test_lb_alarm                         |
  | ok_actions                | []                                    |
  | pool_id                   | 0da0911a-0b07-4937-99ab-c6f6e3404c39  |
  | project_id                | eac679e4896146e6827ce29d755fe289      |
  | repeat_actions            | False                                 |
  | severity                  | low                                   |
  | stack_id                  | cc55271e-ddcd-4db0-8803-265f23297849  |
  | state                     | insufficient data                     |
  | state_reason              | Not evaluated yet                     |
  | state_timestamp           | 2019-10-31T01:19:22.992154            |
  | time_constraints          | []                                    |
  | timestamp                 | 2019-10-31T01:19:22.992154            |
  | type                      | loadbalancer_member_health            |
  | user_id                   | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX      |
  +---------------------------+---------------------------------------+

Below is a brief explanation of the various arguments we have constructed the
alarm with:

- ``--pool-id`` is the loadbalancer pool that the alarm will monitor for
  unhealthy members.
- ``trust+heat://`` tells the alarm to notify heat when a loadbalancer pool
  member is unhealthy. This is what initiates the healing action.
- ``--stack-id`` is the name or ID of the stack which the alarm will initiate
  an update on.
- ``--autoscaling-group-id`` is the autoscaling group which the resources
  belong to.

We can now view the alarm and see that its status is ``insufficient data.``
This is normal as the alarm has not been created to recognise any state of the
loadbalancer that is not the ``ERROR`` state.

.. code-block:: bash

  $ openstack alarm list
  +--------------------------------------+----------------------------+---------------+-------------------+----------+---------+
  | alarm_id                             | type                       | name          | state             | severity | enabled |
  +--------------------------------------+----------------------------+---------------+-------------------+----------+---------+
  | 18be0104-feed-4415-b9a5-55dcda0332ab | loadbalancer_member_health | test_lb_alarm | insufficient data | low      | True    |
  +--------------------------------------+----------------------------+---------------+-------------------+----------+---------+

Now that the alarm is in place we can test it out by simulating the failure of
one of our application servers. For this example we can simulate a failure by
'stopping' a server.

.. code-block:: bash

  # Find one of the server ids
  $ openstack server list
  +--------------------------------------+-------------------------------------------------------+--------+-----------------------------------------+---------------------+---------+
  | ID                                   | Name                                                  | Status | Networks                                | Image               | Flavor  |
  +--------------------------------------+-------------------------------------------------------+--------+-----------------------------------------+---------------------+---------+
  | 4a35a813-ac9a-4195-9b25-ad5d9381f68e | au-5z37-rowgvu2inhwa-25buammtmf2s-server-mkvfo7vxlv64 | ACTIVE | private_net=192.168.2.200, 10.17.9.148  | cirros-0.3.1-x86_64 | m1.tiny |
  | b80aa773-7330-4a00-9666-12980059050b | au-5z37-hlzbc66r2vrc-h6qxnp7n5wru-server-wyf3dksa6w3v | ACTIVE | private_net=192.168.2.201, 10.17.9.147  | cirros-0.3.1-x86_64 | m1.tiny |
  +--------------------------------------+-------------------------------------------------------+--------+-----------------------------------------+---------------------+---------+

  # Then we 'stop' this server
  $ openstack server stop 4a35a813-ac9a-4195-9b25-ad5d9381f68e

If we curl our service again we can see that ``192.168.2.201`` has stopped
responding to our request and the one remaining server is receiving all the
traffic.

.. code-block:: bash

  $ while true; do curl $lb_ip; sleep 2; done
  Welcome to my 192.168.2.200
  Welcome to my 192.168.2.200
  Welcome to my 192.168.2.200
  Welcome to my 192.168.2.200

Querying the loadbalancer member pool also shows that one of the members
status is now reporting ``ERROR``.

.. code-block:: bash

  $ openstack loadbalancer member list $poolid
  +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
  | id                                   | name | project_id                       | provisioning_status | address       | protocol_port | operating_status | weight |
  +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
  | 4eeac1a8-7837-41d9-8299-8d8f9f691b69 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.200 |            80 | ONLINE           |      1 |
  | 2acbd21e-39d5-41fe-8fb9-b3d61333f0c9 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.201 |            80 | ERROR            |      1 |
  +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+

Now that at least one member of the loadbalancer pool is reporting an
operating status of ``ERROR``, the conditions for the alarm to be triggered
are satisfied and the alarm has transitioned from ``ok`` to ``alarm``.

.. code-block:: bash

  +--------------------------------------+----------------------------+---------------+------------+----------+---------+
  | alarm_id                             | type                       | name          | state      | severity | enabled |
  +--------------------------------------+----------------------------+---------------+------------+----------+---------+
  | 18be0104-feed-4415-b9a5-55dcda0332ab | loadbalancer_member_health | test_lb_alarm | alarm      | low      | True    |
  +--------------------------------------+----------------------------+---------------+------------+----------+---------+

For the loadbalancer member health alarm the ``trust+heat://`` action will
mark the failed server as an unhealthy stack resource and then initiate
a stack update.

.. code-block:: bash

  $ openstack stack resource list $stackid
  +----------------------------+--------------------------------------+----------------------------+--------------------+----------------------+
  | resource_name              | physical_resource_id                 | resource_type              | resource_status    | updated_time         |
  +----------------------------+--------------------------------------+----------------------------+--------------------+----------------------+
  | loadbalancer_public_ip     | d54dcfd2-944d-48e3-830f-8cdbc46373a2 | OS::Neutron::FloatingIP    | CREATE_COMPLETE    | 2019-10-10T01:26:34Z |
  | autoscaling_group          | 7a4f0dc9-5ff9-40ce-8bb8-e621574501b6 | OS::Heat::AutoScalingGroup | UPDATE_IN_PROGRESS | 2019-10-10T01:53:06Z |
  | listener                   | 1a0f2cd2-0d45-42f2-929c-7efd3674dc34 | OS::Octavia::Listener      | CREATE_COMPLETE    | 2019-10-10T01:26:35Z |
  | loadbalancer_healthmonitor | 2773d0c1-bdcd-41c1-905d-a0c163e9c74c | OS::Octavia::HealthMonitor | CREATE_COMPLETE    | 2019-10-10T01:26:34Z |
  | loadbalancer_pool          | 30129a16-f6b7-434f-9648-09c306d699f8 | OS::Octavia::Pool          | CREATE_COMPLETE    | 2019-10-10T01:26:35Z |
  | loadbalancer               | 5f9ea90e-97ae-4844-867e-3de70b32abf3 | OS::Octavia::LoadBalancer  | CREATE_COMPLETE    | 2019-10-10T01:26:35Z |
  +----------------------------+--------------------------------------+----------------------------+--------------------+----------------------+

  # After a few minutes, the stack status goes back to healthy. The ERROR load balancer member is replaced.
  $ openstack stack resource list $stackid
  +----------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
  | resource_name              | physical_resource_id                 | resource_type              | resource_status | updated_time         |
  +----------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
  | loadbalancer_public_ip     | d54dcfd2-944d-48e3-830f-8cdbc46373a2 | OS::Neutron::FloatingIP    | CREATE_COMPLETE | 2019-10-10T01:26:34Z |
  | autoscaling_group          | 7a4f0dc9-5ff9-40ce-8bb8-e621574501b6 | OS::Heat::AutoScalingGroup | UPDATE_COMPLETE | 2019-10-10T01:53:06Z |
  | listener                   | 1a0f2cd2-0d45-42f2-929c-7efd3674dc34 | OS::Octavia::Listener      | CREATE_COMPLETE | 2019-10-10T01:26:35Z |
  | loadbalancer_healthmonitor | 2773d0c1-bdcd-41c1-905d-a0c163e9c74c | OS::Octavia::HealthMonitor | CREATE_COMPLETE | 2019-10-10T01:26:34Z |
  | loadbalancer_pool          | 30129a16-f6b7-434f-9648-09c306d699f8 | OS::Octavia::Pool          | CREATE_COMPLETE | 2019-10-10T01:26:35Z |
  | loadbalancer               | 5f9ea90e-97ae-4844-867e-3de70b32abf3 | OS::Octavia::LoadBalancer  | CREATE_COMPLETE | 2019-10-10T01:26:35Z |
  +----------------------------+--------------------------------------+----------------------------+-----------------+----------------------+

  $ openstack loadbalancer member list $poolid
  +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
  | id                                   | name | project_id                       | provisioning_status | address       | protocol_port | operating_status | weight |
  +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
  | 4eeac1a8-7837-41d9-8299-8d8f9f691b69 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.200 |            80 | ONLINE           |      1 |
  | f354fe18-c801-4729-90bb-0af29048ef46 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.202 |            80 | ONLINE           |      1 |
  +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+

Now that the stack update is complete the new server will start responding to
requests with a different IP then the failed member.

.. code-block:: bash

  $ while true; do curl $lb_ip; sleep 2; done
  Welcome to my 192.168.2.200
  Welcome to my 192.168.2.202
  Welcome to my 192.168.2.200
  Welcome to my 192.168.2.202

Now that we've shown you can create an autohealing service using aodh,
we can clean up this stack:

.. code-block:: bash

  $ openstack stack delete $stackid


For more information on the Alarm service, you can visit `the openstack
documentation on aodh`_

.. _`the openstack documentation on aodh`: https://docs.openstack.org/aodh/latest/admin/telemetry-alarms.html
