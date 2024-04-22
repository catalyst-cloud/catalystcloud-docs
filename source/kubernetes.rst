.. _kubernetes:

##########
Kubernetes
##########

Catalyst Cloud Kubernetes Service makes it easy for you to deploy, manage, and scale
Kubernetes clusters to run containerised applications on Catalyst Cloud.

Table of Contents:

.. toctree::
   :maxdepth: 1

   kubernetes/quickstart
   kubernetes/clusters
   kubernetes/user-access
   kubernetes/load-balancers
   kubernetes/ingress
   kubernetes/auto-scaling
   kubernetes/cluster-upgrade
   kubernetes/storage
   kubernetes/versions
   kubernetes/appendix
   kubernetes/glossary

.. TODO(callumdickinson): Add 'kubernetes/auto-scaling' below Production Consiterations.

******************
Providing Feedback
******************

We are keen to establish a feedback loop and collaborate with customers using
Kubernetes, to ensure it meets the unique needs in NZ. If you encounter an
issue or have a suggestion on how we can improve it, please raise a ticket via
the `Support Centre`_.

.. _`Support Centre`: https://catalystcloud.nz/support/support-centre/

Where possible, when creating support tickets, please include the output of the
following command to assist our support team in helping you to resolve it.

.. code-block:: bash

  $ openstack coe cluster show -f json <cluster_name>
