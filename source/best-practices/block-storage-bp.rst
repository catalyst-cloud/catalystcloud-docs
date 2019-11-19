################################
Block storage
################################
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

Volume names should be unique
=============================

All volumes have a UUID that differentiate between them, however these are not
very easy to read for human users. Therefore it is a best practice to make sure
that you name your volumes uniquely. This is to avoid a situation
where you have multiple volumes with the same name (or UUIDs that you don't
recognise) which you plan to attach to different instance, but you are not able
to tell which volume holds which data.

.. note::

  Your names should never include any information on user IDs, emails, project
  information etc. You also need to avoid using '/' in your naming, instead you
  should use '-'


Deletion policies
=================

There are a number of polices that you may wish to use when it comes to
deleting data from your storage options. The following are three of the most
common policies.

- Retention policy: This policy dictates that a volume/object cannot be deleted
  until it reaches a certain age.
- Object lock policy: The storage object is 'locked' and a specific user holds
  the 'key' to the instance and only they can choose to delete data from
  the instance or the instance itself.
- Versioning policy: Whenever your volume is changed a new version is created
  and the previous state of the storage object is saved. Should your newest
  version suffer some failure, you have the option to reload the previous
  saved state. This is a mixture of a delete and backup policy.


Best Practice for maximising disk performance
=============================================

I/O Readahead
-------------

It is recommended to increase the I/O readahead value for the volume to improve
performance. This parameter determines the number of kilobytes that the kernel
will read ahead during a sequential read operation.

The default value for this is 128KB but it is possible to increase this up to
around 2048KB. This should drastically improve sequential read performance, and
can be done using a script in /etc/udev/rules.d/.

Here is an example of what this script might look like.

.. code-block:: console

  $ sudo cat /etc/udev/rules.d/read-ahead-kb.rules
  SUBSYSTEM=="block", KERNEL=="vd[a-z]" ACTION=="add|change",
  ATTR{queue/read_ahead_kb}="1024"

This change is highly recommended if your workload is doing a lot of large
streaming reads.
