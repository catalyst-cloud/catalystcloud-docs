##########
Kubernetes
##########

Catalyst Kubernetes Service makes it easy for you to deploy, manage, and scale
Kubernetes clusters to run containerised applications on the Catalyst Cloud.

.. warning::

  This service is in Technical Preview (ALPHA) and is not recommended for
  production workloads yet.

Table of Contents:

.. toctree::
  :maxdepth: 1

  kubernetes/quickstart
  kubernetes/introduction
  kubernetes/clusters
  kubernetes/storage
  kubernetes/access
  kubernetes/network_policies


.. note::

  If working from the commandline with the OpenStack tools please ensure that
  the version of the python-magnumclient is 2.12.0 or above.

******************
Providing feedback
******************

Our goal with this alpha release is to establish a feedback loop and collaborate
with early adopters of the technology, to ensure it meets the unique needs of
our customers in NZ.

At this stage, the service is expected to have some rough edges and bugs. If you
encounter an issue or have a suggestion on how we can improve it, please raise
a ticket via the `Support Centre`_.

.. _`Support Centre`: https://catalystcloud.nz/support/support-centre/

Where possible, when creating support tickets, please include the output of the
following command to assist our support team in helping you to resolve it.

.. code-block:: bash

  $ openstack coe cluster show <cluster_name>

************
Known Issues
************

This is an overview of the issues encountered in the process of testing this
Technical Preview release.


Cluster takes a long time to deploy
===================================

Description
-----------

Currently the time taken to deploy a cluster from commandline or dashboard is
in the vicinity of 15-25 minutes.

Status
------

The cause of the problem is known and a fix is being investigated.

Workaround
----------

None.
