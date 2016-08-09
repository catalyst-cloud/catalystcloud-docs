.. _launching-your-first-instance-using-heat:

****************************************
Launching your first instance using Heat
****************************************

Heat is the native OpenStack orchestration tool. This section demonstrates how
to create your first instance using Heat.

It is beyond the scope of this section to explain the syntax of writing heat
templates, thus we will make use of a predefined example from the
`catalystcloud-orchestration`_ git repository. For more information on writing
heat templates please consult the documentation at :ref:`cloud-orchestration`.
The template used in this section can be used as an example template on which
you can build your own templates.

Let's checkout the catalystcloud-orchestration repository which includes the
heat templates we will be using:

.. _catalystcloud-orchestration: https://github.com/catalyst/catalystcloud-orchestration

.. code-block:: bash

 $ git clone https://github.com/catalyst/catalystcloud-orchestration.git && ORCHESTRATION_DIR="$(pwd)/catalystcloud-orchestration" && echo $ORCHESTRATION_DIR

Uploading an SSH key
====================

Heat does not support uploading the key itself so we need to do this step
manually.

When an instance is created, OpenStack passes an SSH key to the instance which
can be used for shell access. By default, Ubuntu will install this key for the
'ubuntu' user. Other operating systems have a different default user, as listed
here: :ref:`images`

Use ``nova keypair-add`` to upload your Public SSH key.

.. code-block:: bash

 $ nova keypair-add --pub-key ~/.ssh/id_rsa.pub first-instance-key
 $ nova keypair-list
 +--------------------+-------------------------------------------------+
 | Name               | Fingerprint                                     |
 +--------------------+-------------------------------------------------+
 | first-instance-key | <SSH_KEY_FINGERPRINT>                           |
 +--------------------+-------------------------------------------------+

Building the First Instance Stack using a HEAT Template
=======================================================

We will use a Heat template from the repository we cloned earlier. Before we
start, check that the template is valid:

.. code-block:: bash

 $ heat template-validate -f $ORCHESTRATION_DIR/hot/ubuntu-14.04/first-instance/first-instance.yaml

This command will echo the yaml if it succeeds and will return an error if it
does not. Assuming the template validates let's build the stack:

.. code-block:: bash

 $ heat stack-create first-instance-stack --template-file $ORCHESTRATION_DIR/hot/ubuntu-14.04/first-instance/first-instance.yaml
 +--------------------------------------+----------------------+--------------------+----------------------+
 | id                                   | stack_name           | stack_status       | creation_time        |
 +--------------------------------------+----------------------+--------------------+----------------------+
 | 18d3a376-ac33-4740-a2d3-19879f4807af | first-instance-stack | CREATE_IN_PROGRESS | 2015-11-12T20:19:42Z |
 +--------------------------------------+----------------------+--------------------+----------------------+

As you can see the creation is in progress. You can use the ``event-list``
command to check the progress of creation process:

.. code-block:: bash

 $ heat event-list first-instance-stack

Check the output of stack show:

