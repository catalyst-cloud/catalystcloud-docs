
.. _k8s-quickstart:

###########
Quick start
###########

This quick start guide assumes you have working knowledge of Catalyst Cloud
:ref:`command-line-interface` and some familiarity with Kubernetes.

.. warning::

  Due to active development of this service, we recommend the use of the latest
  version of the CLI to interact with it. Please refer to the
  :ref:`upgrading-the-cli` section of the documentation for upgrade
  instructions. This documentation assumes ``python-magnumclient`` is 2.12.0 or
  above.


**************
Pre-requisites
**************

Ensure user has the required privileges
=======================================

In order to create a Kubernetes cluster you need to ensure the user has been
allocated the ``heat_stack_owner`` role.

Ensure quota is sufficient
==========================

A small quota is sufficient to deploy the production cluster template if your
project is empty. However, if you already have some resources allocated, you
may want to increase your quota to ensure there is sufficient capacity
available to deploy Kubernetes.

By default, the production Kubernetes template allocates:

* 6 compute instances
* 18 vCPUs
* 36 GB of RAM
* 3 block storage volumes
* 60 GB of block storage space
* 3 security groups
* 1 load balancer

As a ``project admin`` you can change your quota using the `Quota Management`_
panel in the dashboard, under the Management section.

.. _`Quota Management`: https://dashboard.cloud.catalyst.net.nz/management/quota/

Download and install kubectl
============================

Kubectl is the command line interface to the Kubernetes API and the canonical
way to interact with Kubernetes clusters.

The instructions below can be used to quickly install kubectl on Linux as a
static binary:

.. code-block:: bash

  $ curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s \
  https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
  $ chmod +x ./kubectl
  $ sudo mv ./kubectl /usr/local/bin/kubectl

For other platforms or installation methods, please refer to the `detailed
instructions on how to install kubectl`_.

.. _`detailed instructions on how to install kubectl`: https://kubernetes.io/docs/tasks/tools/install-kubectl/

Choosing a cluster template
===========================

A cluster template is a blue-print to build a Kubernetes cluster (similar to
machine images for the compute service). The cluster template specifies what
version of Kubernetes will be installed and the features that will be enabled.
Initially Catalyst Cloud will only support the use of the pre-defined templates.

.. Note::

  From cluster template version ``v1.12.10`` onwards, as a security best
  practice, the behaviour when creating a new cluster is for it to be
  created as a :ref:`private-cluster`. This means that the cluster will not be
  reachable directly from the internet by default.

The following command will list all cluster templates available:

.. code-block:: bash

  $ openstack coe cluster template list
  +--------------------------------------+-----------------------------------+
  | uuid                                 | name                              |
  +--------------------------------------+-----------------------------------+
  | b1d124db-b7cc-4085-8e56-859a0a7796e6 | kubernetes-v1.11.9-dev-20190402   |
  | cf337c0a-86e6-45de-9985-17914e78f181 | kubernetes-v1.11.9-prod-20190402  |
  | 967a2b86-8709-4c07-ae89-c0fe6d69d62d | kubernetes-v1.12.7-dev-20190403   |
  | f8fc0c67-84af-4bb8-89fb-d29f4c926975 | kubernetes-v1.12.7-prod-20190403  |
  | bfde711c-655c-4de9-b37e-847fc635b734 | kubernetes-v1.12.10-dev-20190912  |
  | 38382877-957e-4667-9851-838eef892b64 | kubernetes-v1.12.10-prod-20190912 |
  | d319cc8e-e27d-4ef9-be84-a6d431800215 | kubernetes-v1.13.10-dev-20190912  |
  | e8257719-b209-40bf-9619-2895698d5a73 | kubernetes-v1.13.10-prod-20190912 |
  +--------------------------------------+-----------------------------------+

Alternatively, a list of cluster templates available can be seen in the
`Cluster Templates`_ panel in the dashboard, under the **Container Infra**
section.

.. _`Cluster Templates`: https://dashboard.cloud.catalyst.net.nz/project/cluster_templates

When considering which template to use it is also useful to know what volume
size and type the standard templates come with. For more information on the
volumes our cluster templates use, see
:ref:`the storage section of the kubernetes docs<volume-sizes-kube>`

Template types
--------------

The naming convention used for the templates is broken down as follows:

* **kubernetes-v1.11.2** : this is the version of kubernetes that the template
  will use to create the cluster.
* **-prod** or **-dev**: the type of environment to be created (see below).
* **-20190912**: the date on which the template was created.

The difference between the development and production templates are:

