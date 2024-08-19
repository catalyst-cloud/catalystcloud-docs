To create a new Object Storage container, run ``openstack container create``
followed by the unique name for the new container.

.. code-block:: console

  $ openstack container create mycontainer-1
  +---------------------------------------+---------------+------------------------------------+
  | account                               | container     | x-trans-id                         |
  +---------------------------------------+---------------+------------------------------------+
  | AUTH_1a2b3c4d5e1a2b3c4d5e1a2b3c4d5e1a | mycontainer-1 | tx415f9620d24e4ab28f01f-0066beb32f |
  +---------------------------------------+---------------+------------------------------------+

If you'd like to create the container using a specific
:ref:`storage policy <object-storage-storage-policies>`, use the ``--storage-policy`` option
followed by the storage policy name.

.. code-block:: console

  $ openstack container create mycontainer-2 --storage-policy nz-hlz-1--o1--sr-r3
  +---------------------------------------+---------------+------------------------------------+
  | account                               | container     | x-trans-id                         |
  +---------------------------------------+---------------+------------------------------------+
  | AUTH_1a2b3c4d5e1a2b3c4d5e1a2b3c4d5e1a | mycontainer-2 | tx580e7f6582674260b9261-0066beb4a6 |
  +---------------------------------------+---------------+------------------------------------+

Other useful options:

* ``--public`` - Make the container publicly accessible.
  **Be careful when using this option, as no authentication
  will be required to access the container's objects.**
