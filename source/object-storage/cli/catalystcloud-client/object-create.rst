To upload a new object to a container, run ``openstack object create``,
followed by the container name and the path of the file to upload.

.. code-block:: console

  $ openstack object create mycontainer-1 file-1.txt
  +------------+---------------+----------------------------------+
  | object     | container     | etag                             |
  +------------+---------------+----------------------------------+
  | file-1.txt | mycontainer-1 | 746308829575e17c3331bbcb00c0898b |
  +------------+---------------+----------------------------------+

Use the ``--name`` option to upload the object to the container
using a different name.

.. code-block:: console

  $ openstack object create mycontainer-1 file-1.txt --name custom-name.txt
  +-----------------+---------------+----------------------------------+
  | object          | container     | etag                             |
  +-----------------+---------------+----------------------------------+
  | custom-name.txt | mycontainer-1 | 746308829575e17c3331bbcb00c0898b |
  +-----------------+---------------+----------------------------------+

You can also upload multiple files at once in a single command.
Note that ``--name`` is not usable when uploading multiple files.

.. code-block:: console

  $ openstack object create mycontainer-1 file-1.txt file-2.txt
  +------------+---------------+----------------------------------+
  | object     | container     | etag                             |
  +------------+---------------+----------------------------------+
  | file-1.txt | mycontainer-1 | 746308829575e17c3331bbcb00c0898b |
  | file-2.txt | mycontainer-1 | 90cef9cada92ce2cf05cbde9499afbdb |
  +------------+---------------+----------------------------------+
