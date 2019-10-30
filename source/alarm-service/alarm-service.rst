.. _alarm-service-on-Sky-tv_cloud:


*************
Alarm Service
*************

Overview
========

The alarm service, available through the SKY-TV cloud, allows a user to set
up alarms that are monitoring the state of various objects in the cloud. The
alarms wait for specific events to occur; then they change their state
depending on pre set parameters. If a state change occurs then actions that
you predefine for the alarm take effect.

For example: You want to monitor a compute instance to see if the CPU
utilization exceeds 70% for more than 10 minutes. Once the alarm has met
this requirement, it changes its state to 'alarm'. The alarm notifier then tells
your system to perform some action. In this scenario it could be to: spin up a
new instance with more CPU power, or increase the amount of VCPUs your
instance is using. Whatever your goal is the alarm keeps you informed of the
state of your machine so you can implement things such as auto-scaling.

Threshold rules
===============

These are the rules that you define for your alarms. With these you can
specify what events will require a state change for your system to evaluate to
'alarm' or not.

For conventional threshold-oriented alarms, state transitions are governed by:

- A static threshold value with a comparison operator such as greater than or
  less than. e.g. (CPU usage > 70%)

- A statistic selection to aggregate the data.

- A sliding time window to indicate how far back into the recent past you want
  to look. e.g. (test every minute and if for three consecutive minutes
  then...)

After setting up your rules, your alarm should appear in one of the following
states:

- ``ok`` The rule governing the alarm has been evaluated as False.

- ``alarm`` The rule governing the alarm has been evaluated as True.

- ``insufficient data`` There are not enough datapoints available in the
  evaluation periods to meaningfully determine the alarm state.

Composite alarms
----------------

These enable users to have multiple triggering conditions, using
``and`` and ``or`` relations, on their alarms. For example, "if CPU usage >
70% for more than 10 minutes OR CPU usage > 90% for more than 1 minute..."


A working example
=================

For this working example, we will be creating an alarm that monitors a
webserver and autoheals should the server go down for some reason.

Prerequisites
-------------
- You must have a working server on your project.
- You must have the ``heat stack owner`` role.
- Must have jq installed

Process
-------

The first thing that we need to understand is what our webserver
will be doing. For the purposes of this example, we will be using netcat on an
Ubuntu image to simulate a webserver in our project. The Ubuntu instance
responds to requests with the message: "Welcome to my <IP address>".

The following is a yaml file that is used to set up the webserver instances
when we create our stack. You will have to change some of the variables in
this script for it to function properly.

You will need to save the following script as a yaml file named webserver.yaml

.. code-block:: bash

  heat_template_version: 2016-10-14

  description: |
    The heat template is used to create a server as a load balancer member.
  parameters:
    keypair:
      type: string
      default: <KEY-PAIR>
    image_id:
      type: string
      default: <WEBSERVER IMAGE ID>
    flavor_id:
      type: string
      default: c1.c1r1
    network_id:
      type: string
      default: <NETWORK ID>
    sg_ids:
      type: comma_delimited_list
    public_network:
      type: string
    pool_id:
      type: string
      default: no_default
      hidden: true
    metadata:
      type: json

  resources:
    server:
      type: OS::Nova::Server
      properties:
        image: { get_param: image_id }
        flavor: { get_param: flavor_id }
        networks:
          - network: {get_param: network_id}
        key_name: {get_param: keypair}
        security_groups: {get_param: sg_ids}
        metadata: {get_param: metadata}
        config_drive: true
        user_data_format: RAW
        user_data: |
            #!/bin/sh
            MYIP=$(/sbin/ifconfig ens3 | grep 'inet '| awk '{print $2}');
            OUTPUT="Welcome to my $MYIP";
            while true; do echo "HTTP/1.1 200 OK\r\n\r\n${OUTPUT}\r" | sudo nc -l -p 80; done
    pool_member:
      type: OS::Octavia::PoolMember
      properties:
        address: {get_attr: [server, first_address]}
        pool: {get_param: pool_id}
        protocol_port: 80
    server_public_ip:
      type: OS::Neutron::FloatingIP
      properties:
        floating_network: {get_param: public_network}
        port_id: {get_attr: [server, addresses, {get_param: network_id}, 0, port]}

  outputs:
    server_id:
      value: {get_resource: server}

