.. _autoscaling-on-catalyst-cloud:

********************
Auto scaling example
********************

Prerequisites
-------------
- You must have the ``Heat Stack Owner`` role.
- You must have ``aodhclient``, which you can install via ``pip``
- You must have a network set up that can host webservers.
- You must have sourced an RC file on your command line

Bullet point overview
---------------------

- Create a heat stack with two loadbalanced webservers.
- Create a ``ceilometer_cpu_high_alarm`` and a ``ceilometer_cpu_low_alarm``
- Cause one of the instances to exceed the high alarm threshold.
- Observe as the alarm is triggered and the service is scaled up.

Process
-------

This example will create an alarm that monitors a set of simulated webservers.
We will configure our alarm so that should a webserver's CPU usage exceed 20%
the alarm will trigger and activate an autoscaling feature, creating another
webserver. The webservers will be simulated by using netcat on an Ubuntu image
in our project, these Ubuntu instances will respond to requests with the
message: "Welcome to my <IP address>".

To get started we need to clone our example templates. These templates
create most of the resources that are required for this example. However, this
example still requires a network already created before hand for the resources
to function.

.. code-block:: bash

  $ git clone https://github.com/catalyst-cloud/catalystcloud-orchestration/
  $ cd catalystcloud-orchestration/hot/autoscaling/single-server-autoscaling

Next, you will need to change some of the variables in these files. The
``KEY NAME, NETWORK ID, SUBNET ID``, and the ``IMAGE ID`` if you are in a
project outside the hamilton region; All will need to be changed in the
"autoscaling.yaml" file. Similarly, the ``KEYNAME, NETWORK ID, and IMAGE ID``
will also need to be changed in the "webserver.yaml"

Once these changes have been made and your yaml files have been saved, we want
to make sure that they are valid for use. To do this, we can use the
openstack commands below.

.. code-block:: bash

  $ openstack orchestration template validate -f yaml -t autoscaling.yaml
  $ openstack orchestration template validate -f yaml -t webserver.yaml

If your template is valid the console will output the template, if the
template is invalid the console will return an error message instead.
As long as our templates are valid, we can go to the next step which is
creating the stack.

.. code-block:: bash

  $ openstack stack create autoscaling-test -t autoscaling.yaml -e env.yaml
  $ export stackid=$(openstack stack show autoscaling-test -c id -f value) && echo $stackid

We have now created the stack and exported a variable for the stackID which
will be used throughout this example. Next we will want to list the stack
resources so we can see what is being created.

.. code-block:: bash

  $ watch openstack stack resource list $stackid
  +---------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
  | resource_name             | physical_resource_id                 | resource_type              | resource_status | updated_time         |
  +---------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
  | loadbalancer_public_ip    | aeefcc84-eb7f-455b-b6d3-2ec1595a1f4c | OS::Neutron::FloatingIP    | CREATE_COMPLETE | 2020-02-19T20:24:18Z |
  | scaleup_policy            | 61b8b544e97c48b7abf5db1b1962f5fc     | OS::Heat::ScalingPolicy    | CREATE_COMPLETE | 2020-02-19T20:24:18Z |
  | scaledown_policy          | 35e47dc75dd144ff9843f061c592dc5d     | OS::Heat::ScalingPolicy    | CREATE_COMPLETE | 2020-02-19T20:24:18Z |
  | autoscaling_group         | 03f4113e-22dc-46c9-abab-8579941683b1 | OS::Heat::AutoScalingGroup | CREATE_COMPLETE | 2020-02-19T20:24:18Z |
  | listener                  | 6eac615a-1501-4c3f-8a9d-940fee880003 | OS::Octavia::Listener      | CREATE_COMPLETE | 2020-02-19T20:24:18Z |
  | loadbalancer_pool         | 042c7da5-c7e9-4e1b-8c58-856eeead0a3f | OS::Octavia::Pool          | CREATE_COMPLETE | 2020-02-19T20:24:18Z |
  | ceilometer_cpu_low_alarm  | 068f05b5-7f39-4cb6-abdf-ba8c54a6abb8 | OS::Aodh::Alarm            | CREATE_COMPLETE | 2020-02-19T20:24:18Z |
  | ceilometer_cpu_high_alarm | f95884e5-7edb-4f3e-8c92-f29e323fa7a6 | OS::Aodh::Alarm            | CREATE_COMPLETE | 2020-02-19T20:24:18Z |
  | security_group            | 70c0ec40-4519-4e23-abf4-84ab08056314 | OS::Neutron::SecurityGroup | CREATE_COMPLETE | 2020-02-19T20:24:18Z |
  | loadbalancer              | cc31d61d-4f9f-4123-8bd3-861d6397f2c4 | OS::Octavia::LoadBalancer  | CREATE_COMPLETE | 2020-02-19T20:24:19Z |
  +---------------------------+--------------------------------------+----------------------------+-----------------+----------------------+

