#############
Image service
#############

.. _images:

***************************
Images provided by Catalyst
***************************

Catalyst provides some pre-configured operating system images to make it easier
for you to get started on the cloud.

The table below lists the images provided by Catalyst and our partners, as well
as the default user name you should use to log to each one of them (unless you
have overwritten the default user name with cloud-init).

+------------------+-----------+
| Operating system | User-name |
+==================+===========+
| Atomic Linux     | centos    |
+------------------+-----------+
| CentOS Linux     | centos    |
+------------------+-----------+
| CoreOS Linux     | coreos    |
+------------------+-----------+
| Debian Linux     | debian    |
+------------------+-----------+
| Ubuntu Linux     | ubuntu    |
+------------------+-----------+
| Windows          | admin     |
+------------------+-----------+


.. note::

  The orchestration service (Heat) changes the default user name on compute
  instances launched by it to "ec2". This is done to preserve some level of
  compatibility with AWS CloudFormation.

Our standard policy is not to modify or customise cloud images provided by
upstream Linux distributions. This gives you the assurance that you are running
software exactly as provided by the software providers.

Before using the images provided by Catalyst, you should always confirm that
they are suitable for your needs and fit for purpose. Catalyst provides them
"as is", without warranty of any kind. If there is something you need to
change, you can always upload your own images, crafted the way you like, or
take a snapshot of ours and modify it the way you need.

How can I identify the images provided by Catalyst?
===================================================

The images provided by Catalyst are uploaded to tenant ID
``94b566de52f9423fab80ceee8c0a4a23`` and are made public. With the command line
tools, you can easily located them by running:

.. code-block:: bash

  glance image-list --owner 94b566de52f9423fab80ceee8c0a4a23



*******************************
Creating your own custom images
*******************************

The OpenStack upstream documentation provides detailed instructions on how to
prepare all major operating systems to run in the cloud:
https://docs.openstack.org/image-guide/create-images-manually.html

Another method for creating custom images is to use `Packer`_. Packer is an
open source tool developed by `Hashicorp`_ for creating machine images for
multiple platforms from a single source configuration. We have made a tutorial
entitled :ref:`packer-tutorial` that demonstrates how to use Packer.

.. _Packer: https://www.packer.io/
.. _Hashicorp: https://www.hashicorp.com/

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

Follow the instructions of the next sections (converting the machine image,
uploading an image to the cloud and launching a VM based on a custom image) to
conclude the process.


****************************
Converting the machine image
****************************

Please make sure you have converted your image to RAW before uploading it to
our cloud. While QCOW2 images will also work, they will not support copy on
write operations. As a result, launching compute instances from these images or
taking snapshots will take longer.

Tools for image convertion
==========================

Ensure you have the qemu-utils package installed, as it provides the tools
required to convert the disk images.

On Debian or Ubuntu:

.. code-block:: bash

  sudo apt-get install qemu-utils

On Fedora or CentOS:

.. code-block:: bash

  sudo yum install qemu-img

Converting to RAW
=================

From KVM QCOW2 to RAW
---------------------

On a host with QEMU installed, convert the QCOW2 disk to a RAW disk:

.. code-block:: bash

  qemu-img convert -O raw kvm-image.qcow2 raw-image.raw

From VMWare VMDK to RAW
-----------------------

On a host with QEMU installed, convert the VMDK disk to a RAW disk:

.. code-block:: bash

  qemu-img convert -O raw vmware-image.vmdk raw-image.raw


*******************************
Uploading an image to the cloud
*******************************

Please make sure you have converted your image to RAW before uploading it to
our cloud. The previous section provides instructions on how to convert images
from other formats to RAW.

Via the web dashboard
=====================

On the images panel, click on create image. The create image dialogue will be
displayed as shown below:

.. image:: _static/image-create.png

On the image source, select "Image Location" to provide the URL that the image
should be downloaded from, or select "Image File" to upload an image from your
file system.

Select the appropriate format for your image. We strongly recommend the use of
RAW images.

