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

