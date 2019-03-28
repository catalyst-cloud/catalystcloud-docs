############################
Cluster access with Services
############################

*********************
Ingress in Kubernetes
*********************

Kubernetes ingress is a collection of strategies that provide ways by which to
define how access to services running in a cluster is achieved.

Though they all work slightly differently, typically they are implemented as a
service that provides a mapping to a given port or ports that are exposed on
pods or nodes within the cluster and associated with an IP address.

The only real exception to this approach is the ingress controller.


What are the various service types
==================================

* The ``ClusterIP`` is the default Kubernetes service type. It provides access
  to an application's services via an internal cluster IP address that is
  reachable by all other nodes within the cluster. It is not accessible
  from outside of the cluster.
* The ``NodePort`` service is the simplest way to get external access to an
  application's service endpoint within a cluster. This approach opens an
  identical port, typically in the range 30000–32767, across all Nodes in the
  cluster and associates this with an IP address and port. Any traffic that is
  then directed to this port is forwarded on to the application's service.
* A ``LoadBalancer`` is the typical way to expose an application to the
  internet. It relies on the cloud provide to create an external load balancer
  with an IP address in the relevant network space. Any traffic that is then
  directed to this IP address is forwarded on to the application's service.
* An ``Ingress controller`` differs from the previous options in that it is
  not implemented as a Kubernetes service and instead behaves in a manner
  similar to a router that can make rule based routing decisions about which
  service to deliver traffic to.


*******************************
Using the various service types
*******************************

The following sections will explain the various types of service currently
supported and where these might typically be used.

Before looking further at the types of ingress available to us lets create a
simple 1 replica Nginx application based on the default Nginx image. This will
spin up the default Nginx container that will listen, by default, on port 80.

.. literalinclude:: _containers_assets/nginx-app.yaml

Next we will connect to the Nginx pod and install curl so that we can utilise
it to test connectivity in our upcoming examples.

.. code-block:: bash

  $ kubectl get pods
  NAME                              READY   STATUS    RESTARTS   AGE
  nginx-test-app-65b8cd96c4-kqtlm   1/1     Running   0          11m

  $ kubectl exec -it nginx-test-app-65b8cd96c4-kqtlm  /bin/bash
  root@nginx-test-app-65b8cd96c4-kqtlm:/# apt update && apt install -y curl

  <output truncated for brevity>

  root@nginx-test-app-65b8cd96c4-kqtlm:/# exit


*********
ClusterIP
*********

First we will define a service using the ClusterIP type. This service
will expose port 80 on the pod by mapping it to port 80 on the cluster IP that
will get assigned to the service when it is created.

.. literalinclude:: _containers_assets/clusterip.yaml

If we now use kubectl to query the available services we can see that
there is a service called **clusterip-service** that exposes port 80 on the
cluster IP address 10.12.147.210.

.. code-block:: bash

  $ kubectl get service clusterip-service
  NAME                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)
  clusterip-service   ClusterIP   10.12.147.210   none          80/TCP

Now we can connect back into our pod and run curl to query this.

.. code-block:: bash

  $ kubectl exec -it nginx-test-app-65b8cd96c4-kqtlm curl 10.12.147.210:80
  <!DOCTYPE html>
  <html>
  <head>
  <title>Welcome to nginx!</title>
  <style>
    <!-- output truncated for brevity -->
  </style>
  </head>
  <body>
  <h1>Welcome to nginx!</h1>
  <p>If you see this page, the nginx web server is successfully installed and
  working. Further configuration is required.</p>
    <!-- output truncated for brevity -->
  <p><em>Thank you for using nginx.</em></p>
  </body>
  </html>

If all went as expected we should see the html for the default Nginx welcome
page.

As mentioned earlier ``this type of service is only accessible inside the
cluster``, in order to expose it outside of the cluster we will need to look at
our other access options.

To remove the clusterip-service run the following.

.. code-block:: bash

  $ kubectl delete service clusterip-service


********
NodePort
********

A NodePort, as the name implies, works by opening a port on every node of the
cluster where the application in question is running. The associated service
that Kubernetes creates as part of this is then responsible for routing
incoming traffic intended for that service to that NodePort.

The following example shows how to assign a NodePort to our existing nginx-app
pod that we created earlier.

.. literalinclude:: _containers_assets/nodeport.yaml

If we query our available services now we should see a new entry for our
**nodeport-service**

.. code-block:: bash

  $ kubectl get service nodeport-service
  NAME               TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
  nodeport-service   NodePort   10.254.141.196   <none>        80:30001/TCP   5s

There are several ways in which we can now access our Nginx application. The
first is via the cluster IP as in the previous example. Though the same
restriction still applies here in that this will only work from within the
cluster.

