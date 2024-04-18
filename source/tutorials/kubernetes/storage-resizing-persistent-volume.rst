***************************
Resizing a PersistentVolume
***************************

``PersistentVolumes`` created using the provided ``StorageClasses`` can be resized
and Kubernetes since v1.11 supports this.


.. Note::

   ``PersistentVolumes`` can only be **expanded**, not reduced in size.

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


