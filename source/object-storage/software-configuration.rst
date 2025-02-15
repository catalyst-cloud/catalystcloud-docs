######################
Software Configuration
######################

In this section, we have recorded the configuration details of certain software
applications as required in order to have them function with our Object Storage
Service. The following details should not be taken as an endorsement or
recommendation of any software or hardware mentioned; This is only a record of
what we have observed as required configuration or details that our customers
have notified us of.

*********
Cyberduck
*********

Cyberduck is free software, although the developers do ask for donations. It
provides file access to many different services via many different protocols,
such as FTP, SFTP, WebDAV, Swift, S3, Dropbox etc. It is available from:
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
   username, .e.g: example-com:default:operations@example.com
#. Password: enter your password
#. Click "Connect".

This doesn't save the connection details, so if you connect okay, you'll want
to add a bookmark, to do this:

#. Bookmark -> New Bookmark
#. Nickname: Enter a suitable nickname
#. You can set the default folder on your local computer here as well.
#. Click the little x on the top bar of the window.

*********
Duplicati
*********

Duplicati is a backup tool for MS Windows, MacOS and Linux. It is available
from: https://www.duplicati.com/. It can be configured to work with Catalyst
Cloud's object storage service by following the steps below:

Prerequisites:
==============

The following is a list of prerequisites that you will need to have before
you can begin configuring Duplicati to work with our object storage service.

- You already have an object storage container ready to receive and store your
  backup data.

-  You have a user account that is able to interact with the object storage
   service. (For purposes like backups we recommend that you use a dedicated
   user that only has the *object storage role* for permissions)

Configuration steps
===================

Once you have your prerequisites sorted, you can follow these steps to get your
Duplicati backups sent to your object storage container:

#. Use Menu -> Add Backup.

#. Ensure 'Configure a new backup' is selected, go Next.

#. Configure General backup settings. It is a good idea to use encryption for
   you backups, but it isn't required.

#. Configure Backup Destination:

   #. Storage Type: Select: Backup Object Storage / Swift
   #. Bucket name: [Enter the name of your container]
   #. OpenStack AuthURI: Select an identity API URL from :ref:`apis`.  If you
      are using single region replication, please select the identity API URL
      for the region your container is within.
   #. Keystone API version: Select: v3
   #. Domain Name: Enter: "default"
   #. Username & Password: The account credentials you would like to use.
   #. Tenant Name: [Enter the project name where your container is]

#. Source Data: Select the paths and/or files to backup.

#. Schedule: Set the desired schedule.

#. Options: You should be fine to leave the defaults.

Once this is complete you should see your backups start to appear in your
selected object storage container.

**********
S3 Browser
**********

A commercial (free for personal use) client for MS Windows. It is available
from https://s3browser.com/ . It is compatible
with Catalyst Cloud object storage using the OpenStack S3 API.

Configuration steps
===================

#. Accounts -> Add new account
#. Account type: select "S3 Compatible Storage"
#. REST Endpoint: select a "s3" URL from :ref:`apis`
#. Access Key & Secret Access Key: EC2 credentials (you may wish to create a dedicated user).
#. Select "advanced settings"
#. Signature version: select "Signature V4"
#. Select "Close"
#. Select "Add new account"

You should now be able to connect to the account and then browse, upload,
download etc. You may occasionally receive errors that some functionality
isn't supported.

*****
s3cmd
*****

There is a powerful open source tool for managing object storage called
s3cmd. It is available from https://s3tools.org/s3cmd and was originally
written for managing object storage data in Amazon S3. It is also
compatible with Catalyst Cloud object storage using the OpenStack S3
API.

While it is compatible, you will need to ensure that you specify the
appropriate authentication details by customising the s3cmd configuration file.

Configuration changes
=====================

The following changes need to be specified in the .s3cfg file. You can
select the appropriate API endpoint from :ref:`the API page <apis>`.

s3cmd needs to use signature v2 as we've observed that it has a
compatibility issue when communicating with our S3 interface using the
default of signature v4.

.. code-block:: ini

  host_base = object-storage.nz-por-1.catalystcloud.io:443
  host_bucket = object-storage.nz-por-1.catalystcloud.io:443
  signature_v2 = True
  use_https = True

Compatibility with S3
=====================

Please refer to the `Object Storage section`_ of the OpenStack Swift
documentation for an in depth explanation of the compatibility to S3 APIs.

A tutorial is also covered in the Catalyst Cloud documentation
:ref:`here<s3-api-documentation>`.

.. _Object Storage section: https://docs.openstack.org/swift/latest/s3_compat.html

*************************
Synology NAS Hyper Backup
*************************

Synology NAS systems that support the Hyper Backup package can use
our object storage service for full backups of your NAS, including
system settings and application data.

Hyper Backup will create archives on our object storage service, and
therefore you can only access the content of a backup using the
Hyper Backup application on your NAS. If you need direct access to
copies of files, the Synology Cloud Sync (described below) may be
a better option.

Setup
=====

After installing the "Hyper Backup" package from the Synology Package
Center, the following steps are needed to enable backups of your NAS
to our object storage service:

#. Open "Hyper Backup" from the applications menu (top left button of
   the main NAS page)
