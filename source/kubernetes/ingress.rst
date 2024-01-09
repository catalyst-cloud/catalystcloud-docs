#######
Ingress
#######

.. _ingress-controller:

******************************
What is an ingress controller?
******************************

In Kubernetes, Ingress allows external users and client applications access
to HTTP services. Ingress consists of two components.

The `Ingress Resource` is a collection of rules for the inbound traffic to
reach Services. These are Layer 7 (L7) rules that allow hostnames and
optionally paths, to be directed to specific Services in Kubernetes.

An `Ingress Controller` which acts upon the rules set by the Ingress Resource,
typically via an HTTP or L7 load balancer. It is vital that both pieces are
properly configured to route traffic from an outside client to a Kubernetes
Service.

For more information, see `Kubernetes Ingress Documentation`_.

.. _`Kubernetes Ingress Documentation`: https://kubernetes.io/docs/concepts/services-networking/ingress/

Prerequisites
=============

As mentioned above, simply defining an ingress resource is not sufficient to
define Ingress, it also requires an ingress controller to implement the rule
set provided by the resource.

Catalyst Cloud supports common ingress controllers such as **Traefik** and the **Nginx ingress controller**.

While all ingress controllers should fit the reference specification they do in
fact operate slightly differently and the relevant vendor documentation should
be consulted for details on the correct setup.

.. TODO (travis): create an example using Traefik and/or nginx

************************************
Using the Octavia ingress controller
************************************

The Octavia ingress controller is enabled by default on the Catalyst Cloud.

As part of this a  service account with the necessary cluster role binding has
already been created. A configmap has also been deployed to handle the
necessary authentication with the controller.

Some working examples
=====================

The following code examples will walk you through all of the steps required to
setup an Octavia ingress on your cluster.

The following scenarios will be covered.

* Simple HTTP ingress


********************************
Simple HTTP ingress with Octavia
********************************

.. _ingress_test_app:

The test application
====================

For our test application we will use a Google Cloud echoserver. To set this up,
you will need to save the following as a .yml file:

.. include:: _containers_assets/deployment-echoserver.yml

Once you've copied this, we can deploy it to the cluster with the following
command.

.. code-block:: console

  $ kubectl apply -f deployment-echoserver.yml

.. Note::

  For Ingress to work correctly the service that exposes the application needs
  to be created using ``--type=NodePort``

Then we need to create a service to expose the pods on port 80 with the type
**NodePort**.

.. code-block:: console

  $ kubectl expose deployment echoserver-deployment --type=NodePort --target-port=8080 --port 80 --name=echoserver-svc

Before we move on to ingress, it's useful to test the Service from within the cluster

.. code-block:: console

  # Create a temporary pod in interactive mode, to test within pod networks.
  $ kubectl run --rm -it --image nginx shell -- bash

  # Request directly to the service address.
  root@shell:/# curl http://echoserver-svc.default.svc.cluster.local

    Hostname: echoserver-deployment-7fcdd7b5cd-kgp4r

    Pod Information:
      -no pod information available-

    Server values:
      server_version=nginx: 1.13.3 - lua: 10008

    Request Information:
      client_address=10.100.1.16
      method=GET
      real path=/
      query=
      request_version=1.1
      request_scheme=http
      request_uri=http://echoserver-svc.default.svc.cluster.local:8080/

    Request Headers:
      accept=*/*
      host=echoserver-svc.default.svc.cluster.local
      user-agent=curl/7.74.0

    Request Body:
      -no body in request-


.. warning::

  After creating an Ingress, if an existing service is re-created with the
  same service port but with a different NodePort, the Ingress will not work
  and you will need to recreate the Ingress or manually update it to send data
  to the new node port.

Deploying the ingress
=====================

As the majority of the ingress configuration has already been taken care of for
us, we only need to define the ingress itself. This will provide the rules and
conditions for the ingress controller to route traffic to our applications. We
have defined the following:

* a host name for host-based routing
* a default path for the entry URL
* a link to the backend service echoserver-svc on port 80

.. literalinclude:: _containers_assets/octavia-ing-ingress.yml
   :language: yaml

.. code-block:: console

  $ kubectl apply -f octavia-ing-ingress.yml
  ingress.networking.k8s.io/test-octavia-ingress created


Now we can test our connectivity against the Octavia Loadbalancer:

.. code-block:: console

  # Obtain IP address of ingress (it may take a minute or two to appear, as the loadbalancer is created)
  $ kubectl get ingress test-octavia-ingress
  NAME                   CLASS    HOSTS             ADDRESS      PORTS   AGE
  test-octavia-ingress   <none>   api.example.com   10.10.8.81   80      119s

  # Make a request against the Ingress loadbalancer IP.
  $ curl -H "Host:api.example.com" http://10.10.8.81/

  Hostname: echoserver-deployment-7fcdd7b5cd-rmzll

  Pod Information:
    -no pod information available-

  Server values:
    server_version=nginx: 1.13.3 - lua: 10008

  Request Information:
    client_address=10.0.0.10
    method=GET
    real path=/
    query=
    request_version=1.1
    request_scheme=http
    request_uri=http://api.example.com:8080/

  Request Headers:
    accept=*/*
    host=api.example.com
    user-agent=curl/7.68.0

  Request Body:
    -no body in request-


