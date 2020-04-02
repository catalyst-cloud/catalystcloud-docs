
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

To create a new **production** cluster, run the following command:

.. code-block:: bash

  $ openstack coe cluster create k8s-cluster \
  --cluster-template kubernetes-v1.13.10-prod-20190912 \
  --keypair my-ssh-key \
  --node-count 3 \
  --master-count 3

  Request to create cluster c191470e-7540-43fe-af32-ad5bf84940d7 accepted

To create a new **development** cluster run the following command:

.. code-block:: bash

  $ openstack coe cluster create k8s-cluster \
  --cluster-template kubernetes-v1.13.10-dev-20190912 \
  --keypair my-ssh-key \
  --node-count 1 \
  --master-count 1

  Request to create cluster c191470e-7540-43fe-af32-ad5bf84940d7 accepted

Modifying cluster template behaviour
====================================

It is possible to override the behaviour of a template by adding or modifying
the labels supplied by the template. To do this the entire list of existing
labels in the template must be provided as a set of key=value pairs, overriding
the required ones as necessary.

To get the list of existing labels on a template simple view the template like
so.

.. code-block:: bash

  openstack coe cluster template show kubernetes-v1.15.6-dev-20191129 -f yaml
  insecure_registry: '-'
  labels:
    auto_healing_controller: magnum-auto-healer
    auto_healing_enabled: 'true'
    auto_scaling_enabled: 'false'
    cloud_provider_enabled: 'true'
    cloud_provider_tag: 1.14.0-catalyst
    container_infra_prefix: docker.io/catalystcloud/
    heat_container_agent_tag: stein-dev
    ingress_controller: octavia
    k8s_keystone_auth_tag: v1.15.0
    keystone_auth_enabled: 'true'
    kube_dashboard_enabled: 'true'
    kube_tag: v1.15.6
    magnum_auto_healer_tag: v1.15.0-catalyst.0
    master_lb_floating_ip_enabled: 'false'
    octavia_ingress_controller_tag: 1.14.0-catalyst
    prometheus_monitoring: 'true'

  <-- truncated for brevity -->

Then convert this into a comma separated key value list like so.

.. warning::

  ensure there is **no whitespace** added around commas ","  or equal signs '='
  when creating the list


.. code-block:: bash

  auto_healing_controller=magnum-auto-healer,auto_healing_enabled=true, \
  auto_scaling_enabled=false,cloud_provider_enabled=true, \
  cloud_provider_tag=1.14.0-catalyst, \
  container_infra_prefix=docker.io/catalystcloud/, \
  heat_container_agent_tag=stein-dev,ingress_controller=octavia, \
  k8s_keystone_auth_tag=v1.15.0,keystone_auth_enabled=true, \
  kube_dashboard_enabled=true,kube_tag=v1.15.6, \
  magnum_auto_healer_tag=v1.15.0-catalyst.0, \
  master_lb_floating_ip_enabled=false, \
  octavia_ingress_controller_tag=1.14.0-catalyst,prometheus_monitoring=true

This will then be passed as the argument to the **labels** parameter.

.. code-block:: bash

  openstack coe cluster create k8s-cluster \
  --cluster-template kubernetes-v1.13.10-prod-20190912 \
  --labels auto_healing_controller=magnum-auto-healer,auto_healing_enabled=true,<-- truncated -->
  --keypair my-ssh-key \
  --node-count 3 \
  --master-count 3

.. warning::

  If the complete list of labels is not provided it is likely that the cluster
  will fail to deploy correctly and will end up in a FAILED or UNHEALTHY state.

Checking the status of the cluster
==================================

Depending on the template used, it will take 5 to 15 minutes for the cluster to
be created.

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

Accessing a private cluster
===========================

Once the cluster state is ``CREATE_COMPLETE`` and you have successfully
retrieved the cluster config, we need to confirm that we are able to access the
cluster.

.. Note::

  The use of the bastion server is unnecessary if you created a public cluster
  that is directly accessible from the internet.

If you did not override the default behaviour you will have created a **private
cluster**. In order to access this you will need to create a bastion host
within your cloud project to allow you to reach the Kubernetes API.

