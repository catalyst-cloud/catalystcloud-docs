To get the details of a specific object in a container,
run ``openstack object show``, specifying the container name
and the unique object name.

.. code-block:: console

  $ openstack object show mycontainer-1 file-1.txt
  +----------------+---------------------------------------+
  | Field          | Value                                 |
  +----------------+---------------------------------------+
  | account        | AUTH_1a2b3c4d5e1a2b3c4d5e1a2b3c4d5e1a |
  | container      | mycontainer-1                         |
  | content-length | 14                                    |
  | content-type   | text/plain                            |
  | etag           | 746308829575e17c3331bbcb00c0898b      |
  | last-modified  | Fri, 16 Aug 2024 01:58:10 GMT         |
  | object         | file-1.txt                            |
  +----------------+---------------------------------------+
