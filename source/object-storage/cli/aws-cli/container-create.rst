.. note::

  It is **not recommended** to create an Object Storage container
  using the AWS CLI, as the :ref:`storage policy <object-storage-storage-policies>`
  for the container cannot be set.

  Containers created using the AWS CLI will always use the default storage policy
  (``nz--o1--mr-r3``).

The preferred method to create a container using the AWS CLI
is to use the ``aws s3api create-bucket`` command,
specifying the container name with ``--bucket``.

.. code-block:: bash

  aws s3api create-bucket --bucket mycontainer-1

``aws s3 mb`` can also be used,
specifying the container as a bucket name using an ``s3://`` URL.

.. code-block:: bash

  aws s3 mb s3://mycontainer-1
