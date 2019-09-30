.. _access_to_sky-tv_cloud:

############################
Accessing the Sky TV Cloud
############################

In the previous section, we learned about the various services available to
Sky TV's cloud. Now we'll show you how to use these services via the
Sky TV dashboard.


*****************
The web dashboard
*****************

The cloud dashboard is a simple way to interact with
The Sky TV Cloud. It is only available on the internal network and can be
reached at: https://openstack.skytv.co.nz

.. _cloud-dashboard:

.. image:: .. /assets/dashboard-screenshot.png


The web dashboard is a great tool that provides easy
access to most of the services that the Sky TV Cloud provides. All of the
standard services are able to be controlled via the Dashboard. There are some
more advanced abilities that the cloud environment is capable of; however these
are discussed elsewhere in the `Catalyst Cloud
Documentation <https://docs.catalystcloud.nz/>`_

You'll notice on the left hand sidebar you are able to see all of the services
that are provided. These services have their own
guides and tutorials that are featured in the catalyst documentation.
Things such as creating compute instances, partitioning block storage or
object storage etc. Before going on to use these services,
we recommend going through the catalyst
`first instance tutorial. <https://docs.catalystcloud.nz/first-instance.html>`_


The major appeal of using the dashboard is it requires very little programming
expertise or knowledge. There is an assumed level of understanding about the
products you are trying to create or outcomes you seek to achieve, but you can
use most of the services provided by the Sky TV Cloud simply by navigating
through the dashboard.

***
FAQ
***

I cannot connect to the dashboard
=================================

The dashboard is only available while connected to the Sky-TV network.
If you are having issues with connecting to the dashboard, contact your local
systems administrator.

Failed to delete resource
=========================

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


Failed to create snapshot
=========================

Snapshots of instances that were previously created from snapshots need to be
booted with the correct options in order to allow further bootable images
to be created.

The default option (on the Dashboard, Compute -> Images -> Launch) to launch
an instance is to 'boot from image'. This is correct, *unless* the original
instance also created a new volume at start-up (the instance will boot, but a
snapshot won't be able to be created without additional metadata).

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
