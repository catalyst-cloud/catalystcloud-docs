.. _cloud-dashboard:

#########
Dashboard
#########


The web dashboard is a simple way to interact with The Sky TV Cloud. It can
be found at https://openstack.skytv.co.nz.

.. image:: assets/dashboard_screenshot.png

Our web dashboard is a great tool that provides easy
access to most of the services that the Sky TV Cloud provides. All of the
standerd services are able to be controlled via the Dashboard. There are some
more advanced abilities that the cloud environment is capable of; however these
require the use of the :ref:`CLI <command-line-interface>` or interacting with
our API's directly; which is discussed elsewhere in the :ref:`Catalyst Cloud
Documentation
<https://docs.catalystcloud.nz/>`

As previously mention in the getting started section, you can see most of the
services provided on the left hand sidebar. These services have their own
guides and tutorials that are featured later on. Things such
as creating compute instances, partitioning block storage or object storage
etc. Before going on to use these services, we recommend going through our
:ref:`first instance tutorial. <launch-first-instance>`

Some of the dashboard functionality beyond these services are in the
buttons along the top bar. From left to right, these:

* Let you select which project you are working on
* Change what region your operating in
* Access our support functions
* Change accounts or access your account settings.

The major appeal of using the dashboard is it requires very little programming
expertise or knowledge. There is an assumed level of understanding about the
products you are trying to create or outcomes you seek to achieve, but you can
use most of the services provided by the Sky TV simply by navigating
through the dashboard.

Another  major advantage to the web dashboard is that it is accessible from any
IP address, making it a quick way to perform tasks on the Sky TV while
you're away from your normal work station.


.. note::

  When a new feature is introduced to our cloud, it is first exposed via a REST
  API, followed by the command line clients and finally the web dashboard. It
  usually takes 3-6 months for it to reach the dashboard, but it can be used
  well ahead of that via the API and command line clients.


***
FAQ
***

I cannot connect to the dashboard or APIs
=========================================

The dashboard is open to the public Internet, however various mechanisms are in
place to protect the service. If you are having difficulty accessing the
dashboard, please contact us.

Our APIs are currently exposed to customers only (not open to the
public Internet). We ask for your IP address during sign up, so we can provide
you with access to the APIs. If your IP address has changed or you would like
to add more IPs, please contact us to change the information provided.

Please note you can access the Sky TV from a dynamic IP by proxying
your connectivity through one of your cloud instances. When it comes to your
compute instances, you are in full control of your own firewall rules and can
expose them to the Internet.

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
instance also created a new volume at start-up (the instance will boot, but not
itself be able to be snapshotted without additional metadata).

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
