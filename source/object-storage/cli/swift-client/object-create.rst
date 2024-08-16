To upload a new object to a container, run ``swift upload``,
followed by the container name and the path of the file to upload.

.. code-block:: console

  $ swift upload mycontainer-1 file-1.txt
  file-1.txt

Use the ``--object-name`` option to upload the object to the container
using a different name.

.. code-block:: console

  $ swift upload mycontainer-1 file-1.txt --object-name custom-name.txt
  custom-name.txt

You can also upload multiple files at once in a single command.
Note that ``--object-name`` is not usable when uploading multiple files.

.. code-block:: console

  $ swift upload mycontainer-1 file-1.txt file-2.txt
  file-1.txt
  file-2.txt
