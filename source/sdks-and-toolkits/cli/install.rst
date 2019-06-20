.. _installing-the-cli:

###############
Install the CLI
###############


**********************
Install (using Docker)
**********************

The Catalyst Cloud CLI is available as a Docker container that is easy to use,
packaging the command line interface and all its dependencies.

This tool requires Docker to be installed to function. You can find
`instructions on how to install and configure Docker here`_. You can run the
``docker ps`` command to confirm Docker has been successfully installed.

Run the following command to install the Catalyst Cloud CLI:

.. code-block:: bash

  bash <(wget -qO - https://raw.githubusercontent.com/catalyst-cloud/openstackclient-container/master/fetch-installer.sh) -a ccloud -u https://api.cloud.catalyst.net.nz:5000/v3


.. Note::

  If you are intending to use the containerised tools you will need to obtain
  the non MFA enabled openrc file for authentication.

To get a copy of the non MFA enabled openrc file, select the dropdown in the
upper right corner of the dash board and click on ``OpenStack RC File v3``.
Select ``Save As`` when prompted to select the location on your machine to
save this file to.

.. image:: ../../_static/openrc-no-mfa.png
   :align: center

If you need more information on using the file see :ref:`source-rc-file`.

.. _instructions on how to install and configure Docker here: https://docs.docker.com/install/
.. _CLI docker container: https://github.com/catalyst-cloud/openstackclient-container





*******************
Install (using pip)
*******************

When installing the CLI using pip, it is recommended to use a python virtual
environment to contain the required dependencies.

The following provides the basics of manually installing the OpenStack command
line tools on common operating systems.

The examples all make reference to the use of virtual environments. Please
refer to the :ref:`python-virtual-env` tutorial for more information on
``venv``.

Operating System Specific Steps
===============================

Ubuntu Linux 18.04
------------------

Ubuntu 18.04 uses Python 3.x by default. We recommended using Python3.x
because python2 has been schedualed for retirement soon and therefore migrating
over to Python3 is a necessity.

.. code-block:: bash

  # Install python 3.x and virtualenv
  sudo apt-get install python3 python3-ven

  # Create a new virtual environment and activate it
  python3 -m venv vevn

  # Activate the virtual environment
  source venv/bin/activate

  # Install the Python openstack client libraries into your virtual environment
  pip install python-{openstackclient,ceilometerclient,heatclient,neutronclient,swiftclient,octaviaclient,magnumclient}


Debian Linux 8
--------------

.. code-block:: bash

  # Make sure you have virtualenv and pip code dependencies installed
  sudo apt-get install gcc python-dev python-virtualenv

  # Create a new virtual environment for Python 3.x and activate it
  virtualenv venv

  # Activate the virtual environment
  source venv/bin/activate

  # Install the Python openstack client libraries and the Python timezone definitions
  # into your virtual environment
  pip install pytz python-{openstackclient,ceilometerclient,heatclient,neutronclient,swiftclient,octaviaclient,magnumclient}

CentOS Linux 7
--------------

.. code-block:: bash

  # Make sure you have Python development tools and wget installed
  sudo yum install python-devel gcc wget

  # retrieve the pip installer script and install pip and virtualenv
  wget https://bootstrap.pypa.io/get-pip.py
  sudo python get-pip.py
  sudo pip install virtualenv

  # Create a new virtual environment for Python 3.x and activate it
  virtualenv venv

  # Activate the virtual environment
  source venv/bin/activate

  # Install the Python openstack client libraries into your virtual environment
  pip install Python-{openstackclient,ceilometerclient,heatclient,neutronclient,swiftclient,octaviaclient,magnumclient}

Mac OS X
--------

.. code-block:: bash

  # from a terminal session install pip and virtualenv
  sudo easy_install pip
  sudo pip install virtualenv

  # Create a new virtual environment and activate it
  virtualenv venv
  source venv/bin/activate

  # Install the Python openstack client libraries into your virtual environment
  pip install python-{openstackclient,ceilometerclient,heatclient,neutronclient,swiftclient,octaviaclient,magnumclient}

Windows Server 2012 R2
----------------------

A good overview for the setup and configuration of Python, pip and virtualenv
on Windows can be found at http://www.tylerbutler.com/2012/05/how-to-install-python-pip-and-virtualenv-on-windows-with-powershell/

Assuming that Python and pip have successfully been installed then

.. code-block:: powershell

  # From a PowerShell session started with administration rights
  # create and activate a virtual environment
  virtualenv.exe venv
  .\venv\scripts\activate

  Install the Python openstack client libraries into your virtual environment
  pip install python-{openstackclient,ceilometerclient,heatclient,neutronclient,swiftclient,octaviaclient,magnumclient}


If any errors are encountered while pip is building packages it may be
necessary to install the `Microsoft Visual C++ Compiler for Python 2.7`_ and retry.

.. _Microsoft Visual C++ Compiler for Python 2.7: https://www.microsoft.com/en-gb/download/details.aspx?id=44266
