#############
Block storage
#############


********
Overview
********

Our block storage service is provided by a fully distributed storage system,
with no single points of failure and scalable to the exabyte level. The system
is self-healing and self-managing. Data is seamlessly replicated on three
different servers, making it fault tolerant and resilient. The loss of a node
or a disk leads to the data being quickly recovered on another disk or node.

The system runs frequent CRC checks to protect data from soft corruption. The
corruption of a single bit can be detected and automatically restored to a
healthy state.

Storage tiers
=============

Currently the Catalyst Cloud provides a single storage tier called b1.standard,
which combines SSDs with spinning drives to provide a good balance between
performance and cost. Data stored on the b1.standard storage tier is replicated
on three different storage nodes on the same region.

In the future more storage tiers will be provided, offering options in terms of
cost and performance.
