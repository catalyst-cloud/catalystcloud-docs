#################
30 November 2020
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


************************
Container Infra (Magnum)
************************

Magnum received a minor version bump to address the following:

Bug Fixes
=========

The main key area addressed is:

* Fix to provide support for Kubernetes v1.19.x. This will include the
  addition of new templates:

  * kubernetes-v1.19.4-dev-2020
  * kubernetes-v1.19.4-prod-2020

* The following templates have also been released to bump the related
  Kubernetes version they support.

  * kubernetes-v1.17.14-dev-20201124
  * kubernetes-v1.17.14-prod-20201124
  * kubernetes-v1.18.12-dev-20201124
  * kubernetes-v1.18.12-prod-20201124

* The following templates have been deprecated:

  * kubernetes-v1.16.14-dev-20200827
  * kubernetes-v1.16.14-prod-20200827

New Features
============

* Add support for the ability to enable a load balancer on the master node when
  creating a new cluster, using the  **master_lb_enabled**  parameter.

.. Note:: This will require upgrading your CLI tools to use
          **python-magnumclient to 3.2.1**

* Add support to allow rotation of the cluster's Certificate Authority (CA)
  certs via the API.
