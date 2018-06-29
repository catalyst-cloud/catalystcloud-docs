########
Overview
########

Object storage is a web service to store and retrieve data from anywhere using
native web protocols. All object storage operations are done via a modern and
easy to use REST API. Each object typically includes:

* The data itself.
* A variable amount of metadata.
* A globally unique identifier.

Object storage is the primary storage for modern (cloud-native) web and mobile
applications, as well as a place to archive data or a target for backup and
recovery. It is cost-effective, highly durable, highly available, scalable, and
a simple to use storage solution.

Our object storage service is a fully distributed storage system, with no single
point of failure, and scalable to the exabyte level. The system is self-healing
and self-managing. Data stored in object storage is asynchronously replicated to
preserve three replicas of the data on different cloud regions. The system runs
frequent `CRC checks <https://en.wikipedia.org/wiki/Cyclic_redundancy_check>`_
to protect data from soft corruption. The corruption of a single bit can be
detected and automatically restored to a healthy state. The loss of a region,
server or a disk leads to the data being quickly recovered from another disk,
server or region.
