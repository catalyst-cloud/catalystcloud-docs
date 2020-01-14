.. _autoscaling-on-catalyst-cloud:

*******************
Autoscaling example
*******************

Prerequisites
-------------
The prerequisites for this example are the same as the previous one.

- You must have a working server on your project.
- You must have the ``heat stack owner`` role.
- You must have jq installed.
- You must have a security group with rules to allow ingress on port 22 and 80.
- You must have a network set up that can host the webserver.

Process
-------

In this example we will be showing you how to set up auto-scaling for our
webservers using AODH. We will be using ubuntu images just like the previous
example to simulate our webservers. The following script should be saved and
run from the command line, the webserver.yaml and env.yaml from the previous
example can be reused.

Save the following file as autoscaling.yaml

.. code-block:: yaml

  heat_template_version: 2016-10-14

  description: |
    The heat template is used to demo the autoscaling.
  parameters:
    keypair:
      type: string
      default: KEYPAIR NAME
    webserver_image_id:
      description: Using an ubuntu image to simulate a webserver.
      type: string
      default: 0da75c8a-787d-48cd-bb74-e979fc5ceb58 #This image is for the HLZ region
    webserver_flavor_id:
      type: string
      default: c1.c1r1
    webserver_network_id:
      type: string
      default: NETWORK ID
    webserver_sg_ids:
      description: Security groups that allows TCP 22 access
      type: comma_delimited_list
      default: ["SECURITY_GROUP ID"]
    vip_subnet_id:
      description: Should be a subnet of webserver_network_id
      type: string
      default: SUBNET ID
    public_network:
      description: Public network name, could get by 'openstack network list --external'
      type: string
      default: public-net
    scaleup_cpu_threshold:
      description: These are the CPU levels in percentages that must be met before the any scaling will occur.
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
            metadata: {"metering.stack": {get_param: "OS::stack_id"}}
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
    ceilometer_cpu_high_alarm:
      type: OS::Aodh::Alarm
      properties:
        meter_name: cpu_util
        period: 60
        evaluation_periods: 1
        statistic: avg
        comparison_operator: gt
        threshold: 5.0
        alarm_actions:
          - {get_attr: [ scaleup_policy, alarm_url ] }
          # - str_replace:
          #     template: trust+url
          #     params:
          #       url: {get_attr: [scaleup_policy, signal_url]}
        repeat_actions: false
        matching_metadata: { 'metadata.user_metadata.stack': { get_param: "OS::stack_id" } }
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
          - {get_attr: [ scaledown_policy, alarm_url ] }
          # - str_replace:
          #     template: trust+url
          #     params:
          #       url: {get_attr: [scaledown_policy, signal_url]}
        repeat_actions: false
        matching_metadata: { 'metadata.user_metadata.stack': { get_param: "OS::stack_id" } }

  outputs:
    scale_up_url:
      value: {get_attr: [scaleup_policy, alarm_url]}
    scale_down_url:
      value: {get_attr: [scaledown_policy, alarm_url]}
    scale_up_signal_url:
      value: {get_attr: [scaleup_policy, signal_url]}
    scale_down_signal_url:
      value: {get_attr: [scaledown_policy, signal_url]}
    lb_ip:
      value: {get_attr: [loadbalancer_public_ip, floating_ip_address]}