.. note::

  In case of any ``CREATE_FAILED`` statuses you can interrogate the stack for
  any error codes with the command below.

  .. code-block:: bash

    $ openstack stack failures list autoscaling-stack

  A common reason for resources failing to be created is due to quotas being
  exceeded while attempting to create the stack. Fix any errors that you can,
  then delete the stack and try again.


Once these resources reach "CREATE_COMPLETE" the stack has finished and we
can move on. We are going to create some variables as we will need so that we
can refer to certain resource IDs many times throughout this example. These are
the 'Load balancer ID', 'Autoscaling Group ID', and the 'Load balancer pool ID'

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
  +-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | Field                 | Value                                                                                                                                                                                                                                                                                                                                                                                                                         |
  +-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | scale_up_signal_url   | {                                                                                                                                                                                                                                                                                                                                                                                                                             |
  |                       |   "output_value": "https://api.nz-hlz-1.catalystcloud.io:8004/v1/eac679e4896146e6827ce29d755fe289/stacks/autoscaling-test/b832c222-cd6d-498c-8406-7821d862daff/resources/scaleup_policy/signal",                                                                                                                                                                                                                              |
  |                       |   "output_key": "scale_up_signal_url",                                                                                                                                                                                                                                                                                                                                                                                        |
  |                       |   "description": "No description given"                                                                                                                                                                                                                                                                                                                                                                                       |
  |                       | }                                                                                                                                                                                                                                                                                                                                                                                                                             |
  | scale_down_url        | {                                                                                                                                                                                                                                                                                                                                                                                                                             |
  |                       |   "output_value": "https://api.nz-hlz-1.catalystcloud.io:8000/v1/signal/arn%3Aopenstack%3Aheat%3A%3Aeac679e4896146e6827ce29d755fe289%3Astacks/autoscaling-test/b832c222-cd6d-498c-8406-7821d862daff/resources/scaledown_policy?Timestamp=2020-02-19T20%3A24%3A18Z&SignatureMethod=HmacSHA256&AWSAccessKeyId=232bf05e4ed94509a42cfd6bbf0109e2&SignatureVersion=2&Signature=YtN92H4WjBb0DuNaeYS0m6LITd1BTW6DRORflsp%2BaNM%3D",  |
  |                       |   "output_key": "scale_down_url",                                                                                                                                                                                                                                                                                                                                                                                             |
  |                       |   "description": "No description given"                                                                                                                                                                                                                                                                                                                                                                                       |
  |                       | }                                                                                                                                                                                                                                                                                                                                                                                                                             |
  | lb_ip                 | {                                                                                                                                                                                                                                                                                                                                                                                                                             |
  |                       |   "output_value": "103.197.63.170",                                                                                                                                                                                                                                                                                                                                                                                           |
  |                       |   "output_key": "lb_ip",                                                                                                                                                                                                                                                                                                                                                                                                      |
  |                       |   "description": "No description given"                                                                                                                                                                                                                                                                                                                                                                                       |
  |                       | }                                                                                                                                                                                                                                                                                                                                                                                                                             |
  | scale_up_url          | {                                                                                                                                                                                                                                                                                                                                                                                                                             |
  |                       |   "output_value": "https://api.nz-hlz-1.catalystcloud.io:8000/v1/signal/arn%3Aopenstack%3Aheat%3A%3Aeac679e4896146e6827ce29d755fe289%3Astacks/autoscaling-test/b832c222-cd6d-498c-8406-7821d862daff/resources/scaleup_policy?Timestamp=2020-02-19T20%3A24%3A18Z&SignatureMethod=HmacSHA256&AWSAccessKeyId=a18967d3ec414e2f8717eb4d7c9fecc1&SignatureVersion=2&Signature=3Ywy%2FDFGfm8OTiJ56iPLa4KwtMBL%2FbWWCZEBX10x3AI%3D",  |
  |                       |   "output_key": "scale_up_url",                                                                                                                                                                                                                                                                                                                                                                                               |
  |                       |   "description": "No description given"                                                                                                                                                                                                                                                                                                                                                                                       |
  |                       | }                                                                                                                                                                                                                                                                                                                                                                                                                             |
  | scale_down_signal_url | {                                                                                                                                                                                                                                                                                                                                                                                                                             |
  |                       |   "output_value": "https://api.nz-hlz-1.catalystcloud.io:8004/v1/eac679e4896146e6827ce29d755fe289/stacks/autoscaling-test/b832c222-cd6d-498c-8406-7821d862daff/resources/scaledown_policy/signal",                                                                                                                                                                                                                            |
  |                       |   "output_key": "scale_down_signal_url",                                                                                                                                                                                                                                                                                                                                                                                      |
  |                       |   "description": "No description given"                                                                                                                                                                                                                                                                                                                                                                                       |
  |                       | }                                                                                                                                                                                                                                                                                                                                                                                                                             |
  +-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+


  $ export lb_ip=103.197.63.170
  $ while true; do curl $lb_ip; sleep 2; done
  Welcome to my 10.0.0.173
  Welcome to my 10.0.0.174
  Welcome to my 10.0.0.173
  Welcome to my 10.0.0.174
  Welcome to my 10.0.0.173
  Welcome to my 10.0.0.174


