########################################
Downloading compute instance's volume(s)
########################################

Volumes can be copied from the block storage service to the image service and
downloaded using the Glance client.

This tutorial assumes you have installed the OpenStack command line tools and
sourced an openrc file, as explained on :ref:`command-line-interface`.

*************************
Identifying the volume(s)
*************************

The ``openstack volume list`` command can be used to list all volumes
available.

The ``openstack server show`` command can be used to identity the volumes that
are attached to a given compute instance:

.. code-block:: bash

  openstack server show <instance-name-or-id> | grep "volumes_attached"

********************
Uploading the volume
********************

The procedure to upload a volume will vary depending on whether the volume is
attached to an instance (active) or not.

Uploading a detached (inactive) volume
======================================

With the command ``openstack image create --volume <volume-name-or-id>
<image-name>``, a detached volume can be uploaded to the image service:

.. code-block:: bash


  openstack image create --volume imgvol imgvol-img
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | container_format    | bare                                 |
  | disk_format         | raw                                  |
  | display_description |                                      |
  | id                  | 14c25834-b7ae-4a36-b947-xxxxxxxxxxxx |
  | image_id            | 11f636db-0d15-4e97-88a0-xxxxxxxxxxxx |
  | image_name          | imgvol-img                           |
  | size                | 11                                   |
  | status              | uploading                            |
  | updated_at          | 2016-08-23T02:45:34.000000           |
  | volume_type         | b1.standard                          |
  +---------------------+--------------------------------------+


Uploading an attached (active) volume
=====================================

To upload an active volume (a volume that is currently attached to a compute
instance and in use), you must first take a snapshot of the volume using the
``openstack snapshot create`` command, then create a new (inactive) volume from
it using the ``cinder volume-create`` command.

To take a snapshot of an active volume we first need to find the volume ID:

.. code-block:: bash

  $ openstack server show [SERVER NAME] | grep volumes_attached

  $ openstack volume snapshot create --volume <id-from-the-output-of-previous-result> --force <snapshot-name>

  +-------------+--------------------------------------+
  | Field       | Value                                |
  +-------------+--------------------------------------+
  | created_at  | 2019-06-19T02:19:57.604002           |
  | description | None                                 |
  | id          | e82b3e29-eced-4f6c-8985-xxxxxxxxxxxx |
  | name        | test-image-from-CLI                  |
  | properties  |                                      |
  | size        | 50                                   |
  | status      | creating                             |
  | updated_at  | None                                 |
  | volume_id   | 9a7d2ce9-c2c5-41d7-9e4e-xxxxxxxxxxxx |
  +-------------+--------------------------------------+

Now that we have created a snapshot of a running volume, we can view the list
of snapshots to confirm its creation.

.. code-block:: bash

  $ openstack volume snapshot list
  +--------------------------------------+---------------------------+-------------+-----------+------+
  | ID                                   | Name                      | Description | Status    | Size |
  +--------------------------------------+---------------------+----------------+-----------+---------+
  | e82b3e29-eced-4f6c-8985-xxxxxxxxxxxx | test-snapshot-from-volume | None        | available |   50 |
  +--------------------------------------+---------------------------+-------------+-----------+------+

After which we can create a volume from our snapshot.

.. code-block:: bash

  $ openstack volume create --snapshot <name-of-previous-snapshot> --size 11 <name-of-new-volume>
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | attachments         | []                                   |
  | availability_zone   | NZ-WLG-2                             |
  | bootable            | false                                |
  | consistencygroup_id | None                                 |
  | created_at          | 2019-06-19T02:26:27.121055           |
  | description         | None                                 |
  | encrypted           | False                                |
  | id                  | 6693045e-1448-4ec7-a1d6-xxxxxxxxxxxx |
  | multiattach         | False                                |
  | name                | new-vol-from-CLI                     |
  | properties          |                                      |
  | replication_status  | disabled                             |
  | size                | 50                                   |
  | snapshot_id         | e82b3e29-eced-4f6c-8985-xxxxxxxxxxxx |
  | source_volid        | None                                 |
  | status              | creating                             |
  | type                | b1.standard                          |
  | updated_at          | None                                 |
  | user_id             | 53b94a52e9dcxxxxxxx0079a9a3d6434     |
  +---------------------+--------------------------------------+

We then can view the list of our volumes to confirm it's been created.
After, we are able to create our image from the volume made from the snapshot.

.. code-block:: bash

  $ openstack volume list
  +--------------------------------------+-------------------+-----------+------+--------------------------------------------+
  | ID                                   | Name              | Status    | Size | Attached to                                |
  +--------------------------------------+-------------------+-----------+------+--------------------------------------------+
  | 6693045e-1448-4ec7-a1d6-xxxxxxxxxxxx | new-vol-from-CLI  | available |   50 |                                            |
  | 9a7d2ce9-c2c5-41d7-9e4e-xxxxxxxxxxxx | original-volume   | in-use    |   50 | Attached to first-instance-CLI on /dev/vdb |
  +--------------------------------------+-------------------+-----------+------+--------------------------------------------+

  $ openstack image create --volume <name-of-volume-made-from-snapshot> <name-of-new-image-made-from-volume-from-snapshot>
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | container_format    | bare                                 |
  | disk_format         | raw                                  |
  | display_description | None                                 |
  | id                  | 6693045e-1448-4ec7-a1d6-xxxxxxxxxxxx |
  | image_id            | a361ea04-fc0a-48ce-8b9c-xxxxxxxxxxxx |
  | image_name          | image-from-vol-CLI-snapshot          |
  | size                | 50                                   |
  | status              | uploading                            |
  | updated_at          | 2019-06-19T02:26:28.000000           |
  | volume_type         | b1.standard                          |
  +---------------------+--------------------------------------+

Finally we check to make sure that our image has been made and then we save it.

.. code-block:: bash

  $ openstack image list | grep vol

  $ openstack image save --file <new-file-name> <name-of-the-image-from-last-step>

*********************
Downloading the image
*********************

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
