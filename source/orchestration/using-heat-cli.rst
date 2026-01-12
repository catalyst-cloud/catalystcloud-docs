#####################################
Using heat via the command line tools
#####################################

.. _orchestration-prerequisites:

*************
Prerequisites
*************

Setting up users
================

The following roles must be configured on your Catalyst Cloud user
to be able to use the Orchestration Service:

* :ref:`project_member_role`
* :ref:`heat_stack_owner_role`

For more information, see :ref:`Access Control <access_control>`.

Setting up your environment
===========================

First, follow the instructions for :ref:`setting up the CLI Tools and SDKs <sdks_and_toolkits>`.

Make sure you have :ref:`sourced the OpenRC file for your project <source-rc-file>` in an open terminal.

Check that the ``openstack stack`` series of commands are available.
If not, make sure the ``python-heatclient`` package is installed.

.. code-block:: console

  $ openstack stack --help
  Command "stack" matches:
    stack abandon
    stack adopt
    stack cancel
    stack check
    stack create
    stack delete
    stack environment show
    stack event list
    stack event show
    stack export
    stack failures list
    stack file list
    stack hook clear
    stack hook poll
    stack list
    stack output list
    stack output show
    stack resource list
    stack resource mark unhealthy
    stack resource metadata
    stack resource show
    stack resource signal
    stack resume
    stack show
    stack snapshot create
    stack snapshot delete
    stack snapshot list
    stack snapshot restore
    stack snapshot show
    stack suspend
    stack template show
    stack update

When using :ref:`auto-scaling <autoscaling-on-catalyst-cloud>`,
it is highly recommended to make sure you can also access the Catalyst Cloud
:ref:`Metrics Service <metrics-getting-started>` and :ref:`Alarm Service <alarm-overview>`,
as this will allow you to observe the state of the resources and metrics used.

****************
Sample templates
****************

Catalyst Cloud has published example templates that demonstrate the use of the cloud
orchestration service at:
https://github.com/catalyst-cloud/catalystcloud-orchestration.

The following Heat Orchestration Template (HOT) is a simple example
that illustrates how to launch a single instance on Catalyst Cloud
using the Heat orchestration service. For a more interactive
example of how to create an instance using a HOT template, please refer to
:ref:`'your first instance using orchestration'
<launching-your-first-instance-using-heat>` in the documentation.

|

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

If your project has multiple private networks, then the above example will fail
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

*******************
Validate a template
*******************

Before launching or updating a stack, you may want to ensure that the HOT
provided is valid. The following command can be used to validate a HOT:

.. code-block:: bash

 $ openstack orchestration template validate -f hot -t template-file.HOT

This command will return the yaml if it validates and will return an error with
a message if it is invalid.

****************
Creating a stack
****************

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
  | id                  | f2975b89-4a34-4333-90e3-xxxxxxxxxxxx            |
  | stack_name          | mystack                                         |
  | description         | Deploying a single compute instance using Heat. |
  |                     |                                                 |
  | creation_time       | 2016-08-21T23:37:39Z                            |
  | updated_time        | None                                            |
  | stack_status        | CREATE_IN_PROGRESS                              |
  | stack_status_reason | Stack CREATE started                            |
  +---------------------+-------------------------------------------------+

*********************************
Showing information about a stack
*********************************

To obtain information about a running stack:

.. code-block:: bash

  $ openstack stack show mystack

Heat will return the following information about the stack:

