
************************
Sharing between projects
************************

You may need to share custom images created in one project with
another project, the following section describes how to achieve this.

.. note::

 Some commands need to be issued when connected to the source project and some
 when connected to the target. Ensure you are connected to the correct project
 when issuing these commands.

While connected to the source project, find the ID of the image you wish to
share:

.. code-block:: bash

  $ openstack image show -c id -f value ubuntu1604_base_packer
  55d3168c-dbdc-40d9-8ee6-96aff4f9e741

While connected to the target project, issue the following command to find the
project ID:

.. code-block:: bash

 $ openstack configuration show -c auth.project_id -f value
 1234567892b04ed38247bab7d808e214

Now you can proceed to share the image from the source project with the target
project. While connected to the source project, issue the following command:

.. code-block:: bash

 $ openstack image add project 55d3168c-dbdc-40d9-8ee6-96aff4f9e741 1234567892b04ed38247bab7d808e214
 +------------+--------------------------------------+
 | Field      | Value                                |
 +------------+--------------------------------------+
 | created_at | 2016-11-17T02:52:24Z                 |
 | image_id   | 55d3168c-dbdc-40d9-8ee6-96aff4f9e741 |
 | member_id  | 1234567892b04ed38247bab7d808e214     |
 | schema     | /v2/schemas/member                   |
 | status     | pending                              |
 | updated_at | 2016-11-17T02:52:24Z                 |
 +------------+--------------------------------------+

Next, ensure you can see the shared image in the target project:

.. code-block:: bash

 $ glance --os-image-api-version 2 image-list --member-status pending --visibility shared
 +--------------------------------------+-----------------------------+
 | ID                                   | Name                        |
 +--------------------------------------+-----------------------------+
 | 55d3168c-dbdc-40d9-8ee6-96aff4f9e741 | ubuntu1604_base_packer      |
 +--------------------------------------+-----------------------------+

Finally, accept the image in the target project:

.. code-block:: bash

 $ glance --os-image-api-version 2 member-update 55d3168c-dbdc-40d9-8ee6-96aff4f9e741 1234567892b04ed38247bab7d808e214 accepted
 +--------------------------------------+----------------------------------+----------+
 | Image ID                             | Member ID                        | Status   |
 +--------------------------------------+----------------------------------+----------+
 | 55d3168c-dbdc-40d9-8ee6-96aff4f9e741 | 1234567892b04ed38247bab7d808e214 | accepted |
 +--------------------------------------+----------------------------------+----------+

.. note::

 The last two commands are using the older Glance client. This will be updated
 as soon as the OpenStack client supports accepting images.
