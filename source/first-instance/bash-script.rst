The bash script provided here comprises all the commands from the Openstack CLI
example in a single script.

Download and run this script using the following commands:

.. code-block:: bash

 $ wget -q https://raw.githubusercontent.com/catalyst/catalystcloud-docs/master/source/_scripts/create-first-instance.sh
 $ chmod 744 create-first-instance.sh
 $ ./create-first-instance.sh

.. note::

 Please examine the script carefully before it is run, ensuring that its content,
 function, and impact is thoroughly understood. The script may require editing to
 add a prefix, for example.
 See the "VARS" section at the top of the script for more details.
 In addition to this, you are able to change the default DNS settings if you
 have your own that you wish to use. Otherwise the script will use the
 catalyst cloud DNS by default.

.. literalinclude:: _scripts/bash/create-first-instance.sh
  :language: bash


Instead of using the resource cleanup commands in the section below, you can
use the following bash script:

You can download and run this script using the following commands:

.. code-block:: bash

 $ wget -q https://raw.githubusercontent.com/catalyst/catalystcloud-docs/master/source/_scripts/delete-first-instance.sh
 $ chmod 744 delete-first-instance.sh
 $ ./delete-first-instance.sh

.. note::

 You may wish to edit the script before executing, for example to add a prefix.

.. literalinclude:: _scripts/bash/delete-first-instance.sh
  :language: bash
