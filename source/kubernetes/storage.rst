.. _kubernetes-storage:

#######
Storage
#######

Adding storage to a Kubernetes cluster is easy with the Catalyst Cloud
Kubernetes service.

Catalyst Cloud's storage solution for Kubernetes is based on our :ref:`Block Storage
<block-storage-intro>`, service. It conforms to the `Container Storage
Interface`_ (CSI), an open standard for integrating storage and file systems
with containerised workloads.

.. _`Container Storage Interface`: https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/


Fast, Flexible and Secure
=========================

.. TODO(travis): tutorial for migrating pv to a different cluster

Storage volumes can be allocated to Kubernetes workloads to support a variety of
needs including database storage, secure backups and website
content. They are persistent storage which will remain if the workload goes
away and will reattach when needed, such as when a Pod is scaled down to
zero instances and back up again. They can even be migrated to a new cluster in
the event that a cluster is rebuilt. They can be resized as storage
requirements increase. Finally, Block Storage volumes are always encrypted
meaning that data stays secure at rest.

Integration with Catalyst Cloud's :ref:`Block Storage <block-storage-intro>` service means that
users can select from a range of :ref:`volume tiers <block-storage-volume-tiers>` including standard HDD and high
performance NVMe-backed storage.


Persistent Volumes
==================

Storage volumes can be added to a cluster in a couple of ways.


The cluster administrator can create pre-configured static ``PersistentVolumes``
(PV) that define a particular size and type of volume and these in turn can be
utilised by end users, such as application developers, via a
`PersistentVolumeClaim`_ (PVC).

.. _`PersistentVolumeClaim`: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims

Alternatively, a developer can define a PVC which uses one of the pre-defined
`StorageClass`_ objects in Catalyst Cloud.

.. _`StorageClass`: https://kubernetes.io/docs/concepts/storage/storage-classes/#storageclass-objects

.. _k8s-cinder-storage-class:

***************
Storage classes
***************

Catalyst Cloud provides pre-defined `Storage Classes`_ for the block storage tiers
in each region. The storage classes available to Kubernetes clusters are named
according to the underlying :doc:`block storage tiers
</block-storage/volume-tiers>`.

.. _`Storage Classes`: https://kubernetes.io/docs/concepts/storage/storage-classes/

The storage class names and their availability by region are as follows:

+--------------------+-----------+-----------+
| Storage class      | nz-por-1  | nz-hlz-1  |
+====================+===========+===========+
| b1.sr-r3-nvme-1000 | available | available |
+--------------------+-----------+-----------+
| b1.sr-r3-nvme-2500 | available | available |
+--------------------+-----------+-----------+
| b1.sr-r3-nvme-5000 | available | available |
+--------------------+-----------+-----------+
| b1.standard        | available | available |
+--------------------+-----------+-----------+


Adding Storage to a Cluster
===========================


Adding storage to a Catalyst Cloud Kubernetes cluster is easy. As illustrated
in the figure below, a user first creates a ``PersistentVolumeClaim`` (PVC)
using a storage class from the table above.  The control plane then provisions
a volume from Catalyst Cloud Block Storage which can be used by a ``Pod``.

.. figure:: _containers_assets/block-storage.drawio.svg
   :name: k8s-pvc-block-storage
   :class: with-border

   Attaching Catalyst Cloud Block Storage volume to a ``Pod`` using a ``PersistentVolumeClaim``.

This can be demonstrated with an example. We first need to specify a name
for the PVC and a size for the volume:

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
``PersistentVolume`` is created and bound, and a volume is created in Catalyst
Cloud Block Storage.


.. code-block:: bash

  $ kubectl get pvc
  NAME                         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS         AGE
  test-persistentvolumeclaim   Bound    pvc-bca8b8ef-01b2-408e-aba6-bf9bef249e84   1Gi        RWO            b1.sr-r3-nvme-1000   17s

  $ kubectl get pv
  NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                STORAGECLASS         REASON   AGE
  pvc-bca8b8ef-01b2-408e-aba6-bf9bef249e84   1Gi        RWO            Retain           Bound    default/test-persistentvolumeclaim   b1.sr-r3-nvme-1000            17s


To access this from within a pod we need to add a ``volumes`` entry
specifying the ``PersistentVolumeClaim`` and give it a name. We then add a
``volumeMounts`` entry to the container that links to the PVC by its name.
Finally a ``mountPath`` entry that defines the target path for the volume to
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

.. _kubernetes-persistent-volume-retention:

***************************
Persistent Volume Retention
***************************

When a ``PersistentVolume`` is used as a resource within a cluster through the
creation of a ``PersistentVolumeClaim`` it is important to know that the underlying
physical volume assigned to the claim will persist if the cluster is removed.

.. Note::

   If a cluster is deleted before removing resources, the persistence of the
   underlying volume is not affected by the setting of the ``StorageClass``
   *Reclaim Policy*.


If the ``PersistentVolumeClaim`` resource was intentionally released prior to the
cluster being terminated however, the usual retention policy for that
storage class will apply.

The default retention policy is ``Retain`` and is set on all
``PersistentVolumeClaims`` in a cluster at cluster create time. It is
possible to set an alternative value at cluster create time using the
``csi_cinder_reclaim_policy`` label (See :ref:`cluster labels
<k8s-cluster-labels>`).

The ``Retain`` policy prevents accidental removal, and permits re-attachment to
another Kubernetes cluster. For some workloads, it will be preferable to use
the `Delete` reclaim policy which will remove both the automatically created
``PersistentVolume`` and the underlying block storage volume when the
``PersistentVolumeClaim`` is deleted.

Refer to the Kubernetes documentation on `Persistent Volume Reclaiming`_ for more details.


.. _`Persistent Volume Reclaiming`: https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaiming


.. note::
   Please refer to our :ref:`tutorials <kubernetes-tutorials>` for more detailed
   examples using persistant storage in Kubernetes.


*************************************************
Accessing PersistentVolume data without a cluster
*************************************************

If it is necessary to access the data on the ``PersistentVolume`` device without
creating a new cluster, the volume in question will need to be attached to an
existing Catalyst Cloud instance and then mounted as a new volume within the
filesystem.

For further information on mounting an existing volume, see :doc:`/block-storage/using-volumes`.