The process going forward will create a stack with two webserver images and
create an alarm that will monitor them; scaling them up if their CPU usage
exceeds 80%. Unlike the previous example, the alarm is created at the same time
as the stack, so you will not have to manually create it yourself:

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
  $ alias o="openstack"
  $ alias lb="openstack loadbalancer"
  $ alias osrl="openstack stack resource list"
  $ alias osl="openstack stack list"
  $ sudo apt install -y jq

  # Following the first few steps from the previous example; the only change being we are
  # using autoscaling.yaml instead of autohealing.yaml

  $ o stack create autoscaling-test -t autoscaling.yaml -e env.yaml
  $ export stackid=$(o stack show autoscaling-test -c id -f value) && echo $stackid

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

  # Verify that we could send HTTP request to the load balancer VIP, the backend VMs IP addresses are shown alternatively.
  # The VIP floating IP could be found in the stack output.

  $ o stack output show $stackid --all
  +-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | Field                 | Value                                                                                                                                                                                                                                                                                                                                                                                                                         |
  +-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | scale_up_signal_url   | {                                                                                                                                                                                                                                                                                                                                                                                                                             |
  |                       |   "output_value": "https://api.nz-hlz-1.catalystcloud.io:8004/v1/eac679e4896146e6827ce29d755fe289/stacks/autoscaling-test/08b2edcc-5ada-43e9-b802-21c03fdaa286/resources/scaleup_policy/signal",                                                                                                                                                                                                                              |
  |                       |   "output_key": "scale_up_signal_url",                                                                                                                                                                                                                                                                                                                                                                                        |
  |                       |   "description": "No description given"                                                                                                                                                                                                                                                                                                                                                                                       |
  |                       | }                                                                                                                                                                                                                                                                                                                                                                                                                             |
  | scale_down_url        | {                                                                                                                                                                                                                                                                                                                                                                                                                             |
  |                       |   "output_value": "https://api.nz-hlz-1.catalystcloud.io:8000/v1/signal/arn%3Aopenstack%3Aheat%3A%3Aeac679e4896146e6827ce29d755fe289%3Astacks/autoscaling-test/08b2edcc-5ada-43e9-b802-21c03fdaa286/resources/scaledown_policy?Timestamp=2019-12-29T21%3A24%3A46Z&SignatureMethod=HmacSHA256&AWSAccessKeyId=7d44d87fb5204d6c8551e75777c053b1&SignatureVersion=2&Signature=jqiUeq%2BS61DnG3n0axTyZoKDPXshKRU2uIdCXogWlCg%3D",  |
  |                       |   "output_key": "scale_down_url",                                                                                                                                                                                                                                                                                                                                                                                             |
  |                       |   "description": "No description given"                                                                                                                                                                                                                                                                                                                                                                                       |
  |                       | }                                                                                                                                                                                                                                                                                                                                                                                                                             |
  | lb_ip                 | {                                                                                                                                                                                                                                                                                                                                                                                                                             |
  |                       |   "output_value": "103.197.60.15",                                                                                                                                                                                                                                                                                                                                                                                            |
  |                       |   "output_key": "lb_ip",                                                                                                                                                                                                                                                                                                                                                                                                      |
  |                       |   "description": "No description given"                                                                                                                                                                                                                                                                                                                                                                                       |
  |                       | }                                                                                                                                                                                                                                                                                                                                                                                                                             |
  | scale_up_url          | {                                                                                                                                                                                                                                                                                                                                                                                                                             |
  |                       |   "output_value": "https://api.nz-hlz-1.catalystcloud.io:8000/v1/signal/arn%3Aopenstack%3Aheat%3A%3Aeac679e4896146e6827ce29d755fe289%3Astacks/autoscaling-test/08b2edcc-5ada-43e9-b802-21c03fdaa286/resources/scaleup_policy?Timestamp=2019-12-29T21%3A24%3A46Z&SignatureMethod=HmacSHA256&AWSAccessKeyId=b6aebef21f2c4ff4b2a484398f0c37ce&SignatureVersion=2&Signature=hgIKy3qCsotAQcPdm9ze8LszQzfG0SvJdcohVRHdJ78%3D",      |
  |                       |   "output_key": "scale_up_url",                                                                                                                                                                                                                                                                                                                                                                                               |
  |                       |   "description": "No description given"                                                                                                                                                                                                                                                                                                                                                                                       |
  |                       | }                                                                                                                                                                                                                                                                                                                                                                                                                             |
  | scale_down_signal_url | {                                                                                                                                                                                                                                                                                                                                                                                                                             |
  |                       |   "output_value": "https://api.nz-hlz-1.catalystcloud.io:8004/v1/eac679e4896146e6827ce29d755fe289/stacks/autoscaling-test/08b2edcc-5ada-43e9-b802-21c03fdaa286/resources/scaledown_policy/signal",                                                                                                                                                                                                                            |
  |                       |   "output_key": "scale_down_signal_url",                                                                                                                                                                                                                                                                                                                                                                                      |
  |                       |   "description": "No description given"                                                                                                                                                                                                                                                                                                                                                                                       |
  |                       | }                                                                                                                                                                                                                                                                                                                                                                                                                             |
  +-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

  $ export lb_ip=103.197.60.15
  $ while true; do curl $lb_ip; sleep 2; done
  Welcome to my 192.168.2.200
  Welcome to my 192.168.2.201
  Welcome to my 192.168.2.200
  Welcome to my 192.168.2.201

  # Get the resources IDs
  $ lbid=$(lb list | grep webserver_lb | awk '{print $2}');
  $ asgid=$(o stack resource list $stackid | grep autoscaling_group | awk '{print $4}');
  $ poolid=$(lb status show $lbid | jq -r '.loadbalancer.listeners[0].pools[0].id')

  # Verify the load balancer members are all healthy
  $ lb member list $poolid
  +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
  | id                                   | name | project_id                       | provisioning_status | address       | protocol_port | operating_status | weight |
  +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
  | 4eeac1a8-7837-41d9-8299-8d8f9f691b69 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.200 |            80 | ONLINE           |      1 |
  | 2acbd21e-39d5-41fe-8fb9-b3d61333f0c9 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.201 |            80 | ONLINE           |      1 |
  +--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+

  # The autoscaling.yaml file has already set up our alarms. So we can skip that step from the previous example.

  # When we look at our alarms before increasing the CPU workload we see the following:

  $ o alarm list
  +--------------------------------------+-----------+---------------------------------------------------------+-------------------+----------+---------+
  | alarm_id                             | type      | name                                                    | state             | severity | enabled |
  +--------------------------------------+-----------+---------------------------------------------------------+-------------------+----------+---------+
  | 9c245bcc-d31e-4219-ab50-f19d2dd8d0e9 | threshold | autohealing-test-ceilometer_cpu_high_alarm-hpik52fcq7xc | insufficient data | low      | True    |
  | 11578915-f140-4095-a977-51ae861f1cd2 | threshold | autohealing-test-ceilometer_cpu_low_alarm-xzclw6ejci64  | insufficient data | low      | True    |
  +--------------------------------------+-----------+---------------------------------------------------------+-------------------+----------+---------+

