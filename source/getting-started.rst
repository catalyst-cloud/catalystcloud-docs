###############
Getting Started
###############


*******************
General information
*******************

Regions
=======

The Catalyst Cloud is hosted on multiple regions or geographical locations.
Regions are completely independent and isolated from each other, providing
fault tolerance and geographic diversity.

+----------+-----------------+
| Code     | Name            |
+==========+=================+
| nz-por-1 | NZ Porirua 1    |
+----------+-----------------+
| nz_wlg_2 | NZ Wellington 2 |
+----------+-----------------+

The Porirua region is Catalyst's newest addition to the Catalyst Cloud and has
six times the capacity of the Wellington region. We encourage customers to use
“nz-por-1” as their primary region in New Zealand.

The connectivity between compute instances hosted on different regions takes
place over the Internet when allowed by your security groups and network
configuration.

Resources are not replicated automatically across regions unless you do so.
This provides customers the flexibility to introduce replication where required
and to fail-over resources independently when needed.

Changing regions
----------------

Dashboard
^^^^^^^^^

The web dashboard has a region selector dropbox in the top bar. It indicates
the current region you are connected to and allows you to easily switch
between regions.

Command line clients
^^^^^^^^^^^^^^^^^^^^

The command line clients pick up the region from the $OS_REGION_NAME
environment variable. To define the variable:

.. code-block:: bash

  export OS_REGION_NAME="region-code"

Alternatively you can use the "--os-region-name" option to specify the region
on each call.

Endpoints
=========

Once authenticated, you can obtain the service catalogue and the list of API
endpoints on the current region from the identity service.

From the dashboard, you can find the endpoints under Access and Security, API
endpoints.

From the command line tools, you can run "keystone catalog" to list the
services and API endpoints of the current region.

Endpoints for “nz-por-1”
------------------------

+--------------+------------------------------------------------------------+
| Service      | Endpoint                                                   |
+==============+============================================================+
| compute      | https://api.nz-por-1.catalystcloud.io:8774/v2/%tenantid%   |
+--------------+------------------------------------------------------------+
| computev3    | https://api.nz-por-1.catalystcloud.io:8774/v3              |
+--------------+------------------------------------------------------------+
| ec2          | https://api.nz-por-1.catalystcloud.io:8773/services/Cloud  |
+--------------+------------------------------------------------------------+
| identity     | https://api.cloud.catalyst.net.nz:5000/v2.0                |
+--------------+------------------------------------------------------------+
| image        | https://api.nz-por-1.catalystcloud.io:9292                 |
+--------------+------------------------------------------------------------+
| metering     | http://api.nz-por-1.catalystcloud.io:8777                  |
+--------------+------------------------------------------------------------+
| network      | https://api.nz-por-1.catalystcloud.io:9696/                |
+--------------+------------------------------------------------------------+
| object-store | https://api.nz-por-1.catalystcloud.io:8443/swift/v1        |
+--------------+------------------------------------------------------------+
| rating       | https://api.nz-por-1.catalystcloud.io:8788/                |
+--------------+------------------------------------------------------------+
| s3           | https://api.cloud.catalyst.net.nz:8443/swift/v1            |
+--------------+------------------------------------------------------------+
| volume       |  https://api.nz-por-1.catalystcloud.io:8776/v1/%tenantid%  |
+--------------+------------------------------------------------------------+
| volumev2     | https://api.nz-por-1.catalystcloud.io:8776/v2/%tenantid%   |
+--------------+------------------------------------------------------------+

Endpoints for “nz_wlg_2”
------------------------

