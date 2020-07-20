.. _access_control:

**************
Access control
**************

.. _project_users:

Project users
=============
From this screen it is possible to manage which users have access to the
project and the permissions that they will be assigned.

.. image:: ../_static/project_users.png

Roles
=====

Roles are given out to different accounts by a project administrator or
moderator. These allow the accounts
to perform actions that the role has security permissions for. This
insures that you as a ``Project admin`` can hold users to account for there
actions, or limit users ability to perform potentially harmful actions.

On the catalyst cloud there are several key roles that you need to learn when
you're wanting to add more users to your project. More than one role can be
given to a user and with some cases such as the Heat Stack Owner role,
you need multiple roles to have full control of the project. These roles can be
amended once a user has accepted your invitation to the project.

The roles are additive meaning that you can hold a lesser role like 'auth_only'
that is supposed to restrict permissions and a role like 'member' that *allows*
those same restricted permissions. The one that allows permissions supersedes
the role that restricts. This also is relevant when you are talking about
accounts that can add or remove permissions. An admin account has more
permissions than a moderator account. Therefore an admin account cannot have
it's roles removed by a moderator, but an admin **can** remove the roles of a
moderator.

The roles available are split up between General roles, that control your
ability to make changes to the project as a whole. And Kubernetes roles which
are as the name suggests all to do with Kubernetes and the control of clusters.
Information on the Kubernetes roles can be found
:ref:`here <kubernetes-user-access>`

General roles:
==============

Project admin
-------------

The *Project Admin* role allows users to have full control over who has access
to the project, including adding moderators and inviting other people to join
it. However, this role is purely for administrating purposes. It does not
allow you to access or view all resources, you still need the member role for
that.

The list of explicit permissions for the project admin role:

.. code-block:: console

   +-----------------------+------------------------------------------------------------------------+
   | Project Administrator | openstack.volume.get                                                   |
   |                       | openstack.volume.initialize_connection                                 |
   |                       | keystone.identity.project_users_access                                 |
   +-----------------------+------------------------------------------------------------------------+

Project moderator
-----------------

The *Project Moderator* role can invite other people to join your project and
update their roles, but cannot change any of the roles that a project admin has.
This role also has the same problem as the Admin role in regards to resource
access.

The list of explicit permissions for the project moderator role:

.. code-block:: console

   +-----------------------+------------------------------------------------------------------------+
   | Project Moderator     | keystone.identity.project_users_access                                 |
   +-----------------------+------------------------------------------------------------------------+

Project member
--------------

The *Project Member* role gives users access to all services on your project.
The role does not however allow them to invite other people to join the project
nor can a *Project Member* update roles. This role encompasses a number of
others in terms of the privileges that it allows. As
mentioned earlier, because our roles are additive you do not need all of them
to have full control over the project.

The list of explicit permissions for the project member role. This list is
quite extensive as the role covers almost all the service on the cloud:

