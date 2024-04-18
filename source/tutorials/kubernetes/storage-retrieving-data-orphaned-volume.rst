
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

.. literalinclude:: pv-existing.yaml
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

.. literalinclude:: pvc-existing-pv.yaml
    :emphasize-lines: 15

.. code-block:: bash

  $ kubectl create -f pvc-existing-pv.yaml
  persistentvolumeclaim/existing-cinder-pv-claim created

Finally we can create a new Pod that uses our ``PersistentVolumeClaim`` to mount
the required volume on this pod.

.. literalinclude:: pod-with-existing-pv.yaml
    :emphasize-lines: 10-11

.. code-block:: bash

  $ kubectl create -f pod-with-existing-pv.yaml
  pod/pod-cinder created

If we describe the pod we can see that it has now successfully mounted our
volume as /data within the container.

.. literalinclude:: pod-desc-pv.yaml
    :emphasize-lines: 22-23,48
