The preferred method is to use the ``aws s3api delete-bucket`` command,
specifying the container name with ``--bucket``.
This command can only be used to delete empty containers
(all objects must be deleted before the container itself can be deleted),
so is a safer option to ensure data is not accidentally deleted.

.. code-block:: bash

  aws s3api delete-bucket --bucket mycontainer-1

An alternative is to use the ``aws s3 rb`` command,
specifying the container as a bucket name using an ``s3://`` URL.

.. code-block:: bash

  aws s3 rb s3://mycontainer-1

Unlike ``aws s3api delete-bucket``, this command can be used to delete non-empty containers
using the ``--force`` option.

.. code-block:: bash

  aws s3 rb s3://mycontainer-1 --force