.. code-block:: console

   +-----------------------+------------------------------------------------------------------------+
   | Role                  | Permissions                                                            |
   +=======================+========================================================================+
   | Project Member        | ALARM SERVICE                                                          |
   |                       | openstack.alarm.create                                                 |
   |                       | openstack.alarm.delete                                                 |
   |                       | openstack.alarm.list                                                   |
   |                       | openstack.alarm.show                                                   |
   |                       | openstack.alarm.state get                                              |
   |                       | openstack.alarm.state set                                              |
   |                       | openstack.alarm-history.search                                         |
   |                       | openstack.alarm-history.show                                           |
   |                       |                                                                        |
   |                       | COMPUTE SERVICE                                                        |
   |                       | openstack.compute.create                                               |
   |                       | openstack.compute.attach_network                                       |
   |                       | openstack.compute.attach_volume                                        |
   |                       | openstack.compute.detach_volume                                        |
   |                       | openstack.compute.get_all                                              |
   |                       | openstack.compute.start                                                |
   |                       | openstack.compute.stop                                                 |
   |                       | openstack.compute.get                                                  |
   |                       | openstack.compute.shelve                                               |
   |                       | openstack.compute.unshelve                                             |
   |                       | openstack.compute.resize                                               |
   |                       | openstack.compute.confirm_resize                                       |
   |                       | openstack.compute.revert_resize                                        |
   |                       | openstack.compute.rebuild                                              |
   |                       | openstack.compute.reboot                                               |
   |                       | openstack.compute.volume_snapshot_create                               |
   |                       | openstack.compute.volume_snapshot_delete                               |
   |                       | openstack.compute.add_fixed_ip                                         |
   |                       | openstack.compute.remoive_fixed_ip                                     |
   |                       | openstack.compute.attach_interface                                     |
   |                       | openstack.compute.delete_interface                                     |
   |                       | openstack.compute.backup                                               |
   |                       | openstack.compute.lock                                                 |
   |                       | openstack.compute.unlock                                               |
   |                       | openstack.compute.pause                                                |
   |                       | openstack.compute.unpause                                              |
   |                       | openstack.compute.rescue                                               |
   |                       | openstack.compute.unrescue                                             |
   |                       | openstack.compute.resume                                               |
   |                       | openstack.compute.security_groups:add_to_instance                      |
   |                       | openstack.compute.security_groups:remove_from_instance                 |
   |                       | openstack.compute.network.associate                                    |
   |                       | openstack.compute.network.disassociate                                 |
   |                       | openstack.compute.network.allocate_for_instance                        |
   |                       | openstack.compute.network.deallocate_for_instance                      |
   |                       | openstack.compute.snapshot                                             |
   |                       | openstack.compute.suspend                                              |
   |                       | openstack.compute.swap_volume                                          |
   |                       | openstack.compute.compute_extension:keypairs.create                    |
   |                       | openstack.compute.compute_extension:keypairs.delete                    |
   |                       | openstack.compute.compute_extension:keypairs.index                     |
   |                       | openstack.compute.compute_extension:keypairs.show                      |
   |                       |                                                                        |
   |                       | IMAGES                                                                 |
   |                       | openstack.image.add_image                                              |
   |                       | openstack.image.delete_image                                           |
   |                       | openstack.image.get_image                                              |
   |                       | openstack.image.get_images                                             |
   |                       | openstack.image.modify_image                                           |
   |                       | openstack.image.copy_from                                              |
   |                       | openstack.image.download_image                                         |
   |                       | openstack.image.upload_image                                           |
   |                       | openstack.image.delete_image_location                                  |
   |                       | openstack.image.get_image_location                                     |
   |                       | openstack.image.set_image_location                                     |
   |                       |                                                                        |
   |                       | NETWORK SERVICE                                                        |
   |                       | openstack.subnet.create_subnet                                         |
   |                       | openstack.subnet.get_subnet                                            |
   |                       | openstack.subnet.update_subnet                                         |
   |                       | openstack.subnet.delete_subnet                                         |
   |                       | openstack.subnet.create_subnetpool                                     |
   |                       | openstack.subnet.get_subnetpool                                        |
   |                       | openstack.subnet.update_subnetpool                                     |
   |                       | openstack.subnet.delete_subnetpool                                     |
   |                       | openstack.address.create_address_scope                                 |
   |                       | openstack.address.get_address_scope                                    |
   |                       | openstack.address.update_address_scope                                 |
   |                       | openstack.address.delete_address_scope                                 |
   |                       | openstack.network.create_network                                       |
   |                       | openstack.network.get_network                                          |
   |                       | openstack.network.update_network                                       |
   |                       | openstack.network.delete_network                                       |
   |                       | openstack.port.create_port                                             |
   |                       | openstack.port.create_port:device                                      |
   |                       | openstack.port.create_port:mac_address                                 |
   |                       | openstack.port.create_port:fixed_ips                                   |
   |                       | openstack.port.create_port:security_port_enabled                       |
   |                       | openstack.port.create_port:mac_learning_enabled                        |
   |                       | openstack.port.create_port:allowed_address_pairs                       |
   |                       | openstack.port.get_port                                                |
   |                       | openstack.port.update_port                                             |
   |                       | openstack.port.update_port:device_owner                                |
   |                       | openstack.port.update_port:fixed_ips                                   |
   |                       | openstack.port.update_port:port_security_enabled                       |
   |                       | openstack.port.update_port:mac_learning_enabled                        |
   |                       | openstack.port.update_port:allowed_address_pairs                       |
   |                       | openstack.port.delete_port                                             |
   |                       | openstack.router.create_router                                         |
   |                       | openstack.router.get_router                                            |
   |                       | openstack.router.delete_router                                         |
   |                       | openstack.router.add_router_interface                                  |
   |                       | openstack.router.remove_router_interface                               |
   |                       | firewall.create_firewall                                               |
   |                       | firewall.get_firewall                                                  |
   |                       | firewall.update_firewall                                               |
   |                       | firewall.delete_firewall                                               |
   |                       | firewall.create_firewall_policy                                        |
   |                       | firewall.get_firewall_policy                                           |
   |                       | firewall.create_firewall_policy:shared                                 |
   |                       | firewall.update_firewall_policy                                        |
   |                       | firewall.delete_firewall_policy                                        |
   |                       | firewall.create_firewall_rule                                          |
   |                       | firewall.get_firewall_rule                                             |
   |                       | firewall.update_firewall_rule                                          |
   |                       | firewall.delete_firewall_rule                                          |
   |                       | openstack.floatingip.create_floating_ip                                |
   |                       | openstack.floatingip.update_floating_ip                                |
   |                       | openstack.floatingip.delete_floating_ip                                |
   |                       | openstack.floatingip.get_floating_ip                                   |
   |                       |                                                                        |
   |                       | LOAD BALANCER SERVICE                                                  |
   |                       | openstack.loadbalancer.read                                            |
   |                       | openstack.loadbalancer.write                                           |
   |                       | openstack.loadbalancer.read-quota                                      |
   |                       | openstack.loadbalancer.healthmonitor.get_all                           |
   |                       | openstack.loadbalancer.healthmonitor.post                              |
   |                       | openstack.loadbalancer.healthmonitor.get_one                           |
   |                       | openstack.loadbalancer.healthmonitor.put                               |
   |                       | openstack.loadbalancer.healthmonitor.delete                            |
   |                       | openstack.loadbalancer.policy.*                                        |
   |                       | openstack.loadbalancer.rule.*                                          |
   |                       | openstack.loadbalancer.loadbalancer.*                                  |
   |                       | openstack.loadbalancer.pool.*                                          |
   |                       |                                                                        |
   |                       | VOLUME SERVICE                                                         |
   |                       | openstack.volume.create                                                |
   |                       | openstack.volume.delete                                                |
   |                       | openstack.volume.get                                                   |
   |                       | openstack.volume.get_all                                               |
   |                       | openstack.volume.get_volume_metadata                                   |
   |                       | openstack.volume.get_snapshot                                          |
   |                       | openstack.volume.get_all_snapshots                                     |
   |                       | openstack.volume.create_snapshot                                       |
   |                       | openstack.volume.delete_snapshot                                       |
   |                       | openstack.volume.update_snapshot                                       |
   |                       | openstack.volume.extend                                                |
   |                       | openstack.volume.update                                                |
   |                       | openstack.volume_extension.volume_type_access                          |
   |                       | openstack.volume_extension.encryption_metadata                         |
   |                       | openstack.volume_extension.snapshot_attributes                         |
   |                       | openstack.volume_extension.volume_image_metadata                       |
   |                       | openstack.volume_extension.quota.show                                  |
   |                       | openstack.volume_extension.volume_tenant_attribute                     |
   |                       | openstack.volume.create_transfer                                       |
   |                       | openstack.volume.accept_transfer                                       |
   |                       | openstack.volume.delete_transfer                                       |
   |                       | openstack.volume.get_all_transfers                                     |
   |                       | openstack.backup.create                                                |
   |                       | openstack.backup.delete                                                |
   |                       | openstack.backup.get                                                   |
   |                       | openstack.backup.get_all                                               |
   |                       | openstack.backup.restore                                               |
   |                       | openstack.snapshot_extension.snapshot_actions.update_snapshot_status   |
   |                       |                                                                        |
   |                       | ORCHESTRATION SERVICE                                                  |
   |                       | openstack.stacks.lookup                                                |
   |                       |                                                                        |
   |                       | OBJECT STORAGE                                                         |
   |                       | swift.delete.container                                                 |
   |                       | swift.delete.object                                                    |
   |                       | swift.download.container                                               |
   |                       | swift.download.object                                                  |
   |                       | swift.list.container                                                   |
   |                       | swift.post.container                                                   |
   |                       | swift.post.object                                                      |
   |                       | swift.post.account                                                     |
   |                       | swift.copy.container                                                   |
   |                       | swift.copy.object                                                      |
   |                       | swift.stat.container                                                   |
   |                       | swift.stat.object                                                      |
   |                       | swift.upload.file                                                      |
   |                       | swift.upload.folder                                                    |
   |                       | swift.capabilities.proxy_url                                           |
   |                       | swift.tempurl.container                                                |
   |                       | swift.tempurl.object                                                   |
   |                       | swift.auth.storage_url                                                 |
   |                       | swift.auth.auth_token                                                  |
   +-----------------------+------------------------------------------------------------------------+

