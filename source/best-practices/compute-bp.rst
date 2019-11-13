#######
Compute
#######

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
