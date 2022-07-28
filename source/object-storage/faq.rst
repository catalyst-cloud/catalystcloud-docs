###
FAQ
###

***********************************
Can I use s3cmd for object storage?
***********************************

This content has been moved to :doc:`software-configuration`.

While it is compatible, you will need to ensure that you specify the
appropriate authentication details by customizing the s3cmd configuration file.

Configuration changes
=====================

The following changes need to be specified in the .s3cfg file. You can
select the appropriate API endpoint from :ref:`the API page <apis>`.

s3cmd needs to use signature v2 as we've observed that it has a
compatibility issue when communicating with our S3 interface using the
default of signtuare v4.

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
