###################################
Importing existing virtual machines
###################################

Existing virtual machine images from other platforms or hypervisors may
require changes to function on top of Catalyst Cloud. The changes may
require specialised knowledge of the operating system the image is based
on.

.. note::

  Catalyst Cloud does not provide support for images you upload or
  modify to run in Catalyst Cloud. We do not guarantee any compatibility
  with any other platform for images.

********************
Minimum Requirements
********************

The minimum requirements for an existing virtual machine image to be used
in Catalyst Cloud is:

* Intel or AMD "x86" architecture (for c1 compute instances)
* Supports KVM/QEMU ``virtio`` storage and network drivers, and is
  configured to use these for storage and networking
* Uses DHCP on each network interface
* Has ``cloud-init`` or an equivalent package installed
* Linux-based operating system, Windows is not supported for import
* Has the whole boot and OS components in a single disk image, not spread
  over multiple disk images

********************************
Suggested Preparation for Import
********************************

The following steps are suggestions on steps needed to allow a machine
image to be imported and successfully used to start an instance, but may
not be all steps required to support a given application or workload.

Linux
=====

You will need to check that the ``virtio`` drivers are able to be loaded
during boot. By default, these should be available without any need to
modify the system.

However, you can check they are present with the following commands on
the running machine:

.. code-block:: bash

  grep VIRTIO_BLK /boot/config-`uname -r`
  grep VIRTIO_NET /boot/config-`uname -r`

These should return lines like:

.. code-block:: kconfig

  CONFIG_VIRTIO_BLK=m
  CONFIG_VIRTIO_NET=m

If no lines are reported, or they have ``n`` instead of ``m`` or ``y``.
Then the kernel has no support for ``virtio`` drivers and must be changed
to a kernel that does. Changing and selection of a new kernel is outside
the scope of this document.

If the lines end in ``m`` as above, then we need to check the modules are
included in the bootstrap environment used during boot, called ``initrd``.
The following command will check if the ``virtio`` drivers are present
in the bootstrap environment:

.. code-block:: bash

  lsinitramfs /boot/initrd.img-`uname -r` | grep virtio

This should output a number of references including ``virtio_blk`` and
``virtio_net``, the most important two entries to see.

Your machine should have ``/boot`` and the root filesystem in the same
disk image. Although it is possible to create machines with multiple disks
making up different parts of the system, this is an advanced configuration
that requires careful planning and can be very difficult to create and
launch systems in this way.

``cloud-init`` provides tools to query the metadata exposed by Catalyst
Cloud to the server, and is required to ensure features such as
"user data scripts" are picked up and executed by the server. Recent
versions should detect the metadata source provided by Catalyst Cloud
without configuration.

However, if this does need to be configured, the ``OpenStack`` datasource
is the preferred one to use.

Installation of ``cloud-init`` depends on the distribution of Linux your
image uses:

.. tabs::

   .. tab:: Debian/Ubuntu

      .. code-block:: bash

        sudo apt-get install cloud-init

   .. tab:: CentOS 8

      .. code-block:: bash

        sudo dnf -y install cloud-init

Compute instances receive their network configuration from our cloud metadata
agent and DHCP servers. As such, we recommend you configure the network
interfaces to use DHCP instead of a static IP.

.. note::

  Using DHCP does not mean your compute instance will get a different IP every
  time you boot it up. On our cloud, an IP is allocated for your compute
  instance by our compute and network services. This IP will remain the same
  throughout the life-cycle of the compute instance (until it is terminated).
  Each virtual network created by you runs its own DHCP agent that is used
  to lease IPs directed by the compute and network services.

You may also need to remove any persistence rules for network interfaces.
In Debian/Ubuntu, for example, this will purge the persistence rules:

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
on a loop-back device and then change it as required.

.. code-block:: bash

  sudo losetup /dev/loop1 image.raw
  sudo mount /dev/mapper/loop1p1 /mnt

.. warning::

  If you rename a device in fstab to vda, remember you probably need to apply
  the same changes to the boot loader. Don't forget to run update-grub.

Follow the instructions of the next sections (converting the machine image,
uploading an image to the cloud and launching a VM based on a custom image) to
conclude the process.
