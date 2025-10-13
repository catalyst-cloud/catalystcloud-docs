.. _autoscaling-on-catalyst-cloud:

############
Auto-scaling
############

Auto-scaling is the process of dynamically adjusting the number of
workers in a service cluster according to the current demand, without
any direct input from an administrator.

The Catalyst Cloud Orchestration Service supports **auto-scaling groups**
that can be used to **scale out** (increase the size of) or **scale in**
(decrease the size of) a group of instances running in a stack.

.. contents::
    :local:
    :depth: 3
    :backlinks: none

************
How it works
************

The diagram below shows the layout and workflow of a
typical orchestration stack with auto-scaling.

.. image:: _static/autoscaling/workflow.svg
  :name: Workflow

In this example, the Orchestration Service is managing
a highly available web application with a load balancer.

An **auto-scaling group** is used to automatically launch and destroy
web servers. The auto-scaling group also manages load balancer pool
memberships, so once new instances come online they automatically
start serving requests.

.. note::

  A load balancer is not required to implement auto-scaling.
  Auto-scaling groups can be created for just a group of instances,
  allowing any kind of workload to be auto-scaled, not just web services.

The :ref:`Alarm Service <alarm>` is used to monitor the state of the
instances in the auto-scaling group. If CPU or memory usage exceeds
the configured thresholds the relevant alarm will trigger, notifying
the auto-scaling group to add more instances to the cluster. Likewise,
when demand goes back down the relevant alarm will trigger, and the
auto-scaling group will reduce the number of running instances until
the load falls back into the desired ranges.

*******
Example
*******

In this section we show how to create an orchestration stack
with auto-scaling enabled from a set of example templates.

We will go through some of the details of the templates themselves,
send requests to the load balanced web application, and test scaling
instances in the cluster to make sure everything works correctly.

Prerequisites
=============

.. note::

  Before getting started, make sure you have your Catalyst Cloud user and system environment setup so that
  :ref:`you can access the Orchestration Service <orchestration-prerequisites>` using the OpenStack CLI.

This orchestration stack in this example will create everything needed to
run the workloads themselves.

The only thing you need to create manually beforehand is an SSH keypair
to assign to the instances; to learn how to do this, see the documentation
for :ref:`creating a new keypair <creating-keypair>` or
:ref:`importing an existing keypair <importing-keypair>`.
Once you have your keypair, keep a record of the name of the keypair
as it will be used to configure the stack.

Get the templates
=================

First, clone the repository containing our `Orchestration Service examples`_
from GitHub, and navigate to the ``hot/autoscaling`` directory containing
the auto-scaling example templates.

.. _Orchestration Service examples: https://github.com/catalyst-cloud/catalystcloud-orchestration

.. code-block:: console

  $ git clone https://github.com/catalyst-cloud/catalystcloud-orchestration.git
  $ cd catalystcloud-orchestration/hot/autoscaling

Template details
================

.. note::

  This section goes in depth on how auto-scaling is configured in the stack templates.

  To skip the explanation and go straight to creating an auto-scaling stack,
  see :ref:`orchestration-autoscaling-creation`.

In this example stack, the following resources are created:

* An internal network and subnet for the instances
* A security group for controlling access to/from the internal network
* A router for the internal network, to allow Internet access
* A bastion host with a floating IP, to allow SSH access into the cluster
* A load balancer with another floating IP, to expose the web servers
  to the Internet as a highly available cluster from a single address
* An auto-scaling group that adds and removes web server instances,
  and load balancer pool memberships, as needed
* A set of alarms that monitor the state of the instances in the auto-scaling group,
  and notify the auto-scaling group to scale out or scale in the cluster when
  load exceeds the configured thresholds

The stack templates consist of the following files:

* ``autoscaling.yaml`` - The master template for the cluster,
  containing all common resource definitions such as the network,
  the bastion host, the load balancer and the auto-scaling group configuration.
* ``webserver.yaml`` - The template used to manage per-member resources
  for the web servers in the auto-scaling group, such as the instance
  definition and the load balancer pool membership.
* ``env.yaml`` - The environment configuration, used in this case
  to define ``webserver.yaml`` as the ``OS::Autoscaling::Webserver``
  resource type to be referenced in the master template.
* ``user_data.sh`` - The shell script run on startup on the web server instances.

Most of this uses the standard resource definitions as you would see
in other templates, but there are a number of special resource definitions
used to control the auto-scaling functionality.

Auto-scaling group
------------------

The first resource to create is the **auto-scaling group**,
defined using the ``OS::Heat::AutoScalingGroup``
`resource type <https://docs.openstack.org/heat/latest/template_guide/openstack.html#OS::Heat::AutoScalingGroup>`__.

.. code-block:: yaml

  # The auto-scaling group for provisioning web servers.
  autoscaling_group:
    type: OS::Heat::AutoScalingGroup
    properties:
      min_size: {get_param: autoscaling_min_size}
      max_size: {get_param: autoscaling_max_size}
      resource:
        type: OS::Autoscaling::Webserver
        properties:
          keypair: {get_param: keypair}
          flavor: {get_param: webserver_flavor}
          image: {get_param: webserver_image}
          network: {get_resource: network}
          security_groups:
            - {get_resource: internal_security_group}
          group: {get_resource: webserver_group}
          loadbalancer_pool: {get_resource: loadbalancer_pool}

