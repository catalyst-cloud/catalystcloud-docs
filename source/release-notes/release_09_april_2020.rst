############
9 April 2020
############

The main changes of note in this release are:

* the upgrade of the Orchestration Service (Heat) from stable/Queen to
  stable/Train.
* Various web dashboard additions and improvements.


****************************
Orchestration Service (Heat)
****************************

For a full list of the included changes please see upstream release
notes for `stable/Stein`_ and `stable/Train`_

.. _`stable/Stein`: https://docs.openstack.org/releasenotes/heat/stein.html
.. _`stable/Train`: https://docs.openstack.org/releasenotes/heat/train.html

New Features
============

Some of the key new features included in this release are:

* Upgrade Heat template version from ``heat_template_version.2018-03-02`` to
  ``heat_template_version.2018-08-31``
* Added a new config option server_keystone_endpoint_type to specify the
  keystone authentication endpoint (public/internal/admin) to pass into
  cloud-init data
* Add rbac_policy and subnetpool support for OS::Neutron::Quota resource
* Add UDP to supported protocols for Octavia.
* Add tags support for ProviderNet resource
* OS::Aodh::LBMemberHealthAlarm resource plugin is added to manage Aodh
  loadbalancer_member_health alarm.
* Support tags property for the resource OS::Octavia::PoolMember, the property
  is allowed to be updated as well.

Bug Fixes
=========

Some of the key areas addressed are:

* Erroneously, availability_zone for host aggregate resource types was
  considered mandatory in heat templates. It is now optional.
* Heat can now perform a stack update to roll back to a previous version of a
  resource after a previous attempt to create a replacement for it failed.
* Empty string passing in for volume availability_zone can be correctly handled
  now. For this case, it’s same as no AZ set, so the default AZ in cinder.conf
  will be used.
* Non-ASCII text that appears in parameter constraints (e.g. in the description
  of a constraint, or a list of allowed values) will now be handled correctly
  when generating error messages if the constraint is not met.
* OS::Neutron::Port resources will now be replaced when the mac_address
  property is modified. Neutron is unable to update the MAC address of a port
  once the port is in use.

Deprecations
============

* **personality** property of OS::Nova::Server is now deprecated, please use
  user_data or metadata instead.

*************
Web dashboard
*************

In this latest version the following improvements have been included:

- Improved dashboard experience for the Container Infra (Kubernetes) service.
- Support for creating object storage containers with a single region storage
  policy.
