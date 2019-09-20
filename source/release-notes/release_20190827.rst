##############
27 August 2019
##############

The main focus for this release was around our Kubernetes service. With this
release the Catalyst Cloud Kubernetes service has been promoted to a ``Beta``
status.

This release introduced the following new functionality and improvements.

* It is now possible to perform a :ref:`rolling-upgrade` of the Kubernetes
  version of a running cluster with minimum to no impact on running
  applications.
* Cluster :ref:`auto-healing` is a feature of the Kubernetes service that
  monitors the health state of the cluster and automatically repairs
  Kubernetes’ components or nodes.
* Cluster :ref:`auto-scaling` allows a cluster to dynamically increase or
  reduce the number of worker nodes, according their current resource
  allocation
* As a security best practice, Kubernetes clusters are now created in a private
  network and are not visible from the Internet by default. If desirable,
  exposing the Kubernetes API to the internet is a simple additional step
  documented on the :ref:`private-cluster` section of the documentation.
* Cluster :ref:`kubernetes-access-control` roles were added to provide a
  mechanism for handling cluster authentication and authorization based on the
  cloud user's login and associated roles.
* The following new cluster template versions were introduced. The
  **v.1.xx.xx** tag in the template name refers to the associated Kubernetes
  version that will be deployed in the cluster by the template.

  - kubernetes-v1.12.10-dev-20190912
  - kubernetes-v1.12.10-prod-20190912
  - kubernetes-v1.13.10-dev-20190912
  - kubernetes-v1.13.10-prod-20190912

