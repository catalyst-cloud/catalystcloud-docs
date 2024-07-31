.. _kubernetes-ingress:


#######
Ingress
#######


In the section on :ref:`k8s-load-balancers` we explored how you can easily route
traffic to a website by simply creating a ``LoadBalancer`` type service in Kubernetes.

Although this approach works for basic websites, it doesn't work well when a
website has more than one endpoint. For example, consider a website such as
``example.com`` which has sub-domains ``food.example.com`` and
``toys.example.com`` with endpoints at different applications. As shown in the
following figure, each of these endpoints would require a separate load
balancer, which add additional costs to your cluster. As the website adds more
endpoints this can get quite expensive.

.. figure:: _containers_assets/load-balancers.drawio.svg
  :name: k8s-load-balancer-svc
  :class: with-border

Ingress provides a cost-effective alternative by making it possible to host multiple
websites using a single load balancer. As seen in the following figure, Ingress
allows you to route requests to different internal services by using
sub-domains or paths. It also makes it easy to
provide TLS termination for different websites.

.. figure:: _containers_assets/ingress-combined.drawio.svg
  :name: k8s-ingress
  :class: with-border

  **Left**: Using the ``toys`` and ``food`` subdomains for routing requests.
  **Right**: Using the ``/toys`` and ``/food`` paths for routing requests.

.. _ingress-controller:

****************
What is Ingress?
****************

In Kubernetes, **Ingress** allows external users and client applications access
to HTTP services. Ingress consists of two components:

* An **Ingress Resource**, which is a collection of rules for the inbound traffic
  to reach Services. These are Layer 7 (L7) rules that allow hostnames or paths
  to be directed to specific Services in Kubernetes.
* An **Ingress Controller**, which acts upon the rules set by the Ingress Resource,
  typically via an HTTP or L7 load balancer.

It is vital that both pieces are properly configured to route traffic from
an outside client to a Kubernetes Service.

For more information, refer to the `Kubernetes Ingress documentation`_.

.. _`Kubernetes Ingress documentation`: https://kubernetes.io/docs/concepts/services-networking/ingress

****
Demo
****

The following sections will demonstrate how to host a web application using Ingress,
using a demo application as an example.

You can copy-and-paste manifest files on this page and apply them in order,
and a working example Ingress Controller setup will be created in your cluster.

To run this demo, please make sure you have:

* The :ref:`Kubernetes Admin <k8s-rbac-roles>` role assigned to your Catalyst Cloud user account in your project.
* Installed the Catalyst Cloud command line tools,
  and sourced the OpenRC file for your project in your terminal session.
  For more information, please refer to :ref:`cli`.
* Have retreived a :ref:`kubeconfig file <kubeconfig-file-location>` for your cluster.
* Downloaded and installed `kubectl`_, the Kubernetes command line client.
* Downloaded and installed `Helm`_, a package manager for Kubernetes applications.

.. _`kubectl`: https://kubernetes.io/releases/download/#kubectl
.. _`Helm`: https://helm.sh/docs/intro/install

.. _ingress_test_app:

The demo application
====================

For our test application we will use an echoserver. To set this up,
first create a YAML file called ``echoserver-deployment.yml`` with the following contents:

.. literalinclude:: _containers_assets/deployment-echoserver.yml
    :language: yaml

Now, create the deployment in the cluster with the following command.

.. code-block:: bash

  kubectl apply -f echoserver-deployment.yml

Create a `ClusterIP`_ service to expose the application internally on port 80.

.. _`ClusterIP`: https://kubernetes.io/docs/concepts/services-networking/service/#type-clusterip

.. code-block:: bash

  kubectl expose deploy echoserver --name echoserver --port 80 --target-port 8080

Verify that pods and services have been created:

