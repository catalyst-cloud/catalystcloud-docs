***********************************
Importing existing virtual machines
***********************************

Importing an unchanged existing virtual machine to the Catalyst Cloud is likely
to work out of the box, but to get the best out of it and ensure that all API
operations will work with your virtual machine, there are some preparation
steps and tweaks that we highly recommend. For example: cloud VMs have a
cloud-init script that runs at boot time to fetch the configuration of the
compute instance from our metadata agent.

Preparing your existing VM
==========================

Debian and Ubuntu Linux
-----------------------

Make sure GRUB is booting out of the master boot record on the first hard
drive. While it is possible to import virtual machines with more complex disk
configurations, it will be easier if the virtual machine is backed by a single
root-disk.

Install the cloud-init script:

.. code-block:: bash

  sudo apt-get install cloud-init

Configure cloud-init to use EC2 as its metadata source:

.. code-block:: bash

  dpkg-reconfigure cloud-init

Compute instances receive their network configuration from our cloud metadata
agent and DHCP servers. As such, we recommend you configure the network
interfaces (sudo vi /etc/network/interfaces) to use DHCP instead of a static
IP.

.. code-block:: bash

  sudo vi /etc/network/interfaces

.. code-block:: bash

  auto eth0
  iface eth0 inet dhcp

.. note::

  Using DHCP does not mean your compute instance will get a different IP every
  time you boot it up. On our cloud, an IP is allocated for your compute
  instance by our compute and network services. This IP will remain the same
  throughout the life-cycle of the compute instance (until it is terminated).
  Each virtual network created by you runs its own DHCP agent that is used
  to lease IPs directed by the compute and network services.

Since the MAC addresses for your network interfaces will be different on the
cloud, you must remove persistent net rules from udev:

.. code-block:: bash

  sudo echo > /etc/udev/rules.d/70-persistent-net.rules

Block devices on our cloud are named /dev/vd[a,b,c...]. If your /etc/fstab is
using UUIDs, this should not be an issue, as the UUIDs will be preserved in the
migration. However, if your fstab is specifying the block device (eg:
/dev/sda1) like the example below, your compute instance will fail to boot
complaining it could not find its boot device or root file-system. You should
use UUIDs or rename the devices to /dev/vd[a,b,c,...] instead.

.. code-block:: kconfig

  # /etc/fstab: static file system information.
  # <file system> <mount point>   <type>  <options>       <dump>  <pass>
  proc            /proc           proc    defaults        0       0
  # The device below should be /dev/vda1 instead of /dev/sda1
  /dev/sda1       /               ext3    errors=remount-ro 0       1

Renaming the file system on the original virtual machine will probably prevent
you from booting it. To safely rename the devices, you should mount the image
on a loopback device and then change it as required.

.. code-block:: bash

  sudo losetup /dev/loop1 image.raw
  sudo mount /dev/mapper/loop1p1 /mnt

.. warning::

  If you rename a device in fstab to vda, remember you probably need to apply
  the same changes to the boot loader. Don't forget to run update-grub.

Follow the instructions of the next sections (converting the machine image,
uploading an image to the cloud and launching a VM based on a custom image) to
conclude the process.
