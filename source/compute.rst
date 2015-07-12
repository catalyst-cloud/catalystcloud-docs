###############
Compute service
###############


****************************
Launching a compute instance
****************************

Instance initialisation with cloud-init
=======================================

A script called cloud-init is included in all images provided by the Catalyst
Cloud. This script is there to assist you with instance configuration at boot
time. It communicates with the meta-data agent of our cloud and, for example,
configures the network of your compute instance as defined by you via our APIs.

Cloud-init is very powerful and a defacto multi-distribution and multi-cloud
way of handling the early initialisation of a cloud instance.

When you launch a compute instance on the Catalyst Cloud, you can pass
initialisation configuration to cloud-init via "user-data" (either using the
``--user-data`` parameter of ``nova boot``, or as post-creation customisation
script via the web dashboard).

In the following sections we provide examples that illustrate how to perform
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
locate the instance to be resized. On the actions column, click on the downward
arrow to list more actions and then click on resize instance as shown below:

.. image:: _static/compute-resize-button.png
   :align: center

The resize dialogue will pop up, allowing you to chose a new flavour.

.. image:: _static/compute-resize-action.png
   :align: center

.. note::
  Before resizing down a compute instance, please consider if you need to
  change the configuration of your applications, so they can start up with less
  resources. For example: databases and Java virtual machines are often
  configured to allocate a certain amount memory and will fail to start if not
  enough memory is available.

The status of the instance will change to preparing to resize or migrate,
resized or migrated and finally “Confirm or Revert Resize/Migrate” as shown
below:

.. image:: _static/compute-confirm-resize.png
   :align: center

Once the resize operation has been completed, our cloud will prompt you to
confirm or revert the resize operation. Click on confirm to finish the resize
operation.


***************
Security groups
***************

A security group is a virtual firewall that controls network traffic to and
from compute instances. Your tenant comes with a default security group, which
cannot be deleted, and you can create additional security groups.

Security groups are made of security rules. You can add or modify security
rules at any time. When you modify a security group, the new rules are
automatically applied to all compute instances associated with it.

You can associate one or more security groups to your compute instances.

.. note::

  While it is possible to assign many security groups to a compute instance, we
  recommend you to consolidate your security groups and rules as much as
  possible.

Creating a security group
=========================

The default behaviour of security groups is to deny all traffic. Rules added to
security groups are all "allow" rules.

.. note::

  Failing to set up the appropriate security group rules is a common mistake
  that prevents users from reaching their compute instances, or compute
  instances to communicate with each other.

