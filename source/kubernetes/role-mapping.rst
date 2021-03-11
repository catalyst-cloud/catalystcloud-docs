
************************************************
Associating Kubernetes RBAC with Openstack roles
************************************************

By creating a relationship between Kubernetes RBAC and Openstack keystone
roles, you are able to configure access for users based on their openstack
roles. If we look at the *Project Member* role as an example; by default any
user with this role will **not** have access to the pods on your cluster.
However, by creating an association with a kubernetes RBAC, you can allow access
to your cluster for all user on your project who have the *Project Member* role.
Below we discuss the process of how you can create this association and
how you can define your own rules to allow users access to your cluster.

Before we begin, there are a few resources that we are going to need to gather
before we can make changes to our cluster and the pod policy for it. You will
need to have:

- The correct :ref:`openrc<command-line-interface>` file sourced
- A way to ssh to your master node (a jumphost if you have a private cluster)
- Kubectl installed (on your machine or your jumphost)
- Your kube-admin config downloaded

Once you have all of these set up we need to start by taking a look at the
default configmap that connects our openstack roles to our kube RBAC group.
To find the default configmap we use the following command:

.. code-block:: bash

  $ kubectl -n kube-system get configmaps
  NAME                                                           DATA   AGE
  calico-config                                                  4      3d
  coredns                                                        1      3d
  extension-apiserver-authentication                             6      3d
  k8s-keystone-auth-policy                                       1      3d
  keystone-sync-policy                                           1      3d <-- we are looking for this config map here.
  kube-dns-autoscaler                                            1      3d
  kubernetes-dashboard-settings                                  0      3d
  magnum-auto-healer                                             0      3d
  magnum-auto-healer-config                                      1      3d
  magnum-grafana                                                 1      3d
  magnum-grafana-config-dashboards                               1      3d
  magnum-grafana-test                                            1      3d
  magnum-prometheus-operator-apiserver                           1      3d
  ------ Truncated for brevity -----

The ``keystone-sync-policy`` is what we use to connect the openstack keystone
role with a *group* inside the k8s cluster. We can take a look at what our
policy says by default, using the following command:

.. code-block:: bash

  $ kubectl -n kube-system describe configmaps     keystone-sync-policy
  Name:         keystone-sync-policy
  Namespace:    kube-system
  Labels:       <none>
  Annotations:  <none>

  Data
  ====
  syncConfig:
  ----
  role-mappings:
    - keystone-role: _member_
      groups: []

  Events:  <none>

We can see that by default our policy currently has the member role specified,
but it does not have a group to sync with. We can create a group and associate
it with the member role by updating our configmap. For this example we will
call our group "pod-internal-group":

.. Note::

  You do not have to use the ``_member_`` as the keystone role that you sync
  with your internal group, you could use the k8s_viewer role or even the
  auth_only role. We are just using the member role in this example because it
  is part of the default policy and most users will be familiar with this role.

.. code-block:: bash

  $ cat << EOF | kubectl apply -f -
  ---
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: keystone-sync-policy
    namespace: kube-system
  data:
    syncConfig: |
      role-mappings:
        - keystone-role: _member_
          groups: ['pod-internal-group']
  EOF

  # We can confirm this worked by checking our config map again:
  $ kubectl -n kube-system describe configmaps    keystone-sync-policy
  Name:         keystone-sync-policy
  Namespace:    kube-system
  Labels:       <none>
  Annotations:  <none>

  Data
  ====
  syncConfig:
  ----
  role-mappings:
    - keystone-role: _member_
      groups: ['pod-internal-group']

  Events:  <none>

At this point we have now updated our sync policy to include a relationship
between our *Project Member* role and our *pod-internal-group*.

Now, we will create our set of RBAC roles and rolebindings for the group. This
will give users who exist in this group permission to perform the commands that
we specify in our rolebinding. These permissions will then extend to users with
the *Project Member* role because of our keystone-sync configmap. For our
example, we will give our users the ability to list the pods in the kube-system
namespace of our cluster.

.. code-block:: bash

  $ kubectl -n kube-system create role pod-reader --verb=get,list --resource=pods
  $ kubectl -n kube-system create rolebinding pod-reader --role=pod-reader --group=pod-internal-group

.. warning::

  This is only an example and you should be mindful of what access you allow to
  all *project members* on your project.

Now that everything has been set up, your keystone users who have the
*Project Member* role should be able to get and list the pods of your cluster.
You can confirm this with the commands below:

.. code-block::

  # After swapping to our openstack user
  $ kubectl get pod
  Error from server (Forbidden): pods is forbidden: User "daniel" cannot list resource "pods" in API group "" in the namespace "default"

  $ kubectl -n kube-system get pod
  NAME                                                     READY   STATUS    RESTARTS   AGE
  alertmanager-magnum-prometheus-operator-alertmanager-0   2/2     Running   0          3d
  calico-kube-controllers-7457bb579b-qbdqx                 1/1     Running   0          3d
  calico-node-8vxz8                                        1/1     Running   0          3d
  kube-dns-autoscaler-7d66dbddbc-94vbd                     1/1     Running   0          3d
  kubernetes-dashboard-5f4b4f9b5d-x5l9h                    1/1     Running   0          3d
  magnum-auto-healer-f6jl9                                 1/1     Running   0          3d
  ---- List of pods truncated for brevity ----

  $ kubectl -n kube-system get deployment
  Error from server (Forbidden): deployments.extensions is forbidden: User "daniel" cannot list resource "deployments" in API group "extensions" in the namespace "kube-system"

You will notice how even though we gave our pod-internal-group members the
ability to list pods, the command only works in the correct namespace and again
on top of that, even in the correct namespace we only have access to the one
set of commands we specified earlier. This means you can define very strict
rules for what commands each group has access to.
