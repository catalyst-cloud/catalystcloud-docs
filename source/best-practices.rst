###############
Best practices
###############

***********************
Everyday considerations
***********************

Getting the correct ID
======================

For user created objects within the cloud it is always advisable to lookup ID
values before using them in any type of command to ensure that the correct
element has been identified. While it is very rare, it should be noted that it
is possible for underlying system generated cloud objects, such as flavor and
image IDs to also change.

With this in mind, if you are running commands from the CLI tools or one of the
support SDKs, it is recommended to lookup the ID before using it to ensure that
the correct object is referenced.

The following example shows how this could be done using the OpenStack CLI
tool. It queries can query both images and flavors by name to retrieve their ID
and then it also stores the resulting ID into an environment variable so that
it can be reused in subsequent commands.

.. code-block:: bash

    export CC_IMAGE_ID=$( openstack image show ubuntu-18.04-x86_64 -f value -c id )
    export CC_FLAVOR_ID=$( openstack flavor show c1.c1r2 -f value -c id )

Similar mechanisms exist for doing this with other tool sets such as Ansible,
Terraform and the various supported development SDKs.


*****************
High availability
*****************

This document outlines the physical infrastructure and software features that
make the Catalyst Cloud highly available and resilient. It covers built-in
features that are inherited by every project and services that can be used to
enhance the availability of web applications and websites hosted on the
Catalyst Cloud.

24x7 monitoring
===============

The catalyst cloud has robust fine-grained monitoring systems in place. These
systems are monitored 24x7.

Geographic diversity
====================

The Catalyst Cloud provides multiple regions or geographical locations that you
can use to host your applications. Regions are completely independent and
isolated from each other, providing fault tolerance and geographic diversity.

From a network point of view, each region has diverse fibre paths from diverse
providers and ISPs for high availability. Power and cooling systems are also
designed for high availability and allow for maintenance to be performed
without service disruptions to customers.

For more information about our regions, please consult the
:ref:`regions <admin-region>` section of the documentation.


Compute
=======

If a physical compute node fails, our monitoring systems will detect the
failure and trigger an “evacuate” process that will restart all affected
virtual compute instances on a healthy physical server. This process usually
takes between 5 to 20 minutes which allows us to meet our 99.95% availability
SLA for individual compute instances.

Customers that require more than 99.95% availability can combine multiple
compute instances within the same region using anti-affinity groups.
Anti-affinity groups ensure that compute instances that are members of the same
group are hosted on different physical servers. This reduces the risk and
probability of multiple compute instances failing at the same time. For more
information on how to use anti-affinity, please consult :ref:`anti-affinity`.

Customers that require their applications to survive the loss of an entire
region can launch compute instances in different regions. This requires their
applications, or middleware used by their applications (such as databases), to
support this architecture.

Block storage
=============

We run a distributed storage system that by default retains three copies of
your data on different servers spread across a region (a datacenter).
We can afford to lose many disks and multiple storage nodes without losing any
data. As soon as a disk or storage node fails, our storage solution begins
recovering the data from an existing copy, always ensuring that three replicas
are present.

The storage solution is self managing and self healing, constantly placing
your data in optimal locations for data survival and resiliency. It runs
automated error checks in the background that can detect and recover a single
bit of incorrect data (bit rot), by comparing the three copies of the data and
ensuring they are identical.

The solution is designed and implemented with very high availability and data
resiliency in mind. It has no single points of failure.


Object storage
==============

Our object storage service is a fully distributed storage system, with no
single points of failure and scalable to the exabyte level. The system is
self-healing and self-managing. Data stored in object storage is asynchronously
replicated to preserve three replicas of the data in different cloud regions.
The system runs frequent CRC checks to protect data from soft corruption (bit
rot). The corruption of a single bit can be detected and automatically restored
to a healthy state. The loss of a region, server or a disk leads to the data
being quickly recovered from another disk, server or region.

Virtual routers
===============

In the same way that if a compute instance fails, if a physical network node
fails our monitoring systems will detect the failure and trigger the evacuate
process that will ensure all affected virtual router instances are restarted on
a healthy server. This process usually takes between 5 to 20 minutes.

We are working on a new feature that launches two virtual routers on separate
network nodes responding on the same IP address. Once this is complete the
failover between routers will take milliseconds which will most likely not be
noticed. Meanwhile customers requiring Higher availability are advised to
combine compute instances from multiple regions where possible.

HA Tutorials
============

There are a number of options available to Catalyst Cloud customers to enhance
application availability. Catalyst has documented these in detail:

Providing highly available instances within a region:
http://docs.catalystcloud.io/tutorials/deploying-highly-available-instances-with-keepalived.html

Techniques for region failover:
http://docs.catalystcloud.io/tutorials/region-failover-using-the-fastly-cdn.html
