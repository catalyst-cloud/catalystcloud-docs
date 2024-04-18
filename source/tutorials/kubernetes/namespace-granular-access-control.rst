

********************************************
Using namespaces for granular access control
********************************************


.. _kube-namespaces:

It is possible, through the use of **roles** and **namespaces**,  to
achieve a much more granular level of access control.

Kubernetes **namespaces** are a way to create virtual clusters inside a single
physical cluster. This allows for different projects, teams, or customers
to share a Kubernetes cluster.

In order to use namespacing, you will need to provide the following:

* A scope for names.
* A mechanism to attach authorization and policy to a subsection of the
  cluster.

For a more in depth look at namespaces it is recommended that you read through
the `official kubernetes documentation`_.

.. _`official kubernetes documentation`: https://kubernetes.io/docs/tasks/administer-cluster/namespaces-walkthrough/

An example namespace
====================

In this example we will provide access to some cluster resources for a cloud
user that has none of the Kubernetes specific access roles (discussed above )
applied to their account. We will refer to this as our **restricted user**.
Before we begin, the following is a list of the different resources and actions
that we are going to be taking or creating in this example:

You will need to have these resources created before we start:

* A cluster, in our example we have named ours: dev-cluster
* A restricted user, in our example we have named them: clouduser

We are going to be creating the following resource in the tutorial below:

* *namespace* : testapp

The level of access we are going to be supplying for users in this namespace
is:

* *The cluster resource to access* : pod
* *Resource access level* : get, list, watch


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
the required access to our restricted user. The **role** defines **what**
access is being provided, where the **rolebinding** defines **who** is to be
given that access.

Some of the key things to note in the manifest below are:

* In the **Role** config

  - ``apiGroups: [""]``, the use of "" indicates that it applies to the core
    API group

* In the **RoleBinding** config

  - The name in ``subjects:`` is case sensitive.
  - It is possible to add more than one subject to a role binding.
  - The name in ``roleRef:`` must match the name of the role you wish to bind to.

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
using an :ref:`openRC file<configuring-the-cli>`. Once the cloud authentication
has been taken care of we need to set up the cluster config file to
authenticate with the cluster.

We do this by exporting the ``KUBECONFIG`` environment variable with the path
to the files location, like so.

.. code-block:: console

  $ export KUBECONFIG=/home/clouduser/config

Confirming cluster access
-------------------------

We are now in a position to test that we have access to view pods in the
namespace *testapp*. As we have not deployed any workloads as part of this
example we will make use of the **kubectl**  inbuilt command to inspect
authorisation. The command is constructed as follows:

**$ kubectl auth can-i <action_to_check>**

So in our case we want to check that we can get **pod** information from the
testapp namespace, which would look like this.

.. code-block:: console

  $ kubectl auth can-i get pod --namespace testapp
  yes

Now lets confirm that we cannot view **services** in this namespace.

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

.. include:: role-mapping.rst