* **Production**: creates a Kubernetes cluster that is intended for production
  workloads. It creates three or more master nodes and three or more worker
  nodes. The master nodes will have a loadbalancer deployed in front of them to
  provide high availability for the Kubernetes API. This template also deploys
  Prometheus and Grafana to provide cluster metrics.
* **Development**: creates a minimal Kubernetes cluster with a single master
  and a single worker node. As the name suggests, it should not be used for
  production.


******************************
Deploying a Kubernetes cluster
******************************

.. include:: deploying-cluster.rst


**********************************
Accessing the Kubernetes dashboard
**********************************

.. include:: dashboard-access.rst


.. _simple_lb_deployment:

***********************************
Deploying a hello world application
***********************************

It is possible to have a loadbalancer created on your behalf by Kubernetes
through the underlying Catalyst Cloud infrastructure services.

For this example we are going to deploy a container running a simple flask app
that will respond with a basic 'Hello World' message that includes the host
name and IP of the node responding to the request. This will sit behind a
loadbalancer that will be publicly available on the internet via a floating ip
and will serve requests to the application servers using the ``round robin``
algorithm.

The container image in question **catalystcloud/helloworld version_1.1** runs
the following application. You do not need to copy this, it already exists in
the cloud.

.. literalinclude:: _containers_assets/app.py

Creating the application deployment
===================================

First we need to create a manifest like this. If you're following along with
this example you should save this file as ``helloworld-deployment_1.yaml``

.. literalinclude:: _containers_assets/helloworld-deployment_1.yaml

This provides the following parameters for a deployment:

* number of ``replicas`` - 3
* deployment ``image`` - catalystcloud/helloworld version_1.1.
* pod ``labels``, to identify the app to the service - app: helloworld
* ``containerPort`` to expose the application on - 8080

  - This port also uses a name, in this case **helloworld-port**, which
    allows us to refer to it by name rather than value in the service.

To deploy the application run the following command.

.. code-block:: bash

  $ kubectl create -f helloworld-deployment_1.yaml
  deployment.apps/helloworld-deployment created

Check the state of the pods to confirm that they have all been deployed
correctly. Once the status of all of them shows that they are running and
ready, this may take a few seconds, continue to the next section.

.. code-block:: bash

  $ kubectl get pods
  NAME                                     READY   STATUS              RESTARTS   AGE
  helloworld-deployment-5bdfcbb467-648bd   1/1     Running             0          43s
  helloworld-deployment-5bdfcbb467-wlb6n   0/1     ContainerCreating   0          43s
  helloworld-deployment-5bdfcbb467-zrlvl   1/1     Running             0          43s

Creating the loadbalancer service
=================================

The deployment itself however does not provide a means for us to expose the
application outside of the cluster. In order to do this we need to
create a service to act as a go between.

The manifest for our service definition will look like this.

.. literalinclude:: _containers_assets/helloworld-service.yaml

The parameters of interest here are:

- the ``selector`` which links the service to the app using the label
  **helloworld**.
- The ``port`` that it exposes externally - 80.
- The ``targetPort`` on the pods to link back to, in this case the named port,
  **helloworld-port** that we created on the deployment.

To create the service run the following command.

.. code-block:: bash

  kubectl create -f helloworld-service.yaml
  service/helloworld-service created

The final step is to check on the state of the service and wait until the
loadbalancer is active and the ``LoadBalancer Ingress`` field has received a
publicly accessible floating IP address.

.. code-block:: bash

  kubectl describe svc helloworld-service
  Name:                     helloworld-service
  Namespace:                default
  Labels:                   <none>
  Annotations:              <none>
  Selector:                 app=helloworld
  Type:                     LoadBalancer
  IP:                       10.254.241.125
  LoadBalancer Ingress:     202.49.241.67
  Port:                     <unset>  80/TCP
  TargetPort:               helloworld-port/TCP
  NodePort:                 <unset>  32548/TCP
  Endpoints:                192.168.209.128:8080,192.168.209.129:8080,192.168.43.65:8080
  Session Affinity:         None
  External Traffic Policy:  Cluster
  Events:
    Type     Reason                      Age                From                Message
    ----     ------                      ----               ----                -------
    Normal   EnsuringLoadBalancer        10m (x2 over 12m)  service-controller  Ensuring load balancer
    Normal   EnsuringLoadBalancer        60s                service-controller  Ensuring load balancer

Once your service is in this state you should be able to browse to the IP
address assign to the LoadBalancer Ingress field and see a simple text output
similar to the following.

.. code-block:: bash

  Hello World! From Server : helloworld-deployment-5bdfcbb467-c7rln @ 192.168.209.129

If you refresh the browser you should also see the response update to reflect
different host responses as the loadbalancer attempts to round robin the
requests.
