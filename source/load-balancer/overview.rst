########
Overview
########

***********
Terminology
***********

In order to get started we need to first define some terminology as it applies
to this service:

* The ``load balancer`` is a logical grouping of listeners on one or more
  virtual ip addresses (VIP).
* A ``listener`` is the listening endpoint of a load balanced service. It
  requires port and protocol information but not an IP address.
* The ``pool`` is associated with a listener and is responsible for grouping
  the members which receive the client requests forwarded by the listener.
* A ``member`` is a single server or service. It can only be associated with
  a single pool.
* As members may go offline it is possible to use ``health monitors`` to detect
  their state and divert traffic away from members that are not responding
  properly. Health monitors are associated with a pool.


*****************
High availability
*****************

The load balancer service is highly available by default. Two software load
balancer instances are clustered using VRRP, allowing them to fail-over
connections between the load balancers in around five seconds.


*************************
Load balancing algorithms
*************************

The following load balancing algorithms are available and can be used to decide
the behaviour of the load balancer:

* ``Round Robin`` The algorithm chooses the server sequentially in the list.
  Once it reaches the end of the server, the algorithm forwards the new request
  to the first server in the list.
* ``Source`` This algorithm selects the server based on the source IP address
  using the hash to connect it to the matching server.
* ``Least Connection`` algorithm This algorithm selects the server with the
  fewest active transactions and then forwards the user request to the back
  end.


******************
Layer 4 vs Layer 7
******************

Load balancers are typically grouped into two categories: Layer 4 or Layer 7,
which correspond to the layers of the `OSI model`_. The Layer 4 type act upon
data such as IP, TCP, UDP which are protocols found in the network and
transport layers whereas the Layer 7 type act upon requests that contain data
from application layer protocols such as HTTP.

.. _OSI model: https://en.wikipedia.org/wiki/OSI_model
.. _glossary: https://docs.openstack.org/octavia/queens/reference/glossary.html
