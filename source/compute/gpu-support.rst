.. _gpu-support:

##############################
GPU Support in Virtual Servers
##############################

********
Overview
********

Catalyst Cloud provides several options for deloying instances with
NVIDIA GPU acceleration that can be utilised by selecting the desired GPU
:ref:`flavor <instance-types>` when creating the instances.

All GPU instances require suitable drivers to be installed in the
operating system before the GPU can be utilised. This applies to both
operating system images you upload, and to images provided by
Catalyst Cloud.

Instances built using c2-gpu flavors use virtual GPU partitions which have
special driver reqirements. Standard NVIDIA drivers supplied with operating
systems cannot be used for c2-gpu instances. Please refer to the
:ref:`c2-gpu instructions<c2-gpu-support>` for details.

All other GPU instances use direct pass-through of the entire GPU hardware,
so any driver that is compatible with the GPU hardware can be installed.
Catalyst Cloud recommends using drivers supplied by the operating system vendor
or downloaded directly from NVIDIA.

These steps do not apply to Kubernetes worker nodes. For more information
on using GPU with Kubernetes, please refer to the
:doc:`cluster GPU acceleration documentation </kubernetes/gpu-acceleration>`.

******************************
Creating a GPU-backed Instance
******************************

To create a GPU-backed instance, simply :doc:`create an instance <launch-compute-instance>`
using a GPU-backed flavor.

The list of GPU-backed types and which GPUs they provide is listed
under the :ref:`compute-accel-types` section of the Instance types
documentation.

Once the instance is created, suitable GPU drivers will need to be installed
before the GPU can be used.

*********************************
Setup for most GPU instance types
*********************************

These requirements and instructions are for most GPU instance types
except c2-gpu, which has a different process outlined below in :ref:`c2-gpu-support`.

Minimum Requirements
********************

The minimum requirements for GPU instances are as follows:

* A boot/OS disk of at least 30GB (when installing CUDA support).
  Windows instances should use at least 50GB.
* Compatible NVIDIA GPU driver.

The following operating systems have been tested with GPU support:

* Ubuntu LTS 20.04 and later.
* Rocky Linux 8 and later.
* Windows Server 2019 and later.

All other OS images are unsupported and untested.

GPU Driver Installation
***********************

Basic Installation Process
==========================

.. tabs::

    .. tab:: Ubuntu

        The simplest method to install drivers is to use the packages supplied in the
        operating system repositories. The 'server' driver packages are recommended:

        .. code-block:: bash

            sudo apt install nvidia-driver-570-server

        .. note::

            NVIDIA recently began providing the option of either a proprietary or an
            open source driver. As of the 570 release the open source driver does not
            work on g4 (4x GPU) flavours on Catalyst Cloud.

        Once the driver is installed, use ``nvidia-smi`` to verify that the driver is
        loaded and the GPU(s) detected:

        .. code-block::

            $ nvidia-smi
            Mon Jun 30 02:40:15 2025
            +-----------------------------------------------------------------------------------------+
            | NVIDIA-SMI 570.133.20             Driver Version: 570.133.20     CUDA Version: 12.8     |
            |-----------------------------------------+------------------------+----------------------+
            | GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
            | Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
            |                                         |                        |               MIG M. |
            |=========================================+========================+======================|
            |   0  NVIDIA L40S                    Off |   00000000:04:00.0 Off |                    0 |
            | N/A   29C    P0             84W /  350W |       0MiB /  46068MiB |      3%      Default |
            |                                         |                        |                  N/A |
            +-----------------------------------------+------------------------+----------------------+

            +-----------------------------------------------------------------------------------------+
            | Processes:                                                                              |
            |  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
            |        ID   ID                                                               Usage      |
            |=========================================================================================|
            |  No running processes found                                                             |
            +-----------------------------------------------------------------------------------------+

        If that doesn't work, try running ``sudo modprobe nvidia`` to ensure the NVIDIA
        driver is loaded, or reboot the instance.

        Please refer to the :ref:`CUDA section <nvidia-cuda-support>` for instructions on installing the
        CUDA toolkit.

    .. tab:: Microsoft Windows

        To use GPUs in Windows, simply download and install the latest drivers from:

        https://www.nvidia.com/en-us/drivers/

        Select the GPU model according to the flavour being used:

        .. list-table::
           :header-rows: 1

           * - Compute Flavour
             - GPU Model
           * - c1a-gpu
             - NVIDIA RTX A6000
           * - c2a-gpu
             - NVIDIA A100 40GB
           * - c3-gpu
             - NVIDIA L40S

        Once the driver package is installed, verify that it is installed by checking
        the GPU state in Device Manager, or running ``nvidia-smi`` from the command
        prompt.

Automated Driver Installation
=============================

For a more streamlined setup of GPU instances, the necessary GPU driver packages
can be installed via :ref:`user data when creating instances <instance_initialisation>`.
This means the GPU is ready to use within a few minutes of the instance booting
up without requiring additional steps.

