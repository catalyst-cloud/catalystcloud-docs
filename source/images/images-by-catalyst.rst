.. _images:

###############
Types of images
###############

Catalyst provides some pre-configured operating system images to make it easier
for you to get started on the cloud.

Catalyst provides only recent and supported images through the web dashboard,
out of maintenance images may still be available via API listings and can be
used for new instances when launched from the API.

The table below lists the images provided by Catalyst and our partners, as well
as the default user name you should use to log in to each one of them
(unless you have overwritten the default user name with cloud-init).

+-------------------------------------+-------------------+-----------+-------------------+
| Operating system                    | Image name prefix | User-name | Licence/IP policy |
+=====================================+===================+===========+===================+
| CentOS Linux                        | centos-*          | centos    | |centos_link|     |
+-------------------------------------+-------------------+-----------+-------------------+
| CoreOS Linux                        | coreos-*          | core      | |apache_link|     |
+-------------------------------------+-------------------+-----------+-------------------+
| Debian Linux                        | debian-*          | debian    | |debian_link|     |
+-------------------------------------+-------------------+-----------+-------------------+
| Fedora CoreOS Linux                 | fedora-coreos-*   | core      | |fedora_link|     |
+-------------------------------------+-------------------+-----------+-------------------+
| Flatcar Container Linux             | flatcar-*         | core      | |flatcar_link|    |
+-------------------------------------+-------------------+-----------+-------------------+
| Rocky Linux                         | rocky-*           | rocky     | |rocky_link|      |
+-------------------------------------+-------------------+-----------+-------------------+
| openSUSE Leap Linux                 | opensuse-leap-*   | opensuse  | |opensuse_link|   |
+-------------------------------------+-------------------+-----------+-------------------+
| SUSE Linux Enterprise Server (SLES) | suse-sles-*       | sles      | BYOS model        |
+-------------------------------------+-------------------+-----------+-------------------+
| Ubuntu Linux                        | ubuntu-*          | ubuntu    | |ubuntu_link|     |
+-------------------------------------+-------------------+-----------+-------------------+


.. admonition:: BYOS (Bring Your Own Subscription):

    After launching a new instance from a
    suse-sles-* image you will have a running instance that is unable to receive
    any software updates. In order to keep your instance up to date you will need a
    SUSE registration code and you will have to follow the registration process
    as explained by the |suse_sles_registration|; After which your instance will
    appear on the |suse_customer_center|.

.. |apache_link| raw:: html

    <a href="https://www.apache.org/licenses/LICENSE-2.0" target="_blank">www.apache.org</a>

.. |centos_link| raw:: html

    <a href="https://www.centos.org/legal/licensing-policy/#distributions" target="_blank">www.centos.org</a>

.. |debian_link| raw:: html

    <a href="https://www.debian.org/social_contract#guidelines" target="_blank">www.debian.org</a>

.. |fedora_link| raw:: html

    <a href="https://fedoraproject.org/wiki/Legal:Licenses/LicenseAgreement" target="_blank">fedoraproject.org</a>

.. |rocky_link| raw:: html

    <a href="https://rockylinux.org/licensing/" target="_blank">rockylinux.org</a>

.. |opensuse_link| raw:: html

    <a href="https://en.opensuse.org/openSUSE:License" target="_blank">opensuse.org</a>

.. |suse_sles_registration| raw:: html

    <a href="https://documentation.suse.com/sle-public-cloud/all/single-html/public-cloud/#sec-admin-suseconnect" target="_blank">SUSE Public Cloud Guide</a>

.. |suse_customer_center| raw:: html

    <a href="https://scc.suse.com/" target="_blank">SUSE Customer Center</a>

.. |ubuntu_link| raw:: html

    <a href="https://ubuntu.com/legal/intellectual-property-policy" target="_blank">ubuntu.com</a>

.. |flatcar_link| raw:: html

    <a href="https://www.flatcar.org/license" target="_blank">www.flatcar.org</a>

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

.. note::

  In particular take note that the ``ubuntu-minimal-*`` images are not
  compatible with the dashboard console as explained
  `here <https://docs.catalystcloud.nz/compute/faq.html#dashboard-console-and-ubuntu-minimal-images>`_

***************************************************
How can I identify the images provided by Catalyst?
***************************************************

The images provided by Catalyst can be identified using the projectID
(``94b566de52f9423fab80ceee8c0a4a23``) that they are shared from. Using the
command line tools, you can easily locate our shared images by running:

.. code-block:: bash

  openstack image list --long | grep 94b566de52f9423fab80ceee8c0a4a23

For a less verbose view, you can filter by column name.

.. code-block:: bash

  openstack image list -c ID -c Name -c Project --long | grep 94b566de52f9423fab80ceee8c0a4a23

*******************************
Images provided by our partners
*******************************

+------------------+-------------------+-----------+-----------------+-------------------+
| Operating system | Image name prefix | User-name | Partner         | Licence           |
+==================+===================+===========+=================+===================+
| Windows          | windows-server-*  | admin     | Silicon Systems | |windows_link|    |
+------------------+-------------------+-----------+-----------------+-------------------+
| Windows          | sql-server-*      | admin     | Silicon Systems | |sql_link|        |
+------------------+-------------------+-----------+-----------------+-------------------+

.. |windows_link| raw:: html

    <a href="https://www.microsoft.com/licensing/spur/productoffering/WindowsServer/all" target="_blank">SPUR for SPLA licensing</a>

.. |sql_link| raw:: html

    <a href="https://www.microsoft.com/licensing/spur/productoffering/sqlserver/all" target="_blank">SPUR for SPLA licensing</a>

.. note::

  SPUR: Services Provider Use Rights

  SPLA: Services Provider License Agreement

  With SPLA the Provider (here Silicon Systems) is the licensee.

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
