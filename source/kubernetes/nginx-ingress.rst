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

What is an Ingress Controller?
==============================

In Kubernetes, Ingress allows external users and client applications access
to HTTP services. Ingress consists of two components.

Ingress Resource is a collection of rules for the inbound traffic to reach
Services. These are Layer 7 (L7) rules that allow hostnames (and optionally
paths) to be directed to specific Services in Kubernetes.

Ingress Controller which acts upon the rules set by the Ingress Resource,
typically via an HTTP or L7 load balancer. It is vital that both pieces are
properly configured to route traffic from an outside client to a Kubernetes
Service.

Some working examples
---------------------

In order to use the Nginx ingress controller we first need to  install it into
our cluster. While this can be done by hand creating all of the required
deployments, services and roles it is far simpler to use the Helm nginx-ingress
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

Once Helm is installed we need to ensure  it will work correctly. As the
Catalyst Cloud does make use of RBAC access controls within it's clusters we
need to also ensure that there is a correctly configured service account in our
cluster for ``tiller``. The following YAML will create this account and ensure
that it has the correct RBAC roles to perform the necessary actions on behalf
of Helm.

.. code-block:: bash

  cat <<EOF | kubectl apply -f -
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: tiller
    namespace: kube-system
  ---
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRoleBinding
  metadata:
    name: tiller
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: cluster-admin
  subjects:
    - kind: ServiceAccount
      name: tiller
      namespace: kube-system
  EOF

Now that we have the service account in place we can initialise Helm.

.. code-block:: bash

  $ helm init --service-account tiller --history-max 200

.. code-block:: bash

  $ kubectl -n kube-system get pods


*************************
Simple ingress with Nginx
*************************

For the first example we will create a straight forward HTTP ingress controller
that will direct traffic to a backend pod that will simply echo back details
of the pod, the request and the associated headers it recieved.

.. code-block:: bash

  $ kubectl run echoserver --image=gcr.io/google-containers/echoserver:1.10 --port=8080 --expose
  kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
  service/echoserver created
  deployment.apps/echoserver created

  $ kubectl get pod,service
  kubectl get pod,service
  NAME                              READY   STATUS    RESTARTS   AGE
  pod/echoserver-7cc8b87c6f-h8ls5   1/1     Running   0          34m

  NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
  service/echoserver   ClusterIP   10.254.58.23   <none>        8080/TCP   34m
  service/kubernetes   ClusterIP   10.254.0.1     <none>        443/TCP    41d

Now we need to define the basic configuration for the ingress controller.

.. code-block:: bash

  cat <<EOF > nginx-ingress-controller-helm-values.yaml
  controller:
      publishService:
          enabled: true
  EOF

Now create the nginx ingress controller using the helm chart.

.. code-block:: bash

  $ helm install stable/nginx-ingress --name nginx-ingress -f nginx-ingress-controller-helm-values.yaml

  NAME:   nginx-ingress
  LAST DEPLOYED: Wed Aug  7 13:55:09 2019
  NAMESPACE: default
  STATUS: DEPLOYED

  RESOURCES:
  ==> v1/Pod(related)
  NAME                                            READY  STATUS             RESTARTS  AGE
  nginx-ingress-controller-9d9ccb6f8-c8jsl        0/1    ContainerCreating  0         1s
  nginx-ingress-default-backend-7d5dd85c4c-wrzzq  0/1    ContainerCreating  0         1s

  ==> v1/Service
  NAME                           TYPE          CLUSTER-IP     EXTERNAL-IP  PORT(S)                     AGE
  nginx-ingress-controller       LoadBalancer  10.254.49.193  <pending>    80:31227/TCP,443:31316/TCP  1s
  nginx-ingress-default-backend  ClusterIP     10.254.94.54   <none>       80/TCP                      1s

  ==> v1/ServiceAccount
  NAME           SECRETS  AGE
  nginx-ingress  1        1s

  ==> v1beta1/ClusterRole
  NAME           AGE
  nginx-ingress  1s

  ==> v1beta1/ClusterRoleBinding
  NAME           AGE
  nginx-ingress  1s

  ==> v1beta1/Deployment
  NAME                           READY  UP-TO-DATE  AVAILABLE  AGE
  nginx-ingress-controller       0/1    1           0          1s
  nginx-ingress-default-backend  0/1    1           0          1s

  ==> v1beta1/Role
  NAME           AGE
  nginx-ingress  1s

  ==> v1beta1/RoleBinding
  NAME           AGE
  nginx-ingress  1s


  NOTES:
  The nginx-ingress controller has been installed.
  It may take a few minutes for the LoadBalancer IP to be available.
  You can watch the status by running 'kubectl --namespace default get services -o wide -w nginx-ingress-controller'

  An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
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


