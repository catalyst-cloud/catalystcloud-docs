.. _using-a-bash-script:

*******************
Using a bash script
*******************

The bash script provided here comprises all the commands from the section
:ref:`using-the-command-line-interface` in a single script.

Download and run this script using the following commands:

.. code-block:: bash

 $ wget -q https://raw.githubusercontent.com/catalyst/catalystcloud-docs/master/scripts/create-first-instance.sh
 $ chmod 744 create-first-instance.sh
 $ ./create-first-instance.sh

.. note::

 Please examine the script carefully before it is run, ensuring that its content,
 function, and impact is thoroughly understood. The script may require editing to
 add a prefix, for example.
 See the "VARS" section at the top of the script for more details.

.. literalinclude:: ../_scripts/create-first-instance.sh
  :language: bash