.. code-block:: bash

 $ heat stack-show first-instance-stack
 +-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------+
 | Property              | Value                                                                                                                                           |
 +-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------+
 | capabilities          | []                                                                                                                                              |
 | creation_time         | 2016-01-28T03:47:03Z                                                                                                                            |
 | description           | HOT template for building the first instance stack on                                                                                           |
 |                       | the Catalyst Cloud nz-por-1 region.                                                                                                             |
 | disable_rollback      | True                                                                                                                                            |
 | id                    | 12de4178-a638-4b6a-9088-84b588db75e1                                                                                                            |
 | links                 | https://api.nz-por-1.catalystcloud.io:8004/v1/0cb6b9b744594a619b0b7340f424858b/stacks/first-instance-stack/12de4178-a638-4b6a-9088-84b588db75e1 |
 | notification_topics   | []                                                                                                                                              |
 | outputs               | []                                                                                                                                              |
 | parameters            | {                                                                                                                                               |
 |                       |   "OS::project_id": "0cb6b9b744594a619b0b7340f424858b",                                                                                         |
 |                       |   "OS::stack_name": "first-instance-stack",                                                                                                     |
 |                       |   "private_net_cidr": "10.0.0.0/24",                                                                                                            |
 |                       |   "private_subnet_name": "private-subnet",                                                                                                      |
 |                       |   "key_name": "first-instance-key",                                                                                                             |
 |                       |   "image": "ubuntu-14.04-x86_64",                                                                                                               |
 |                       |   "private_net_pool_end": "10.0.0.200",                                                                                                         |
 |                       |   "domain_name": "localdomain",                                                                                                                 |
 |                       |   "OS::stack_id": "12de4178-a638-4b6a-9088-84b588db75e1",                                                                                       |
 |                       |   "private_net_gateway": "10.0.0.1",                                                                                                            |
 |                       |   "public_net": "public-net",                                                                                                                   |
 |                       |   "public_net_id": "849ab1e9-7ac5-4618-8801-e6176fbbcf30",                                                                                      |
 |                       |   "private_net_pool_start": "10.0.0.10",                                                                                                        |
 |                       |   "private_net_dns_servers": "202.78.247.197,202.78.247.198,202.78.247.199",                                                                    |
 |                       |   "private_net_name": "private-net",                                                                                                            |
 |                       |   "secgroup_name": "first-instance-sg",                                                                                                         |
 |                       |   "router_name": "border-router",                                                                                                               |
 |                       |   "servers_flavor": "c1.c1r1",                                                                                                                  |
 |                       |   "host_name": "first-instance"                                                                                                                 |
 |                       | }                                                                                                                                               |
 | parent                | None                                                                                                                                            |
 | stack_name            | first-instance-stack                                                                                                                            |
 | stack_owner           | your@email.net.nz                                                                                                                               |
 | stack_status          | CREATE_COMPLETE                                                                                                                                 |
 | stack_status_reason   | Stack CREATE completed successfully                                                                                                             |
 | stack_user_project_id | 0cb6b9b744594a619b0b7340f424858b                                                                                                                |
 | template_description  | HOT template for building the first instance stack on                                                                                           |
 |                       | the Catalyst Cloud nz-por-1 region.                                                                                                             |
 | timeout_mins          | 60                                                                                                                                              |
 | updated_time          | None                                                                                                                                            |
 +-----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------+

Once our stack status is ``CREATE_COMPLETE`` we can SSH to our first instance
using the floating IP:

.. code-block:: bash

 $ export CC_FLOATING_IP_ID=$( heat resource-show first-instance-stack first_instance_server_floating_ip | grep physical_resource_id | awk '{ print $4 } ' )
 $ export CC_PUBLIC_IP=$( neutron floatingip-list -c floating_ip_address -c id | grep $CC_FLOATING_IP_ID | awk '{ print $2 }' )
 $ ssh ubuntu@$CC_PUBLIC_IP

Deleting the First Instance Stack using Heat
============================================

When working with stacks created by Heat it is generally a good idea to use
Heat to delete resources rather than using the other OpenStack command line
tools. Deleting components of the stack manually can result in resources or
stacks in an inconsistent state.

Lets delete the ``first-instance-stack`` we created previously:

.. code-block:: bash

 $ heat stack-delete first-instance-stack
 +--------------------------------------+----------------------+---------------------+----------------------+
 | id                                   | stack_name           | stack_status        | creation_time        |
 +--------------------------------------+----------------------+---------------------+----------------------+
 | 12de4178-a638-4b6a-9088-84b588db75e1 | first-instance-stack | DELETE_IN_PROGRESS  | 2016-01-28T03:47:03Z |
 +--------------------------------------+----------------------+---------------------+----------------------+

Check that the stack has been deleted properly using the ``heat list``
command. If there is an error or the deletion is taking a long time check the
output of ``heat event-list first-instance-stack``.
