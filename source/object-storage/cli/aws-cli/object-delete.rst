The ``aws s3 rm`` command can be used to delete an object from a container,
specifying the ``s3://`` URL for the object.

.. code-block:: console

  $ aws s3 rm s3://mycontainer-1/file-1.txt
  delete: s3://mycontainer-1/file-1.txt

Alternatively ``aws s3api delete-object`` can be used as shown below,
using ``--bucket`` to specify the container name
and ``--key`` to specify the unique object name.

.. code-block:: bash

  aws s3api delete-object --bucket mycontainer-1 --key file-1.txt
