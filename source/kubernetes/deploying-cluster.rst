  Private vs Public cluster API access
====================================

Any cluster created using one of the predefined templates will, by default, be
created as a ``private cluster``. This means that the Kubernetes API will
**not** be accessible from the internet and access will need to be via a
bastion or jumphost server within the cloud project.

If you would prefer to create a ``publicly accessible cluster`` then simply
add the following option to the cluster creation command.

.. code-block:: bash

  --floating-ip-enabled

The actual usage would look like this.

.. code-block:: console

  $ openstack coe cluster create <Cluster name> \
    --cluster-template <Template ID> \
    --floating-ip-enabled

.. Note::

  This quickstart guide covers the steps to creating a kubernetes cluster
  from scratch. But if you wish to create a cluster on an existing
  private network then you can refer to the relevant section in
  :ref:`the private-cluster <cluster-on-existing-net>` documentation.


Creating a cluster
==================

To create a new **development** cluster run the following command:

.. code-block:: bash

  $ openstack coe cluster create k8s-cluster \
  --cluster-template kubernetes-v1.14.10-dev-20200422 \
  --keypair my-ssh-key \
  --node-count 3 \
  --master-count 1

  Request to create cluster c191470e-7540-43fe-af32-ad5bf84940d7 accepted

.. _modifying_a_cluster_with_labels:


Checking the status of the cluster
==================================

Since we are using the development template, the cluster will take 10 to 15
minutes be created.

You can use the following command to check the status of the cluster:

.. code-block:: bash

  $ openstack coe cluster list
  +--------------------------------------+-------------+----------+------------+--------------+--------------------+
  | uuid                                 | name        | keypair  | node_count | master_count | status             |
  +--------------------------------------+-------------+----------+------------+--------------+--------------------+
  | c191470e-7540-43fe-af32-ad5bf84940d7 | k8s-cluster | testkey  |          1 |            1 | CREATE_IN_PROGRESS |
  +--------------------------------------+-------------+----------+------------+--------------+--------------------+

Alternatively, you can check the status of the cluster on the `Clusters panel`_
, in the ``Container Infra`` section of the Dashboard.

.. _`Clusters panel`: https://dashboard.cloud.catalyst.net.nz/project/clusters

Please wait until the status changes to ``CREATE_COMPLETE`` to proceed.

Getting the cluster config
==========================

The kubectl command-line tool uses kubeconfig files to determine how to connect
to the APIs of the Kubernetes cluster. The following command will download the
necessary certificates and create a configuration file on your current
directory. It will also export the ``KUBECONFIG`` variable on your behalf:

.. code-block:: bash

  $ eval $(openstack coe cluster config k8s-cluster)

If you wish to save the configuration to a different location you can use the
``--dir <directory_name>`` parameter to select a different destination.

.. Note::

  If you are running multiple clusters, or are deleting and re-creating a
  cluster, it is necessary to ensure that the current ``kubectl configuration``
  is referencing the correct cluster configuration.