.. code-block:: text

  +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------+
  | Field                 | Value                                                                                                                                      |
  +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------+
  | id                    | 700a9425-8ed8-4993-8773-xxxxxxxxxxxx                                                                                                       |
  | stack_name            | mystack                                                                                                                                    |
  | description           | Deploying a single compute instance using Heat.                                                                                            |
  |                       |                                                                                                                                            |
  | creation_time         | 2016-08-22T00:44:14Z                                                                                                                       |
  | updated_time          | None                                                                                                                                       |
  | stack_status          | CREATE_COMPLETE                                                                                                                            |
  | stack_status_reason   | Stack CREATE completed successfully                                                                                                        |
  | parameters            | OS::project_id: 3d5d40b4a6904e6db4xxxxxxf53d4f39                                                                                           |
  |                       | OS::stack_id: 700a9425-8ed8-4993-8773-xxxxxxxxxxxx                                                                                         |
  |                       | OS::stack_name: mystack                                                                                                                    |
  |                       | flavor: c1.c1r1                                                                                                                            |
  |                       | image: atomic-7-x86_64                                                                                                                     |
  |                       | key_name: glxxxxxxes                                                                                                                       |
  |                       |                                                                                                                                            |
  | outputs               | - description: The networks of the deployed server                                                                                         |
  |                       |   output_key: server_networks                                                                                                              |
  |                       |   output_value:                                                                                                                            |
  |                       |     private-net:                                                                                                                           |
  |                       |     - 192.168.100.17                                                                                                                       |
  |                       |                                                                                                                                            |
  | links                 | - href: https://api.nz-por-1.catalystcloud.io:8004/v1/3d5d40b4a6904e6db4xxxxxxf53d4f39/stacks/mystack/700a9425-8ed8-4993-8773-xxxxxxxxxxxx |
  |                       |   rel: self                                                                                                                                |
  |                       |                                                                                                                                            |
  | parent                | None                                                                                                                                       |
  | disable_rollback      | True                                                                                                                                       |
  | stack_user_project_id | 3d5d40b4a6904e6db4xxxxxxf53d4f39                                                                                                           |
  | stack_owner           | None                                                                                                                                       |
  | capabilities          | []                                                                                                                                         |
  | notification_topics   | []                                                                                                                                         |
  | timeout_mins          | None                                                                                                                                       |
  +-----------------------+--------------------------------------------------------------------------------------------------------------------------------------------

*******************************
List resources owned by a stack
*******************************

You can list the resources that belong to a stack with the command below:

.. code-block:: bash

  $ openstack stack resource list mystack
  +---------------+--------------------------------------+------------------+-----------------+----------------------+
  | resource_name | physical_resource_id                 | resource_type    | resource_status | updated_time         |
  +---------------+--------------------------------------+------------------+-----------------+----------------------+
  | server        | 498df201-7206-4565-822d-xxxxxxxxxxxx | OS::Nova::Server | CREATE_COMPLETE | 2016-08-22T00:44:14Z |
  +---------------+--------------------------------------+------------------+-----------------+----------------------+

******************************
List events related to a stack
******************************

You can list the events related to the life-cycle of a stack with the following
command:

.. code-block:: bash

 $ openstack stack event list mystack

This information is useful for troubleshooting templates, as it allows you to
identify whether they are producing the expected events and results.

Individual events can be further analysed using the ``heat event-show``
command.

.. _orchestration-stack-delete:

****************
Deleting a stack
****************

Orchestration stacks can be deleted using the following command
(substituting ``mystack`` with the name or ID of the stack you
want to delete):

.. code-block:: bash

  openstack stack delete mystack

You will be asked to confirm that you want to delete the stack.
Enter ``y`` and press Enter to confirm the deletion.

.. code-block:: console

  $ openstack stack delete mystack
  Are you sure you want to delete this stack(s) [y/N]? y

The stack will transition into ``DELETE_IN_PROGRESS`` state,
and the resources will start to be deleted.

.. code-block:: console

  $ openstack stack list
  +--------------------------------------+------------+--------------------+----------------------+
  | id                                   | stack_name | stack_status       | creation_time        |
  +--------------------------------------+------------+--------------------+----------------------+
  | 1f913699-010e-4564-ba08-xxxxxxxxxxxx | mystack    | DELETE_IN_PROGRESS | 2015-04-16T05:58:49Z |
  +--------------------------------------+------------+--------------------+----------------------+

All resources created by the stack will be automatically and quickly deleted.
Once the resources owned by the stack have been deleted, the stack itself
will be deleted and no longer available.

You can watch the resources being deleted with the following command,
to make sure all resources are being deleted properly:

.. code-block:: bash

  watch openstack stack resource list mystack

.. note::

  If any resources report a resource status of ``DELETE_FAILED``,
  you can find out the reason using the following command:

  .. code-block:: bash

    openstack stack failures list mystack

  If the output does not point to a particular root cause, try deleting the resource
  manually using the CLI for the respective service; that should give you a better
  idea of why the resource is failing to be deleted.

  If a resource cannot be deleted due to being in an ``ERROR`` state, please
  raise a ticket via the `Support Centre`_ and we will help you resolve the issue.

  .. _`Support Centre`: https://catalystcloud.nz/support/support-centre

  Once the resources that failed to delete have been cleaned up, the rest of the
  resources should be deleted automatically.