The auto-scaling group defines the type of resource to create in a cluster,
the minimum and maximum size of the cluster, and other optional parameters
that configure how rolling updates of resources are performed. By using a
custom resource type as shown above, multiple child resources can be created
per auto-scaling group member.

Server group
------------

All instances in an auto-scaling group should also be added to a **server group**,
defined using the ``OS::Nova::ServerGroup``
`resource type <https://docs.openstack.org/heat/latest/template_guide/openstack.html#OS::Nova::ServerGroup>`__.

.. code-block:: yaml

  # The server group for the cluster of web servers.
  webserver_group:
    type: OS::Nova::ServerGroup
    properties:
      policies:
        - {get_param: webserver_group_policy}

Server groups have two purposes here:

* By setting a hard or soft anti-affinity policy on the server group,
  it ensures that no two auto-scaling group members end up on the same
  physical machine, protecting against hypervisor failures (for more info,
  see :ref:`anti-affinity`).
* The alarms that monitor load across the auto-scaling group query metrics
  by server group, as a way to associate the auto-scaling group members with
  each other.

In the instance definition for the auto-scaling group members, the ``group``
scheduler hint and the ``metering.server_group`` metadata attribute are used
to correctly configure the server group on the instances.

.. code-block:: yaml

  # An instance to be managed by an auto-scaling group.
  # Define as the resource property of an OS::Heat::AutoScalingGroup resource,
  # or inside a custom resource type along with other required per-member resources
  # (e.g. load balancer pool memberships).
  webserver:
    type: OS::Nova::Server
    properties:
      image: {get_param: image}
      flavor: {get_param: flavor}
      networks:
        - network: {get_param: network}
      key_name: {get_param: keypair}
      security_groups: {get_param: security_groups}
      scheduler_hints:
        group: {get_param: group}
      metadata:
        metering.server_group: {get_param: group}
      config_drive: true
      user_data_format: RAW
      user_data: {get_file: user_data.sh}

Scaling policies
----------------

Now that we have the auto-scaling group and the underlying instances correctly
configured, we need to define exactly how instances should be scaled.

**Scaling policies** are defined for the auto-scaling group
using the ``OS::Heat::ScalingPolicy``
`resource type <https://docs.openstack.org/heat/latest/template_guide/openstack.html#OS::Heat::ScalingPolicy>`__.

.. code-block:: yaml

  # The policy for scaling out web servers when load is high.
  autoscaling_up_policy:
    type: OS::Heat::ScalingPolicy
    properties:
      adjustment_type: change_in_capacity
      auto_scaling_group_id: {get_resource: autoscaling_group}
      scaling_adjustment: 1
      cooldown: {get_param: autoscaling_granularity}

  # The policy for scaling in web servers when load is low.
  autoscaling_down_policy:
    type: OS::Heat::ScalingPolicy
    properties:
      adjustment_type: change_in_capacity
      auto_scaling_group_id: {get_resource: autoscaling_group}
      scaling_adjustment: -1
      cooldown: {get_param: autoscaling_granularity}

These configure exactly what happens when a scaling action is triggered
for the auto-scaling group, such as the amount of instances to scale
at one time, or required cooldown time between scaling actions.
Separate policies are required for each type of scaling action,
in this case scaling out (up policy) and scaling in (down policy).

Alarms
------

The final piece of the puzzle is automating the scaling actions,
which is implemented using specially configured **alarms**.

:ref:`Resource metric aggregate threshold alarms <alarm-resource-metric-aggregate-threshold>`,
managed using the ``OS::Aodh::GnocchiAggregationByResourcesAlarm``
`resource type <https://docs.openstack.org/heat/latest/template_guide/openstack.html#OS::Aodh::GnocchiAggregationByResourcesAlarm>`__,
can be used to monitor the state of metrics across all active instances
in the auto-scaling group.

