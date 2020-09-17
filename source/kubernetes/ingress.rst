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

Prerequisites
=============

As mentioned above, simply defining an ingress resource is not sufficient to
define Ingress, it also requires an ingress controller to implement the rule
set provided by the resource.

Catalyst Cloud provides the native **Octavia ingress controller** and it also
supports other common ingress controllers such as the
**Nginx ingress controller**.

While all ingress controllers should fit the reference specification they do in
fact operate slightly differently and the relevant vendor documentation should
be consulted for details on the correct setup.


************************************
Using the Octavia ingress controller
************************************

This guide explains how to deploy an Octavia ingress controller in to a
Kubernetes cluster running on an Openstack cloud.

Some working examples
=====================

The code examples below will walk you through all of the steps required to be
able to setup and Octavia ingress on your cluster.

The following scenarios will be covered.

* simple HTTP ingress


***************************
Simple ingress with Octavia
***************************

.. _ingress_test_app:

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

**********************************
Using the Nginx ingress controller
**********************************

This guide explains how to deploy an Nginx ingress controller in to a
Kubernetes cluster running on an Openstack cloud.

This guide makes the following assumptions.

* You have installed the OpenStack command line tools and sourced an
  OpenStack RC file, as explained at :ref:`command-line-interface`
* You have installed `kubectl`_ and and familiar with its use.

.. _`kubectl`: https://kubernetes.io/docs/tasks/tools/install-kubectl/

Some working examples
=====================

In order to use the Nginx ingress controller we first need to  install it into
our cluster. While this can be done by hand creating all of the required
deployments, services and roles it is far simpler to use the ``ingress-nginx``
chart to do this.

The following 3 scenarios are all implemented using the same Helm chart with
with differing configuration in order to achieve the necessary Nginx ingress
behaviour. They also use the same container as the backend service.

* simple HTTP ingress
* Ingress with TLS termination
* Ingress with PROXY protocol support

Setting up Helm
===============

If you do not already have helm installed you can see `installing helm`_ for
more details.

.. _`installing helm`: https://helm.sh/docs/using_helm/

Once Helm is installed we need to add the repository that will supply the
Nginx ingress controller chart

To do that run the following command.

.. code-block:: console

  $ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx


We can confirm if the chart is present in our local helm repository like so.

.. code-block:: console

  $ helm search repo ingress-nginx
  NAME                       	CHART VERSION	APP VERSION	DESCRIPTION
  ingress-nginx/ingress-nginx	2.3.0

*************************
Simple ingress with Nginx
*************************

We will use the same :ref:`test application <ingress_test_app>` setup as that
shown previously for the Octavia example above. It will provide a simple web
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


It is possible to check the current state of the ingress controller run the
following. It will return output similar to that show above from when the
controller was deployed, updating the the **STATUS** where applicable.

.. code-block:: bash

  $ helm status nginx-ingress

Now we need to wait until the ingress controller service gets an external
IP address. We can use the following command to check this.

The ``-w`` present in the command means that it will run the command in
question and then watch for changes.

.. code-block:: bash

  $ kubectl get services -w nginx-ingress-ingress-nginx-controller
  NAME                                     TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                      AGE
  nginx-ingress-ingress-nginx-controller   LoadBalancer   10.254.63.124   103.197.61.141   80:32435/TCP,443:30432/TCP   146m

Now create an ingress that routes the incoming requests to the echo service
based on the the URL path "/ping". This requires the use of the ``annotation``
**kubernetes.io/ingress.class: nginx**

.. code-block:: bash

  cat <<EOF | kubectl apply -f -
  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
      name: test-http
      annotations:
          kubernetes.io/ingress.class: nginx
  spec:
      rules:
      - host: test.example.com
        http:
          paths:
          - backend:
              serviceName: echoserver-svc
              servicePort: 8080
            path: /ping
  EOF

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
    x-request-id=44b267885e34e253619ad6eabc9de69c
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

In this example we will add TLS support to our previous example. The extra
steps involve

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
ingress, the same as the previous example, that routes the incoming requests
for test.example.com to the echo service based on the the URL path "/ping".
This time we will also add configuration for TLS support.  This change adds the
hosts that the ingress will accept traffic for and the cluster secret that will
provide the certificate used for the encryption.

.. code-block:: bash

  $ cat <<EOF | kubectl apply -f -
  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    name: test-with-tls
    annotations:
        kubernetes.io/ingress.class: nginx
  spec:
    rules:
        - host: test.example.com
          http:
            paths:
            - backend:
                serviceName: echoserver-svc
                servicePort: 8080
              path: /ping
    tls:
        - hosts:
          - test.example.com
          secretName: tls-secret-test-example-com
  EOF

Once the ingress is active and has been assigned an external IP address we can
test the service

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
    x-request-id=3f871ce2c2d0b9935d9b45cae43e4d17
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

There are 2 sets of configuration we need to enable for this support to
function.

The configuration for the Nginx ingress requires the following parameters to be
enabled.

* ``use-proxy-protocol``
  Enables or disables the PROXY protocol to receive client connection (real IP
  address) information passed through proxy servers and load balancers.

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

* ``PROXY protocol``
  This option provides support so that you can use a Service in LoadBalancer
  mode to configure a load balancer outside of Kubernetes itself, that will
  forward connections prefixed with PROXY protocol.

  The load balancer will send an initial series of octets describing the
  incoming connection.

This is the actual configuration that will be used by the helm chart.

.. code-block:: bash

  cat <<EOF > nginx-ingress-controller-helm-values.yaml
  controller:
      publishService:
          enabled: true
      config:
          use-forward-headers: "true"
          compute-full-forward-for: "true"
          use-proxy-protocol: "true"
      service:
          annotations:
            loadbalancer.openstack.org/proxy-protocol: "true"
  EOF

We install it as we have previously.

.. code-block:: bash

  $ helm install stable/nginx-ingress --name nginx-ingress -f nginx-ingress-controller-helm-values.yaml
  NAME:   nginx-ingress
  LAST DEPLOYED: Wed Aug 21 14:10:01 2019
  NAMESPACE: default
  STATUS: DEPLOYED

  <-- output truncated for brevity -->


Finally we can set up the ingress as we have for the previous examples.

.. code-block:: bash

  cat <<EOF | kubectl apply -f -
  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
      name: test-with-proxy
      annotations:
          kubernetes.io/ingress.class: nginx
  spec:
      rules:
      - host: test.example.com
        http:
          paths:
          - backend:
              serviceName: echoserver
              servicePort: 8080
            path: /ping
  EOF

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
    x-request-id=a244d459cce51cec15f5482fd4983709
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

