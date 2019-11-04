########
Overview
########

**********
Containers
**********

Linux containers are self-contained execution environments with their own,
isolated CPU, memory, block I/O, and network resources that share the kernel of
the host operating system. The result is something that feels like a virtual
machine, but sheds all the weight and startup overhead of a guest operating
system. You can link containers together, set security policies, limit resource
utilisation and more.

`Docker`_ is a tool designed to make it easier to create, deploy, and run Linux
containers. The Kubernetes service offered by the Catalyst Cloud supports
Docker container format.

.. _`Docker`: https://www.docker.com/


******************************
Container Orchestration Engine
******************************

Container Orchestration refers to the automated arrangement, coordination, and
management of software containers.

The process of deploying multiple containers to implement an application can be
optimized through automation. This becomes more and more valuable as the number
of containers and hosts grow. This type of automation is referred to as
orchestration. Orchestration can include a number of features, including:

* Provisioning cluster hosts.
* Instantiating a set of containers.
* Rescheduling failed containers.
* Linking containers together through agreed interfaces.
* Exposing services outside of the cluster.
* Scaling the cluster by adding or removing containers.

`Kubernetes`_ (or k8s) is an open-source container orchestration system (COE)
for automating deployment, scaling, and management of containerised
applications. It became the de-facto COE standard in the industry.

.. _`Kubernetes`: https://kubernetes.io/
