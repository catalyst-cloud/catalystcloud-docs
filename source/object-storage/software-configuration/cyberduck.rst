.. index::
   single: Cyberduck
   single: Mountain Duck
   single: Client Software; Cyberduck
   single: Client Software; Mountain Duck

.. _cyberduck:
.. _mountainduck:

*************************
Cyberduck & Mountain Duck
*************************

Cyberduck and Mountain Duck are both created by iterate GmbH.

Cyberduck is free software, although the developers do ask for donations. It
provides file access to many different services via many different protocols,
such as FTP, SFTP, WebDAV, Swift, S3, Dropbox etc.

You can install it from either the Windows or MacOS app stores, or by
downloading an installer directly from the Cyberduck website:
https://cyberduck.io .

Mountain Duck allows you to mount a remote storage server as a local disk on
a Mac or Windows. You can purchase it from the Windows or Mac stores, or
directly from their website: https://mountainduck.io/ .

In both of the below examples, if you are using a policy that is single
region, please select the profile for the relevant region.

Cyberduck configuration steps
=============================

#. File -> Open Connection
#. Open the drop down at the top of the window with "FTP (File Transfer
   Protocol)".

   #. If the correct Catalyst Cloud profile isn't in the drop down, then:

      #. Select "More Options...".
      #. Start typing "Catalyst Cloud", tick the region(s) you want to use.
      #. Close the Preferences window.

   #. Select the appropriate Catalyst Cloud option.

#. Enter the details for the connection:

   #. Project:default:Username: Enter you project name, "default", and your
      username, e.g.: example-org-nz:default:operations@example.org.nz
   #. Password: enter your password
   #. Path: optional, but could be an object storage container within your
      project, and could even include a path within that container.

#. Click "Connect".

This doesn't save the connection details, so if you connect okay, you'll want
to add a bookmark, to do this:

#. Bookmark -> New Bookmark
#. Nickname: Enter a suitable nickname
#. You can set the default folder on your local computer here as well.
#. Click the little x on the top bar of the window.

Mountain Duck configuration steps
=================================

#. Tray icon -> Preferences... -> Profiles
#. Wait for the addiiional profiles to load...
#. Start typing "Catalyst Cloud", tick the region(s) you want to use.
#. Close the Preferences window.
#. Tray icon -> Open Connection...
#. Open the drop down at the top of the window with "WebDav (HTTPS)", select
   the appropriate Catalyst Cloud option.
#. Enter the details for the connection:

   #. Nickname: Enter a suitable nickname
   #. Project:default:Username: Enter you project name, "default", and your
      username, e.g.: example-org-nz:default:operations@example.org.nz
   #. Password: enter your password
   #. Path: optional, but could be an object storage container within your
      project, and could even include a path within that container.

#. Click "Connect" save and connect immediately, or "OK" to only save.

You can then connect/disconnect by clicking on the Tray icon.
