************************
Best Practices for Roles
************************


Project Admin
=============
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

Start/Stop Instance
===================
The most common use for the start/stop instance role is for automated start up
or shut down. You are able to add an automated user to the project that will
only be able to perform start and stop commands on the system. This role
is recommended over say the `member` role for security reasons. If the
automated user's account information was ever compromised or the automation
changed in some way to try and make changes to the project outside start/stop
commands, they would all fail.


Auth Only
=========
The auth only role is a restrictive role and has a number of use cases.
The most common would be when adding a new user to a
sensitive project and requiring them to change their password and setting up
MFA before giving them a more powerful role. The second would be when there is
a need to create users with restricted object storage access. For more
information on this please see :ref:`object-storage-access`.
