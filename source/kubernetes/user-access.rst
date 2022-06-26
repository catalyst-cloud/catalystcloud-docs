.. _kubernetes-user-access:

###########
User access
###########

************
Introduction
************

Kubernetes clusters launched on the Catalyst Cloud are integrated with the
OpenStack Keystone (Identity) service. Users with one of the roles
listed below are able to interact with any Kubernetes clusters owned by their
project using their existing cloud credentials.

The OpenStack Keystone Identity roles related to the Kubernetes service are:

* ``k8s_admin``: administrators of the cluster platform with full privileges to
  perform any operation.
* ``k8s_developer``: users able to deploy applications to the cluster platform,
  who are restricted from performing cluster level operations.
* ``k8s_viewer``: users able to view/obtain information about cluster resources.

For a detailed list of permissions associated with these roles, please refer to
role permissions table in this document.

These roles can be added to an existing user through the :ref:`project_users`
page by anyone who has the Project Admin or Project Moderator roles
assigned to their account.

+---------------+--------------------------------------------------------------+
| Role          | Permissions                                                  |
+===============+==============================================================+
| k8s_admin     | Privileged users with maximum rights. Full admin access is   |
|               | granted for Magnum cluster CRUD operations and all           |
|               | Kubernetes namespaces.                                       |
+---------------+--------------------------------------------------------------+
| k8s_developer | Privileged users with restricted rights. Kubernetes CRUD     |
|               | operation access is granted to any namespace other than the  |
|               | admin (``kube-system``) namespace.                           |
+---------------+--------------------------------------------------------------+
| k8s_viewer    | Non-privileged users able to perform READ actions in both    |
|               | Magnum and Kubernetes. Has access to all namespaces,         |
|               | excluding the admin namespace.                               |
+---------------+--------------------------------------------------------------+


.. Warning::

  The privileged roles deserve special attention when deploying kubernetes
  clusters. The `RBAC permissions
  <https://kubernetes.io/docs/reference/access-authn-authz/rbac/>`_ that grant
  the ability to launch a pod in the cluster is a powerful right and use of a
  more restrictive `Admission Controller
  <https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/>`_
  may be appropriate to meet specific customer security needs.

  Please note: this means any user with the the k8s_developer role must be a 
  trusted individual, as by default they're capable of escalating their own 
  privileges.

.. _`Admission Controller`` 

Integrated Pod Policy Solutions:

* `Pod Security Policies <https://kubernetes.io/docs/concepts/security/pod-security-policy/>`_ 
  for Kubernetes clusters >=1.16 and <= 1.24.
* `Pod Security Admission <https://kubernetes.io/docs/concepts/security/pod-security-admission/>`_ 
  for Kubernetes clusters >=1.25.

Example 3rd Party Policy Solutions:

* `Open Policy Agent <https://www.openpolicyagent.org/docs/latest/>`_ / 
  `Gatekeeper <https://github.com/open-policy-agent/gatekeeper/>`_
* `Kyverno <https://github.com/kyverno/kyverno/>`_

More information
================

The following is a comprehensive list of the exact `RBAC permissions
<https://kubernetes.io/docs/reference/access-authn-authz/rbac/>`_ that each role
gives a user:


.. code-block:: console

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

.. _non-admin-cluster-user:

Authenticating a non-admin cluster user
=======================================

The first thing we need to address is a means for our restricted user to be
able to authenticate with the cluster. To do this we will need to create
a new configuration file that can be used by non administrator users. This
will apply to all users on our project, including our restricted user.

Creating a non-admin cluster config
-----------------------------------

As the **cluster administrator** we need to create a **cluster config file**
that allows cloud project users to use the cloud's own authentication service
as a means to access the cluster.

We can do that with the following command:

**$ openstack coe cluster config <CLUSTER_NAME> --use-keystone**

For example:

.. code-block:: console

  $ openstack coe cluster config dev-cluster --use-keystone

This config file can now be made available to other cloud users that need
access to this cluster. By default this file will provide the following levels
of access:

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