Next, we need to set up the constructs required to have our loadbalanced self
healing webservers. The following yaml will create a loadbalancer, an
autoscaling group and a health monitor. This script also communicates with the
webserver yaml to spin up the two Ubuntu instances to simulate the webservers.
After these are created we will attach an alarm.

Save this yaml as autohealing.yaml

.. code-block:: bash

  heat_template_version: 2016-10-14

  description: |
    The heat template is used to demo the autoscaling and auto-healing for a webserver.
  parameters:
    keypair:
      type: string
      default: <KEYPAIR>
    webserver_image_id:
      description: Need to be an Ubuntu image.
      type: string
      default: <UBUNTU IMAGE ID>
    webserver_flavor_id:
      type: string
      default: c1.c1r1
    webserver_network_id:
      type: string
      default: <WEBSERVER NETWORK ID>
    webserver_sg_ids:
      description: |
        Security groups that allows 22/TCP access from public network and
        80/TCP from the <WEBSERVER NETWORK ID> CIDR
      type: comma_delimited_list
      default: ["<SECURITY GROUP ID>"]
    vip_subnet_id:
      description: Should be a subnet of webserver_network_id
      type: string
      default: <SUBNET ID>>
    public_network:
      description: Public network name, could get by 'openstack network list --external'
      type: string
      default: <PUBLIC ID>

  resources:
    autoscaling_group:
      type: OS::Heat::AutoScalingGroup
      properties:
        min_size: 2
        max_size: 4
        resource:
          type: OS::LB::Server
          properties:
            keypair: {get_param: keypair}
            image_id: {get_param: webserver_image_id}
            flavor_id: {get_param: webserver_flavor_id}
            network_id: {get_param: webserver_network_id}
            sg_ids: {get_param: webserver_sg_ids}
            public_network: {get_param: public_network}
            pool_id: {get_resource: loadbalancer_pool}
            metadata: {"metering.server_group": {get_param: "OS::stack_id"}}
    loadbalancer:
      type: OS::Octavia::LoadBalancer
      properties:
        vip_subnet: {get_param: vip_subnet_id}
        name: webserver_lb
    loadbalancer_public_ip:
      type: OS::Neutron::FloatingIP
      properties:
        floating_network: {get_param: public_network}
        port_id: {get_attr: [loadbalancer, vip_port_id]}
    listener:
      type: OS::Octavia::Listener
      properties:
        name: webserver_listener
        protocol: HTTP
        protocol_port: 80
        loadbalancer: {get_resource: loadbalancer}
    loadbalancer_pool:
      type: OS::Octavia::Pool
      properties:
        lb_algorithm: ROUND_ROBIN
        protocol: HTTP
        listener: {get_resource: listener}
    loadbalancer_healthmonitor:
      type: OS::Octavia::HealthMonitor
      properties:
        delay: 5
        max_retries: 3
        pool: {get_resource: loadbalancer_pool}
        timeout: 15
        type: HTTP
        http_method: GET
        expected_codes: 200


To connect both of these yaml files we will make a third one that allows the
webserver.yaml to be used as an resource for the auto-healing.yaml. It is
one line of code, but the separation of the webserver artifacts and the
loadbalancer artifacts makes it easier to track when editing and is
a good practice.

Save this file as env.yaml:

.. code-block:: bash

 resource_registry:
   OS::LB::Server: webserver.yaml


Now, after you have changed the variables in your yaml files, we need to
check whether our templates are valid. This is done with the following
commands:

.. code-block:: bash

  $ openstack orchestration template validate -f yaml -t autohealing.yaml
  $ openstack orchestration template validate -f yaml -t webserver.yaml

If your template is valid the console will print out the template, if the
template is invalid the console will return an error message instead.

As long as our templates are valid, we can go to the next step which is
creating the stack.

