#######
Ingress
#######

****************
What is ingress?
****************

Ingress provides a means to give external users and client applications access
to HTTP services running in a Kubernetes cluster. It is not intended as a means
to expose arbitrary ports or protocols so services other than HTTP/HTTPS
would require a loadbalancer or NodePort service to be configured.

The Ingress is made up of two main components:

* An **Ingress Resource**, which is the set of Layer 7 (L7) rules that define
  how inbound traffic can reach a service. It may be also provide some or all
  of the following:

  - Provide externally reachable URLs, including paths.
  - To load balance traffic.
  - Provide a means for TLS/SSL termination.

* The **Ingress Controller**, which acts on the rules set by the Ingress
  Resource, typically via an HTTP or L7 load balancer. It’s vital that both
  pieces are properly configured to route traffic from an outside client to a
  Kubernetes Service.


*************
Prerequisites
*************

As mentioned above, simply defining an ingress resource is not sufficient to
create an Ingress, it also requires an ingress controller. Catalyst Cloud
provides the native ``Octavia ingress controller`` though it also supports
other common controllers such as the ``ingress-nginx`` controller.

While all ingress controllers should fit the reference specification they do in
fact operate slightly differently and the relevant vendor documentation should
be consulted for details on the correct setup.

************************************
Using the Octavia ingress controller
************************************

In this example we will implement a minimal configuration to illustrate how to
setup ingress to a simple web application that is deployed with multiple
replicas.

The test application
====================

For the test application we will use the Google Cloud echoserver

.. include:: _containers_assets/deployment-echoserver.yml

Deploy this to the cluster with the following command.

.. code-block:: console

  $ kubectl apply -f deployment-echoserver.yml

The create a service to expose the pods on port 80.

.. code-block:: console

  $ kubectl expose deployment echoserver --type=NodePort --target-port=8080 --port 80 --name=echoserver-svc

Deploying the ingress
=====================

In order to setup up the ingress controller we need to create a service
account for this purpose and associate it with an appropriate cluster role
that has the necessary cluster rights.

.. literalinclude:: _containers_assets/octavia-ing-rbac.yml
   :language: yaml

.. code-block:: console

  $ kubectl apply -f octavia-ing-rbac.yml
  serviceaccount/octavia-ingress-controller created
  clusterrolebinding.rbac.authorization.k8s.io/octavia-ingress-controller created

The file **octavia-ing-configmap.yml** below, defines the configuration for the
ingress controller. It requires several user, cluster and project specific
details to be entered. The following commands can assist with acquiring this
information.

The password entry and cluster name will need to be supplied by the user.

.. code-block:: console

  # to get the subnet-id for the cluster1
  $ clustername='<YOUR_CLUSTER_NAME>'
  $ openstack subnet list | grep $clustername | awk -F'\| ' '{ print $2 }'

  # to get the floating-network-id
  $ openstack network list --external -c ID -f value

  # to get the project-id auth-url and region
  $ openstack configuration show -c auth.project_id -f value -c auth_url -f value -c region_name -f value -f yaml

  # to get the user-id
  $ openstack token issue -c user_id -f value -f yaml

.. literalinclude:: _containers_assets/octavia-ing-configmap.yml
   :language: yaml

Once the file has been updated with the correct information create the
configmap.

.. code-block:: console

  $ kubectl apply -f octavia-ing-configmap.yml
  configmap/octavia-ingress-controller-config created

Next we define the ingress itself. This provides the rules and conditions for
the ingress controller to route traffic to the applications. We have defined
the following:

* a host name for host-based routing
* a default path for the entry URL
* link to the backend service echoserver-svc on port 80

.. literalinclude:: _containers_assets/octavia-ing-ingress.yml
   :language: yaml

.. code-block:: console

  $ kubectl apply -f octavia-ing-ingress.yml
  ingress.networking.k8s.io/test-octavia-ingress created

Finally we deploy the ingress controller as a statefulset. This deploys a
single replica running the ``octavia-ing-configmap.yml`` container. It mounts
the configuration as a volume in the pod.

.. literalinclude:: _containers_assets/octavia-ing-statefulset.yml
   :language: yaml

.. code-block:: console

  $ kubectl apply -f octavia-ing-statefulset.yml
  statefulset.apps/octavia-ingress-controller unchanged

Once the pod is deployed we need to wait until the ingress is assigned a
floating IP address as shown below.

.. code-block:: console

  $ kubectl get ing
  NAME                   HOSTS              ADDRESS          PORTS   AGE
  test-octavia-ingress   api.sample.com     103.197.61.251   80      3m43s

Now we can test our connectivity with the following.

.. code-block:: console

  $ ip=103.197.61.251
  $ curl -H "Host:api.sample.com" http://$ip/ping/


  Hostname: echoserver-66ff84f846-ljc9h

  Pod Information:
    -no pod information available-

  Server values:
    server_version=nginx: 1.13.3 - lua: 10008

  Request Information:
    client_address=10.0.0.12
    method=GET
    real path=/ping/
    query=
    request_version=1.1
    request_scheme=http
    request_uri=http://api.sample.com:8080/ping/

  Request Headers:
    accept=*/*
    host=api.sample.com
    user-agent=curl/7.64.1

  Request Body:
    -no body in request-

Cleanup
=======

To remove this setup from your cluster run the following from the directory
that holds the files you created during the deployment.

.. code-block:: console

  $ for i in octavia-ing-*; do kubectl delete -f $i ; done
  configmap "octavia-ingress-controller-config" deleted
  ingress.networking.k8s.io "test-octavia-ingress" deleted
  serviceaccount "octavia-ingress-controller" deleted
  clusterrolebinding.rbac.authorization.k8s.io "octavia-ingress-controller" deleted
  statefulset.apps "octavia-ingress-controller" deleted
