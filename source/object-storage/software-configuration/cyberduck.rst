*********
Cyberduck
*********

Cyberduck is free software, although the developers do ask for donations. It
provides file access to many different services via many different protocols,
such as FTP, SFTP, WebDAV, Swift, S3, Dropbox etc.

You can install it from either the Windows or MacOS app stores, or by
downloading an installer directly from the Cyberduck website:
https://cyberduck.io .

Currently when you use Cyberduck, there will be three entries for each folder
and file shown. This is because we have three regions and Cyberduck queries
all three. We expect to have profiles for our object storage available in
Cyberduck soon which will resolve this issue.

Configuration steps
===================

#. File -> Open Connection
#. Select "OpenStack Swift (Keystone 3) in the top drop down.
#. Server: select a "identity" URL from :ref:`apis` and enter only the server
   name, e.g.: api.nz-por-1.catalystcloud.io
#. Port: 5000
#. Project:Domain:Username: Enter you project name, "default", and your
   username, e.g.: example-org-nz:default:operations@example.org.nz
#. Password: enter your password
#. Click "Connect".

This doesn't save the connection details, so if you connect okay, you'll want
to add a bookmark, to do this:

#. Bookmark -> New Bookmark
#. Nickname: Enter a suitable nickname
#. You can set the default folder on your local computer here as well.
#. Click the little x on the top bar of the window.
