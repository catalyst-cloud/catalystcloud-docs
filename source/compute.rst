###############
Compute service
###############


********
Overview
********

The compute service provides scalable on-demand compute capacity for your
applications in the form of compute instances. Compute instances are virtual
servers that can be scaled up, down, or horizontally (by adding and removing
more compute instances).

Flavors
========

The compute instance flavor (US spelling is correct here) defines the amount of
CPU and RAM allocated to your virtual servers. The price per hour for a compute
instance varies according to its flavor. Existing flavors can be found here:
https://catalyst.net.nz/catalyst-cloud/services/iaas/compute-service

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


Best practices
==============

It is best to scale applications horizontally (by adding more compute instances
and balancing load amongst them) rather than vertically. It is possible to
scale compute instances horizontally without downtime. Resizing compute
instance vertically (up or down) will result in a brief downtime, because the
operating system needs to reboot to pick up the new configuration.



****************************
Launching a compute instance
****************************

Instance initialisation with cloud-init
=======================================

A script called cloud-init is included in all images provided by the Catalyst
Cloud. This script is there to assist you with instance configuration at boot
time. It communicates with the meta-data agent of our cloud and, for example,
configures the network of your compute instance as defined by you via our APIs.

Cloud-init is very powerful. It's a de facto multi-distribution and multi-cloud
way of handling the early initialisation of a cloud instance.

When you launch a compute instance on the Catalyst Cloud, you can pass
initialisation configuration to cloud-init via "user-data" (either using the
``--user-data`` parameter of ``openstack server create``, or as a post-creation
customisation script via the web dashboard).

In the following sections, we provide examples that illustrate how to perform
common initialisation tasks with cloud-init, using different configuration
formats.


Cloud config format
-------------------

The cloud config format is the simplest way to accomplish initialisation tasks
using the cloud-config syntax. The example below illustrates how to upgrade
all packages on the first boot.

.. code-block:: bash

  #cloud-config
  # Run a package upgrade on the first boot
  package_upgrade: true

The example below shows cloud-init being used to change various configuration
options during boot time, such as the hostname, locale and timezone.

.. code-block:: bash

  #cloud-config

  # On the Catalyst Cloud, the default username for access to your instances is:
  # - CentOS: centos
  # - CoreOS: core
  # - Debian: debian
  # - Ubuntu: ubuntu
  # - Instances deployed by Heat: ec2-user
  # You can chose a different username with the "user" parameter as shown below.
  user: username

  # Set the hostname and FQDN
  fqdn: hostname.example.com
  manage_etc_hosts: true

  # Set the timezone to UTC (strongly recommended)
  timezone: UTC

  # Set the locale
  locale: en_US.UTF-8

  # Run package update and upgrade on first boot
  package_upgrade: true

  # Mount additional volumes
  mounts:
   - [ /dev/vdb, /mnt, auto ]

  # Install packages
  packages:
   - git
   - sysstat
   - htop
   - apache2

  # Run commands (in order, output displayed on the console)
  runcmd:
   - echo "Sample command"

  # Reboot when finished
  power_state:
   mode: reboot
   message: Rebooting to apply new settings

  # Log all cloud-init process output (info & errors) to a logfile
  output: {all: ">> /var/log/cloud-init-output.log"}

Script format
-------------

Cloud init can be used to run scripts written in any language (bash, python,
ruby, perl, ...) at boot time. Scripts must begin with ``#!``.

.. code-block:: bash

  #!/bin/bash

  # Upgrade all packages
  apt-get update
  apt-get -y upgrade

  # Install apache
  apt-get -y install apache2

MIME format
-----------

The mime multi part archive format allows you to combine multiple cloud-init
formats, files and scripts into a single file.

The example below uses the cloud-config format to install apache and the script
format to overwrite the index.html file of the default website:

.. code-block:: bash

  From nobody Sun Jul 12 18:59:36 2015
  Content-Type: multipart/mixed;
  boundary="===============6187713584654397420=="
  MIME-Version: 1.0

  --===============6187713584654397420==
  MIME-Version: 1.0
  Content-Type: text/text/cloud-config; charset="us-ascii"
  Content-Transfer-Encoding: 7bit
  Content-Disposition: attachment; filename="cloud-config.init"

  #cloud-config
  # Install packages
  packages:
   - apache2

   --===============6187713584654397420==
   MIME-Version: 1.0
   Content-Type: text/text/x-shellscript; charset="us-ascii"
   Content-Transfer-Encoding: 7bit
   Content-Disposition: attachment; filename="script.sh"

   #!/bin/bash
   echo "<h1>Hello world!</h1>" > /var/www/html/index.html

   --===============6187713584654397420==--

Cloud-init official docs
------------------------

For other formats and more detailed information on how to use cloud-init to
initialise your compute instances, please read:
http://cloudinit.readthedocs.org/en/latest/index.html.


***************************
Resizing a compute instance
***************************

The resize operation can be used to change the flavor (increase or decrease the
amount of CPU and RAM) of a compute instance.

