To delete one or more containers, use the ``openstack container delete`` command,
followed by the names of the containers to delete.

.. code-block:: bash

  openstack container delete mycontainer-1

By default, only containers that contain no objects can be deleted.
To delete the containers **and all of the objects contained within them**,
use the ``--recursive`` option.

.. code-block:: bash

  openstack container delete mycontainer-1 --recursive