.. code-block:: yaml

  # The alarm that triggers a scale out when CPU usage exceeds the threshold.
  autoscaling_cpu_high_alarm:
    type: OS::Aodh::GnocchiAggregationByResourcesAlarm
    properties:
      description:
        str_replace:
          template: Scale out if average CPU usage exceeds threshold%
          params:
            threshold: {get_param: autoscaling_cpu_high_threshold}
      resource_type: instance
      metric: cpu
      aggregation_method: "rate:mean"
      granularity: {get_param: autoscaling_granularity}
      threshold:
        yaql:
          # 10^9 nanoseconds * number of vCPUs * granularity in seconds * (threshold in percent / 100)
          expression: >-
            1000000000
            * int(regex("^c[^.]\.c([0-9]+).*$").replace($.data.flavor, "\g<1>"))
            * $.data.granularity
            * (float($.data.threshold) / 100)
          data:
            flavor: {get_param: webserver_flavor}
            granularity: {get_param: autoscaling_granularity}
            threshold: {get_param: autoscaling_cpu_high_threshold}
      query:
        str_replace:
          template: '{"and": [{"=": {"server_group": "group_id"}}, {"=": {"ended_at": null}}]}'
          params:
            group_id: {get_resource: webserver_group}
      comparison_operator: gt
      evaluation_periods: 1
      alarm_actions:
        - {get_attr: [autoscaling_up_policy, alarm_url]}
        - str_replace:
            template: trust+url
            params:
              url: {get_attr: [autoscaling_up_policy, signal_url]}
      repeat_actions: true

  # The alarm that triggers a scale in when CPU usage goes below the threshold.
  autoscaling_cpu_low_alarm:
    type: OS::Aodh::GnocchiAggregationByResourcesAlarm
    properties:
      description:
        str_replace:
          template: Scale in if average CPU usage goes below threshold%
          params:
            threshold: {get_param: autoscaling_cpu_low_threshold}
      resource_type: instance
      metric: cpu
      aggregation_method: "rate:mean"
      granularity: {get_param: autoscaling_granularity}
      threshold:
        yaql:
          # 10^9 nanoseconds * number of vCPUs * granularity in seconds * (threshold in percent / 100)
          expression: >-
            1000000000
            * int(regex("^c[^.]\.c([0-9]+).*$").replace($.data.flavor, "\g<1>"))
            * $.data.granularity
            * (float($.data.threshold) / 100)
          data:
            flavor: {get_param: webserver_flavor}
            granularity: {get_param: autoscaling_granularity}
            threshold: {get_param: autoscaling_cpu_low_threshold}
      query:
        str_replace:
          template: '{"and": [{"=": {"server_group": "group_id"}}, {"=": {"ended_at": null}}]}'
          params:
            group_id: {get_resource: webserver_group}
      comparison_operator: lt
      evaluation_periods: 1
      alarm_actions:
        - {get_attr: [autoscaling_down_policy, alarm_url]}
        - str_replace:
            template: trust+url
            params:
              url: {get_attr: [autoscaling_down_policy, signal_url]}
      repeat_actions: true

  # The alarm that triggers a scale out when memory usage exceeds the threshold.
  autoscaling_memory_high_alarm:
    type: OS::Aodh::GnocchiAggregationByResourcesAlarm
    properties:
      description:
        str_replace:
          template: Scale out if average memory usage exceeds threshold%
          params:
            threshold: {get_param: autoscaling_memory_high_threshold}
      resource_type: instance
      metric: memory.usage
      aggregation_method: mean
      granularity: {get_param: autoscaling_granularity}
      threshold:
        yaql:
          # RAM in GiB * 1024 to convert to MiB * (threshold in percent / 100)
          expression: >-
            int(regex("^c[^.]\.c[0-9]+r([0-9]+).*$").replace($.data.flavor, "\g<1>"))
            * 1024
            * (float($.data.threshold) / 100)
          data:
            flavor: {get_param: webserver_flavor}
            threshold: {get_param: autoscaling_memory_high_threshold}
      query:
        str_replace:
          template: '{"and": [{"=": {"server_group": "group_id"}}, {"=": {"ended_at": null}}]}'
          params:
            group_id: {get_resource: webserver_group}
      comparison_operator: gt
      evaluation_periods: 1
      alarm_actions:
        - {get_attr: [autoscaling_up_policy, alarm_url]}
        - str_replace:
            template: trust+url
            params:
              url: {get_attr: [autoscaling_up_policy, signal_url]}
      repeat_actions: true

  # The alarm that triggers a scale in when memory usage goes below the threshold.
  autoscaling_memory_low_alarm:
    type: OS::Aodh::GnocchiAggregationByResourcesAlarm
    properties:
      description:
        str_replace:
          template: Scale in if average memory usage goes below threshold%
          params:
            threshold: {get_param: autoscaling_memory_low_threshold}
      resource_type: instance
      metric: memory.usage
      aggregation_method: mean
      granularity: {get_param: autoscaling_granularity}
      threshold:
        yaql:
          # RAM in GiB * 1024 to convert to MiB * (threshold in percent / 100)
          expression: >-
            int(regex("^c[^.]\.c[0-9]+r([0-9]+).*$").replace($.data.flavor, "\g<1>"))
            * 1024
            * (float($.data.threshold) / 100)
          data:
            flavor: {get_param: webserver_flavor}
            threshold: {get_param: autoscaling_memory_low_threshold}
      query:
        str_replace:
          template: '{"and": [{"=": {"server_group": "group_id"}}, {"=": {"ended_at": null}}]}'
          params:
            group_id: {get_resource: webserver_group}
      comparison_operator: lt
      evaluation_periods: 1
      alarm_actions:
        - {get_attr: [autoscaling_down_policy, alarm_url]}
        - str_replace:
            template: trust+url
            params:
              url: {get_attr: [autoscaling_down_policy, signal_url]}
      repeat_actions: true

In the above example, **CPU usage** and the **memory usage** are both monitored for load.
Two alarms are required for each monitored metric - one that triggers when the high threshold
is exceeded, and another one that triggers when load goes below the low threshold. This results
in 4 alarms being created for the auto-scaling group.

