###############
Security groups
###############

A security group is a virtual firewall that controls network traffic to and
from compute instances. Your project comes with a default security group, which
cannot be deleted, and you can create additional security groups.

Security groups are made of security rules. You can add or modify security
rules at any time. When you modify a security group, the new rules are
automatically applied to all compute instances associated with it.

You can associate one or more security groups with your compute instances.

.. note::

  While it is possible to assign many security groups to a compute instance, we
  recommend you consolidate your security groups and rules as much as
  possible.

*************************
Creating a security group
*************************

The default behaviour of security groups is to deny all traffic. Rules added to
security groups are all "allow" rules.

.. note::

  Failing to set up the appropriate security group rules is a common mistake
  that prevents users from reaching their compute instances, or compute
  instances from communicating with each other.