.. tabs::

    .. tab:: Linux

        User data example for automatically installing NVIDIA driver release 570 on Ubuntu
        24.04:

        .. code-block:: yaml

            #cloud-config

            package_upgrade: true
            packages:
              - nvidia-driver-570-server

        Other versions of Ubuntu and other distributions may require a different package name.
        Please refer to the documentation for the specific distribution for more examples.

    .. tab:: Microsoft Windows

        Executing the NVIDIA driver installer with the ``/s`` argument runs it silently.
        The examples below specify the 573 release for Windows Server 2022 and 2025 but
        should work with any release if the URL is changed accordingly.

        User data for Windows can be supplied as a straight PowerShell script or cloud-init
        style configuration in YAML format.

        Windows Server 2019 and later include ``curl`` so regular cloud-init style
        config data can be used to run the necessary commands directly:

        .. code-block:: yaml

            #cloud-config

            runcmd:
              - curl -o nvidia.exe https://us.download.nvidia.com/tesla/573.39/573.39-data-center-tesla-desktop-winserver-2022-2025-dch-international.exe
              - nvidia.exe /s

        Alternatively a PowerShell script can be used directly instead:

        .. code-block:: ps1

            #ps1

            Invoke-WebRequest https://us.download.nvidia.com/tesla/573.39/573.39-data-center-tesla-desktop-winserver-2022-2025-dch-international.exe -OutFile nvidia.exe
            nvidia.exe /s

        Refer to the `Cloudbase-Init documentation <https://cloudbase-init.readthedocs.io/en/latest/userdata.html>`_
        for more information on user data configuration options for Windows.

.. _c2-gpu-support:

*******************************
Setup for c2-gpu Instance Types
*******************************

Unlike other GPU-backed types, c2-gpu instances are provided with a partition of
an NVIDIA A100 GPU rather than the entire capacity of the card, using NVIDIA
vGPU services. The partition size provided is "GRID A100D-20C", which
provides two compute pipelines and 20GB of video RAM from the underlying GPU.

vGPUs are isolated in hardware between different consumers, so there is
no risk of information leaking or performance problems from other users
of the same physical GPU.

Minimum Requirements
********************

For c2-gpu, the absolute minimum requirements are as follows:

* A boot/OS disk of at least 30GB (when installing CUDA support)
* Compatible NVIDIA vGPU driver. This is currently version
  535.154.05.

The version of the driver loaded into your virtual server **must** be
exactly this version, and not any other. From time to time we will
update the version needed, and inform you when this updated will be
required on your virtual servers.

.. note::

    Drivers provided by OS or distribution vendors should not be
    installed. Only the drivers specified here will function with
    the vGPUs available.

    Installing Ubuntu HWE kernel packages on Ubuntu is not recommended.

In addition, NVIDIA support only the following server operating
systems for your vGPU virtual server while running in Catalyst Cloud:

* Ubuntu LTS 20.04, 22.04 and 24.04

Tested by Catalyst Cloud, but not supported by NVIDIA are the following
server operating systems:

* Rocky Linux 8, 9

All other OS images are unsupported or untested.

Creating a c2-gpu virtual server
********************************

To create a GPU-enabled virtual server, create an instance using a flavor
prefixed with "c2-gpu".