+--------------+-------------------------------------------------------+
| Service      | Endpoint                                              |
+==============+=======================================================+
| compute      | https://api.cloud.catalyst.net.nz:8774/v2/%tenantid%  |
+--------------+-------------------------------------------------------+
| computev3    | https://api.cloud.catalyst.net.nz:8774/v3             |
+--------------+-------------------------------------------------------+
| ec2          | https://api.cloud.catalyst.net.nz:8773/services/Cloud |
+--------------+-------------------------------------------------------+
| identity     | https://api.cloud.catalyst.net.nz:5000/v2.0           |
+--------------+-------------------------------------------------------+
| image        | https://api.cloud.catalyst.net.nz:9292                |
+--------------+-------------------------------------------------------+
| metering     | http://api.cloud.catalyst.net.nz:8777                 |
+--------------+-------------------------------------------------------+
| network      | https://api.cloud.catalyst.net.nz:9696/               |
+--------------+-------------------------------------------------------+
| object-store | https://api.cloud.catalyst.net.nz:8443/swift/v1       |
+--------------+-------------------------------------------------------+
| rating       | https://api.cloud.catalyst.net.nz:8788/               |
+--------------+-------------------------------------------------------+
| s3           | https://api.cloud.catalyst.net.nz:8443/swift/v1       |
+--------------+-------------------------------------------------------+
| volume       | https://api.cloud.catalyst.net.nz:8776/v1/%tenantid%  |
+--------------+-------------------------------------------------------+
| volumev2     | https://api.cloud.catalyst.net.nz:8776/v2/%tenantid%  |
+--------------+-------------------------------------------------------+

DNS servers
===========

Catalyst operate a number of recursive DNS servers in each cloud region for use
by Catalyst Cloud instances, free of charge. They are:

+----------+------------------------------------------------+
|  Region  | DNS Servers                                    |
+==========+================================================+
| nz-por-1 | 202.78.247.197, 202.78.247.198, 202.78.247.199 |
+----------+------------------------------------------------+
| nz_wlg_2 | 202.78.240.213, 202.78.240.214, 202.78.240.215 |
+----------+------------------------------------------------+

.. _command-line-tools:

*************************
Command line client tools
*************************

Each OpenStack project provides a command-line client, which enables you to
interact with the cloud APIs through easy-to-use commands.

.. seealso::

  The OpenStack upstream documentation on how to install and use the command
  line tools can be found at: http://docs.openstack.org/cli-reference/

Installing the OpenStack clients
================================

Ubuntu Linux
------------

.. code-block:: bash

  sudo apt-get update
  sudo apt-get install python-ceilometerclient python-cinderclient python-glanceclient python-keystoneclient python-neutronclient python-novaclient python-swiftclient


Redhat / CentOS / Fedora Linux
------------------------------

.. code-block:: bash

  sudo yum install -y https://rdo.fedorapeople.org/rdo-release.rpm
  sudo yum update -y
  sudo yum install -y python-ceilometerclient python-cinderclient python-glanceclient python-keystoneclient python-neutronclient python-novaclient python-swiftclient

Configuring the OpenStack client tools
======================================

Source an OpenStack RC file
---------------------------

When no configuration arguments are passed, the OpenStack client tools will try
to obtain their configuraton from environment variables. To help you define
these variables the cloud dashboard allows you to download an OpenStack RC file
from which you can easily source the required configuration.

To download an OpenStack RC file from the dashboard:

* Log to your project on the dashboard and select your preferred region.

* Go to "Access and Security", select the "API Access" tab and click on
  "Download OpenStack RC File". Save this file on the host where the client
  tools are going to be used from.

* Source the configuration from the OpenStack RC file:

  .. code-block:: bash

    source projectname-openrc.sh

* When prompted for a password, enter the password of the user who downloaded
  the file. Note that your password is not displayed on the screen as you type
  it in.

  .. warning::

    You should never type in your password on the command line (or pass it as
    an argument to the client tools), because the password will be stored in
    plain text on the shell history file. This is unsafe and could allow a
    potential attacker to compromise your credentials.

* You can confirm the configuration works by running a simple command, such as
  "nova list" and ensuring it return no errors.


****
SDKs
****

A rich set of software development kits (SDKs) are available for OpenStack,
providing language bindings and tools that makes it easy for you to use the
Catalyst Cloud.

The official OpenStack clients are the native Python bidings for the OpenStack
APIs and the recommended SDK for the Catalyst Cloud:
https://wiki.openstack.org/wiki/OpenStackClients

SDKs for all other major languages can be found at:
https://wiki.openstack.org/wiki/SDKs

OpenStack has a very rich eco-system and often multiple SDK options for a given
language. The http://developer.openstack.org/ provides a recommendation for the
most stable and feature rich SDK for your preferred language.


*************
API reference
*************

The OpenStack API reference can be found at:
http://developer.openstack.org/api-ref.html

.. note::

  The OpenStack API complete reference guide covers versions of the APIs that are current, experimental and deprecated. Please make sure you are referring to the correct version of the API.
