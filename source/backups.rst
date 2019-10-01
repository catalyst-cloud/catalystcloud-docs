#######
Backups
#######

.. _backups:

This is a basic overview showing how to create server backups in OpenStack
Swift object storage using `Duplicity`_.

.. _Duplicity: http://duplicity.nongnu.org/



Assumptions:

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
