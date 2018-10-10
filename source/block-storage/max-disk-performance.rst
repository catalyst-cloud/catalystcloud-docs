#############################################
Best Practice for maximising disk performance
#############################################

*************
I/O Readahead
*************

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

This change is highly recommended if your workload is doing a lot of large streaming
reads.

**************************
Striping Volumes and RAID0
**************************

.. Note::

  The use of striped volumes is no longer considered to be a best practice approach to storage
  performance on the Catalyst Cloud.

In the past it was our opinion that the use of striping volumes to improve I/O performance was an
acceptable approach when using the Catalyst Cloud. This is no longer the case, as there are
several use cases where this has wide ranging impact in terms of overall storage performance.

If you do find yourself in the position of suffering due to demonstrable disk I/O performance
then please raise a ticket with us through the Support Panel to discuss your requirements and we
will assist in helping you resolve this.
