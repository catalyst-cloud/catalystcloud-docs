########
Networks
########


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


Networks are isolated between regions
=====================================

By default your networks and instance cannot access or connect to one another
across different regions. This ensures that if an instance or network were
compromised in some way that the instances in other regions would not be
affected.
If you have a need to connect two or more networks across regions you
can do so using a :ref:`vpn`