.. code-block:: console

  $ kubectl get all
  NAME                              READY   STATUS    RESTARTS   AGE
  pod/echoserver-6c456d4fcc-hmqts   1/1     Running   0          16s

  NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
  service/echoserver   ClusterIP   172.30.105.68   <none>        80/TCP    3s
  service/kubernetes   ClusterIP   172.24.0.1      <none>        443/TCP   19h

  NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
  deployment.apps/echoserver   1/1     1            1           16s

  NAME                                    DESIRED   CURRENT   READY   AGE
  replicaset.apps/echoserver-6c456d4fcc   1         1         1       16s

We are also able to check if the echoserver application is working correctly.

First, login to the cluster using a temporary pod:

.. code-block:: bash

  kubectl run --rm -it --image nginx shell -- bash

Now run the following command to make a request against the echoserver:

.. code-block:: bash

  curl http://echoserver.default.svc.cluster.local

If everything is working, you should see something similar to the following output.

.. code-block:: console

  root@shell:/# curl http://echoserver.default.svc.cluster.local


  Hostname: echoserver-6c456d4fcc-hmqts

  Pod Information:
    -no pod information available-

  Server values:
    server_version=nginx: 1.14.2 - lua: 10015

  Request Information:
    client_address=172.18.62.200
    method=GET
    real path=/
    query=
    request_version=1.1
    request_scheme=http
    request_uri=http://echoserver.default.svc.cluster.local:8080/

  Request Headers:
    accept=*/*
    host=echoserver.default.svc.cluster.local
    user-agent=curl/7.88.1

  Request Body:
    -no body in request-

.. TODO(travis): move someplace below

.. Deploying Ingress
.. =====================
..
.. As the majority of the ingress configuration has already been taken care of for
.. us, we only need to define the ingress itself. This will provide the rules and
.. conditions for the ingress controller to route traffic to our applications. We
.. have defined the following:
..
.. * a host name for host-based routing
.. * a default path for the entry URL
.. * a link to the backend service echoserver on port 80

********************************
Installing an Ingress Controller
********************************

We have an application running, but it can only be reached from *within* the cluster.
Since we do not want to require our customers to log into a pod on the cluster to see the
website, we need to make it accessible to the outside world on a public IP address.

There are number of `ingress controllers`_ available from various vendors.
Catalyst Cloud supports many of these, including `Ingress-Nginx`_ and `Traefik`_.
Implementation for each will vary, so it is important
to always refer to the vendor's documentation when using a particular Ingress Controller.

.. _`ingress controllers`: https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/#additional-controllers
.. _`Ingress-Nginx`: https://kubernetes.github.io/ingress-nginx
.. _`Traefik`: https://doc.traefik.io/traefik/providers/kubernetes-ingress

.. _kubernetes-ingress-nginx:

********************************
Ingress-Nginx Ingress Controller
********************************

In this demo we will install the `Ingress-Nginx`_ ingress controller using Helm,
and configure it to serve our echoserver application to the public Internet.

Setting up Helm
===============

.. FIXME (travis): Should we have a separate section describing tools for installing things into a cluster?

To install the ingress controller with Helm, we need to add the repository
that will supply us with the Helm chart for it.

To do this, run the following command:

.. code-block:: bash

  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

We can confirm that the chart is present in our local Helm repository using the following command:

.. code-block:: console

  $ helm search repo ingress-nginx
  NAME                       	CHART VERSION	APP VERSION	DESCRIPTION
  ingress-nginx/ingress-nginx	4.10.0       	1.10.0     	Ingress controller for Kubernetes using NGINX a...

Deploying the Ingress Controller
================================

.. note::

   Deploying an Ingress Controller requires the :ref:`Kubernetes Admin <k8s-rbac-roles>` role.

   For more information on granting Kubernetes RBAC roles to users,
   please refer to :ref:`User Access <kubernetes-user-access>`.

First, we need to install the Nginx ingress controller in our cluster.

To do this, run the following command and ensure that the output says ``STATUS: deployed``.

.. code-block:: console

  $ helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
  Release "ingress-nginx" does not exist. Installing it now.
  NAME: ingress-nginx
  LAST DEPLOYED: Wed Apr 17 10:35:05 2024
  NAMESPACE: ingress-nginx
  STATUS: deployed
  REVISION: 1
  TEST SUITE: None
  NOTES:
  The ingress-nginx controller has been installed.
  It may take a few minutes for the load balancer IP to be available.
  You can watch the status by running 'kubectl get service --namespace ingress-nginx ingress-nginx-controller --output wide --watch'

  An example Ingress that makes use of the controller:
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: example
      namespace: foo
    spec:
      ingressClassName: nginx
      rules:
        - host: www.example.com
          http:
            paths:
              - pathType: Prefix
                backend:
                  service:
                    name: exampleService
                    port:
                      number: 80
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

You can check the current state of the ingress controller by running
the following command. It returns similar output to the previous command,
with the ``STATUS`` being updated upon state changes.

.. code-block:: bash

  helm status -n ingress-nginx ingress-nginx

Now we need to wait until the ingress controller service gets an external
IP address. We can use the following command to check this:

.. code-block:: console

  $ kubectl get service --namespace ingress-nginx ingress-nginx-controller --watch
  NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
  ingress-nginx-controller   LoadBalancer   172.24.53.166   192.0.2.1     80:32014/TCP,443:30489/TCP   5m35s

Once we have our external IP address, we can move on to creating an ``Ingress``.

.. note::

   Creating an ``Ingress`` requires the :ref:`Kubernetes Developer <k8s-rbac-roles>` role.

The below manifest routes the incoming requests to the echoserver based on the the URL path ``/ping``.

.. literalinclude:: _containers_assets/echoserver-ingress.yml
  :language: yaml

Create a file called ``echoserver-ingress.yml`` with the above contents,
and run the following command to apply the manifest.

.. code-block:: bash

  kubectl apply -f echoserver-ingress.yml

Wait for an IP address to be assigned to the Ingress.

This should be quick, as the Catalyst Cloud load balancer
and IP address are allocated when the Ingress Controller is created.

.. code-block:: console

  $ kubectl get ingress --watch
  NAME        HOSTS              ADDRESS         PORTS   AGE
  echoserver  example.com        192.0.2.1       80      45s

Once the publically accessible IP address has been assigned,
send a request to the ``/ping`` endpoint using the following command
(substituting ``192.0.2.1`` for the IP address of your echoserver).

.. code-block:: bash

  curl http://example.com/ping --resolve example.com:80:192.0.2.1

If everything is working correctly, you should see something similar to
the following output:

.. code-block:: console

  $ curl http://example.com/ping --resolve example.com:80:192.0.2.1


  Hostname: echoserver-6c456d4fcc-hmqts

  Pod Information:
    -no pod information available-

  Server values:
    server_version=nginx: 1.14.2 - lua: 10015

  Request Information:
    client_address=172.18.62.205
    method=GET
    real path=/ping
    query=
    request_version=1.1
    request_scheme=http
    request_uri=http://example.com:8080/ping

  Request Headers:
    accept=*/*
    host=example.com
    user-agent=curl/7.68.0
    x-forwarded-for=10.0.0.11
    x-forwarded-host=example.com
    x-forwarded-port=80
    x-forwarded-proto=http
    x-forwarded-scheme=http
    x-real-ip=10.0.0.11
    x-request-id=a87ccdf5c8c858df1ab2b8bc980fb881
    x-scheme=http

  Request Body:
    -no body in request-

