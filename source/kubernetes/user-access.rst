.. FIXME(travis): edit this section

.. _kubernetes-user-access:

###########
User Access
###########

.. FIXME (travis): does this section belong in the create clusters section? It's not really about cluster access.
.. Creating Clusters as Service User
.. ============
..
.. When a user creates a Kubernetes cluster, OpenStack creates an object called a
.. *trust*. Within the cluster, a trust is used to perform operations on the
.. user's behalf such as creating load balancers, storage volumes or additional
.. nodes when resizing a cluster. A trust mirrors the roles of the user who
.. created the cluster. Consequently, when that user account is removed or
.. disabled it will no longer be able to authenticate with the OpenStack API and
.. may become unhealthy.
..
.. In order to avoid this scenario we recommend creating a separate *service user*
.. to manage Kubernetes clusters. Ideally the service user should have a
.. descriptive username like `serviceuser+prod@myexample.com`. In order to
.. create clusters this user only needs the ``_member_`` role. It is not necessary
.. or recommended to give it any other roles.
..
.. .. image:: _containers_assets/k8s_service_user_create.png

Managing how individuals and applications can interact with your Kubernetes
cluster is critical to keeping your application secure.
Catalyst Cloud Kubernetes Service integrates with the :ref:`identity-access-management`
service to make it easy to manage access using role-based access control (RBAC).

In this section we will discuss how to grant Kubernetes RBAC roles to your
Catalyst Cloud account, and use them to interact with your cluster.

.. _k8s-rbac-roles:

*************************
Role-Based Access Control
*************************

Role-Based Access Control (RBAC) is one of the key pillars of Kubernetes
security. RBAC determines who or what can interact with your clusters. It
provides an easy way to assign or revoke permissions to groups of users.
Permissions can be easily audited which is extremely valuable for ensuring
compliance with strict regulatory and security requirements.

.. note::

  Kubernetes RBAC roles only grant you permissions within Kubernetes.
  These roles are separate from the standard user roles.

  To create a Kubernetes cluster in your project, your user must be granted
  the  :ref:`Project Member <project_member_role>` role.

  To interact with Kubernetes after your cluster is created,
  even :ref:`Project Admins <project_admin_role>` need to grant themselves the appropriate
  Kubernetes RBAC roles.

Catalyst Cloud provides the following roles which can be used
to control access to Kubernetes clusters.

.. list-table:: Catalyst Cloud Kubernetes Role Permissions
   :name: role-permissions
   :widths: 15 10 50
   :header-rows: 1

   * - Role
     - CLI Name
     - Permissions
   * - Kubernetes Admin
     - ``k8s_admin``
     - Privileged users with maximum rights. Full admin access is
       granted for Catalyst Cloud Kubernetes Service cluster CRUD
       operations and all Kubernetes namespaces in a cluster.
   * - Kubernetes Developer
     - ``k8s_developer``
     - Privileged users with restricted rights.
       Kubernetes CRUD operation access is granted to any namespace
       other than the managed (``kube-system``, ``openstack-system``,
       ``tigera-operator``, ``calico-apiserver`` and ``calico-system``)
       namespaces.
   * - Kubernetes Viewer
     - ``k8s_viewer``
     - Non-privileged users able to perform read actions in a
       Catalyst Cloud Kubernetes Service cluster.
       Has read-only access to all namespaces, excluding the managed
       namespaces.

Inviting users with assigned roles
==================================

When inviting a new user to your Catalyst Cloud project,
you can assign them the required roles for interacting with Kubernetes,
so that when they create their account they will automatically have
the required access.

A good practice is to limit the roles you grant users
to the minimum that are needed for the tasks they will perform.

.. note::

  Only :ref:`Project Admins <project_admin_role>` or
  :ref:`Project Moderators <project_mod_role>` can invite users to a Catalyst Cloud project.

