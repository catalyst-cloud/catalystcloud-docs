.. index::
   single: s3cmd
   single: Client Software; s3cmd

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

.. code-block:: ini

  host_base = object-storage.nz-por-1.catalystcloud.io:443
  host_bucket = object-storage.nz-por-1.catalystcloud.io:443

If you are on an older version of s3cmd, you may need to force the use of
signature v2. To do this edit your .s3cfg file, and set:

.. code-block:: ini

  signature_v2 = True