The example templates allow you to configure the load thresholds as a percentage,
which is very convenient since there is no need to  manually configure the number of
vCPUs or available RAM in the monitoring. But since the monitored metrics are not
available in the :ref:`Catalyst Cloud Metrics Service <metrics>` as a percentage,
some complex templating is performed to convert the percentage into the correct
threshold figures, based on the :ref:`flavour <instance-types>` used by the
instances and the granularity of the performed queries.

**Alarm actions** are configured on the alarms to notify the appropriate auto-scaling
policy, which runs the scaling action. Once load is better distributed across the cluster,
the alarms will recover and the cluster will run with the same number of workers until
changes in demand cause the alarms to trigger again.

And that's it! With the above resources added to your stack,
you should have a functioning auto-scaling cluster.

.. _orchestration-autoscaling-creation:

Creating the stack
==================

Let's create a new stack and get our example resources up and running.

A number of parameters are available in the example templates
(for more info see ``autoscaling.yaml``), but the only required one
is ``keypair``, which sets the SSH keypair used to login to the instances.

The below command will create a new stack called ``autoscaling-example``
(we will refer to the stack using this name from now on).
Run this command, setting ``keypair`` to the name of the keypair you'd
like the use.

.. code-block:: bash

  openstack stack create autoscaling-example --template autoscaling.yaml \
                                             --environment env.yaml \
                                             --parameter "keypair=<NAME>"

The Orchestration Service will start creating the resources in the background.

.. code-block:: console

  $ openstack stack create autoscaling-example --template autoscaling.yaml --environment env.yaml --parameter "keypair=example-keypair"
  +---------------------+-----------------------------------------------------------------------+
  | Field               | Value                                                                 |
  +---------------------+-----------------------------------------------------------------------+
  | id                  | dd254c00-2424-4b9a-a5a0-fff6bf9dc046                                  |
  | stack_name          | autoscaling-example                                                   |
  | description         | An example Catalyst Cloud Orchestration Service template              |
  |                     | for building a cluster of web servers with auto-scaling.              |
  |                     |                                                                       |
  |                     | This provisions the following cloud resources:                        |
  |                     |                                                                       |
  |                     | * Security groups to control access to/from instances.                |
  |                     | * An internal network for all instances.                              |
  |                     | * A bastion host with its own floating IP to allow SSH access         |
  |                     |   into the cluster.                                                   |
  |                     | * A load balancer to allow highly available access to the web servers |
  |                     |   from the Internet, with its own floating IP.                        |
  |                     | * An auto-scaling group that launches, monitors and scales            |
  |                     |   a cluster of web server instances depending on the configured       |
  |                     |   load thresholds.                                                    |
  | creation_time       | 2025-10-10T00:55:35Z                                                  |
  | updated_time        | None                                                                  |
  | stack_status        | CREATE_IN_PROGRESS                                                    |
  | stack_status_reason | Stack CREATE started                                                  |
  +---------------------+-----------------------------------------------------------------------+

Checking created resources
==========================

To monitor resource creation in real time, you can use the ``watch`` command
to continuously report the status of all created resources.

.. code-block:: console

   watch openstack stack resource list autoscaling-example

It will take a few minutes for all resources in the stack to reach ``CREATE_COMPLETE`` state.

