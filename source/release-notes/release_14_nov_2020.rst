#################
14 November 2020
#################

The main changes of note in this release are:

* Loadbalancer as a Service (Octavia) has been upgraded from version Train to
  Ussuri.
* Container Infra service (Magnum) has several fixes and features added in
  this release.

***********************************
Loadbalancer as a Service (Octavia)
***********************************

For the full details of the included changes please see upstream release notes
for `stable/Ussuri`_

.. _`stable/Ussuri`: https://docs.openstack.org/releasenotes/octavia/ussuri.html

Key Features
============

* TBC by Lingxian after it is in Prod


************************
Container Infra (Magnum)
************************

Bug Fixes
=========

The main key area addressed is:

* Fix to provide support for Kubernetes v1.19.x. This will include the
  addition of new templates:

TODO: get template names

  * kubernetes-v1.19.8-dev-2020
  * kubernetes-v1.19.8-prod-2020

TODO: confirm deprecation

  As well as the deprecation of the following templates:

  * kubernetes-v1.16.14-dev-20200827
  * kubernetes-v1.16.14-prod-20200827

New Features
============

* Add placeholder for Kubernetes keystone auth role-mapping sync
* Add support for the ability to **master_lb_enabled** when creating a new
  cluster

for #3, it's a new parameter, just like the floating_ip_enabled, when user
create a new cluster, they can choose if enable the master lb, use need to
upgrade python-magnumclient to 3.2.1

* Add support to allow rotation of the Certificate Authority (CA) certs via
  the API.