.. warning::
  The resize operation causes a brief downtime of the compute instance, as the
  guest operating system will be restarted to pick up the new configuration. If
  you need to scale your application without downtime, consider scaling it
  horizontally (add/remove compute instances) as opposed to vertically
  (add/remove resources to an existing instance).

To resize a compute instance, go to the Instances panel on the dashboard and
locate the instance to be resized. On the Actions column, click on the downward
arrow to list more actions and then click on Resize Instance as shown below:

.. image:: _static/compute-resize-button.png
   :align: center

The resize dialogue will pop up, allowing you to chose a new flavor.

.. image:: _static/compute-resize-action.png
   :align: center

.. note::
  Before resizing down a compute instance, please consider if you need to
  change the configuration of your applications, so they can start up with less
  resources. For example: databases and Java virtual machines are often
  configured to allocate a certain amount of memory and will fail to start if not
  enough memory is available.

The status of the instance will change to preparing to resize or migrate,
resized or migrated and finally “Confirm or Revert Resize/Migrate” as shown
below:

.. image:: _static/compute-confirm-resize.png
   :align: center

Once the resize operation has been completed, our cloud will prompt you to
confirm or revert the resize operation. Click on confirm to finish the resize
operation.

.. _stopping compute:

***************************
Stopping a compute instance
***************************

There are four different ways you can stop a compute instance:

* Shelve will prompt the operating system to shutdown gracefully, power off the
  virtual machine, preserve the disk and deallocate the compute resources (CPU
  and RAM) from our compute nodes. Instances in this state are not charged for,
  as their compute aspect is not operational. We only charge for the disks (for
  example: root disk or additional volumes connected to it), as we still need
  to retain the data while the instance is powered off. When re-started it may
  be allocated to a different compute node.

* Shut off will prompt the operating system to shutdown gracefully, power off
  the virtual machine, but preserve the compute resources (CPU and RAM)
  allocated on a compute node. Instances in this state are still charged as if
  they were running. When re-started it will continue to be hosted on the same
  compute node.

* Pause will store the memory state of the compute instance in memory and then
  freeze the virtual machine. Instances in this state are still charged as if
  they were running. When re-started it will resume its operation exactly where
  it was, except if the physical compute node was restarted (for example: a
  power failure) and its memory content lost.

* Suspend will store the memory state of the compute instance on disk and then
  shut down the virtual machine. Instances in this state are still charged as
  if they were running. When re-started it will resume its operation exactly
  where it was, but will take longer to start because it needs to read its
  memory state from disk.


****************************
Automatic restart on failure
****************************

When server failures occur, the Catalyst Cloud will attempt to restart the
affected compute instances on a healthy server to minimise their downtime.

To benefit from this feature, your application must be configured and prepared
to start automatically and resume its normal operation at boot time and your
guest operating system to respond to ACPI power events.

The operating system images supplied by Catalyst or our partners already have
ACPI configured to respond to power events by default.


***************************
Anti-affinity groups for HA
***************************

..
  Affinity and anti-affinity groups allow you to ensure compute instances are
  placed on the same or different hypervisors (physical servers).

Anti-affinity groups allow you to ensure compute instances are placed on
different physical servers.

..
  Server affinity is useful when you want to ensure that the data transfer
  amongst compute instances is as fast as possible. On the other hand it may
  reduce the availability of your application (a single server going down affects
  all compute instances in the group) or increase CPU contention.

Server anti-affinity is useful when you want to increase the availability of an
application within a region. Compute instances in an anti-affinity group are
placed on different physical servers, ensuring that the failure of a server
will not affect all your compute instances simultaneously.


Managing server groups
======================

Via the APIs
------------

Please refer to the server groups API calls at http://developer.openstack.org/api-ref/compute/#server-groups-os-server-groups.

Via the command line tools
--------------------------

To create a server group:

.. code-block:: bash

  openstack server group create $groupname $policy

Where:

