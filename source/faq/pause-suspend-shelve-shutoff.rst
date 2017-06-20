###################################################################
Pause, Suspend, Shelve and Shut Off Instance. Whats the difference?
###################################################################

See :ref:`stopping compute` for the differences between the methods of halting
a compute instance.

* For lowering costs ``Shelve Instance`` is the recommended option.
* For longer term preservation of halted instances ``Shelve Instance`` is the
  recommended option.

It is important to note here that the ``Shelve Instance`` action will only help to lower the
monthly costs associated with your cloud project.

The act of shelving an instance creates a snapshot of the running instance which it stores as an
image on block storage meaning you now have an extra volume associated with your project. Once this
has been done it stops the instance and schedules it to be removed from memory. So where the cost
saving comes in when shelving instances is due to the fact that you are no longer paying for the
compute services that a running instance uses, instead you are now only paying the, much cheaper,
cost of storing a snapshot of your image on disk.

To illustrate this, lets say you had a simple 1 vCPU 1Gb RAM instance with a 10GB disk running 24/7
for an entire month, which we will assume is 730 hours as an average.

The cost for this would be:
  $32.12 / month

Compare that to the same instance stored as a disk image:
  $4.02 / month

You can see that even for such a small compute instance the cost saving is quite significant. If
you were to apply this to a compute instance with 4vCPU and 16GB RAM, the monthly running cost
would be:
  $285.43 / month

so it would definitely make sense to shelve instances you not need running fulltime.
