
.. _cli-installation-examples:

*******************************
Commandline Client Installation
*******************************

Overview
========
This guide is intended to provide a details on how to install the latest
OpenStack command line tools for the operating systems and versions
included below.

While it may be possible to get the command OpenStack CLI tools working on
older version of those platforms included they have been excluded at this time
due to the fact that there are constraints,  typically non-compliant system
python versions,  that make this difficult or in some cases risky to achieve.

Approach
========

All examples were implemented using virtualenv in an effort to minimise impact
on exising systems and they have also been tested against Catalyst Cloud to
ensure , that at the time of writing, they worked as expected.

Once the command line client tools have been installed, ensure you have sourced
your OpenStack RC file as shown here :ref:`source-rc-file` then run a simple
command such as the one shown below to confirm that your installation and
credential setup is working correctly.

.. code-block:: bash

    openstack network list

Ubuntu
======

Ubuntu 14.04
############
default python version: 2.7.6

.. code-block:: bash

  # Make sure you have pip and virtualenv installed
  sudo apt-get install python-pip python-virtualenv python-dev

  # Create a new virtual environment for Python and activate it
  virtualenv venv
  source venv/bin/activate

  # Install Python openstackclient library and the Python timezone definitions
  # into your virtual environment
  pip install pytz python-openstackclient

Ubuntu 16.04
############
For the server version of Ubuntu 16.04 the default version of python on the
system is python 3.x. If python 2.7.X is required this must be installed
manually.

Using python version: 2.7.x
---------------------------
.. code-block:: bash

  # Install python 2.7.x, pip and virtualenv
  sudo apt-get install python python-pip python-virtualenv

  # Create a new virtual environment for Python 2.7.x and activate it
  virtualenv venv
  source venv/bin/activate

  # Install Python openstackclient library into your virtual environment
  pip install python-openstackclient

|

Using python version: 3.5.x
----------------------------
The upstream OpenStack documentation states _"Currently, the clients do not
support Python 3"_; however this has been tested and found to be working with
the caveat outlined in the note below.

.. code-block:: bash

  # Make sure you have virtualenv and pip code dependencies installed
  sudo apt-get install python3-dev python-pip python-virtualenv

  # Create a new virtual environment for Python 3.x and activate it
  virtualenv -p /usr/bin/python3 venv
  source venv/bin/activate

  # Install Python openstackclient library into your virtual environment
  pip install python-openstackclient

|

.. note::

    Running openstack in interactive mode will result in an error at this time
    due to a known issue: see
    https://bugs.launchpad.net/python-openstackclient/+bug/1505268
    If complete commands are run however they will work as expected.

Debian
======

Debian 8
########

.. code-block:: bash

  # Make sure you have virtualenv and pip code dependencies installed
  sudo apt-get install gcc python-dev python-virtualenv

  # Create a new virtual environment for Python 3.x and activate it
  virtualenv venv
  source venv/bin/activate

  # Install Python openstackclient library and the Python timezone definitions
  # into your virtual environment
  pip install pytz python-openstackclient


Centos
======

Centos 7.0
##########

.. code-block:: bash

  # Make sure you have python development tools and wget installed
  sudo yum install python-devel gcc wget

  # retrieve the pip installer script and install pip and virtualenv
  wget https://bootstrap.pypa.io/get-pip.py
  sudo python get-pip.py
  sudo pip install virtualenv

  # Create a new virtual environment for Python 3.x and activate it
  virtualenv venv
  source venv/bin/activate

  # Install Python openstackclient library on your virtual environment
  pip install python-openstackclient


Mac
===

MacOSX Yosemite - 10.10.5
#########################
Tested on the default system python, version - 2.7.10.

.. code-block:: bash

  # from a terminal session install pip and virtualenv
  sudo easy_install pip
  sudo pip install virtualenv

  # Create a new virtual environment and activate it
  virtualenv venv
  source venv/bin/activate

  # Install Python openstackclient library on your virtual environment
  pip install python-openstackclient

Windows
=======

Windows Server 2012R2
#####################

A good overview for the setup and configuration of Python, pip and virtualenv
on Windows can be found at http://www.tylerbutler.com/2012/05/how-to-install-python-pip-and-virtualenv-on-windows-with-powershell/

Assuming that Python and pip have successfully been installed then

.. code-block:: bash

  # From a PowerShell session started with administratoion rights
  # create and activate a virtual environment
  virtualenv.exe venv
  .\venv\scripts\activate

  # Install Python openstackclient library on your virtual environment
  pip install python-openstackclient

If any errors are encountered while pip is building packages it may be
necessary to install the following and retry.
Microsoft Visual C++ Compiler for Python 2.7
https://www.microsoft.com/en-gb/download/details.aspx?id=44266
