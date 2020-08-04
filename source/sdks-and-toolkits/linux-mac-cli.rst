##################################
Linux or Mac OS CLI
##################################

.. _installing_cli_os:
.. _command-line-interface:


*****************************
Installation on Linux and Mac
*****************************

When installing the CLI using pip, it is recommended to use a python virtual
environment to contain the required dependencies. The examples below all make
reference to the use of a virtual environment. If you require more information
on the basic functions of the python virtual environment, please refer to the
:ref:`python-virtual-env` tutorial.

Operating system specific steps
===============================

Here is an outline for installing the Openstack command line tools on the
common Linux/Unix based systems. This includes OSX as it runs a BSD based
system.

.. tabs::

    .. tab:: Ubuntu 20.04

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

    .. tab:: Debian 9

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

    .. tab:: Centos 8

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

    .. tab:: Mac OSX

        .. code-block:: bash

          # from a terminal session install pip and virtualenv
          sudo easy_install pip
          sudo pip install virtualenv

          # Create a new virtual environment and activate it
          virtualenv venv
          source venv/bin/activate

          # Install the Python openstack client libraries into your virtual environment
                    pip install -U pip \
          python-openstackclient \
          python-ceilometerclient \
          python-heatclient \
          python-neutronclient \
          python-swiftclient \
          python-octaviaclient \
          python-magnumclient \
          aodhclient


Using docker (experimental)
===========================

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

.. image:: ../_static/openrc-no-mfa.png
   :align: center

If you need more information on using the file see :ref:`source-rc-file`.

.. _instructions on how to install and configure Docker here: https://docs.docker.com/install/
.. _CLI docker container: https://github.com/catalyst-cloud/openstackclient-container

.. _upgrading-the-cli:

Upgrading the CLI
==================

To keep the command line tools up to date, you will need to perform upgrades
on them after changes have come out. The following code snippet will upgrade
all of the tools listed above;
make sure that you have activated your virtual environment before running the
command below:

.. code-block:: bash

  pip install --upgrade pip \
  python-openstackclient \
  python-ceilometerclient \
  python-heatclient \
  python-neutronclient \
  python-swiftclient \
  python-octaviaclient \
  python-magnumclient \
  aodhclient

******************************
Configuration on Linux and Mac
******************************

.. _configuring-the-cli:

Prior to using the CLI, ensure you are working from a whitelisted IP address.
More information can be found under :ref:`here <access-and-whitelist>`

.. _source-rc-file:

Source an openstack RC file
===========================

When no configuration arguments are passed, the OpenStack client tools will try
to obtain their configuration from environment variables. To help you define
these variables, the cloud dashboard allows you to download an OpenStack RC
file from which you can easily source the required configuration.

To download an OpenStack RC file from the dashboard:

* Log in to your project on the dashboard and select your preferred region.

* From the left hand menu select "API Access" and click on

  "Download OpenStack RC File v3.0". Save this file on the host where the
  client tools are going to be used from.

* Source the configuration from the OpenStack RC file:

  .. code-block:: bash

    source projectname-openrc.sh

* When prompted for a password, enter the password of the user who downloaded
  the file. Note that your password is not displayed on the screen as you type
  it in.

  .. warning::

    You should never type in your password on the command line (or pass it as
    an argument to the client tools), because the password will be stored in
    plain text in the shell history file. This is unsafe and could allow a
    potential attacker to compromise your credentials.

* You can confirm the configuration works by running a simple command, such as
  ``openstack network list`` and ensuring it returns no errors.

.. Note::

  You are also able to download the Openstack RC file from the top-right
  corner where your login details are display as shown below:

.. image:: ../_static/openrc-no-mfa.png
  :align: right

Difference between OpenRC with or without MFA
=============================================

You will notice that when you go to download the OpenRC file from the
dashboard there are 2 version available. One that says OpenStackRC v3
and one that says OpenStackRC v3 (MFA Enabled)

Of course if you have MFA enabled then you will want to download the MFA
enabled file; However, this file can be used on accounts without multi-factor
authentication. The difference between the two is that the normal
OpenstackRC file keeps a copy of your Username and Password and uses those for
authentication against the cloud. Where as the MFA uses a token that gets
passed to the API's for confirmation.

You do not need to have MFA enabled to use the MFA RC file. You can just
enter nothing when prompted for it, and the system will create a token from
your username and password and authenticate it that way.
This is useful for those that care more about Security than convenience. The
trade off is that the Token has a lifespan. After 14 hours the token will
expire and you will have to re-authenticate your credentials to continue
working on your project via the CLI.

******************************
Using the CLI on Linux and Mac
******************************

This page assumes that you have installed the python virtual environment and
other dependencies from the :ref:`installing_cli_os` page earlier in this
section of the documentation. If you have, then the following should make
sense. If you want more information about how to use the python virtual
environment then please check the :ref:`activate-venv` section of our
documentation under tutorials.


**If you installed the CLI using pip:**

1. Activate your virtual environment.
2. :ref:`source-rc-file`
3. Invoke the CLI with the ``openstack`` command

**If you installed the CLI using docker:**

1. :ref:`source-rc-file`
2. Invoke the CLI with the ``ccloud`` alias anywhere the ``openstack`` command
   is otherwise used.


For a reference of all commands supported by the CLI, refer to the `OpenStack
Client documentation <https://docs.openstack.org/python-openstackclient>`_.

*************
The next step
*************

We highly recommend that if you are going to be using the CLI often that you
take the time to go through the documentation section on :ref:`setting up your
first instance <using-the-command-line-interface>`, using the CLI method. It
gives you a great step-by-step process to how to create an instance but also
teaches you the common commands found in openstack and the CLI.
