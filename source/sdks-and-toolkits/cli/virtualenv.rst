For more information on virtual environments, refer to the Python tutorial on
`Virtual Environments and Packages <https://docs.python.org/3/tutorial/venv.html>`_.

.. tabs::

  .. group-tab:: Debian / Ubuntu

    First, **create** a new virtual environment using the following command.

    This creates a new folder in the current directory named ``catalystcloud-cli``
    containing an isolated Python runtime environment.

    .. code-block:: bash

      python3 -m venv catalystcloud-cli

    Next, **activate** the virtual environment by sourcing the ``activate`` script
    into your shell.

    .. code-block:: bash

      . catalystcloud-cli/bin/activate

    ``(catalystcloud-cli)`` should now be prepended to your shell prompt,
    and the ``python`` command will be provided from the virtual environment,
    as shown below.

    .. code-block:: console

      (catalystcloud-cli) $ which python
      .../catalystcloud-cli/bin/python

  .. group-tab:: Red Hat / CentOS

    First,  **create** a new virtual environment using the following command.

    This creates a new folder in the current directory named ``catalystcloud-cli``
    containing an isolated Python runtime environment.

    .. code-block:: bash

      python3 -m venv catalystcloud-cli

    Next, **activate** the virtual environment by sourcing the ``activate`` script
    into your shell.

    .. code-block:: bash

      . catalystcloud-cli/bin/activate

    ``(catalystcloud-cli)`` should now be prepended to your shell prompt,
    and the ``python`` command will be provided from the virtual environment,
    as shown below.

    .. code-block:: console

      (catalystcloud-cli) $ which python
      .../catalystcloud-cli/bin/python

  .. group-tab:: macOS

    First,  **create** a new virtual environment using the following command.

    This creates a new folder in the current directory named ``catalystcloud-cli``
    containing an isolated Python runtime environment.

    .. code-block:: bash

      python -m venv catalystcloud-cli

    Next, **activate** the virtual environment by sourcing the ``activate`` script
    into your shell.

    .. code-block:: bash

      . catalystcloud-cli/bin/activate

    ``(catalystcloud-cli)`` should now be prepended to your shell prompt,
    and the ``python`` command will be provided from the virtual environment,
    as shown below.

    .. code-block:: console

      (catalystcloud-cli) $ which python
      .../catalystcloud-cli/bin/python

  .. group-tab:: Windows

    First, **create** a new virtual environment using the following command.

    This creates a new folder in the current directory named ``catalystcloud-cli``
    containing an isolated Python runtime environment.

    .. code-block:: bash

      python -m venv catalystcloud-cli

    Next, **activate** the virtual environment by running the ``activate`` script
    for your shell.

    .. tabs::

      .. group-tab:: PowerShell

        .. code-block:: powershell

          catalystcloud-cli\Scripts\Activate.ps1

      .. group-tab:: Command Prompt

        .. code-block:: batch

          catalystcloud-cli\Scripts\activate.bat

    ``(catalystcloud-cli)`` should now be prepended to your shell prompt,
    and the ``python`` command will be provided from the virtual environment,
    as shown below.

    .. code-block:: powershell

      (catalystcloud-cli) > where python
      ...\catalystcloud-cli\Scripts\python.exe