.. code-block:: bash

  $ openstack stack create autohealing-test -t autohealing.yaml -e env.yaml

  +---------------------+-------------------------------------------------------------------------------------+
  | Field               | Value                                                                               |
  +---------------------+-------------------------------------------------------------------------------------+
  | id                  | 94dd128a-3a9a-4473-96c6-77591e39e5ed                                                |
  | stack_name          | autohealing-test                                                                    |
  | description         | The heat template is used to demo the autoscaling and auto-healing for a webserver. |
  |                     |                                                                                     |
  | creation_time       | 2019-10-17T21:39:10Z                                                                |
  | updated_time        | None                                                                                |
  | stack_status        | CREATE_IN_PROGRESS                                                                  |
  | stack_status_reason | Stack CREATE started                                                                |
  +---------------------+-------------------------------------------------------------------------------------+

  # Make a variable for the stack id to use in future commands:
  export stackid=$(o stack show autohealing-test -c id -f value) && echo $stackid

  $ openstack stack resource list $stackid

  +----------------------------+--------------------------------------+----------------------------+--------------------+----------------------+
  | resource_name              | physical_resource_id                 | resource_type              | resource_status    | updated_time         |
  +----------------------------+--------------------------------------+----------------------------+--------------------+----------------------+
  | loadbalancer_public_ip     |                                      | OS::Neutron::FloatingIP    | INIT_COMPLETE      | 2019-10-17T21:39:11Z |
  | autoscaling_group          |                                      | OS::Heat::AutoScalingGroup | INIT_COMPLETE      | 2019-10-17T21:39:11Z |
  | listener                   |                                      | OS::Octavia::Listener      | INIT_COMPLETE      | 2019-10-17T21:39:11Z |
  | loadbalancer_healthmonitor |                                      | OS::Octavia::HealthMonitor | INIT_COMPLETE      | 2019-10-17T21:39:11Z |
  | loadbalancer_pool          |                                      | OS::Octavia::Pool          | INIT_COMPLETE      | 2019-10-17T21:39:11Z |
  | loadbalancer               | ccb89934-4a8a-4c0b-9b72-145e3c86c311 | OS::Octavia::LoadBalancer  | CREATE_IN_PROGRESS | 2019-10-17T21:39:11Z |
  +----------------------------+--------------------------------------+----------------------------+--------------------+----------------------+

Now the stack is creating all of our resources defined in the yaml files.
This can take some time and so you may have to re-run the previous command to
see the status of your resources. You can also view the stack progress on the
dashboard via
`the orchestration tab <https://dashboard.cloud.catalyst.net.nz/project/stacks/>`_.
You will have to wait until all resources are at the status CREATE_COMPLETE.
Once your stack is completed and ready to access, we do the following to
acquire the VIP for the loadbalancer:

.. code-block:: bash

  $ openstack stack output show $stackid --all

  +-------+-----------------------------------------+
  | Field | Value                                   |
  +-------+-----------------------------------------+
  | lb_ip | {                                       |
  |       |   "output_value": "103.254.156.149",    |
  |       |   "output_key": "lb_ip",                |
  |       |   "description": "No description given" |
  |       | }                                       |
  +-------+-----------------------------------------+

Once we have the VIP we can curl our webserver to make sure that it is working
correctly.

.. code-block:: bash

  # replace the IP here with the results from the previous output.
  $ while true; do curl 103.254.156.149; sleep 2; done
  Welcome to my 10.0.0.80
  Welcome to my 10.0.0.81
  Welcome to my 10.0.0.80
  Welcome to my 10.0.0.81

  # to stop this process you can press ctrl Z or ctrl C

  # from here we need to set up some more variables for our Resource IDs.
  lbid=$(openstack loadbalancer list | grep webserver_lb | awk '{print $2}')
  asgid=$(openstack stack resource list $stackid | grep autoscaling_group | awk '{print $4}')
  poolid=$(openstack loadbalancer status show $lbid | jq -r '.loadbalancer.listeners[0].pools[0].id')

So far we have created our loadbalancer, our webserver, set up some resource
ID aliases and have checked to make sure that the webserver is behaving as
expected. Now we need to check that our loadbalancers are healthy.

.. code-block:: bash

  $ openstack loadbalancer member list $poolid

  +--------------------------------------+------+----------------------------------+---------------------+-----------+---------------+------------------+--------+
  | id                                   | name | project_id                       | provisioning_status | address   | protocol_port | operating_status | weight |
  +--------------------------------------+------+----------------------------------+---------------------+-----------+---------------+------------------+--------+
  | db19f0f8-a769-4640-8702-3101a3592af1 |      | eac679e4896146e6827ce29d755fe289 | ACTIVE              | 10.0.0.80 |            80 | ONLINE           |      1 |
  | 2f358812-02c1-4bf5-a7c5-578b66b7feca |      | eac679e4896146e6827ce29d755fe289 | ACTIVE              | 10.0.0.81 |            80 | ONLINE           |      1 |
  +--------------------------------------+------+----------------------------------+---------------------+-----------+---------------+------------------+--------+

