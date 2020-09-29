.. _identity-access-management:

##############################
Identity and access management
##############################


Also known as IAM, it is a set of rules and protocols that govern an individual
account's level of access to different resources on your project. This is
important for security purposes as you do not want all users on on your
project having unilateral control over all the resources on your system.
IAM is also important for accountability reasons, as you can track closely
which users have access to which resources and when they accessed them. The
Catalyst Cloud makes use of *Roles* to define and restrict what access should
be given to which users. The practices mentioned in the following sections
will discuss in detail what the different roles are and how you are able to
manage them as an administrative user.

In addition to the information surrounding roles, this section also covers
Multi-factor-authentication. We highly recommend setting up MFA for
any user on your project, but especially on accounts which have the
'project-administrator' role.


.. toctree::
   :maxdepth: 1

   identity-access-management/roles
   identity-access-management/multi-factor-authentication
   identity-access-management/best-practices
   identity-access-management/additional-permissions
