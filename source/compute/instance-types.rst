.. _instance-types:

==============
Instance Types
==============

The Compute service offers virtual machines with different
configurations and capabilities. Understanding which type should be
used for a given workload is important to both ensure you get the
performance you expect, while also managing your compute service costs.

Catalyst Cloud provides a variety of compute types organised as
types and sizes of resources, combined into a "flavor".

*********************
General Purpose Types
*********************

We provide two different general purpose types. These are suitable
for most workloads and use cases. The table below lists the different
CPU characteristics of each of these types:

.. list-table:: General Purpose Types
    :header-rows: 1

    * - Type
      - Vendor/Arch
      - Generation
      - vCPU Policy
      - pCPU Policy
    * - c1
      - Intel x86-64
      - Sandy Bridge
      - vCPU is a thread of a pCPU
      - pCPU are shared between VMs
    * - c3
      - Intel x86-64
      - Sapphire Rapids
      - vCPU is a thread of a pCPU
      - pCPU are dedicated to a single VM

All virtual servers are provided with no oversubscription of RAM (that
is, all RAM is backed 1:1 on a reserved basis). See below for the
explanation of vCPU and pCPU policies.

***************
Burstable Types
***************

Burstable types are similar to general purpose, but are more heavily
limited in CPU performance, and more suitable for workloads that do
not need constant on-demand performance. They may sometimes be able
to "burst" above their minimum CPU time allowances, but this is not
always assured. They are best suited to development or test
workloads.

The CPU characteristics of these types are listed below:

.. list-table:: Burstable Types
    :header-rows: 1

    * - Type
      - Vendor/Arch
      - Generation
      - vCPU Policy
    * - c2-burst
      - Intel x86-64
      - Skylake
      - vCPU is a thread of a pCPU

All virtual servers are provided with no oversubscription of RAM (that
is, all RAM is backed 1:1 on a reserved basis). All virtual servers
in burstable types use a shared pCPU policy. See below for the
explanation of vCPU and pCPU policies.

In burstable types, there is a minimum amount of CPU time provided
to each instance, and a maximum based on the number of vCPU the
specific flavor has. These are summarised in the tables below:

.. list-table:: c2-burst CPU Limits
  :header-rows: 1

  * - Flavor
    - Minimum Time
    - Maximum Time
  * - c2-burst.c1r05
    - 5%
    - 100%
  * - c2-burst.c1r1
    - 10%
    - 100%
  * - c2-burst.c1r2
    - 20%
    - 100%
  * - c2-burst.c2r4
    - 40%
    - 200%
  * - c2-burst.c2r8
    - 60%
    - 200%
  * - c2-burst.c4r16
    - 90%
    - 400%
  * - c2-burst.c8r32
    - 135%
    - 800%

*****************
Accelerated Types
*****************

These compute types feature additional hardware accelerators, for
workloads that are written to specifically target the accelerator
provided. They are not suitable as general purpose servers, as they
are inherently not as cost efficient if the accelerator is not used.

.. list-table:: Accelerated Types
    :header-rows: 1
    :widths: 10 18 18 18 18 18

    * - Type
      - Vendor/Arch
      - Generation
      - vCPU Policy
      - pCPU Policy
      - Accelerator
    * - c1a-gpu
      - AMD x86-64
      - Milan
      - vCPU is a pCPU (no threading)
      - pCPU are dedicated to a single VM
      - 1 or more NVIDIA RTX A6000 48GB GPU
    * - c2-gpu
      - Intel x86-64
      - Skylake
      - vCPU is a thread of a pCPU
      - pCPU are shared between VMs
      - Slice of an NVIDIA A100 80GB GPU
    * - c2a-gpu
      - AMD x86-64
      - Milan
      - vCPU is a pCPU (no threading)
      - pCPU are dedicated to a single VM
      - 1 NVIDIA A100 40GB GPU
    * - c3-gpu
      - Intel x86-64
      - Sapphire Rapids
      - vCPU is a thread of a pCPU
      - pCPU are dedicated to a single VM
      - 1 or more NVIDIA L40S 48GB GPU


