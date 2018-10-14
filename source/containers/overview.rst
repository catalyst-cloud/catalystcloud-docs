########
Overview
########

What is a container?
====================
Linux containers are self-contained execution environments with their own,
isolated CPU, memory, block I/O, and network resources that share the kernel of
the host operating system. The result is something that feels like a virtual
machine, but sheds all the weight and startup overhead of a guest operating
system. You can link containers together, set security policies, limit resource utilisation and
more.

The Container Orchestration Engine
==================================
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

Catalyst Cloud currently only offers ``Kubernetes`` so we will focus on that as our default
container orchestration engine (COE).

Kubernetes on Catalyst Cloud
============================
Catalyst Cloud is now providing a `certified Kubernetes`_ container service which has been
approved by the Cloud Native Computing Foundation (`CNCF`_).

.. Note::

  The Catalyst Cloud Kubernetes Service is currently a **Technical (Alpha) Preview**. As such it is
  possible that failures will be encountered as we move towards our production ready state.

.. _`CNCF`: https://www.cncf.io
.. _`certified Kubernetes`: https://www.cncf.io/certification/kcsp/

Identifying and Reporting Issues
--------------------------------
If you encounter issues while deploying a cluster please raise a ticket via the Support Panel and
provide the output from the following command to assist our support team in helping you resolve
your issues.

.. code-block:: bash

  $ openstack coe cluster show <cluster_name>
