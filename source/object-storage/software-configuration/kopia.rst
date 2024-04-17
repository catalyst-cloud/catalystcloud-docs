*****
Kopia
*****

A fast and secure Open-Source Backup Software for Windows, Mac, and Linux.

The Kopia installer, which is available from https://kopia.io/ . There are
both command line and GUI versions available. You should pick the one
which best suits your needs.

commandline version
===================

You may wish to replace the s3 URL with another s3 API URL from :ref:`apis`.
If you are using single region replication, please select the s3 API URL for
the region your container is within (for single region profiles).  Please
note that you don't include 'https://' when providing the endpoint.

.. code-block:: bash

  kopia repository create s3 \
        --endpoint=object-storage.nz-por-1.catalystcloud.nz
        --bucket=... \
        --access-key=... \
        --secret-access-key=...

GUI
===

You can use the Kopia GUI, please note that on Linux releases since 2025 there
is an upstream issue in Kopia around the GTK library support, you may need to
run: `kopia-ui --gtk-version=3`

You may wish to replace the s3 URL with another s3 API URL from :ref:`apis`.
If you are using single region replication, please select the s3 API URL for
the region your container is within (for single region profiles).

#. Select "Amazon S3 or Compatible Storage"
#. Enter the following details:

   #. Bucket: A bucket you have already created.
   #. Server Endpoint:  object-storage.nz-por-1.catalystcloud.io  (note, don't include "https://")
   #. Override Region: leave blank
   #. Access Key ID: EC2 Access Key for your project
   #. Secret Access Key: EC2 Secret Key for your project
   #. Sesstion Token: leave blank
   #. Object Name Prefix: Set a prefix if desired.
   #. Next

#. Create New Repository

   #. Enter Password and Confirmation
   #. Create Repository

You can now take snapshots, create schedules etc.