Heat stack owner
----------------

The *Heat Stack Owner* role allows users access to the Heat Cloud Orchestration
Service. Users who attempt to use Heat when they do not have this role will
receive an error stating they are missing the required role. This role is
required for interacting with the Cloud Orchestration Service, regardless of
other roles.

For more information on this service, please consult the documentation at
:ref:`Cloud orchestration. <cloud-orchestration>`

The list of explicit permissions for the Heat stack owner role:

.. code-block:: console

   +-----------------------+------------------------------------------------------------------------+
   | Heat Stack Owner      | openstack.orchestration.actions:action                                 |
   |                       | openstack.orchestration.build_info:build_info                          |
   |                       | openstack.orchestration.cloudformation:ListStacks                      |
   |                       | openstack.orchestration.cloudformation:CreateStack                     |
   |                       | openstack.orchestration.cloudformation:DescribeStacks                  |
   |                       | openstack.orchestration.cloudformation:DeleteStack                     |
   |                       | openstack.orchestration.cloudformation:UpdateStack                     |
   |                       | openstack.orchestration.cloudformation:CancelUpdateStack               |
   |                       | openstack.orchestration.cloudformation:DescribeStackEvents             |
   |                       | openstack.orchestration.cloudformation:ValidateTemplate                |
   |                       | openstack.orchestration.cloudformation:GetTemplate                     |
   |                       | openstack.orchestration.cloudformation:EstimateTemplateCost            |
   |                       | openstack.orchestration.cloudformation:DescribeStackResources          |
   |                       | openstack.orchestration.events:index                                   |
   |                       | openstack.orchestration.events:show                                    |
   |                       | openstack.orchestration.resource:index                                 |
   |                       | openstack.orchestration.resource:mark_unhealthy                        |
   |                       | openstack.orchestration.resource:show                                  |
   |                       | openstack.orchestration.software_configs:index                         |
   |                       | openstack.orchestration.software_configs:create                        |
   |                       | openstack.orchestration.software_configs:show                          |
   |                       | openstack.orchestration.software_configs:delete                        |
   |                       | openstack.orchestration.software_development:index                     |
   |                       | openstack.orchestration.software_development:create                    |
   |                       | openstack.orchestration.software_development:show                      |
   |                       | openstack.orchestration.software_development:update                    |
   |                       | openstack.orchestration.software_development:delete                    |
   |                       | openstack.orchestration.stacks:abandon                                 |
   |                       | openstack.orchestration.stacks:create                                  |
   |                       | openstack.orchestration.stacks:delete                                  |
   |                       | openstack.orchestration.stacks:details                                 |
   |                       | openstack.orchestration.stacks:export                                  |
   |                       | openstack.orchestration.stacks:generate_template                       |
   |                       | openstack.orchestration.stacks:index                                   |
   |                       | openstack.orchestration.stacks:list_resource_types                     |
   |                       | openstack.orchestration.stacks:list_template_versions                  |
   |                       | openstack.orchestration.stacks:list_template_functions                 |
   |                       | openstack.orchestration.stacks:preview                                 |
   |                       | openstack.orchestration.stacks:resource_scheme                         |
   |                       | openstack.orchestration.stacks:show                                    |
   |                       | openstack.orchestration.stacks:template                                |
   |                       | openstack.orchestration.stacks:environment                             |
   |                       | openstack.orchestration.stacks:files                                   |
   |                       | openstack.orchestration.stacks:update                                  |
   |                       | openstack.orchestration.stacks:update_patch                            |
   |                       | openstack.orchestration.stacks:preview_update                          |
   |                       | openstack.orchestration.stacks:preview_update_patch                    |
   |                       | openstack.orchestration.stacks:validate_template                       |
   |                       | openstack.orchestration.stacks:snapshot                                |
   |                       | openstack.orchestration.stacks:show_snapshot                           |
   |                       | openstack.orchestration.stacks:delete_snapshot                         |
   |                       | openstack.orchestration.stacks:list_snapshots                          |
   |                       | openstack.orchestration.stacks:restore_snapshot                        |
   |                       | openstack.orchestration.stacks:List_outputs                            |
   |                       | openstack.orchestration.stacks:show_output                             |
   +-----------------------+------------------------------------------------------------------------+

