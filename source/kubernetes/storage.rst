.. _storage:

#######
Storage
#######


*******
Volumes
*******

In Kubernetes volumes are tied to `pods`_  and their life cycles. They are the
most basic storage abstraction, where volumes are bound to pods and containers
mount these volumes and access them as if they were a local filesystem.

This also provides a mechanism for containers within a pod to be able to share
data by mounting the volume in a shared manner.

.. _`pods`: https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/

.. Note::

  Volumes are ephemeral and they are tied to the lifetime of the pod. Once the
  pod terminates all volumes and associated data within it are gone.

To use a volume, a Pod specifies what volumes to provide for the Pod and where
to mount them in the containers. The containers themselves see these presented
as file systems. Kubernetes supports several different `volume types`_ , for
this example we will use an ``emptyDir`` volume which is essentially an empty
directory mounted on the host.

.. _`volume types`: https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes

.. literalinclude:: _containers_assets/volume1.yaml

Here we can see we have 2 containers in the pod both which mount the volume,
*shared-volume*. The web container mounts it as */data* while the logger
container mounts it as */logs*.


******************
Persistent volumes
******************

``Persistent volumes`` on the other hand exist within Kubernetes but outside of
the pods. They work differently in that pods need to claim a volume, based on
a ``storage class``, to use it and will retain it throughout their lifetime
until it is released. Persistent volumes however, also have the option to
retain the volume even if the their pods are destroyed.

The cluster administrator can create pre-configured static PersistentVolumes
(PV) that define a particular size and type of volume and these in turn can be
utilised by end users, such as application developers, via
``PersistentVolumeClaims`` (PVC).

If a PersistentVolumeClaim is made and no matching PersistentVolume type
is found Kubernetes will attempt to dynamically provision the storage based
on the volume claim. If no storage class is defined then the default storage
class will be used.

Storage classes
===============

Catalyst Cloud provides pre-defined storage classes for all of the block
storage tiers in each region. There are storage classes available for the
default `standard storage tier`_ and for each of the
`performance storage tiers`_.

.. _`standard storage tier`: https://docs.catalystcloud.nz/block-storage/overview.html#the-standard-tier
.. _`performance storage tiers`: https://docs.catalystcloud.nz/block-storage/overview.html#the-performance-tier

The storage class names and their availability by region are as follows:

+--------------------+--------------+
| Storage class name | Availability |
+====================+==============+
| b1.standard        | | nz-hlz-1a  |
|                    | | nz-por-1a  |
|                    | | NZ-WLG-2   |
+--------------------+--------------+
| b1.sr-r3-nvme-1000 | | nz-hlz-1a  |
|                    | | nz-por-1a  |
+--------------------+--------------+
| b1.sr-r3-nvme-2500 | | nz-hlz-1a  |
|                    | | nz-por-1a  |
+--------------------+--------------+
| b1.sr-r3-nvme-5000 | | nz-hlz-1a  |
|                    | | nz-por-1a  |
+--------------------+--------------+

Dynamic allocation
==================

Lets look at the steps involved in dynamically allocating a PersistentVolume to
a pod.

Next create a definition file for a PersistentVolumeClaim using a
storage class class from the table above. We also need to specify a name for
the claim and a size for the volume. In our example we will use the following:

* storage class : b1.standard
* volume name : test-persistentvolumeclaim
* volume size : 1 GB

.. literalinclude:: _containers_assets/pvc1.yaml
    :emphasize-lines: 6,10,13

Now create a claim for the volume.

.. code-block:: bash

  $ kubectl create -f pvc1.yaml
  persistentvolumeclaim/test-persistentvolumeclaim created

To access this from within our pod we need to add a ``volumes`` entry
specifying the PersistentVolumeClaim and giving it a name, then a
``volumeMounts`` entry to the container that links to the PVC by its name and
finally a ``mountPath`` entry that defines the target path for the volume to
be mounted in the container.

.. literalinclude:: _containers_assets/pvc-example1.yaml

Create the new pod.

.. code-block:: bash

  $ kubectl create -f pvc-example1.yaml
  pod/pod-pv-test created

Once the pod is available exec a bash shell into it to confirm that the new
volume is present on the /data .

.. code-block:: bash

  $ kubectl exec -it pod-pv-test -- /bin/bash

  root@pod-pv-test:/# mount |grep data
  /dev/vdb on /data type ext4 (rw,relatime,seclabel,data=ordered)

If we describe the pod we can see under the ``Mounts:`` section that it
has a volume mounted from the storage class **block-storage-class** and the
``Volumes:`` section shows the related persistent volume claim for this storage.

.. code-block:: bash

  $ kubectl describe pod pod-pv-test