Set the minimum disk size to at least the size of the image. If you are using a
compressed format, like QCOW2, use the expanded size of the image.

Click on create image and wait until the image has been downloaded or uploaded.

Via the command line tools
==========================

If the image is larger than 5GB, we recommend using the OpenStack CLI to upload
it to the cloud. Ensure that you have the OpenStack command line tools
installed and that you have sourced an openrc file, as explained on
:ref:`command-line-interface`.

To upload the converted image to the Catalyst Cloud:

.. code-block:: bash

  glance image-create --disk-format raw --container-format bare --file
  raw-image.raw --name image-name --is-public=False --progress


*****************************************
Launching an instance from a custom image
*****************************************

On the dashboard you will find the image you uploaded on “Images & Snapshots”
under your private images. Click on the Launch button and:

* Select “Boot from image (creates a new volume).” as the instance boot source.
* Ensure the device size is at least the same size as the image uploaded.
* If you are importing an existing virtual machine, for its first boot you
  should choose a flavour that provides at least the same amount of CPU and RAM
  the VM had before. Once you confirm the compute instance is booting
  appropriately, if desirable, you can resize it to a smaller flavour.

.. warning::

  Remember that your VM has been imported exactly as it was before, therefore
  there might be some things that may prevent you from connecting to it
  remotely (for example: a host base firewall blocking connections). You can
  use the console and your existenting user credentials to connect to your
  compute instance and make adjustments to its configuration as required.

*******************************
Sharing images between projects
*******************************

You may need to share custom images created in one project (tenant) with
another project, the following section describes how to achieve this.

.. note::

 Some commands need to be issued when connected to the source project and some
 when connected to the target, ensure you are connected to the correct project
 when issuing these commands.

While connected to the source project find the id of the image you wish to
share:

.. code-block:: bash

  $ openstack image show -c id -f value ubuntu1604_base_packer
  55d3168c-dbdc-40d9-8ee6-96aff4f9e741

While connected to the target project issue the following command to find the
project id:

.. code-block:: bash

 $ openstack configuration show -c auth.project_id -f value
 1234567892b04ed38247bab7d808e214

Now we can proceed to share the image from the source project with the target
project. While connected to the source project issue the following command:

.. code-block:: bash

 $ openstack image add project 55d3168c-dbdc-40d9-8ee6-96aff4f9e741 1234567892b04ed38247bab7d808e214
 +------------+--------------------------------------+
 | Field      | Value                                |
 +------------+--------------------------------------+
 | created_at | 2016-11-17T02:52:24Z                 |
 | image_id   | 55d3168c-dbdc-40d9-8ee6-96aff4f9e741 |
 | member_id  | 1234567892b04ed38247bab7d808e214     |
 | schema     | /v2/schemas/member                   |
 | status     | pending                              |
 | updated_at | 2016-11-17T02:52:24Z                 |
 +------------+--------------------------------------+

Next ensure we can see the shared image in the target project:

.. code-block:: bash

 $ glance --os-image-api-version 2 image-list --member-status pending --visibility shared
 +--------------------------------------+-----------------------------+
 | ID                                   | Name                        |
 +--------------------------------------+-----------------------------+
 | 55d3168c-dbdc-40d9-8ee6-96aff4f9e741 | ubuntu1604_base_packer      |
 +--------------------------------------+-----------------------------+

Finally we accept the image in the target project:

.. code-block:: bash

 $ glance --os-image-api-version 2 member-update 55d3168c-dbdc-40d9-8ee6-96aff4f9e741 1234567892b04ed38247bab7d808e214 accepted
 +--------------------------------------+----------------------------------+----------+
 | Image ID                             | Member ID                        | Status   |
 +--------------------------------------+----------------------------------+----------+
 | 55d3168c-dbdc-40d9-8ee6-96aff4f9e741 | 1234567892b04ed38247bab7d808e214 | accepted |
 +--------------------------------------+----------------------------------+----------+

.. note::

 The last two commands are using the older glance client, this will be updated
 as soon as the openstack client supports accepting images.

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

