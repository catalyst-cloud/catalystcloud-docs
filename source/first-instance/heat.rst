.. _launching-your-first-instance-using-heat:

*******************************
Using the orchestration service
*******************************

Heat is the native OpenStack orchestration tool. This section demonstrates how
to create a first instance using Heat.

It is beyond the scope of this section to explain the syntax of writing Heat
templates. A predefined example from the `catalystcloud-orchestration`_ git
repository will be used here as a template. This example may also be used as
the basis for new templates.

.. tip::

  For more information on writing Heat templates, please consult the documentation
  at :ref:`cloud-orchestration`.

Checkout the catalystcloud-orchestration repository. This includes the example
Heat templates:

.. _catalystcloud-orchestration: https://github.com/catalyst/catalystcloud-orchestration

.. code-block:: bash

 $ git clone https://github.com/catalyst/catalystcloud-orchestration.git && ORCHESTRATION_DIR="$(pwd)/catalystcloud-orchestration" && echo $ORCHESTRATION_DIR


Uploading an SSH key
====================

Heat does not support uploading an SSH key. This step must be performed
manually.

When an instance is created, OpenStack passes an SSH key to the instance which
can be used for shell access. By default, Ubuntu will install this key for the
"ubuntu" user. Other operating systems have a different default user, as listed
here: :ref:`images`

Use ``openstack keypair create`` to upload your Public SSH key.

.. tip::

  Name the key using information such as your username and the hostname on which the
  ssh key was generated. This makes the key easy to identify at a later stage.

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
  | testkey    | <SSH_KEY_FINGERPRINT>                           |
  +------------+-------------------------------------------------+


.. note::

 Keypairs must be created in each region being used.


Building the first instance stack using a Heat template
=======================================================

Select the following Heat template from the catalystcloud-orchestration
repository cloned earlier. Before making use of a template, it is good practice
to check that the template is valid:

.. code-block:: bash

 $ openstack orchestration template validate -t $ORCHESTRATION_DIR/hot/ubuntu-18.04/first-instance/first-instance.yaml


This command will echo the yaml if it succeeds and will return an error if it
does not. If the template validates, it may be used to build the stack:

.. code-block:: bash

  $ openstack stack create -t $ORCHESTRATION_DIR/hot/ubuntu-18.04/first-instance/first-instance.yaml first-instance-stack
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



The ``stack_status`` indicates that creation is in progress. Use the
``event list`` command to check on the stack's orchestration progress:

.. code-block:: bash

 $  openstack stack event list first-instance-stack



View the output of the ``stack show`` command for further details:

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
  |                       | image: ubuntu-18.04-x86_64                                                                                                                              |
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


Once the stack status is ``CREATE_COMPLETE``, it is possible to SSH to the
Floating IP of the instance:

.. code-block:: bash

 $ export CC_FLOATING_IP_ID=$( openstack stack resource show -f value -c physical_resource_id first-instance-stack first_instance_server_floating_ip )
 $ export CC_PUBLIC_IP=$( openstack floating ip show -f value -c floating_ip_address $CC_FLOATING_IP_ID )
 $ ssh ubuntu@$CC_PUBLIC_IP


Deleting the first instance stack using Heat
============================================

.. warning::

  If a stack has been orchestrated using Heat, it is generally a good idea to also
  use Heat to delete that stack's resources. Deleting components of a Heat
  orchestrated stack manually, whether using the other command line tools or the
  web interface, can result in resources or stacks being left in an inconsistent
  state.

To delete the ``first-instance-stack`` created previously, proceed as follows:

.. code-block:: bash

 $ openstack stack delete first-instance-stack
 Are you sure you want to delete this stack(s) [y/N]? y

Check that the stack has been deleted properly using the ``openstack stack
list`` command. If there is an error, or if deleting the stack is taking a long
time, check the output of ``openstack stack event list first-instance-stack``.