.. Warning::

  When using a bastion server to access a private cluster you will need to
  delete the bastion before trying to delete the cluster.

  Failure to do so will leave your cluster in a **DELETE_FAILED** state that
  will require assistance from the Catalyst Cloud team to resolve.


For the purpose of this example let's assume we deployed a bastion host with
the following characteristics:

* name - bastion
* flavor - c1.c1r1
* image - ubuntu-18.04-x86_64
* network - attached to the Kubernetes cluster network
* security group - bastion-ssh-access
* security group rules - ingress TCP/22 from 114.110.xx.xx ( public IP to allow
  traffic from)

The following commands are to check our setup and gather the information we
need to set up our SSH forward in order to reach the API endpoint.

Find the instance's external public IP address

.. code-block:: bash

  $ openstack server show bastion -c addresses -f value
  private=10.0.0.16, 103.197.62.38

Confirm that we have a security group applied to our instance that allows
inbound TCP connections on port 22 from our current public IP address. In this
case our security group is called bastion-ssh-access and out public IP is
114.110.xx.xx.

.. code-block:: bash

  $ openstack server show bastion -c security_groups -f value
  name='bastion-ssh-access'
  name='default'

  $ openstack security group rule list bastion-ssh-access
  +--------------------------------------+-------------+-----------+------------------+------------+-----------------------+
  | ID                                   | IP Protocol | Ethertype | IP Range         | Port Range | Remote Security Group |
  +--------------------------------------+-------------+-----------+------------------+------------+-----------------------+
  | 42c1320c-98d5-4275-9c2d-b81b0eadac29 | tcp         | IPv4      | 114.110.xx.xx/32 | 22:22      | None                  |
  +--------------------------------------+-------------+-----------+------------------+------------+-----------------------+

Finally we need the IP address for the Kubernetes API endpoint

.. code-block:: bash

  $ openstack coe cluster show k8s-prod -c api_address -f value
  https://10.0.0.5:6443

We will make use of SSH's port forwarding ability in order to allow us to
connect from our local machine's environment. To do this run the following
command in your shell.

.. code-block:: bash

  ssh -f -L 6443:10.0.0.5:6443 ubuntu@103.197.62.38 -N

* -f fork the process in background
* -N do not execute any commands
* -L specifies what connections are given to the localhost. In this example we use the
   ``port:host:hostport`` to bind 6443 on localhost to 6443 on the API endpoint at 10.0.0.5
* The **ubuntu@103.197.62.38** is the credentials for SSH to log into the bastion host.

.. Note::

  Setting up the SSH forwarding is optional. You can choose to deploy a cloud
  instance on the Kubernetes cluster network with appropriate remote access
  and SSH on it and run all of your cluster interactions from there.

As a quick test we can run the following curl command to check that we get a
response from the API server.

.. code-block:: bash

  $ curl https://localhost:6443 --insecure
  {
    "kind": "Status",
    "apiVersion": "v1",
    "metadata": {

    },
    "status": "Failure",
    "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
    "reason": "Forbidden",
    "details": {

    },
    "code": 403
  }

If the curl request returned a JSON response similar to that shown above you
can run the following command to confirm that Kubernetes is working as
expected.

First, if you are running a private cluster and connecting over the SSH tunnel
you will need to edit the kubeconfig file you retrieved earlier and make the
following change.

Find the ``server`` entry that points to the Kubernetes API.

.. code-block:: bash

  server: https://10.0.0.5:6443

Change it so that it points to the localhost address instead.

.. code-block:: bash

  server: https://127.0.0.1:6443

Then run kubectl to confirm that the cluster responds correctly.

.. Note::

    If you have not yet set up the Kubernetes command line tools see :ref:`setting_up_kubectl` for details.

.. code-block:: bash

  $ kubectl cluster-info
  Kubernetes master is running at https://103.254.156.157:6443
  Heapster is running at https://103.254.156.157:6443/api/v1/namespaces/kube-system/services/heapster/proxy
  CoreDNS is running at https://103.254.156.157:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

You can now proceed with deploying your applications into the cluster using
kubectl or whatever your preferred mechanism may be.
