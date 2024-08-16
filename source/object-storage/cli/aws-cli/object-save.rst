The ``aws s3 cp`` command can be used to download an object from a container,
by specifying the source ``s3://`` URL for the object as the first argument
and the local destination path as the second argument.

.. code-block:: console

  $ aws s3 cp s3://mycontainer-1/file-1.txt file-1.txt
  download: s3://mycontainer-1/file-1.txt to ./file-1.txt

The file will be saved to the target path.

.. code-block:: console

  $ cat file-1.txt
  Hello, world!

Alternatively ``aws s3api get-object`` can be used as shown below,
using ``--bucket`` to specify the container name
and ``--key`` to specify the unique object name.

.. code-block:: console

  $ aws s3api get-object --bucket mycontainer-1 --key file-1.txt file-1.txt
  {
      "LastModified": "2024-08-16T04:28:01+00:00",
      "ContentLength": 14,
      "ETag": "\"746308829575e17c3331bbcb00c0898b\"",
      "ContentType": "binary/octet-stream",
      "Metadata": {}
  }
