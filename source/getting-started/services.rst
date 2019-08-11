.. _services_on_the_catalyst_cloud:

##############################
Services on the Sky TV Cloud
##############################

This documentation covers services and protocols specific to Sky TV. For
information on the other services that this tool provides, we reccomend
refering to the `Catalyst Cloud documentation`_.

Below we will briefly discuss some of the relevant services:

.. _`Catalyst Cloud documentation`: https://docs.catalystcloud.nz/

Compute service
===============

The compute service provides compute power on demand, in the form of
"instances". If you like to think about physical computers, you can imagine an
instance as one or more CPUs and GB of RAM that you have provisioned usage of.

Image service
=============

It is a common task to install an operating system onto a block storage volume,
so that you can boot the instance into the operating system. The image service
was created to make this as easy as possible.

An image is a "pre-made" operating system installation that can be used
immediately by an instance, rather than spending time installing the operating
system, the drivers, miscellaneous files, and configurations that help the
instance integrate better with the Sky TV Cloud.

Block storage service
=====================

The block storage service provides volumes of data storage that you can attach
to instances. You could imagine block storage volumes as hard disk drives and
solid state drives on a physical computer. Block storage volumes can be as
large or as small as you want them to be, however they are not dynamic; you
decide beforehand how much storage you want to particion.


Object storage service
======================

Object storage is a storage system unique to cloud computing. Instead of
provisioning a volume of storage capacity, you just upload a file, and The
Cloud handles it's storage.

With object storage, you only pay for bits your
files are using, not any empty, unproductive bits. This allows you to minimise
your costs. Secondarily, data stored in object storage can be more efficiently
stored than block storage.

