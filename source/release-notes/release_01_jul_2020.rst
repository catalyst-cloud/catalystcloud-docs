###########
1 July 2020
###########

The main changes of note in this release are:

* The Kubernetes Service (Magnum) designation has been changed from **Beta** to
  that of General Availability (GA) and as such it is considered to be suitable
  for use with production workloads.



***************************
Kubernetes service (Magnum)
***************************

For a full list of the Kubernetes version changes please see upstream release
notes for `1.18.2`_

.. _`1.18.2`: https://kubernetes.io/docs/setup/release/notes/

New Features
============

* The Kubernetes version has been updated to v1.18.2.
* Two new templates were added to provide support for Kubernetes v1.18.2, these
  are:

  - kubernetes-v1.18.2-dev-20200630
  - kubernetes-v1.18.2-prod-20200630

* Support of the templates for Kubernetes v1.15.11 will be deprecated.
* Added support for the sha256 digest check for k8s hyperkube image.
* The behaviour of the Kubernetes **development templates** has changed to make
  all new clusters created with them **publicly accessible over the internet**
  by default.
* Added support to allow for cluster labels to be over-ridden at creation time
  by means of merging changes rather than having to provide the entire label
  list.
* Enable visibility of the cluster health status for private clusters.
* Provide a means to limit access to the Kubernetes API through the use of the
  the ``master_lb_allowed_cidrs`` label.

