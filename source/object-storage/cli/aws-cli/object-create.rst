The ``aws s3 cp`` command can be used to upload an object to a container,
by specifying the local source path as the first argument
and the destination ``s3://`` URL for the object as the second argument.

.. code-block:: console

  $ aws s3 cp file-1.txt s3://mycontainer-1/file-1.txt
  upload: ./file-1.txt to s3://mycontainer-1/file-1.txt

Alternatively ``aws s3api put-object`` can be used as shown below,
using ``--body`` to specify the source file path,
``--bucket`` to specify the container name
and ``--key`` to specify the unique object name.

.. code-block:: console

  $ aws s3api put-object --body file-1.txt --bucket mycontainer-1 --key file-1.txt
  {
      "ETag": "\"746308829575e17c3331bbcb00c0898b\""
  }