Compute start/stop
------------------

The *Compute Start/Stop* role allows users to start, stop, hard reboot and soft
reboot compute instances. In addition, this role now also supports shelving
and un-shelving an instance. This is useful because.

- Shelved instances are not billed for compute resources.
- Storage resources are still billed since they are still being stored on
  a server.
- "stopped" instances are still billed as if they were running because they are
  still scheduled to a hypervisor host.

However this role still cannot sleep/suspend an instance. Other than these
actions it is equivalent to auth_only.

This role is implied when a user also has *Project Member*.

The list of explicit permissions for the compute start/stop role:

.. code-block:: console

   +-----------------------+------------------------------------------------------------------------+
   | Compute Start/Stop    | openstack.compute.start                                                |
   |                       | openstack.compute.stop                                                 |
   |                       | openstack.compute.shelve                                               |
   |                       | openstack.compute.unshelve                                             |
   +-----------------------+------------------------------------------------------------------------+

Object storage
--------------

The *Object Storage* role allows users to create, update and delete containers,
and objects within those containers. Creative and destructive actions related
to compute, network and block storage will fail. This role is implied when a
user also has *Project Member*.

The list of explicit permissions for the object storage role:

.. code-block:: console

   +-----------------------+------------------------------------------------------------------------+
   | Object Storage        | swift.delete.container                                                 |
   |                       | swift.delete.object                                                    |
   |                       | swift.download.container                                               |
   |                       | swift.download.object                                                  |
   |                       | swift.list.container                                                   |
   |                       | swift.post.container                                                   |
   |                       | swift.post.object                                                      |
   |                       | swift.post.account                                                     |
   |                       | swift.copy.container                                                   |
   |                       | swift.copy.object                                                      |
   |                       | swift.stat.container                                                   |
   |                       | swift.stat.object                                                      |
   |                       | swift.upload.file                                                      |
   |                       | swift.upload.folder                                                    |
   |                       | swift.capabilities.proxy_url                                           |
   |                       | swift.tempurl.container                                                |
   |                       | swift.tempurl.object                                                   |
   |                       | swift.auth.storage_url                                                 |
   |                       | swift.auth.auth_token                                                  |
   +-----------------------+------------------------------------------------------------------------+

