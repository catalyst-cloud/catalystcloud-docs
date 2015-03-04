####################
Command line clients
####################

Each OpenStack project provides a command-line client, which enables you to
interact with the cloud APIs through easy-to-use commands.

.. seealso::

  OpenStack upstream documentation on how to install and use the command line
  tools can be found at:
  http://docs.openstack.org/cli-reference/

********************************
Installing the OpenStack clients
********************************

Ubuntu Linux
============

.. code-block:: bash

  sudo apt-get update
  sudo apt-get install python-ceilometerclient python-cinderclient python-glanceclient python-keystoneclient python-neutronclient python-novaclient python-swiftclient


Redhat / CentOS / Fedora Linux
==============================

.. code-block:: bash

  sudo yum install -y https://rdo.fedorapeople.org/rdo-release.rpm
  sudo yum update -y
  sudo yum install -y python-ceilometerclient python-cinderclient python-glanceclient python-keystoneclient python-neutronclient python-novaclient python-swiftclient

*********************************
Configuring the OpenStack clients
*********************************

Source an OpenStack RC file
===========================

By default, the OpenStack client tools will get their configuraton from
environment variables. To help you define these variables the cloud dashboard
allows you to download an OpenStack RC file from which you can easily source
the required configuration.

To download an OpenStack RC file from the dashboard:

* Log to your project on the dashboard and select your preferred region.

* Go to "Access and Security", select the "API Access" tab and click on
  "Download OpenStack RC File". Save this file to the host where the client
  tools are going to be used from.

* Source the configuration from the OpenStack RC file:

  .. code-block:: bash

    source projectname-openrc.sh

* When prompted for a password, enter the password for the user who downloaded
  the file. Note that your password is not displayed on the screen as you type
  it in.

  .. warning::

    You should never type in your password on the command line (or pass it as
    an argument to the client tools), because the password will be stored in
    plain text on the shell history file. This is unsafe and could allow a
    potential attacker to compromise your credentials.

* You can confirm the configuration works by running a simple command, such as
  "nova list" and ensuring it return no errors.

