.. _services:

Services
========

When pods get deployed by a controller they gain the ability to be automatically replaced in the
cluster when they fail. The problem with this is that the newly created pods also get given a
new IP address. This is also the case when new pods are created due to actions such as scaling
applications taking place or performing tasks such as rolling updates.

Given that this is the case it means that we cannot rely on pod IPs for reliable network
communication between all of the elements within an application. That is where ``services`` come
to the rescue.

Services are a network abstraction that provides a reliable means of addressing networked
components within a cluster. For a given set of pods it provides a policy by which they can access
each other through the use of ``labels``. Services also provide a simple, randomised
load-balancing function and to the pods they manage.

If we go back to our original pod example (pod1.yaml).
.. literalinclude:: _containers_assets/pod1.yaml

We can add a very simple service to this to provide a more robust means to connect to it from
external sources. To do this create the file service1.yaml.

.. literalinclude:: _containers_assets/service1.yaml

As we saw in the pod configuration file, we use the same high level fields, apiVersion, kind,
metadata and spec, to define our service. The differences are that *kind* now specifies that the
resource we want to create is of the type **Service**. The metadata *name* is changed to give the
service it's own unique name, making it easier to identify.

The key changes though are the addition of the ``selector`` and ``type`` fields to the spec. The
*selector* ties the service to the pod, or as we will see in later examples the deployment, by
associating it with the pod or pods that have the same label. In this case the label is
**app: basic-pod**, which matches the label supplied when we created our pod.

The *type* of service that is defined determines the nature of the connectivity that will allowed
from external clients. The types are

- **ClusterIP** : Exposes the service on an internal IP that is only accessible from within the
  cluster. This is the default service type.
- **NodePort** : Creates a static port that exposes the individual Node IP addresses, the NodePort
  automatically routes to the cluster IP. Access is via <NodeIP>:<NodePort>
- **LoadBalancer** : Provides access via the Cloud service providers load balancer service.
- **ExternalName** : Maps the service to and external CNAME record with the specified value. This
  is an un-proxied connection.

In this example we are using the ``NodePort`` type. This is the most basic way to enable
external traffic to access your service, though it does have a limit of a single service per port.

//TODO add diagram of NodePort example

To test that we can now access our Nginx instance via this port we can simply run the following:

//TODO CC example of curling result from IP:nodeport

This approach has its downsides and as such would only really be useful for s demo app or where
cost is a big consideration. The more acceptable, standard approach would be to use the
``LoadBalancer`` type which we will cover in more details when we discuss
:ref:`Controllers <controllers>`
