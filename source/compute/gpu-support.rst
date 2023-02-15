.. _gpu-support:

##############################
GPU Support in Virtual Servers
##############################

**********************
c2-gpu Virtual Servers
**********************

Each c2-gpu instance type includes one or more slices of NVIDIA A100
GPUs. The slice size provided is "GRID A100D-20C", which provides
2 compute pipelines and 20GB of video RAM from the card.

.. warning::

    c2-gpu virtual servers are in Technical Preview only

Minimum Requirements
====================

For "c2-gpu", the absolute minimum requirements are as follows:

* A boot/OS disk of at least 30GB (when installing CUDA support)
* NVIDIA vGPU driver from the v15.0 series. This is currently version
  525.60.12.

The version of the driver loaded into your virtual server **must** be
exactly this version, and not any other. From time to time we will
update the version needed, and inform you when this updated will be
required on your virtual servers.

.. note::

    Drivers provided by OS or distribution vendors should not be
    installed. Only the drivers specified here will function with
    the vGPUs available.

In addition, NVIDIA support only the following server operating
systems for your vGPU virtual server while running in Catalyst Cloud:

* Ubuntu 22.04, 20.04

Tested by Catalyst Cloud, but not supported by NVIDIA are the following
server operating systems:

* Rocky Linux 8, 9

All other OS images are unsupported or untested.

Creating a c2-gpu virtual server
================================

Catalyst Cloud is not permitted to modify any OS image we provide
to you, so driver installation must take place after the instance
has been created.

Ubuntu
******

Once you have created an Ubuntu virtual server using a version supported
by the NVIDIA drivers, you will need to perform the following steps.

First, ensure all packages are up to date on your server and it is
running the latest kernel (which will require a reboot):

.. code-block:: bash

    sudo apt update
    sudo apt dist-upgrade -y
    sudo reboot

Then download and install the GRID driver package.

.. code-block:: bash

    sudo apt install -y dkms
    curl -O https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_483553c6e156487eaeefd63a5669151d/gpu-guest-drivers/nvidia/grid/15.0/linux/nvidia-linux-grid-525_525.60.13_amd64.deb
    sudo dpkg -i nvidia-linux-grid-525_525.60.13_amd64.deb

Next, you will need to install the client license for vGPU support.
Download and save the license to ``/etc/nvidia/ClientConfigToken`` on
your virtual server, using the following steps:

.. code-block:: bash

    cd /etc/nvidia/ClientConfigToken && curl -O https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_483553c6e156487eaeefd63a5669151d/gpu-guest-drivers/nvidia/grid/licenses/client_configuration_token_12-29-2022-15-20-23.tok

Edit the GRID driver configuration file ``/etc/nvidia/gridd.conf`` and
ensure that ``FeatureType`` is set to ``1``. Then restart the NVIDIA
``gridd`` daemon. The following commands apply the setting and restart
the daemon:

.. code-block:: bash

    sudo sed -i -e '/^\(FeatureType=\).*/{s//\11/;:a;n;ba;q}' -e '$aFeatureType=1' /etc/nvidia/gridd.conf
    sudo systemctl restart nvidia-gridd

After the daemon has been restarted, check the license status of the
vGPU:

.. code-block:: bash

    nvidia-smi -q | grep 'License Status'

This should return a line stating it is "Licensed" with an expiry in
the future.

(Optional) Install the CUDA toolkit, if CUDA support is needed:

.. code-block:: bash

    curl -O https://developer.download.nvidia.com/compute/cuda/12.0.0/local_installers/cuda_12.0.0_525.60.13_linux.run
    sudo sh cuda_12.0.0_525.60.13_linux.run --silent --toolkit

This will run without any visible output for a while, before returning
to a command prompt.

.. note::

    We do not recommend using Debian or Ubuntu packages for the
    installation of CUDA toolkit. Those packages conflicts with
    required driver versions and will break your vGPU support.

To complete CUDA tookit installation, ensure that the CUDA libraries are
available for applications to link and load:

.. code-block:: bash

    sudo tee /etc/ld.so.conf.d/cuda.conf << /usr/local/cuda/lib64
    sudo ldconfig

RHEL-derived Distributions
**************************

Linux distributions derived from RHEL, such as Rocky Linux, need the
following steps to install the drivers.

.. note::

    NVIDIA do not support RHEL-derived Linux distributions on
    Catalyst Cloud

First, ensure all packages are up to date on your server and it is
running the latest kernel:

.. code-block:: bash

    sudo dnf update -y && sudo reboot

Then install kernel source and related development tools:

.. code-block:: bash

    sudo dnf install -y kernel-devel make

(Optional) Next, enable EPEL repositories and install DKMS support. This
will automatically rebuild the drivers on kernel upgrades, rather than
forcing you to re-install the GRID drivers every time the kernel is
updated.

.. code-block:: bash

    sudo dnf install -y epel-release
    sudo dnf install -y dkms

Then install the GRID driver package:

.. code-block:: bash

    curl -O https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_483553c6e156487eaeefd63a5669151d/gpu-guest-drivers/nvidia/grid/15.0/linux/NVIDIA-Linux-x86_64-525.60.13-grid.run
    sudo sh NVIDIA-Linux-x86_64-525.60.13-grid.run -s -Z

This may produce errors or warnings related to missing X libraries and
Vulkan ICD loader. These warnings can be safely ignored.

It may also produce an error about failing to register with DKMS, if you
installed DKMS support above. This can be safely ignored, the modules
will be rebuilt automatically despite the error message.

Next, you will need to install the client license for vGPU support.
Download and save the license to ``/etc/nvidia/ClientConfigToken`` on
your virtual server, using the following steps:

.. code-block:: bash

    cd /etc/nvidia/ClientConfigToken && curl -O https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_483553c6e156487eaeefd63a5669151d/gpu-guest-drivers/nvidia/grid/licenses/client_configuration_token_12-29-2022-15-20-23.tok

Edit the GRID driver configuration file ``/etc/nvidia/gridd.conf`` and
ensure that ``FeatureType`` is set to ``1``. Then restart the NVIDIA
``gridd`` daemon. The following commands apply the setting and restart
the daemon:

.. code-block:: bash

    sudo sed -i -e '/^\(FeatureType=\).*/{s//\11/;:a;n;ba;q}' -e '$aFeatureType=1' /etc/nvidia/gridd.conf
    sudo systemctl restart nvidia-gridd

After the daemon has been restarted, check the license status of the
vGPU:

.. code-block:: bash

    nvidia-smi -q | grep 'License Status'

This should return a line stating it is "Licensed" with an expiry in
the future.

(Optional) Install the CUDA toolkit, if CUDA support is needed:

.. code-block:: bash

    curl -O https://developer.download.nvidia.com/compute/cuda/12.0.0/local_installers/cuda_12.0.0_525.60.13_linux.run
    sudo sh cuda_12.0.0_525.60.13_linux.run --silent --toolkit

This will run without any visible output for a while, before returning
to a command prompt.

.. note::

    We do not recommend using distribution-provided packages for the
    installation of CUDA toolkit. Those packages conflicts with
    required driver versions and will break your vGPU support.

To complete CUDA tookit installation, ensure that the CUDA libraries are
available for applications to link and load:

.. code-block:: bash

    sudo tee /etc/ld.so.conf.d/cuda.conf << /usr/local/cuda/lib64
    sudo ldconfig

**************
Docker Support
**************

NVIDIA provide documentation on supporting vGPU access from Docker
containers here:

https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html

