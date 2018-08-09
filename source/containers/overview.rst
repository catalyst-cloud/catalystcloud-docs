########
Overview
########

What is a container?
====================
Linux containers are self-contained execution environments with their own,
isolated CPU, memory, block I/O, and network resources that share the kernel of
the host operating system. The result is something that feels like a virtual
machine, but sheds all the weight and startup overhead of a guest operating
system.

You can think of containers as lightweight, scaleable and isolated VMs in
which you run your applications. You can link containers together, set security
policies, limit resource utilisation and more.

The Container Orchestration Engine
==================================
Container Orchestration refers to the automated arrangement, coordination, and
management of software containers.

The process of deploying multiple containers to implement an application can be
optimized through automation. This becomes more and more valuable as the number
of containers and hosts grow. This type of automation is referred to as
orchestration. Orchestration can include a number of features, including:

* Provisioning hosts
* Instantiating a set of containers
* Rescheduling failed containers
* Linking containers together through agreed interfaces
* Exposing services to machines outside of the cluster
* Scaling the cluster by adding or removing containers

Catalyst Cloud currently only offers the Kubernetes so we will focus on
that as our default container orchestration engine (COE)
