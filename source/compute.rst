###############
Compute service
###############


***************
Security groups
***************

A security group is a virtual firewall that controls network traffic to and
from compute instances. Your tenant comes with a default security group, which
cannot be deleted, and you can create additional security groups.

Security groups are made of security rules. You can add or modify security
rules at any time. When you modify a security group, the new rules are
automatically applied to all compute instances associated with it.

You can associate one or more security groups to your compute instances.

.. note::

  While it is possible to assign many security groups to a compute instance, we
  recommend you to consolidate your security groups and rules as much as
  possible.

Creating a security group
=========================

From the dashboard
------------------

From the command line clients
-----------------------------