#. Click the "+" button in the top left of the Hyper Backup window.
#. Select which type of backup you want, either are supported.
#. For Data backups:

   #. Select "Openstack Swift" from the list of backup destinations and
      click "Next"
   #. On the next page:

      #. For "Identity Service endpoint" enter "https://api.nz-por-1.catalystcloud.io:5000/"
      #. For "Identity Service version" select "3.0" from the drop-down
      #. Enter your Catalyst Cloud username and password in the
         appropriate boxes
      #. For "Tenant/Project" choose "id" from the drop-down, and then
         enter the project ID where objects will be stored. You can find
         the project ID from the Catalyst Cloud dashboard under Identity
         and then Projects.
      #. For "Domain", choose "id" from the drop-down and enter
         "default"
      #. You should now be able to select a Catalyst Cloud region from
         the "Location" drop down.
      #. You can select an existing object container from the
         "Container" drop-down, or create a new one in the same
         drop-down
      #. "Directory" can be left as the default generated by the NAS.
      #. Click Next

   #. Select the volumes you wish to back up, and click "Next"
   #. Select the Synology applications you want backed up, and click
      "Next"
   #. Lastly, you can give the backup job a name, and set the
      backup schedule. Then click "Next"
   #. The next page will allow you set a backup rotation. Click
      "Done" when complete.
   #. You will be promoted if you want to perform a backup now.

Using single-region object containers
=====================================

By default, containers created by your Synology NAS in the above
process will use our multi-region replication mode. This is generally
recommended for backups.

However, if you would prefer single-region object storage, you will
need to create the object container in our dashboard first using this
policy, and then select that container in the process above rather than
creating a new container.

Note: ensure you select the same region you created the object container
in when selecting the location in the steps above.

Restoring backups
=================

Hyper Backup includes a "Backup Explorer" that can restore files and
settings from backups you have in our object storage service.

Consult the Synology documentation for more information on how to
restore backups.

***********************
Synology NAS Cloud Sync
***********************

Synology NAS systems that support the Cloud Sync package can use our
object storage service for backups or two-way syncing of your NAS.

This can be used for backups as an alternative to the Hyper Backup
service described above, with the following differences:

* Cloud Sync preserves files as they are on your NAS in the object
  storage service, so can be used by other clients or directly accessed
  from the Catalyst Cloud dashboard
* As Cloud Sync will sync files only, you cannot use it to backup a
  LUN, system settings, or application data from packages installed on
  your NAS.
* Cloud Sync allows two-way synchronisation, that is writes and updates
  directly to the object storage service can be downloaded to your NAS
  automatically
* When using Cloud Sync as a backup, restoring files is more
  complicated and not provided directly in the Synology NAS UI.
* Cloud Sync can be configured to limit the use of bandwidth while
  syncing, while Hyper Backup will not limit bandwidth usage.
* Cloud Sync will not maintain a history of versions itself, the sync
  is current data only.

Setup
=====

After installing the "Cloud Sync" package from the Synology Package
Center, the following steps are needed to add a backup or sync to
our object storage service:

#. From the applications menu (top left) open Cloud Sync
#. Press the "+" button in the top left of the Cloud Sync pane to add
   a new target.
#. In the list of Cloud Providers, select "OpenStack Swift" and click
   "Next".
#. Enter the following details:

   #. For "Identity Service endpoint", enter "https://api.nz-por-1.catalystcloud.io:5000/"
   #. For "Identity Service version", select "3.0" from the drop-down
   #. Enter your cloud username and password in "Username" and "Password"
   #. For "Tenant/Project" choose "id" from the drop-down, and then
      enter the project ID where objects will be stored. You can find
      the project ID from the Catalyst Cloud dashboard under Identity
      and then Projects.
   #. For "Domain", choose "id" from the drop-down and enter "default"
   #. Click "Next"

#. If your credentials are correct, you will be asked now for a
   location and container name. "Location" chooses which cloud region
   the objects will be stored in. "Container Name" allows you to
   select an existing object storage container, or create a new one.
   You'll need to enter both of these values before hitting "Next"
#. In the next page, the settings provided are:

   #. "Connection name" is a name you'll see for this backup on your
      NAS.
   #. "Local Path" is the directory on your NAS you want backed up.
   #. "Remote Path" can set left as "Root folder". We do not recommend
      sending multiple backups in different folders to the same
      object container.
   #. "Sync direction" can be any of the settings. For a backup, we
      recommend "Upload changes only"
   #. "Part size" must be a minimum of 128MB, however we support any
      size up to 5GB.
   #. For backups, we recommend ticking the option "Don't remove files
      in the destination folder when they are removed in the source
      folder", this means that you can restore deleted files from
      your NAS by copying them from the object storage service.
   #. For other options, please consult Synology DSM documentation.
   #. Note: enabling data encryption may prevent restoring individual
      files.

#. Once clicking Next, you'll be able to confirm the settings and
   enable the sync.


Using single-region object containers
=====================================

By default, containers created by your Synology NAS in the above
process will use our multi-region replication mode. This is generally
recommended for backups.

However, if you would prefer single-region object storage, you will
need to create the object container in our dashboard first using this
policy, and then select that container in the process above rather than
creating a new container.

Note: ensure you select the same region you created the object container
in when selecting the location in the steps above.

Restoring deleted files
=======================

The Synology NAS has no built-in interface to restore files, however
this can be done by downloading the deleted files from the Catalyst
Cloud dashboard. You can browse and download files stored directly
from the dashboard.

Note: If you have enabled "Data Encryption", you will not be able
to restore files with this method.

******
WinSCP
******

WinSCP is an open source and free SFTP and FTP client for MS Windows. It also
supports S3, and is compatible with Catalyst Cloud object storage using the
OpenStack S3 API. It is available from https://winscp.net/ .

Configuration steps
===================

#. New site
#. File protocol: Amazon S3
#. Host name: select the appropriate "s3" endpoint from :ref:`the API page <apis>`.
#. Access Key & Secret Access Key: EC2 credentials (you may wish to create a dedicated user).
