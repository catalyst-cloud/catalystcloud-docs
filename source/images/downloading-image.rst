##########################
Downloading from the cloud
##########################


An image may be downloaded from Catalyst Cloud by using the :ref:`OpenStack CLI tools <command-line-interface>`.
The command to download an image is:

.. code-block:: bash

  $ openstack image save --file <filename> <ID or name>

Where:
 - ``<filename>`` is the name to save the image file to
 - ``<ID or name>`` is the ID or the name of the image you want to save

For example to download the image called ``ubuntu-22.04-x86_64`` and save it as ``ubuntu-2204.raw`` we can use the
following command:

.. code-block:: bash

  $ openstack image save --file ubuntu-2204.raw ubuntu-22.04-x86_64


The image file will be in the "raw" or "QCOW2" format and may need to be converted to another format in order to be
manipulated or used outside of Catalyst Cloud.  See :doc:`converting-machine-image` for more details.