.. _kubernetes-ingress-nginx-tls:

Ingress with TLS support
========================

The Ingress we created in the previous section only allowed
unencrypted HTTP traffic to our application.
In the majority of cases you want traffic to be encrypted via HTTPS.

So let's reconfigure our Ingress to enable HTTPS.
The extra steps involved are:

* Creating a self-signed SSL certificate.
* Creating a Kubernetes secret to hold the certificate.
* Adding a new set of ingress rules to enable HTTPS on port 443,
  and load the SSL certificate from the Kubernetes secret.

The first step is to create a self-signed certificate and private key
to configure the Ingress with.

.. code-block:: bash

  openssl req -x509 \
              -sha256 \
              -nodes \
              -days 365 \
              -newkey rsa:4096 \
              -keyout tls.key \
              -out tls.crt \
              -subj "/CN=example.com/O=Integration"

The SSL certificate will be saved to ``tls.crt``, and the private key to ``tls.key``.

.. note::

  For production use, you will need to use a trusted certificate authority (CA)
  to get your SSL certificate signed.

  Once your SSL certificate has been signed, you can follow the instructions
  below to configure your Ingress, substituting ``tls.crt`` for the certificate
  file name, and ``tls.key`` for the private key file.

Next we will create a TLS secret using the certificates created in the
previous step.