* ``$groupname`` is a name you choose (eg: app-servers)
* ``$policy`` is `anti-affinity``

.. * ``$policy`` is either ``affinity`` or ``anti-affinity``

To list server groups:

.. code-block:: bash

  openstack server group list

To delete a server group:

.. code-block:: bash

  openstack server group delete $groupid

Deleting a server group does not delete the compute instances that belong to
the group.

Add compute instance to server group
====================================

Via the command line tools
--------------------------

When launching a compute instance, you can pass a hint to our cloud scheduler
to indicate it belongs to a server group. This is done using the ``--hint
group=$GROUP_ID`` parameter, as indicated below.

.. code-block:: bash

  openstack server create --flavor $CC_FLAVOR_ID --image $CC_IMAGE_ID
  --key-name $KEY_NAME --security-group default --security-group $SEC_GROUP
  --nic net-id=$CC_PRIVATE_NETWORK_ID --hint group=$GROUP_ID first-instance

.. note::

  If you receive a `No valid host was found` error, it means that the cloud
  scheduler could not find a suitable server to honour the policy of the server
  group. For example, we may not have enough capacity on the same hypervisor to
  place another instance in affinity, or enough hypervisors with sufficient
  capacity to place instances in anti-affinity.

Via Ansible
-----------

The example below illustrates how the server group hint can be passed in an
Ansible playbook using the os_server module:

.. code-block:: yaml

  - name: Create a compute instance on the Catalyst Cloud
    os_server:
      state: present
      name: "{{ instance_name }}"
      image: "{{ image }}"
      key_name: "{{ keypair_name }}"
      flavor: "{{ flavor }}"
      nics:
        - net-name: "{{ private_network_name }}"
      security_groups: "default,{{ security_group_name }}"
      scheduler_hints: "group=78f2aabc-e73a-4c72-88fd-79185797548c"


***
FAQ
***

What is Instance Boot Source?
=============================

When creating a new instance via the dashboard you are asked to select an
Instance Boot Source. This is the template used to create an instance. You can
use a snapshot of an existing instance, an image, or a volume (if enabled). You
can also choose to use persistent storage by creating a new volume.

Let's clarify these terms.

Images
------

These are pre-configured operating system images that are available for
selection as a boot source. Images are provided by the OpenStack service known
as Glance. When booting from an image you can elect to create a new volume from
the image. If you choose to create a new volume you need to decide if you want
the volume to be deleted on instance termination.

Volumes
-------

Volumes are block devices provided by the Cinder service that can be attached
to instances. Volumes can be used as a boot source provided they contain an
appropriate operating system.

Instance Snapshot
-----------------

Instances that have been snapshotted can be selected as a boot source. Instance
snapshots are Images of the type "Snapshot".

Volume Snapshot
---------------

Volumes that have been snapshotted can be selected as a boot source.


Ephemeral vs Persistent
-----------------------

Ephemeral storage is only available for the lifetime of the instance so when
the instance is terminated, any data that was stored on it is lost. It is
stored in the same block storage as persistent data to allow instances to
retain their ephemeral storage if the instance is live migrated to another
physical hypervisor.

Persistent storage on the other hand will persist when instances are rebooted.

Select the boot source
======================

+--------------------+-----------------------------------+------------+
| Boot Source        | Description                       | Type       |
|                    |                                   |            |
+====================+===================================+============+
| Image, do not      | This option allows a user to      | Ephemeral  |
| create new volume  | specify an image from the Glance  |            |
|                    | repository to copy into an        |            |
|                    | ephemeral disk.                   |            |
+--------------------+-----------------------------------+------------+
| Image,             | This option allows a user to      | Persistent |
| create new volume, | specify an image from the Glance  |            |
| do not delete      | repository to copy into a         |            |
| volume on terminate| persistent volume.                |            |
+--------------------+-----------------------------------+------------+
| Image,             | This option allows a user to      | Ephemeral  |
| create new volume, | specify an image from the Glance  |            |
| delete volume on   | repository to copy into a         |            |
| terminate          | volume which will be deleted on   |            |
|                    | termination.                      |            |
+--------------------+-----------------------------------+------------+
| Instance Snapshot  | This option allows a user to      | Ephemeral  |
|                    | specify an instance snapshot to   |            |
|                    | use as the root disk; the         |            |
|                    | disk is ephemeral.                |            |
+--------------------+-----------------------------------+------------+
| Volume, do not     | This option allows a user to      | Persistent |
| delete on terminate| specify a Cinder volume (by name  |            |
|                    | or UUID) that should be directly  |            |
|                    | attached to the instance as the   |            |
|                    | root disk; any content stored in  |            |
|                    | volume will persist on instance   |            |
|                    | termination.                      |            |
+--------------------+-----------------------------------+------------+
| Volume,            | This option allows a user to      | Ephemeral  |
| delete on terminate| specify a Cinder volume (by name  |            |
|                    | or UUID) that should be directly  |            |
|                    | attached to the instance as the   |            |
|                    | root disk; the volume will be     |            |
|                    | deleted on termination.           |            |
+--------------------+-----------------------------------+------------+
| Volume Snapshot,   | This option allows a user to      | Persistent |
| do not delete on   | specify a Cinder volume snapshot  |            |
| terminate          | (by name or UUID) that should be  |            |
|                    | directly attached to the instance |            |
|                    | as the root disk; the volume will |            |
|                    | persist on instance termination.  |            |
+--------------------+-----------------------------------+------------+
| Volume Snapshot,   | This option allows a user to      | Ephemeral  |
| delete on terminate| specify a Cinder volume snapshot  |            |
|                    | (by name or UUID) that should be  |            |
|                    | directly attached to the instance |            |
|                    | as the root disk; the volume will |            |
|                    | be deleted on termination.        |            |
+--------------------+-----------------------------------+------------+

|

Pause, Suspend, Shelve and Shut Off Instance. What's the difference?
=====================================================================

See :ref:`stopping compute` for the differences between the methods of halting
a compute instance.

* For lowering costs, ``Shelve Instance`` is the recommended option.
* For longer term preservation of halted instances, ``Shelve Instance`` is the
  recommended option.

|

The cost of a running instance vs a shelved instance
----------------------------------------------------

.. note::

  It is important to be aware that the ``Shelve Instance`` action will only help to lower the
  monthly costs associated with your cloud project.

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


Locale errors on Ubuntu Linux
=============================

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
