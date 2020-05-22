##########
Kubernetes
##########

Catalyst Kubernetes Service makes it easy for you to deploy, manage, and scale
Kubernetes clusters to run containerised applications on the Catalyst Cloud.

Table of Contents:

.. toctree::
   :maxdepth: 1

   kubernetes/quickstart
   kubernetes/overview
   kubernetes/clusters
   kubernetes/access-control
   kubernetes/auto-healing
   kubernetes/auto-scaling
   kubernetes/ingress
   kubernetes/network-policies
   kubernetes/private-cluster
   kubernetes/logging
   kubernetes/rolling-upgrade
   kubernetes/services
   kubernetes/storage


******************
Providing feedback
******************

We are keen to establish a feedback loop and collaborate with customers using
Kubernetes, to ensure it meets the unique needs in NZ. If you encounter an
issue or have a suggestion on how we can improve it, please raise a ticket via
the `Support Centre`_.

.. _`Support Centre`: https://catalystcloud.nz/support/support-centre/

Where possible, when creating support tickets, please include the output of the
following command to assist our support team in helping you to resolve it.

.. code-block:: bash

  $ openstack coe cluster show <cluster_name>

************
Known Issues
************

**Cluster takes 15-25 minutes to deploy**


* **Description:** Time to deploy a cluster is in the vicinity of 15-25
  minutes.
* **Status:** The cause of the problem is known and a release that reduces
  deployment times is being planned.
* **Workaround:** None.