Auth only
---------

The *Auth Only* role is the most restrictive role. Users are only able to
manage their own account information. This role cannot view, create or destroy
project resources and it does not permit the uploading of SSH keys or the
viewing of project usage and quota information.

The list of explicit permissions for the auth only role:

.. code-block:: console

   +-----------------------+------------------------------------------------------------------------+
   | Authentication Only   | openstack.keypair.create                                               |
   |                       | openstack.quota.show                                                   |
   +-----------------------+------------------------------------------------------------------------+

Kubernetes specific roles
=========================

There are certain roles that are used for kubernetes actions only and are
required to perform specific actions on kubernetes clusters. They can be
found in the :ref:`kubernetes <kubernetes-user-access>` section of the
documentation.


Adding a new user
=================
To add a new user click on "Invite User", add the email of the user that you
wish to invite and select the 'Roles' that you wish to assign to them, then
click "Invite".

|

.. image:: ../_static/invite_user.png

|

Once a new project member has been invited the "Invited Users" count will
increase.

.. image:: ../_static/invited_count.png

|

Once the user clicks on the link in the invitation email the "Invited Users"
count will decrease by 1 and the user will appear in the Project Users panel.

Updating a user
===============
Selecting the "Update User" action from the main "Project Users" screen will
load the same panel as the one presented when inviting a new user. It is then
possible to modify the current roles assigned to the user.


Revoking user access
====================
To remove access to a project you can select 'Revoke User' from the Actions
drop down on an individual user

|

.. image:: ../_static/revoke_user.png

or select multiple users using the check boxes on the Project Users list and
then click "Revoke Users" on the upper right of the page.

|

.. image:: ../_static/revoke_multiple_users.png
