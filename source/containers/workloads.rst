.. _kubernetes-workloads:

#########
Workloads
#########

Pods
====

The pod is the basic building block in Kubernetes. It is the smallest, simplest
unit in the Kubernetes object model that can be created or deployed.

It's purpose is to encapsulate an application container  or containers along
with storage resources, networking and configuration that governs how the
container(s) should run.

The most common container runtime that is used is Docker but others are
also supported.

Single container pods and multi-container pods
----------------------------------------------
The ``one-container-per-pod`` is a common use case where the pod acts as a
wrapper around the container and Kubernetes then manages the pod rather than
the container.

In the scenario where there is a requirement to have a more tightly coupled set
of containers that work together to provide a single service it may be
beneficial to co-locate them in the same pod. This also simplifies the sharing
of resources such as networking and storage. The pod is still serves to wrap
these containers and resources allowing them to be managed as a single entity.

Pod networks
------------
Each pod is given a unique IP address that can be used to communicate with it.
The containers within a pod use a shared network namespace that they can all
access via ``localhost``, they use this to commnicate with each other. To
communicate outside of the pod they utilise the shared network resources in a
coordinated fashion, here a is a link to a more in deth discussion on
`pod networking`_


.. _`pod networking`: https://medium.com/google-cloud/understanding-kubernetes-networking-pods-7117dd28727

Pod storage
-----------

A Pod can specify a set of shared storage volumes which all containers in the Pod can access which
allows those containers to share data. Volumes also allow persistent data in a Pod to
survive in case one of the containers within needs to be restarted.

On-disk files in a Container are ephemeral, which presents some problems for non-trivial
applications when running in Containers. First, when a Container crashes, kubelet will restart it,
but the files will be lost - the Container starts with a clean state. Second, when running
Containers together in a Pod it is often necessary to share files between those Containers.
The Kubernetes Volume abstraction solves both of these problems.


A Kubernetes volume, on the other hand, has an explicit lifetime - the same as the Pod that
encloses it. Consequently, a volume outlives any Containers that run within the Pod, and data is
preserved across Container restarts. Of course, when a Pod ceases to exist, the volume will cease
to exist, too. Perhaps more importantly than this, Kubernetes supports many types of volumes, and
a Pod can use any number of them simultaneously.

At its core, a volume is just a directory, possibly with some data in it, which is accessible to
the Containers in a Pod. How that directory comes to be, the medium that backs it, and the
contents of it are determined by the particular volume type used.

To use a volume, a Pod specifies what volumes to provide for the Pod (the .spec.volumes field)
and where to mount those into Containers (the .spec.containers.volumeMounts field).

A process in a container sees a filesystem view composed from their Docker image and volumes.
The Docker image is at the root of the filesystem hierarchy, and any volumes are mounted at
the specified paths within the image. Volumes can not mount onto other volumes or have hard
links to other volumes. Each Container in the Pod must independently specify where to mount each
volume.


Pods and Controllers
--------------------

A Controller can create and manage multiple Pods for you, handling replication and rollout and
providing self-healing capabilities at cluster scope. For example, if a Node fails, the Controller
might automatically replace the Pod by scheduling an identical replacement on a different Node.

Some examples of Controllers that contain one or more pods include:


Controllers
===========
Once you’ve declared your desired state through the Kubernetes API, the controllers work to make
the cluster’s current state match this desired state.

The standard controller processes are kube-controller-manager and cloud-controller-manager,

ReplicaSets
-----------


Deployments
-----------



Persistent Volume Claims
========================