Next we have to trigger one of the alarms that we created. To do this we SSH to
one of our instances and use "stress" which is a simple stress testing program.
Because our images are from a base Ubuntu image they do not come with stress
already pre installed. We will have to install it manually.

.. code-block:: bash

  $ o server list #to find the floating IP of the instance
  $ ssh ubuntu@103.197.60.167
  $ sudo apt update
  $ sudo apt upgrade
  $ sudo apt install stress
  $ stress -c 8 -t 1200s &
  $ exit

  # After a few minutes your alarm should trigger and go from 'insufficient data' to 'alarm'
  # The alarm will then create a new instance to keep up with the increased CPU load.

  $ o alarm list
  +--------------------------------------+-----------+---------------------------------------------------------+-------+----------+---------+
  | alarm_id                             | type      | name                                                    | state | severity | enabled |
  +--------------------------------------+-----------+---------------------------------------------------------+-------+----------+---------+
  | 9c245bcc-d31e-4219-ab50-f19d2dd8d0e9 | threshold | autoscaling-test-ceilometer_cpu_high_alarm-hpik52fcq7xc | alarm | low      | True    |
  | 11578915-f140-4095-a977-51ae861f1cd2 | threshold | autoscaling-test-ceilometer_cpu_low_alarm-xzclw6ejci64  | ok    | low      | True    |
  +--------------------------------------+-----------+---------------------------------------------------------+-------+----------+---------+

  # looking at our alarm specifically we can see information on what actions its going to take.

  $ o alarm show autohealing-test-ceilometer_cpu_high_alarm-hpik52fcq7xc
  +---------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | Field                     | Value                                                                                                                                                                                                                                                                                                                                                                       |
  +---------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | alarm_actions             | ['https://api.nz-hlz-1.catalystcloud.io:8004/v1/eac679e4896146e6827ce29d755fe289/stacks/autohealing-test/13f0119d-2b7c-4406-91b5-b646369ca03b/resources/scaleup_policy/signal']                                                                                                                                                                                             |
  | alarm_id                  | 9c245bcc-d31e-4219-ab50-f19d2dd8d0e9                                                                                                                                                                                                                                                                                                                                        |
  | description               | Alarm when cpu_util is gt a avg of 5.0 over 60 seconds                                                                                                                                                                                                                                                                                                                      |
  | enabled                   | True                                                                                                                                                                                                                                                                                                                                                                        |
  | insufficient_data_actions | []                                                                                                                                                                                                                                                                                                                                                                          |
  | name                      | autoscaling-test-ceilometer_cpu_high_alarm-hpik52fcq7xc                                                                                                                                                                                                                                                                                                                     |
  | ok_actions                | []                                                                                                                                                                                                                                                                                                                                                                          |
  | project_id                | eac679e4896146e6827ce29d755fe289                                                                                                                                                                                                                                                                                                                                            |
  | repeat_actions            | False                                                                                                                                                                                                                                                                                                                                                                       |
  | severity                  | low                                                                                                                                                                                                                                                                                                                                                                         |
  | state                     | alarm                                                                                                                                                                                                                                                                                                                                                                       |
  | state_reason              | Transition to alarm due to 1 samples outside threshold, most recent: 5.26166666667                                                                                                                                                                                                                                                                                          |
  | state_timestamp           | 2019-11-07T01:02:52.083002                                                                                                                                                                                                                                                                                                                                                  |
  | threshold_rule            | {'meter_name': 'cpu_util', 'evaluation_periods': 1, 'period': 60, 'statistic': 'avg', 'threshold': 5.0, 'query': [{'field': 'metadata.user_metadata.server_group', 'value': '13f0119d-2b7c-4406-91b5-b646369ca03b', 'op': 'eq'}, {'field': 'project_id', 'value': 'eac679e4896146e6827ce29d755fe289', 'op': 'eq'}], 'comparison_operator': 'gt', 'exclude_outliers': False} |
  | time_constraints          | []                                                                                                                                                                                                                                                                                                                                                                          |
  | timestamp                 | 2019-11-07T01:02:52.083002                                                                                                                                                                                                                                                                                                                                                  |
  | type                      | threshold                                                                                                                                                                                                                                                                                                                                                                   |
  | user_id                   | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                                                                                                                                                                                                                                                                                                                                            |
  +---------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

  # Once the state has been changed to 'alarm' the scaleup_policy is activated
  # which goes on to create the new instance.

  $ o stack resource show autoscaling-test scaleup_policy
  +------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | Field                  | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
  +------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | attributes             | {'signal_url': 'https://api.nz-hlz-1.catalystcloud.io:8004/v1/eac679e4896146e6827ce29d755fe289/stacks/autohealing-test/13f0119d-2b7c-4406-91b5-b646369ca03b/resources/scaleup_policy/signal', 'alarm_url': 'https://api.nz-hlz-1.catalystcloud.io:8000/v1/signal/arn%3Aopenstack%3Aheat%3A%3Aeac679e4896146e6827ce29d755fe289%3Astacks/autohealing-test/13f0119d-2b7c-4406-91b5-b646369ca03b/resources/scaleup_policy?Timestamp=2019-11-07T01%3A01%3A19Z&SignatureMethod=HmacSHA256&AWSAccessKeyId=a8551ce97a5744b3baf238ed603febc5&SignatureVersion=2&Signature=RTpBm40JegQmZ6b5YEOOOqeizNZEa7id2YMpUM1Iu8k%3D'} |
  | creation_time          | 2019-11-07T01:01:19Z                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
  | description            |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
  | links                  | [{'href': 'https://api.nz-hlz-1.catalystcloud.io:8004/v1/eac679e4896146e6827ce29d755fe289/stacks/autohealing-test/13f0119d-2b7c-4406-91b5-b646369ca03b/resources/scaleup_policy', 'rel': 'self'}, {'href': 'https://api.nz-hlz-1.catalystcloud.io:8004/v1/eac679e4896146e6827ce29d755fe289/stacks/autohealing-test/13f0119d-2b7c-4406-91b5-b646369ca03b', 'rel': 'stack'}]                                                                                                                                                                                                                                        |
  | logical_resource_id    | scaleup_policy                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
  | physical_resource_id   | 2099d91fdf0147d1ae6fc5cbfdd6b4eb                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
  | required_by            | ['ceilometer_cpu_high_alarm']                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
  | resource_name          | scaleup_policy                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
  | resource_status        | CREATE_COMPLETE                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
  | resource_status_reason | state changed                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
  | resource_type          | OS::Heat::ScalingPolicy                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
  | updated_time           | 2019-11-07T01:01:19Z                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
  +------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

  # Finally, we can see this new instance when we list our servers.

  $ o server list
  +--------------------------------------+-------------------------------------------------------+--------+----------------------------------------+---------------------+---------+
  | ID                                   | Name                                                  | Status | Networks                               | Image               | Flavor  |
  +--------------------------------------+-------------------------------------------------------+--------+----------------------------------------+---------------------+---------+
  | 5a87c2b4-4f0b-41a0-98dc-c27c3bd18c4b | au-a3zs-iw65sw7slge4-ym6x2zvensy3-server-ngdcpq52cja4 | ACTIVE | private-net=10.0.0.162, 103.197.60.173 | ubuntu-18.04-x86_64 | c1.c1r1 |
  | e66ed5c5-7183-41e1-a2d2-c0606837a08e | au-a3zs-e3rrocfyub26-zgwkkb3bvjem-server-eo2mpsvuroez | ACTIVE | private-net=10.0.0.161, 103.197.60.167 | ubuntu-18.04-x86_64 | c1.c1r1 |
  | 56591ff3-b2a6-431c-9d48-29a49fabfedd | au-a3zs-dqs5ofwuqegp-5uqp34rwzszb-server-qexfzb23qjxl | ACTIVE | private-net=10.0.0.160, 103.197.60.159 | ubuntu-18.04-x86_64 | c1.c1r1 |
  +--------------------------------------+-------------------------------------------------------+--------+----------------------------------------+---------------------+---------+

Our new instance is live and the load balancers ensure that the workload is
spread evenly. You can see this if you try to curl the instances like earlier.

.. code-block:: bash

  $ while true; do curl $lb_ip; sleep 2; done
  Welcome to my 192.168.2.200
  Welcome to my 192.168.2.201
  Welcome to my 192.168.2.202
  Welcome to my 192.168.2.200
  Welcome to my 192.168.2.201
  Welcome to my 192.168.2.202

  # Now we can clean up this stack

  $ o stack delete autoscaling-test


For more information on the Alarm service, you can visit `the openstack
documentation on aodh`_

.. _`the openstack documentation on aodh`: https://docs.openstack.org/aodh/latest/admin/telemetry-alarms.html
