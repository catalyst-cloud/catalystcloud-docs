##############
Best practices
##############


************
Root volumes
************

When creating a new compute instance, the preference is to use a block storage
volume for the root disk. Volume backed instances have several benefits, such
as:

* Snapshopts are created in seconds and use less space.
* The volume and it's associated data can continue to exist after the compute
  instace is terminated.

When launching an instance via the dashboard the default behaviour is to create
a volume for its root disk. Other methods of instance creation vary and some
will equire the volume to be created ahead of the instance being launched, so
please consult the relevant documentation for clarification.

Typically ephemeral root disks should only be used for workloads that are
temporary in nature, like one-off jobs.


*****************
High availability
*****************

If a physical compute node fails, our monitoring systems will detect the failure
and trigger a process that restarts the affected virtual compute instances on a
healthy physical server. This process usually takes between 5 to 20 minutes
which allows us to meet our 99.95% availability SLA for individual compute
instances.

Customers that require more than 99.95% availability can combine multiple
compute instances within the same region using anti-affinity groups.
Anti-affinity groups ensure that compute instances that are members of the same
group are hosted on different physical servers. This reduces the risk and
probability of multiple compute instances failing at the same time. For more
information on how to use anti-affinity, please consut :ref:`anti-affinity`.

Customers that require their applications to survive the loss of an entire
region can launch compute instances in different regions. This requires their
applications, or middleware used by their applications (such as databases), to
support this architecture.


***********
Scalability
***********

It is best to scale applications horizontally (by adding more compute instances
and balancing load amongst them) rather than vertically. It is possible to
scale compute instances horizontally without downtime. Resizing compute
instance vertically (up or down) will result in a brief downtime, because the
operating system needs to reboot to pick up the new configuration.
