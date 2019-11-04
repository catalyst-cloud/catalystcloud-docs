########
Clusters
########

This section shows a more in depth view of clusters and their uses. It
goes over the process of creating clusters, which is already covered in
quick start section of this documentation. If you have gone through that you
don't need to follow all of the examples again.

******************
What is a cluster?
******************

A container cluster is the foundation of the Kubernetes Engine, it consists of
one or more **master node(s)** and one or more **woker node(s)**. It is made up
of a collection of compute, networking, and storage resources necessary to run
any given workloads. Communication between them is by way of a shared network.
An entire system may be comprised of multiple clusters.

The ``master`` server is the control plane of the cluster consisting of a
collection of services responsible for providing the centralised scheduling,
logic and management of all aspects of the cluster. While it is possible to run
a cluster with a single master that hosts all of the required services it is
more advisable, especially for production environments, to deploy them in a
multi-master HA configuration.

Some of the key services running on the master are:

- The interface to the cluster is via the ``API Server``, which provides a
  RESTful API frontend to the control plane.
- Configuration and state of the cluster is managed by the ``cluster store``.
  This is based on ``etcd``, which is a distributed key-value store, and
  provides the single source of truth for the cluster and as such is the only
  stateful component within the cluster.
- The ``scheduler``

The machines designated as ``nodes``, previously referred to as minions, are
responsible for accepting and running workloads assigned by the master using
appropriate local and external resources.

********************
The cluster template
********************

A cluster template is a collection of parameters to describe how a cluster can
be constructed. Some parameters are relevant to the infrastructure of the
cluster, while others are for the particular COE.

The cloud provider may supply pre-defined templates for users and it may also
be possible, in some situations, for user to create their own templates.
Initially Catalyst Cloud will only allow the use of the pre-defined templates.

.. Note::

  From cluster template version ``v1.12.10`` onwards, as a security best
  practice, the behaviour when creating a new cluster is for it to be
  created as a :ref:`private-cluster`. This means that the cluster will not be
  reachable directly from the internet by default.

Viewing templates
=================

When running openstack command line tools ensure that you have sourced a valid
openrc file first. For more information on this see :ref:`source-rc-file`


.. Note::

  In order to be able to create a Kubernetes cluster the user needs to ensure
  that they have been allocated the ``heat_stack_owner`` role.

.. code-block:: bash

  $ source keystonerc

Then list all of the available cluster templates.

.. code-block:: bash

  $ openstack coe cluster template list
  +--------------------------------------+----------------------------------+
  | uuid                                 | name                             |
  +--------------------------------------+----------------------------------+
  | c5b5a636-0066-4291-8da9-5190915f5a76 | kubernetes-v1.11.6-prod-20190130 |
  | 5cb74603-4ad3-4e3b-a1d4-4539c392dbf0 | kubernetes-v1.11.6-dev-20190130  |
  | 5e17bc87-27b2-4c61-ba58-c064fd10245d | kubernetes-v1.11.9-dev-20190402  |
  | bd116a49-4381-4cb6-adf8-cd442e1a713f | kubernetes-v1.11.9-prod-20190402 |
  | be25ca0c-2bf6-4bef-a234-4e073b187d71 | kubernetes-v1.12.7-dev-20190403  |
  | 81d0f765-62fe-4c99-b7f8-284ffddac861 | kubernetes-v1.12.7-prod-20190403 |
  +--------------------------------------+----------------------------------+


To view the details of a particular template.

