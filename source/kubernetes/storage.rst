.. _storage:

#######
Storage
#######


*******
Volumes
*******

In Kubernetes volumes are tied to pods and their lifecycles. They are the most basic storage
abstraction, where volumes are bound to pods and containers mount these volumes and access them
as if they were a local filesystem.

This also provides a mechanism for containers within a pod to be able to share data by mounting
the volume in a shared manner

To use a volume, a Pod specifies what volumes to provide for the Pod and where to mount them in
the containers. The containers themselves see these presented as filesystems. Kubernetes supports
several different `volume types`_ , for this example we will use an ``emptyDir`` volume which is
essentially an empty directory mounted on the host.

.. _`volume types`: https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes

.. literalinclude:: _containers_assets/volume1.yaml

Here we can see we have 2 containers in the pod both which mount the volume, *shared-volume*. The
web container mounts it as */data* while the logger container mounts it as */logs*


******************
Persistent Volumes
******************

``Persistent volumes`` on the other hand exist within Kubernetes but outside of the pods. They
work differently in that pods need to claim a volume, based on a ``storage class``, to use it
and will retain it throughout their lifetime until it is released. They will also have the option
to retain the volume even if the their pods are destroyed.

The cluster administrator can create pre-configured static PersistentVolumes that define a
particular size and type of volume and these in turn can be utilised by end users, such as
application developers, via ``PersistentVolumeClaims``.

If a PersistentVolumeClaim is made and no matching PersistentVolume type is found Kubernetes will
attempt to dynamically provision the storage based on the volume claim. If no storage class is
defined then the default storage class will be used.

.. Note::

  In the current Technical Preview there is no ``default storage class`` defined for a new cluster
  in the Catalyst Cloud. This will need to be created prior to using PersistentVolumes.

Dynamic Allocation
==================

Lets look at the steps involved in dynamically allocating a PersistentVolume to a pod.

First we need to create a storage class, for the Catalyst Cloud these will initially be limited to
our usual block storage tier so the parameter for the ``volume type`` must be set to
``b1.standard``.

It is also necessary to specify the availability zone for the storage class to be defined in. To
find the availability zone your cluster is in run the following.

.. code-block:: bash

  $ openstack availability zone list
  +-----------+-------------+
  | Zone Name | Zone Status |
  +-----------+-------------+
  | nz-hlz-1a | available   |
  | nz-hlz-1a | available   |
  +-----------+-------------+

Create the definition file for your storage type. We will call this storage class
*cinder-standard* and update the availability and type parameters as discussed above.

.. literalinclude:: _containers_assets/storage1.yaml

Then create the storage class within your cluster.

.. code-block:: bash

  $ kubectl create -f storage.yaml

Next create a definition file for a PersistentVolumeClaim using the new storage class. As there is
only the one storage class we can omit naming it in the definition as it will be used by default.
Though we do need to specify a name for the claim and a size for the resulting volume, in this
example we will use 1GB.

.. literalinclude:: _containers_assets/pvc1.yaml

Now create a claim for the volume.

.. code-block:: bash

  $ kubectl create -f pvc1.yaml

To access this from with in our pod we need to add a ``volumes`` entry specifying the
PersistentVolumeClaim and giving it a name, then a ``volumeMounts`` entry to the container that
links to the PVC by its name and finally a ``mountPath`` entry that defines the target path for
the volume to be mounted in the container.

.. literalinclude:: _containers_assets/pvc-example1.yaml

Create the new pod and once it is available exec a bash shell into it to confirm that the new
volume is present.

.. code-block:: bash

  $ kubectl create -f pvc-example1.yaml

Now if we describe the pod we can see under the ``Mounts:`` section that it has a volume mounted
from the storage class cinder-storage and the ``Volumes:`` section shows the related persistent
volume claim for this storage.

.. code-block:: bash

  $ kubectl describe pod pod-cinder

::

  Name:         pod-cinder
  Namespace:    default
  Node:         k8s-m3-n3-pw6k57d7glg6-minion-1/10.0.0.14

  <snip>

  Containers:
    cinder-storage-container:
      Container ID:   docker://d4cc2a5e02b1e907a0e7a75a7bc40b690e383932ca71001372463fd0383dec23
      Image:          lingxiankong/alpine-test
      Image ID:       docker-pullable://docker.io/lingxiankong/alpine-test@sha256:71e08da2e5761059d93fa2354b99958042406b308552b0b739325988e99d8e27
      Port:           8080/TCP
      Host Port:      0/TCP
      State:          Running
        Started:      Sun, 21 Oct 2018 12:13:11 +1300
      Ready:          True
      Restart Count:  0
      Environment:    <none>
      Mounts:
        /data from cinder-storage (rw)
        /var/run/secrets/kubernetes.io/serviceaccount from default-token-5nfhn (ro)
  Conditions:
    Type              Status
    Initialized       True
    Ready             True
    ContainersReady   True
    PodScheduled      True
  Volumes:
    cinder-storage:
      Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
      ClaimName:  cinder-pvc
      ReadOnly:   false

  <snip>