.. tabs::

  .. tab:: Kubernetes Admin

    .. tabs::

      .. group-tab:: CLI

        Run the following command to invite a new user to your project,
        replacing ``jondoe+k8s_admin@example.com`` with the email address
        you wish to send the invite to.

        .. note::

          If you would like this user to be able to create and delete Kubernetes
          clusters, as well as manage other Catalyst Cloud resources,
          add the ``_member_`` (:ref:`Project Member <project_member_role>`) role
          as an additional parameter to the command.

        .. code-block:: bash

          openstack project user invite jondoe+k8s_admin@example.com k8s_admin

        An invite email will be sent to the provided email address.
        Once the user accepts, their Catalyst Cloud account will be
        automatically granted the requested roles in your project.

      .. group-tab:: Dashboard

        Navigate to the **Management -> Access Control -> Project Users** page,
        and press the **+ Invite User** button in the top right of the page.

        The **Invite User** window will open. Type in the email address of the user
        to invite, and grant the new user the **k8s_admin** role by ticking it in the
        role list.

        .. note::

          If you would like this user to be able to create and delete Kubernetes
          clusters, as well as manage other Catalyst Cloud resources,
          also assign them the :ref:`Project Member <project_member_role>` role.

        .. image:: _containers_assets/k8s_admin_user_create.png

        Once you are done, press **Invite** to send the invite.
        Once the user accepts, their Catalyst Cloud account will be
        automatically granted the requested roles in your project.

  .. tab:: Kubernetes Developer

    .. tabs::

      .. group-tab:: CLI

        Run the following command to invite a new user to your project,
        replacing ``jondoe+k8s_dev@example.com`` with the email address
        you wish to send the invite to.

        .. code-block:: bash

          openstack project user invite jondoe+k8s_dev@example.com k8s_developer

        An invite email will be sent to the provided email address.
        Once the user accepts, their Catalyst Cloud account will be
        automatically granted the requested roles in your project.

      .. group-tab:: Dashboard

        Navigate to the **Management -> Access Control -> Project Users** page,
        and press the **+ Invite User** button in the top right of the page.

        The **Invite User** window will open. Type in the email address of the user
        to invite, and grant the new user the **k8s_developer** role by ticking it
        in the role list.

        .. image:: _containers_assets/k8s_dev_user_create.png

        Once you are done, press **Invite** to send the invite.
        Once the user accepts, their Catalyst Cloud account will be
        automatically granted the requested roles in your project.

  .. tab:: Kubernetes Viewer

    .. tabs::

      .. group-tab:: CLI

        Run the following command to invite a new user to your project,
        replacing ``jondoe+k8s_viewer@example.com`` with the email address
        you wish to send the invite to.

        .. code-block:: bash

          openstack project user invite jondoe+k8s_dev@example.com k8s_viewer

        An invite email will be sent to the provided email address.
        Once the user accepts, their Catalyst Cloud account will be
        automatically granted the requested roles in your project.

      .. group-tab:: Dashboard

        Navigate to the **Management -> Access Control -> Project Users** page,
        and press the **+ Invite User** button in the top right of the page.

        The **Invite User** window will open. Type in the email address of the user
        to invite, and grant the new user the **k8s_viewer** role by ticking it
        in the role list.

        .. image:: _containers_assets/k8s_viewer_user_create.png

        Once you are done, press **Invite** to send the invite.
        Once the user accepts, their Catalyst Cloud account will be
        automatically granted the requested roles in your project.

Granting roles to existing users
================================

:ref:`Project Admins <project_admin_role>` and :ref:`Project Moderators <project_mod_role>`
can grant Kubernetes RBAC roles to existing users.

