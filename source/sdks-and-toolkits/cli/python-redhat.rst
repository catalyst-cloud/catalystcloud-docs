Python is usually pre-installed on standard installations of Fedora
and Red Hat Enterprise Linux.

If it is not already installed, run the following command to install it:

.. code-block:: bash

  sudo dnf install -y python3 python3-devel

Now run the following command to check that the ``python3`` command is usable.

.. code-block:: bash

  python3 --version

If the installed Python version is printed, Python is working correctly.

.. code-block:: console

  $ python3 --version
  Python 3.12.4
