###########
Quick start
###########

This quick start guide assumes you have working knowledge of Catalyst Cloud
:ref:`command-line-interface` and familiarity with Kubernetes.

******************************
Deploying a Kubernetes cluster
******************************

Choosing a cluster template
===========================

A cluster template is a blue-print to build a Kubernetes cluster (similar to
machine images for the compute service). The cluster template specifies what
version of Kubernetes will be installed and the features that will be enabled.

.. Note::

  In order to be able to create a Kubernetes cluster the user needs to ensure
  that they have been allocated the ``heat_stack_owner`` role.

The following command will list all cluster templates available:

.. code-block:: bash

  $ openstack coe cluster template list
  +--------------------------------------+----------------------------------+
  | uuid                                 | name                             |
  +--------------------------------------+----------------------------------+
  | cf6f8cab-8d22-4f38-a88b-25f8a41e5b77 | kubernetes-v1.11.2-dev-20181008  |
  | 53b3e77f-b004-437c-9626-2d25ddb15329 | kubernetes-v1.11.2-prod-20181008 |
  +--------------------------------------+----------------------------------+

Template types
--------------

The naming convention used for the templates is broken down as follows:

* ``kubernetes-v1.11.2`` : this is the version of kubernetes that the template
  will use to create the cluster.
* ``-dev`` or ``-prod`` : this create either a minimalist cluster for proof of
  oncept or development work, whereas the prod option creates a more production
  ready cluster (see below).
* ``-20181008`` the final portion of the name is the date on which the template
  was created.

The difference between between the  development and production templates are:

* ``dev`` creates a small Kubernetes cluster with a single master and a single
  worker node. As the name suggests, it should not be used for production.
* ``prod`` creates a Kubernetes cluster that is intended for production
  workloads. It expects a minimum three master nodes and three worker nodes.
  The master nodes will have two loadbalancers deployed in front of them in
  order to provide HA for the API and etcd services. This template also deploys
  Prometheus and Grafana to provide cluster metrics.

.. warning::

  Please note that despite having a template called "production", the
  Kubernetes service on the Catalyst Cloud is still in alpha and should not be
  used for production workloads.

Ensure quota is sufficient
==========================

A small quota is sufficient to deploy the production cluster template if your
project is empty. However, if you already have some resources allocated, you
may want to increase your quota to ensure there is sufficient capacity available
to deploy Kubernetes.

By default, the production Kubernetes template allocates:

* 6 compute instances
* 18 vCPUs
* 36 GB of RAM
* 8 floating IPs
* 3 security groups
* 3 volumes
* 60 GB of block storage space

As a ``project admin`` you can change your quota using the `quota management`_
panel in the dashboard.

.. _`quota management`: https://dashboard.cloud.catalyst.net.nz/management/quota/

Creating a cluster from the command line
========================================

To create a new **development** cluster run the following command:

.. code-block:: bash

  $ openstack coe cluster create k8s-dev-cluster \
  --cluster-template kubernetes-v1.11.2-dev-20181008 \
  --keypair my-ssh-key \
  --node-count 1 \
  --master-count 1

  Request to create cluster c191470e-7540-43fe-af32-ad5bf84940d7 accepted

To create a new **production** cluster, run the following command:

.. code-block:: bash

  $ openstack coe cluster create k8s-prod-cluster \
  --cluster-template kubernetes-v1.11.2-prod-20181008 \
  --keypair my-ssh-key \
  --node-count 3 \
  --master-count 3

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

Please wait until the status changes to ``CREATE_COMPLETE`` to proceed.


Creating a cluster from the dashboard
=====================================

This section outlines how to create a cluster throught the Catalyst Cloud
dashboard with needing to use the open stack command line tools. It will still
require the use of the the commandline to handle certificates and use kubectl
to interact with the cluster.

Whether you are creating a **development** or a **production** cluster, the
steps from the dashboard are almost identical.

Once logged into the dashboard select ``Cluster Templates`` from the ``
Container Infra`` section of the left hand menu.

.. image:: _containers_assets/menu_item.png
   :align: center

