###################
Cloud orchestration
###################


********
Overview
********

Cloud orchestration allows you to deploy applications and infrastructure using
a simple template language that describes the required resources and their
relationship. The orchestration service manages the life-cycle of application
stacks on your behalf. When a template is modified, the service orchestrates
the required changes to the infrastructure in the appropriate order. Templates
can be managed like code and stored on your preferred version control system.

.. Heat makes auto-scaling easy. You can define a scaling group and a scaling
   policy and Heat will add or remove compute instances to the group as
   required.

The orchestration service can be integrated to configuration management systems
to provision and manage software. It can run Puppet or Chef in standalone mode,
or be used to present compute instances back to the Puppet/Chef master for
software configuration.

The service is currently in beta and available via the APIs and command line
tools. It will be soon exposed via the web dashboard as well. There are no
additional charges for the use of the cloud orchestration service. You will
only pay for the resources consumed by your running application stacks (such as
compute, network and storage).

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

The following HOT template is a simple example that illustrates how to launch a
single instance on the Catalyst Cloud using the Heat orchestration service.

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
      default: cirros-0.3.1-x86_64
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

Validate a template
-------------------

Before launching or updating a stack, you may want to ensure that the heat
orchestration template (HOT) provided is valid. The following command can be
used to validate a HOT template:

.. code-block:: bash

  heat template-validate -f template-file.hot

Creating a stack
----------------

The following example illustrates how to create a stack using Heat. Note that
parameters specified in the HOT template without a default value must be passed
using "--parameters".

.. code-block:: bash

  heat stack-create mystack --template-file test.hot --parameters "key_name=mykey"

Heat will return a confirmation message indicating the stack is being created:

.. code-block:: text

  +--------------------------------------+------------+--------------------+----------------------+
  | id                                   | stack_name | stack_status       | creation_time        |
  +--------------------------------------+------------+--------------------+----------------------+
  | 74236185-7180-40f7-80e2-395229f0c2e9 | mystack    | CREATE_IN_PROGRESS | 2015-04-16T05:54:06Z |
  +--------------------------------------+------------+--------------------+----------------------+

Showing information about a stack
---------------------------------

To obtain information about a running stack:

.. code-block:: bash

  heat stack-show mystack

Heat will return the following information about the stack:

.. code-block:: text

  +----------------------+-----------------------------------------------------------+
  | Property             | Value                                                     |
  +----------------------+-----------------------------------------------------------+
  | capabilities         | []                                                        |
  | creation_time        | 2015-04-16T05:58:49Z                                      |
  | description          | Deploying a single compute instance using Heat.           |
  | disable_rollback     | True                                                      |
  | id                   | 1f913699-010e-4564-ba08-e57dc5e09bca                      |
  | links                | https://api.cloud.catalyst.net.nz:8004/v1/...             |
  | notification_topics  | []                                                        |
  | outputs              | [                                                         |
  |                      |   {                                                       |
  |                      |     "output_value": {                                     |
  |                      |       "frontend": [                                       |
  |                      |         "192.168.0.13"                                    |
  |                      |       ]                                                   |
  |                      |     },                                                    |
  |                      |     "description": "The networks of the deployed server", |
  |                      |     "output_key": "server_networks"                       |
  |                      |   }                                                       |
  |                      | ]                                                         |
  | parameters           | {                                                         |
  |                      |   "OS::stack_name": "mystack",                            |
  |                      |   "key_name": "bruno",                                    |
  |                      |   "flavor": "c1.c1r1",                                    |
  |                      |   "image": "cirros-0.3.1-x86_64",                         |
  |                      |   "OS::stack_id": "1f913699-010e-4564-ba08-e57dc5e09bca"  |
  |                      | }                                                         |
  | stack_name           | mystack                                                   |
  | stack_status         | CREATE_COMPLETE                                           |
  | stack_status_reason  | Stack CREATE completed successfully                       |
  | template_description | Deploying a single compute instance using Heat.           |
  | timeout_mins         | 60                                                        |
  | updated_time         | None                                                      |
  +----------------------+-----------------------------------------------------------+

List resources owned by a stack
-------------------------------

You can list the resources that belong to a stack with the command below:

.. code-block:: bash

  heat resource-list mystack

List events related to a stack
------------------------------

You can list the events related to the life-cycle of a stack with the following
command:

.. code-block:: bash

  heat event-list mystack

This information is useful to troubleshoot templates, as it allows you to
identify whether they are producing the expected events and results.

Individual events can be further analysed using the ``heat event-show``
command.

Deleting a stack
----------------

To delete a stack:

.. code-block:: bash

  heat stack-delete mystack

Heat will return a confirmation message informing the stack is being deleted.

.. code-block:: text

  +--------------------------------------+------------+--------------------+----------------------+
  | id                                   | stack_name | stack_status       | creation_time        |
  +--------------------------------------+------------+--------------------+----------------------+
  | 1f913699-010e-4564-ba08-e57dc5e09bca | mystack    | DELETE_IN_PROGRESS | 2015-04-16T05:58:49Z |
  +--------------------------------------+------------+--------------------+----------------------+


*******************
HOT template format
*******************

More information on the HOT template format can be found on the OpenStack user
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

