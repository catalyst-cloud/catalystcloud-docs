A list of objects can be returned using the ``aws s3 ls`` command,
specifying the container as a bucket name using an ``s3://`` URL.

.. code-block:: console

  $ aws s3 ls s3://mycontainer-1
                             PRE images/
  2024-08-16 14:22:25         14 file-1.txt
  2023-08-25 11:31:27    1908226 image-1.png

Just like on AWS, objects with directory-style prefixes (e.g. ``images/image-2.png``)
are not listed by default. Use the ``--recursive`` option to recursively list all objects
in the container.

.. code-block:: console

  $ aws s3 ls s3://mycontainer-1
  2024-08-16 14:22:25         14 file-1.txt
  2023-08-25 11:31:27    1908226 image-1.png
  2024-08-16 15:55:09     723424 images/image-2.png

For more information on how to use the ``aws s3 ls`` command, see the `AWS CLI documentation <aws s3 ls>`_.

To get the list of objects in a format suitable for ingestion
by a script, use the ``aws s3api list-objects-v2`` command.

.. code-block:: console

  $ aws s3api list-objects-v2 --bucket mycontainer-1
  {
      "Contents": [
          {
              "Key": "file-1.txt",
              "LastModified": "2024-08-16T02:22:25.304000+00:00",
              "ETag": "\"746308829575e17c3331bbcb00c0898b\"",
              "Size": 14,
              "StorageClass": "STANDARD"
          },
          {
              "Key": "image-1.png",
              "LastModified": "2024-08-16T02:22:28.010000+00:00",
              "ETag": "\"90cef9cada92ce2cf05cbde9499afbdb\"",
              "Size": 1908226,
              "StorageClass": "STANDARD"
          },
          {
              "Key": "images/image-2.png",
              "LastModified": "2024-08-16T03:55:09.486000+00:00",
              "ETag": "\"746308829575e17c3331bbcb00c0898b\"",
              "Size": 723424,
              "StorageClass": "STANDARD"
          }
      ],
      "RequestCharged": null
  }

.. _`aws s3 ls`: https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3/ls.html
