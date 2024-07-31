.. _cli:

##################
Catalyst Cloud CLI
##################

This guide documents how to install, configure and use the command line interface (CLI)
tools for interacting with Catalyst Cloud APIs.

Catalyst Cloud supports a rich command line interface based around the
`OpenStack Client <https://docs.openstack.org/python-openstackclient/latest/index.html>`_,
an extensible command line interface for OpenStack-based clouds,
along with a number of plugins for interacting with our numerous
cloud services. The command line tools can be used on Linux, macOS and Windows.

We provide a convenience package for installing OpenStack Client
and the numerous plugins that provide access to our services called
the :ref:`cli-installation-catalystcloud-client`.
Using this package in the instructions below should make it easier
to get your Catalyst Cloud CLI environment up and running.

.. _cli-setup-python:

************
Setup Python
************

The Catalyst Cloud CLI tools are written in Python, so before they can be installed,
a working Python environment must be available on your system.

It is recommended to install
`a supported version of Python <https://devguide.python.org/versions>`_.
When using the :ref:`Catalyst Cloud API Client <cli-installation-catalystcloud-client>`,
Python 3.8 or later is required (available from Ubuntu 20.04 LTS onwards).

.. tabs::

  .. group-tab:: Debian / Ubuntu

    .. include:: cli/python-debian.rst

  .. group-tab:: Fedora / Red Hat

    .. include:: cli/python-redhat.rst

  .. group-tab:: macOS

    .. include:: cli/python-macos.rst

  .. group-tab:: Windows

    .. include:: cli/python-windows.rst

.. _cli-build-tools:

*****************
Setup Build Tools
*****************

.. tabs::

  .. group-tab:: Debian / Ubuntu

    .. include:: cli/build-debian.rst

  .. group-tab:: Fedora / Red Hat

    .. include:: cli/build-redhat.rst

  .. group-tab:: macOS

    .. include:: cli/build-macos.rst

  .. group-tab:: Windows

    .. include:: cli/build-windows.rst

.. _cli-installation:

************
Installation
************

Now that Python and the required build tools are installed and working,
we can install the CLI tools used to interact with Catalyst Cloud.

.. _cli-installation-catalystcloud-client:

Catalyst Cloud API Client
=========================

We now provide a package called the
`Catalyst Cloud API Client <https://pypi.org/project/catalystcloud-client>`_
that makes it easy to install the packages for interacting with Catalyst Cloud
in a command line environment.

Just install the ``catalystcloud-client`` package and the ``openstack`` command
will become available, with all of the API client packages required for our
cloud services automatically installed using the correct versions.

.. note::

  The Catalyst Cloud API Client is not required to use our cloud
  from the command line.
  It is a convenience option we provide for our customers to make it
  easier and quicker to get started with Catalyst Cloud.

  The standard OpenStack Client packages can be installed and used
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

  .. group-tab:: OpenStack Client

    While we recommend using the Catalyst Cloud API Client to install
    the required CLI commands for interacting with Catalyst Cloud,
    it is not required.

    The individual OpenStack Client packages can be installed directly.
    This allows you to, for example, only install the packages required
    for the services you wish to use, which is useful for container image builds.

    For more information on the client packages required for specific services,
    please refer to :ref:`cli-available-commands`.

    .. tabs::

      .. group-tab:: pip

        To install the OpenStack Client using pip, we need to create and activate
        a **virtual environment** to install packages to.

        .. include:: cli/virtualenv.rst

        We can now install the OpenStack Client into the virtual environment.

        To install the packages, run the following command:

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

          When opening a new terminal, you will need to activate the virtual environment
          again to use the OpenStack Client.

.. _cli-configuration:

*************
Configuration
*************

The ``openstack`` command, and other applications that communicate
with Catalyst Cloud such as Terraform and Ansible, use environment
variables containing your user and project's details for authenticating
with Catalyst Cloud.

We provide **OpenRC files** which, upon authenticating with your password
(and MFA verification code if required), will automatically configure
these variables in your terminal session, which will allow you to use
these applications to interact with Catalyst Cloud.

.. tabs::

  .. group-tab:: Debian / Ubuntu

    .. include:: cli/openrc-unix.rst

  .. group-tab:: Fedora / Red Hat

    .. include:: cli/openrc-unix.rst

  .. group-tab:: macOS

    .. include:: cli/openrc-unix.rst

  .. group-tab:: Windows

    .. include:: cli/openrc-windows.rst

