#################################
Object storage from the dashboard
#################################

********
Overview
********

Object storage is a web service to store and retrieve data from anywhere using
native web protocols. Each object typically includes the data itself, a
variable amount of metadata, and a globally unique identifier. All object
storage operations are done via a modern and easy to use REST API.

Object storage is the primary storage for modern (cloud-native) web and mobile
applications, as well as a place to archive data or a target for backup and
recovery. It is cost-effective, highly durable, highly available, scalable and
simple to use storage solution.

Our object storage service is a fully distributed storage system, with no
single points of failure and scalable to the exabyte level. The system is
self-healing and self-managing. Data stored in object storage is asynchronously
replicated to preserve three replicas of the data on different cloud regions.
The system runs frequent CRC checks to protect data from soft corruption. The
corruption of a single bit can be detected and automatically restored to a
healthy state. The loss of a region, server or a disk leads to the data being
quickly recovered from another disk, server or region.

*******************
Using the dashboard
*******************

Data must be stored in a container (also referred to as a bucket) so we need
to create at least one container prior to uploading data. To create a new
container, navigate to the "Containers" section and click "Create Container".

.. image:: ../_static/os-containers.png
   :align: center

Provide a name for the container and select the appropriate access level and
click "Create".

.. note::

  Setting "Public" level access on a container means that anyone
  with the container's URL can access the content of that container.

.. image:: ../_static/os-create-container.png
  :align: center

You should now see the newly created container. As this is a new container, it
currently does not contain any data. Click on "Upload Object" to add some
content.

.. image:: ../_static/os-view-containers.png
   :align: center

Click on the "Browse" button to select the file you wish to upload and click
"Upload Object"

.. image:: ../_static/os-upload-object.png
   :align: center

In the Containers view the Object Count has gone up to one and the size of
the container is now 69.9KB

.. image:: ../_static/os-data-uploaded.png
   :align: center
