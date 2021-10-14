***************
Using Duplicity
***************

What is Duplicity?
==================

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



Prerequisites
=============

If you're using a major Linux distribution, you should be able to find a
pre-compiled package in the repositories. If not, then a tar file is available
at `Duplicity`_.

.. _Duplicity: http://duplicity.nongnu.org/

.. code-block:: bash

  sudo apt-get update
  sudo apt-get install duplicity

Because we are going to authenticate against keystone, it is also necessary to
install ``python-keystoneclient``.

.. code-block:: bash

  sudo apt-get install python-keystoneclient

or

.. code-block:: bash

  pip install python-keystoneclient

If you intend to create encrypted backups you will also require a GPG key. The
``gpg --gen-key`` command line tool can create a local one for you, see
(`GnuPG`_) for more information on this.

.. _GnuPG: https://www.gnupg.org/gph/en/manual/c14.html

Duplicity requires certain environment variables to be set. One option would
be to source a simple bash script like this. The data for these variables can
be obtained from your OpenStack RC file.

.. code-block:: bash

  #!/bin/bash

  # Swift credentials for Duplicity
  export SWIFT_USERNAME="somebody@example.com"
  export SWIFT_TENANTNAME="mycloudtenant"
  export SWIFT_AUTHURL="https://api.cloud.catalyst.net.nz:5000/v2.0"
  export SWIFT_AUTHVERSION="2"

  # With Keystone you pass the keystone password.
  echo "Please enter your OpenStack Password: "
  read -sr PASSWORD_INPUT
  export SWIFT_PASSWORD=$PASSWORD_INPUT

In order to source this file, run the following from the command line

.. code-block:: bash

  source <filename.sh>

This will need be done before each Duplicity run if the variables are not
already set.



An example using Duplicity
==========================

Firstly, lets check our connectivity to the object store. If we run the
following for an existing empty container, in this case 'first-container', we
should see something like this

.. code-block:: bash

  $ duplicity collection-status swift://first-container
  Local and Remote metadata are synchronized, no sync needed.
  Last full backup date: none
  Collection Status
  -----------------
  Connecting with backend: BackendWrapper
  Archive dir: /home/ubuntu/.cache/duplicity/cd3fc2f113a80b76b6xxxxxx7b16aee5

  Found 0 secondary backup chains.
  No backup chains with active signatures found
  No orphaned or incomplete backup sets found.

Now we can run our first backup. For this example we will use a single local
file called foo.sh.

.. note::

  if you do not have a valid gpg key you will need to append ``--no-encryption``
  to the end of your duplicity commands.

|

.. code-block:: bash

  $ duplicity foo.sh swift://first-container
  Local and Remote metadata are synchronized, no sync needed.
  Last full backup date: none
  GnuPG passphrase for decryption:
  Retype passphrase for decryption to confirm:
  No signatures found, switching to full backup.
  --------------[ Backup Statistics ]--------------
  StartTime 1484012914.11 (Tue Jan 10 01:48:34 2017)
  EndTime 1484012914.11 (Tue Jan 10 01:48:34 2017)
  ElapsedTime 0.01 (0.01 seconds)
  SourceFiles 1
  SourceFileSize 44 (44 bytes)
  NewFiles 1
  NewFileSize 44 (44 bytes)
  DeletedFiles 0
  ChangedFiles 0
  ChangedFileSize 0 (0 bytes)
  ChangedDeltaSize 0 (0 bytes)
  DeltaEntries 1
  RawDeltaSize 44 (44 bytes)
  TotalDestinationSizeChange 231 (231 bytes)
  Errors 0
  -------------------------------------------------

We can verify the state of our backups with:

.. code-block:: bash

  $ duplicity collection-status swift://first-container
  Local and Remote metadata are synchronized, no sync needed.
  Last full backup date: Tue Jan 10 01:48:25 2017
  Collection Status
  -----------------
  Connecting with backend: BackendWrapper
  Archive dir: /home/ubuntu/.cache/duplicity/cd3fc2f113a80b76b6xxxxxx7b16aee5

  Found 0 secondary backup chains.

  Found primary backup chain with matching signature chain:
  -------------------------
  Chain start time: Tue Jan 10 01:48:25 2017
  Chain end time: Tue Jan 10 01:48:25 2017
  Number of contained backup sets: 1
  Total number of contained volumes: 1
   Type of backup set:                            Time:      Num volumes:
                  Full         Tue Jan 10 01:48:25 2017                 1
  -------------------------
  No orphaned or incomplete backup sets found.

and check to see if there are local files that have not yet been backed up by
running

.. code-block:: bash

  duplicity verify swift://first-container .
  Local and Remote metadata are synchronized, no sync needed.
  Last full backup date: Tue Jan 10 01:48:25 2017
  GnuPG passphrase for decryption:
  Verify complete: 595 files compared, 0 differences found.

.. warning::

  If you wish to back up the root '/' directory, it is advisable to add
  ``--exclude /proc`` as this may cause Duplicity to crash on the weird stuff
  in there.