.. code-block:: bash

  $ openstack coe cluster template show kubernetes-v1.12.7-prod-20190403
  +-----------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | Field                 | Value                                                                                                                                                                                                                                                                                                                                              |
  +-----------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | insecure_registry     | -                                                                                                                                                                                                                                                                                                                                                  |
  | labels                | {'kube_tag': 'v1.12.7', 'cloud_provider_enabled': 'true', 'prometheus_monitoring': 'true', 'cloud_provider_tag': '1.14.0-catalyst', 'container_infra_prefix': 'docker.io/catalystcloud/', 'ingress_controller': 'octavia', 'octavia_ingress_controller_tag': '1.14.0-catalyst', 'heat_container_agent_tag': 'stein-dev', 'etcd_volume_size': '20'} |
  | updated_at            | 2019-04-03T10:26:47+00:00                                                                                                                                                                                                                                                                                                                          |
  | floating_ip_enabled   | True                                                                                                                                                                                                                                                                                                                                               |
  | fixed_subnet          | -                                                                                                                                                                                                                                                                                                                                                  |
  | master_flavor_id      | c1.c2r4                                                                                                                                                                                                                                                                                                                                            |
  | uuid                  | 81d0f765-62fe-4c99-b7f8-284ffddac861                                                                                                                                                                                                                                                                                                               |
  | no_proxy              | -                                                                                                                                                                                                                                                                                                                                                  |
  | https_proxy           | -                                                                                                                                                                                                                                                                                                                                                  |
  | tls_disabled          | False                                                                                                                                                                                                                                                                                                                                              |
  | keypair_id            | -                                                                                                                                                                                                                                                                                                                                                  |
  | public                | True                                                                                                                                                                                                                                                                                                                                               |
  | http_proxy            | -                                                                                                                                                                                                                                                                                                                                                  |
  | docker_volume_size    | 20                                                                                                                                                                                                                                                                                                                                                 |
  | server_type           | vm                                                                                                                                                                                                                                                                                                                                                 |
  | external_network_id   | e0ba6b88-5360-492c-9c3d-119948356fd3                                                                                                                                                                                                                                                                                                               |
  | cluster_distro        | fedora-atomic                                                                                                                                                                                                                                                                                                                                      |
  | image_id              | 83833f4f-5d09-44cd-9e23-b0786fc580fd                                                                                                                                                                                                                                                                                                               |
  | volume_driver         | cinder                                                                                                                                                                                                                                                                                                                                             |
  | registry_enabled      | False                                                                                                                                                                                                                                                                                                                                              |
  | docker_storage_driver | overlay2                                                                                                                                                                                                                                                                                                                                           |
  | apiserver_port        | -                                                                                                                                                                                                                                                                                                                                                  |
  | name                  | kubernetes-v1.12.7-prod-20190403                                                                                                                                                                                                                                                                                                                   |
  | created_at            | 2019-04-03T08:40:10+00:00                                                                                                                                                                                                                                                                                                                          |
  | network_driver        | calico                                                                                                                                                                                                                                                                                                                                             |
  | fixed_network         | -                                                                                                                                                                                                                                                                                                                                                  |
  | coe                   | kubernetes                                                                                                                                                                                                                                                                                                                                         |
  | flavor_id             | c1.c4r8                                                                                                                                                                                                                                                                                                                                            |
  | master_lb_enabled     | True                                                                                                                                                                                                                                                                                                                                               |
  | dns_nameserver        | 202.78.240.215                                                                                                                                                                                                                                                                                                                                     |
  | hidden                | False                                                                                                                                                                                                                                                                                                                                              |
  +-----------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+


There are some key parameters that are worth mentioning in the above template:

* ``coe: kubernetes``
  Specifies the container orchestration engine, such as kubernetes, swarm and
  mesos. Currently the the only option available on the Catalyst Cloud is
  Kubernetes.
* ``master_lb_enabled: true``
  As multiple masters may exist in a cluster, a load balancer is created to
  provide the API endpoint for the cluster and to direct requests to the
  masters. Where the load balancer service is not available, this option can be
  set to ‘false’ thus creating a cluster without the load balancer. In this
  case, one of the masters will serve as the API endpoint. The default for
  load balancer is True.
* ``network_driver: calico``
  This is the driver used to provide networking services to the containers.
  This is independent from the Neutron networking that the cluster uses. Calico
  is the Catalyst Cloud recommended network driver as it provides secure
  network connectivity for containers and virtual machine workloads.
* ``labels``
  These are arbitrary labels (defined by the cluster drivers)  in the form of
  key=value pairs as a way to pass additional parameters to the cluster driver.

******************
Creating a cluster
******************

To create a new cluster we run the ``openstack coe cluster create`` command,
providing the name of the cluster that we wish to create along with any
possible additional or over-riding parameters that are necessary.

.. code-block:: bash

  $ openstack coe cluster create k8s-cluster \
  --cluster-template kubernetes-v1.12.7-dev-20190403 \
  --keypair testkey \
  --node-count 1 \
  --master-count 1

  Request to create cluster c191470e-7540-43fe-af32-ad5bf84940d7 accepted

  $ openstack coe cluster list
  +--------------------------------------+-------------+----------+------------+--------------+--------------------+
  | uuid                                 | name        | keypair  | node_count | master_count | status             |
  +--------------------------------------+-------------+----------+------------+--------------+--------------------+
  | c191470e-7540-43fe-af32-ad5bf84940d7 | k8s-cluster | testkey  |          1 |            1 | CREATE_IN_PROGRESS |
  +--------------------------------------+-------------+----------+------------+--------------+--------------------+