Cleanup
=======

To remove this setup from your cluster run the following from the directory
that holds the files you created during your deployment.

.. code-block:: console

  $ kubectl delete -f deployment-echoserver.yml -f octavia-ing-ingress.yml
  deployment.apps "echoserver-deployment" deleted
  ingress.networking.k8s.io "test-octavia-ingress" deleted

  $ kubectl delete service echoserver-svc
  service "echoserver-svc" deleted


**********************************
Using the Nginx ingress controller
**********************************

This guide explains how to deploy an Nginx ingress controller an existing
Kubernetes cluster running on an Openstack cloud.

This guide makes the following assumptions.

* You have installed the OpenStack command line tools and sourced an
  OpenStack RC file, as explained at :ref:`command-line-interface`
* You have installed `kubectl`_ and and familiar with its use.

.. _`kubectl`: https://kubernetes.io/docs/tasks/tools/#kubectl

Some working examples
=====================

In order to use the Nginx ingress controller we first need to install it into
our cluster. While this can be done by hand creating all of the required
deployments, services and roles it is far simpler to use the ``ingress-nginx``
chart to do this.

The following 3 scenarios are all implemented using the same Helm chart with
with differing configuration in order to achieve the necessary Nginx ingress
behavior. They also use the same container as the backend service.

* simple HTTP ingress
* Ingress with TLS termination
* Ingress with PROXY protocol support

Setting up Helm
===============

If you do not already have helm installed you can see `installing helm`_ for
more details.

.. _`installing helm`: https://helm.sh/docs/using_helm/

Once Helm is installed we need to add the repository that will supply us with
the Nginx ingress controller chart.

To do that run the following command.

.. code-block:: console

  $ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx


We can confirm if the chart is present in our local helm repository like so:

.. code-block:: console

  $ helm search repo ingress-nginx
  NAME                       	CHART VERSION	    APP VERSION	    DESCRIPTION
  ingress-nginx/ingress-nginx	2.3.0

*************************
Simple ingress with Nginx
*************************

We will use the same :ref:`test application <ingress_test_app>` setup as shown
previously in the Octavia example above. It will provide a simple web
application that will respond to our requests.


First we need to install the Nginx ingress controller in our cluster. To do
this run the following command and ensure that the output says
``STATUS: deployed``.

.. code-block:: bash

  $ helm install nginx-ingress ingress-nginx/ingress-nginx
  NAME: nginx-ingress
  LAST DEPLOYED: Tue Jun  9 12:33:43 2020
  NAMESPACE: default
  STATUS: deployed
  REVISION: 1
  TEST SUITE: None
  NOTES:
  The ingress-nginx controller has been installed.
  It may take a few minutes for the LoadBalancer IP to be available.
  You can watch the status by running 'kubectl --namespace default get services -o wide -w nginx-ingress-ingress-nginx-controller'

  An example Ingress that makes use of the controller:

    apiVersion: networking.k8s.io/v1beta1
    kind: Ingress
    metadata:
      annotations:
        kubernetes.io/ingress.class: nginx
      name: example
      namespace: foo
    spec:
      rules:
        - host: www.example.com
          http:
            paths:
              - backend:
                  serviceName: exampleService
                  servicePort: 80
                path: /
      # This section is only required if TLS is to be enabled for the Ingress
      tls:
          - hosts:
              - www.example.com
            secretName: example-tls

  If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

    apiVersion: v1
    kind: Secret
    metadata:
      name: example-tls
      namespace: foo
    data:
      tls.crt: <base64 encoded cert>
      tls.key: <base64 encoded key>
    type: kubernetes.io/tls

It is possible to check the current state of the ingress controller by running
the following piece of code. It will return an output similar to that shown
above, from when the controller was deployed, updating the the **STATUS** where
applicable.

.. code-block:: bash

  $ helm status nginx-ingress

Now we need to wait until the ingress controller service gets an external
IP address. We can use the following command to check this:

.. code-block:: bash

  # The '-w' present in the command means that it will run the command in question and then watch for changes.
  $ kubectl get services -w nginx-ingress-ingress-nginx-controller

  NAME                                     TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
  nginx-ingress-ingress-nginx-controller   LoadBalancer   10.254.63.124   103.197.61.141   80:32435/TCP,443:30432/TCP   146m