If your loadbalancer's operating_status is not ONLINE then you may have to wait
for the cloud init scripts to finish. Once the loadbalancers are healthy you
are able to create the alarm.

.. code-block:: bash

  $ aodh_prefix="https://api.cloud.catalyst.net.nz:8042"
  $ token=$(openstack token issue -f yaml -c id | awk '{print $2}')

  cat <<EOF | http post ${aodh_prefix}/v2/alarms X-Auth-Token:$token
  {
    "alarm_actions": ["trust+heat://"],
    "name": "test_lb_alarm",
    "repeat_actions": false,
    "loadbalancer_member_health_rule": {
      "pool_id": "$poolid",
      "stack_id": "$stackid",
      "autoscaling_group_id": "$asgid"
    },
    "type": "loadbalancer_member_health"
  }
  EOF

We have now created our alarm listener and set it to watch our stack. To
make sure our alarm is working as intended, we need to force an event that
would trigger the threshold rule of our alarm. Since we have set up autohealing
in this example, we are going to kill one of the 'webserver' processes running
on our instances and then monitor to see how our autohealing handles it.

.. code-block:: bash

  # chose one of the instances created with the previous commands
  $ openstack server list
  +--------------------------------------+-------------------------------------------------------+-------------------+------------------------------------------+------------------------------+---------+
  | ID                                   | Name                                                  | Status            | Networks                                 | Image                        | Flavor  |
  +--------------------------------------+-------------------------------------------------------+-------------------+------------------------------------------+------------------------------+---------+
  | 15128ab5-9cc1-4431-96df-116d559d6174 | au-enga-d5aumrvqcfnt-tgyrbcqyamjs-server-wbm6byfme5px | ACTIVE            | private-net-1=10.0.0.92, 103.254.156.166 | ubuntu-18.04-x86_64          | c1.c1r1 |
  | 44d83149-df02-4858-8dd7-b571a130fc36 | au-enga-qxleizgeetgo-patreg6ttmwn-server-7doecymjpdzs | ACTIVE            | private-net-1=10.0.0.91, 103.254.156.17  | ubuntu-18.04-x86_64          | c1.c1r1 |
  +--------------------------------------+-------------------------------------------------------+-------------------+------------------------------------------+------------------------------+---------+

  # SSH to that instance and kill the program that posts 'welcome to my IP'

  $ ssh ubuntu@103.254.156.166
  $ curl localhost
  Welcome to my 10.0.0.105
  $ ps -ef |grep bash|grep script|grep -v grep
  root      1149  1117  0 19:24 ?        00:00:00 /bin/bash /var/lib/cloud/instance/scripts/part-001
  ubuntu    3233  3230  0 19:50 pts/0    00:00:00 -bash
  $ sudo kill -9 1149
  $ curl localhost
  curl: (7) couldn't connect to host

After this you will see that one of your load balancer members in ERROR
operating_status.

