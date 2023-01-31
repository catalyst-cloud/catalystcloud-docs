.. _change-compute-type:

================================
Changing type of virtual servers
================================

The Compute service supports different types of virtual servers, and
from time to time you may want to convert from one type to another.

This can be done in-place on existing virtual servers, using the
"resize" function to choose not only a different size but a different
type as well.

*********************************
How to change virtual server type
*********************************

TBD

*****************************
Limitations on changing types
*****************************

When converting an existing system between types, there are important
limitations which must be taken into account.

.. warning::

    The platform *does not* check if any of these limitations would
    affect your virtual server. It will (generally) allow you to change
    types even if you applications or OS would not function.

Downtime
========

Changing between types requires the server to be shut down and
restarted. The change cannot be done in a non-interrupting manner.

CPU Architecture
================

When converting between types, you must ensure that the OS installed in
the virtual server is compatible with the new type. This includes any
CPU architecture differences.

For example, converting between a x86-64 architecture and an ARM
architecture will result in a machine that does not boot and will
never execute the OS code installed.

The following table lists the CPU Architecture of our types.

.. list-table:: CPU Architectures
    :header-rows: 1
    :widths: 25 75

    * - Server Type
      - CPU Architecture
    * - c1
      - Intel x86-64
    * - c2-burst
      - Intel x86-64
    * - c2-gpu
      - Intel x86-64

CPU Flags
=========

For each type of virtual server, we provide a different level of
"cpu flags", that is which instructions are available from the CPU.
These determine if your code is able to be executed.

In general, most code compiled for a given CPU architecture should
gracefully handle the presence or lack of specific instructions. This
is because those instructions often fall into "acceleration" rather
then core features.

For example, our "c1" compute does not support Intel's AVX-512 SMID
instructions, which are used for mass data processing in parallel.
Our "c2-burst" does support AVX-512, so when converting from "c2-burst"
to "c1", your code must handle the lack of these instructions if it
can use them.

THe following table lists the maximum CPU flags for each of our types.

.. list-table:: CPU Flags
    :header-rows: 1
    :widths: 25 75

    * - Server Type
      - Maximum CPU Level
    * - c1
      - Intel x86-64 "Sandy Bridge"
    * - c2-burst
      - Intel x86-64 "Skylake"
    * - c2-gpu
      - TBD

Additional Hardware
===================

Some types have additional hardware capabilities, which are not
present on all types. Therefore, if your application depends on
any of these features, you may not be able to change types.

The following table lists any additional hardware features which
could affect your application.

.. list-table:: Hardware Features
    :header-rows: 1
    :widths: 25 75

    * - Server Type
      - Additional Hardware
    * - c1
      - None
    * - c2-burst
      - Intel Quick Assist Technology (1)
    * - c2-gpu
      - NVIDIA A100 vGPU

**Notes:**

(1) This is not currently exposed to guests, but may be enabled at
a later date.
