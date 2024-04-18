.. _block-storage-intro:

#############
Block storage
#############

Block Storage is commonly used by virtual servers as "volumes", and
behaves similar to disks attached to a physical server. They are
expected to be used with filesystems or storage support inside the
operating system of an instance. Every virtual server will have
at least one block storage volume attached (referred to as the "root"
volume) containing the operating system.

Block Storage volumes also back "Persistent Volumes" in our Managed
Kubernetes services, so some of the concepts here apply to those as
well.

The contents of a block storage volume can created as empty or from
a source image or existing copy of another device. Details on how to
create volumes from different sources are under this section of
the documentation.

Block storage volumes can (with some exceptions) be detached or copied,
snapshots and backups made of them, and can be attached to different
servers as needed.

The block storage service implements techniques to reduce the impact
of a physical failure, such as maintaining multiple copies of a block
storage volume and regular checks to see these copies are consistent.
However, you should always have backups of any block storage volumes,
as failures can occur that affect data stored, and these features
do not provide any means of recovery from deleted data inside the
operating system. See :ref:`Backups<backups>`.

Block Storage volumes are tightly coupled to a specific location, and
cannot be attached to servers in different locations. For storage that
is distributed between regions, consider
:doc:`Object Storage <object-storage>` instead.

Table of Contents:

.. toctree::
  :maxdepth: 1

  block-storage/volume-tiers
  block-storage/using-volumes
  block-storage/using-lvm
  block-storage/uuid-mount
  block-storage/volume-transfer
  block-storage/using-snapshots
  block-storage/faq
  Best practices <block-storage/block-storage-bp>



