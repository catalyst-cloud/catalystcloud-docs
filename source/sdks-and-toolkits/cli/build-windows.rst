To install the Catalyst Cloud CLI tools on Windows,
in addition to Python, the Microsoft C++ Build Tools (version 14.0 or later)
must also be installed.

This is required to build and install some of the dependencies of the CLI tools.
If the build tools are not installed, you may get build errors while installing
the packages.

First, download the latest version of the
`Microsoft C++ Build Tools <https://visualstudio.microsoft.com/visual-cpp-build-tools>`_
from the website.

.. image:: assets/windows-build-download.png

When you open the installer, it will need to download additional data
to allow the installation to be configured.

Click **Continue** to proceed.

.. image:: assets/windows-build-step1.png

After the download is complete, you will be presented with the main installer
interface.

All we need is "Desktop development with C++", so tick that and then click
**Install** or **Install while downloading** to start the installation.

.. image:: assets/windows-build-step2.png

Once the installation is complete, simply click **OK** to close the dialog.

.. image:: assets/windows-build-step3.png

We can see that **Visual Studio Build Tools** has now been installed,
so close Visual Studio Installer.
We can now continue with installation of the Catalyst Cloud CLI tools.
