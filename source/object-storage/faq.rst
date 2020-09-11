###
FAQ
###

***********************************
Can I use s3cmd for object storage?
***********************************

There is a powerful open source tool for managing object storage called
s3cmd. It is available from http://s3tools.org/s3cmd and was originally
written for managing object storage data in Amazon S3. It is also
compatible with Catalyst Cloud object storage using the OpenStack S3
API.

While it is compatible, there is a 'gotcha' with the Catalyst Cloud. In
order to use s3cmd with the Catalyst Cloud, you need to customise the
s3cmd configuration file.

Configuration changes
=====================

The following changes need to be specified in the .s3cfg file.

.. code-block:: ini

  host_base = object-storage.nz-por-1.catalystcloud.io:443
  host_bucket = object-storage.nz-por-1.catalystcloud.io:443
  signature_v2 = True
  use_https = True

Compatibility with S3
=====================

Please refer to the Object Storage section for OpenStack Swift
compatibility to S3 APIs.

.. seealso::

  It is also documented in the Catalyst Cloud documentation
  :ref:`here<s3-api-documentation>`.
