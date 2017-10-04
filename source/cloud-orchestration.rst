.. _cloud-orchestration:

###################
Cloud orchestration
###################

********
Overview
********

Cloud orchestration allows you to deploy applications and infrastructure using
a simple template language that describes the required resources and their
relationship. The template format is based on YAML and is called Heat
Orchestration Template (HOT). The orchestration service manages the life-cycle
of application stacks on your behalf. When a template is modified, the service
orchestrates the required changes to the infrastructure in the appropriate
order. Templates can be managed like code and stored in your preferred version
control system.

.. Heat makes auto-scaling easy. You can define a scaling group and a scaling
   policy and Heat will add or remove compute instances to the group as
   required.

The orchestration service can be integrated to configuration management systems
to provision and manage software. It can run `Puppet`_ or `Chef`_ in standalone
mode, or be used to present compute instances back to the Puppet/Chef master
for software configuration.

.. _Puppet: https://puppetlabs.com/
.. _Chef: https://www.chef.io/

There are no additional charges for the use of the cloud orchestration service.
You will only pay for the resources consumed by your running application stacks
(such as compute, network and storage).

The OpenStack project that provides orchestration is known as Heat. More
information about Heat can be found in the OpenStack wiki:
https://wiki.openstack.org/wiki/Heat

Using Heat via the command line tools
=====================================

Sample templates
----------------

Catalyst has published example templates that demonstrate the use of the cloud
orchestration service at:
https://github.com/catalyst/catalystcloud-orchestration.

.. note::

  The default username for all compute instances created by the cloud
  orchestration service (Heat) is "ec2-user". This is done to retain
  compatibility with the AWS CloudFormation service.

The following heat Heat Orchestration Template (HOT) is a simple example
that illustrates how to launch a single instance on the Catalyst Cloud
using the Heat orchestration service.

.. code-block:: yaml

  #
  # Deploying a compute instance using Heat
  #
  heat_template_version: 2013-05-23

  description: >
    Deploying a single compute instance using Heat.

  parameters:
    key_name:
      type: string
      description: Name of an existing key pair to use for the server
      constraints:
        - custom_constraint: nova.keypair
    flavor:
      type: string
      description: Flavor for the server to be created
      default: c1.c1r1
      constraints:
        - custom_constraint: nova.flavor
    image:
      type: string
      description: Image ID or image name to use for the server
      default: atomic-7-x86_64
      constraints:
        - custom_constraint: glance.image

  resources:
    server:
      type: OS::Nova::Server
      properties:
        key_name: { get_param: key_name }
        image: { get_param: image }
        flavor: { get_param: flavor }

  outputs:
    server_networks:
      description: The networks of the deployed server
      value: { get_attr: [server, networks] }

If the more typical choice of default user (i.e "ubuntu" for Ubuntu images,
"centos" for Centos etc.) is desired, then amend the template to specify
a user_data_format of "RAW" in the ``OS::Nova::Server`` properties:

.. code-block:: yaml

  resources:
    server:
      type: OS::Nova::Server
      properties:
        key_name: { get_param: key_name }
        image: { get_param: image }
        flavor: { get_param: flavor }
        user_data_format: RAW

If your tenant has multiple private networks, then the above example will fail
to start an instance - you need to specify which private network to attach to:

.. code-block:: yaml

  parameters:
    net:
      type: string
      description: Network for the server use
      default: private_net
      constraints:
        - custom_constraint: neutron.network

  resources:
    server:
      type: OS::Nova::Server
      properties:
        key_name: { get_param: key_name }
        image: { get_param: image }
        flavor: { get_param: flavor }
        user_data_format: RAW
        networks:
          - network: {get_param: net}

Validate a template
-------------------

Before launching or updating a stack, you may want to ensure that the HOT
provided is valid. The following command can be used to validate a HOT:

.. code-block:: bash

 $ openstack orchestration template validate-f template-file.hot

This command will return the yaml if it validates and will return an error with
a message if it is invalid.

Creating a stack
----------------

.. note::

  A stack is the collection of resources that will be created by Heat. This
  might include instances (VMs), networks, subnets, routers, ports, router
  interfaces, security groups, security group rules, auto-scaling rules, etc.

The following example illustrates how to create a stack using Heat. Note that
parameters specified in the HOT without a default value must be passed
using the ``--parameter`` argument. You can pass multiple parameters by
separating them with a semicolon.

.. code-block:: bash

  $ openstack stack create -t test.hot --parameter "key_name=mykey" mystack