::

  Name:         pod-pv-test
  Namespace:    default
  Node:         k8s-m3-n3-u6zyxknksxcs-minion-0/10.0.0.13
  Start Time:   Thu, 07 Mar 2019 10:19:56 +1300
  Labels:       <none>
  Annotations:  <none>
  Status:       Running
  IP:           192.168.206.134
  Containers:
    test-storage-container:
      Container ID:   docker://e9fc4a3ec04e9777134f7ebbd624422efc8b67ca27567464e8d584f5be85df73
      Image:          nginx:latest
      Image ID:       docker-pullable://docker.io/nginx@sha256:98efe605f61725fd817ea69521b0eeb32bef007af0e3d0aeb6258c6e6fe7fc1a
      Port:           8080/TCP
      Host Port:      0/TCP
      State:          Running
        Started:      Thu, 07 Mar 2019 10:20:20 +1300
      Ready:          True
      Restart Count:  0
      Environment:    <none>
      Mounts:
        /data from test-persistentvolume (rw)
        /var/run/secrets/kubernetes.io/serviceaccount from default-token-6kv8n (ro)
  Conditions:
    Type              Status
    Initialized       True
    Ready             True
    ContainersReady   True
    PodScheduled      True
  Volumes:
    test-persistentvolume:
      Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
      ClaimName:  test-persistentvolumeclaim
      ReadOnly:   false
    default-token-6kv8n:
      Type:        Secret (a volume populated by a Secret)
      SecretName:  default-token-6kv8n
      Optional:    false
  QoS Class:       BestEffort
  Node-Selectors:  <none>
  Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                   node.kubernetes.io/unreachable:NoExecute for 300s
  Events:          <none>


***************************
Persistent volume retention
***************************

When a PersistentVolume is used as a resource within a cluster through the
creation of a PersistentVolumeClaim it is important to know that the underlying
physical volume assigned to the claim will persist if the cluster is removed.

.. Note::

  The persistence of the underlying volume is not affected by the setting
  of the StorageClass ``Reclaim Policy`` setting in this scenario.

If the PersistentVolumeClaim resource was intentionally released prior to the
cluster being terminated however, the usual retention policy for that
storage class will apply.

Retrieving data from an orphaned PersistentVolume
=================================================

Assume we had previously created a cluster that had a Pod with a
PersistentVolume mounted on it. If the cluster was unintentionally deleted or
failed due to unexpected circumstances we would still be able to access the
Persistent Volume in question from another cluster within the same cloud
project.

First we need to query our project to identify the volume in question and
retrieve its UUID.

.. code-block:: bash

  $ openstack volume list
  +--------------------------------------+-------------------------------------------------------------+-----------+------+-------------+
  | ID                                   | Name                                                        | Status    | Size | Attached to |
  +--------------------------------------+-------------------------------------------------------------+-----------+------+-------------+
  | 6b1903ea-d1aa-452d-93cc-184537d538bd | kubernetes-dynamic-pvc-1e3b558f-3945-11e9-9776-fa163e96b322 | available |    1 |             |
  +--------------------------------------+-------------------------------------------------------------+-----------+------+-------------+

Once we have the ID value for the volume in question we can create a new
``PersistentVolume`` resource in our cluster and link it specifically to that
volume.

.. literalinclude:: _containers_assets/pv-existing.yaml
    :emphasize-lines: 18

.. code-block:: bash

  $ kubectl create -f pv-existing.yaml
  persistentvolume/cinder-pv created

Once we have the PV created we need to create a corresponding
``PersistentVolumeClaim`` for that resource.

The key point to note here is that our claim needs to reference the specific
PersistentVolume we created in the previous step. To do this we use a selector
with the ``matchLabels`` argument to refer to a corresponding label that we had
in the PersistentVolume declaration.

.. literalinclude:: _containers_assets/pvc-existing-pv.yaml
    :emphasize-lines: 15

.. code-block:: bash

  $ kubectl create -f pvc-existing-pv.yaml
  persistentvolumeclaim/existing-cinder-pv-claim created

Finally we can create a new Pod that uses our PersistentVolumeClaim to mount
the required volume on this pod.

.. literalinclude:: _containers_assets/pod-with-existing-pv.yaml
    :emphasize-lines: 10-11

.. code-block:: bash

  $ kubectl create -f pod-with-existing-pv.yaml
  pod/pod-cinder created

If we describe the pod we can see that it has now successfully mounted our
volume as /data within the container.

.. literalinclude:: _containers_assets/pod-desc-pv.yaml
    :emphasize-lines: 22-23,48


Accessing PersistentVolume data without a cluster
=================================================

If it is necessary to access the data on the PersistentVolume device without
creating a new cluster, the volume in question will need to be attached to an
existing cloud instance and then mounted as a new volume within the filesystem.
From here you should be able to follow the steps in the orphaned PVC section.


