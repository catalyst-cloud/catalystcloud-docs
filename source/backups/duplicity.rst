What is Duplicity
=================
Duplicity is a band-width efficient backup utility capable of providing
encrypted, digitally signed, versioned, remote backups in a space efficient
manner.

Duplicity creates an initial archive that is a full backup. All subsequent
backups are incremental and only save the difference between the latest (full
or incremental) backup. A full backup and corresponding series of incremental
backups can be recovered to any point in time covered by the incremental
backups. If an incremental backup is missing from the `backup chain`_ then any
subsequent incremental backup file cannot be recovered.

Duplicity is released under the terms of the GNU General Public License
(`GPL`_), and as such is free software.

.. _GPL: https://en.wikipedia.org/wiki/GNU_General_Public_License
.. _backup chain: http://sqlbak.com/academy/backup-chain/
