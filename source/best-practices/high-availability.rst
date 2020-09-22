#################
High availability
#################

This document outlines the physical infrastructure and software features that
make the Catalyst Cloud highly available and resilient. It covers built-in
features that are inherited by every project and services that can be used to
enhance the availability of web applications and websites hosted on the
Catalyst Cloud.

***************
24x7 monitoring
***************

The catalyst cloud has robust fine-grained monitoring systems in place. These
systems are monitored 24x7.

********************
Geographic diversity
********************

The Catalyst Cloud provides multiple regions or geographical locations that you
can use to host your applications. Regions are completely independent and
isolated from each other, providing fault tolerance and geographic diversity.

From a network point of view, each region has diverse fibre paths from diverse
providers and ISPs for high availability. Power and cooling systems are also
designed for high availability and allow for maintenance to be performed
without service disruptions to customers.

For more information about our regions, please consult the
:ref:`regions <admin-region>` section of the documentation.

***************************
High availability tutorials
***************************

There are a number of options available to Catalyst Cloud customers to enhance
application availability. Catalyst has documented these in detail:

Providing highly available instances within a region:
http://docs.catalystcloud.io/tutorials/compute/deploying-highly-available-instances-with-keepalived.html

Techniques for region failover:
http://docs.catalystcloud.io/tutorials/other/region-failover-using-the-fastly-cdn.html
