To download a single object from a container, use the ``openstack object save`` command,
followed by the container name and the unique object name.

.. code-block:: bash

  openstack object save mycontainer-1 file-1.txt

The file will be saved to the local directory of the terminal session.

.. code-block:: console

  $ cat file-1.txt
  Hello, world!

If you'd like to save the file to a specific location
(or under a different name), use the ``--file`` option to specify the destination.

.. code-block:: bash

  openstack object save mycontainer-1 file-1.txt --file /home/example/Downloads/file-1.txt
