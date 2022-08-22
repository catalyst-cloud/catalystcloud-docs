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

#. Using our dashboard, API or commandline, create an Object Storage container
   using your preferred Storage Policy.
#. It is recommended that you use a dedicated user on Catalyst Cloud which only
   has the Object Storage role for performing backups.
#. Use Menu -> Add Backup.
#. Ensure 'Configure a new backup' is selected, go Next.
#. Configure General backup settings. It is a good idea to use encryption for
   you backups, but it isn't required.
#. Configure Backup Destination:

   #. Storage Type: Select: Backup Object Storage / Swift
   #. Bucket name: Enter the name of the container you created in the Step 1.
   #. OpenStack AuthURI: Select a identity API URL from :ref:`apis`.  If you
      are using single region replication, please select the identity API URL
      for the region the container is within.
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