From here you can select the template that you would like to use to deploy your
cluster from. For this example we will use the latest version of the production
template, **kubernetes-v1.12.7-prod-20190403**.

.. image:: _containers_assets/cluster_templates.png
   :align: center

Next we click on ``Create Cluster`` to launch the cluster wizard. We can add
a name for our cluster and also select a different cluster template if we wish.

Click **Next** to proceed.

.. image:: _containers_assets/cluster_create_1.png
   :align: center

On this screen we have the option of overriding the default node counts and
docker volume size supplied by the template. Here we have entered values
identical to those in the template as an illustration.

For the ``Docker Volume`` size it is recommended to leave this as the default
value defined by the template.

Click **Next** to proceed.

.. image:: _containers_assets/cluster_create_2.png
   :align: center

On this final screen we have the ability to provide custome discovery URLs and
also creation time values. Again unless you have a very specific requirement
around these then the default values should be sufficient.

The final setting is the ``Keypair`` which is the SSH key that will be used in
creation of each of the cluster nodes. This is required and is used when
commandline access is required to the cluster nodes.

.. image:: _containers_assets/cluster_create_3.png
   :align: center

Click **Submit** to launch the cluster.

Once the cluster's status is ``CREATE_COMPLETE``, as shown below, you can begin
deploying your applications to your cluster.

.. image:: _containers_assets/create_complete.png
   :align: center

To see more information about your deployed cluster you can click on the link
in the Clusters page, and it will drill down to show the details of the cluster
template and related resources.

.. image:: _containers_assets/cluster_link.png
   :align: center

Take note of the ``API Address`` in the Nodes section as we will need this when
we create the ``kubeconfig`` file further down.

.. image:: _containers_assets/cluster_details.png
   :align: center

There is also some very useful information in the associated ``Stack`` that was
responsible for creating the cluster. You can either click on the ``Stack ID``
link shown at the bottom of the page in the image above. Alternatively you can
navigate to the corresponding stack from the left hand menu under
Orchestration -> Stacks then click on the ``Stack Name`` that corresponds to
the cluster name with an random string appended, then select the Overview tab.

.. image:: _containers_assets/stack_details.png
   :align: center

Obtaining certificates for cluster authentication
=================================================

As we are not using the Openstack commandline tools in this example we will
need anther way to authenticate with our new cluster. We will do this using
certificates and keys.

.. Note::

  All commands outlined in this section will assume that any files created or
  reference are located in the users current working directory.

First we will need to create a certificate signing request (CSR). We will do
that with the following command.

.. code-block:: bash

  openssl req -new -newkey rsa:2048 -nodes -keyout test-cluster.key -out test-cluster.csr -subj "/CN=admin/O=system:masters"

Now go back to the cluster page in the dashboard and click on the dropdown to
the left of the cluster and select ``Sign Certificate``.

.. image:: _containers_assets/sign_client_cert_1.png
   :align: center

Select **Choose file** and add the ``test-cluster.csr`` file we created in the
previous step.

Click **Sign Certificate** and when prompted save the new file as
``test-cluster_cert.pem``.

.. image:: _containers_assets/sign_client_cert_2.png
   :align: center

Before we leave the dashboard we also need to save a copy of the clusters CA
certificate. To do this click on ``Show Certificate`` to the left of the
cluster. When prompted save the file as ``test-cluster_ca.pem``.

.. image:: _containers_assets/get_ca_cert.png
   :align: center

Back on the command line we need to convert our new certificates and key to a
base64 format to use in our kubeconfig file. To do this run the following.

.. code-block:: bash

  for i in test-cluster*; do echo $i; cat $i | base64; done

The output will be the name of each file followed by the the base64 converted
format.

In the ``config`` file example below replace the necessary fields as follows:

* for **certificate-authority-data**  use the output from **test-cluster_ca.pem**
* for **client-certificate-data** use the output from **test-cluster_cert.pem**
* for **client-key-data** use the output from **test-cluster.key**

