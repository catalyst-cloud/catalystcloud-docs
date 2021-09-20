################################
Creating a backup
################################

The purpose of this section is to provide examples on how you can use different
tools to create a volume backup on the Catalyst Cloud.

Before you continue with the examples below, there are a few assumptions that
are made which you will need to consider before jumping in further:

1)
 You are familiar with the Linux command line and Openstack CLI tools.
2)
 You have installed the OpenStack command line tools and sourced an openrc
 file, as explained in :ref:`this section of the documentation<command-line-interface>`.


***********************
Using the Openstack CLI
***********************

To create a backup using the openstack command line tools, we first need to
find the original volume we are trying to back up. To show a list of the
currently available volumes, you can use the following code snippet:

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
command. The syntax for creating a backup using the openstack CLI is:

.. code-block:: bash

    $ openstack volume backup create [--incremental] [--force] <VOLUME>

Where ``<VOLUME>`` is the name or ID of the original volume you wish to back up.
Because we exported our volume ID earlier we can use the following to create our
initial backup:

.. code-block:: bash

    $ openstack volume backup create $volumeID

Now that we have our backup created, we can view it with the following commands.

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
    | volume_id             | 81599985-6aac-4a13-90e4-b550798729ee |
    +-----------------------+--------------------------------------+

For future backups of the original volume we can
make use of the ``incremental`` optional argument. Instead of creating an
entirely new backup, the incremental argument will create a snapshot with the
differences between our current backup volume and the updated state of the
original volume.

.. include:: duplicity.rst