Once the cluster is active, access to server nodes in the cluster is via ssh.
The ssh user will be 'fedora' and the authentication will be using the ssh key
provided in the cluster template.

.. code-block:: bash

  $ ssh fedora@<node_ip>

.. note::

  Once a cluster template is in use, it cannot be updated or deleted until all of
  the clusters using it have been terminated.

.. _kube_cli:

*************************
Setting up Kubernetes CLI
*************************

Getting kubectl
===============

To deploy and manage applications on kubernetes use the Kubernetes command-line
tool, `kubectl`_. With this tool you can inspect cluster resources; create,
delete, and update components; and look at your new cluster and bring up
example apps. It's basically the Kubernertes Swiss army knife.

The details for getting the latest version of kubectl can be found `here`_.

.. _`kubectl`: https://kubernetes.io/docs/reference/kubectl/kubectl/
.. _`here`: https://kubernetes.io/docs/tasks/tools/install-kubectl/#kubectl-install-1

To install on Linux via the command line as a simple binary, perform the
following steps:

.. code-block:: bash

  $ curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s \
  https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

  $ chmod +x ./kubectl
  $ sudo mv ./kubectl /usr/local/bin/kubectl


The basic format of kubectl commands looks like this:

.. code-block:: bash

  kubectl [command] [TYPE] [NAME] [flags]

where command, TYPE, NAME, and flags are:

- ``command``: the operation to perform
- ``TYPE``: the resource type to act on
- ``NAME``: the name of the resource in question
- ``flags``: optional flags to provide extra


Cluster Access Using kubeconfig Files
=====================================

The kubectl command-line tool uses kubeconfig files to find the information it
needs to choose a cluster and communicate with the API server of a cluster.
These files provide information about clusters, users, namespaces, and
authentication mechanisms.

Getting the cluster config
==========================

Configure native client to access cluster. You can source the output of this
command to get the native client of the corresponding COE configured to access
the cluster.

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

Accessing the Kubernetes Dashboard
==================================

By default Kubernetes provides a web based dashboard that exposes the details
of a given cluster. In order to access this it is first necessary to to
retrieve the admin token for the cluster you wish to examine.

The following command will extract the correct value from the secrets in the
kube-system namespace.

::

  $ kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-token | awk '{print $1}')
  Name:         admin-token-f5728
  Namespace:    kube-system
  Labels:       <none>
  Annotations:  kubernetes.io/service-account.name=admin
                kubernetes.io/service-account.uid=cc4416d1-ca82-11e8-8993-123456789012

  Type:  kubernetes.io/service-account-token

  Data
  ====
  ca.crt:     1054 bytes
  namespace:  11 bytes
  token:      1234567890123456789012.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi10b2tlbi1mNTcyOCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJhZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImNjNDQxNmQxLWNhODItMTFlOC04OTkzLWZhMTYzZTEwZWY3NiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTphZG1pbiJ9.ngUnhjCOnIQYOAMzyx9TbX7dM2l4ne_AMiJmUDT9fpLGaJexVuq7EHq6FVfdzllgaCINFC2AF0wlxIscqFRWgF1b1SPIdL05XStJZ9tMg4cyr6sm0XXpzgkMLsuAzsltt5GfOzMoK3o5_nqn4ijvXJiWLc4XkQ3_qEPHUtWPK9Jem7p-GDQLfF7IvxafJpBbbCR3upBQpFzn0huZlpgdo46NAuzTT6iKhccnB0IyTFVgvItHtFPFKTUAr4jeuCDNlIVfho99NBSNYM_IwI-jTMkDqIQ-cLEfB2rHD42R-wOEWztoKeuXVkGdPBGEiWNw91ZWuWKkfslYIFE5ntwHgA

Next run the ``kubectl proxy`` command from the CLI. You can run this command
in a separate window, however you will need to source the CONFIG file in said
window.

.. code-block:: bash

  $ kubectl proxy
  Starting to serve on 127.0.0.1:8001

