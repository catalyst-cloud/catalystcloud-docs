.. _s3cmd:

*****
s3cmd
*****

There is a powerful open source tool for managing object storage called
s3cmd. It is available from https://s3tools.org/s3cmd and was originally
written for managing object storage data using S3. It is
compatible with Catalyst Cloud object storage using the OpenStack S3
API.

While it is compatible, you do need to ensure that you specify the
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