Heat will return a confirmation message indicating the stack is being created:

.. code-block:: text

  +---------------------+-------------------------------------------------+
  | Field               | Value                                           |
  +---------------------+-------------------------------------------------+
  | id                  | f2975b89-4a34-4333-90e3-3712636f6d1b            |
  | stack_name          | mystack                                         |
  | description         | Deploying a single compute instance using Heat. |
  |                     |                                                 |
  | creation_time       | 2016-08-21T23:37:39Z                            |
  | updated_time        | None                                            |
  | stack_status        | CREATE_IN_PROGRESS                              |
  | stack_status_reason | Stack CREATE started                            |
  +---------------------+-------------------------------------------------+

Showing information about a stack
---------------------------------

To obtain information about a running stack:

.. code-block:: bash

  $ openstack stack show mystack

Heat will return the following information about the stack:

.. code-block:: text

  +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------+
  | Field                 | Value                                                                                                                                      |
  +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------+
  | id                    | 700a9425-8ed8-4993-8773-eed4a276b040                                                                                                       |
  | stack_name            | mystack                                                                                                                                    |
  | description           | Deploying a single compute instance using Heat.                                                                                            |
  |                       |                                                                                                                                            |
  | creation_time         | 2016-08-22T00:44:14Z                                                                                                                       |
  | updated_time          | None                                                                                                                                       |
  | stack_status          | CREATE_COMPLETE                                                                                                                            |
  | stack_status_reason   | Stack CREATE completed successfully                                                                                                        |
  | parameters            | OS::project_id: 3d5d40b4a6904e6db4dc5321f53d4f39                                                                                           |
  |                       | OS::stack_id: 700a9425-8ed8-4993-8773-eed4a276b040                                                                                         |
  |                       | OS::stack_name: mystack                                                                                                                    |
  |                       | flavor: c1.c1r1                                                                                                                            |
  |                       | image: atomic-7-x86_64                                                                                                                     |
  |                       | key_name: glyndavies                                                                                                                       |
  |                       |                                                                                                                                            |
  | outputs               | - description: The networks of the deployed server                                                                                         |
  |                       |   output_key: server_networks                                                                                                              |
  |                       |   output_value:                                                                                                                            |
  |                       |     private-net:                                                                                                                           |
  |                       |     - 192.168.100.17                                                                                                                       |
  |                       |                                                                                                                                            |
  | links                 | - href: https://api.nz-por-1.catalystcloud.io:8004/v1/3d5d40b4a6904e6db4dc5321f53d4f39/stacks/mystack/700a9425-8ed8-4993-8773-eed4a276b040 |
  |                       |   rel: self                                                                                                                                |
  |                       |                                                                                                                                            |
  | parent                | None                                                                                                                                       |
  | disable_rollback      | True                                                                                                                                       |
  | stack_user_project_id | 3d5d40b4a6904e6db4dc5321f53d4f39                                                                                                           |
  | stack_owner           | None                                                                                                                                       |
  | capabilities          | []                                                                                                                                         |
  | notification_topics   | []                                                                                                                                         |
  | timeout_mins          | None                                                                                                                                       |
  +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------

List resources owned by a stack
-------------------------------

You can list the resources that belong to a stack with the command below:

.. code-block:: bash

  $ openstack stack resource list mystack
  +---------------+--------------------------------------+------------------+-----------------+----------------------+
  | resource_name | physical_resource_id                 | resource_type    | resource_status | updated_time         |
  +---------------+--------------------------------------+------------------+-----------------+----------------------+
  | server        | 498df201-7206-4565-822d-3482fb10b5a7 | OS::Nova::Server | CREATE_COMPLETE | 2016-08-22T00:44:14Z |
  +---------------+--------------------------------------+------------------+-----------------+----------------------+


List events related to a stack
------------------------------

You can list the events related to the life-cycle of a stack with the following
command:

.. code-block:: bash

 $ openstack stack event list mystack

This information is useful for troubleshooting templates, as it allows you to
identify whether they are producing the expected events and results.

Individual events can be further analysed using the ``heat event-show``
command.

Deleting a stack
----------------

To delete a stack:

.. code-block:: bash

  $ openstack stack delete mystack

Heat will return a confirmation message saying the stack is being deleted.

.. code-block:: text

  +--------------------------------------+------------+--------------------+----------------------+
  | id                                   | stack_name | stack_status       | creation_time        |
  +--------------------------------------+------------+--------------------+----------------------+
  | 1f913699-010e-4564-ba08-e57dc5e09bca | mystack    | DELETE_IN_PROGRESS | 2015-04-16T05:58:49Z |
  +--------------------------------------+------------+--------------------+----------------------+


