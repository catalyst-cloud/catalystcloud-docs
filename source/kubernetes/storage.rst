.. _storage:

#######
Storage
#######

Volumes
=======

Volumes in Kubernetes are mounted filesystems or files that are managed by
the kubelet. These volumes are defined at the pod level and each container
can specify which volume to mount and the mount location.

There are several types of volumes that may be used on Catalyst Cloud's Managed
Kubernetes, some common types include:

* `configMap`_
* `emptyDir`_
* `hostpath`_  (pay special attention to the security implications)
* `nfs`_
* `persistentVolumeClaim`_
* `secret`_

To read more about using these volume types, refer to the `Kubernetes
Volume documentation`_.

.. _`configMap`: https://kubernetes.io/docs/concepts/storage/volumes/#configmap
.. _`emptyDir`: https://kubernetes.io/docs/concepts/storage/volumes/#emptydir
.. _`hostpath`: https://kubernetes.io/docs/concepts/storage/volumes/#hostpath
.. _`nfs`: https://kubernetes.io/docs/concepts/storage/volumes/#nfs
.. _`persistentVolumeClaim`: https://kubernetes.io/docs/concepts/storage/volumes/#persistentvolumeclaim
.. _`secret`: https://kubernetes.io/docs/concepts/storage/volumes/#secret
.. _`Kubernetes Volume documentation`: https://kubernetes.io/docs/concepts/storage/volumes/

On this page, we will show examples of ephemeral volumes using `emptyDir`, and persistent volumes
using `persistentVolumeClaims`, which are provisioned using OpenStack Cinder our block storage service.


Ephemeral Volumes
=================

In Kubernetes, ephemeral volumes are tied to `pods`_  and their life cycles.
They are the most basic storage abstraction, and containers within the pod
mount these volumes and access them as if they were a local filesystem.

This also provides a mechanism for containers within a pod to be able to share
data by mounting the same volume.

.. _`pods`: https://kubernetes.io/docs/concepts/workloads/pods/

.. Note::

  Once a pod terminates, all ephemeral volumes and associated data within it are gone.

To use a volume, a Pod specifies a list of volumes and where to mount them in
each container. The containers themselves see these presented as file systems.
Kubernetes supports several different `volume types`_ , for
this example we will use an ``emptyDir`` volume which is essentially an empty
directory bind mounted from the host.

.. _`volume types`: https://kubernetes.io/docs/concepts/storage/volumes/#volume-types

.. literalinclude:: _containers_assets/volume1-emptydir.yaml

Here we can see we have two containers in the pod that mount the same volume,
*shared-volume*. The *test-web* container mounts it on */data*, while the
*test-logger* container mounts it on */logs*. Both containers can then read
and write to the same filesystem.


Persistent volumes
==================

``PersistentVolumes`` on the other hand, exist as separate resources within
Kubernetes.
They work differently to emphemeral volumes, in that pods need to claim a volume
based on a ``StorageClass`` and will retain it throughout their lifetime
until it is released. ``PersistentVolumes`` also have the option to
retain the volume even if the pods using it are destroyed.

The cluster administrator can create pre-configured static ``PersistentVolumes``
(PV) that define a particular size and type of volume and these in turn can be
utilised by end users, such as application developers, via a
``PersistentVolumeClaim`` (PVC).

If a ``PersistentVolumeClaim`` is made and no matching ``PersistentVolume``
is found, Kubernetes can attempt to dynamically provision the storage based
on the volume claim. If no storage class is defined then the default storage
class will be used.

***************
Storage classes
***************

Catalyst Cloud provides pre-defined `Storage Classes`_ for the block storage tiers
in each region. See :doc:`/block-storage/volume-tiers`.

.. _`Storage Classes`: https://kubernetes.io/docs/concepts/storage/storage-classes/

The storage class names and their availability by region are as follows:

