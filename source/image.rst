#############
Image service
#############


***
FAQ
***

What operating systems are supported by the Catalyst Cloud?
===========================================================

You should be able to run all major operating systems supporting the x86_64
architecture. The following operating systems were already tested by Catalyst
or its customers:

* Linux
* FreeBSD
* Windows

You can use the image service to upload your own operating system image to the
Catalyst Cloud. Please remember you can only run software that is owned by you,
public domain or that you hold a valid license for. You have the freedom to
choose what software you run and it is your responsibility to comply with the
terms related to its usage.

What pre-configured images are provided by Catalyst?
====================================================

Catalyst provides some pre-configured images to make it easier for you to run
your applications on the cloud. The images provided by Catalyst include:

* Ubuntu Linux (official cloud image provided by Canonical)
* CentOS (official cloud image provided by the CentOS community)
* Debian (official cloud image provided by the Debian community)

Before using them, you should always confirm that they are suitable for your
needs and fit for purpose. Catalyst provides them "as is", without warranty of
any kind. If there is something you need to change, you can always upload your
own images, crafted the way you like, or take a snapshot of ours and modify it
the way you need.

How can I identify the images provided by Catalyst?
===================================================

The images provided by Catalyst are uploaded to tenant ID
``94b566de52f9423fab80ceee8c0a4a23`` and are made public. With the command line
tools, you can easily located them by running:

.. code-block:: bash

  glance image-list --owner <TENANT_ID> --is-public True

