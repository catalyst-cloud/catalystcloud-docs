.. _storage:

#######
Storage
#######

*******
Volumes
*******

As mentioned previously in :ref:`pod storage <pod_storage>` , volumes are tied to pods and their
lifecycles. They are the most basic storage abstraction, where volumes are bound to pods and
containers mount these volumes and access them as if they were a local filesystem.

This also provides a mechanism for containers within a pod to be able to share data by mounting
the volume in a shared manner

To use a volume, a Pod specifies what volumes to provide for the Pod and where to mount them in
the containers. The containers themselves see these presented as filesystems. Kubernetes supports
several different `volume types`_ ; for this example we will use an ``emptyDir`` volume which is
essentially an empty directory mounted on the host.

.. _`volume types`: https://kubernetes.io/docs/concepts/storage/volumes/#types-of-volumes

.. literalinclude:: _containers_assets/volume1.yaml

Here we can see we have 2 containers in the pod both which mount the volume, *shared-volume*. The
web container mounts it as */data* while the logger container mounts it as */logs*

******************
Persistent Volumes
******************
``Persistent volumes`` on the other hand exist within Kubernetes but outside of the pods. They
work differently in that pods need to claim a volume to use it and will retain it throughout their
lifetime until it is released. They will also remain in existence even if the their pods are
destroyed. The cluster administrator defines the PersistentVolumes whereas the end users, such as
application developers, create the ``PersistentVolumeClaims``.

As Persistent Volumes have the ability be reused


Persistent Redis store example

First, create a PersistentVolume.


Second, the volume must be claimed


Finally, add a volumeMounts entry matching the volume name and target path