+--------------------+-----------+-----------+-----------+
| Storage class      | nz-por-1  | nz-hlz-1  |  nz_wlg_2 |
+====================+===========+===========+===========+
| b1.standard        | available | available | available |
+--------------------+-----------+-----------+-----------+
| b1.sr-r3-nvme-1000 | available | available |           |
+--------------------+-----------+-----------+-----------+
| b1.sr-r3-nvme-2500 | available | available |           |
+--------------------+-----------+-----------+-----------+
| b1.sr-r3-nvme-5000 | available | available |           |
+--------------------+-----------+-----------+-----------+


******************
Dynamic allocation
******************

Let's look at the steps involved in dynamically allocating a ``PersistentVolume`` to
a pod.

First, we create a definition file for a ``PersistentVolumeClaim`` using a
storage class from the table above. We also need to specify a name for
the claim and a size for the volume. In our example we will use the following:

* storage class : b1.sr-r3-nvme-1000
* volume name : test-persistentvolumeclaim
* volume size : 1 GiB

.. literalinclude:: _containers_assets/pvc1.yaml
    :emphasize-lines: 6,10,13

Now create the claim for the volume in Kubernetes.

.. code-block:: bash

  $ kubectl create -f pvc1.yaml
  persistentvolumeclaim/test-persistentvolumeclaim created

We should soon be able to see this PVC transition to *Bound* status, as a
``PersistentVolume`` is created and bound, and a Cinder volume created in OpenStack.


.. code-block:: bash

  $ kubectl get pvc
  NAME                         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS         AGE
  test-persistentvolumeclaim   Bound    pvc-bca8b8ef-01b2-408e-aba6-bf9bef249e84   1Gi        RWO            b1.sr-r3-nvme-1000   17s

  $ kubectl get pv
  NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                STORAGECLASS         REASON   AGE
  pvc-bca8b8ef-01b2-408e-aba6-bf9bef249e84   1Gi        RWO            Retain           Bound    default/test-persistentvolumeclaim   b1.sr-r3-nvme-1000            17s


To access this from within a pod we need to add a ``volumes`` entry
specifying the ``PersistentVolumeClaim`` and give it a name. Then we add a
``volumeMounts`` entry to the container that links to the PVC by its name and
finally a ``mountPath`` entry that defines the target path for the volume to
be mounted in the container.

.. literalinclude:: _containers_assets/pvc1-pod.yaml
  :emphasize-lines: 15-16,18-20

Create the new pod.

.. code-block:: bash

  $ kubectl create -f pvc1-pod.yaml
  pod/pod-pv-test created

Once the pod is available, exec into it with a *bash* shell to confirm that the new
volume is mounted on */data*.

.. code-block:: bash

  $ kubectl exec -it pod-pv-test -- /bin/bash

  root@pod-pv-test:/# mount | grep data
  /dev/vdd on /data type ext4 (rw,relatime,seclabel)


If we describe the pod we can see under the `Mounts:` section that it
has a volume mounted from the storage class **block-storage-class** and the
`Volumes:` section shows the related persistent volume claim for this storage.

