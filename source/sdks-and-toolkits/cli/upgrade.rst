.. _upgrading-the-cli:

#################
Upgrading the CLI
#################


*********
Using pip
*********

If you installed the CLI using pip and a virtual environment, you will need to
:ref:`activate-venv` first. Once activated, you can run the following command to
upgrade the CLI:

.. code-block:: bash

  pip install --upgrade python-{openstackclient,ceilometerclient,heatclient,neutronclient,swiftclient,octaviaclient,magnumclient}
