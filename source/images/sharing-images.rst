###############################
Sharing images between projects
###############################

In the event that you need to share custom images created in one project across
on or multiple other projects, the following section describes how you are able
to share your images using openstack API commands.

.. note::

 Some commands need to be issued when connected to the source project and some
 when connected to the target. Ensure you are connected to the correct project
 when issuing these commands.

After :ref:`sourcing an openRC file<source-rc-file>` from the project that
houses the image you want to share. We will call this the *source project*
going forward. We then need to find the ID of our image.

.. code-block:: bash

  $ openstack image show -c id -f value ubuntu1604_base_packer
  55d3168c-dbdc-40d9-8ee6-xxxxxxxxxxxx
  # we will then export this ID for use later on (this will only be stored on your source project command line)
  $ export image_ID=55d3168c-dbdc-40d9-8ee6-xxxxxxxxxxxxs

While connected to the target project, issue the following command to find the
project ID:

.. code-block:: bash

 $ openstack configuration show -c auth.project_id -f value
 1234567892b04ed3xxxxxxb7d808e214
 # we can export this ID as an environment variable as well for use later
 $ export target_project_ID=1234567892b04ed3xxxxxxb7d808e214

Next we will need to change the visibility status of our image from **private**
to **shared**. By default images are created with their visibility set to
private so we will need to update our image's visibility in order to be able to
transfer it successfully. While connected to your source project use the
following to set your images visibility to shared:

.. code-block:: bash

  $ openstack image set $image_ID --shared

Now you can proceed to share the image from the source project with the target
project. While connected to the source project, issue the following command:

.. code-block:: bash

 $ openstack image add project $image_ID $target_project_ID
 +------------+--------------------------------------+
 | Field      | Value                                |
 +------------+--------------------------------------+
 | created_at | 2016-11-17T02:52:24Z                 |
 | image_id   | 55d3168c-dbdc-40d9-8ee6-xxxxxxxxxxxx |
 | member_id  | 1234567892b04ed3xxxxxxb7d808e214     |
 | schema     | /v2/schemas/member                   |
 | status     | pending                              |
 | updated_at | 2016-11-17T02:52:24Z                 |
 +------------+--------------------------------------+

Next, ensure you can see the shared image in the target project. We use the
`--member-status` parameter for this, so that we can see the images we have
pending approval for transfer:

.. code-block:: bash

 # If you have more than one image you are trying to transfer you can use  "| grep" to filter the images returned in the following command.
 $ openstack image list --member-status pending | grep 55d3168c-dbdc-40d9-8ee6-xxxxxxxxxxxx
 | 55d3168c-dbdc-40d9-8ee6-xxxxxxxxxxxx | ubuntu1604_base_packer      |


Finally, accept the image in the target project:

.. code-block:: bash

 $ openstack image set 55d3168c-dbdc-40d9-8ee6-xxxxxxxxxxxx --accept
 $ openstack image list | grep 55d3168c-dbdc-40d9-8ee6-xxxxxxxxxxxx
 | 55d3168c-dbdc-40d9-8ee6-xxxxxxxxxxxx | ubuntu1604_base_packer      |

Unsharing an image
==================

In the event that you wish to remove a shared image from a project you are able
to rescind the permissions from the target project. While connected to your
source project you can run the following command:

.. code-block:: bash

  # substitute the variables below for the respective IDs we used in the previous section.
  $ openstack image remove project $image_ID $target_project_ID

Once this is done you should now longer be able to see the image on the target
project:

.. code-block:: bash

  $ openstack image show $image_ID
  No Image found for 55d3168c-dbdc-40d9-8ee6-xxxxxxxxxxxx
