.. _images:

###############
Types of images
###############

Catalyst provides some pre-configured operating system images to make it easier
for you to get started on the cloud.

The table below lists the images provided by Catalyst and our partners, as well
as the default user name you should use to log in to each one of them
(unless you have overwritten the default user name with cloud-init).

+---------------------+--------------------+-----------+
| Operating system    | Image name prefix  | User-name |
+=====================+====================+===========+
| Atomic Linux        | atomic-*           | centos    |
+---------------------+--------------------+-----------+
| CentOS Linux        | centos-*           | centos    |
+---------------------+--------------------+-----------+
| CoreOS Linux        | coreos-*           | core      |
+---------------------+--------------------+-----------+
| Debian Linux        | debian-*           | debian    |
+---------------------+--------------------+-----------+
| Fedora Atomic Linux | fedora-atomic-*    | fedora    |
+---------------------+--------------------+-----------+
| Ubuntu Linux        | ubuntu-*           | ubuntu    |
+---------------------+--------------------+-----------+

.. note::

  The orchestration service (Heat) changes the default user name on compute
  instances launched by it to "ec2". This is done to preserve some level of
  compatibility with AWS CloudFormation.

Our standard policy is not to modify or customise cloud images provided by
upstream Linux distributions. This gives you the assurance that you are running
software exactly as provided by the software providers.

Before using the images provided by Catalyst, you should always confirm that
they are suitable for your needs and fit for purpose. Catalyst provides them
*"as is"*, without warranty of any kind. If there is something you need to
change, you can always upload your own images, crafted the way you like, or
take a snapshot of ours and modify it the way you need.

***************************************************
How can I identify the images provided by Catalyst?
***************************************************

The images provided by Catalyst are uploaded to projectID (also known as tenant
previously)
``94b566de52f9423faxxxxxxe8c0a4a23`` and are made public. With the command line
tools, you can easily located them by running:

.. code-block:: bash

  openstack image list --long | grep 94b566de52f9423faxxxxxxe8c0a4a23

For a less verbose view filter by column name

.. code-block:: bash

  openstack image list -c ID -c Name -c Project --long | grep 94b566de52f9423faxxxxxxe8c0a4a23

*******************************
Images provided by our partners
*******************************

+------------------+-----------+-----------------+
| Operating system | User-name | Partner         |
+==================+===========+=================+
| Windows          | admin     | Silicon Systems |
+------------------+-----------+-----------------+

Before using the images provided by our Partners, you should always confirm
that they are suitable for your needs and fit for purpose. Catalyst provides
them "as is", without warranty of any kind.

*******************************
Creating your own custom images
*******************************

The OpenStack upstream documentation provides detailed instructions on how to
prepare all major operating systems to run in the cloud:
https://docs.openstack.org/image-guide/create-images-manually.html

Another method for creating custom images is to use `Packer`_. Packer is an
open source tool developed by `Hashicorp`_ for creating machine images for
multiple platforms from a single source configuration. We have made a tutorial
entitled :ref:`packer-tutorial` that demonstrates how to use Packer.

.. _Packer: https://www.packer.io/
.. _Hashicorp: https://www.hashicorp.com/
