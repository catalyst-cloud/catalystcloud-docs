########
Glossary
########

This page is a glossary of terms used throughout the documentation on Catalyst Cloud Kubernetes Service.

More Kubernetes specific terms can be found in the `Kubernetes Documentation glossary`_.

.. _`Kubernetes Documentation glossary`: https://kubernetes.io/docs/reference/glossary/?fundamental=true

**********
Containers
**********

Linux containers are processes that run within their own namespaces.
These can specify limits and slices of CPU, memory, block storage, and
network resources.
Containers share the kernel of the host operating system and may feel like a
virtual machine without the weight and startup overhead of a full guest
operating system.
Containers can share filesystems and namespaces on the same host, set security
policies, limit resource utilisation and more.

There are several tools used for running OCI compatible containers, including
`Docker`_ and `containerd`_. These make it easy to run and manage containers.

Catalyst Cloud Kubernetes Service runs on containerd and supports OCI
container registries including `Docker Hub`_, `GitHub Packages`_
and private OCI registries.

.. _`Docker`: https://www.docker.com
.. _`containerd`: https://containerd.io
.. _`Docker Hub`: https://hub.docker.com
.. _`GitHub Packages`: https://github.com/features/packages

************************************
Container Orchestration Engine (COE)
************************************

Container Orchestration Engine refers to the automated arrangement, coordination, and
management of software containers.

The process of deploying multiple containers to implement an application across
multiple hosts can be made easier through automation.
This becomes more valuable as the number of containers and hosts grow.
This type of automation is referred to as orchestration.
Orchestration can include a number of features, including:

* Provisioning cluster hosts.
* Instantiating a set of containers.
* Rescheduling failed containers to alternative nodes.
* Linking containers together through agreed interfaces.
* Exposing services outside of the cluster.
* Scaling the cluster by adding or removing containers or nodes.

`Kubernetes`_ (or K8s) is an open-source container orchestration system (COE)
for automating deployment, scaling, and management of containerised applications.
It has become the de-facto COE standard in the Cloud Native industry.

.. _`Kubernetes`: https://kubernetes.io/

******
Magnum
******

`OpenStack Magnum`_ is the software that provides the API and integration with
a number of OpenStack services to accept requests to create, update and delete
container orchestration engine (COE) clusters.

Catalyst Cloud uses this software along with a driver that interacts with `Cluster API`_
to provide the Managed Kubernetes service.

The terminology you see on the command line and the Catalyst Cloud dashboard
come from this software and isn't always the same as the Kubernetes project,
as Magnum is written to support several container orchestration engines (COEs).

.. _`OpenStack Magnum`: https://docs.openstack.org/magnum/latest/user/index.html
.. _`Cluster API`: https://cluster-api.sigs.k8s.io
