.. _installing-the-cli:

##################
Installing the CLI
##################


*********************
Using pip (recommend)
*********************

When installing the CLI using pip, it is recommended to use a python virtual
environment to contain the required dependencies.

The following provides the basics of manually installing the OpenStack command
line tools on common operating systems.

The examples all make reference to the use of virtual environments. Please
refer to the :ref:`python-virtual-env` tutorial for more information on
``venv``.

Operating system specific steps
===============================

.. _installing_ubuntu_cli:

Ubuntu Linux 20.04
------------------

.. code-block:: bash

  # Make sure the package cache is up to date and ensure you have
  # Python3 installed
  sudo apt update
  sudo apt install -y python3-venv python3-dev

  # create a virtual environment using the Python3 virtual environment module
  python3 -m venv venv

  # activate the virtual environment
  source venv/bin/activate

  # install the Openstack commandline tools into the virtual environment
  pip install -U pip \
  wheel \
  python-openstackclient \
  python-ceilometerclient \
  python-heatclient \
  python-neutronclient \
  python-swiftclient \
  python-octaviaclient \
  python-magnumclient \
  aodhclient

.. _installing_debian_cli:

Debian Linux 9
--------------

.. code-block:: bash

  # Make sure the package cache is up to date and ensure you have
  # Python3 installed
  sudo apt update
  sudo apt install -y python3-venv

  # create a virtual environment using the Python3 virtual environment module
  python3 -m venv venv

  # activate the virtual environment
  source venv/bin/activate

  # install the Openstack commandline tools into the virtual environment
  pip install -U pip \
  python-openstackclient \
  python-ceilometerclient \
  python-heatclient \
  python-neutronclient \
  python-swiftclient \
  python-octaviaclient \
  python-magnumclient \
  aodhclient


.. _installing_centos_cli:

CentOS Linux 8
--------------

.. code-block:: bash

  # Make sure the package cache is up to date and ensure you have
  # Python3 installed
  sudo yum update -y
  sudo yum install -y python3

  # create a virtual environment using the Python3 virtual environment module
  python3 -m venv venv

  # activate the virtual environment
  source venv/bin/activate

  # install the Openstack commandline tools into the virtual environment
  pip install -U pip \
  python-openstackclient \
  python-ceilometerclient \
  python-heatclient \
  python-neutronclient \
  python-swiftclient \
  python-octaviaclient \
  python-magnumclient \
  aodhclient

.. _installing_macos_cli:

MacOS
-----

.. code-block:: bash

  # from a terminal session install pip and virtualenv
  sudo easy_install pip
  sudo pip install virtualenv

  # Create a new virtual environment and activate it
  virtualenv venv
  source venv/bin/activate

  # Install the Python openstack client libraries into your virtual environment
  pip install python-{openstackclient,ceilometerclient,heatclient,neutronclient,swiftclient,octaviaclient,magnumclient}

.. _installing_windows_powershell_cli:

Windows (Powershell)
--------------------

A good overview for the setup and configuration of Python and pip
on Windows can be found at http://www.tylerbutler.com/2012/05/how-to-install-python-pip-and-virtualenv-on-windows-with-powershell/

.. Note::
  The guide above mentions how to download virtualenv for powershell, however
  this is assuming you are using python2 which has been discontinued. For this
  reason, we recommend using pip to install the normal `virtualenvwrapper.`
  using `pip install virtualenvwrapper`

Assuming that Python and pip have successfully been installed then

.. code-block:: powershell

  # From a PowerShell session started with administration rights
  # create and activate a virtual environment
  virtualenv.exe venv
  .\venv\scripts\activate

  # Install the Python openstack client libraries into your virtual environment
  pip install python-openstackclient python-ceilometerclient python-heatclient python-neutronclient python-swiftclient python-octaviaclient python-magnumclient

Now that you have installed the required libraries to work with the Catalyst
Cloud onto your virtual environment; You have to make sure that whenever you
use powershell to interact with the cloud, you work on your Virtual
Environment. It may save time to make a short python script that runs the
activation command for you when you start powershell up.

If any errors are encountered while pip is building packages it may be
necessary to install the `Microsoft Visual C++ Compiler for Python 2.7`_
and retry.

.. _Microsoft Visual C++ Compiler for Python 2.7: https://www.microsoft.com/en-gb/download/details.aspx?id=44266

.. _installing_windows_linux_subsystem_cli:

Windows (Linux Subsystem)
-------------------------
This is a much easier method to using the Command Line Interface on a windows
machine. It allows you to create a virtual instance of a linux operating
system of your choice, then complete the rest of this tutorial as if you were
running said operating system.
For this example we will be using Ubuntu 18.04

.. Note::
 This method is only available if you currently run a 64bit version of windows.

First, you will need to open PowerShell as an Administrator and run:

.. code-block:: powershell

 # Running as Administrator
 Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

You will then need to download a version of Ubuntu from either the Microsoft
store, from a command line script, or to manually unpack it and install it from
their release website. For our purposes we will be using the Microsoft Store.

.. image:: ../assets/windows-store.png

I've chosen to use Ubuntu 18.04. Once installed, you open the application
and set up an Unix account. An Unix account is only relevant on your machine
and once set up you won't need to use your login details again (but hold on to
them for security purposes) Once that is done you will be met with a screen
somewhat like this:

.. image:: ../assets/unix-shell.png

Once you have this up and running, you'll need to change directory to be
able to find files you download onto your windows machine.
The following code should get you to your root folder, aka 'My Computer'

.. code-block:: bash

  $ cd /mnt/c

Then you simply need to follow the guide on how to install the CLI on ubuntu
detailed :ref:`earlier on this page.<installing_ubuntu_cli>`

.. _installing_docker_cli:


***************************
Using Docker (experimental)
***************************

The Catalyst Cloud CLI is available as a Docker container that is easy to use,
packaging the command line interface and all its dependencies.

This tool requires Docker to be installed to function. You can find
`instructions on how to install and configure Docker here`_. You can run the
``docker ps`` command to confirm Docker has been successfully installed.

Run the following command to install the Catalyst Cloud CLI:

.. code-block:: bash

  bash <(wget -qO - https://raw.githubusercontent.com/catalyst-cloud/openstackclient-container/master/fetch-installer.sh) -a ccloud -u https://api.cloud.catalyst.net.nz:5000/v3


.. Note::

  Our documentation currently refers to the CLI command as ``openstack``. When
  using the containerised version of the CLI, this command must be replaced with
  ``ccloud`` in the provided examples.

If you are intending to use the containerised tools you will need to obtain the
non MFA enabled openrc file for authentication.To get a copy of the non MFA
enabled openrc file, select the dropdown in the upper right corner of the dash
board and click on ``OpenStack RC File v3``. Select ``Save As`` when prompted to
select the location on your machine to save this file to.

.. image:: ../../_static/openrc-no-mfa.png
   :align: center

If you need more information on using the file see :ref:`source-rc-file`.

.. _instructions on how to install and configure Docker here: https://docs.docker.com/install/
.. _CLI docker container: https://github.com/catalyst-cloud/openstackclient-container