.. tabs::

  .. tab:: Kubernetes Admin

    .. tabs::

      .. group-tab:: CLI

        Run the following command to grant the **Kubernetes Admin** role
        to a Catalyst Cloud user (replacing ``jondoe+k8s_admin@example.com``
        with the email address of the user).

        .. code-block:: bash

          openstack project user role add jondoe+k8s_admin@example.com k8s_admin

      .. group-tab:: Dashboard

        Navigate to the **Management -> Access Control -> Project Users** page.

        Find the user you wish to grant the role to in the list, and press the
        **Update User** button to open the **Update User** window.

        .. image:: _containers_assets/k8s_admin_user_update.png

        Grant the **Kubernetes Admin** role by ticking **k8s_admin**
        in the role list, and press **Update** to save your changes.

  .. tab:: Kubernetes Developer

    .. tabs::

      .. group-tab:: CLI

        Run the following command to grant the **Kubernetes Developer** role
        to a Catalyst Cloud user (replacing ``jondoe+k8s_dev@example.com``
        with the email address of the user).

        .. code-block:: bash

          openstack project user role add jondoe+k8s_dev@example.com k8s_developer

      .. group-tab:: Dashboard

        Navigate to the **Management -> Access Control -> Project Users** page.

        Find the user you wish to grant the role to in the list, and press the
        **Update User** button to open the **Update User** window.

        .. image:: _containers_assets/k8s_dev_user_update.png

        Grant the **Kubernetes Developer** role by ticking **k8s_developer**
        in the role list, and press **Update** to save your changes.

  .. tab:: Kubernetes Viewer

    .. tabs::

      .. group-tab:: CLI

        Run the following command to grant the **Kubernetes Viewer** role
        to a Catalyst Cloud user (replacing ``jondoe+k8s_viewer@example.com``
        with the email address of the user).

        .. code-block:: bash

          openstack project user role add jondoe+k8s_viewer@example.com k8s_viewer

      .. group-tab:: Dashboard

        Navigate to the **Management -> Access Control -> Project Users** page.

        Find the user you wish to grant the role to in the list, and press the
        **Update User** button to open the **Update User** window.

        .. image:: _containers_assets/k8s_viewer_user_update.png

        Grant the **Kubernetes Viewer** role by ticking **k8s_viewer**
        in the role list, and press **Update** to save your changes.

******************************
Accessing a Kubernetes cluster
******************************

.. _kubeconfig-file-location:

The kubeconfig file
===================

A `kubeconfig file`_ is required for :ref:`kubectl <setting_up_kubectl>` to
interact with a Kubernetes cluster.

On Catalyst Cloud there are two types of kubeconfig file,
both of which can be downloaded via the API:

.. NOTE(travis): eventually can be downloaded from Horizon as well.

* **RBAC kubeconfig**: Provides access to the Kubernetes cluster based on
  :ref:`user roles assigned in Catalyst Cloud <k8s-rbac-roles>`.

  * This is recommended for most interaction with a managed Kubernetes cluster.

* **Admin kubeconfig**: Allows unrestricted access to a Kubernetes cluster
  using an **admin token** provided with the kubeconfig file.

  * **Not recommended for general access.**
    For most use cases, RBAC kubeconfig files should be used to interact with the cluster.
    Refer to
    :ref:`Retrieving the admin kubeconfig <retrieving-admin-kubeconfig>`
    for more information.

.. note::

  Retrieving the kubeconfig file from Catalyst Cloud requires **Kubernetes Admin**
  permissions.

  **Kubernetes Developers** and **Kubernetes Viewers** cannot retrieve their own kubeconfig,
  but an **RBAC kubeconfig** retrieved by a **Kubernetes Admin** can be shared with these users
  to give them access to the cluster.

.. _`kubeconfig file`: https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig

.. _retrieving-rbac-kubeconfig:

Retrieving the RBAC kubeconfig
##############################

Currently, the only way to retreve the kubeconfig file is
to use the :ref:`Catalyst Cloud CLI <sdks_and_toolkits>`.

.. tabs::

  .. group-tab:: Linux / macOS

    First, open a terminal window and :ref:`source your OpenRC file <source-rc-file>`
    to authenticate with Catalyst Cloud.

    To retrieve the RBAC kubeconfig file, run the ``openstack coe cluster config`` command
    with the ``--use-keystone`` option. The exact usage is as follows:

    .. code-block:: bash

      openstack coe cluster config <CLUSTER-NAME> --use-keystone

    This will save the kubeconfig file in the current directory under the name ``config``.

    To configure ``kubectl`` to use the kubeconfig, run the following command
    to set the ``KUBECONFIG`` environment variable to the current directory:

    .. code-block:: bash

      export KUBECONFIG=$(pwd)/config

  .. group-tab:: Windows (PowerShell)

    First, open a terminal window and :ref:`source your OpenRC file <windows-configuration>`
    to authenticate with Catalyst Cloud.

    To retrieve the RBAC kubeconfig file, run the ``openstack coe cluster config`` command
    with the ``--use-keystone`` option. The exact usage is as follows:

    .. code-block:: powershell

      openstack coe cluster config <CLUSTER-NAME> --use-keystone

    This will save the kubeconfig file in the current directory under the name ``config``.

    To configure ``kubectl`` to use the kubeconfig, run the following command
    to set the ``KUBECONFIG`` environment variable to the current directory:

    .. code-block:: powershell

      $Env:KUBECONFIG = $pwd\config

  .. group-tab:: Windows (Command Prompt)

    First, open a terminal window and :ref:`source your OpenRC file <windows-configuration>`
    to authenticate with Catalyst Cloud.

    To retrieve the RBAC kubeconfig file, run the ``openstack coe cluster config`` command
    with the ``--use-keystone`` option. The exact usage is as follows:

    .. code-block:: bat

      openstack coe cluster config <CLUSTER-NAME> --use-keystone

    This will save the kubeconfig file in the current directory under the name ``config``.

    To configure ``kubectl`` to use the kubeconfig, run the following command
    to set the ``KUBECONFIG`` environment variable to the current directory:

    .. code-block:: bat

      set KUBECONFIG=%cd%\config

