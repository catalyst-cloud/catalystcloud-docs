:orphan:

***************************************
Interacting with the Kubernetes service
***************************************

There are two main APIs to interact with Catalyst Cloud Kubernetes Service,
creating clusters using the Magnum  supports when interact with
the Kubernetes service. There is the Kubernetes CLI and the Container infra
section on the  Catalyst Cloud dashboard. In this section of the documentation
we will cover the command line methods in greater depth. To know more about
the dashboard approach, please see the :ref:`k8s-quickstart` section of the
documents.

Getting kubectl
===============

To deploy and manage applications on kubernetes through the command line,
we use the Kubernetes command-line tool, `kubectl`_. With this tool you can
inspect cluster resources; create, delete, and update components; and look at
your new cluster and bring up example apps. It's basically the Kubernertes
Swiss army knife.

The details for getting the latest version of kubectl can be found `here`_.

.. _`kubectl`: https://kubernetes.io/docs/reference/kubectl/kubectl/
.. _`here`: https://kubernetes.io/docs/tasks/tools/#kubectl

To install these tools on Linux via the command line as a simple binary,
perform the following steps:

.. code-block:: bash

  $ curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s \
  https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

  $ chmod +x ./kubectl
  $ sudo mv ./kubectl /usr/local/bin/kubectl


The basic format of a kubectl command looks like this:

.. code-block:: bash

  kubectl [command] [TYPE] [NAME] [flags]

where command, TYPE, NAME, and flags are:

- ``command``: the operation to perform
- ``TYPE``: the resource type to act on
- ``NAME``: the name of the resource in question
- ``flags``: optional flags to provide extra


Cluster access using kubeconfig files
=====================================

The kubectl command-line tool uses kubeconfig files to find the information it
needs to choose a cluster and communicate with the API server of a cluster.
These files provide information about clusters, users, namespaces, and
authentication mechanisms.

Getting the cluster config
==========================

We use our cluster config to configure our native command line to communicate
with our cluster. To do so we have to source the config file of our
cluster using the following command.

For example: ``eval $(openstack coe cluster config <cluster-name>)``

.. code-block:: bash

  $ eval $(openstack coe cluster config k8s-cluster)

This will download the necessary certificates and create a config file within
the directory that you are running the command from. If you wish to save the
configuration to a different location you can use the
``--dir <directory_name>`` parameter to select a different destination.

.. Note::

  If you are running multiple clusters or are deleting and re-creating cluster it is necessary to
  ensure that the current ``kubectl configuration`` is referencing the right cluster. The
  following section will outline this in more detail.

Production consideration for config files
=========================================

Because the initial config file that you create contains all the certifications
for your cluster, it is recommended that for production clusters you safely
store this config file away and then create another config file that you
can share between your staff. This new file allows people access to the cluster
by authenticating with their OpenRC credentials. To create this new file,
you can use the following:

.. code-block:: bash

  $ eval $(openstack coe cluster config k8s-cluster --use-keystone)

Viewing the cluster
===================

It is possible to view details of the cluster with the following command. This
will return the address of the master and the services running there.

.. code-block:: bash

  $ kubectl cluster-info
  Kubernetes master is running at https://103.254.156.157:6443
  Heapster is running at https://103.254.156.157:6443/api/v1/namespaces/kube-system/services/heapster/proxy
  CoreDNS is running at https://103.254.156.157:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

In order to view more in depth information about the cluster simply add the
dump option to the above example. This generates output suitable for debugging
and diagnosing cluster problems. By default, it redirects everything to stdout.

.. code-block:: bash

  $ kubectl cluster-info dump
