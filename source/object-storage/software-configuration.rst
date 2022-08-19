######################
Software Configuration
######################

Documentation of software or hardware in this section should not be taken
as an endorsement or recommendation. It records the configuration that we
have observed as required, or that our customers have notified us about.

*********
Duplicati
*********

Duplicati has a backup tool for MS Windows, MacOS and Linux. It is available
from: https://www.duplicati.com/ .  It is compatible with Catalyst Cloud
object storage. To configure backing up to Catalyst Cloud:

#. Using our dashboard, API or commandline, create an Object Storage container using your preferred Storage Policy.
#. It is recommended that you use a dedicated user on Catalyst Cloud which only has the Object Storage role for performing backups.
#. Use Menu -> Add Backup.
#. Ensure 'Configure a new backup' is selected, go Next.
#. Configure General backup settings. It is a good idea to use encryption for you backups, but it isn't required.
#. Configure Backup Destination:

   #. Storage Type: Select: Backup Object Storage / Swift
   #. Bucket name: Enter the name of the container you created in the Step 1.
   #. OpenStack AuthURI: Select a identity API URL from :ref:`apis`.  If you are using single region replication, please select the identity API URL for the region the container is within.
   #. Keystone API version: Select: v3
   #. Domain Name: Enter: default
   #. Username & Password: The account credentials you'd like to use.
   #. Tenant Name: Enter the project for the container.

#. Source Data: Select the paths and/or files to backup.
#. Schedule: Set the desired schedule.
#. Options: You can probably leave the defaults.

*****
s3cmd
*****

There is a powerful open source tool for managing object storage called
s3cmd. It is available from http://s3tools.org/s3cmd and was originally
written for managing object storage data in Amazon S3. It is also
compatible with Catalyst Cloud object storage using the OpenStack S3
API.

While it is compatible, you will need to ensure that you specify the
appropriate authentication details by customizing the s3cmd configuration file.

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

***********************
Synology NAS Cloud Sync
***********************

Synology NAS systems that support the Cloud Sync package can use our
object storage service for backups or two-way syncing of your NAS.

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

   #. For "Identity Service endpoint", enter "https://api.nz-por-1.catalystcloud.io:5000/v3"
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

Restoring deleted files
=======================

The Synology NAS has no built-in interface to restore files, however
this can be done by downloading the deleted files from the Catalyst
Cloud dashboard. You can browse and download files stored directly 
from the dashboard.

Note: If you have enabled "Data Encryption", you will not be able
to restore files with this method.