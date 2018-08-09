########
Clusters
########

What is a cluster?
==================
A container cluster is the foundation of the Kubernetes Engine: it is the set
of Kubernetes objects that are required to run your containerized applications.

A cluster requires at least one **master** server and one or more **node**
servers. It makes use of a shared network to communicate between them.

The master server is the primary point of contact within the cluster and it is
responsible for providing the centralised scheduling, logic and management of
all aspects of the cluster.

The machines designated as nodes are responsible for accepting and running
workloads assigned by the master using appropriate local and external
resources.


The Cluster Template
====================
A cluster template is a collection of parameters to describe how a cluster can
be constructed. Some parameters are relevant to the infrastructure of the
cluster, while others are for the particular COE.

The cloud provider may supply pre-defined templates for users and it may also be possible, in some
situations, for user to create their own templates. Initially Catalyst Cloud will only allow the
use of the pre-defined templates.


Viewing templates
-----------------
When running openstack commandline tools ensure that you have sourced a valid openrc file first.
For more information on this see :ref:`source-rc-file`

.. code-block:: bash

  $ source keystonerc

Then list all of the available cluster templates.

.. code-block:: bash

  $ openstack coe cluster template list
  +--------------------------------------+------+
  | uuid                                 | name |
  +--------------------------------------+------+
  | 43791a50-5dbc-4584-a36b-98fa9359d374 | k8s  |
  +--------------------------------------+------+

To view the details of a particular template.

.. code-block:: bash

  $ openstack coe cluster template show k8s
  +-----------------------+--------------------------------------+
  | Field                 | Value                                |
  +-----------------------+--------------------------------------+
  | insecure_registry     | -                                    |
  | labels                | {}                                   |
  | updated_at            | -                                    |
  | floating_ip_enabled   | True                                 |
  | fixed_subnet          | -                                    |
  | master_flavor_id      | ds1G                                 |
  | uuid                  | 43791a50-5dbc-4584-a36b-98fa9359d374 |
  | no_proxy              | -                                    |
  | https_proxy           | -                                    |
  | tls_disabled          | False                                |
  | keypair_id            | testkey                              |
  | public                | True                                 |
  | http_proxy            | -                                    |
  | docker_volume_size    | -                                    |
  | server_type           | vm                                   |
  | external_network_id   | public                               |
  | cluster_distro        | fedora-atomic                        |
  | image_id              | 169623d9-f521-4f18-afeb-0e2728b3482f |
  | volume_driver         | -                                    |
  | registry_enabled      | False                                |
  | docker_storage_driver | devicemapper                         |
  | apiserver_port        | -                                    |
  | name                  | k8s                                  |
  | created_at            | 2018-04-05T23:18:10+00:00            |
  | network_driver        | calico                               |
  | fixed_network         | -                                    |
  | coe                   | kubernetes                           |
  | flavor_id             | ds1G                                 |
  | master_lb_enabled     | False                                |
  | dns_nameserver        | 8.8.8.8                              |
  +-----------------------+--------------------------------------+


There are some key parameters that are worth mentioning in the abopve template:

* **coe: kubernetes**
  Specifies the container orchestration engine, such as kubernetes, swarm and mesos. Currently the
  the only option available on the Catalyst Cloud is Kubernetes.
* **master_lb_enabled: true**
  As multiple masters may exist in a cluster, a load balancer is created to provide the API
  endpoint for the cluster and to direct requests to the masters. Where the load balancer service
  is not available, this option can be set to ‘false’ thus creating a cluster without the load
  balancer. In this case, one of the masters will serve as the API endpoint. The default is True.
* **network_driver: calico**
  This is the driver used to provide networking services to the containers. This is independant
  from the Neutron networking that the cluster uses. Calico is the Catalyst Cloud recommended
  network driver as it provides secure network connectivity for containers and virtual machine
  workloads.
* **labels**
  These are arbitrary labels (defined by the cluster drivers)  in the form of key=value pairs as a
  way to pass additional parameters to the cluster driver. Currently only
  ``prometheus_monitoring`` is supported and if set to True the monitoring stack will be set up
  and Node Exporter it automatically picked up and launched as a regular Kubernetes POD. By
  default this is False

Creating a cluster
==================

To create a new cluster simply run t

.. code-block:: bash

  $ openstack coe cluster create k8s-cluster \
  --cluster-template k8s \
  -- keypair testkey
  --node-count 4 \
  --master-count 1

  Request to create cluster c191470e-7540-43fe-af32-ad5bf84940d7 accepted

  $ openstack coe cluster list
  +--------------------------------------+-------------+----------+------------+--------------+--------------------+
  | uuid                                 | name        | keypair  | node_count | master_count | status             |
  +--------------------------------------+-------------+----------+------------+--------------+--------------------+
  | c191470e-7540-43fe-af32-ad5bf84940d7 | k8s-cluster | testkey  |          4 |            1 | CREATE_IN_PROGRESS |
  +--------------------------------------+-------------+----------+------------+--------------+--------------------+

Once the cluster is active access to server nodes in the cluster is via ssh, the ssh user will be
'fedora' and the authentication will be using the ssh key provided in the cluster template.

.. code-block:: bash

  ssh fedora@<node_ip>

.. note::

  Once a cluster template is in use it cannot be updated or deleted until all of the clusters
  using it have been terminated.


Setting up Kubernetes CLI
=========================

Getting kubectl
---------------

To deploy and manage applications on kubernetes use the Kubernetes command-line tool, `kubectl`_.
With this tool you can inspect cluster resources; create, delete, and update components; and look
at your new cluster and bring up example apps. The details for getting the latest version of
kubectl can be found `here`_.

.. _`kubectl`: https://kubernetes.io/docs/reference/kubectl/kubectl/
.. _`here`: https://kubernetes.io/docs/tasks/tools/install-kubectl/#kubectl-install-1

To install on Linux via the commandline perform the following steps:

.. code-block:: bash

  $ curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s \
  https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

  $ chmod +x ./kubectl
  $ sudo mv ./kubectl /usr/local/bin/kubectl

Cluster Access Using kubeconfig Files
-------------------------------------
The kubectl command-line tool uses kubeconfig files to find the information it needs
to choose a cluster and communicate with the API server of a cluster. These files to provide
information about clusters, users, namespaces, and authentication mechanisms.

Get cluster config
------------------
Configure native client to access cluster. You can source the output of this
command to get the native client of the corresponding COE configured to access
the cluster.

Example: ``eval $(openstack coe cluster config <cluster-name>)``

.. code-block:: bash

  eval $(openstack coe cluster config k8s-cluster)

Viewing the cluster
-------------------
It is possible to view details of the cluster with the following command. This will return the
address of the master and the services runnig there.

.. code-block:: bash

  $ kubectl cluster-info
  Kubernetes master is running at https://172.24.4.9:6443
  Heapster is running at https://172.24.4.9:6443/api/v1/namespaces/kube-system/services/heapster/proxy
  CoreDNS is running at https://172.24.4.9:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

In order to view more in depth information about the cluster simply add the dump option to the
above example. This generates output suitable for debugging and diagnosing cluster problems.
By default, it redirects everything to stdout.

.. code-block:: bash

  $ kubectl cluster-info dump

Now that we have a cluster up and running and have confirmed our access lets take a look at
running :ref:`kubernetes-workloads` on Kubernetes.
