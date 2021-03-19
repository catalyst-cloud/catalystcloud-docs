################
A simple example
################

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
