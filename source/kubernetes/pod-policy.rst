================================================
User access using pod policy and openstack roles
================================================

By customizing the ``pod policy`` of your cluster, you are able to configure
access for users based on their openstack roles. If we look at the
*Project Member* role as an example; by default any user with this role
will not have access to the pods on your cluster. However, by changing
the default pod policy, you can define a set of commands that any user on your
project who has the *Project Member* role can perform on your cluster. Below we
discuss the process of how you can make changes to the default pod policy and
how you can define your own rules to allow users access to your cluster.

Before we begin, there are a few resources that we are going to need to gather
before we can make changes to our cluster and the pod policy for it. You will
need to have:

- The correct :ref:`openrc<command-line-interface>` file sourced
- A way to ssh to your master node (a jumphost if you have a private cluster)
- Kubectl installed (on your machine or your jumphost)
- Your kube config downloaded

Once you have all of these set up we can first take a look at what the default
pod policy is. To find the current policy we use the following commands:

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

The ``keystone-sync-policy`` is what we use to connect the openstack role with 
the user roles inside the k8s cluster. We can take a look at what our policy 
says by default, using the following command: 

.. code-block:: bash

  # See default configmap
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
    - keystone-role: member
      groups: []

  Events:  <none>

We can see that our default policy currently has the member role specified, but 
it does not have a group to sync with. We can use the following code snippet to 
update the config map and create a new group, attaching it to the member role: 

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
        - keystone-role: member
          groups: ['my-special-group']
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
    - keystone-role: member
      groups: ['my-special-group']

  Events:  <none>

