################################
Creating a backup
################################

The purpose of this section is to provide examples on how you can use different
tools to create a backup of your data on Catalyst Cloud.

Before you continue with the examples below, there are a few assumptions that
are made which you will need to consider before jumping in further:

#. You are familiar with the Linux command line and the OpenStack CLI tools.
#. You have installed the OpenStack command line tools and sourced an OpenRC
   file, as explained in :ref:`this section of the
   documentation<command-line-interface>`.

**************************
Which method should I use?
**************************

While both of the methods we describe will create a backup of your data,
there are some differences between them in how your backup is created,
stored and maintained.

When using OpenStack to create your backup, a point in time snapshot of your
data is created. From this snapshot, OpenStack creates a volume; this is your
backup volume. A copy of this volume is then placed in object storage in the
back end for redundancy.

Because this backup is created using a point in time snapshot, it is a 'crash
consistent' solution that is able to restore your data to the specific point in
time the original backup was taken. It does not ensure that the data is in a
particular state after the restore.

The other tools on the other hand, will create backups that make multiple attempts
to capture a given file if it has been changed. This is due to them being
file oriented tools rather than performing a point in time backup. As mentioned
earlier, being a file oriented backup, They allow you to perform
file-level restoration from your backup should you need to.

Depending on the type of backup you want to create and the solution that best
suits your situation, you may decide to use one method or another. Generally the
basic OpenStack backup solution is easier for maintaining a crash consistent
copy of your data somewhere ready to restore while the others are able to perform
a more rigorous capture of the state of your files.

***********************
Using the OpenStack CLI
***********************

Creating your backup
====================

To create a backup using the OpenStack command line tools, we first need to
find the original volume we are trying to back up. To show a list of the
currently available volumes, you can use the following command:

.. code-block:: bash

    $ openstack volume list
    +--------------------------------------+---------------------+-----------+------+-----------------+
    | ID                                   | Name                | Status    | Size | Attached to     |
    +--------------------------------------+---------------------+-----------+------+-----------------+
    | 81599985-XXXX-XXXX-XXXX-XXXXXXXXXXee | backup-vol-original | available | 5    |                 |
    +--------------------------------------+---------------------+-----------+------+-----------------+
    # we can then export our volume ID for later use:
    $ export volumeID='81599985-XXXX-XXXX-XXXX-XXXXXXXXXXee'

Once we have the volume that we want to back up we can construct our backup
command. The syntax for creating a backup using the OpenStack CLI is:

.. code-block:: bash

    $ openstack volume backup create [--incremental] [--force] <VOLUME>

Where ``<VOLUME>`` is the name or ID of the original volume you wish to back up.
Because we exported our volume ID earlier we can use the following to create our
initial backup:

.. code-block:: bash

    $ openstack volume backup create $volumeID

Now that we have our backup created, we can view it with the following commands.

.. Note::

    If your volumes is currently attached to a running instance the default backup
    command will fail. However, you can  still create a volume backup using the
    ``--force`` parameter. This will allow you to create a backup even if your
    original volume is in the ``in-use`` state.

.. code-block:: bash

    $ openstack volume backup list
    +--------------------------------------+------+-------------+-----------+------+
    | ID                                   | Name | Description | Status    | Size |
    +--------------------------------------+------+-------------+-----------+------+
    | 376a741c-XXXX-XXXX-XXXX-XXXXXXX7881c | None | None        | available | 5    |
    +--------------------------------------+------+-------------+-----------+------+
    # Once we have our backup ID we can view more information about it like so:

    $ openstack volume backup show 376a741c-XXXX-XXXX-XXXX-XXXXXXX7881c
    +-----------------------+--------------------------------------+
    | Field                 | Value                                |
    +-----------------------+--------------------------------------+
    | availability_zone     | nz-por-1a                            |
    | container             | volumes_backup_nz-por-1              |
    | created_at            | 2021-09-20T04:13:08.000000           |
    | data_timestamp        | 2021-09-20T04:13:08.000000           |
    | description           | None                                 |
    | fail_reason           | None                                 |
    | has_dependent_backups | False                                |
    | id                    | 376a741c-XXXX-XXXX-XXXX-XXXXXXX7881c |
    | is_incremental        | False                                |
    | name                  | None                                 |
    | object_count          | 104                                  |
    | size                  | 5                                    |
    | snapshot_id           | None                                 |
    | status                | available                            |
    | updated_at            | 2021-09-20T04:14:59.000000           |
    | volume_id             | 81599985-XXXX-XXXX-XXXX-XXXXXXXXXXee |
    +-----------------------+--------------------------------------+

For future backups of the original volume we can
make use of the ``incremental`` optional argument. Instead of creating an
entirely new backup, the incremental argument will create a snapshot with the
differences between our current backup volume and the updated state of the
original volume.

