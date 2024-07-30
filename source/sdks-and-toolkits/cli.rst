.. _cli:

##################
Catalyst Cloud CLI
##################

.. _`Catalyst Cloud API Client`: https://pypi.org/project/catalystcloud-client

.. _cli-setup-python:

************
Setup Python
************

The Catalyst Cloud CLI tools are written in Python, so before they can be installed,
a working Python environment must be available on your system.

To install the CLI tools for Catalyst Cloud, it is recommended to use
`a supported version of Python <https://devguide.python.org/versions>`_.
When using the :ref:`Catalyst Cloud API Client <cli-catalystcloud-client>`,
Python 3.8 or later is required (available from Ubuntu 20.04 LTS onwards).

.. tabs::

  .. group-tab:: Debian / Ubuntu

      Run the following commands to install Python on your system, and additional packages
      required for managing virtual environments:

      .. code-block:: bash

        sudo apt-get update
        sudo apt-get install -y python3 python3-dev python3-venv

      Now run the following command to check that the ``python3`` command is usable.

      .. code-block:: bash

        python3 --version

      If the installed Python version is printed, Python is working correctly.

      .. code-block:: console

        $ python3 --version
        Python 3.12.4

  .. group-tab:: Fedora / Red Hat

      Python is usually pre-installed on standard installations of Fedora
      and Red Hat Enterprise Linux.

      If it is not already installed, run the following command to install it:

      .. code-block:: bash

        sudo dnf install -y python3

      Now run the following command to check that the ``python3`` command is usable.

      .. code-block:: bash

        python3 --version

      If the installed Python version is printed, Python is working correctly.

      .. code-block:: console

        $ python3 --version
        Python 3.12.4

  .. group-tab:: macOS

      While `Python for macOS <https://brew.sh/>`_ can be installed directly
      from the website, we recommend using a package manager such as
      `Homebrew <https://brew.sh>`_.

      Once Homebrew is installed, just run the following command to install Python:

      .. code-block:: bash

        brew install python

      Now run the following command to check that the ``python`` command is usable.

      .. code-block:: bash

        python --version

      If the installed Python version is printed, Python is working correctly.

      .. code-block:: console

        $ python --version
        Python 3.12.4

  .. group-tab:: Windows

      .. tabs::

        .. group-tab:: Installer

          First, download the latest version of
          `Python for Windows <https://www.python.org/downloads/windows>`_
          for your architecture (which will be **64-bit** for a regular
          PC, or **ARM64** for an ARM-based PC).

          .. image:: assets/windows-installer-download.png

          Run the downloaded file to start the installation process.

          Make sure the "Use admin privileges when installing py.exe"
          and "Add python.exe to PATH" are checked, and click
          **Customize installation** to change some settings before
          installation starts.

          .. image:: assets/windows-installer-step1.png

          In the **Optional Features** section, we recommend
          selecting all available options to install a fully featured
          Python environment.

          If you would like a minimal installation, make sure that
          "pip" is checked at a minimum. If "py" is selected, make sure
          that "for all users (requires admin permissions)" is also checked.

          Click **Next** to continue installation.

          .. image:: assets/windows-installer-step2.png

          In **Advanced Options**, make sure "Install Python for all users"
          is checked.
          The other options here can be changed according to your needs.
          If unsure, leave them set to their defaults.

          Now we are ready to install Python. Click **Install** to start.

          .. image:: assets/windows-installer-step3.png

          Once the installation is complete, you can simply click **Close**.

          "Disable path length limit" is optional.

          .. image:: assets/windows-installer-step4.png

          Now open a PowerShell window, and run the following
          command to check that the ``python`` command is usable.

          .. code-block:: powershell

            python --version

          If the installed Python version is printed, Python is working correctly.

          .. image:: assets/windows-installer-check.png

        .. group-tab:: Scoop

          Python can be automatically installed using the
          `Scoop <https://scoop.sh>`_ command-line installer.

          Once Scoop is installed, open PowerShell and run the following command to install Python:

          .. code-block:: powershell

            scoop install python

          Now run the following command to check that the ``python`` command is usable.

          .. code-block:: powershell

            python --version

          If the installed Python version is printed, Python is working correctly.

          .. code-block:: powershell

            > python --version
            Python 3.12.4

.. _cli-installation:

************
Installation
************

Now that Python is installed and working, we can install the CLI tools
used to interact with Catalyst Cloud.

.. _cli-installation-catalystcloud-client:

Catalyst Cloud API Client
=========================

We now provide a package called the `Catalyst Cloud API Client`_ that makes it easy
to install the packages for interacting with Catalyst Cloud in a command line environment.

Just install the ``catalystcloud-client`` package:

.. tabs::

  .. group-tab:: pipx

    .. code-block:: bash

      pipx install catalystcloud-client --include-deps

  .. group-tab:: pip

    .. code-block:: bash

      pip install catalystcloud-client

