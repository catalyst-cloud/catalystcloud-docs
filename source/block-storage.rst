#############
Block storage
#############

Block volumes are similar to virtual disks that can be attached to any compute
instance, in a region, to provide additional storage. They are highly available
and extremely resilient.

Our block storage service is provided by a fully distributed storage system,
with no single points of failure and scalable to the exabyte level. The system
is self-healing and self-managing. Data is seamlessly replicated on three
different servers in the same region, making it fault tolerant and resilient.

The loss of a node or disk leads to the data being quickly recovered on
another node or disk. Additionally, the system runs frequent CRC checks to
protect data from soft corruption. The corruption of a single bit can be
detected and automatically restored to a healthy state.

Table of Contents:

.. toctree::
  :maxdepth: 1

  block-storage/overview
  block-storage/using-volumes
  block-storage/uuid-mount
  block-storage/using-lvm
  block-storage/faq



