##############
Object storage
##############

Object storage is a web service to store and retrieve data from anywhere using
native web protocols. Each object typically includes the data itself, a
variable amount of metadata, and a globally unique identifier. All object
storage operations are done via a modern and easy to use REST API.

It is the ideal service to store data for websites, web applications, mobile
applications, IoT sensors, and devices. Object storage can also be used for
data archival, data lakes, backups and disaster recovery.
All object storage operations are done via a modern and easy to use REST API.

Object storage is the primary storage for modern (cloud-native) web and mobile
applications, as well as a place to archive data or a target for backup and
recovery. It is cost-effective, highly durable, highly available, scalable and
simple to use storage solution.

Our object storage service is a fully distributed storage system, with no
single points of failure and scalable to the exabyte level. The system is
self-healing and self-managing. Data stored in object storage is asynchronously
replicated to preserve three replicas of the data on different cloud regions,
designed to deliver 99.999999999% durability.
The system runs frequent CRC checks to protect data from soft corruption. The
corruption of a single bit can be detected and automatically restored to a
healthy state. The loss of a region, server or a disk leads to the data being
quickly recovered from another disk, server or region.

Table of Contents:

.. toctree::
  :maxdepth: 1

  object-storage/dashboard
  object-storage/cli
  object-storage/api
  object-storage/advanced
  object-storage/storage-access-control
  object-storage/faq
  object-storage/best-practice-object-storage