And the ``openstack`` command will become available, with all of the
API client packages required for our cloud services automatically installed
using the correct versions.

.. note::

  The Catalyst Cloud API Client is not required to use our cloud
  from the command line.
  It is a convenience option we provide for our customers to make it
  easier and quicker to get started with Catalyst Cloud.

  The standard OpenStack CLI packages can be installed and used
  without installing the Catalyst Cloud API Client, as documented below.

.. _cli-installation-procedure:

Procedure
=========

There are many ways to install the tools for using Catalyst Cloud on the command line,
depending on your use case.

Pick your preferred package and installation method, and follow the documented steps.

.. tabs::

  .. group-tab:: Catalyst Cloud API Client

    The Catalyst Cloud API Client is a standard Python package available on PyPI,
    and can be installed using one of the following methods.

    .. tabs::

      .. group-tab:: pipx

        `pipx <https://pipx.pypa.io>`_ is an easy way to install Python programs
        to your local user environment, while keeping the packages themselves
        in isolated environments to keep your system Python clean.

        To install the Catalyst Cloud API Client using pipx, run the following command:

        .. code-block:: bash

          pipx install catalystcloud-client --include-deps

        This will automatically install the ``openstack`` command
        to the your user's runtime environment, as well as all of
        the required API client packages for interacting with
        Catalyst Cloud, using supported versions.

        .. note::

          The ``--include-deps`` option is required because ``catalystcloud-client``
          is a **metapackage**, a package that installs other packages which contain
          the CLI commands you will use when interacting with Catalyst Cloud.

          The command to use when interacting with Catalyst Cloud is called ``openstack``.

        Once the installation is complete, run the following command to
        check that the ``openstack`` command is available.

        .. code-block:: bash

          openstack --version

        If the command version is printed, everything is working correctly.

        .. code-block:: console

          $ openstack --version
          openstack 6.0.1

        To update the Catalyst Cloud API Client to the latest version,
        simply run ``pipx upgrade`` to update the package and
        all of its dependencies.

        .. code-block:: bash

          pipx upgrade catalystcloud-client

      .. group-tab:: pip

        To install the Catalyst Cloud API Client using pip, we need to create and activate
        a **virtual environment** to install packages to.

        .. include:: cli/virtualenv.rst

        We can now install the Catalyst Cloud API Client into the virtual environment.

        To install the package, run the following command:

        .. code-block:: bash

          python -m pip install catalystcloud-client

        This will automatically install the ``openstack`` command
        to the virtual environment, as well as all of the required
        API client packages for interacting with Catalyst Cloud,
        using supported versions.

        Once the installation is complete, run the following command to
        check that the ``openstack`` command is available.

        .. code-block:: console

          $ openstack --version
          openstack 6.0.1

        .. note::

          Virtual environments are isolated from your user's runtime environment.

          When opening a new shell, you will need to activate the virtual environment
          again to use the Catalyst Cloud API Client.

        To update the Catalyst Cloud API Client to the latest version,
        run pip again with the ``--upgrade`` option to
        update the package and all of its dependencies.

        .. code-block:: bash

          python -m pip install --upgrade catalystcloud-client

  .. group-tab:: OpenStack CLI

    While we recommend using the :ref:`Catalyst Cloud API Client <cli-catalystcloud-client>`
    to install the required CLI commands for interacting with Catalyst Cloud,
    it is not required.

    The individual OpenStack API client packages can be installed directly.
    This allows you to only install the packages required for the services
    you wish to use.
    For more information on the client packages required for specific services,
    refer to `Available Commands`_ in the Catalyst Cloud API Client documentation.

    .. _`Available Commands`: https://github.com/catalyst-cloud/catalystcloud-client/blob/main/README.md#available-commands

    .. tabs::

      .. group-tab:: pip

        To install the OpenStack CLI using pip, we need to create and activate
        a **virtual environment** to install packages to.

        .. include:: cli/virtualenv.rst

        We can now install the OpenStack CLI into the virtual environment.

        To install the OpenStack CLI run the following command:

        .. code-block:: bash

          python -m pip install "openstacksdk<0.99" python-openstackclient aodhclient gnocchiclient python-adjutantclient python-barbicanclient python-cinderclient python-distilclient python-glanceclient python-heatclient python-keystoneclient python-magnumclient python-neutronclient python-novaclient python-octaviaclient python-openstackclient python-swiftclient python-troveclient

        This installs the ``openstack`` command, as well as all of the
        required API client packages for interacting with Catalyst Cloud,
        using supported versions.

        Once the installation is complete, run the following command to
        check that the ``openstack`` command is available.

        .. code-block:: console

          $ openstack --version
          openstack 6.0.1

        .. note::

          Virtual environments are isolated from your user's runtime environment.

          When opening a new shell, you will need to activate the virtual environment
          again to use the OpenStack CLI.

*************
Configuration
*************
