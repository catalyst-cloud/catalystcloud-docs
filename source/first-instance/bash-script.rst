*************************************************
Launching your first instance using a bash script
*************************************************

This section provides a bash script that runs the commands from the previous
section in a single script.

You can download and run this script using the following commands:

.. code-block:: bash

 $ wget -q https://raw.githubusercontent.com/catalyst/catalystcloud-docs/master/scripts/create-first-instance.sh
 $ chmod 744 create-first-instance.sh
 $ ./create-first-instance.sh

.. note::

 You may wish to edit the script before executing, for example to add a prefix.

.. literalinclude:: ../../scripts/create-first-instance.sh
  :language: bash
