###
FAQ
###


********************************************************************
Pause, Suspend, Shelve and Shut Off Instance. What's the difference?
********************************************************************

See :ref:`stopping compute` for the differences between the methods of halting
a compute instance.

For lowering costs and long term preservation of compute instances, ``Shelve
Instance`` is the recommended option.

The cost of a running instance vs a shelved instance
====================================================

.. note::

  It is important to be aware that the ``Shelve Instance`` action will only help
  to lower the monthly costs associated with your cloud project.

The act of shelving an instance creates a snapshot of the running instance
which it stores as an image on block storage, meaning you now have an extra
volume associated with your project. Once this has been done, it stops the
instance and schedules it to be removed from memory. The cost saving when
shelving instances is due to the fact that you are no longer paying for the
compute services that a running instance uses. Instead, you are now only
paying the much cheaper cost of storing a snapshot of your image on disk.

To illustrate this, let's say you had a simple 1 vCPU 1Gb RAM instance
with a 10GB disk running 24/7 for an entire month, which we will assume is
730 hours as an average.

The cost for this would be:
**$32.12 / month**

Compare that to the same instance stored as a disk image:
**$4.02 / month**

You can see that even for such a small compute instance the cost saving is
quite significant. If you were to apply this to a compute instance with
4vCPU and 16GB RAM, the monthly running cost would be:
**$285.43 / month**

so it would definitely make sense to shelve instances you don't need
to run fulltime.


*****************************
Locale errors on Ubuntu Linux
*****************************

When launching an Ubuntu compute instance using the images provided by
Canonical, we recommend you configure the locale using cloud-init. The
example below illustrates how the locale can be defined at boot time using the
cloud-config syntax.

.. code-block:: bash

  #cloud-config
  fqdn: instancename.example.com
  locale: en_US.UTF-8

If the locale is not configured appropriately, you may get locale related
errors, such as:

* locale.Error: unsupported locale setting
* perl: warning: Setting locale failed
* perl: warning: Please check that your locale settings

These errors can occur while installing packages or performing simple tasks on
the operating system.

If you have not defined the locale at boot time, you can still configure it
later using the following procedure.

First, ensure that your hostname is defined in ``/etc/hosts`` (sudo vi
/etc/hosts). If you only have an entry for localhost, add another entry with
the name of your compute instance, as shown below:

.. code-block:: bash

  127.0.0.1 localhost
  127.0.0.1 instancename

Use the commands below to configure and generate your locales. Replace
``en_US.UTF-8`` with your desired locale.

.. code-block:: bash

  export LC_ALL="en_US.UTF-8"
  sudo echo "LC_ALL=en_US.UTF-8" >> /etc/environment
  sudo dpkg-reconfigure locales
