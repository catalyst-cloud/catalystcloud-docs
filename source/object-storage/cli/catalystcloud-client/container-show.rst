To view the details for a specific container,
use ``openstack container show`` followed by the container name.

.. code-block:: console

  $ openstack container show mycontainer-1
  +----------------+---------------------------------------+
  | Field          | Value                                 |
  +----------------+---------------------------------------+
  | account        | AUTH_1a2b3c4d5e1a2b3c4d5e1a2b3c4d5e1a |
  | bytes_used     | 1908226                               |
  | container      | mycontainer-1                         |
  | object_count   | 1                                     |
  | storage_policy | nz--o1--mr-r3                         |
  +----------------+---------------------------------------+