.. code-block:: bash

  $ kubectl exec -it nginx-test-app-65b8cd96c4-kqtlm curl 10.254.141.196:80
    <!-- output truncated for brevity -->
  <h1>Welcome to nginx!</h1>
    <!-- output truncated for brevity -->

To access the cluster from outside we will first need to find the addresses
that have been associated with the Node itself.

.. code-block:: bash

  $ kubectl get pod nginx-test-app-65b8cd96c4-kqtlm -o wide
  NAME                              READY   STATUS    RESTARTS   AGE   IP              NODE                              NOMINATED NODE
  nginx-test-app-65b8cd96c4-kqtlm   1/1     Running   0          64m   192.168.158.2   k8s-m3-n3-4elkr4e46fng-minion-0   <none>

  $ kubectl describe node k8s-m3-n3-4elkr4e46fng-minion-0 | grep IP
  InternalIP:  10.0.0.15
  ExternalIP:  202.49.241.87

In this particular example we can see that our node has both an internal and an
external IP address. This means that we could browse directly to
http://202.49.241.87:30001 from the internet (assuming the cluster has
appropriate inbound access enabled).

Alternatively this could also be accessed by any other server instance that was
deployed on the 10.0.0.0/24 host network that had appropriate security group
access.

For example if we have another instance that is attached to that network on
10.0.0.16 and both it and the node running the Nginx application belong to a
security group that allows access to TCP/30001 then the following will be
possible.

.. code-block:: bash

  $ ssh ubuntu@k8s-bastion
  ubuntu@k8s-bastion:~$ curl 10.0.0.15:30001
    <!-- output truncated for brevity -->
  <h1>Welcome to nginx!</h1>
    <!-- output truncated for brevity -->


This provides a handy way to give access to non-production clusters where it is
not necessarily desirable to use publicly addressable IP addresses either
because of cost or availability. The only downside of this approach  is that
standard services such as HTTP and HTTPS end up being exposed on a non-standard
ports

Typically the NodePort type tends to be used as an abstraction for use with
higher-level ingress types such as the loadbalancer.

************
LoadBalancer
************

Using a LoadBalancer service type automatically deploys an external load
balancer. The exact implementation of this will be dependent on the cloud
provider that you are using.

For most scenarios of a production nature this would be the most
straightforward approach to take.

To provide our Nginx application with an internet facing loadbalancer we can
simply run the following.

.. literalinclude:: _containers_assets/loadbalancer.yaml

Check the state the status of the loadbalanced-service until the EXTERNAL-IP
status is no longer <pending>.

.. code-block:: bash

  $ kubectl get service loadbalanced-service
  NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)        AGE
  loadbalanced-service   LoadBalancer   10.254.28.183   202.49.242.3   80:31177/TCP   2m18s

Once we can see that our service is active and has been assigned an external IP
address we should be able to retrive the "Welcome Page" via the browser or
simply via curl from any internet accessible machine.

.. code-block:: bash

  $ curl 202.49.242.3
    <!-- output truncated for brevity -->
  <h1>Welcome to nginx!</h1>
    <!-- output truncated for brevity -->

For a more complete example that shows connections being load balanced between
many identical application pods take a look at :ref:`simple_lb_deployment`


********************************
Modifying loadbalancer behaviour
********************************

While the default behaviour of the loadbalancer service may be fine for a large
majority of typical use cases, there are times when this behaviour will need to
be modified to suit a particular scenario.

Some examples of where this might be applicable include such things as:

* being able to retain the floating IP used for the VIP.
* creating a loadbalancer that does not have an IP address assigned from the
  public address pool.
* The ability to assign which network, subnet or port the loadbalancer will use
  for it's VIP address.

Fortunately Kubernetes supplies a means to achieve these desired changes in
behaviour through the use of ``annotations``.

Using Internal IP only
======================

Although, by default, the loadbalancer is created with an externally
addressable public IP address it is possible to use a local IP address instead
with the following annotation.

.. code-block:: bash

  annotations:
    service.beta.kubernetes.io/openstack-internal-load-balancer: "true"

A simple example would look like this.

.. literalinclude:: _containers_assets/loadbalancer_internal_ip.yaml

The resulting loadbalancer would be provisioned with a VIP from the existing
Kubernetes host network.

If we examine the node we can see that it's internal network address is in the
10.0.0.0/24 subnet and a simple query of the the new service shows that it too
has now been assigned an addressfrom this same range as it's VIP.

.. code-block:: bash

  $ kubectl describe nodes k8s-m3-n3-4elkr4e46fng-minion-0 | grep InternalIP
  InternalIP:  10.0.0.15

  $ kubectl get svc lb-internal-ip
  NAME             TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
  lb-internal-ip   LoadBalancer   10.254.229.121   10.0.0.38     80:32500/TCP   138m
