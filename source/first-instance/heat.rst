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

Use ``openstack keypair create`` to upload your Public SSH key.

.. tip::
 You can name your key using information like the username and host on which the ssh key was generated so that it is easy to identify later.

.. code-block:: bash

  $ openstack keypair create --public-key ~/.ssh/id_test.pub first-instance-key
  +-------------+-------------------------------------------------+
  | Field       | Value                                           |
  +-------------+-------------------------------------------------+
  | fingerprint | <SSH_KEY_FINGERPRINT>                           |
  | name        | testkey                                         |
  | user_id     | <USER_ID>                                       |
  +-------------+-------------------------------------------------+

  $ openstack keypair list
  +------------+-------------------------------------------------+
  | Name       | Fingerprint                                     |
  +------------+-------------------------------------------------+
  | testkey    | <SSH_KEY_FINGERPRINT> |
  +------------+-------------------------------------------------+

 .. note::
 These keypairs must be created in each region being used.

Building the First Instance Stack using a HEAT Template
=======================================================

We will use a Heat template from the repository we cloned earlier. Before we
start, check that the template is valid:

.. code-block:: bash

 $ openstack orchestration template validate -t $ORCHESTRATION_DIR/hot/ubuntu-14.04/first-instance/first-instance.yaml

This command will echo the yaml if it succeeds and will return an error if it
does not. Assuming the template validates let's build the stack:

.. code-block:: bash

  $ openstack stack create -t $ORCHESTRATION_DIR/hot/ubuntu-14.04/first-instance/first-instance.yaml first-instance-stack
  +---------------------+-------------------------------------------------------------------------------------------+
  | Field               | Value                                                                                     |
  +---------------------+-------------------------------------------------------------------------------------------+
  | id                  | cb956f56-536a-4244-930d-62ae1eb2b182                                                      |
  | stack_name          | first-instance-stack                                                                      |
  | description         | HOT template for building the first instance stack on the Catalyst Cloud nz-por-1 region. |
  |                     |                                                                                           |
  | creation_time       | 2016-08-18T22:39:25Z                                                                      |
  | updated_time        | None                                                                                      |
  | stack_status        | CREATE_IN_PROGRESS                                                                        |
  | stack_status_reason | Stack CREATE started                                                                      |
  +---------------------+-------------------------------------------------------------------------------------------+


As you can see the creation is in progress. You can use the ``event-list``
command to check the progress of creation process:

.. code-block:: bash

 $  openstack stack event list first-instance-stack

Check the output of stack show:

.. code-block:: bash

  $  openstack stack show first-instance-stack
  +-----------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------+
  | Field                 | Value                                                                                                                                                   |
  +-----------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------+
  | id                    | cb956f56-536a-4244-930d-62ae1eb2b182                                                                                                                    |
  | stack_name            | first-instance-stack                                                                                                                                    |
  | description           | HOT template for building the first instance stack on the Catalyst Cloud nz-por-1 region.                                                               |
  |                       |                                                                                                                                                         |
  | creation_time         | 2016-08-18T22:39:25Z                                                                                                                                    |
  | updated_time          | None                                                                                                                                                    |
  | stack_status          | CREATE_COMPLETE                                                                                                                                         |
  | stack_status_reason   | Stack CREATE completed successfully                                                                                                                     |
  | parameters            | OS::project_id: <PROJECT_ID>                                                                                                        |
  |                       | OS::stack_id: cb956f56-536a-4244-930d-62ae1eb2b182                                                                                                      |
  |                       | OS::stack_name: first-instance-stack                                                                                                                    |
  |                       | domain_name: localdomain                                                                                                                                |
  |                       | host_name: first-instance                                                                                                                               |
  |                       | image: ubuntu-14.04-x86_64                                                                                                                              |
  |                       | key_name: first-instance-key                                                                                                                            |
  |                       | private_net_cidr: 10.0.0.0/24                                                                                                                           |
  |                       | private_net_dns_servers: 202.78.247.197,202.78.247.198,202.78.247.199                                                                                   |
  |                       | private_net_gateway: 10.0.0.1                                                                                                                           |
  |                       | private_net_name: private-net                                                                                                                           |
  |                       | private_net_pool_end: 10.0.0.200                                                                                                                        |
  |                       | private_net_pool_start: 10.0.0.10                                                                                                                       |
  |                       | private_subnet_name: private-subnet                                                                                                                     |
  |                       | public_net: public-net                                                                                                                                  |
  |                       | public_net_id: 849ab1e9-7ac5-4618-8801-e6176fbbcf30                                                                                                     |
  |                       | router_name: border-router                                                                                                                              |
  |                       | secgroup_name: first-instance-sg                                                                                                                        |
  |                       | servers_flavor: c1.c1r1                                                                                                                                 |
  |                       |                                                                                                                                                         |
  | outputs               | []                                                                                                                                                      |
  |                       |                                                                                                                                                         |
  | links                 | - href: https://api.nz-por-1.catalystcloud.io:8004/v1/<PROJECT_ID>/stacks/first-instance-stack/cb956f56-536a-4244-930d-62ae1eb2b182 |
  |                       |   rel: self                                                                                                                                             |
  |                       |                                                                                                                                                         |
  | parent                | None                                                                                                                                                    |
  | disable_rollback      | True                                                                                                                                                    |
  | stack_user_project_id | <PROJECT_ID>                                                                                                                        |
  | stack_owner           | None                                                                                                                                                    |
  | capabilities          | []                                                                                                                                                      |
  | notification_topics   | []                                                                                                                                                      |
  | timeout_mins          | None                                                                                                                                                    |
  +-----------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------+


Once our stack status is ``CREATE_COMPLETE`` we can SSH to our first instance
using the floating IP:

.. code-block:: bash

 $ export CC_FLOATING_IP_ID=$( openstack stack resource show first-instance-stack first_instance_server_floating_ip | grep physical_resource_id | awk '{ print $4 } ' )
 $ export CC_PUBLIC_IP=$( openstack ip floating list -c 'Floating IP Address' -c ID | grep $CC_FLOATING_IP_ID | awk '{ print $4 }' )
 $ ssh ubuntu@$CC_PUBLIC_IP

Deleting the First Instance Stack using Heat
============================================

When working with stacks created by Heat it is generally a good idea to use
Heat to delete resources rather than using the other OpenStack command line
tools. Deleting components of the stack manually can result in resources or
stacks in an inconsistent state.

Lets delete the ``first-instance-stack`` we created previously:

.. code-block:: bash

 $ openstack stack delete first-instance-stack
 Are you sure you want to delete this stack(s) [y/N]? y

Check that the stack has been deleted properly using the
``openstack stack list`` command. If there is an error or the
deletion is taking a long time check the output of ``openstack stack event list
first-instance-stack``.
