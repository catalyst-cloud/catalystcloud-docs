##########################################
Object storage with the command line tools
##########################################


========
Overview
========

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


===================================
Using the command line client tools
===================================

First, ensure that you have installed the correct version of the tools for your
operating system version and have sourced your OpenStack RC file
see :ref:`command-line-interface` for full details.

To view the containers currently in existence in your project:

.. code-block:: bash

    $ openstack container list
    mycontainer-1
    mycontainer-2

To view the objects stored within a container:
``openstack object list <container_name>``

.. code-block:: bash

    $ openstack object list mycontainer-1
    +-------------+
    | Name        |
    +-------------+
    | file-1.txt  |
    | image-1.png |
    +-------------+

To create a new container: ``openstack container create <container_name>``

.. code-block:: bash

    $ openstack container create mynewcontainer
    +---------+----------------+----------------------------------------------------+
    | account | container      | x-trans-id                                         |
    +---------+----------------+----------------------------------------------------+
    | v1      | mynewcontainer | tx000000000000000146531-0057bb8fc9-2836950-default |
    +---------+----------------+----------------------------------------------------+


To add a new object to a container:
``openstack object create <container_name> <file_name>``

.. code-block:: bash

    $ openstack object create mynewcontainer hello.txt
    +-----------+----------------+----------------------------------+
    | object    | container      | etag                             |
    +-----------+----------------+----------------------------------+
    | hello.txt | mynewcontainer | d41d8cd98f00b204e9800998ecf8427e |
    +-----------+----------------+----------------------------------+


To delete an object: ``openstack object delete <container> <object>``

.. code-block:: bash

    $ openstack object delete mynewcontainer hello.txt

To delete a container: ``openstack container delete <container>``

.. note::

  this will only work if the container is empty.

.. code-block:: bash

    $ openstack container delete mycontainer-1

To delete a container and all of the objects within the container:
``openstack container delete --recursive <container>``

.. code-block:: bash

  $ openstack container delete --recursive mycontainer-1
