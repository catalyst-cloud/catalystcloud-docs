.. _access_control:

**************
Access control
**************

.. _project_users:

Project Users
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
amended once a user has accepted your invitation to the
project.

The roles are additive meaning that you can hold a lesser role like 'auth_only'
that is supposed to restrict permissions and a role like 'member' that *allows*
those same restricted permissions. The one that allows them supersedes the
other.

The roles available are split up between General roles, that control your
ability to make changes to the project as a whole. And Kubernetes roles which
are as the name suggests all to do with Kubernetes and the control of clusters.
Information on the Kubernetes roles can be found
:ref:`here <kubernetes-user-access>`

General Roles:
==============

Project Admin
-------------

The *Project Admin* role allows users to have full control over who has access
to the project, including adding moderators and inviting other people to join
it. However, this role is purely for administrating purposes. It does not
allow you to access or view all resources, you still need the member role for
that.

Project Moderator
-----------------

The *Project Moderator* role can invite other people to join your project and
update their roles, but cannot change the project admin. Has the same problem
as the Admin role in regards to resource access.

Project Member
--------------

The *Project Member* role gives users access to all services on your project.
The role does not however allow them to invite other people to join the project
nor can a *Project Member* update roles. This role encompasses a number of
others in terms of the privileges that it allows. As
mentioned earlier, because our roles are additive you do not need all of them
to have full control over the project.

Heat Stack Owner
----------------

The *Heat Stack Owner* role allows users access to the Heat Cloud Orchestration
Service. Users who attempt to use Heat when they do not have this role will
receive an error stating they are missing the required role. This role is
required for interacting with the Cloud Orchestration Service, regardless of
other roles.

For more information on this service, please consult the documentation at
:ref:`Cloud orchestration. <cloud-orchestration>`

Compute Start/Stop
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


Object Storage
--------------

The *Object Storage* role allows users to create, update and delete containers,
and objects within those containers. Creative and destructive actions related
to compute, network and block storage will fail. This role is implied when a
user also has *Project Member*.


Auth only
---------

The *Auth Only* role is the most restrictive role. Users are only able to
manage their own account information. This role cannot view, create or destroy
project resources and it does not permit the uploading of SSH keys or the
viewing of project usage and quota information.

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