.. code-block:: text

  +-----------------------------------+-------------------------------------------------------------------------------------+----------------------------------------------+-----------------+----------------------+
  | resource_name                     | physical_resource_id                                                                | resource_type                                | resource_status | updated_time         |
  +-----------------------------------+-------------------------------------------------------------------------------------+----------------------------------------------+-----------------+----------------------+
  | autoscaling_up_policy             | 41e0751171fc4982acfef2c565f29ea7                                                    | OS::Heat::ScalingPolicy                      | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | subnet                            | 9c45e1a1-9878-40cb-b985-8dbdcfbf1339                                                | OS::Neutron::Subnet                          | CREATE_COMPLETE | 2025-10-10T22:06:18Z |
  | bastion_server                    | 1842093a-eb7a-4380-9fe9-aab83bc95c4c                                                | OS::Nova::Server                             | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | network                           | d0331ea5-b6fb-4a52-bdfe-61375793ed1f                                                | OS::Neutron::Net                             | CREATE_COMPLETE | 2025-10-10T22:06:18Z |
  | autoscaling_memory_low_alarm      | 5c55e371-f16c-4120-9fe2-9f3be11d71ab                                                | OS::Aodh::GnocchiAggregationByResourcesAlarm | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | internal_security_group_rule_ssh  | dee7d066-cb4c-4e66-a621-1fee53ccf3e8                                                | OS::Neutron::SecurityGroupRule               | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | loadbalancer_floating_ip          | 8944d3e1-17e0-4d08-bc74-2a7f68491b0d                                                | OS::Neutron::FloatingIP                      | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | autoscaling_group                 | 5c1c51ab-02f9-471c-a760-7b9e06426808                                                | OS::Heat::AutoScalingGroup                   | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | autoscaling_cpu_low_alarm         | f52a14d8-e1c4-4597-a08f-9c07b07ddb06                                                | OS::Aodh::GnocchiAggregationByResourcesAlarm | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | internal_security_group           | 5f8ce8f0-c6ca-4ece-9b8a-c2f6f5525123                                                | OS::Neutron::SecurityGroup                   | CREATE_COMPLETE | 2025-10-10T22:06:18Z |
  | webserver_group                   | 7a612ef2-ad1d-49fa-a72d-51253761cdda                                                | OS::Nova::ServerGroup                        | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | loadbalancer_pool                 | 65b27c46-aa58-4986-8846-ffd80e2b8b24                                                | OS::Octavia::Pool                            | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | autoscaling_cpu_high_alarm        | 334411fa-8f4b-482d-ba05-c4399a7a3393                                                | OS::Aodh::GnocchiAggregationByResourcesAlarm | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | router                            | 006e2146-16d2-42d6-99d6-301bb1f130c8                                                | OS::Neutron::Router                          | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | bastion_floating_ip               | 36b944e0-b707-4fc7-91be-23fe89bf4c6b                                                | OS::Neutron::FloatingIP                      | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | loadbalancer_listener             | 2aba82b0-7970-45d3-9263-69ec8b65a6dd                                                | OS::Octavia::Listener                        | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | router_interface                  | 006e2146-16d2-42d6-99d6-301bb1f130c8:subnet_id=9c45e1a1-9878-40cb-b985-8dbdcfbf1339 | OS::Neutron::RouterInterface                 | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | internal_security_group_rule_http | 905afa55-6c92-467c-83cb-68601de482d6                                                | OS::Neutron::SecurityGroupRule               | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | autoscaling_memory_high_alarm     | a49a2804-f06d-48c4-a296-6fb925e4503e                                                | OS::Aodh::GnocchiAggregationByResourcesAlarm | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  | loadbalancer                      | 71a4c4ee-f051-4e98-abe5-cd1e98684202                                                | OS::Octavia::LoadBalancer                    | CREATE_COMPLETE | 2025-10-10T22:06:18Z |
  | autoscaling_down_policy           | b596018eafbc4d6db4b4b0673b851816                                                    | OS::Heat::ScalingPolicy                      | CREATE_COMPLETE | 2025-10-10T22:06:17Z |
  +-----------------------------------+-------------------------------------------------------------------------------------+----------------------------------------------+-----------------+----------------------+

.. note::

  If any resources end up in ``CREATE_FAILED`` state, you can find out
  the cause using the following command:

  .. code-block:: bash

    openstack stack failures list autoscaling-example

  A common reason for resource creation failing is exceeding your
  project quota while attempting to create the stack. Free up some
  resources in your project, and try again by deleting and recreating
  the stack.

  .. code-block::

    openstack stack delete autoscaling-example

If all resources were created successfully, the cluster should now be
up and running, so let's test connectivity to everything.

First, we'll try to login to the bastion host. Fetch the floating IP
address of the bastion host, and then use SSH to login to the host.
You should be able to access the console on the bastion host.