This ``config`` file can now be shared with other team members that need
access to this cluster. This file provides the following levels of access:

* Users with the **Kubernetes Admin**, **Kubernetes Developer** or **Kubernetes Viewer** role
  will have access specified by that role (see :ref:`k8s-rbac-roles`).
* Users without RBAC roles will not be able to access the cluster.

.. _retrieving-admin-kubeconfig:

Retrieving the admin kubeconfig (not recommended)
#################################################

.. warning::

  The **admin kubeconfig** should not be used directly in most use cases.

  Unlike the :ref:`RBAC kubeconfig <retrieving-rbac-kubeconfig>`, which requires
  authenticating with Catalyst Cloud before providing cluster access,
  the admin kubeconfig allows for **unrestricted access without authentication**.
  Using this kubeconfig file makes it impossible to audit
  **who or what is making changes to a cluster**.

  A **Kubernetes Admin** can perform any task that the admin kubeconfig allows,
  so this file is not necessary for everyday usage.
  **Only use the admin kubeconfig file when required.**

Currently, the only way to retreve the kubeconfig file is
to use the :ref:`Catalyst Cloud CLI <sdks_and_toolkits>`.

.. tabs::

  .. group-tab:: Linux / macOS

    First, open a terminal window and :ref:`source your OpenRC file <source-rc-file>`
    to authenticate with Catalyst Cloud.

    To retrieve the RBAC kubeconfig file, run the ``openstack coe cluster config`` command,
    **without** the ``--use-keystone`` option. The exact usage is as follows:

    .. code-block:: bash

      openstack coe cluster config <CLUSTER-NAME>

    This will save the kubeconfig file in the current directory under the name ``config``.

    To configure ``kubectl`` to use the kubeconfig, run the following command
    to set the ``KUBECONFIG`` environment variable to the current directory:

    .. code-block:: bash

      export KUBECONFIG=$(pwd)/config

  .. group-tab:: Windows (PowerShell)

    First, open a terminal window and :ref:`source your OpenRC file <windows-configuration>`
    to authenticate with Catalyst Cloud.

    To retrieve the RBAC kubeconfig file, run the ``openstack coe cluster config`` command,
    **without** the ``--use-keystone`` option. The exact usage is as follows:

    .. code-block:: powershell

      openstack coe cluster config <CLUSTER-NAME>

    This will save the kubeconfig file in the current directory under the name ``config``.

    To configure ``kubectl`` to use the kubeconfig, run the following command
    to set the ``KUBECONFIG`` environment variable to the current directory:

    .. code-block:: powershell

      $Env:KUBECONFIG = $pwd\config

  .. group-tab:: Windows (Command Prompt)

    First, open a terminal window and :ref:`source your OpenRC file <windows-configuration>`
    to authenticate with Catalyst Cloud.

    To retrieve the RBAC kubeconfig file, run the ``openstack coe cluster config`` command,
    **without** the ``--use-keystone`` option. The exact usage is as follows:

    .. code-block:: bat

      openstack coe cluster config <CLUSTER-NAME>

    This will save the kubeconfig file in the current directory under the name ``config``.

    To configure ``kubectl`` to use the kubeconfig, run the following command
    to set the ``KUBECONFIG`` environment variable to the current directory:

    .. code-block:: bat

      set KUBECONFIG=%cd%\config

.. note::

  The admin kubeconfig file contains an **admin token** that provides unrestricted access
  to your cluster.

  Make sure it is stored on your system with the appropriate permissions,
  e.g. removing read/write access to anyone except your system user.

