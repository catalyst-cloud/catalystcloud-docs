.. _packer-tutorial-gpu:

##########################################################
Using Packer to build images with GPU drivers and software
##########################################################


This tutorial demonstrates how to use Packer to build an image that includes
GPU drivers and CUDA libraries in Catalyst Cloud. Creating such an image can
significantly reduce time spent setting up instances requiring GPU support,
particularly when deploying multiple GPU compute instances.

This document is based on a combination of the following tutorials:

* :ref:`gpu-support`
* :ref:`packer-tutorial`

For the purposes of this tutorial we'll be building an image based on Ubuntu
22.04 "Jammy Jellyfish" and installing the NVIDIA driver and CUDA library
versions according to the :ref:`GPU compute setup guide<gpu-support>`.

*************
Prerequisites
*************

To complete this tutorial you will need the following:

* :ref:`A network created<adding-networks>` in your cloud project with Internet
  access that the temporary instance can be connected to.
* :ref:`A security group<security-groups>` in your cloud project that permits
  inbound SSH access.
* :ref:`Openrc file<source-rc-file>` for your Catalyst Cloud project sourced
  in your shell.
* `Packer must be installed <https://developer.hashicorp.com/packer/downloads>`_
  on your system.
* Sufficient quota capacity in your cloud project for Packer to create the
  temporary resources required to build the image.

Note that you can run this process from either your own workstation or a cloud
instance. The steps below assume this is being run from a workstation, and any
changes necessary for running this on a cloud instance are described in the
respective steps.

Packer will automatically create a temporary SSH key, virtual server and
floating IP address and clean them up once it has finished.

********************************************
Image build process
********************************************

1.  Obtain the IDs of the flavour and image to build the temporary instance
    from, and the network and security group to attach to it. We can also set
    a name for the image we are creating:

    .. code:: bash

        export FLAVOR_ID=$(openstack flavor show -f value -c id c2-gpu.c4r80g1)
        export NETWORK_ID=$(openstack network show -f value -c id demo-network1)
        export SECURITY_GROUP=$(openstack security group show -f value -c id demo-ssh-admin)
        export SOURCE_IMAGE_ID=$(openstack image show -f value -c id ubuntu-22.04-x86_64)
        export DEST_IMAGE_NAME="ubuntu-22.04-cuda"

    In the above example the network name is ``demo-network1``; you will need
    to substitute this with the name of your own chosen network.

    You can also substitute the destination image name with a value of your
    choosing.

    If any of the above commands fail, resolve the cause before continuing with
    the next step.

2.  If you are performing these steps from your workstation, set the public
    network ID for your region. Skip this step if you are running Packer on
    another cloud instance:

    .. code:: bash

        export FLOATING_IP_NETWORK=$(openstack network show -f value -c id public-net)

3.  Create a Packer build template by running the script below:

    .. code:: bash

        cat << EOF > catalyst-gpu.json
        {
            "builders": [
                {
                    "type": "openstack",
                    "identity_endpoint": "$OS_AUTH_URL",
                    "region": "$OS_REGION_NAME",
                    "image_name": "$DEST_IMAGE_NAME",
                    "source_image": "$SOURCE_IMAGE_ID",
                    "flavor": "$FLAVOR_ID",
                    "floating_ip_network": "$FLOATING_IP_NETWORK",
                    "networks": [
                        "$NETWORK_ID"
                    ],
                    "security_groups": [
                        "$SECURITY_GROUP"
                    ],
                    "volume_size": 30,
                    "ssh_username": "ubuntu",
                    "ssh_ip_version": "4"
                }
            ],
            "provisioners": [
                {
                    "type": "shell",
                    "inline": [
                        "set -e",
                        "sudo apt update",
                        "sudo apt -y dist-upgrade"
                    ]
                },
                {
                    "type": "shell",
                    "expect_disconnect": true,
                    "inline": "sudo reboot"
                },
                {
                    "type": "shell",
                    "pause_before": "90s",
                    "inline": [
                        "set -e",
                        "sudo apt update",
                        "sudo apt install -y dkms",
                        "curl -O https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_483553c6e156487eaeefd63a5669151d/gpu-guest-drivers/nvidia/grid/15.0/linux/nvidia-linux-grid-525_525.60.13_amd64.deb",
                        "sudo dpkg -i nvidia-linux-grid-525_525.60.13_amd64.deb",
                        "rm -f nvidia-linux-grid-525_525.60.13_amd64.deb",
                        "sudo mkdir -p /etc/nvidia/ClientConfigToken",
                        "(cd /etc/nvidia/ClientConfigToken && sudo curl -O https://object-storage.nz-por-1.catalystcloud.io/v1/AUTH_483553c6e156487eaeefd63a5669151d/gpu-guest-drivers/nvidia/grid/licenses/client_configuration_token_12-29-2022-15-20-23.tok)",
                        "sudo sed -i -e '/^\\\(FeatureType=\\\).*/{s//\\\11/;:a;n;ba;q}' -e '\$aFeatureType=1' /etc/nvidia/gridd.conf",
                        "sudo systemctl restart nvidia-gridd",
                        "curl -O https://developer.download.nvidia.com/compute/cuda/12.0.0/local_installers/cuda_12.0.0_525.60.13_linux.run",
                        "echo 'Installing CUDA. This may take a few minutes...'",
                        "sudo sh cuda_12.0.0_525.60.13_linux.run --silent --toolkit",
                        "rm -f cuda_12.0.0_525.60.13_linux.run",
                        "echo /usr/local/cuda/lib64 | sudo tee /etc/ld.so.conf.d/cuda.conf",
                        "sudo ldconfig",
                        "sudo systemctl stop cloud-init",
                        "sudo rm -rf /var/lib/cloud/"
                    ]
                }
            ]
        }
        EOF

4.  Run Packer to validate the configuration and then build the image:

    .. code:: bash

        packer validate catalyst-gpu.json
        packer build catalyst-gpu.json

    Note that this process may take half an hour or so to complete.

5.  Verify that the new image is available:

    .. code::

        openstack image show $DEST_IMAGE_NAME

At this stage you can deploy new GPU instances using your custom image. Once
they boot up, applications that require GPU access should be able to run
without any further configuration action required.