.. code-block:: bash

  kubectl create secret tls example-com-https --key tls.key --cert tls.crt

Additionally, label the secret so it will be easier to cleanup once we're done:

.. code-block:: bash

  kubectl label secret example-com-https group=example-com

Now create a new manifest called ``echoserver-ingress-https.yml``
with the below contents.

This will reconfigure our ``echoserver`` Ingress to accept traffic on HTTPS
on port 443, and redirect all unencrypted HTTP traffic on port 80 to HTTPS instead.

.. literalinclude:: _containers_assets/echoserver-ingress-https.yml
  :language: yaml

Run the following command to apply our changes:

.. code-block:: bash

  kubectl apply -f echoserver-ingress-https.yml

The existing Ingress will be reconfigured in-place.

.. code-block:: console

  $ kubectl apply -f echoserver-ingress-https.yml
  ingress.networking.k8s.io/echoserver configured

The ``echoserver`` Ingress should now be accepting traffic on both port 80 and 443.

.. code-block:: console

  $ kubectl get ingress
  NAME         CLASS   HOSTS         ADDRESS      PORTS     AGE
  echoserver   nginx   example.com   192.0.2.1    80, 443   41m

To make sure everything is working correctly, send a request
to the ``/ping`` endpoint using HTTPS via the following ``curl`` command
(substituting ``192.0.2.1`` for the public IP address of your application).

.. code-block:: bash

  curl -vk https://example.com/ping --resolve example.com:443:192.0.2.1

If everything is working correctly, you should see something similar to
the following output.

We can see that the TLS handshake is completed successfully
with the correct CN (``example.com``), and the echoserver
homepage is returned by the application.

