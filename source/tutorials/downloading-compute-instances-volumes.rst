########################################
Downloading compute instance's volume(s)
########################################

Volumes can be copied from the block storage service to the image service and
downloaded using the glance client.

This tutorial assumes you have installed the OpenStack command line tools and
sourced an openrc file, as explained on :ref:`command-line-tools`.

Identifying the volume(s)
=========================

The ``cinder list`` command can be used to list all volumes available.

The ``nova show`` command can be used to identity the volumes that are attached
to a given compute instance:

.. code-block:: bash

  nova show <instance-name-or-id> | grep "volumes_attached"

Uploading the volume
====================

The procedure to upload a volume will vary depending on whether the volume is
attached to an instance (active) or not.

Uploading a detached (inactive) volume
--------------------------------------

A detached volume can be uploaded to the image service using the following
command:

.. code-block:: bash

  cinder upload-to-image <volume-name-or-id> <image-name>

Uploading an attached (active) volume
-------------------------------------

To upload an active volume (a volume that is currently attached to a compute
instance and in use), you must first take a snapshot of the volume using the
``cinder volume-snapshot`` command and then create a new (inactive) volume from
it using the ``cinder volume-create`` command.

To take a snapshot of an active volume:

.. code-block:: bash

  cinder snapshot-create <volume-name-or-id> --display-name <snapshot-name> --force True

To show a list of all snapshots:

.. code-block:: bash

  cinder snapshot-list

The command below can be used to create a new volume based on a snapshot.
Please note that the volume size should match the snapshot size.

.. code-block:: bash

  cinder create --snapshot-id <snapshot-id> --display-name <new-volume-name> <size>

A detached volume can be uploaded to the image service using the command below:

.. code-block:: bash

  cinder upload-to-image <volume-name-or-id> <image-name>

Downloading the image
=====================

Copying a volume from the block storage service to the image service can take
some time (depending on volume size). First, you should confirm that the upload
has finished (status shown as active), using the command below:

.. code-block:: bash

  glance image-show <image-name-or-id>

If the status of the image is active, you can download the image using the
following command:

.. code-block:: bash

  glance image-download <image-name-or-id> --file <file-name> --progress

The downloaded file is the raw image (a bare container) that can be uploaded
back to other cloud regions, other clouds or imported into a hypervisor for
local use.