Once the proxy is ready browse to the following URL:

``http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy``

You will be prompted with a login screen, select ``token`` as the type and
paste in the authentication token acquired in the step above.

.. image:: _containers_assets/kubernetes_dashboard_login.png
   :align: center

Once successfully authenticated you will be able to view the cluster console.

.. image:: _containers_assets/kubernetes_dashboard1.png
   :align: center

Now that we have a cluster up and running and have confirmed our access you
should be able to run workloads in your Kubernetes cluster.

.. _cluster_config:

*******************************
Managing cluster configurations
*******************************

When working with multiple clusters or a cluster that has been torn down and
recreated it is necessary to ensure that you have the correct ``cluster
context`` loaded in order for kubectl to interact with the intended cluster.

In order to see the current configuration and context that ``kubectl`` is
using, run the following.

.. code-block:: bash

  $ kubectl config view
  apiVersion: v1
  clusters:
  - cluster:
      certificate-authority: /home/testuser/tmp/ca.pem
      server: https://202.49.241.204:6443
    name: k8s-m1-n1
  contexts:
  - context:
      cluster: k8s-m1-n1
      user: admin
    name: default
  current-context: default
  kind: Config
  preferences: {}
  users:
  - name: admin
    user:
      client-certificate: /home/testuser/tmp/cert.pem
      client-key: /home/testuser/tmp/key.pem

  $ kubectl config current-context
  default

This shows us the details of the current configuration file that kubectl is
referencing and also the specific cluster context within that, in this case
``default``. There is also an environment variable called ``$KUBECONFIG`` that
stores the path or paths to the various configurations that are available.

If we had run the command to retrieve the cluster configuration from a
directory called tmp within our home directory then the output would look
like this.

.. code-block:: bash

  echo $KUBECONFIG
  /home/testuser/tmp/config

If there was a second cluster that we wished to also be able to work with then
we need to retrieve the configuration and store it to a local directory.

.. Note::

  At the current time it is not possible to store multiple cluster
  configurations within the same directory. There is a change coming in a future
  release that will make this possible using a converged configuration file.

If you run ``eval $(openstack coe cluster config <cluster-name>)`` within a
directory that already contains the configuration for a cluster it will fail.
If this is intentional, as in the case of upgrading a cluster that has been
rebuilt, then this is possible by adding the ``--force`` flag, like this.

.. code-block:: bash

  $ eval $(openstack coe cluster config --force k8s-cluster )

If you are wanting to download the configuration for another cluster then we
can use the ``-dir`` flag and pass in the location for the configuration to be
saved. Here we will save our new configuration into a directory called
``.kube/`` under the users home directory.

.. code-block:: bash

  $ eval $(openstack coe cluster config --dir ~/.kube/ k8s-cluster-2)

If we now check the current config we will see that it also says ``default``,
this is because the naming convention used in the creation of the local config
automatically is loaded with **default** as its value.

.. code-block:: bash

  $ kubectl config current-context
  default

If we view the actual config however we can see that this is indeed a different
file to the one we view previously.

.. code-block:: bash

  $ kubectl config view
  apiVersion: v1
  clusters:
  - cluster:
      certificate-authority: /home/testuser/.kube/ca.pem
      server: https://202.49.240.103:6443
    name: k8s-cluster-2
  contexts:
  - context:
      cluster: k8s-cluster-2
      user: admin
    name: default
  current-context: default
  kind: Config
  preferences: {}
  users:
  - name: admin
    user:
      client-certificate: /home/testuser/.kube/cert.pem
      client-key: /home/testuser/.kube/key.pem

To make things more useful we can change and confirm the new name of the
context in the following manner.

.. code-block:: bash

  $ kubectl config rename-context default test
  $ kubectl config current-context
  test

The final step needed to give us access to both of our clusters is to update
the ``$KUBECONFIG`` environment variable so that it knows about both and allows
us to see them in a single view.

.. code-block:: bash

  $ export KUBECONFIG=~/tmp/config:~/.kube/config
  $ kubectl config get-contexts
  CURRENT   NAME      CLUSTER        AUTHINFO   NAMESPACE
            default   k8s-cluster    admin
  *         test      k8s-cluster-2  admin


Now we can simply switch between the various contexts available to us in the
following manner.

.. code-block:: bash

  kubectl config use-context default
