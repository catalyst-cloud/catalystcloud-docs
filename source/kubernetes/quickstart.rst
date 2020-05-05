
.. _k8s-quickstart:

###########
Quick start
###########

The purpose of this quick start is to create a cluster that you are able to
test and experiment with, so that you can gain a better understanding of how
the Kubernetes platform works. We are going to be creating a cluster using the
development template with network access from the public internet. We chose
these options because it creates a small cluster, meaning less of a price tag.
And the wider access that is provided by a publicly accessible cluster means
that it's easier for us to conduct tests on the cluster with multiple people
and from multiple locations. However, because of the public access this cluster
will have, this guide should **not** be used to create a production ready cluster.

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

A small quota is sufficient to deploy the development cluster template if your
project is empty. However, if you already have some resources allocated, you
may want to increase your quota to ensure there is sufficient capacity
available to deploy Kubernetes.

By default, the development Kubernetes template allocates:

* 4 compute instances
* 8 vCPUs
* 16 GB of RAM
* 4 block storage volumes
* 40 GB of block storage space
* 3 security groups
* 1 load balancer

As a ``project admin`` you can change your quota using the `Quota Management`_
panel in the dashboard, under the Management section.

.. _`Quota Management`: https://dashboard.cloud.catalyst.net.nz/management/quota/

Download and install kubectl
============================

This quickstart will cover two ways to start your cluster. The Kubectl is only
required for the command line example as Kubectl is the command line interface
to the Kubernetes API and the canonical way to interact with Kubernetes
clusters.

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
For this example, we are going to be using a development template. In
comparison to a production template, the dev templates are locked to one master
node rather than three, they have smaller sizes for the NVMe volumes they use.

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
  | 18a9fa94-95f4-46a4-be3c-c8fae025ce97 | kubernetes-v1.13.12-dev-20191129  |
  | a04e8d58-bd81-4eae-9242-144dc75b3821 | kubernetes-v1.13.12-prod-20191129 |
  | 681241fd-682a-418e-aa1e-8238ceca834e | kubernetes-v1.15.11-dev-20200330  |
  | 77b71c57-7ad3-49fc-a5c2-80962325e7a1 | kubernetes-v1.15.11-prod-20200330 |
  | e7be8a37-c5a6-4dfa-853c-8ff0653ede31 | kubernetes-v1.14.10-dev-20200422  |
  | 9ab35677-8644-4d3c-bb81-281f7ec52e31 | kubernetes-v1.14.10-prod-20200422 |
  | 2cb17a1a-bafd-48c4-a466-c690524d325d | kubernetes-v1.15.11-dev-20200501  |
  +--------------------------------------+-----------------------------------+

Alternatively, a list of cluster templates available can be seen in the
`Cluster Templates`_ panel in the dashboard, under the **Container Infra**
section.

.. _`Cluster Templates`: https://dashboard.cloud.catalyst.net.nz/project/cluster_templates


******************************
Deploying a Kubernetes cluster
******************************

.. _dashboard-cluster-creation:

Creating a cluster from the Catalyst Cloud Dashboard
====================================================

One of the ways to create a kubernetes cluster is by using the section on our
dashboard labelled **Clusters** under the **Container Infra** tab. From here
you will see the following screen:

.. image:: _containers_assets/cluster-main-screen.png

This screen gives you an overview of your clusters, their status and how many
clusters you have measured against your quota. To create a new cluster from
here, click on the *+ Create Cluster* button and you will be met with this
screen:

.. image:: _containers_assets/create-cluster.png

Pick a name for your new cluster, add a keypair, choose the region you want
to deploy this cluster in, and choose from the dropdown list one of the
templates that we have available. In our case, we are going to be using
kubernetes-v1.14.10-dev-20200422. Once that is done your screen should look
something like this:

.. image:: _containers_assets/quickstart-template-picked.png

We then move on to the size of our cluster. If you leave these fields free they
will take on the default outlined in the template, which is fine for our
purposes. You should see that for the master nodes, we are already locked to
only one node; This is because we are using the dev template, however we can
still choose the number of worker nodes.

.. Note::

  When manually selecting a size, make sure that the flavor of your master
  nodes is larger than c1.r1 if the default has not already been set higher.

.. image:: _containers_assets/quickstart-size.png

Next we have the final required settings which is the network we want to deploy
our cluster on. We can either choose an existing network that we have already
prepared, or create a new network that will be attached to the cluster.
Additionally while in this tab, we can select whether we want our cluster to
be visible from only our private network or visible to the public and we can
choose the type of ingress controller that we want our cluster to utilize.

For our quickstart, we are going to be creating a new network for our cluster
to sit on and we are going to make it available publicly.

.. image:: _containers_assets/quickstart-network.png

The other tabs ``management`` and ``advanced`` allow you to set autohealing on
your nodes and add labels to your cluster respectfully.

Once you have set all of these parameters, you can click submit and your
cluster will start creating. This process can take up to 20 minutes
depending on the size of the cluster you are trying to build. Once it is built
however, you will be able to access the cluster in the ways detailed below.



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