.. code-block:: console

  $ curl -vk https://example.com/ping --resolve example.com:443:192.0.2.1
  * Added example.com:443:192.0.2.1 to DNS cache
  * Hostname example.com was found in DNS cache
  *   Trying 192.0.2.1:443...
  * TCP_NODELAY set
  * Connected to example.com (192.0.2.1) port 443 (#0)
  * ALPN, offering h2
  * ALPN, offering http/1.1
  * successfully set certificate verify locations:
  *   CAfile: /etc/ssl/certs/ca-certificates.crt
    CApath: /etc/ssl/certs
  * TLSv1.3 (OUT), TLS handshake, Client hello (1):
  * TLSv1.3 (IN), TLS handshake, Server hello (2):
  * TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
  * TLSv1.3 (IN), TLS handshake, Certificate (11):
  * TLSv1.3 (IN), TLS handshake, CERT verify (15):
  * TLSv1.3 (IN), TLS handshake, Finished (20):
  * TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
  * TLSv1.3 (OUT), TLS handshake, Finished (20):
  * SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
  * ALPN, server accepted to use h2
  * Server certificate:
  *  subject: CN=example.com; O=Integration
  *  start date: Apr 16 23:33:11 2024 GMT
  *  expire date: Apr 16 23:33:11 2025 GMT
  *  issuer: CN=example.com; O=Integration
  *  SSL certificate verify result: self signed certificate (18), continuing anyway.
  * Using HTTP2, server supports multi-use
  * Connection state changed (HTTP/2 confirmed)
  * Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
  * Using Stream ID: 1 (easy handle 0x5593baec7340)
  > GET /ping HTTP/2
  > Host: example.com
  > user-agent: curl/7.68.0
  > accept: */*
  >
  * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
  * TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
  * old SSL session ID is stale, removing
  * Connection state changed (MAX_CONCURRENT_STREAMS == 128)!
  < HTTP/2 200
  < date: Tue, 16 Apr 2024 23:48:24 GMT
  < content-type: text/plain
  < strict-transport-security: max-age=31536000; includeSubDomains
  <


  Hostname: echoserver-6c456d4fcc-hmqts

  Pod Information:
    -no pod information available-

  Server values:
    server_version=nginx: 1.14.2 - lua: 10015

  Request Information:
    client_address=172.18.62.205
    method=GET
    real path=/ping
    query=
    request_version=1.1
    request_scheme=http
    request_uri=http://example.com:8080/ping

  Request Headers:
    accept=*/*
    host=example.com
    user-agent=curl/7.68.0
    x-forwarded-for=10.0.0.11
    x-forwarded-host=example.com
    x-forwarded-port=443
    x-forwarded-proto=https
    x-forwarded-scheme=https
    x-real-ip=10.0.0.11
    x-request-id=89005bafa033a3005d00ab70860c6001
    x-scheme=https

  Request Body:
    -no body in request-

  * Connection #0 to host example.com left intact

We can also test whether or not redirection of unencrypted HTTP traffic is working.

Run the following ``curl`` to send a request to the unencrypted endpoint.

.. code-block:: bash

  curl -vk http://example.com/ping --resolve example.com:80:192.0.2.1

This time, a ``308 Permanent Redirect`` response directing the client
to the HTTPS endpoint should be returned.

.. code-block:: console

  $ curl -vk http://example.com/ping --resolve example.com:80:192.0.2.1
  * Added example.com:80:192.0.2.1 to DNS cache
  * Hostname example.com was found in DNS cache
  *   Trying 192.0.2.1:80...
  * TCP_NODELAY set
  * Connected to example.com (192.0.2.1) port 80 (#0)
  > GET /ping HTTP/1.1
  > Host: example.com
  > User-Agent: curl/7.68.0
  > Accept: */*
  >
  * Mark bundle as not supporting multiuse
  < HTTP/1.1 308 Permanent Redirect
  < Date: Tue, 16 Apr 2024 23:50:26 GMT
  < Content-Type: text/html
  < Content-Length: 164
  < Connection: keep-alive
  < Location: https://example.com/ping
  <
  <html>
  <head><title>308 Permanent Redirect</title></head>
  <body>
  <center><h1>308 Permanent Redirect</h1></center>
  <hr><center>nginx</center>
  </body>
  </html>
  * Connection #0 to host example.com left intact

.. _kubernetes-ingress-nginx-proxy:

Ingress using the ``PROXY`` protocol
====================================

One downside of the standard Ingress Controller configuration is
that the IP address of the client is not passed through to the application.

In the ``curl`` output, we can see that the ``X-Forwarded-For`` and ``X-Real-IP``
headers contain the internal IP address of the load balancer, **not** the client.

.. code-block:: text
  :emphasize-lines: 5,10

  Request Headers:
    accept=*/*
    host=example.com
    user-agent=curl/7.68.0
    x-forwarded-for=10.0.0.11
    x-forwarded-host=example.com
    x-forwarded-port=443
    x-forwarded-proto=https
    x-forwarded-scheme=https
    x-real-ip=10.0.0.11
    x-request-id=89005bafa033a3005d00ab70860c6001
    x-scheme=https

To resolve this, we can reconfigure the Ingress Controller to use the ``PROXY`` protocol.

The ``PROXY`` protocol is a network protocol for preserving a client's IP address
when the client's TCP connection passes through a proxy or load balancer.
This protocol is supported by both Catalyst Cloud Load Balancer as a Service
and the Ingress-Nginx Ingress Controller, allowing us to use it to ensure
the client's IP address gets passed through to the application.

To setup our Ingress Controller, we must set the following controller options
for the Helm chart:

* ``use-proxy-protocol`` - Set to ``true`` to enable the ``PROXY`` protocol
  on the Ingress Controller.
* ``use-forwarded-headers`` - Set to ``true`` to make Nginx pass through
  ``X-Forwarded-*`` headers to the backend application.
* ``compute-full-forwarded-for`` - Set to ``true`` to append the remote address
  to the ``X-Forwarded-For`` header, instead of completely replacing it.

  * This may or may not need to be enabled, depending on what your application supports.

For more information on how to customise a Helm chart, refer to
`Customizing the Chart Before Installing`_ in the Helm documentation.

.. _`Customizing the Chart Before Installing`: https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing

In addition to the above, we need to set the following
:ref:`Load Balancer Annotations <kubernetes-loadbalancer-annotations>`
to configure the Kubernetes Load Balancer:

* ``loadbalancer.openstack.org/proxy-protocol`` - Set to ``true`` to create
  a ``PROXY`` load balancer on Catalyst Cloud.

The final Helm controller configuration looks like this:

.. literalinclude:: _containers_assets/ingress-nginx-proxy-config.yml
  :language: yaml

Save this file as ``ingress-nginx-proxy-config.yml``, and run the following command to apply
our changes to the Ingress Controller.

.. code-block:: bash

  helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace --values ingress-nginx-proxy-config.yml

The existing Ingress Controller should have been modified with our changes.

.. code-block:: console

  $ helm status -n ingress-nginx ingress-nginx
  NAME: ingress-nginx
  LAST DEPLOYED: Wed Apr 17 15:53:00 2024
  NAMESPACE: ingress-nginx
  STATUS: deployed
  REVISION: 2
  TEST SUITE: None
  NOTES:
  The ingress-nginx controller has been installed.
  It may take a few minutes for the load balancer IP to be available.
  You can watch the status by running 'kubectl get service --namespace ingress-nginx ingress-nginx-controller --output wide --watch'

  An example Ingress that makes use of the controller:
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: example
      namespace: foo
    spec:
      ingressClassName: nginx
      rules:
        - host: www.example.com
          http:
            paths:
              - pathType: Prefix
                backend:
                  service:
                    name: exampleService
                    port:
                      number: 80
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
  $ kubectl get service --namespace ingress-nginx ingress-nginx-controller
  NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
  ingress-nginx-controller   LoadBalancer   172.24.53.166   192.0.2.1     80:32014/TCP,443:30489/TCP   5h22m

We're now ready to check our application one more time.
Run the following command to query the echoserver
(substituting ``192.0.2.1`` for your deployment's IP address):

.. code-block:: console
  :emphasize-lines: 25,30

  $ curl -k https://example.com/ping --resolve example.com:443:192.0.2.1


  Hostname: echoserver-6c456d4fcc-hmqts

  Pod Information:
    -no pod information available-

  Server values:
    server_version=nginx: 1.14.2 - lua: 10015

  Request Information:
    client_address=172.18.62.205
    method=GET
    real path=/ping
    query=
    request_version=1.1
    request_scheme=http
    request_uri=http://example.com:8080/ping

  Request Headers:
    accept=*/*
    host=example.com
    user-agent=curl/7.68.0
    x-forwarded-for=198.51.100.1
    x-forwarded-host=example.com
    x-forwarded-port=443
    x-forwarded-proto=https
    x-forwarded-scheme=https
    x-real-ip=198.51.100.1
    x-request-id=719dc3d46ee1f04edb861caf03c59a70
    x-scheme=https

  Request Body:
    -no body in request-

If ``X-Forwarded-For`` and ``X-Real-IP`` are correct
(they are set to your local network's public IP address),
then your application now has access to the original client IP address.

Cleanup
=======

And that's it!

To clean up all of the resources created in the Kubernetes cluster in these demos,
simply run the following commands.

.. code-block:: bash

  kubectl delete ingress echoserver
  kubectl delete service echoserver
  kubectl delete secret echoserver-https
  kubectl delete deployment echoserver
  helm delete ingress-nginx
  kubectl delete namespace ingress-nginx
