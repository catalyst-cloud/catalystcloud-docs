.. _kubernetes-access-control:

##############
Access control
##############

************
Introduction
************

Kubernetes clusters launched on the Catalyst Cloud are integrated with the
Identity and Access Management (IAM) service. Users with one of the roles
listed below are able to interact with any Kubernetes clusters owned by their
project using their existing cloud credentials.

The IAM roles related to the Kubernetes service are:

* ``k8s-admin`` administrator of the cluster platform and able to perform all
  operations within the cluster.
* ``k8s-developer`` can deploy applications to the cluster but cannot perform
  destructive operations within the ``kube-system`` namespace.
* ``k8s-viewer`` can only have view and obtain information of cluster
  resources.

For a detailed list of permissions associated with this role, please refer to
role permissions table in this document.

These roles can be added to an existing user through the :ref:`project_users`
page by anyone who has the Project Admin or Project Moderator roles
assigned to their account.

+---------------+------------------------------------------------------------------+
| Role          | Permissions                                                      |
+===============+==================================================================+
| k8s_admin     | Allows user to perform CRUD operations to Magnum cluster and     |
|               | have full admin access to Kubernetes. Has access to all          |
|               | namespaces, including the admin namespace.                       |
+---------------+------------------------------------------------------------------+
| k8s_developer | Allow users to perform CRUD operations to Kubernetes resources.  |
|               | The user has access to all namespaces, excluding the admin       |
|               | namespace.                                                       |
+---------------+------------------------------------------------------------------+
| k8s_viewer    | Only allows the user to perform READ operations in both Magnum   |
|               | and Kubernetes. Has access to all namespaces, excluding the      |
|               | admin namespace.                                                 |
+---------------+------------------------------------------------------------------+

*********************************
Generating Kubernetes config file
*********************************

As the owner of the cluster (user who created it), you can run the following
command to obtain the generic Kubernetes configuration file:

.. code-block:: bash

  $ openstack coe cluster config test-cluster --use-keystone

The output of this command will be a file named ``config`` in the current
working directory. This configuration file instructs ``kubectl`` to use the
Catalyst Cloud credentials for authentication. A copy of this file will need
to be made available to any user that requires access to the cluster.

.. note::

    If you run this command in the directory where your current ``config``
    file exists it will fail. You will need to run this from a different
    location.

*********************
Accessing the cluster
*********************

Once you have copied the config generated in the previous step, you need to
create an environment variable to let ``kubectl`` know where to find its
configuration file.

.. code-block:: bash

  $ export KUBECONFIG='/home/user/config'

Next, you have to :ref:`source-rc-file` and export a variable with an access
token as demonstrated below:

.. code-block:: bash

  export OS_TOKEN=$(openstack token issue -f yaml -c id | awk '{print $2}')

Now, for the duration of the authentication token issued in the previous step,
you should be able to use ``kubectl`` to interact with the cluster.

.. code-block:: bash

  kubectl cluster-info

If the token expires, you can re-generate another token by sourcing the **MFA
enabled OpenStack RC file** again.