.. code-block::
  :emphasize-lines: 29,38-41,56


  $ kubectl describe pod pod-pv-test
  Name:             pod-pv-test
  Namespace:        default
  Priority:         0
  Service Account:  default
  Node:             cluster1-afjuly77v4gr-node-0/10.0.0.14
  Start Time:       Wed, 31 Jan 2024 22:49:45 +0000
  Labels:           <none>
  Annotations:      cni.projectcalico.org/containerID: d0e0273a9c017d9beb9476d886bd028c953ef8e39e730a7f407eb411f39d7dca
                    cni.projectcalico.org/podIP: 10.100.130.208/32
                    cni.projectcalico.org/podIPs: 10.100.130.208/32
  Status:           Running
  IP:               10.100.130.208
  IPs:
    IP:  10.100.130.208
  Containers:
    test-storage-container:
      Container ID:   containerd://5fcb09543ec5202f1a2ee56b2086aaabe8291fd07234e75a1bf10f40d198a106
      Image:          nginx:latest
      Image ID:       docker.io/library/nginx@sha256:4c0fdaa8b6341bfdeca5f18f7837462c80cff90527ee35ef185571e1c327beac
      Port:           8080/TCP
      Host Port:      0/TCP
      State:          Running
        Started:      Wed, 31 Jan 2024 22:50:08 +0000
      Ready:          True
      Restart Count:  0
      Environment:    <none>
      Mounts:
        /data from test-persistentvolume (rw)
        /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-p2npp (ro)
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
    kube-api-access-p2npp:
      Type:                    Projected (a volume that contains injected data from multiple sources)
      TokenExpirationSeconds:  3607
      ConfigMapName:           kube-root-ca.crt
      ConfigMapOptional:       <nil>
      DownwardAPI:             true
  QoS Class:                   BestEffort
  Node-Selectors:              <none>
  Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                               node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
  Events:
    Type    Reason                  Age   From                     Message
    ----    ------                  ----  ----                     -------
    Normal  Scheduled               2m    default-scheduler        Successfully assigned default/pod-pv-test to cluster1-afjuly77v4gr-node-0
    Normal  SuccessfulAttachVolume  111s  attachdetach-controller  AttachVolume.Attach succeeded for volume "pvc-bca8b8ef-01b2-408e-aba6-bf9bef249e84"
    Normal  Pulling                 108s  kubelet                  Pulling image "nginx:latest"
    Normal  Pulled                  97s   kubelet                  Successfully pulled image "nginx:latest" in 10.696765403s (10.69679197s including waiting)
    Normal  Created                 97s   kubelet                  Created container test-storage-container
    Normal  Started                 97s   kubelet                  Started container test-storage-container


***************************
Persistent volume retention
***************************

When a ``PersistentVolume`` is used as a resource within a cluster through the
creation of a ``PersistentVolumeClaim`` it is important to know that the underlying
physical volume assigned to the claim will persist if the cluster is removed.

.. Note::

  The persistence of the underlying volume is not affected by the setting
  of the ``StorageClass`` *Reclaim Policy* in the scenario where the cluster is
  deleted before removing resources.

If the ``PersistentVolumeClaim`` resource was intentionally released prior to the
cluster being terminated however, the usual retention policy for that
storage class will apply.

The policy `Retain` is the default provided, and this allows for manual deletion
of the underlying resource. This prevents accidental removal, and permits
re-attachment to another Kubernetes cluster.

For some workloads, it will be preferable to use the `Delete` reclaim policy which
will remove both the automatically created ``PersistentVolume`` and the underlying
Cinder volume when the ``PersistentVolumeClaim`` is deleted.

Refer to the Kubernetes documentation on `Persistent Volume Reclaiming`_ for more details.


.. _`Persistent Volume Reclaiming`: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaiming


***************************
Resizing a PersistentVolume
***************************

``PersistentVolumes`` created using the provided ``StorageClasses`` can be resized
and Kubernetes since v1.11 supports this.


.. Note::

   ``PersistentVolumes`` can only be **expanded**, not reduced in size.

On Catalyst Cloud you may need to apply the below patch to enable resizing, as `ALLOWVOLUMEEXPANSION` has not been
enabled by default.
The patch is idempotent and can be safely re-applied to all clusters.

.. code-block:: bash

  $ kubectl patch storageclass b1.sr-r3-nvme-1000 b1.sr-r3-nvme-2500 b1.sr-r3-nvme-5000 b1.standard -p '{"allowVolumeExpansion": true}'
  storageclass.storage.k8s.io/b1.sr-r3-nvme-1000 patched
  storageclass.storage.k8s.io/b1.sr-r3-nvme-2500 patched
  storageclass.storage.k8s.io/b1.sr-r3-nvme-5000 patched
  storageclass.storage.k8s.io/b1.standard patched

Now listing ``StorageClasses`` will show `true` in the `ALLOWVOLUMEEXPANSION` column.

