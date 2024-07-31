To install the Catalyst Cloud CLI tools on Fedora or Red Hat Enterprise Linux,
in addition to Python, the packages from the "Development Tools" group
must also be installed.

Run the following command to install them:

.. code:: bash

  sudo dnf groupinstall -y "Development Tools"

This installs a full C/C++ compiler toolchain, which allows you to install
some dependencies of the Catalyst Cloud CLI tools that must be compiled upon
installation.