To help with streamlining c2-gpu server builds we've :ref:`provided examples on
using Packer to build custom images that include GPU drivers and software<packer-tutorial-gpu>`.
This process is recommended for bulk GPU compute deployments.

Installing Drivers for c2-gpu Instances
***************************************

Ubuntu
======

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
    curl -O https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_483553c6e156487eaeefd63a5669151d/gpu-guest-drivers/nvidia/grid/16.7/linux/nvidia-linux-grid-535_535.183.06_amd64.deb
    sudo dpkg -i nvidia-linux-grid-535_535.183.06_amd64.deb

.. note::

    If you get a 404 response to this download, contact Catalyst Cloud
    support as the driver versions may have been updated making this
    documentation outdated.

Next, you will need to install the client license for vGPU support.
Download and save the license to ``/etc/nvidia/ClientConfigToken`` on
your virtual server, using the following steps:

.. code-block:: bash

    (cd /etc/nvidia/ClientConfigToken && curl -O https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_483553c6e156487eaeefd63a5669151d/gpu-guest-drivers/nvidia/grid/licenses/client_configuration_token_12-29-2022-15-20-23.tok)

Edit the GRID driver configuration file ``/etc/nvidia/gridd.conf`` and
ensure that ``FeatureType`` is set to ``1``. Then restart the
``nvidia-gridd`` service. The following commands apply the setting and
restart the service:

.. code-block:: bash

    sudo sed -i -e '/^\(FeatureType=\).*/{s//\11/;:a;n;ba;q}' -e '$aFeatureType=1' /etc/nvidia/gridd.conf
    sudo systemctl restart nvidia-gridd

After the service has been restarted, check the license status of the
vGPU:

.. code-block:: bash

    nvidia-smi -q | grep 'License Status'

This should return a line stating it is "Licensed" with an expiry in
the future.

(Optional) Install the CUDA toolkit, if CUDA support is needed:

.. code-block:: bash

    curl -O https://developer.download.nvidia.com/compute/cuda/12.2.2/local_installers/cuda_12.2.2_535.104.05_linux.run
    sudo sh cuda_12.2.2_535.104.05_linux.run --silent --toolkit

This will run without any visible output for a while, before returning
to a command prompt.

.. note::

    We do not recommend using Debian or Ubuntu packages for the
    installation of CUDA toolkit. Those packages conflicts with
    required driver versions and will break your vGPU support.

To complete CUDA tookit installation, ensure that the CUDA libraries are
available for applications to link and load:

.. code-block:: bash

    sudo tee /etc/ld.so.conf.d/cuda.conf <<< /usr/local/cuda/lib64
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

    curl -O https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_483553c6e156487eaeefd63a5669151d/gpu-guest-drivers/nvidia/grid/16.7/linux/NVIDIA-Linux-x86_64-535.183.06-grid.run
    sudo sh NVIDIA-Linux-x86_64-535.183.06-grid.run -s -Z

.. note::

    If you get a 404 response to this download, contact Catalyst Cloud
    support as the driver versions may have been updated making this
    documentation outdated.

This may produce errors or warnings related to missing X libraries and
Vulkan ICD loader. These warnings can be safely ignored.

It may also produce an error about failing to register with DKMS, if you
installed DKMS support above. This can be safely ignored, the modules
will be rebuilt automatically despite the error message.

Next, you will need to install the client license for vGPU support.
Download and save the license to ``/etc/nvidia/ClientConfigToken`` on
your virtual server, using the following steps:

.. code-block:: bash

    (cd /etc/nvidia/ClientConfigToken && curl -O https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_483553c6e156487eaeefd63a5669151d/gpu-guest-drivers/nvidia/grid/licenses/client_configuration_token_12-29-2022-15-20-23.tok)

Edit the GRID driver configuration file ``/etc/nvidia/gridd.conf`` and
ensure that ``FeatureType`` is set to ``1``. Then restart the ``nvidia-
gridd`` service. The following commands apply the setting and restart
the service:

.. code-block:: bash

    sudo sed -i -e '/^\(FeatureType=\).*/{s//\11/;:a;n;ba;q}' -e '$aFeatureType=1' /etc/nvidia/gridd.conf
    sudo systemctl restart nvidia-gridd

After the service has been restarted, check the license status of the
vGPU:

.. code-block:: bash

    nvidia-smi -q | grep 'License Status'

This should return a line stating it is "Licensed" with an expiry date in
the future.

(Optional) Install the CUDA toolkit, if CUDA support is needed:

.. code-block:: bash

    curl -O https://developer.download.nvidia.com/compute/cuda/12.2.2/local_installers/cuda_12.2.2_535.104.05_linux.run
    sudo sh cuda_12.2.2_535.104.05_linux.run --silent --toolkit

This will run without any visible output for a while, before returning
to a command prompt.

.. note::

    We do not recommend using distribution-provided packages for the
    installation of CUDA toolkit. Those packages conflicts with
    required driver versions and will break your vGPU support.

To complete CUDA tookit installation, ensure that the CUDA libraries are
available for applications to link and load:

.. code-block:: bash

    sudo tee /etc/ld.so.conf.d/cuda.conf <<< /usr/local/cuda/lib64
    sudo ldconfig

.. _nvidia-cuda-support:

************
CUDA Support
************

The CUDA version supported is specific to the NVIDIA driver release version.
For most GPU flavors, simply download the appropriate CUDA toolkit version from
NVIDIA to match the driver release used in the instance:

https://docs.nvidia.com/cuda/cuda-installation-guide-linux/

Some operating systems (e.g. Ubuntu) include CUDA packages in their
repositories that can also be used instead, although they are usually older
versions.

In the case of c2-gpu instances the CUDA toolkit version is currently limited
by driver release 535 which officially supports CUDA 12.2.

NVIDIA provide compatibility libraries to allow applications compiled against
newer CUDA releases to work. There are some caveats to this. Please refer to
the NVIDIA CUDA compatibility guide for more information:

https://docs.nvidia.com/deploy/pdf/CUDA_Compatibility.pdf


CUDA Compatibility for c2-gpu in Ubuntu
=======================================

Catalyst Cloud suggests the following approach to enable CUDA 12.4 compatibility
(for example) with c2-gpu on Ubuntu instances.

Add the NVIDIA CUDA repo and signing keys and update the APT cache:

.. code-block:: bash

    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu$(lsb_release -rs | tr -d .)/x86_64/cuda-keyring_1.1-1_all.deb
    sudo dpkg -i cuda-keyring_1.1-1_all.deb
    sudo apt update

Install the CUDA 12.4 compatibility package:

.. code-block:: bash

    sudo apt install cuda-compat-12-4

When running your application you'll need to set the ``LD_LIBRARY_PATH``
environment variable to the location of the CUDA compatibility libraries, which
in this case is ``/usr/local/cuda-12.4/compat``. For example:

.. code-block:: bash

    LD_LIBRARY_PATH=/usr/local/cuda-12.4/compat /path/to/application

If a different CUDA compatibility level is required then this can be
substituted in the steps above, provided NVIDIA have provided it.

**************
Docker Support
**************

NVIDIA provide documentation on supporting vGPU access from Docker
containers here:

https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