The loadbalancer is alternating the traffic between these two servers on every
request. To keep our service from being slowed down due to intense traffic,
we have created an autoscaling feature. The alarm and the autoscaling policy
were outlined in the yaml files from earlier. The policy is set up so that we
always have at least 2 instances of our webservers running, up to a maximum of
4. The alarm is set up so that should one of the instances CPU usage reach more
than 20%, the stack will scale up and should they reach below 5% then they will
scale down.

We can view the alarms and see that their status is ``insufficient data.``
This is normal as neither of the conditions for their activation have been met.

.. code-block:: bash

  $ openstack alarm list
  +--------------------------------------+--------------+---------------------------------------------------------+-------------------+----------+---------+
  | alarm_id                             | type         | name                                                    | state             | severity | enabled |
  +--------------------------------------+--------------+---------------------------------------------------------+-------------------+----------+---------+
  | 068f05b5-7f39-4cb6-abdf-ba8c54a6abb8 | threshold    | autoscaling-test-ceilometer_cpu_low_alarm-yxxszsyqse7o  | insufficient data | low      | True    |
  | f95884e5-7edb-4f3e-8c92-f29e323fa7a6 | threshold    | autoscaling-test-ceilometer_cpu_high_alarm-nj6g43s4zete | insufficient data | low      | True    |
  +--------------------------------------+--------------+---------------------------------------------------------+-------------------+----------+---------+


Now that we know the alarms are already set up, we can test how they function.
For this example we are going to simulate a high CPU load by using ``stress``
on our server.

To get started we need to SSH to one of our instances. We will first need to
find our instance floating IPs

.. code-block:: bash

  $ openstack server list
  +--------------------------------------+-------------------------------------------------------+--------+----------------------------------------+------------------------------+---------+
  | ID                                   | Name                                                  | Status | Networks                               | Image                        | Flavor  |
  +--------------------------------------+-------------------------------------------------------+--------+----------------------------------------+------------------------------+---------+
  | 138e8312-c6ff-459a-8828-2c16b80879f4 | au-iycd-bb2jcbshf6yk-5hqoctc45ifi-server-2ezgc4jaoy4m | ACTIVE | private-net=10.0.0.174, 103.197.63.187 | ubuntu-18.04-x86_64-20200203 | c1.c1r1 |
  | f656d349-f4be-463e-b1cb-c5da6139c9f9 | au-iycd-ypdn7lmlghbu-o4yeqn3l7lrh-server-nbzj6cp6bfc5 | ACTIVE | private-net=10.0.0.173, 103.197.63.183 | ubuntu-18.04-x86_64-20200203 | c1.c1r1 |
  +--------------------------------------+-------------------------------------------------------+--------+----------------------------------------+------------------------------+---------+

