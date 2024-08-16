To download a single object from a container, use the ``swift download`` command,
followed by the container name and the unique object name.

.. code-block:: console

  $ swift download mycontainer-1 file-1.txt
  file-1.txt [auth 0.000s, headers 0.844s, total 0.845s, 0.000 MB/s]

The file will be saved to the local directory of the terminal session.

.. code-block:: console

  $ cat file-1.txt
  Hello, world!

If you'd like to save the file to a specific location
(or under a different name), use the ``--output`` option to specify the destination.

.. code-block:: bash

  $ swift download mycontainer-1 file-1.txt --output /home/example/Downloads/file-1.txt
  file-1.txt [auth 0.000s, headers 0.844s, total 0.845s, 0.000 MB/s]

Multiple objects can be downloaded at once by passing additional arguments.

.. code-block:: console

  $ swift download mycontainer-1 file-1.txt file-2.txt
  file-2.txt [auth 0.000s, headers 0.279s, total 0.279s, 0.000 MB/s]
  file-1.txt [auth 0.000s, headers 0.401s, total 0.402s, 0.000 MB/s]

When downloading multiple objects, use the ``--output-dir`` option to specify
the target directory to download files to:

.. code-block:: console

  $ swift download mycontainer-1 file-1.txt file-2.txt --output-dir /home/example/Downloads
  file-2.txt [auth 0.000s, headers 0.279s, total 0.279s, 0.000 MB/s]
  file-1.txt [auth 0.000s, headers 0.401s, total 0.402s, 0.000 MB/s]
