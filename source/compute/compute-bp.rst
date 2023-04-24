######################
Compute best practices
######################

*****************
High availability
*****************

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


************
Root volumes
************

When creating a new compute instance, the preference is to use a
``Persistent Volume`` for its root disk. Persistent volumes have several
benefits, such as:

* Snapshots are created in seconds and use less space.
* The volume and it's associated data can continue to exist after the compute
  instance is deleted.

When launching an instance via the dashboard the default behaviour is to create
a ``Persistent Volume`` for its root disk. Other methods of instance creation
vary and some will require the volume to be created ahead of the instance being
launched, if this is the case please consult the relevant documentation for
clarification.

Typically an ``Ephemeral Disk`` should only be used for cloud native workloads,
that use the immutable infrastructure principle, or workloads that are
temporary in nature, such as batch jobs.


****************************
Automatic restart on failure
****************************

When server failures occur, the Catalyst Cloud will attempt to restart the
affected compute instances on a healthy server to minimize their downtime.

To benefit from this feature, your application must be configured and prepared
to start automatically and resume its normal operation at boot time and your
guest operating system to respond to ACPI power events.
The operating system images supplied by Catalyst or our partners already have
ACPI configured to respond to power events by default.


***********
Scalability
***********

It is best to scale applications horizontally (by adding more compute instances
and balancing load amongst them) rather than vertically. It is possible to
scale compute instances horizontally without downtime. Resizing compute
instance vertically (up or down) will result in a brief downtime, because the
operating system needs to reboot to pick up the new configuration.


**************************
Nested Virtualization
**************************

Nested virtualization is a feature that allows you to run KVM virtual machines
inside of an instance. This feature is available from the default images
that are provided by Catalyst Cloud. Support for nested instances is only
provided from Catalyst Cloud, up to the point of the initial instance that is
created using our cloud. Any further virtualized instances that are created are
the responsibility of the customer to maintain and support.

Additionally, there are some limitations that you should be aware of (and your
users should be aware of) when using nested virtualization.

#. Guests hosted using virtualization will fail to complete live migration.
#. Guests will fail to automatically resume from suspension when it occurs.

These limitations are inherent to nested KVM virtualization and cannot be
mitigated from a higher level at this stage.

