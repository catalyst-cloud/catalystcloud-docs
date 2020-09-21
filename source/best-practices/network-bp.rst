########
Networks
########

************************************
Virtual router high availability
************************************

In the same way that if a compute instance fails, if a physical network node
fails our monitoring systems will detect the failure and trigger the evacuate
process that will ensure all affected virtual router instances are restarted on
a healthy server. This process usually takes between 5 to 20 minutes.

We are working on a new feature that launches two virtual routers on separate
network nodes responding on the same IP address. Once this is complete the
failover between routers will take milliseconds which will most likely not be
noticed. Meanwhile customers requiring Higher availability are advised to
combine compute instances from multiple regions where possible.

*************************************
Networks are isolated between regions
*************************************

By default your networks and instance cannot access or connect to one another
across different regions. Regions are completely independent and isolated from
each other, providing fault tolerance and geographic diversity. This ensures
that if an instance or network were compromised by some disaster natural or
otherwise; the instances in separate regions would not be affected. There are
ways to go around this if you need to connect instances or networks across a
region for some purpose. This can be done using :ref:`vpn`

