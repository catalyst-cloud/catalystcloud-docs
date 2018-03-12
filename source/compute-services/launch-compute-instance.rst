############################
Launching a compute instance
############################

***************************************
Instance initialisation with cloud-init
***************************************

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

*******************
Cloud config format
*******************

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

*************
Script format
*************

Cloud init can be used to run scripts written in any language (bash, python,
ruby, perl, ...) at boot time. Scripts must begin with ``#!``.

.. code-block:: bash

  #!/bin/bash

  # Upgrade all packages
  apt-get update
  apt-get -y upgrade

  # Install apache
  apt-get -y install apache2

***********
MIME format
***********

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

************************
Cloud-init official docs
************************

For other formats and more detailed information on how to use cloud-init to
initialise your compute instances, please read:
http://cloudinit.readthedocs.org/en/latest/index.html.
