.. _alarm-service-on-Sky-tv_cloud:


*************
Alarm Service
*************

Overview
========

The alarm service, available through the SKY-TV cloud, allows a user to set
up alarms that are listening on certain objects in the cloud. The alarms wait
for specific events to occur; then they change their state depending on pre set
parameters. If a state change occurs then actions that you predefine for the
alarm take effect.

For example: You want to monitor a compute instance to see if the CPU
utilization exceeds 70% for more than 10 minutes. Once the alarm has met
this requirement, it changes its state to 'alarm'. The aodh-notifier then tells
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
will be doing. For the purposes of this example, we will be using an Ubuntu
image to simulate a webserver in our project,  it responds to requests with the
message: "Welcome to my <IP address>".

The following is a yaml file that is used to set up this webserver when we
create our stack. You will have to change some of the variables in this script
for it to function properly.

save this yaml as webserver.yaml

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
            MYIP=$(/sbin/ifconfig eth0 |grep 'inet addr'|awk -F: '{print $2}'| awk '{print $1}');
            OUTPUT="Welcome to my $MYIP"
            while true; do echo -e "HTTP/1.1 200 OK\r\n\r\n${OUTPUT}\r" | sudo nc -l -p 80; done
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

Next, we need to set up a load balancer. The following yaml will create a
loadbalancer, an autoscaling group and a health monitor. This script also
communicates with the webserver yaml to spin up 2 ubuntu instances to
simulate the webserver. After these are created we will attach an AODH Alarm.

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
      description: Need to be a cirros image.
      type: string
      default: 08a29966-85b9-4056-8d97-b51b7f862d01 # confirm this is a cirros image manually
    webserver_flavor_id:
      type: string
      default: c1.c1r1
    webserver_network_id:
      type: string
      default: <WEBSERVER NETWORK ID>
    webserver_sg_ids:
      description: Security groups that allows TCP 22 access
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


The next step is using these yaml files together to set up our webserver and
to test whether we can use auto-healing with an aodh alarm.

To connect both of these yaml files we will make a 3rd one that allows the
webserver.yaml to be used as an environment for the auto-healing.yaml. It is
one line of code, but the separation of the webserver artefacts and the
loadbalancer artefacts makes it easier to track when editing.

Save this file as env.yaml

.. code-block:: bash

 resource_registry:
   OS::LB::Server: webserver.yaml


Now, after you have changed the variables in your yaml files, we need to
check whether our template (in this case the yaml file) is valid. This is done
with the command:

.. code-block:: bash

  openstack orchestration template validate -f yaml -t autohealing.yaml
  openstack orchestration template validate -f yaml -t webserver.yaml

If your template is valid the console will print out the template, if there is
an error the console will return said error instead.

As long as our templates are valid, we go to the next step which is creating
the stack.

.. code-block:: bash

  openstack stack create autohealing-test -t autohealing.yaml -e env.yaml

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

  stackid=(94dd128a-3a9a-4473-96c6-77591e39e5ed)

  #then we take the ID for our stack for the next command:
  openstack stack resource list $stackid

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

You may need to re-run the previous command or view the progress of your stack
via the dashboard, until the resource status of your all resources is
CREATE_COMPLETE. This can take several minutes. Once your stack is completed
and ready to access, we do the following to acquire the VIP for the
loadbalancer:

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
  Welcome to my 103.254.156.149
  Welcome to my 103.254.156.149
  Welcome to my 103.254.156.149

  # to stop this process you can press ctrl Z or ctrl C

  #from here we need to get the resource IDs for our webserver
  lbid=$(lb list | grep webserver_lb | awk '{print $2}')
  asgid=$(o stack resource list $stackid | grep autoscaling_group | awk '{print $4}');
  poolid=$(lb status show $lbid | jq -r '.loadbalancer.listeners[0].pools[0].id')

So far we have created our loadbalancer, our webserver, set up some resource
IDs and have checked to make sure that the webserver is behaving as expected.
Now we need to check that our loadbalancers are working correctly and
create the AODH alarm.

.. code-block:: bash

  openstack loadbalancer member list $poolid




For more information on the Alarm service, you can visit `the openstack
documentation on aodh`_

.. _`the openstack documentation on aodh`: https://docs.openstack.org/aodh/latest/admin/telemetry-alarms.html
