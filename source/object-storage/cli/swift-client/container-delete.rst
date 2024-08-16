To delete a container, use the ``swift delete`` command,
followed by the name of the container to delete.

Any objects that exist in the container will also be deleted.

.. code-block:: console

  $ swift delete mycontainer-1
  file-2.txt
  file-1.txt
  mycontainer-1

.. warning::

  There is an ``--all`` option which can be used to delete
  **all objects and containers** in your project.
  This option is **NOT** required to delete a container.
  **Do not use it unless you really intend to delete all containers
  from a project.**
