#############
Image service
#############


***********************************
Importing existing virtual machines
***********************************

Importing an unchanged existing virtual machine to the Catalyst Cloud is likely
to work out of the box, but to get the best out of it and ensure that all API
operations will work with your virtual machine, there are some preparation
steps and tweaks that are highly recommended. For example: cloud VMs have a
cloud-init script that runs at boot time to fetch the configuration of the
compute instance from our metadata agent.

Preparing your existing VM
==========================

.. seealso::

  The OpenStack upstream documentation provides detailed instructions on how to
  prepare all major operating systems to run in the cloud:
  http://docs.openstack.org/image-guide/content/ch_creating_images_manually.html

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
agent and DHCP servers. As such, it is recommended to configure the network
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
  throughout the life-cycle of the compute instance (until it is terminated). Each
  virtual network created by you runs its own DHCP agent that is used to lease
  IPs directed by the compute and network services.

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

Converting the machine image
============================

Ensure you have the qemu-utils package installed, as it provides the tools
required to convert the disk images:

.. code-block:: bash

  sudo apt-get install qemu-utils

From KVM to OpenStack
---------------------

On a host with QEMU installed, convert the QCOW2 disk to a RAW disk:

.. code-block:: bash

  qemu-img convert -O raw kvm-image.qcow2 raw-image.raw

From VMWare to OpenStack
------------------------

On a host with QEMU installed, convert the VMDK disk to a RAW disk:

.. code-block:: bash

  qemu-img convert -O raw vmware-image.vmdk raw-image.raw

Uploading the image to the cloud
--------------------------------

If the image is larger than 5GB, we recommend using the OpenStack CLI to upload
it to the cloud. Ensure that you have the OpenStack command line tools
installed and that you have sourced an openrc file, as explained on
:ref:`command-line-tools`.

To upload the converted image to the Catalyst Cloud:

.. code-block:: bash

  glance image-create --disk-format raw --container-format bare --file
  raw-image.raw --name image-name --is-public=False --progress

Launching the VM on the cloud
-----------------------------

On the dashboard you will find the image you uploaded on “Images & Snapshots”
under your private images. Click on the Launch button and:

* Select “Boot from image (creates a new volume).” as the instance boot source.
* Ensure the device size is at least the same size as the image uploaded.
* For its first boot you should choose a flavour that provides at least the
  same amount of CPU and RAM the VM had before. Once you confirm the compute
  instance is booting appropriately, if desirable, you can resize it to a
  smaller flavour.

.. warning::

  Remember that your VM has been imported exactly as it was before, therefore
  there might be some things, like a host based firewall blocking connections,
  that may prevent you from connecting to it remotely. You can use the console
  and your existenting user credentials to connect to your compute instance and
  make adjustments to its configuration as required.


***
FAQ
***

What operating systems are supported by the Catalyst Cloud?
===========================================================

You should be able to run all major operating systems supporting the x86_64
architecture. The following operating systems were already tested by Catalyst
or its customers:

* Linux
* FreeBSD
* Windows

You can use the image service to upload your own operating system image to the
Catalyst Cloud. Please remember you can only run software that is owned by you,
public domain or that you hold a valid license for. You have the freedom to
choose what software you run and it is your responsibility to comply with the
terms related to its usage.

What pre-configured images are provided by Catalyst?
====================================================

Catalyst provides some pre-configured images to make it easier for you to run
your applications on the cloud. The images provided by Catalyst include:

* Ubuntu Linux (official cloud image provided by Canonical)
* CentOS (official cloud image provided by the CentOS community)
* CoreOS (official OpenStack image provided by CoreOS)
* Debian (official cloud image provided by the Debian community)

Before using them, you should always confirm that they are suitable for your
needs and fit for purpose. Catalyst provides them "as is", without warranty of
any kind. If there is something you need to change, you can always upload your
own images, crafted the way you like, or take a snapshot of ours and modify it
the way you need.

How can I identify the images provided by Catalyst?
===================================================

The images provided by Catalyst are uploaded to tenant ID
``94b566de52f9423fab80ceee8c0a4a23`` and are made public. With the command line
tools, you can easily located them by running:

.. code-block:: bash

  glance image-list --owner 94b566de52f9423fab80ceee8c0a4a23 --is-public True