Once we have our external IP address, we can move on to creating an ingress
that routes the incoming requests to the echo service based on the the URL path
"/ping". This requires the use of the ``annotation`` **kubernetes.io/ingress.
class: nginx**

.. literalinclude:: _containers_assets/ingress-create.sh
  :language: shell

Wait for IP address to be allocated

.. code-block:: bash

  $ kubectl get ingress -w

  NAME        HOSTS              ADDRESS         PORTS   AGE
  test-http   test.example.com   103.197.63.20   80      45s

Send a request to the /ping URL on the client IP address seen on the echo
service

.. code-block:: bash

  ip=103.197.63.20
  curl -H "Host:test.example.com" http://$ip/ping


  Hostname: echoserver

  Pod Information:
    -no pod information available-

  Server values:
    server_version=nginx: 1.13.3 - lua: 10008

  Request Information:
    client_address=10.100.115.13
    method=GET
    real path=/ping
    query=
    request_version=1.1
    request_scheme=http
    request_uri=http://test.example.com:8080/ping

  Request Headers:
    accept=*/*
    host=test.example.com
    user-agent=curl/7.64.1
    x-forwarded-for=10.0.0.14
    x-forwarded-host=test.example.com
    x-forwarded-port=80
    x-forwarded-proto=http
    x-real-ip=10.0.0.14
    x-request-id=44b267885e34e2536xxxxxxabc9de69c
    x-scheme=http

  Request Body:
    -no body in request-

Cleanup
=======

Before moving on to the next example let's clean up the resources we created
in this example.

.. code-block:: bash

  $ kubectl delete ingress test-http
  $ helm delete nginx-ingress


******************************
Nginx ingress with TLS support
******************************

In this example we will add TLS support on top our previous example. The extra
steps involve are:

* The creation of a self signed SSL certificate.
* Creating a Kubernetes secret to hold the certificate.
* Creating a new set of ingress rules to add port 443 and the details of how
  to access the certificates.

For simplicity we will use a self signed certificate, though you can use
certificates purchased from a provider in the exact same manner. The following
code will create this for us.

.. code-block:: bash

  $ if [ ! -f ./certs/tls.key ]; then
    mkdir certs
    openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 \
        -keyout certs/tls.key \
        -out certs/tls.crt \
        -subj "/CN=test.example.com/O=Integration"
  fi

Next we will create a TLS secret using the certificates created in the
previous step.

.. code-block:: bash

  $ kubectl create secret tls tls-secret-test-example-com --key certs/tls.key --cert certs/tls.crt

Label the secret so it's easier to delete later

.. code-block:: bash

  $ (kubectl get secret -l group=test-example-com 2>/dev/null | grep tls-secret-test-example-com) || kubectl label secret tls-secret-test-example-com group=test-example-com

As the helm config will remain the same as the previous example, we can go
ahead and deploy the ingress controller.

.. code-block:: bash

  $ helm install nginx-ingress ingress-nginx/ingress-nginx
  NAME: nginx-ingress
  LAST DEPLOYED: Tue Jun  9 12:33:43 2020
  NAMESPACE: default
  STATUS: deployed
  REVISION: 1
  TEST SUITE: None
  NOTES:
  The ingress-nginx controller has been installed.
  It may take a few minutes for the LoadBalancer IP to be available.
  You can watch the status by running 'kubectl --namespace default get services -o wide -w nginx-ingress-ingress-nginx-controller'

  An example Ingress that makes use of the controller:

    apiVersion: networking.k8s.io/v1beta1
    kind: Ingress
    metadata:
      annotations:
        kubernetes.io/ingress.class: nginx
      name: example
      namespace: foo
    spec:
      rules:
        - host: www.example.com
          http:
            paths:
              - backend:
                  serviceName: exampleService
                  servicePort: 80
                path: /
      # This section is only required if TLS is to be enabled for the Ingress
      tls:
          - hosts:
              - www.example.com
            secretName: example-tls

    If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

      apiVersion: v1
      kind: Secret
      metadata:
        name: example-tls
        namespace: foo
      data:
        tls.crt: <base64 encoded cert>
        tls.key: <base64 encoded key>
      type: kubernetes.io/tls

Once the loadbalancer is active and has an external IP we can create an
ingress, in the same way as the previous example, that routes the incoming
requests for test.example.com to the echo service based on the the URL path "/
ping". This time we will also add configuration for TLS support. This change
adds the hosts that the ingress will accept traffic for and the cluster secret
that will provide the certificate used for the encryption.

.. literalinclude:: _containers_assets/ingress-tls-create.sh
  :language: shell

Once the ingress is active and has been assigned an external IP address we can
test the service:

.. code-block:: bash

  $ kubectl get ingress -w
  NAME            HOSTS              ADDRESS          PORTS     AGE
  test-with-tls   test.example.com   202.49.241.145   80, 443   41s

  $ ip=202.49.241.145
  $ curl -H "Host:test.example.com" https://$ip/ping --insecure
  Hostname: echoserver-deployment-7d874bf66b-v6rrt

  Pod Information:
    -no pod information available-

  Server values:
    server_version=nginx: 1.13.3 - lua: 10008

  Request Information:
    client_address=10.100.189.71
    method=GET
    real path=/ping
    query=
    request_version=1.1
    request_scheme=http
    request_uri=http://test.example.com:8080/ping

  Request Headers:
    accept=*/*
    host=test.example.com
    user-agent=curl/7.64.1
    x-forwarded-for=10.0.0.13
    x-forwarded-host=test.example.com
    x-forwarded-port=443
    x-forwarded-proto=https
    x-real-ip=10.0.0.13
    x-request-id=3f871ce2c2d0b9935d9bxxxxxx3e4d17
    x-scheme=https

  Request Body:
    -no body in request-