.. code-block:: console

  $ openstack stack output show autoscaling-example bastion_floating_ip -c output_value -f value
  192.0.2.1
  $ ssh -i ~/.ssh/keypair_private_key.pem ubuntu@192.0.2.1
  The authenticity of host '192.0.2.1 (192.0.2.1)' can't be established.
  ED25519 key fingerprint is SHA256:p+3UXWE0tFEIMUPMif6e0+n9gSHLwjveIvmcuugC3Rc.
  This key is not known by any other names.
  Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
  Warning: Permanently added '192.0.2.1' (ED25519) to the list of known hosts.
  Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.8.0-59-generic x86_64)

  * Documentation:  https://help.ubuntu.com
  * Management:     https://landscape.canonical.com
  * Support:        https://ubuntu.com/pro

  System information as of Fri Oct 10 22:23:03 UTC 2025

    System load:  0.14              Processes:             96
    Usage of /:   18.2% of 8.65GB   Users logged in:       0
    Memory usage: 17%               IPv4 address for ens3: 10.0.0.102
    Swap usage:   0%

  Expanded Security Maintenance for Applications is not enabled.

  0 updates can be applied immediately.

  Enable ESM Apps to receive additional future security updates.
  See https://ubuntu.com/esm or run: sudo pro status


  The list of available updates is more than a week old.
  To check for new updates run: sudo apt update


  The programs included with the Ubuntu system are free software;
  the exact distribution terms for each program are described in the
  individual files in /usr/share/doc/*/copyright.

  Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
  applicable law.

  To run a command as administrator (user "root"), use "sudo <command>".
  See "man sudo_root" for details.

  ubuntu@autoscaling-example-bastion-server-radhlpt36blw:~$

If this works, you can use SSH from the bastion host to login to the web server instances as needed.

Next, let's check that the web application is working. Run the
following command to get the floating IP address of the load balancer.

.. code-block:: console

  $ openstack stack output show autoscaling-example loadbalancer_floating_ip -c output_value -f value
  192.0.2.2

The web application is served via unencrypted HTTP on port 80, so simply use
``curl`` to make a request.

.. code-block:: console

  $ curl http://192.0.2.2
  Hello, world! This request was served by au-x-u6thgn62eec6-ev65hjmjcmss-webserver-vdq2wg3l2mcv (10.0.0.151).

If you receive a response similar to the one above, congratulations!
Your highly available web application is now up and running.

This cluster runs with a minimum of 2 web servers. Keep running the
command until you have received a response from all running instances.

.. code-block:: console

  $ curl http://192.0.2.2
  Hello, world! This request was served by au-x-u6thgn62eec6-ev65hjmjcmss-webserver-vdq2wg3l2mcv (10.0.0.151).
  $ curl http://192.0.2.2
  Hello, world! This request was served by au-x-k2va3k4min64-kgypkpgxo2t3-webserver-goiwpb5kbnil (10.0.0.215).

Scaling instances
=================

Let's take a deeper dive into the auto-scaling aspect of the cluster.

We can check how many instances are running at the moment
by getting the currently active server group members.

.. code-block:: console

  $ openstack stack resource show autoscaling-example webserver_group -c attributes -f json | jq '.attributes.members'
  [
    "a6745eaf-2939-4899-9966-3aaa229f617f",
    "6cd4fef9-ba78-4342-afa7-ff5d6d12243e"
  ]

There are 4 auto-scaling alarms created in this example,
with the following stack resource names:

* ``autoscaling_cpu_high_alarm``
* ``autoscaling_cpu_low_alarm``
* ``autoscaling_memory_high_alarm``
* ``autoscaling_memory_low_alarm``

Check the state of the alarms to see if any are calling for scaling actions to be run.

.. code-block:: console

  $ openstack stack resource show autoscaling-example autoscaling_cpu_high_alarm -c attributes -f json | jq '.attributes'
  {
    "alarm_actions": [
      "https://api.nz-por-1.catalystcloud.io:8000/v1/signal/arn%3Aopenstack%3Aheat%3A%3A9864e20f92ef47238becfe06b869d2ac%3Astacks/autoscaling-example/cb1e6eae-b59d-4788-8b9b-a21d2d16c150/resources/autoscaling_up_policy?SignatureMethod=HmacSHA256&AWSAccessKeyId=58caf713909b4be1813a63757cc89e1c&SignatureVersion=2&Signature=eBn3wJ21VeqpNxj%2BA00L0Q88joislaLEqPdDF7FZvfs%3D",
      "trust+https://api.nz-por-1.catalystcloud.io:8004/v1/9864e20f92ef47238becfe06b869d2ac/stacks/autoscaling-example/cb1e6eae-b59d-4788-8b9b-a21d2d16c150/resources/autoscaling_up_policy/signal"
    ],
    "ok_actions": [],
    "name": "autoscaling-example-autoscaling_cpu_high_alarm-p6bosunxssog",
    "timestamp": "2025-10-10T22:08:11.081755",
    "description": "Scale out if average CPU usage exceeds 20%",
    "time_constraints": [],
    "enabled": true,
    "state_timestamp": "2025-10-10T22:08:11.081755",
    "gnocchi_aggregation_by_resources_threshold_rule": {
      "evaluation_periods": 1,
      "metric": "cpu",
      "threshold": 120000000000.0,
      "granularity": 600,
      "aggregation_method": "rate:mean",
      "query": "{\"and\": [{\"or\": [{\"=\": {\"created_by_project_id\": \"9864e20f92ef47238becfe06b869d2ac\"}}, {\"and\": [{\"=\": {\"created_by_project_id\": \"ceecc421f7994cc397380fae5e495179\"}}, {\"=\": {\"project_id\": \"9864e20f92ef47238becfe06b869d2ac\"}}]}]}, {\"and\": [{\"=\": {\"server_group\": \"7a612ef2-ad1d-49fa-a72d-51253761cdda\"}}, {\"=\": {\"ended_at\": null}}]}]}",
      "comparison_operator": "gt",
      "resource_type": "instance"
    },
    "alarm_id": "334411fa-8f4b-482d-ba05-c4399a7a3393",
    "state": "insufficient data",
    "insufficient_data_actions": [],
    "repeat_actions": true,
    "user_id": "517bcd700274432d96f43616ac1e37ea",
    "state_reason": "Not evaluated yet",
    "project_id": "9864e20f92ef47238becfe06b869d2ac",
    "type": "gnocchi_aggregation_by_resources_threshold",
    "evaluate_timestamp": "2025-10-10T23:23:43",
    "severity": "low"
  }

Note that the alarm is in ``insufficient data`` state. This is normal for
newly created clusters; the Metrics Service collects compute metrics every
10 minutes, so it can take up to 20 minutes before there are enough metrics
for the alarms to be evaluated correctly.

Once some time has passed, the alarm should transition into ``ok`` state.

.. code-block:: console

  $ openstack stack resource show autoscaling-example autoscaling_cpu_high_alarm -c attributes -f json | jq '.attributes'
  {
    "alarm_actions": [
      "https://api.nz-por-1.catalystcloud.io:8000/v1/signal/arn%3Aopenstack%3Aheat%3A%3A9864e20f92ef47238becfe06b869d2ac%3Astacks/autoscaling-example/cb1e6eae-b59d-4788-8b9b-a21d2d16c150/resources/autoscaling_up_policy?SignatureMethod=HmacSHA256&AWSAccessKeyId=58caf713909b4be1813a63757cc89e1c&SignatureVersion=2&Signature=eBn3wJ21VeqpNxj%2BA00L0Q88joislaLEqPdDF7FZvfs%3D",
      "trust+https://api.nz-por-1.catalystcloud.io:8004/v1/9864e20f92ef47238becfe06b869d2ac/stacks/autoscaling-example/cb1e6eae-b59d-4788-8b9b-a21d2d16c150/resources/autoscaling_up_policy/signal"
    ],
    "ok_actions": [],
    "name": "autoscaling-example-autoscaling_cpu_high_alarm-p6bosunxssog",
    "timestamp": "2025-10-10T22:08:11.081755",
    "description": "Scale out if average CPU usage exceeds 20%",
    "time_constraints": [],
    "enabled": true,
    "state_timestamp": "2025-10-10T22:08:11.081755",
    "gnocchi_aggregation_by_resources_threshold_rule": {
      "evaluation_periods": 1,
      "metric": "cpu",
      "threshold": 120000000000.0,
      "granularity": 600,
      "aggregation_method": "rate:mean",
      "query": "{\"and\": [{\"or\": [{\"=\": {\"created_by_project_id\": \"9864e20f92ef47238becfe06b869d2ac\"}}, {\"and\": [{\"=\": {\"created_by_project_id\": \"ceecc421f7994cc397380fae5e495179\"}}, {\"=\": {\"project_id\": \"9864e20f92ef47238becfe06b869d2ac\"}}]}]}, {\"and\": [{\"=\": {\"server_group\": \"7a612ef2-ad1d-49fa-a72d-51253761cdda\"}}, {\"=\": {\"ended_at\": null}}]}]}",
      "comparison_operator": "gt",
      "resource_type": "instance"
    },
    "alarm_id": "334411fa-8f4b-482d-ba05-c4399a7a3393",
    "state": "ok",
    "insufficient_data_actions": [],
    "repeat_actions": true,
    "user_id": "517bcd700274432d96f43616ac1e37ea",
    "state_reason": "Transition to ok due to 1 samples inside threshold, most recent: 2780000000.0",
    "project_id": "9864e20f92ef47238becfe06b869d2ac",
    "type": "gnocchi_aggregation_by_resources_threshold",
    "evaluate_timestamp": "2025-10-10T23:23:43",
    "severity": "low"
  }

.. note::

  You may find that the "low" threshold alarms are always in ``alarm`` state
  due to the load on the instances being lower than the configured thresholds.

  Normally this would result in a scale in, but because we are already at the
  configured minimum number of instances in the cluster (2), nothing happens.
  Similarly, when load exceeds the "high" thresholds and the cluster is already
  running the maximum number of instances, no scale outs are performed despite
  the alarms being triggered.

  This is normal behaviour, and there are no negative side effects
  from the alarms constantly being in a triggered state.

We can now test that auto-scaling actually works as intended
by inducing a load on one of the web servers.

First, fetch the internal IP address of one of the web server instances
using the IDs we fetched earlier.

.. code-block:: console

  $ openstack server show a6745eaf-2939-4899-9966-3aaa229f617f -c addresses -f json | jq --raw-output '.addresses | to_entries | [first][0].value[0]'
  10.0.0.215

With this, we can login to the web server via the jump host.

.. note::

  Open a new terminal tab or window for interacting with the web server,
  as we will be coming back to the OpenStack CLI afterwards to keep an
  eye on the status of the cluster.

The easiest way of doing this is to start an SSH agent in your
terminal, add the SSH key to it, and use the ``ssh -J`` option
when logging in to configure the bastion host as the proxy jump host.

.. code-block:: console

  $ eval $(ssh-agent -s)
  Agent pid 1281681
  $ ssh-add ~/.ssh/keypair_private_key.pem
  Identity added: ~/.ssh/keypair_private_key.pem (example@example.com)
  $ ssh -J ubuntu@192.0.2.1 ubuntu@10.0.0.215
  Warning: Permanently added '10.0.0.215' (ED25519) to the list of known hosts.
  Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.8.0-59-generic x86_64)

  * Documentation:  https://help.ubuntu.com
  * Management:     https://landscape.canonical.com
  * Support:        https://ubuntu.com/pro

  System information as of Sat Oct 11 01:09:45 UTC 2025

    System load:  0.0               Processes:             101
    Usage of /:   18.5% of 8.65GB   Users logged in:       0
    Memory usage: 20%               IPv4 address for ens3: 10.0.0.215
    Swap usage:   0%


  Expanded Security Maintenance for Applications is not enabled.

  0 updates can be applied immediately.

  Enable ESM Apps to receive additional future security updates.
  See https://ubuntu.com/esm or run: sudo pro status


  The list of available updates is more than a week old.
  To check for new updates run: sudo apt update


  The programs included with the Ubuntu system are free software;
  the exact distribution terms for each program are described in the
  individual files in /usr/share/doc/*/copyright.

  Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
  applicable law.

  To run a command as administrator (user "root"), use "sudo <command>".
  See "man sudo_root" for details.

  ubuntu@au-x-k2va3k4min64-kgypkpgxo2t3-webserver-goiwpb5kbnil:~$

