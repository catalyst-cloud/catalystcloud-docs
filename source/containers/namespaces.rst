.. _namespaces:

##########
Namespaces
##########

Namespaces provide virtual segmentation within a cluster. The

When a cluster is initially provisioned it will be created with three namespaces. These are:

- **default** : The default namespace for objects when no other namespace is provided.
- **kube-system** : The namespace for system objects created by Kubernetes.
- **kube-public** : This is created automatically and is readable by all users even if
  unauthenticated. It is typically reserved for cluster usage, where a resources should be visible
  and readable publicly throughout the entire cluster. It's public nature is convention and is not
  mandatory.

Creating and using a namespace is straightforward. First define the new namespace in a
configuration file. Here is an example to make a new namespace called *development*

.. literalinclude:: _containers_assets/namespace1.yaml

The run the kubectl create command referencing the namespace configuration file and confirm that
there is now a new namespace available for use.

.. code-block:: bash

  $ kubectl create -f namespace1.yaml
  $ kubectl get namespace