Cleanup
=======

Before moving on to the next example let's clean up the resources we created
in this example.

.. code-block:: bash

  $ kubectl delete ingress test-with-tls
  $ helm delete nginx-ingress

*****************************************
Nginx ingress with PROXY protocol support
*****************************************

For the final example we will enable support for the PROXY protocol. This
provides visibility of the originating servers IP address to the backend
services.

There are 2 sets of configuration which we need to enable for this support to
function.

The configuration for the Nginx ingress requires the following parameters to be
enabled.

* ``use-proxy-protocol``
  Will enable or disable the PROXY protocol to receive client connection (real
  IP address) information passed through proxy servers and load balancers.

* ``use-forwarded-headers``
  If true, NGINX passes the incoming X-Forwarded-* headers to upstreams. Use
  this option when NGINX is behind another L7 proxy / load balancer that is
  setting these headers.

  If false, NGINX ignores incoming X-Forwarded-* headers, filling them with the
  request information it sees. Use this option if NGINX is exposed directly to
  the internet, or it's behind a L3/packet-based load balancer that doesn't
  alter the source IP in the packets.

* ``compute-full-forwarded-for``
  Will append the remote address to the X-Forwarded-For header instead of
  replacing it. When this option is enabled, the upstream application is
  responsible for extracting the client IP based on its own list of trusted
  proxies.


For the cluster itself the following annotation needs to be added to the
configuration.

* ``PROXY protocol``:
  This option provides support so that you can use a Service in LoadBalancer
  mode to configure a load balancer outside of Kubernetes itself, which will
  forward connections prefixed with the PROXY protocol.

  The load balancer will send an initial series of octets describing the
  incoming connection.

This is the actual configuration that will be used by the helm chart.

.. literalinclude:: _containers_assets/ingress-configure-proxy.sh
  :language: shell

We install it as we have previously.

.. code-block:: bash

  $ helm install stable/nginx-ingress --name nginx-ingress -f nginx-ingress-controller-helm-values.yaml
  NAME:   nginx-ingress
  LAST DEPLOYED: Wed Aug 21 14:10:01 2019
  NAMESPACE: default
  STATUS: DEPLOYED

  <-- output truncated for brevity -->


Finally we can set up the ingress as we have for the previous examples.

.. literalinclude:: _containers_assets/ingress-create-proxy.sh
  :language: shell

Once the external IP is available we can test it with curl as we have
previously. The important thing to note here is that now we can see the
originating IP address included in the request headers.

.. code-block:: bash

  $ kubectl get ingress
  NAME              HOSTS              ADDRESS          PORTS   AGE
  test-with-proxy   test.example.com   202.49.241.165   80      80s

  $ ip=202.49.241.165
  $ curl -H "Host:test.example.com" http://$ip/ping
  Hostname: echoserver-7cc8b87c6f-h8ls5

  Pod Information:
    -no pod information available-

  Server values:
    server_version=nginx: 1.13.3 - lua: 10008

  Request Information:
    client_address=192.168.73.68
    method=GET
    real path=/ping
    query=
    request_version=1.1
    request_scheme=http
    request_uri=http://test.example.com:8080/ping

  Request Headers:
    accept=*/*
    host=test.example.com
    user-agent=curl/7.54.0
    x-forwarded-for=203.109.145.15
    x-forwarded-host=test.example.com
    x-forwarded-port=80
    x-forwarded-proto=http
    x-original-uri=/ping
    x-real-ip=203.109.145.15
    x-request-id=a244d459cce51cec1xxxxxxfd4983709
    x-scheme=http

  Request Body:
    -no body in request-

Cleanup
=======

Before moving on to the next example let's clean up the resources we created
in this example.

.. code-block:: bash

  $ kubectl delete ingress test-with-proxy
  $ helm delete nginx-ingress

