.. _iam-best-practices:

########################
Best Practices for roles
########################

*************
Project admin
*************

It is recommended by Catalyst that you keep an admin account and a user
account with moderation privileges. Separating your working account from the
administrative account ensures that making changes to the structure of your
project or major changes, must be a deliberate decision done on the
administrative account; not something just done half handedly on your normal
account.

To tie in with this; when you
create your admin account or have an account with differing privileges, it is
recommended you create the account with the
syntax: **youremail+accountprivileges@...** For example an admin account would
look like: **youremail+admin@...** This ensures a clear distinction between
which account is which but it also allows your to receive mail for both account
at a single email address.

*******************
Start/Stop instance
*******************

The most common use for the start/stop instance role is for automated start up
or shut down. You are able to add an automated user to the project that will
only be able to perform start and stop commands on the system. This role
is recommended over say the `member` role for security reasons. If the
automated user's account information was ever compromised or the automation
changed in some way to try and make changes to the project outside start/stop
commands, they would all fail.

*********
Auth only
*********

This allows you to add users to your project,
without giving them the ability to change or even see its contents. This role's
main purpose is for a user to be able to connect to your project then
change their password and enable MFA. Then a moderator can give the user a more
powerful role. This helps to ensure a higher level of security for your
project.

Another practice of the *auth only* role is to partially expose
containers or files from object storage to a user, without providing them
access to the rest of your project. With restricted object storage access the
user can be given read or write privileges for a specific container
(or all containers) but still have no access to the rest of the project. For a
more thorough guide on this please see :ref:`object-storage-access`.
