#######
Backups
#######

.. _backups:

Backups are an important part of a business plan, in order to maintain a high
level of functionality in the face of unforeseeable events. Whether these be
from natural disasters affecting a region or human error causing systems to go
down. Having a well maintained backup of your system is vital to helping your
business get back to a high operational standard quickly.

The following sections cover different methods for creating and maintaining
backups on the cloud as well as ways to automate the backup process.

The main method of backing up your instances will be through the in built
backup commands using Openstack. Alternatively, we also discuss ways that you
can use `Duplicity`_ to create backups as well.

.. _Duplicity: http://duplicity.nongnu.org/

The main distinction between the two is that the default Openstack backup
creates new volume resource that holds a copy of your data from the point
in time you decided to back up your data. While Duplicity creates a
file-orientated backup, allowing you to perform file-level restoration from your
backup.

The following are the different sections that go into greater detail on
specific issues.

.. toctree::
   :maxdepth: 1

   backups/creating-backup
   backups/automating
