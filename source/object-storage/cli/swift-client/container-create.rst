To create a new Object Storage container, run ``swift post``
followed by the unique name for the new container.

.. code-block:: bash

  swift post mycontainer-1

If you'd like to create the container using a specific
:ref:`storage policy <object-storage-storage-policies>`,
use the ``--header`` option to specify the ``X-Storage-Policy`` header as shown below.

.. code-block:: bash

  swift post mycontainer-1 --header 'X-Storage-Policy: nz-hlz-1--o1--sr-r3'