.. code-block:: bash

  $ kubectl get storageclass
  NAME                           PROVISIONER                RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
  b1.sr-r3-nvme-1000 (default)   cinder.csi.openstack.org   Retain          Immediate           true                   6d3h
  b1.sr-r3-nvme-2500             cinder.csi.openstack.org   Retain          Immediate           true                   6d3h
  b1.sr-r3-nvme-5000             cinder.csi.openstack.org   Retain          Immediate           true                   6d3h
  b1.standard                    cinder.csi.openstack.org   Retain          Immediate           true                   6d3h


To initiate a resize, edit the ``PersistentVolumeClaim`` and set
`spec.resources.requests.storage` to an increased size.

.. code-block:: bash
   :emphasize-lines: 23

    $ kubectl edit pvc/test-persistentvolumeclaim

    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      annotations:
        pv.kubernetes.io/bind-completed: "yes"
        pv.kubernetes.io/bound-by-controller: "yes"
        volume.beta.kubernetes.io/storage-provisioner: cinder.csi.openstack.org
        volume.kubernetes.io/storage-provisioner: cinder.csi.openstack.org
      creationTimestamp: "2024-01-31T22:42:26Z"
      finalizers:
      - kubernetes.io/pvc-protection
      name: test-persistentvolumeclaim
      namespace: default
      resourceVersion: "1156755"
      uid: bca8b8ef-01b2-408e-aba6-bf9bef249e84
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 3Gi
      storageClassName: b1.sr-r3-nvme-1000
      volumeMode: Filesystem
      volumeName: pvc-bca8b8ef-01b2-408e-aba6-bf9bef249e84


Once this has been done, there will be several failed events. This is
because online resizing is not permitted and a pod has the PV mounted.

