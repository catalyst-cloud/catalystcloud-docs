#####################################################
Deploying a turnkey Linux image on the Catalyst Cloud
#####################################################

This tutorial assumes you have installed the OpenStack command line tools and
sourced an openrc file, as explained at :ref:`command-line-interface`. We also
assume that you have uploaded an SSH key, as explained at
:ref:`uploading-an-ssh-key`.

Introduction
============

In this tutorial you will learn how to deploy a `Turnkey Linux`_ image onto the
Catalyst Cloud using the command line tools.

.. _Turnkey Linux: https://www.turnkeylinux.org/

Pre-requisites and Setup
========================

First, retrieve the required image from `Turnkey Linux`_, for this
example you will use the following image ``turnkey-core-14.1-jessie-amd64``.

The following steps need to be completed on a machine that has API access to
the Catalyst Cloud. If your location has not been whitelisted to allow for this
you can deploy a bare bones Linux instance in the Catalyst Cloud and
complete the following steps from there.

Download the ``Turnkey Linux`` image to your machine, extract the archive and
change into the directory containing the image files.

.. code-block:: bash

  $ tar zxvf turnkey-core-14.1-jessie-amd64-openstack.tar.gz
  $ cd turnkey-core-14.1-jessie-amd64/
  $ ls -l
  total 657176
  -rw-r--r-- 1 glyndavies glyndavies 900616192 Apr 12 13:20 turnkey-core-14.1-jessie-amd64.img
  -rw-r--r-- 1 glyndavies glyndavies  15755328 Apr 12 13:20 turnkey-core-14.1-jessie-amd64-initrd
  -rw-r--r-- 1 glyndavies glyndavies   3120288 Apr 12 13:20 turnkey-core-14.1-jessie-amd64-kernel

Creating the images
===================

Three images need to be created to allow this to work correctly.
These are the ramdisk image, the kernel image and that actual
Turnkey image we are looking to deploy.

First we will create the ramdisk image and store its ID in an environment
variable called ``TL_RAMDISK_ID``.

.. code-block:: bash

  $ openstack image create --container-format ari --disk-format ari --file turnkey-core-14.1-jessie-amd64-initrd turnkey-initrd
  +------------------+----------------------------------------------------------------------------------------------------------+
  | Field            | Value                                                                                                    |
  +------------------+----------------------------------------------------------------------------------------------------------+
  | checksum         | fe64cdf0556012f6453d7ef15c0a205e                                                                         |
  | container_format | ari                                                                                                      |
  | created_at       | 2016-09-12T02:34:19Z                                                                                     |
  | disk_format      | ari                                                                                                      |
  | file             | /v2/images/5115c995-d7f2-4499-8a21-885cff137912/file                                                     |
  | id               | 5115c995-d7f2-4499-8a21-885cff137912                                                                     |
  | min_disk         | 0                                                                                                        |
  | min_ram          | 0                                                                                                        |
  | name             | turnkey-initrdturnkey-initrd                                                                             |
  | owner            | <OWNER_ID>                                                                                               |
  | properties       | direct_url='rbd://b0849a66-357e-4428-a84c-f5ccd277c076/images/5115c995-d7f2-4499-8a21-885cff137912/snap' |
  | protected        | False                                                                                                    |
  | schema           | /v2/schemas/image                                                                                        |
  | size             | 15755328                                                                                                 |
  | status           | active                                                                                                   |
  | tags             |                                                                                                          |
  | updated_at       | 2016-09-12T02:34:20Z                                                                                     |
  | virtual_size     | None                                                                                                     |
  | visibility       | private                                                                                                  |
  +------------------+----------------------------------------------------------------------------------------------------------+

  $ TL_RAMDISK_ID=$(openstack image show turnkey-initrd -c id -f value) && echo $TL_RAMDISK_ID

Next we create the kernel image and store its ID in ``TL_KERNEL_ID``.

.. code-block:: bash

  $ openstack image create --container-format aki --disk-format aki --file turnkey-core-14.1-jessie-amd64/turnkey-core-14.1-jessie-amd64-kernel turnkey-kernel
  +------------------+----------------------------------------------------------------------------------------------------------+
  | Field            | Value                                                                                                    |
  +------------------+----------------------------------------------------------------------------------------------------------+
  | checksum         | 9ea41f0f085e2de0939984a3d4b6a707                                                                         |
  | container_format | aki                                                                                                      |
  | created_at       | 2016-09-12T02:34:35Z                                                                                     |
  | disk_format      | aki                                                                                                      |
  | file             | /v2/images/9cc60e22-1553-450e-9cec-9fefd6591200/file                                                     |
  | id               | 9cc60e22-1553-450e-9cec-9fefd6591200                                                                     |
  | min_disk         | 0                                                                                                        |
  | min_ram          | 0                                                                                                        |
  | name             | turnkey-kernel                                                                                           |
  | owner            | <OWNER_ID>                                                                                               |
  | properties       | direct_url='rbd://b0849a66-357e-4428-a84c-f5ccd277c076/images/9cc60e22-1553-450e-9cec-9fefd6591200/snap' |
  | protected        | False                                                                                                    |
  | schema           | /v2/schemas/image                                                                                        |
  | size             | 3120288                                                                                                  |
  | status           | active                                                                                                   |
  | tags             |                                                                                                          |
  | updated_at       | 2016-09-12T02:34:37Z                                                                                     |
  | virtual_size     | None                                                                                                     |
  | visibility       | private                                                                                                  |
  +------------------+----------------------------------------------------------------------------------------------------------+

  $ TL_KERNEL_ID=$(openstack image show turnkey-kernel -c id -f value) && echo $TL_KERNEL_ID

Finally we create the ``Turnkey`` image:

.. code-block:: bash

  $ openstack image create --disk-format ami --property ramdisk_id=$TL_RAMDISK_ID --property kernel_id=$TL_KERNEL_ID --file turnkey-core-14.1-jessie-amd64.img turnkey-img
  +------------------+----------------------------------------------------------------------------------------------------------+
  | Field            | Value                                                                                                    |
  +------------------+----------------------------------------------------------------------------------------------------------+
  | checksum         | e2642a2e2ffaddd0785a48ff19be9598                                                                         |
  | container_format | bare                                                                                                     |
  | created_at       | 2016-09-12T02:41:33Z                                                                                     |
  | disk_format      | ami                                                                                                      |
  | file             | /v2/images/7af4b047-15c3-4d82-92df-9ae57b42cba8/file                                                     |
  | id               | 7af4b047-15c3-4d82-92df-9ae57b42cba8                                                                     |
  | min_disk         | 0                                                                                                        |
  | min_ram          | 0                                                                                                        |
  | name             | turnkey-img                                                                                              |
  | owner            | <OWNER_ID>                                                                                               |
  | properties       | direct_url='rbd://b0849a66-357e-4428-a84c-f5ccd277c076/images/7af4b047-15c3-4d82-92df-                   |
  |                  | 9ae57b42cba8/snap', kernel_id='9cc60e22-1553-450e-9cec-9fefd6591200',                                    |
  |                  | ramdisk_id='5115c995-d7f2-4499-8a21-885cff137912'                                                        |
  | protected        | False                                                                                                    |
  | schema           | /v2/schemas/image                                                                                        |
  | size             | 900616192                                                                                                |
  | status           | active                                                                                                   |
  | tags             |                                                                                                          |
  | updated_at       | 2016-09-12T02:41:54Z                                                                                     |
  | virtual_size     | None                                                                                                     |
  | visibility       | private                                                                                                  |
  +------------------+----------------------------------------------------------------------------------------------------------+

  $ TL_TURNKEY_ID=$(openstack image show turnkey-img -c id -f value) && echo $TL_TURNKEY_ID

Deploy the Turnkey image
========================

Now that you have a local version of the ``Turnkey Linux`` image hosted on the
Catalyst Cloud, you can use this to create your new instance. Once again you will
do this using the command line tools, and pass in parameters using environment
variables.

.. code-block:: bash

  $ export CC_FLAVOR_ID=$( openstack flavor show c1.c1r1 -f value -c id )
  $ export CC_SECURITY_GROUP_ID=$( openstack security group show example-security-grp -f value -c id )
  $ export CC_PRIVATE_NETWORK_ID=$( openstack network show private-net -f value -c id )

  $ openstack server create --flavor $CC_FLAVOR_ID --image $TL_TURNKEY_ID \
  --key-name example-key --security-group default \
  --security-group $CC_SECURITY_GROUP_ID \
  --nic net-id=$CC_PRIVATE_NETWORK_ID turnkey-instance

  +--------------------------------------+-----------------------------------------------------------------------------+
  | Field                                | Value                                                                       |
  +--------------------------------------+-----------------------------------------------------------------------------+
  | OS-DCF:diskConfig                    | MANUAL                                                                      |
  | OS-EXT-AZ:availability_zone          |                                                                             |
  | OS-EXT-STS:power_state               | NOSTATE                                                                     |
  | OS-EXT-STS:task_state                | scheduling                                                                  |
  | OS-EXT-STS:vm_state                  | building                                                                    |
  | OS-SRV-USG:launched_at               | None                                                                        |
  | OS-SRV-USG:terminated_at             | None                                                                        |
  | accessIPv4                           |                                                                             |
  | accessIPv6                           |                                                                             |
  | addresses                            |                                                                             |
  | adminPass                            | GTDNrKEdYa8S                                                                |
  | config_drive                         |                                                                             |
  | created                              | 2016-09-12T22:22:03Z                                                        |
  | flavor                               | c1.c1r1 (28153197-6690-4485-9dbc-fc24489b0683)                              |
  | hostId                               |                                                                             |
  | id                                   | 8f969202-2cfa-472d-94c5-afc2417e72b0                                        |
  | image                                | turnkey-img (1711d56a-f963-433d-b6ab-34cc4dd2f63c)                          |
  | key_name                             | example-ket                                                                 |
  | name                                 | turnkey-instance                                                            |
  | os-extended-volumes:volumes_attached | []                                                                          |
  | progress                             | 0                                                                           |
  | project_id                           | <PROJECT_ID>                                                                |
  | properties                           |                                                                             |
  | security_groups                      | [{u'name': u'default'}, {u'name': u'60467ab2-c004-4502-b91c-d004cffcb688'}] |
  | status                               | BUILD                                                                       |
  | updated                              | 2016-09-12T22:22:04Z                                                        |
  | user_id                              | <USER_ID>                                                                   |
  +--------------------------------------+-----------------------------------------------------------------------------+

Once the following command shows your new instance as active, you will be able
to associate a floating IP with your new instance and access it via SSH.

.. code-block:: bash

  $ openstack server list
  +--------------------------------------+-------------------------+---------+--------------------------------------------+
  | ID                                   | Name                    | Status  | Networks                                   |
  +--------------------------------------+-------------------------+---------+--------------------------------------------+
  | 8f969202-2cfa-472d-94c5-afc2417e72b0 | first-instance          | ACTIVE  | private-net=192.168.100.43                 |
  +--------------------------------------+-------------------------+---------+--------------------------------------------+

.. note::

  * The Turnkey Linux instances will expect you to SSH initially as root
    ``ssh root@<floating-ip>`` and complete the initial setup steps.
  * Turnkey images also provide a web console for administration purposes. If
    you are having trouble connecting to this, please ensure that your security
    group/s are configured to provide appropriate access.