*******************
HOT format
*******************

More information on the HOT format can be found on the OpenStack user
guide at: http://docs.openstack.org/user-guide/hot-guide/hot.html

More information on resource types that can be orchestrated by Heat can be
found at:
http://docs.openstack.org/developer/heat/template_guide/openstack.html

.. note::

  Only resources related to services provided by the Catalyst Cloud should be
  used.

The resource types available on the Catalyst Cloud are:

* OS::Cinder::Volume
* OS::Cinder::VolumeAttachment
* OS::Glance::Image
* OS::Heat::AccessPolicy
* OS::Heat::AutoScalingGroup
* OS::Heat::CloudConfig
* OS::Heat::HARestarter
* OS::Heat::InstanceGroup
* OS::Heat::MultipartMime
* OS::Heat::RandomString
* OS::Heat::ResourceGroup
* OS::Heat::ScalingPolicy
* OS::Heat::SoftwareComponent
* OS::Heat::SoftwareConfig
* OS::Heat::SoftwareDeployment
* OS::Heat::SoftwareDeployments
* OS::Heat::Stack
* OS::Heat::StructuredConfig
* OS::Heat::StructuredDeployment
* OS::Heat::StructuredDeployments
* OS::Heat::SwiftSignal
* OS::Heat::SwiftSignalHandle
* OS::Heat::UpdateWaitConditionHandle
* OS::Heat::WaitCondition
* OS::Heat::WaitConditionHandle
* OS::Neutron::FloatingIP
* OS::Neutron::FloatingIPAssociation
* OS::Neutron::HealthMonitor
* OS::Neutron::IKEPolicy
* OS::Neutron::IPsecPolicy
* OS::Neutron::IPsecSiteConnection
* OS::Neutron::MeteringLabel
* OS::Neutron::MeteringRule
* OS::Neutron::Net
* OS::Neutron::NetworkGateway
* OS::Neutron::Port
* OS::Neutron::ProviderNet
* OS::Neutron::Router
* OS::Neutron::RouterGateway
* OS::Neutron::RouterInterface
* OS::Neutron::SecurityGroup
* OS::Neutron::Subnet
* OS::Neutron::VPNService
* OS::Nova::FloatingIP
* OS::Nova::FloatingIPAssociation
* OS::Nova::KeyPair
* OS::Nova::Server
* OS::Nova::ServerGroup
* OS::Swift::Container

.. Resources to be added in the future
.. * OS::Ceilometer::Alarm
.. * OS::Ceilometer::CombinationAlarm
.. * OS::Neutron::Firewall
.. * OS::Neutron::FirewallPolicy
.. * OS::Neutron::FirewallRule
.. * OS::Neutron::LoadBalancer
.. * OS::Neutron::Pool
.. * OS::Neutron::PoolMember
.. * OS::Sahara::Cluster
.. * OS::Sahara::ClusterTemplate
.. * OS::Sahara::NodeGroupTemplate
.. * OS::Trove::Cluster
.. * OS::Trove::Instance


***
FAQ
***

.. _project-id-name:

How do I find my project ID or name?
====================================

There are a number of ways to find your project ID and name.

Using the Dashboard
-------------------
The project ID and name can be found in the ``User Credentials`` popup. This
can be accessed by clicking on `+View Credentials`_ in the `API Access` tab
on the main

.. _+View Credentials: https://dashboard.cloud.catalyst.net.nz/project/access_and_security/api_access/view_credentials/
.. _Access & Security: https://dashboard.cloud.catalyst.net.nz/project/access_and_security/
.. _API Access: https://dashboard.cloud.catalyst.net.nz/project/access_and_security/?tab=access_security_tabs__api_access_tab

Using the Command Line
----------------------

If you are using the OpenStack command line tools you have most likely sourced
an openrc file, as explained in :ref:`command-line-interface`. If this is the
case, you can find your project ID by issuing the following command:

.. code-block:: bash

 $ echo $OS_TENANT_ID
 1234567892b04ed38247bab7d808e214

 $ echo $OS_TENANT_NAME
 My-Example-Company-Ltd

Alternatively, you can use the ``openstack configuration show`` command:

.. code-block:: bash

 $ openstack configuration show -c auth.project_id -f value
 1234567892b04ed38247bab7d808e214

 $ openstack configuration show -c auth.project_name -f value
 My-Example-Company-Ltd