Next, update the system, and then use APT to install the ``stress`` package.

.. code-block:: console

  $ sudo apt update
  $ sudo apt upgrade
  $ sudo apt install stress

Finally, run the ``stress`` command in the background
to induce a load on the web server at full utilisation.

The load can then be verified with the ``htop`` command.

.. code-block:: bash

  $ stress --cpu 2 --timeout 1800s &
  $ htop


Go back to your original terminal with the OpenStack CLI active.
If you check the state of the CPU high alarm again, you should
see that it has now been triggered.

.. note::

  Due to compute metrics being collected by the Metrics Service
  every 10 minutes (as noted above), it will take up to 20 minutes
  for the alarms to register the increase in load.

.. code-block:: console

  $ openstack stack resource show autoscaling-example autoscaling_cpu_high_alarm -c attributes -f json | jq '.attributes'
  {
    "alarm_actions": [
      "https://api.nz-por-1.catalystcloud.io:8000/v1/signal/arn%3Aopenstack%3Aheat%3A%3A9864e20f92ef47238becfe06b869d2ac%3Astacks/autoscaling-example/cb1e6eae-b59d-4788-8b9b-a21d2d16c150/resources/autoscaling_up_policy?SignatureMethod=HmacSHA256&AWSAccessKeyId=58caf713909b4be1813a63757cc89e1c&SignatureVersion=2&Signature=eBn3wJ21VeqpNxj%2BA00L0Q88joislaLEqPdDF7FZvfs%3D",
      "trust+https://api.nz-por-1.catalystcloud.io:8004/v1/9864e20f92ef47238becfe06b869d2ac/stacks/autoscaling-example/cb1e6eae-b59d-4788-8b9b-a21d2d16c150/resources/autoscaling_up_policy/signal"
    ],
    "ok_actions": [],
    "name": "autoscaling-example-autoscaling_cpu_high_alarm-p6bosunxssog",
    "timestamp": "2025-10-10T22:08:11.081755",
    "description": "Scale out if average CPU usage exceeds 20%",
    "time_constraints": [],
    "enabled": true,
    "state_timestamp": "2025-10-10T22:08:11.081755",
    "gnocchi_aggregation_by_resources_threshold_rule": {
      "evaluation_periods": 1,
      "metric": "cpu",
      "threshold": 120000000000.0,
      "granularity": 600,
      "aggregation_method": "rate:mean",
      "query": "{\"and\": [{\"or\": [{\"=\": {\"created_by_project_id\": \"9864e20f92ef47238becfe06b869d2ac\"}}, {\"and\": [{\"=\": {\"created_by_project_id\": \"ceecc421f7994cc397380fae5e495179\"}}, {\"=\": {\"project_id\": \"9864e20f92ef47238becfe06b869d2ac\"}}]}]}, {\"and\": [{\"=\": {\"server_group\": \"7a612ef2-ad1d-49fa-a72d-51253761cdda\"}}, {\"=\": {\"ended_at\": null}}]}]}",
      "comparison_operator": "gt",
      "resource_type": "instance"
    },
    "alarm_id": "334411fa-8f4b-482d-ba05-c4399a7a3393",
    "state": "ok",
    "insufficient_data_actions": [],
    "repeat_actions": true,
    "user_id": "517bcd700274432d96f43616ac1e37ea",
    "state_reason": "Transition to ok due to 1 samples inside threshold, most recent: 2780000000.0",
    "project_id": "9864e20f92ef47238becfe06b869d2ac",
    "type": "gnocchi_aggregation_by_resources_threshold",
    "evaluate_timestamp": "2025-10-10T23:23:43",
    "severity": "low"
  }

