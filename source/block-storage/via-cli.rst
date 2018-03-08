.. _via-cli:

###########
Via the CLI
###########

*******************
Create a new volume
*******************

Use the ``openstack volume create`` command to create a new volume:

.. code-block:: console

  $ openstack volume create --description 'database volume' --size 50 db-vol-01
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | attachments         | []                                   |
  | availability_zone   | nz-por-1a                            |
  | bootable            | false                                |
  | consistencygroup_id | None                                 |
  | created_at          | 2016-08-18T23:08:40.021641           |
  | description         | database volume                      |
  | encrypted           | False                                |
  | id                  | 7e94a2f6-b4d2-47f1-83f7-a200e963404a |
  | multiattach         | False                                |
  | name                | db-vol-01                            |
  | properties          |                                      |
  | replication_status  | disabled                             |
  | size                | 50                                   |
  | snapshot_id         | None                                 |
  | source_volid        | None                                 |
  | status              | creating                             |
  | type                | b1.standard                          |
  | updated_at          | None                                 |
  | user_id             | 4b934c44d8b24e60acad9609b641bee3     |
  +---------------------+--------------------------------------+

Attach a volume to a compute instance
=====================================

Use the ``openstack server add volume`` command to attach the volume to an
instance:

.. code-block:: console

  $ openstack server add volume INSTANCE_NAME VOLUME_NAME

The command above assumes that your volume name is unique. If you have volumes
with duplicate names, you will need to use the volume ID to attach it to a
compute instance.

The next steps are at :ref:`using-volumes`
