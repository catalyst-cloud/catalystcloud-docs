.. _convert_image_to_raw:

#################
Converting images
#################

Please make sure your image is a RAW image before uploading.

While you can use QCOW2 images, they do not support copy-on-write operations.
As a result, launching compute instances from these images or taking snapshots
will take longer.

**************************
Tools for image conversion
**************************

Ensure you have the qemu-utils package installed, as it provides the tools
required to convert a disk image.

On Debian or Ubuntu:

.. code-block:: bash

  sudo apt-get install qemu-utils

On Fedora or CentOS:

.. code-block:: bash

  sudo yum install qemu-img

*****************
Converting to RAW
*****************

From KVM QCOW2 to RAW
=====================

On a host with qemu-utils installed, convert the QCOW2 disk to a RAW disk:

.. code-block:: bash

  qemu-img convert -O raw kvm-image.qcow2 raw-image.raw

From VMWare VMDK to RAW
=======================

On a host with qemu-utils installed, convert the VMDK disk to a RAW disk:

.. code-block:: bash

  qemu-img convert -O raw vmware-image.vmdk raw-image.raw
