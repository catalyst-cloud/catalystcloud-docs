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

Configuration steps:
====================

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
