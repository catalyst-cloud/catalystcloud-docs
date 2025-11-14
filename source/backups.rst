#######
Backups
#######

.. _backups:

Backups are an important part of a business continuity plan, in order to maintain a high
level of functionality in the face of unforeseeable events. Whether these be
from natural disasters affecting a region or human error causing systems to go
down. Having a well maintained backup of your system is vital to helping your
business get back to full operation quickly.

The following sections cover different methods for creating and maintaining
backups on Catalyst Cloud as well as ways to automate the backup process.

The main method of backing up your instances will be through the in built
backup commands provided by Catalyst Cloud. Alternatively, we also refer to how
to configure a number of other backup systems that may be useful.

The main distinction between the two approaches to backups are that the
the default OpenStack backup creates a new volume resource that holds a copy
of your data at the point in time you decided to back up your data. While
the other tools create file-orientated backups, allowing you to perform
file-level restoration from your backup. You may find that a combination of
the two approaches is useful.

The following are the different sections that go into greater detail on
specific issues.

.. toctree::
   :maxdepth: 1

   backups/creating-backup
   backups/automating
