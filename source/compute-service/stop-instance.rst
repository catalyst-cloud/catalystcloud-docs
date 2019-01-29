.. _stopping compute:

###########################
Stopping a compute instance
###########################

*****************
Options available
*****************
There are four different ways you can stop a compute instance:

.. Note::

  The **only** state where an instance will not be incurring compute charges is
  when it has been ``SHELVED``.

* ``Shelve`` will prompt the operating system to shutdown gracefully, power off
  the virtual machine, preserve the disk and deallocate the compute resources
  (CPU and RAM) from our compute nodes. **Instances in this state are not
  charged for, as their compute aspect is not operational**. We only charge for
  the disks (for example: root disk or additional volumes connected to it),
  as we still need to retain the data while the instance is powered off. When
  re-started it may be allocated to a different compute node.

* ``Shut off`` will prompt the operating system to shutdown gracefully, power
  off the virtual machine, but preserve the compute resources (CPU and RAM)
  allocated on a compute node. Instances in this state are still charged as if
  they were running. When re-started it will continue to be hosted on the same
  compute node.

* ``Pause`` will store the memory state of the compute instance in memory and
  then freeze the virtual machine. Instances in this state are still charged as
  if they were running. When re-started it will resume its operation exactly
  where it was, except if the physical compute node was restarted (for example:
  a power failure) and its memory content lost.

* ``Suspend`` will store the memory state of the compute instance on disk and
  then shut down the virtual machine. Instances in this state are still charged
  as if they were running. When re-started it will resume its operation exactly
  where it was, but will take longer to start because it needs to read its
  memory state from disk.