.. code-block:: bash

  $ openstack loadbalancer member list $poolid
  +--------------------------------------+----------------------------------+---------------------+-----------+------------------+--------+----------------+
  | id                                   | project_id                       | provisioning_status | address   | operating_status | weight | protocol_port  |
  +--------------------------------------+----------------------------------+---------------------+-----------+------------------+--------+----------------+
  | db19f0f8-a769-4640-8702-3101a3592af1 | eac679e4896146e6827ce29d755fe289 | ACTIVE              | 10.0.0.80 | ONLINE           |      1 |             80 |
  | 2f358812-02c1-4bf5-a7c5-578b66b7feca | eac679e4896146e6827ce29d755fe289 | ACTIVE              | 10.0.0.81 | ERROR            |      1 |             80 |
  +--------------------------------------+----------------------------------+---------------------+-----------+------------------+--------+----------------+

  # Alarm will automatically trigger Heat stack update and will monitor the autoscaling_group resource status.
  # while this is happening there should only be one IP in the http response
  $ while true; do curl $vip; sleep 2; done
  Welcome to my 10.0.0.80
  Welcome to my 10.0.0.80
  Welcome to my 10.0.0.80
  Welcome to my 10.0.0.80

  $ openstack stack resource list $stackid
  +----------------------------+--------------------------------------+----------------------------+--------------------+----------------------+
  | resource_name              | physical_resource_id                 | resource_type              | resource_status    | updated_time         |
  +----------------------------+--------------------------------------+----------------------------+--------------------+----------------------+
  | loadbalancer_public_ip     |                                      | OS::Neutron::FloatingIP    | CREATE_COMPLETE    | 2019-10-17T21:39:11Z |
  | autoscaling_group          |                                      | OS::Heat::AutoScalingGroup | UPDATE_IN_PROGRESS | 2019-10-17T21:39:11Z |
  | listener                   |                                      | OS::Octavia::Listener      | CREATE_COMPLETE    | 2019-10-17T21:39:11Z |
  | loadbalancer_healthmonitor |                                      | OS::Octavia::HealthMonitor | CREATE_COMPLETE    | 2019-10-17T21:39:11Z |
  | loadbalancer_pool          |                                      | OS::Octavia::Pool          | CREATE_COMPLETE    | 2019-10-17T21:39:11Z |
  | loadbalancer               | ccb89934-4a8a-4c0b-9b72-145e3c86c311 | OS::Octavia::LoadBalancer  | CREATE_COMPLETE    | 2019-10-17T21:39:11Z |
  +----------------------------+--------------------------------------+----------------------------+--------------------+----------------------+

  #After a few minutes, the stack status goes back to healthy, the ERROR load balancer member is replaced and the stack is 'autohealed'
  $ openstack stack resource list $stackid
  +----------------------------+--------------------------------------+----------------------------+------------------+----------------------+
  | resource_name              | physical_resource_id                 | resource_type              | resource_status  | updated_time         |
  +----------------------------+--------------------------------------+----------------------------+------------------+----------------------+
  | loadbalancer_public_ip     |                                      | OS::Neutron::FloatingIP    | CREATE_COMPLETE  | 2019-10-17T21:39:11Z |
  | autoscaling_group          |                                      | OS::Heat::AutoScalingGroup | CREATE_COMPLETE  | 2019-10-17T21:39:11Z |
  | listener                   |                                      | OS::Octavia::Listener      | CREATE_COMPLETE  | 2019-10-17T21:39:11Z |
  | loadbalancer_healthmonitor |                                      | OS::Octavia::HealthMonitor | CREATE_COMPLETE  | 2019-10-17T21:39:11Z |
  | loadbalancer_pool          |                                      | OS::Octavia::Pool          | CREATE_COMPLETE  | 2019-10-17T21:39:11Z |
  | loadbalancer               | ccb89934-4a8a-4c0b-9b72-145e3c86c311 | OS::Octavia::LoadBalancer  | CREATE_COMPLETE  | 2019-10-17T21:39:11Z |
  +----------------------------+--------------------------------------+----------------------------+------------------+----------------------+

  $ openstack loadbalancer member list $poolid
  +--------------------------------------+------+----------------------------------+---------------------+-----------+---------------+------------------+--------+
  | id                                   | name | project_id                       | provisioning_status | address   | protocol_port | operating_status | weight |
  +--------------------------------------+------+----------------------------------+---------------------+-----------+---------------+------------------+--------+
  | db19f0f8-a769-4640-8702-3101a3592af1 |      | eac679e4896146e6827ce29d755fe289 | ACTIVE              | 10.0.0.80 |            80 | ONLINE           |      1 |
  | 2f358812-02c1-4bf5-a7c5-578b66b7feca |      | eac679e4896146e6827ce29d755fe289 | ACTIVE              | 10.0.0.81 |            80 | ONLINE           |      1 |
  +--------------------------------------+------+----------------------------------+---------------------+-----------+---------------+------------------+--------+
  $ while true; do curl $vip; sleep 2; done
  Welcome to my 10.0.0.81
  Welcome to my 10.0.0.80
  Welcome to my 10.0.0.81
  Welcome to my 10.0.0.80


For more information on the Alarm service, you can visit `the openstack
documentation on aodh`_

.. _`the openstack documentation on aodh`: https://docs.openstack.org/aodh/latest/admin/telemetry-alarms.html
