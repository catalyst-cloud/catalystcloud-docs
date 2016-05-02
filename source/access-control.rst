.. _access-control:

##############
Access Control
##############

********
Overview
********

The Catalyst Cloud allows you to invite more people to join your project and
define the actions they can perform using roles.

*****
Roles
*****

Compute Start/Stop
------------------
The "Compute Start/Stop" role allows users to start, stop, hard reboot and soft
reboot compute instances. Other, more destructive or creative actions will fail.
This role is implied when a user also has "Project Member".

Heat Stack Owner
----------------
The “Heat Stack Owner” role allows users access to the Heat Cloud Orchestration
Service. Users who attempt to use heat when they do not have this role will
receive an error stating they are missing the required role. This role is
required for interacting with the Cloud Orchestration Service regardless of
other roles.

For more information on this service please consult the documentation at
:ref:`cloud-orchestration`.

Object Storage
------------------
The "Object Storage" role allows users to create, update and delete containers,
and objects within those containers. Creative and destructive actions related
to compute, network and block storage will fail. This role is implied when a user
also has "Project Member".

Project Admin
-------------
The “Project Admin” role allows users to have full control over your project,
including adding moderators and inviting other people to join it.  The role
remains largely administrative until a role such as "Project Member" is also
assigned.

Project Member
--------------
The “Project Member” role gives people access to all services on your project,
but does not allow them to invite other people to join the project or update
roles.

Project Moderator
-----------------
The “Project Moderator” role can invite other people to join your project and
update their roles, but cannot change the project admin.  The role is essentially
an administrative one until a role such as "Project Member" is also assigned.

*************
Project Users
*************

``Dashboard → Management → Project Users``

.. note::

 The Project Users page is only accessible to users with the “Project Admin” or “Project Moderator” role.

The project users page allows project admins and moderators to perform
administrative functions. Users can be added, revoked or updated from here.