The alarm has now notified the auto-scaling group that a scale out should occur.

If we re-run the command we used earlier to check the number of running instances,
we now see that a third instance has joined the cluster!

.. code-block:: console

  $ openstack stack resource show autoscaling-example webserver_group -c attributes -f json | jq '.attributes.members'
  [
    "87e11933-f057-4b45-86b6-da0bb4697905",
    "d3d56962-988e-40d6-b5c7-ad7df1abbf63",
    "c3bd7529-0140-4d7a-9bb3-ea8286e13dc5"
  ]

With a third instance now running, we should check that it has joined the
load balancer pool. Using the same ``curl`` command we used earlier,
the third instance should have started responding to requests.

.. code-block:: console

  $ curl http://192.0.2.2
  Hello, world! This request was served by au-x-u6thgn62eec6-ev65hjmjcmss-webserver-vdq2wg3l2mcv (10.0.0.151).
  $ curl http://192.0.2.2
  Hello, world! This request was served by au-x-k2va3k4min64-kgypkpgxo2t3-webserver-goiwpb5kbnil (10.0.0.215).
  $ curl http://192.0.2.2
  Hello, world! This request was served by au-x-f6tup25k7exn-jackdd47dc6k-webserver-7rzds4ycexj6 (10.0.0.105).

Cleanup
=======

We have successfully implemented an auto-scaling, highly available
web application on the Catalyst Cloud Orchestration Service.

This concludes the tutorial. To clean up, all you need to do is
delete the stack and all resources will be quickly deleted.

.. code-block:: bash

  openstack stack delete autoscaling-example
