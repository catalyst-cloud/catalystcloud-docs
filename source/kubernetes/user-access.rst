.. _kubernetes-user-access:

###########
User Access
###########


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


********************************************
Using namespaces for granular access control
********************************************

It is possible, through the use of **roles** and **namespaces**,  to
achieve a much more granular level of access control.

Kubernetes **namespaces** are a way to provide virtual clusters inside the
same physical cluster. They assist different projects, teams, or customers in
sharing a Kubernetes cluster.

In order to do this namespace provide the following:

* A scope for names.
* A mechanism to attach authorization and policy to a subsection of the
  cluster.

For a more in depth look at namespaces take a look `here`_.

.. _`here`: https://kubernetes.io/docs/tasks/administer-cluster/namespaces-walkthrough/

A working example
=================

In this example we will provide access to some cluster resources for a cloud
user that has none of the Kubernetes specific access roles (discussed above )
applied to their account. We will refer to this as our **restricted user**.

* *cluster* name : dev-cluster
* *namespace* : testapp
* *restricted user's name* : clouduser
* *cluster resource to access* : pod
* *resource access level* : get, list, watch


Authenticating a non-admin cluster user
=======================================

The first thing we need to address is a means for non admin users to be able to
authenticate with the cluster.

Creating a non-admin cluster config
-----------------------------------

As the **cluster administrator** we need to create a **cluster config file**
that allows cloud project users to use the cloud's own authentication service
as a means to access the cluster.

We can do that with the following command:

**openstack coe cluster config <CLUSTER_NAME> --use-keystone**

For example:

.. code-block:: console

  $ openstack coe cluster config dev-cluster --use-keystone

This config file can now be made available to other cloud users that need
access to this cluster. By default it will provide the following levels of
access:

* For a restricted project user, that is a project user with no Kubernetes
  specific role assigned to their cloud account, the default is no cluster
  access.
* For a project user with a Kubernetes specific role assigned to their cloud
  account, they will be assigned the level of access dictated by that role
  (see above)

Setting up the access policy
============================

.. Note::

  Run the following commands as the **cluster administrator**.

First, we will create a new namespace for the application to run in.

.. code-block:: yaml

  cat <<EOF | kubectl apply -f -
  ---
  apiVersion: v1
  kind: Namespace
  metadata:
    name: testapp
  EOF

Confirm that is was created correctly.

.. code-block:: console

  $ kubectl get ns
  NAME      STATUS   AGE
  testapp   Active   3h45m

Next we need to create a new role and a role binding in the cluster to provide
the required access to the user. The **role** defines **what** access is being
provided, where the **rolebinding** defines **who** is to be given that access.

Some of the key things to note in the manifest below are:

* In the **Role** config

  - ``apiGroups: [""]``, the use of "" indicates that it applies to the core
    API group

* In the **RoleBinding** config

  - The name in subjects: is case sensitive.
  - It is possible to add more than one subject to a role binding.
  - The name in roleRef: must match the name of the role you wish to bind to.

.. code-block:: yaml

  cat <<EOF | kubectl apply -f -
  ---
  apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    namespace: testapp
    name: pod-viewer
  rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "watch", "list"]

  ---
  apiVersion: rbac.authorization.k8s.io/v1
  kind: RoleBinding
  metadata:
    name: view-pods
    namespace: testapp
  subjects:
  - kind: User
    name: clouduser
    apiGroup: rbac.authorization.k8s.io
  roleRef:
    kind: Role
    name: pod-viewer
    apiGroup: rbac.authorization.k8s.io
  EOF

Confirm that our Role and RoleBinding were created successfully in our new
namespace.

.. code-block:: console

  $ kubectl get role,rolebinding -n testapp
  NAME                                        AGE
  role.rbac.authorization.k8s.io/pod-viewer   21s

  NAME                                              AGE
  rolebinding.rbac.authorization.k8s.io/view-pods   21s

Testing our restricted users access
===================================

.. Note::

  Run the following commands as the **restricted user**.

Setting up our cloud authentication
-----------------------------------

To access the cluster we first need to authenticate against the cloud
using an openrc file. If this is done using the MFA enabled version of the
file it will set the ``OS_TOKEN`` environment variable by default.

If, however,  you are using the non-MFA enabled version you will need to set
this variable manually with the following.

.. code-block:: console

  $ export OS_TOKEN=$(openstack token issue -f yaml -c id | awk '{print $2}')

Once the cloud authentication has been taken care of we need to set the
cluster config file up to authenticate with the cluster.

We do this by exporting the ``KUBECONG`` environment variable with the path to
the files location, like so.

.. code-block:: console

  $ export KUBECONFIG=/home/clouduser/config

Confirming cluster access
-------------------------

We are now in a position to test that we have access to view pods in the
namespace *testapp*. As we have not deployed any workloads as part of this
example we will make use of the **kubectl**  inbuilt command to inspect
authorisation. To do this we use the following command:

**kubectl auth can-i <action_to_check>**

So in our case we want to check that we can get pod information from the
testapp namespace, which would look like this.

.. code-block:: console

  $ kubectl auth can-i get pod --namespace testapp
  yes

Now lets confirm that we cannot view services in this namespace.

.. code-block:: console

  $ kubectl auth can-i get service --namespace testapp
  no

The final check is to confirm that our right to view pods does not apply in
any other namespace. We will check the default to confirm that this is true.

.. code-block:: console

  $ kubectl auth can-i get pod --namespace default
  no

Cleaning up
===========

.. Note::

  Run the following commands as the **cluster administrator**.

To remove the elements we created in this example run the following commands:

.. code-block:: console

  $ kubectl delete rolebinding view-pods --namespace testapp
  rolebinding.rbac.authorization.k8s.io "view-pods" deleted

  $ kubectl delete role pod-viewer --namespace testapp
  role.rbac.authorization.k8s.io "pod-viewer" deleted

  $ kubectl delete namespace testapp
  namespace "testapp" deleted
