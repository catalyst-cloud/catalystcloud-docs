#######
Backups
#######

.. _backups:

Backups are an important part of a business plan to maintain a high level of
functionality in the face of unforeseeable events. Whether these be from
natural disasters affecting a region or human error causing systems to go down.
Having a well maintained backup of your system is vital to helping your
business get back to a high operational standard quickly.

The following section covers a basic overview, showing you how to create a
server backup utilizing `Duplicity`_, our object storage service and a
more advanced tutorial on how to automate the backup process.

.. _Duplicity: http://duplicity.nongnu.org/

Before you continue with the examples below, there are a few assumptions
that need to be considered:

1)
 You are familiar with the Linux command line and Openstack CLI tools.
2)
 You have installed the OpenStack command line tools and sourced an openrc
 file, as explained in :ref:`command-line-interface`.

The following are the different sections that go into greater detail on
specific issues.

.. toctree::
   :maxdepth: 1

   backups/duplicity
   backups/prerequisites
   backups/simple-example
   backups/automating
