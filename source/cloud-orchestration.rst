###################
Cloud orchestration
###################


********
Overview
********

Heat allows you to deploy applications using a template that describe the
required resources and their relationship. The templates can be managed like
code and stored on your preferred source control system. Heat manages the
life-cycle of the application stacks on your behalf. When you change the
template, it orchestrates the required changes on the infrastructure in the
appropriate order, respecting the relationship and dependencies defined.

.. Heat makes auto-scaling easy. You can define a scaling group and a scaling
   policy and Heat will add or remove compute instances to the group as
   required.

Heat can be integrated to configuration management systems to provision and
manage software. Heat can run Puppet or Chef in standalone mode, or be used to
present compute instances back to the Puppet/Chef master for software
configuration.

Using Heat via the command line tools
=====================================

The following HOT template illustrates how to launch a single instance on the
Catalyst Cloud using the Heat orchestration service.

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
guide at: http://docs.openstack.org/user-guide/content/hot-guide.html