Now we need to wait until the service gets an external IP address

.. code-block:: bash

  $ kubectl get service
  NAME                            TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                      AGE
  echoserver                      ClusterIP      10.254.58.23     <none>           8080/TCP                     49m
  kubernetes                      ClusterIP      10.254.0.1       <none>           443/TCP                      41d
  nginx-ingress-controller        LoadBalancer   10.254.204.209   202.49.241.135   80:30722/TCP,443:30897/TCP   2m32s
  nginx-ingress-default-backend   ClusterIP      10.254.68.138    <none>           80/TCP

  $ openstack loadbalancer list | grep nginx
  | 09d21949-528f-4afa-a1fb-9441b4555670 | kube_service_ea0613ef-4b48-4b22-b39a-cfb146c81c8a_default_nginx-ingress-controller | eac679e4896146e6827ce29d755fe289 | 10.0.0.16   | ACTIVE              | octavia  |

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
              serviceName: echoserver
              servicePort: 8080
            path: /ping
  EOF

Wait for IP address to be allocated

.. code-block:: bash

  $ kubectl get ingress -w

  NAME        HOSTS              ADDRESS          PORTS   AGE
  test-http   test.example.com   202.49.241.135   80      107s

Send a request to the /ping URL on the client IP address seen on the echo
service

.. code-block:: bash

  $ ip=202.49.241.135
  $ curl -H "Host:test.example.com" http://$ip/ping

  Hostname: echoserver-7cc8b87c6f-h8ls5

  Pod Information:
    -no pod information available-

  Server values:
    server_version=nginx: 1.13.3 - lua: 10008

  Request Information:
    client_address=192.168.73.66
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
    x-forwarded-for=10.0.0.14
    x-forwarded-host=test.example.com
    x-forwarded-port=80
    x-forwarded-proto=http
    x-original-uri=/ping
    x-real-ip=10.0.0.14
    x-request-id=157496f47a599ef1b2754eb910fa6b6c
    x-scheme=http

  Request Body:
    -no body in request-

Cleanup
=======

Before moving on to the next example let's clean up the resources we created
in this example.

.. code-block:: bash

  $ kubectl delete ingress test-http
  $ helm delete --purge nginx-ingress

******************************
Nginx ingress with TLS support
******************************

In this example we will add TLS support to our previous example.

For simplicity we will use a self signed certificate. The following code will
create this for us.

.. code-block:: bash

  $ if [ ! -f ./certs/tls.key ]; then
    mkdir certs
    openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 \
        -keyout certs/tls.key \
        -out certs/tls.crt \
        -subj "/CN=test.example.com/O=Integration"
  fi

Next we will create a TLS secret based using the certificates created in the
previous step.

.. code-block:: bash

  $ kubectl create secret tls tls-secret-test-example-com --key certs/tls.key --cert certs/tls.crt

Label the secret so it's easier to delete later

.. code-block:: bash

  $ (kubectl get secret -l group=test-example-com 2>/dev/null | grep tls-secret-test-example-com) || kubectl label secret tls-secret-test-example-com group=test-example-com

As the helm config will remain the same as the previous example, we can go
ahead and deploy the ingress controller.

.. code-block:: bash

  $ helm install stable/nginx-ingress --name nginx-ingress -f nginx-ingress-controller-helm-values.yaml
  NAME:   nginx-ingress
  LAST DEPLOYED: Wed Aug 21 12:39:01 2019
  NAMESPACE: default
  STATUS: DEPLOYED

  <-- output truncated for brevity -->

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
                serviceName: echoserver
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
  Hostname: echoserver-7cc8b87c6f-h8ls5

  Pod Information:
    -no pod information available-

  Server values:
    server_version=nginx: 1.13.3 - lua: 10008

  Request Information:
    client_address=192.168.73.67
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
    x-forwarded-for=10.0.0.14
    x-forwarded-host=test.example.com
    x-forwarded-port=443
    x-forwarded-proto=https
    x-original-uri=/ping
    x-real-ip=10.0.0.14
    x-request-id=2e1fa5e968414311d47076cbc3c6dcc7
    x-scheme=https

  Request Body:
    -no body in request-

Cleanup
=======

Before moving on to the next example let's clean up the resources we created
in this example.

.. code-block:: bash

  $ kubectl delete ingress test-with-tls
  $ helm delete --purge nginx-ingress

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

Once the external IP is availale we can test it with curl as we have
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
  $ helm delete --purge nginx-ingress

