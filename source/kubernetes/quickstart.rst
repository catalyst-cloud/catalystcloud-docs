
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

If you did not override the default behaviour you will have created a **private
cluster**. In order to access this you will need to create a bastion host
within your cloud project to allow you to reach the Kubernetes API.

.. Note::

  The use of the bastion server is unnecessary if you created a public cluster
  that is directly accessible from the internet.

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

.. code-block:: bash

  $ kubectl cluster-info
  Kubernetes master is running at https://103.254.156.157:6443
  Heapster is running at https://103.254.156.157:6443/api/v1/namespaces/kube-system/services/heapster/proxy
  CoreDNS is running at https://103.254.156.157:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

You can now proceed with deploying your applications into the cluster using
kubectl or whatever your preferred mechanism may be.


**********************************
Accessing the Kubernetes dashboard
**********************************

The Catalyst Kubernetes Service enables the Kubernetes web dashboard by default
(this behaviour can be overwritten if desirable).

In order to access the Kubernetes dashboard, you will need to retrieve the
admin token for the cluster using the following command:

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

In a separate terminal run the ``kubectl proxy`` command to allow for your
browser to connect to the Kubernetes dashboard.

.. code-block:: bash

  $ kubectl proxy
  Starting to serve on 127.0.0.1:8001

Once the proxy is ready, open following URL on your browser:
http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy

You will be presented with a login screen, as illustrated below. Select
**Token** as the authentication type and paste in the authentication token
acquired in the previous step.

.. image:: _containers_assets/kubernetes_dashboard_login.png
   :align: center

Once successfully authenticated you will be able to view the Kubernetes
dashboard, as illustrated below.

.. image:: _containers_assets/kubernetes_dashboard1.png
   :align: center

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
