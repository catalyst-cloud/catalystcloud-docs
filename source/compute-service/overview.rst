########
Overview
########

*******
Flavors
*******

The compute instance flavor (US spelling is correct here) defines the amount of
CPU and RAM allocated to your virtual servers. The price per hour for a compute
instance varies according to its flavor. Existing flavors can be found here:
https://catalystcloud.nz/services/iaas/compute/

Our flavors are named after the amount of CPU and RAM they provide you,
so you don't need to consult our documentation to find out their
specifications. We currently provide a number of common combinations
of CPU and RAM, and are prepared to introduce new flavors if required.

A virtual CPU (vCPU), also known as a virtual processor, is a time slice of a
physical processing unit assigned to a compute instance or virtual machine. The
mapping of virtual CPUs to physical cores is part of the performance and
capacity management services performed by the Catalyst Cloud on your behalf. We
aim to deliver the performance required by applications, and to increase cost
efficiency to our customers by optimising hardware utilisation.

Since virtual CPUs do not map one-to-one to physical cores, some performance
variation may occur over time. This variation tends to be small, and can be
mitigated by scaling applications horizontally on multiple compute instances in
an anti-affinity group. We monitor the performance of our physical servers and
have the ability to move compute instances around, without downtime, to spread
out load if required.

**************
Best practices
**************

It is best to scale applications horizontally (by adding more compute instances
and balancing load amongst them) rather than vertically. It is possible to
scale compute instances horizontally without downtime. Resizing compute
instance vertically (up or down) will result in a brief downtime, because the
operating system needs to reboot to pick up the new configuration.