Additional command line options
###############################

The ``openstack coe cluster config`` command can optionally take a few
additional arguments:

* ``--dir <path>`` - Specify an alternative directory to save the kubeconfig file to.

  * By default, the kubeconfig file will be saved to the current directory.

* ``--force`` - Recreate the ``config`` file in the specified directory if it already exists.

  * By default, the command will fail if the ``config`` already exists in the specified directory.

.. _setting_up_kubectl:

Setting up kubectl
##################

Once the kubeconfig file has been downloaded, ``kubectl`` can be configured to use the
``config`` file using one of the following methods:

#. Passing it using the ``--kubeconfig`` command line argument.
#. Setting the ``KUBECONFIG`` environment variable to the full path of the kubeconfig file.
#. Saving the kubeconfig file to ``$HOME/.kube/config``.

``kubectl`` looks for the kubeconfig file in the above order,
with ``$HOME/.kube/config`` being checked last.

**************************
Interacting with a cluster
**************************

With the :ref:`kubeconfig file in place <kubeconfig-file-location>`, it is now
possible to interact with a Kubernetes cluster. Depending on the level of
access granted, the user will be able to query and/or create resources on the cluster.

You can verify what your user can and cannot do using the ``kubectl auth can-i`` command.

.. _k8s-admin-role:

Kubernetes Admin
================

A user with the **Kubernetes Admin** (``k8s_admin``) role has the ability to perform any actions on the cluster.

Check if your user can create pods in the ``default`` namespace:

.. code-block:: console

  $ kubectl auth can-i create pods -n default
  yes

Check if your user can create pods in **all** namespaces:

.. code-block:: console

  $ kubectl auth can-i create pods -A
  yes

Check if your user can delete secrets in **all** namespaces:

.. code-block:: console

  $ kubectl auth can-i delete secrets -A
  yes

.. _k8s-developer-role:

Kubernetes Developer
====================

The **Kubernetes Developer** (``k8s_developer``) role allows a user to perform
most everyday operations within all non-privileged namespaces.

.. code-block:: console

  $ kubectl auth can-i create pods -n default
  yes

However, a Kubernetes Developer is not allowed to perform any actions
in the admin (``kube-system``) namespace.

.. code-block:: console

  $ kubectl auth can-i create pods -n kube-system
  no

Kubernetes Developers are also not allowed to perform certain cluster-level operations.

.. code-block:: console

  $ kubectl auth can-i patch clusterrolebinding
  no
  $ kubectl auth can-i create clusterrolebinding
  no

Production Considerations
=========================

The privileged roles deserve special attention when deploying Kubernetes clusters.

The `RBAC permissions`_ that grant
the ability to launch a pod in the cluster is a powerful privilege.
Use of a more restrictive `Admission Controller`_ may be appropriate
to meet specific customer security needs.

Any user with the :ref:`k8s-admin-role` or :ref:`k8s-developer-role` role
must be a trusted individual.

.. _`RBAC permissions`: https://kubernetes.io/docs/reference/access-authn-authz/rbac
.. _`Admission Controller`: https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers

****************************
Other ways to control access
****************************

There are a number of other tools available for managing RBAC to Kubernetes clusters.

Integrated policy solutions:

* `Pod Security Admission <https://kubernetes.io/docs/concepts/security/pod-security-admission>`_

Third-party policy solutions:

* `Open Policy Agent <https://www.openpolicyagent.org/docs>`_
* `Gatekeeper <https://open-policy-agent.github.io/gatekeeper/website>`_
* `Kyverno <https://kyverno.io>`_

********
Appendix
********

.. _openstack-k8s-role-permissions:

Kubernetes Role Permissions
===========================

This is a comprehensive list of the exact `RBAC permissions`_ that each role gives a user:

