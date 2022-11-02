###
FAQ
###

*****************************************
I cannot connect to the dashboard or APIs
*****************************************

The dashboard and APIs are open to the public Internet, however various mechanisms
are in place to protect the service. If you are having difficulty accessing the
dashboard or APIs, please contact us.


*************************
Failed to delete resource
*************************

Delete errors are often caused by dependencies preventing you from deleting a
resource. For example:

* Trying to delete a volume, when a snapshot depends on it.
* Trying to delete a network, when a port is still connected to it (such as a
  router's interface)

Error messages provided by the dashboard tend to be brief and sometimes lack
specific details about what caused the error. If you are repeatedly being
presented with a delete error, please check whether resource dependencies
could be the cause. The command line tools are designed to be more verbose
and tend to give more information about what is causing a delete error.

*************************
Failed to create snapshot
*************************

Snapshots of instances that were previously created from snapshots need to be
booted with the correct options in order to allow further bootable images
to be created.

The default option (on the Dashboard, Compute -> Images -> Launch) to launch
an instance is to 'boot from image'. This is correct, *unless* the original
instance also created a new volume at start-up (the instance will boot, but not
itself be able to take a snapshot without additional metadata).

In the latter case, where the initial instance was created along with a new
volume, the snapshot needs to be booted with the Instance Boot Source set to
"Boot from snapshot (creates a new volume)".

An instance accidentally booted with incorrect options can be corrected by
either of the following:

* Shut down the existing instance and re-launch it as above.
* Alternatively, use the Glance API client to update the metadata
  for the image that backs the existing instance:

.. code-block:: bash

 $ glance image-update <image-name-or-id> --container-format bare --disk-format raw
