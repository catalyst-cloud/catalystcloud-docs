Python for Windows can be installed either using the GUI installer,
or using a command-line package manager for automatic installation.

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
