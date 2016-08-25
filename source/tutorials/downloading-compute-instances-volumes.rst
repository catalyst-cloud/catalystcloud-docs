hel########################################
Downloading compute instance's volume(s)
########################################

Volumes can be copied from the block storage service to the image service and
downloaded using the glance client.

This tutorial assumes you have installed the OpenStack command line tools and
sourced an openrc file, as explained on :ref:`command-line-tools`.

Identifying the volume(s)
=========================

The ``openstack volume list`` command can be used to list all volumes available.

The ``openstack server show`` command can be used to identity the volumes that
are attached to a given compute instance:

.. code-block:: bash

  openstack server show <instance-name-or-id> | grep "volumes_attached"

Uploading the volume
====================

The procedure to upload a volume will vary depending on whether the volume is
attached to an instance (active) or not.

Uploading a detached (inactive) volume
--------------------------------------

With thos command ``openstack image create --volume <volume-name-or-id>
<image-name>`` detached volume can be uploaded to the image service:

.. code-block:: bash


  openstack image create --volume imgvol imgvol-img
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | container_format    | bare                                 |
  | disk_format         | raw                                  |
  | display_description |                                      |
  | id                  | 14c25834-b7ae-4a36-b947-881d031017f1 |
  | image_id            | 11f636db-0d15-4e97-88a0-244f25558f0b |
  | image_name          | imgvol-img                           |
  | size                | 11                                   |
  | status              | uploading                            |
  | updated_at          | 2016-08-23T02:45:34.000000           |
  | volume_type         | b1.standard                          |
  +---------------------+--------------------------------------+


Uploading an attached (active) volume
-------------------------------------

To upload an active volume (a volume that is currently attached to a compute
instance and in use), you must first take a snapshot of the volume using the
``openstack snapshot create`` command and then create a new (inactive) volume from
it using the ``cinder volume-create`` command.

To take a snapshot of an active volume:

.. code-block:: bash

  openstack snapshot create --name extra-disk-ss2 --force extra-disk

To show a list of all snapshots:

.. code-block:: bash

  openstack snapshot list

The command below can be used to create a new volume based on a snapshot.
Please note that the volume size should match the snapshot size.

.. code-block:: bash

  openstack volume create --snapshot <snapshot-name-or-id> --size <size> <new-volume-name>

Downloading the image
=====================

Copying a volume from the block storage service to the image service can take
some time (depending on volume size). First, you should confirm that the upload
has finished (status shown as active), using the command below:

.. code-block:: bash

  openstack image show <image-name-or-id>

If the status of the image is active, you can download the image using the
following command:

.. code-block:: bash

  openstack image save --file <file-name> <image-name-or-id>

The downloaded file is the raw image (a bare container) that can be uploaded
back to other cloud regions, other clouds or imported into a hypervisor for
local use.
