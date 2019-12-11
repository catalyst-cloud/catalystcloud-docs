.. _alarm-service-on-Sky-tv_cloud:

*************
Alarm Service
*************

Overview
========

The alarm service, available through the SKY-TV cloud, allows a user to set
up alarms that monitor the state of various objects in the cloud. The
alarms wait for specific events to occur; then they change their state
depending on pre set parameters. If a state change occurs then actions that
you predefine for the alarm take effect.

For example: You want to monitor a compute instance to see if the CPU
utilization exceeds 70% for more than 10 minutes. Once the alarm has met
this requirement, it changes its state to 'alarm'. The notifier then
tells your system to perform some action. In this scenario it could be to: spin
up a new instance with more CPU power, or increase the amount of VCPUs your
instance is using.

Threshold rules
===============

These are the rules that you define for your alarms. With these you can
specify what events will require a state change to your alarms.

For conventional threshold-oriented alarms, state transitions are governed by:

- A static threshold value with a comparison operator such as greater than or
  less than. e.g. (CPU usage > 70%)

- A statistic selection to aggregate the data.

- A sliding time window to indicate how far back into the recent past you want
  to look. e.g. "test every minute and if for three consecutive minutes
  then..."

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

An autohealing  example
=======================

Prerequisites
-------------
- You must have a working server on your project.
- You must have the ``heat stack owner`` role.
- You must have jq installed.
- You must have a security group with rules to allow ingress on port 22 and 80.
- You must have a network set up that can host the webserver.
- Currently aodh is only available in HLZ and Porirua regions.

Process
-------

For this working example, we will be creating an alarm that monitors a
simulated webserver. We will configure our alarm so that should the webserver
go down the alarm will trigger and implement an autohealing feature.
To create this simulated webserver, we will be using netcat on an Ubuntu image
in our project. The Ubuntu instance will respond to requests with the message:
"Welcome to my <IP address>".

The following is a yaml file that is used to set up the webserver instances
when we create our stack. You will have to change some of the variables in
this script for it to function properly.

Save the following script as a yaml file named webserver.yaml

.. code-block:: bash

   heat_template_version: 2016-10-14

   description: |
     The heat template is used to create a server as a load balancer member.
   parameters:
     keypair:
       type: string
       default: KEYPAIR NAME
     image_id:
       type: string
       default: 0da75c8a-787d-48cd-bb74-e979fc5ceb58 # an ubuntu18 image ID
     flavor_id:
       type: string
       default: c1.c1r1 # Flavor with 1GB RAM and 10GB disk space
     network_id:
       type: string
       default: NETWORK ID
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
             #!/bin/bash
             MYIP=$(/sbin/ifconfig ens3 | grep 'inet '| awk '{print $2}');
             OUTPUT="Welcome to my $MYIP";
             while true; do echo -e "HTTP/1.1 200 OK\r\n\r\n${OUTPUT}\r" | sudo nc -q0 -l -p 80; done
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
     The heat template is used to demo the autoscaling and autohealing for a webserver.
   parameters:
     keypair:
       type: string
       default: KEYPAIR NAME
     webserver_image_id:
       description: changed to use ubuntu 18.04.
       type: string
       default: 0da75c8a-787d-48cd-bb74-e979fc5ceb58 # image ID of ubuntu instance
     webserver_flavor_id:
       type: string
       default: c1.c1r1 # Flavor with 1GB RAM and 10GB disk space
     webserver_network_id:
       type: string
       default: NETWORK ID
     webserver_sg_ids:
       description: |
         Security groups that allows 22/TCP from public and 80/TCP from the local network to allow
         the loadbalancer health checks through.
       type: comma_delimited_list
       default: ["SECURITY GROUP ID"]
     vip_subnet_id:
       description: Should be a subnet of webserver_network_id
       type: string
       default: SUBNET ID
     public_network:
       description: Public network name, could get by 'openstack network list --external'
       type: string
       default: public-net
     scaleup_cpu_threshold:
       type: number
       default: 80
     scaledown_cpu_threshold:
       type: number
       default: 5

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
     scaleup_policy:
       type: OS::Heat::ScalingPolicy
       properties:
         adjustment_type: change_in_capacity
         auto_scaling_group_id: {get_resource: autoscaling_group}
         scaling_adjustment: 1
         cooldown: 60
     scaledown_policy:
       type: OS::Heat::ScalingPolicy
       properties:
         adjustment_type: change_in_capacity
         auto_scaling_group_id: {get_resource: autoscaling_group}
         scaling_adjustment: -1
         cooldown: 60
       type: OS::Aodh::Alarm
       properties:
         meter_name: cpu_util
         period: 60
         evaluation_periods: 1
         statistic: avg
         comparison_operator: gt
         threshold: 5.0
         alarm_actions:
           - {get_attr: [ scaleup_policy, signal_url ] }
         repeat_actions: false
         matching_metadata: { 'metadata.user_metadata.server_group': { get_param: "OS::stack_id" } }
     ceilometer_cpu_low_alarm:
       type: OS::Aodh::Alarm
       properties:
         meter_name: cpu_util
         period: 60
         evaluation_periods: 1
         statistic: avg
         comparison_operator: lt
         threshold: 1.0
         alarm_actions:
           - {get_attr: [ scaledown_policy, signal_url ] }
         repeat_actions: false
         matching_metadata: { 'metadata.user_metadata.server_group': { get_param: "OS::stack_id" } }

   outputs:
     # scale_up_url:
     #   value: {get_attr: [scaleup_policy, alarm_url]}
     # scale_down_url:
     #   value: {get_attr: [scaledown_policy, alarm_url]}
     lb_ip:
       value: {get_attr: [loadbalancer_public_ip, floating_ip_address]}
     lb_vip:
       value: {get_attr: [loadbalancer, vip_address]}