.. note::

  Note that configuration using OpenRC files only apply to the terminal session
  in which the OpenRC file is sourced.

  When opening a new terminal session, you will need to source your OpenRC file
  and provide your password and MFA verification code again.

.. _cli-usage:

*****
Usage
*****

At this point you should now have a working Catalyst Cloud CLI environment,
but we can confirm this by running a test command that returns
information from Catalyst Cloud.

.. tabs::

  .. group-tab:: Debian / Ubuntu

    .. include:: cli/test-unix.rst

  .. group-tab:: Fedora / Red Hat

    .. include:: cli/test-unix.rst

  .. group-tab:: macOS

    .. include:: cli/test-unix.rst

  .. group-tab:: Windows

    .. include:: cli/test-windows.rst

You can now use the available CLI commands to perform tasks
on Catalyst Cloud, such as
:ref:`launching a compute instance <compute-launching-an-instance>`.

.. _cli-available-commands:

******************
Available Commands
******************

The following table contains a complete list of commands available
using the ``openstack`` CLI command to interact with Catalyst Cloud.

For more information on using these commands to interact with Catalyst Cloud,
refer to our documentation for each service.

.. list-table::
   :header-rows: 1

   * - Service
     - Resource Type
     - Command
     - API Client Library
   * - Identity
     - Projects
     - ``openstack project``
     - ``python-keystoneclient``
   * - Identity
     - Users
     - ``openstack user``
     - ``python-keystoneclient``
   * - Identity
     - EC2 Credentials
     - ``openstack ec2 credentials``
     - ``python-keystoneclient``
   * - Identity
     - Application Credentials
     - ``openstack application credential``
     - ``python-keystoneclient``
   * - Compute
     - Instances / Servers
     - ``openstack server``
     - ``python-novaclient``
   * - Compute
     - Keypairs
     - ``openstack keypair``
     - ``python-novaclient``
   * - Networking
     - Networks
     - ``openstack network``
     - ``python-neutronclient``
   * - Networking
     - Routers
     - ``openstack router``
     - ``python-neutronclient``
   * - Networking
     - Floating IPs
     - ``openstack floating ip``
     - ``python-neutronclient``
   * - Networking
     - Security Groups
     - ``openstack security group``
     - ``python-neutronclient``
   * - Networking
     - VPNs
     - ``openstack vpn``
     - ``python-neutronclient``
   * - Load Balancer
     - Load Balancers
     - ``openstack loadbalancer``
     - ``python-octaviaclient``
   * - Block Storage
     - Volumes
     - ``openstack volume``
     - ``python-cinderclient``
   * - Image
     - Images
     - ``openstack image``
     - ``python-glanceclient``
   * - Database
     - Databases
     - ``openstack database``
     - ``python-troveclient``
   * - Orchestration
     - Stacks
     - ``openstack stack``
     - ``python-heatclient``
   * - Kubernetes
     - Clusters
     - ``openstack coe cluster``
     - ``python-magnumclient``
   * - Kubernetes
     - Node Groups
     - ``openstack coe nodegroup``
     - ``python-magnumclient``
   * - Object Storage
     - Containers
     - ``openstack container``
     - ``python-swiftclient``
   * - Object Storage
     - Objects
     - ``openstack object``
     - ``python-swiftclient``
   * - Object Storage
     - Accounts
     - ``openstack object store account``
     - ``python-swiftclient``
   * - Secret Management
     - Secrets
     - ``openstack secret``
     - ``python-barbicanclient``
   * - Telemetry
     - Metrics
     - ``openstack metric``
     - ``gnocchiclient``
   * - Telemetry
     - Alarms
     - ``openstack alarm``
     - ``aodhclient``
   * - Billing
     - Invoices
     - ``openstack rating invoice``
     - ``python-distilclient``
   * - Billing
     - Quotations
     - ``openstack rating quotation``
     - ``python-distilclient``
   * - Billing
     - Products
     - ``openstack rating product``
     - ``python-distilclient``
   * - Administration
     - Project Users
     - ``openstack project user``
     - ``python-adjutantclient``
   * - Administration
     - Project Quotas
     - ``openstack project quota``
     - ``python-adjutantclient``
   * - Administration
     - Manageable Roles
     - ``openstack manageable roles``
     - ``python-adjutantclient``
   * - Administration
     - Passwords
     - ``openstack password``
     - ``python-adjutantclient``
