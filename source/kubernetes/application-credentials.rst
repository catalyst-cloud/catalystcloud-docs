#######################
Application Credentials
#######################

An :doc:`application credential </identity-access-management/application-credentials>`
is created for your cluster on creation. The credential is used by the Catalyst
Cloud Kubernetes Service to manage cloud resources for the cluster. The
application credential is owned by the user who created the cluster or last
rotated the credentials, so it is important to take care when managing the
users in your project to ensure uninterrupted access.

.. warning::

  If the user that created the cluster is removed from the project or disabled
  then the cluster will be prevented from actions that require access to cloud
  resources, such as creating/updating ingress load balancers, persistent
  volume operations, or scaling of worker nodes.

Updating the Application Credentials for your cluster
=====================================================

If you need to change the application credential associated with your cluster,
you can use the credential rotation action available via a command in the
Openstack client.

Select a suitable user in your project and authenticate as that user using an
OpenRC file. The user must not be authenticated using an existing application
credential unless it was explicitly set to unrestricted at creation.

Via the Command Line
--------------------

To rotate your cluster application credential via the CLI, you can use the
automated rotation command available in the Openstack client. This requires
version >=4.9.0 of the Magnum client.

.. code-block:: console

  pip install "python-magnumclient>=4.9.0"

With the appropriate Magnum client installed, you can invoke the application
credential rotation with the name or ID of your cluster.

.. code-block:: console

  openstack coe credential rotate 12345678-abcd-1234-abcd-123456789abc

For clusters on templates older than v1.34, manually restart Openstack services
that rely on the application credential.

.. code-block:: console

  kubectl rollout restart -n openstack-system deployment/openstack-cinder-csi-controllerplugin
  kubectl rollout restart -n openstack-system daemonset/openstack-cinder-csi-nodeplugin
  kubectl rollout restart -n openstack-system daemonset/openstack-cloud-controller-manager

You can verify these services have been restarted by inspecting the age of the
affected pods.

.. code-block:: console

  kubectl get pods -n openstack-system

This should report that the Cinder CSI plugin and Openstack controller have
only been running for a short time.

.. code-block:: console

  NAME                                                    READY   STATUS    RESTARTS   AGE
  openstack-cinder-csi-controllerplugin-6c8b8cf78-9kv48   6/6     Running   0          16s
  openstack-cinder-csi-nodeplugin-4wbc8                   3/3     Running   0          7s
  openstack-cinder-csi-nodeplugin-9xnr9                   3/3     Running   0          8s
  openstack-cloud-controller-manager-pwvmg                1/1     Running   0          3s

Via the Dashboard
-----------------

Cluster credential rotation via the dashboard is currently not supported, but
has been developed and it will be added in an upcoming release.
