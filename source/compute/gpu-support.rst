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

All GPU instances use direct pass-through of the entire GPU hardware,
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

.. _gpu-driver-installation:

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
           * - c2-gpu
             - NVIDIA A100 80GB
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


.. _nvidia-cuda-support:

************
CUDA Support
************

The CUDA version supported is specific to the NVIDIA driver release version.
In most cases simply download the appropriate CUDA toolkit version from
NVIDIA to match the driver release used in the instance:

https://docs.nvidia.com/cuda/cuda-installation-guide-linux/

Some operating systems (e.g. Ubuntu) include CUDA packages in their
repositories that can also be used instead, although they are usually older
versions.


**************
Docker Support
**************

NVIDIA provide documentation on supporting GPU access from Docker
containers here:

https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
