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

Heat Stack Owner
----------------
The “Heat Stack Owner” role allows users access to the Heat Cloud Orchestration
Service. Users who attempt to use heat when they do not have this role will
receive an error stating they are missing the required role. This role is
required for interacting with the Cloud Orchestration Service regardless of
other roles.

For more information on this service please consult the documentation at
:ref:`cloud-orchestration`.

Project Admin
-------------
The “Project Admin” role allows users to have full control over your project,
including adding moderators and inviting other people to join it.

Project Member
--------------
The “Project Member” role gives people access to all services on your project,
but does not allow them to invite other people to join the project or update
roles.

Project Moderator
-----------------
The “Project Moderator” role can invite other people to join your project and
update their roles, but cannot change the project admin.

*************
Project Users
*************

``Dashboard → Management → Project Users``

.. note::

 The Project Users page is only accessible to users with the “Project Admin” or “Project Moderator” role.

The project users page allows project admins and moderators to perform
administrative functions. Users can be added, revoked or updated from here.
