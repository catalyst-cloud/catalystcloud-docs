.. _alarm-service-on-Sky-tv_cloud:


*************
Alarm Service
*************

Overview
========

The alarm service available through the SKY-TV cloud, allows a user to set
up alarms that are listening on certain objects in the cloud. The alarms wait
for specific parameters to occur then they change their state depending on your
parameters. If a state change occurs then actions that you predefine for the
alarm take effect.

For example: You want to monitor a compute instance to see if the CPU
utilization exceeds 70% for more than 10 minutes. Once the alarm has met
this requirement, it changes state to 'alarm'. The aodh-notifier then tells
your system to perform some action. In this scenario it could be to: spin up a
new instance with more CPU power, or increase the amount of VCPU's your
instance is using. Whatever your goal is the alarm keeps you informed of the
state of your machine so you can implement things such as auto-scaling.

Threshold rules
===============

These are the rules that you define for your alarms and the requirements needed
for them to evaluate to 'alarm' or not.

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
``and`` and ``or`` relations, on their alarms.

A working example
=================

For this working example, we will be creating an alarm that monitors a
webserver and autoheals should the server go down for some reason.

The first thing that we need to do is create a webserver. This can be done
using the following script.

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
      default: m1.tiny
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



For more information on the Alarm service, you can visit `the openstack
documentation on aodh`_

.. _`the openstack documentation on aodh`: https://docs.openstack.org/aodh/latest/admin/telemetry-alarms.html