.. code-block:: bash

  $ kubectl get events
  LAST SEEN   TYPE      REASON                   OBJECT                                             MESSAGE
  5s          Warning   ExternalExpanding        persistentvolumeclaim/test-persistentvolumeclaim   waiting for an external controller to expand this PVC
  2s          Normal    Resizing                 persistentvolumeclaim/test-persistentvolumeclaim   External resizer is resizing volume pvc-bca8b8ef-01b2-408e-aba6-bf9bef249e84
  2s          Warning   VolumeResizeFailed       persistentvolumeclaim/test-persistentvolumeclaim   resize volume "pvc-bca8b8ef-01b2-408e-aba6-bf9bef249e84" by resizer "cinder.csi.openstack.org" failed: rpc error: code = Internal desc = Could not resize volume "127fd890-8bb5-4962-92f6-bf498a8881c5" to size 2: Expected HTTP response code [202] when accessing [POST https://api.catalystcloud.nz:8776/v3/b6170e3eab4d44428c879485de7bee98/volumes/127fd890-8bb5-4962-92f6-bf498a8881c5/action], but got 406 instead

To complete the resize, re-create the pod that has the ``PersistentVolume`` mounted; either
by deleting it and re-creating or by scaling the associated deployment down and back up.

In this example, we do not have a ``Deployment``, so we will delete and re-create the pod.

.. code-block:: bash

  $ kubectl delete -f pvc1-pod.yaml
  pod "pod-pv-test" deleted
  $ kubectl create -f pvc1-pod.yaml
  pod/pod-pv-test created

When the ``PersistentVolume`` is mounted on the new pod, it will be resized by
Cinder CSI, and the kubelet will resize the filesystem. Then the pod will be
started with the new size.

We can see these ``events`` and verify the size is reflected inside the new pod:

.. code-block:: bash
   :emphasize-lines: 10

    $ kubectl get events
    LAST SEEN   TYPE      REASON                       OBJECT                                             MESSAGE
    2m57s       Normal    Killing                      pod/pod-pv-test                                    Stopping container test-storage-container
    2m28s       Warning   ExternalExpanding            persistentvolumeclaim/test-persistentvolumeclaim   waiting for an external controller to expand this PVC
    2m28s       Normal    Resizing                     persistentvolumeclaim/test-persistentvolumeclaim   External resizer is resizing volume pvc-bca8b8ef-01b2-408e-aba6-bf9bef249e84
    2m26s       Normal    FileSystemResizeRequired     persistentvolumeclaim/test-persistentvolumeclaim   Require file system resize of volume on node
    2m15s       Normal    Scheduled                    pod/pod-pv-test                                    Successfully assigned default/pod-pv-test to cluster1-afjuly77v4gr-node-0
    2m7s        Normal    SuccessfulAttachVolume       pod/pod-pv-test                                    AttachVolume.Attach succeeded for volume "pvc-bca8b8ef-01b2-408e-aba6-bf9bef249e84"
    2m5s        Normal    FileSystemResizeSuccessful   persistentvolumeclaim/test-persistentvolumeclaim   MountVolume.NodeExpandVolume succeeded for volume "pvc-bca8b8ef-01b2-408e-aba6-bf9bef249e84" cluster1-afjuly77v4gr-node-0
    2m5s        Normal    FileSystemResizeSuccessful   pod/pod-pv-test                                    MountVolume.NodeExpandVolume succeeded for volume "pvc-bca8b8ef-01b2-408e-aba6-bf9bef249e84" cluster1-afjuly77v4gr-node-0
    2m4s        Normal    Pulling                      pod/pod-pv-test                                    Pulling image "nginx:latest"
    2m3s        Normal    Pulled                       pod/pod-pv-test                                    Successfully pulled image "nginx:latest" in 1.579627165s (1.579648593s including waiting)
    2m3s        Normal    Created                      pod/pod-pv-test                                    Created container test-storage-container
    2m2s        Normal    Started                      pod/pod-pv-test                                    Started container test-storage-container


.. code-block:: bash

    $ kubectl exec -it pod-pv-test -- /bin/bash

    root@pod-pv-test:/# mount | grep data
    /dev/vdd on /data type ext4 (rw,relatime,seclabel,mb_optimize_scan=0)

    root@pod-pv-test:/# df -h /data
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/vdd        3.0G   24K  3.0G   1% /data



*************************************************
Retrieving data from an orphaned PersistentVolume
*************************************************

Assume we had previously created a cluster that had a Pod with a
``PersistentVolume`` mounted on it. If the cluster was deleted without deleting
the ``PersistentVolume``, or if the ``PersistentVolume`` was set to `Retain`, we can still
find the Cinder volume and use it within another Kubernetes cluster in the same
cloud project and region.


First we need to query our project to identify the volume in question and
retrieve its UUID.

.. code-block:: bash

  $ openstack volume list
  +--------------------------------------+-------------------------------------------------------------+-----------+------+-------------+
  | ID                                   | Name                                                        | Status    | Size | Attached to |
  +--------------------------------------+-------------------------------------------------------------+-----------+------+-------------+
  | 6b1903ea-d1aa-452d-93cc-xxxxxxxxxxxx | kubernetes-dynamic-pvc-1e3b558f-3945-11e9-9776-xxxxxxxxxxxx | available |    1 |             |
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
``PersistentVolume`` we created in the previous step. To do this we use a selector
with the ``matchLabels`` argument to refer to a corresponding label that we had
in the ``PersistentVolume`` declaration.

.. literalinclude:: _containers_assets/pvc-existing-pv.yaml
    :emphasize-lines: 15

.. code-block:: bash

  $ kubectl create -f pvc-existing-pv.yaml
  persistentvolumeclaim/existing-cinder-pv-claim created

Finally we can create a new Pod that uses our ``PersistentVolumeClaim`` to mount
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

*************************************************
Accessing PersistentVolume data without a cluster
*************************************************

If it is necessary to access the data on the ``PersistentVolume`` device without
creating a new cluster, the volume in question will need to be attached to an
existing cloud instance and then mounted as a new volume within the filesystem.

For further information on mounting an existing volume, see :doc:`/block-storage/using-volumes`.