.. code-block:: bash

  # kubectl config file
  apiVersion: v1
  clusters:
  - cluster:
      certificate-authority-data: LS0tLS1CRUdJT<redacted>==
      server: https://150.242.43.187:6443
    name: test-cluster
  contexts:
  - context:
      cluster: test-cluster
      user: admin
    name: default
  current-context: default
  kind: Config
  preferences: {}
  users:
  - name: admin
    user:
      client-certificate-data: LS0tLS1CRUdJT<redacted>==
      client-key-data: LS0tLS1CRUdJT<redacted>

Save this file as ``config``.

Now let's set the KUBECONFIG variable so that ``kubectl`` knows where to find
it's configuration. To do this run the following from the current working
directory.

.. code-block:: bash

  export KUBECONFIG=/path/to/file/config

As a quick check, you can run the following command to confirm that Kubernetes
is working as expected:

.. code-block:: bash

  $ kubectl cluster-info
  Kubernetes master is running at https://150.242.43.187:6443
  Heapster is running at https://150.242.43.187:6443/api/v1/namespaces/kube-system/services/heapster/proxy
  CoreDNS is running at https://150.242.43.187:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

  To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.



*****************************
Setting up the Kubernetes CLI
*****************************

Getting kubectl
===============

Detailed instructions for downloading and setting up the latest version of
kubectl can be found `here`_.

.. _`here`: https://kubernetes.io/docs/tasks/tools/install-kubectl/

Run the following commands to install kubectl on Linux as a static binary:

.. code-block:: bash

  $ curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s \
  https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
  $ chmod +x ./kubectl
  $ sudo mv ./kubectl /usr/local/bin/kubectl


******************************
Configuring the Kubernetes CLI
******************************

The kubectl command-line tool uses kubeconfig files to determine how to coonect
to the APIs of the Kubernetes cluster.

Getting the cluster config
==========================

The following command will download the necessary certificates and create a
configuration file on your current directory. It will also export the
``KUBECONFIG`` variable on your behalf:

.. code-block:: bash

  $ eval $(openstack coe cluster config k8s-cluster)

If you wish to save the configuration to a different location you can use the
``--dir <directory_name>`` parameter to select a different destination.

.. Note::

  If you are running multiple clusters, or are deleting and re-creating a
  cluster, it is necessary to ensure that the current ``kubectl configuration``
  is referencing the correct cluster configuration.

Testing the cluster
===================

Once the cluster state is ``CREATE_COMPLETE`` and you have successfully
retrieved the cluster config, you can proceed with deploying your applications
into the cluster using kubectl or whatever your preferred mechanism may be.

As a quick check, you can run the following command to confirm that Kubernetes
is working as expected:

.. code-block:: bash

  $ kubectl cluster-info
  Kubernetes master is running at https://103.254.156.157:6443
  Heapster is running at https://103.254.156.157:6443/api/v1/namespaces/kube-system/services/heapster/proxy
  CoreDNS is running at https://103.254.156.157:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

**********************************
Accessing the Kubernetes dashboard
**********************************

The Catalyst Kubernetes Service enables the Kubernetes web dashboard by default
(this behaviour can be overwritten if desirable).

In order to access the Kubernetes dashboard, you will need retrieve the admin
token for the cluster using the following command:

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

``http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy``

You will be presented with a login screen, as illustrated below. Select
``Token`` as the authentication type and paste in the authentication token
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

The container image in question **chelios/helloworld version_1.1** runs the
following application

.. literalinclude:: _containers_assets/app.py

Creating the application deployment
===================================

First we need to create a manifest like this.

.. literalinclude:: _containers_assets/helloworld-deployment_1.yaml

This provides the following parameters for a deployment:

* number of ``replicas`` - 3
* deployment ``image`` - chelios/helloworld version_1.1.
* pod ``labels``, to identify the app to the service - app: helloworld
* ``containerPort`` to expose the application on - 5000

  - This port also uses a name, in this case **helloworld-port**, which
    allows us to refer to it by name rather than value in the service.

To deploy the application run the following command.

.. code-block:: bash

  $ kubectl create -f helloworld-deployment_1.yaml
  deployment.apps/helloworld-deployment created

Check the state of the pods to confirm that they have all been deployed
correctly.

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
  Endpoints:                192.168.209.128:5000,192.168.209.129:5000,192.168.43.65:5000
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