.. code-block:: text

  +----------------------+-----------------------------------------------------+
  | Role                 | Permissions                                         |
  +======================+=====================================================+
  | k8s_admin            | resourcemanager.projects.*                          |
  +----------------------+-----------------------------------------------------+
  | k8s_developer        | container.apiServices.*                             |
  |                      | container.bindings.*                                |
  |                      | container.certificateSigningRequests.create         |
  |                      | container.certificateSigningRequests.delete         |
  |                      | container.certificateSigningRequests.get            |
  |                      | container.certificateSigningRequests.list           |
  |                      | container.certificateSigningRequests.update         |
  |                      | container.certificateSigningRequests.watch          |
  |                      | container.clusterRoleBindings.get                   |
  |                      | container.clusterRoleBindings.list                  |
  |                      | container.clusterRoleBindings.watch                 |
  |                      | container.clusterRoles.get                          |
  |                      | container.clusterRoles.list                         |
  |                      | container.clusterRoles.watch                        |
  |                      | container.componentStatuses.*                       |
  |                      | container.configMaps.*                              |
  |                      | container.controllerRevisions.get                   |
  |                      | container.controllerRevisions.list                  |
  |                      | container.controllerRevisions.watch                 |
  |                      | container.cronJobs.*                                |
  |                      | container.customResourceDefinitions.*               |
  |                      | container.deployments.*                             |
  |                      | container.endpoints.*                               |
  |                      | container.events.*                                  |
  |                      | container.horizontalPodAutoscalers.*                |
  |                      | container.ingresses.*                               |
  |                      | container.initializerConfigurations.*               |
  |                      | container.jobs.*                                    |
  |                      | container.limitRanges.*                             |
  |                      | container.localSubjectAccessReviews.*               |
  |                      | container.namespaces.*                              |
  |                      | container.networkPolicies.*                         |
  |                      | container.nodes.get                                 |
  |                      | container.nodes.list                                |
  |                      | container.nodes.watch                               |
  |                      | container.persistentVolumeClaims.*                  |
  |                      | container.persistentVolumes.*                       |
  |                      | container.podDisruptionBudgets.*                    |
  |                      | container.podPresets.*                              |
  |                      | container.podSecurityPolicies.get                   |
  |                      | container.podSecurityPolicies.list                  |
  |                      | container.podSecurityPolicies.watch                 |
  |                      | container.podTemplates.*                            |
  |                      | container.pods.*                                    |
  |                      | container.replicaSets.*                             |
  |                      | container.replicationControllers.*                  |
  |                      | container.resourceQuotas.*                          |
  |                      | container.roleBindings.get                          |
  |                      | container.roleBindings.list                         |
  |                      | container.roleBindings.watch                        |
  |                      | container.roles.get                                 |
  |                      | container.roles.list                                |
  |                      | container.roles.watch                               |
  |                      | container.secrets.*                                 |
  |                      | container.selfSubjectAccessReviews.*                |
  |                      | container.serviceAccounts.*                         |
  |                      | container.services.*                                |
  |                      | container.statefulSets.*                            |
  |                      | container.storageClasses.*                          |
  |                      | container.subjectAccessReviews.*                    |
  |                      | container.tokenReviews.*                            |
  +----------------------+-----------------------------------------------------+
  | k8s_viewer           | container.apiServices.get                           |
  |                      | container.apiServices.list                          |
  |                      | container.apiServices.watch                         |
  |                      | container.binding.get                               |
  |                      | container.binding.list                              |
  |                      | container.binding.watch                             |
  |                      | container.clusterRoleBindings.get                   |
  |                      | container.clusterRoleBindings.list                  |
  |                      | container.clusterRoleBindings.watch                 |
  |                      | container.clusterRoles.get                          |
  |                      | container.clusterRoles.list                         |
  |                      | container.clusterRoles.watch                        |
  |                      | container.componentStatuses.get                     |
  |                      | container.componentStatuses.list                    |
  |                      | container.componentStatuses.watch                   |
  |                      | container.configMaps.get                            |
  |                      | container.configMaps.list                           |
  |                      | container.configMaps.watch                          |
  |                      | container.controllerRevisions.get                   |
  |                      | container.controllerRevisions.list                  |
  |                      | container.controllerRevisions.watch                 |
  |                      | container.cronJobs.get                              |
  |                      | container.cronJobs.list                             |
  |                      | container.cronJobs.watch                            |
  |                      | container.customResourceDefinitions.get             |
  |                      | container.customResourceDefinitions.list            |
  |                      | container.customResourceDefinitions.watch           |
  |                      | container.deployments.get                           |
  |                      | container.deployments.list                          |
  |                      | container.deployments.watch                         |
  |                      | container.endpoints.get                             |
  |                      | container.endpoints.list                            |
  |                      | container.endpoints.watch                           |
  |                      | container.events.get                                |
  |                      | container.events.list                               |
  |                      | container.events.watch                              |
  |                      | container.horizontalPodAutoscalers.get              |
  |                      | container.horizontalPodAutoscalers.list             |
  |                      | container.horizontalPodAutoscalers.watch            |
  |                      | container.ingresses.get                             |
  |                      | container.ingresses.list                            |
  |                      | container.ingresses.watch                           |
  |                      | container.initializerConfigurations.get             |
  |                      | container.initializerConfigurations.list            |
  |                      | container.initializerConfigurations.watch           |
  |                      | container.jobs.get                                  |
  |                      | container.jobs.list                                 |
  |                      | container.jobs.watch                                |
  |                      | container.limitRanges.get                           |
  |                      | container.limitRanges.list                          |
  |                      | container.limitRanges.watch                         |
  |                      | container.localSubjectAccessReviews.get             |
  |                      | container.localSubjectAccessReviews.list            |
  |                      | container.localSubjectAccessReviews.watch           |
  |                      | container.namespaces.get                            |
  |                      | container.namespaces.list                           |
  |                      | container.namespaces.watch                          |
  |                      | container.networkPolicies.get                       |
  |                      | container.networkPolicies.list                      |
  |                      | container.networkPolicies.watch                     |
  |                      | container.nodes.get                                 |
  |                      | container.nodes.list                                |
  |                      | container.nodes.watch                               |
  |                      | container.persistentVolumeClaims.get                |
  |                      | container.persistentVolumeClaims.list               |
  |                      | container.persistentVolumeClaims.watch              |
  |                      | container.persistentVolumes.get                     |
  |                      | container.persistentVolumes.list                    |
  |                      | container.persistentVolumes.watch                   |
  |                      | container.podDisruptionBudgets.get                  |
  |                      | container.podDisruptionBudgets.list                 |
  |                      | container.podDisruptionBudgets.watch                |
  |                      | container.podPresets.get                            |
  |                      | container.podPresets.list                           |
  |                      | container.podPresets.watch                          |
  |                      | container.podTemplates.get                          |
  |                      | container.podTemplates.list                         |
  |                      | container.podTemplates.watch                        |
  |                      | container.podSecurityPolicies.get                   |
  |                      | container.podSecurityPolicies.list                  |
  |                      | container.podSecurityPolicies.watch                 |
  |                      | container.pods.get                                  |
  |                      | container.pods.list                                 |
  |                      | container.pods.watch                                |
  |                      | container.replicaSets.get                           |
  |                      | container.replicaSets.list                          |
  |                      | container.replicaSets.watch                         |
  |                      | container.replicationControllers.get                |
  |                      | container.replicationControllers.list               |
  |                      | container.replicationControllers.watch              |
  |                      | container.resourceQuotas.get                        |
  |                      | container.resourceQuotas.list                       |
  |                      | container.resourceQuotas.watch                      |
  |                      | container.roleBindings.get                          |
  |                      | container.roleBindings.list                         |
  |                      | container.roleBindings.watch                        |
  |                      | container.roles.get                                 |
  |                      | container.roles.list                                |
  |                      | container.roles.watch                               |
  |                      | container.secrets.get                               |
  |                      | container.secrets.list                              |
  |                      | container.secrets.watch                             |
  |                      | container.selfSubjectAccessReviews.get              |
  |                      | container.selfSubjectAccessReviews.list             |
  |                      | container.selfSubjectAccessReviews.watch            |
  |                      | container.serviceAccounts.get                       |
  |                      | container.serviceAccounts.list                      |
  |                      | container.serviceAccounts.watch                     |
  |                      | container.services.get                              |
  |                      | container.services.list                             |
  |                      | container.services.watch                            |
  |                      | container.statefulSets.get                          |
  |                      | container.statefulSets.list                         |
  |                      | container.statefulSets.watch                        |
  |                      | container.storageClasses.get                        |
  |                      | container.storageClasses.list                       |
  |                      | container.storageClasses.watch                      |
  |                      | container.subjectAccessReviews.get                  |
  |                      | container.subjectAccessReviews.list                 |
  |                      | container.subjectAccessReviews.watch                |
  +----------------------+-----------------------------------------------------+

.. _`RBAC permissions`: https://kubernetes.io/docs/reference/access-authn-authz/rbac
