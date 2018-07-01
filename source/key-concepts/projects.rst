.. _projects:

########
Projects
########

Everything you do and host on the Catalyst Cloud is in a ``project``.

The Catalyst Cloud provides an isolated and multi-tenanted approach to creating
workspaces. These workspaces are typically referred to as a ``project`` but for
historical reasons you may also see them referred to as a ``tenant`` or
a ``tenancy``.

.. _find-project-id:

********************
Finding a project ID
********************

Every project on the Catalyst Cloud has a ``project name`` (a user friendly
name) and a ``project id`` (an auto-generated UUID). There are a number of ways
to find your project ID and name.

Using the Dashboard
===================

The project ID and name can be found on the `API Access`_ panel by clicking on
the `View Credentials`_ button.

.. _API Access: https://dashboard.cloud.catalyst.net.nz/project/api_access/
.. _View Credentials: https://dashboard.cloud.catalyst.net.nz/project/api_access/view_credentials/

Using the Command Line
======================

If you are using the OpenStack command line tools you have most likely sourced
an openrc file, as explained in :ref:`command-line-interface`. If this is the
case, you can find your project ID by issuing the following command:

.. code-block:: bash

 $ echo $OS_PROJECT_ID
 1234567892b04ed38247bab7d808e214

 $ echo $OS_Project_NAME
 My-Example-Company-Ltd

Alternatively, you can use the ``openstack configuration show`` command:

.. code-block:: bash

 $ openstack configuration show -c auth.project_id -f value
 1234567892b04ed38247bab7d808e214

 $ openstack configuration show -c auth.project_name -f value
 My-Example-Company-Ltd


*********************
Creating new projects
*********************

You can request the creation of more projects via the `Support
Requests`_ panel.

.. _Support Requests: https://dashboard.cloud.catalyst.net.nz/management/tickets/

****************
Changing project
****************

Via the dashboard
=================

On the dashboard, you can change which project you are working on using the
dropdown on the top left corner.

.. image:: ../_static/project_dropdown.png

Via the CLI
===========

The command line interface picks up the project configuration from the
``$OS_PROJECT_NAME`` and ``$OS_PROJECT_ID`` environment variables.

To define these variable:

.. code-block:: bash

  export OS_PROJECT_NAME="project-name"
  export OS_PROJECT_ID="UUID"

If a project ID is specified, the project name is not used. If only the project
name is specified, the CLI will perform a lookup for the name to find the ID.

Alternatively you can use the ``--os-project-name`` and ``--os-project-id``
options to specify the project on each call.


**************
Project access
**************

The person who signed up to the Catalyst Cloud gets by default the ``Project
Administrator`` role.

As a project administrator or moderator, you can invite and remove people from
your projects using the `Project Users Panel`_.

.. _Project Users Panel: https://dashboard.cloud.catalyst.net.nz/management/project_users/


**************
Project quotas
**************

Each project comes with an initial ``quota`` that sets a limit on the amount of
cloud resources that you can initially consume. This can be expanded if you need
more resources.

Please refer to the :ref:`quota section of the documentation<quotas>` for more
information on quotas.

*****************
Project isolation
*****************

While projects are inherently secure, it is considered better to use
multiple projects where it's feasible to do so. For example, it is sensible
and useful to separate production workloads from development and testing
environments, if only to help mitigate the possibility of human error
impacting your business.