To connect both of these yaml files we will make a third one that allows the
webserver.yaml to be used as an resource for the auto-healing.yaml. It is
one line of code, but the separation of the webserver artefacts and the
loadbalancer artefacts makes it easier to track when editing and is
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

   # WGTN parameters
   e044255f-40c2-48e5-a5f2-60d423e3ec54 | ubuntu-18.04-x86_64
   e0ba6b88-5360-492c-9c3d-119948356fd3 | public-net

   # HLZ parameters
   0da75c8a-787d-48cd-bb74-e979fc5ceb58 | ubuntu-18.04-x86_64
   f10ad6de-a26d-4c29-8c64-2a7418d47f8f | public-net

   # POR parameters
   514fe561-bc07-4d7a-aa57-43ea280d445e | ubuntu-18.04-x86_64
   2e69dea1-53f4-46be-b0e6-74467cf5cc88 | public-net


   # Set some command aliases and install jq
   alias o="openstack"
   alias lb="openstack loadbalancer"
   alias osrl="openstack stack resource list"
   alias osl="openstack stack list"
   sudo apt install -y jq

   # First, create the Head stack using the template files and wait until it's created successfully
   # Change the default value of the parameters defined in autohealing.yaml

   o stack create autohealing-test -t autohealing.yaml -e env.yaml
   export stackid=$(o stack show autohealing-test -c id -f value) && echo $stackid

   watch openstack stack resource list $stackid
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

   # Verify that we could send HTTP request to the load balancer VIP, the backend VMs IP addresses are shown alternatively.
   # The VIP floating IP could be found in the stack output.
   $ o stack output show $stackid --all
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

   # Get the resources IDs
   lbid=$(lb list | grep webserver_lb | awk '{print $2}');
   asgid=$(o stack resource list $stackid | grep autoscaling_group | awk '{print $4}');
   poolid=$(lb status show $lbid | jq -r '.loadbalancer.listeners[0].pools[0].id')

   # Verify the load balancer members are all healthy
   $ lb member list $poolid
   +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
   | id                                   | name | project_id                       | provisioning_status | address       | protocol_port | operating_status | weight |
   +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
   | 4eeac1a8-7837-41d9-8299-8d8f9f691b69 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.200 |            80 | ONLINE           |      1 |
   | 2acbd21e-39d5-41fe-8fb9-b3d61333f0c9 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.201 |            80 | ONLINE           |      1 |
   +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+

   # perform the alarm setup using openstack cli
   $ echo $lbid $asgid $poolid $stackid
   0db8dcc8-77c1-4682-8213-21f4e90cafd1
   9ec5bb8c-3b7f-4a71-858d-cb73d0d03b4e
   0da0911a-0b07-4937-99ab-c6f6e3404c39
   cc55271e-ddcd-4db0-8803-265f23297849

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
   | user_id                   | 4b934c44d8b24e60acad9609b641bee3      |
   +---------------------------+---------------------------------------+

   # Log into one of the VMs and manually kill the webserver process
   $ o server list
   +--------------------------------------+-------------------------------------------------------+--------+-----------------------------------------+---------------------+---------+
   | ID                                   | Name                                                  | Status | Networks                                | Image               | Flavor  |
   +--------------------------------------+-------------------------------------------------------+--------+-----------------------------------------+---------------------+---------+
   | 4a35a813-ac9a-4195-9b25-ad5d9381f68e | au-5z37-rowgvu2inhwa-25buammtmf2s-server-mkvfo7vxlv64 | ACTIVE | lingxian_net=192.168.2.200, 10.17.9.148 | cirros-0.3.1-x86_64 | m1.tiny |
   | b80aa773-7330-4a00-9666-12980059050b | au-5z37-hlzbc66r2vrc-h6qxnp7n5wru-server-wyf3dksa6w3v | ACTIVE | lingxian_net=192.168.2.201, 10.17.9.147 | cirros-0.3.1-x86_64 | m1.tiny |
   +--------------------------------------+-------------------------------------------------------+--------+-----------------------------------------+---------------------+---------+

   $ ssh ubuntu@103.197.62.142
   $ curl localhost
   Welcome to my 10.0.0.105
   $ ps -ef |grep bash|grep script|grep -v grep
   root      1149  1117  0 19:24 ?        00:00:00 /bin/bash /var/lib/cloud/instance/scripts/part-001
   ubuntu    3233  3230  0 19:50 pts/0    00:00:00 -bash
   $ sudo kill -9 1149
   $ curl localhost
   curl: (7) couldn't connect to host

   # After a few seconds, you should see there is one load balancer member in ERROR operating_status.
   $ lb member list $poolid
   +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
   | id                                   | name | project_id                       | provisioning_status | address       | protocol_port | operating_status | weight |
   +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
   | 4eeac1a8-7837-41d9-8299-8d8f9f691b69 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.200 |            80 | ONLINE           |      1 |
   | 2acbd21e-39d5-41fe-8fb9-b3d61333f0c9 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.201 |            80 | ERROR            |      1 |
   +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+

   # Aodh will automatically trigger Heat stack update, keep checking the autoscaling_group resource status. At the same time, there should be only one IP address in the http response.
   $ while true; do curl $vip; sleep 2; done
   Welcome to my 192.168.2.200
   Welcome to my 192.168.2.200
   Welcome to my 192.168.2.200
   Welcome to my 192.168.2.200
   $ osrl $stackid
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
   $ osrl $stackid
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
   $ lb member list $poolid
   +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
   | id                                   | name | project_id                       | provisioning_status | address       | protocol_port | operating_status | weight |
   +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
   | 4eeac1a8-7837-41d9-8299-8d8f9f691b69 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.200 |            80 | ONLINE           |      1 |
   | f354fe18-c801-4729-90bb-0af29048ef46 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.202 |            80 | ONLINE           |      1 |
   +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
   $ while true; do curl $vip; sleep 2; done
   Welcome to my 192.168.2.200
   Welcome to my 192.168.2.202
   Welcome to my 192.168.2.200
   Welcome to my 192.168.2.202


   # Now we can clean up this stack:

   $ o stack delete $stackid

For more information on the Alarm service, you can visit `the openstack
documentation on aodh`_

.. _`the openstack documentation on aodh`: https://docs.openstack.org/aodh/latest/admin/telemetry-alarms.html
