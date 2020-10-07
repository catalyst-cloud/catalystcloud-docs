
############################
Converting the machine image
############################

Please make sure you have converted your image to RAW before uploading it to
our cloud. While QCOW2 images will also work, they will not support
copy-on-write operations. As a result, launching compute instances from these
images or taking snapshots will take longer.

**************************
Tools for image conversion
**************************

Ensure you have the qemu-utils package installed, as it provides the tools
required to convert the disk images.

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

On a host with QEMU installed, convert the QCOW2 disk to a RAW disk:

.. code-block:: bash

  qemu-img convert -O raw kvm-image.qcow2 raw-image.raw

From VMWare VMDK to RAW
=======================

On a host with QEMU installed, convert the VMDK disk to a RAW disk:

.. code-block:: bash

  qemu-img convert -O raw vmware-image.vmdk raw-image.raw
