.. _services_on_the_sky-tv_cloud:

##############################
Services on the Sky TV Cloud
##############################

This documentation covers services and protocols specific to Sky TV. For
information on the other services that this tool provides, we recommend
referring to the `Catalyst Cloud documentation`_.

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
decide beforehand how much storage you want to partition.


Object storage service
======================

Object storage is a storage system unique to cloud computing. Instead of
provisioning a volume of storage capacity, you just upload a file, and the
cloud handles it's storage.

With object storage, you only pay for bits your
files are using, not any empty, unproductive bits. This allows you to minimise
your costs. Secondarily, data stored in object storage can be more efficiently
stored than block storage.

Database service
================

The Database service allows you to create, organise and manage database
instances on networks that you have on the cloud. These database instances
run on a datastore that you are able to create and define using `trove`_,
a service that can be entirely run using OpenStack. For more information on
how to create and manage a database, please refer
to :ref:`this section of the documentation <database_page>`

.. _`trove`: https://wiki.openstack.org/wiki/Trove

Alarm service
=============

This service is provided with
`AODH`_. It exists to alert you
when a specified condition is met. This can be an important function for any
business as it allows you to keep a closer eye on how effective your other
services are being used, so that you can make decision that will effect your
costs for each instance. The most common use case of the Alarm service
is auto-scaling of instances. More information can be found in our
:ref:`Alarm service section <alarm-service-on-Sky-tv_cloud>`

.. _`AODH`: https://docs.openstack.org/aodh/latest/
