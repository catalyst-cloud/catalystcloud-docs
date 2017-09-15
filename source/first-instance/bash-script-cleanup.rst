************************************
Resource cleanup using a bash script
************************************

This script includes all the comands from the section above in a single bash
script.

You can download and run this script using the following commands:

.. code-block:: bash

 $ wget -q https://raw.githubusercontent.com/catalyst/catalystcloud-docs/master/scripts/delete-first-instance.sh
 $ chmod 744 delete-first-instance.sh
 $ ./delete-first-instance.sh

.. note::

 You may wish to edit the script before executing, for example to add a prefix.

.. literalinclude:: ../_scripts/delete-first-instance.sh
  :language: bash
