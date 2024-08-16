Some of the object metadata is available from the S3 CLI.

To get this metadata run the ``aws s3api head-object`` command,
using ``--bucket`` to specify the container name
and ``--key`` to specify the unique object name.

.. code-block:: console

  $ aws s3api head-object --bucket mycontainer-1 --key file-1.txt
  {
      "LastModified": "2024-08-16T02:22:26+00:00",
      "ContentLength": 14,
      "ETag": "\"746308829575e17c3331bbcb00c0898b\"",
      "ContentType": "text/plain",
      "Metadata": {}
  }
