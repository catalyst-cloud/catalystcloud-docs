Check that the ``openstack container`` and ``openstack object`` series of commands available by running the help command.

.. code-block:: console

  $ openstack container --help
  Command "container" matches:
    container create
    container delete
    container list
    container save
    container set
    container show
    container unset
  $ openstack object --help
  Command "object" matches:
    object create
    object delete
    object list
    object save
    object set
    object show
    object store account set
    object store account show
    object store account unset
    object unset

If you have sourced your OpenRC file, you should now be able to run these commands.