It is important to note that your workloads and operating systems
using accelerated types must have appropriate drivers and licenses
for any accelerator present.

Accelerated types may have additional requirements the OS must follow
for the accelerator to be functional. For GPUs, see :ref:`gpu-support`.

**********************
vCPU and pCPU Policies
**********************

A "vCPU" means a CPU that the virtual machine provides for an operating
system to use, and a "pCPU" means a CPU core that is actually
physically supporting the execution of the vCPU.

Instance types may allocate a vCPU as a thread of a pCPU where the
pCPU supports threads, this will be listed in the tables above as a
"thread" policy. Some pCPU do not support threads or are configured
to disable threading, and in those cases a vCPU is simply allocated
to a pCPU and listed in the table above as "no threading" policy.

Some physical CPUs support threading, but has been disabled for a
specific compute type. The vCPU policy reflects this. It is not
possible to change the threading policy on individual virtual servers,
it is set by the type of compute the virtual server is using.

An instance type may also treat pCPU as shared between more than one
VM, or dedicated to a single specific VM. Where the pCPU is dedicated
and vCPUs are threads of a pCPU, the threads are always allocated as
siblings on pCPUs. The nature of shared pCPUs means the actual pCPU
executing a vCPU will dynamically change, based on demand.

It should be noted that vCPU performance depends on whether the pCPU
is threaded, whether threading is enabled, and whether the pCPUs are
shared. These are in addition to usually expected differences about
workload, CPU generation or features, and clock rates. The exact
behavior of threads on a pCPU is documented in the CPU vendor's
documentation or datasheets.

Lastly, whether all vCPU are used by an operating system is dependant
on the operating system. You may need to consult documentation for
the operating system about any limits on vCPU, cores, and sockets.
We are also unable to guarantee that a virtual server is provided with
a CPU topology that will always implement the most optimal approach for
any operating system or license for software.

.. _change-instance-type:

********************************
Changing type of virtual servers
********************************

You can change the type of virtual server after it has been created.
The instance type can be changed by performing the :ref:`resize-server`
process. Note that a resize needs the server to be stopped, which is
either done automatically for you or you can stop and start the server
yourself.

While this change can be done in-place, it is important to note
that the operating system and software must be tolerant of the
differences between the old and new type the instance has.

.. warning::

    The platform *does not* check if any of these limitations below
    would affect your virtual server. It will (generally) allow you
    to change types even if your applications or OS would not function.

CPU Architecture
================

When converting between types, you must ensure that the OS installed in
the virtual server is compatible with the new type. This includes any
CPU architecture differences.

For example, converting between a x86-64 architecture and an ARM
architecture will result in a machine that does not boot and will
never execute the OS code installed.

In most cases, converting between the same architecture provided by
different vendors will boot, but note that like CPU generation this
may result in software which does not perform to the same level. For
example, switching between Intel and AMD x86-64 CPUs is generally low
risk for most code but there are still differences that may affect
performance.

Consult the tables above for which vendor and architecture any instance
type is.

CPU Generation
==============

For each type of virtual server, we provide a different level of
"cpu flags", that is which instructions are available from the CPU.
These determine if your code is able to be executed. CPU flags are
grouped into a "Generation" level as noted in the tables above.

In general, most code compiled for a given CPU architecture should
gracefully handle the presence or lack of specific instructions. This
is because those instructions often fall into "acceleration" rather
then core features.

For example, our "c1" compute does not support Intel's AVX-512 SMID
instructions, which are used for mass data processing in parallel.
Our "c2-burst" does support AVX-512, so when converting from "c2-burst"
to "c1", your code must handle the lack of these instructions if it
can use them.

The relationship between CPU Generations can be found in the
documentation or datasheets of the vendor of the CPU.

Additional Hardware
===================

Some types have additional hardware capabilities, which are not
present on all types. Therefore, if your application depends on
any of these features, you may not be able to change types.

These are primarily an issue when switching out of one of the types
with accelerators.
