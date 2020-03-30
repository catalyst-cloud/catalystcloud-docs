##############
24 March 2020
##############

The main change of note in this release is the upgrade of the Loadbalancer
Service (Octavia) from stable/Stein to stable/Train.


***********************
Load Balancer (Octavia)
***********************

For a full list of the included changes please see upstream `release
notes`_

.. _`release notes`: https://docs.openstack.org/releasenotes/octavia/train.html

New Features
============

One if the key new features included in this release is:

* Support to VIP access control list. Users can now limit incoming traffic to
  a set of allowed CIDRs.

Bug Fixes
=========

Some of the key areas addressed are:

* Fixed a bug which prevented the creation of listeners for different protocols
  on the same port (i.e: tcp port 53, and udp port 53).
* Fixed an issue where the listener API would accept null/None values for
  fields that must have a valid value.
* Addressed several issues relating to the use of UDP protocols.

Known Issues
============

* When a load balancer with a UDP listener is updated, the listener service is
  restarted, which causes an interruption of the flow of traffic during a short
  period of time. This issue is caused by a keepalived bug

Deprecations
============

* Octavia v1 API deprecation is complete. All relevant code, tests, and docs
  have been removed.
