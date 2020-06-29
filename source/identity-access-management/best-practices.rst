<<<<<<< HEAD
*************************
Best Practices for Access
*************************
=======
.. _iam-best-practices:

************************
Best Practices for roles
************************
>>>>>>> 3b55f7a892d653b7a06809f8293138fdd585e741

Project admin
=============
<<<<<<< HEAD
After creating a project and adding users to it,
the best practice is that you create an user account with moderation
privileges distinct from your admin account. Separating your working account
from the administrative account ensures that making changes to the structure of
your project, must be a deliberate decision. Where you have to actively log
into your admin account with MFA active on it so ensure even more security.
=======
It is recommended by Catalyst that you keep an admin account and a user
account with moderation privileges. Separating your working account from the
administrative account ensures that making changes to the structure of your
project or major changes, must be a deliberate decision done on the
administrative account; not something just done half handedly on your normal
account.
>>>>>>> 3b55f7a892d653b7a06809f8293138fdd585e741

To tie in with this; when you
create your admin account or have an account with differing privileges, it is
recommended you create the account with the
syntax: **youremail+accountprivileges@...** For example an admin account would
look like: **youremail+admin@...** This ensures a clear distinction between
which account is which but it also allows your to receive mail for both account
at a single email address.

Start/Stop instance
===================
<<<<<<< HEAD
The most common use for the start/stop instance role is for start up or
shut down of instances via automated scripts tied to an account.
This role is recommended over say the `member` role for
security reasons. If the automated user's account information was ever
compromised or the automation changed in some way to try and make changes to
the project outside start/stop commands, they would all fail because this role
only allows the user to start or stop instances, not delete or change data.
=======
The most common use for the start/stop instance role is for automated start up
or shut down. You are able to add an automated user to the project that will
only be able to perform start and stop commands on the system. This role
is recommended over say the `member` role for security reasons. If the
automated user's account information was ever compromised or the automation
changed in some way to try and make changes to the project outside start/stop
commands, they would all fail.
>>>>>>> 3b55f7a892d653b7a06809f8293138fdd585e741


Auth only
=========
In order to ensure that the security of your project remains intact, we
created the *auth only* role. This allows you to add users to your project,
without giving them the ability to change or even see its contents. This role's
main purpose is for a user to be able to connect to your project but first
change their password or enable MFA before an moderator gives them a more
powerful role.

Another practice of the *auth only* role is to partially expose
containers or files from object storage to a user, without providing them
a more powerful role. With restricted object storage access the user can be
given read or write privileges for a specific container (or all) but still have
no access to the rest of the project. For a more
thorough guide on this please see :ref:`object-storage-access`.