Next we use the floating IP of one of our instances to SSH to the server. We
will then update the system and install stress.

.. code-block:: bash

  $ ssh ubuntu@103.197.63.187
  $ sudo apt update
  $ sudo apt upgrade
  $ sudo apt install stress
  $ stress -c 8 -t 1200s &
  $ exit

After 10 minutes or so the scale up alarm should trigger and change from
'insufficient data' to 'alarm' The alarm will then inform the stack to
create a new instance to handle the increased CPU load.

.. Note::

  The reason it takes 10 minutes for the alarm to trigger is because ceilometer
  has to calculate the CPU usage and the default on our cloud for the time
  window of such calculation is 10 minute intervals.

.. code-block:: bash

  $ openstack alarm list
  +--------------------------------------+----------------------------+---------------------------------------------------------+---------+----------+---------+
  | alarm_id                             | type                       | name                                                    | state   | severity | enabled |
  +--------------------------------------+----------------------------+---------------------------------------------------------+---------+----------+---------+
  | 068f05b5-7f39-4cb6-abdf-ba8c54a6abb8 | threshold                  | autoscaling-test-ceilometer_cpu_low_alarm-yxxszsyqse7o  | ok      | low      | True    |
  | f95884e5-7edb-4f3e-8c92-f29e323fa7a6 | threshold                  | autoscaling-test-ceilometer_cpu_high_alarm-nj6g43s4zete | alarm   | low      | True    |
  +--------------------------------------+----------------------------+---------------------------------------------------------+---------+----------+---------+

Now that the ``autoscaling-test-ceilometer_cpu_high_alarm`` has been triggered
the alarm will notify the stack that it needs to create a new instance to
manage this burst of additional traffic we have artificially created. The new
server gets created and we can see this when we list our servers.

.. code-block:: bash

  $ openstack server list
  +--------------------------------------+-------------------------------------------------------+--------+----------------------------------------+------------------------------+---------+
  | ID                                   | Name                                                  | Status | Networks                               | Image                        | Flavor  |
  +--------------------------------------+-------------------------------------------------------+--------+----------------------------------------+------------------------------+---------+
  | 138e8312-c6ff-459a-8828-2c16b80879f4 | au-iycd-bb2jcbshf6yk-5hqoctc45ifi-server-2ezgc4jaoy4m | ACTIVE | private-net=10.0.0.174, 103.197.63.187 | ubuntu-18.04-x86_64-20200203 | c1.c1r1 |
  | f656d349-f4be-463e-b1cb-c5da6139c9f9 | au-iycd-ypdn7lmlghbu-o4yeqn3l7lrh-server-nbzj6cp6bfc5 | ACTIVE | private-net=10.0.0.173, 103.197.63.183 | ubuntu-18.04-x86_64-20200203 | c1.c1r1 |
  | 1831094d-8674-4d65-a562-c7c055dd0817 | au-3szv-bbkmrjnkqgcc-fw6slqugogph-server-vtmu7gk7dqku | ACTIVE | private-net=10.0.0.191, 103.197.63.10  | ubuntu-18.04-x86_64-20200203 | c1.c1r1 |
  +--------------------------------------+-------------------------------------------------------+--------+----------------------------------------+------------------------------+---------+

Our new instance is live and the load balancer ensures that the workload is
spread evenly. If we go to curl our load balancer IP like earlier we
can see this.

.. code-block:: bash

  $ while true; do curl $lb_ip; sleep 2; done
  Welcome to my 10.0.0.173
  Welcome to my 10.0.0.174
  Welcome to my 10.0.0.175
  Welcome to my 10.0.0.173
  Welcome to my 10.0.0.174
  Welcome to my 10.0.0.175
  Welcome to my 10.0.0.173
  Welcome to my 10.0.0.174
  Welcome to my 10.0.0.175

We have successfully implemented an autoscaling service using an alarm and the
orchestration service on the cloud. You can take what you have learned from
this and implement your own using these services. For now, we will clean up the
resources used in this example using the following:

.. code-block:: bash

  $ openstack stack delete $stackid

