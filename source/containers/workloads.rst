.. _kubernetes-workloads:

#########
Workloads
#########

The declarative model and the desired state
===========================================
This is the underlying concept of how Kubernetes does what it does. The ``declarative model`` is
where we provide Kubernetes with a YAML or JSON **manifest file**, via the API server, that
declares the only desired state for the application to be deployed and not how to do it.

Once the manifest has been received, it is stored in the cluster store as a record of the
application's ``desired state``, and then the application is deployed to the cluster.

The final piece of this is the creation of background watch loops that are responsible for
monitoring the state of the cluster on a constant basis looking for any variations that differ
from the desired state.

Pods
====

The pod is the basic building block inside a Kubernetes cluster. It is the smallest, simplest
unit in the Kubernetes object model that can be created or deployed. It's purpose is to
encapsulate an application container or containers along with storage resources, networking and
configuration that governs how the container(s) should run.

The most common container runtime, and the one that is used on the Catalyst Cloud, is ``Docker``
but others, such as rkt, are also available.

Pods typically contains a single container but there are cases where several tightly coupled
containers may be deployed in the same pod. The pod provides a **shared execution environment**
which means that all containers running within the pod share all of it's resources, such as
memory, IP address, hostname and volumes to name a few. This is achieved through the use of
**namespaces**.

A pod usually represents a single instance of an application.

Pod networks
------------
Each pod is given a unique IP address that can be used to communicate with it. The containers
within a pod use a shared network namespace that they can all access via ``localhost``, they use
this to communicate with each other. To communicate outside of the pod they utilise the shared
network resources in a coordinated fashion, here a is a link to a more in depth discussion on
`pod networking`_


.. _`pod networking`: https://medium.com/google-cloud/understanding-kubernetes-networking-pods-7117dd28727

Pod storage
-----------

The container file system is ephemeral, meaning it only lives as long as the container does.
If your application needs it's running state to survive events such as reboots, and crashes, it
will require some kind of persistent storage. Another limitation of the on-disk container storage
is that it is tied to the individual container it does not provide any means to share data between
containers.

A Pod, however, is capable of utilising a Kubernetes ``volume``, which is an abstraction that
solves both of the issues mentioned above. Kubernetes volumes have an explicit lifetime which the
same as the Pod that hosts it. As a result volumes outlive any Containers that run within the Pod,
and data is preserved across Container restarts. When the pod ceases to exist the volume will
disappear as well.

To use a volume, a Pod specifies what volumes to provide for the Pod via the .spec.volumes field
and where to mount those into containers with the .spec.containers.volumeMounts field.

TODO: This will be covered in more detail in the examples


Persistent Volume Claims
------------------------
TODO: describe PVC usage



Controllers
===========
If a pod is created directly and fails to deploy or crashes it will not get rescheduled. To
overcome this problem it is possible to make use of a higher level of abstraction provided by
Kubernetes called ``controllers``.

These controllers represent different types of usage scenarios. The image below shows a
simplified Kubernetes setup with a controller managing copies of pods, for a specific application
scenario, across multiple nodes.

This means that you don’t need to be responsible for managing pod creation manually as Controller
can create and manage multiple Pods for you, taking care of such tasks as replication, rollout and
providing self-healing capabilities.

.. image:: _containers_assets/simple_k8s.jpg


Controller types
----------------
The following controller types are the most commonly used of those that are currently available in
Kubernetes.  Each caters to a slightly different ```application pattern``` as illustrated below.

* Deployment

  - **Stateless Pattern**, when you don’t need to keep state (persistent data) in your workloads

* StatefulSet

  - **Stateful Pattern**, if some of your applications need to store data, as is the case for
    databases or message queues

* DaemonSet

  - **aemon Pattern**, you want to run daemon-like workloads such as log collection or monitoring
    daemons

* Job

  - **Batch Pattern**, for running batch processing workloads.
