
.. _load-balancer-intro:

#############
Load balancer
#############

Load balancing is the action of taking front-end requests and distributing
these across a pool of back-end servers for processing based on a series of
rules. This can be extremely useful to you as a business as a load balancer
allows you to provide an highly available and resilient front end system to
your consumers. By having a loadbalancer watching over your compute instances,
you can ensure that the load is spread evenly between them, eliminating the
strains of high traffic, such as unexpected peaks in lag or potential downtime.

The load balancer service encapsulates the complexity of implementing a typical
load balancing solution into an easy to use cloud based service that natively
provides a multi-tenanted, highly scalable, and programmable alternative.

Table of Contents:

.. toctree::
  :maxdepth: 1

  load-balancer/overview
  load-balancer/layer-4
  load-balancer/layer-7
  load-balancer/health-monitor
  load-balancer/connection-draining
  load-balancer/access-control
  load-balancer/tls-termination