.. code-block:: bash

    # When we create our incremental backup we still use the ID of the original volume that we are backing up.
    $ openstack volume backup create --incremental $volumeID
    +-------+--------------------------------------+
    | Field | Value                                |
    +-------+--------------------------------------+
    | id    | cbbefa42-XXXX-XXXX-XXXX-XXXXXXX36f00 |
    | name  | None                                 |
    +-------+--------------------------------------+

    # Now if we take a look at our first backup we will see that the `has_dependant_volume` property is set to True:
    $ openstack volume backup show 376a741c-XXXX-XXXX-XXXX-XXXXXXX7881c
    +-----------------------+--------------------------------------+
    | Field                 | Value                                |
    +-----------------------+--------------------------------------+
    | availability_zone     | nz-por-1a                            |
    | container             | volumes_backup_nz-por-1              |
    | created_at            | 2021-09-20T04:13:08.000000           |
    | data_timestamp        | 2021-09-20T04:13:08.000000           |
    | description           | None                                 |
    | fail_reason           | None                                 |
    | has_dependent_backups | True                                 |
    | id                    | 376a741c-XXXX-XXXX-XXXX-XXXXXXX7881c |
    | is_incremental        | False                                |
    | name                  | None                                 |
    | object_count          | 104                                  |
    | size                  | 5                                    |
    | snapshot_id           | None                                 |
    | status                | available                            |
    | updated_at            | 2021-10-04T00:33:04.000000           |
    | volume_id             | 81599985-XXXX-XXXX-XXXX-XXXXXXXXXXee |
    +-----------------------+--------------------------------------+

    $ export first_backup="376a741c-XXXX-XXXX-XXXX-XXXXXXX7881c"

    # If we then take a look at our new backup, we will see that it has the 'is_incremental' property set to True:
    $ openstack volume backup show cbbefa42-XXXX-XXXX-XXXX-XXXXXXX36f00
    +-----------------------+--------------------------------------+
    | Field                 | Value                                |
    +-----------------------+--------------------------------------+
    | availability_zone     | nz-por-1a                            |
    | container             | volumes_backup_nz-por-1              |
    | created_at            | 2021-10-04T00:32:22.000000           |
    | data_timestamp        | 2021-10-04T00:32:22.000000           |
    | description           | None                                 |
    | fail_reason           | None                                 |
    | has_dependent_backups | False                                |
    | id                    | cbbefa42-XXXX-XXXX-XXXX-XXXXXXX36f00 |
    | is_incremental        | True                                 |
    | name                  | None                                 |
    | object_count          | 1                                    |
    | size                  | 5                                    |
    | snapshot_id           | None                                 |
    | status                | available                            |
    | updated_at            | 2021-10-04T00:33:04.000000           |
    | volume_id             | 81599985-XXXX-XXXX-XXXX-XXXXXXXXXXee |
    +-----------------------+--------------------------------------+

    $ export second_backup="cbbefa42-XXXX-XXXX-XXXX-XXXXXXX36f00"

Restoring from your backup
==========================

The last thing that we need to cover is how to restore your volume using one of
these backups. The syntax for the restore command is as follows:

.. code-block:: bash

    $ openstack volume backup restore <BACKUP_ID> <VOLUME_ID>

Depending on which backup we want to use, OpenStack will perform different
actions when restoring our volume.

If we choose our original backup to restore from, then OpenStack will perform a
full restore of our backup. This will restore the volume to the point in time
our original backup was created.:

.. code-block:: bash

    $ openstack volume backup restore $first_backup $volume_ID
    +-------------+--------------------------------------+
    | Field       | Value                                |
    +-------------+--------------------------------------+
    | backup_id   | 376a741c-XXXX-XXXX-XXXX-XXXXXXX7881c |
    | volume_id   | 81599985-XXXX-XXXX-XXXX-XXXXXXXXXXee |
    | volume_name | backup-vol-original                  |
    +-------------+--------------------------------------+

If we choose to restore from our incremental backup, then OpenStack will first
organize a list of the backups we have made starting with the initial backup. It
will then perform a full restore starting from that backup and then layer on the
additional backups afterward:

.. code-block:: bash

    $ openstack volume backup restore $second_backup $volume_ID
    +-------------+--------------------------------------+
    | Field       | Value                                |
    +-------------+--------------------------------------+
    | backup_id   | cbbefa42-XXXX-XXXX-XXXX-XXXXXXX36f00 |
    | volume_id   | 81599985-XXXX-XXXX-XXXX-XXXXXXXXXXee |
    | volume_name | backup-vol-original                  |
    +-------------+--------------------------------------+

***********
Other Tools
***********

Here are some sample backup tools, and how to configure them for operating with
Catalyst Cloud:

* :ref:`duplicati`
* :ref:`duplicity_sect`
