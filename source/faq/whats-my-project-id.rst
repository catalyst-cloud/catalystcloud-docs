############################
How do I find my project ID?
############################

There are a number of ways to find your project ID.

Using the Dashboard
-------------------
The project ID can be found in the ``User Credentials`` popup. This can be
accessed by clicking on `+View Credentials`_ in the `API Access`_ tab under
`Access & Security`_.

.. _+View Credentials: https://dashboard.cloud.catalyst.net.nz/project/access_and_security/api_access/view_credentials/
.. _Access & Security: https://dashboard.cloud.catalyst.net.nz/project/access_and_security/
.. _API Access: https://dashboard.cloud.catalyst.net.nz/project/access_and_security/?tab=access_security_tabs__api_access_tab

Using the Command Line
----------------------

If you are using the OpenStack command line tools you have most likely sourced
an openrc file, as explained in :ref:`command-line-interface`. If this is the
case then you can find your project ID by issuing the following command:

.. code-block:: bash

 $ echo $OS_TENANT_ID
 1234567892b04ed38247bab7d808e214

Alternatively you can use the ``openstack configuration show`` command:

.. code-block:: bash

 $ openstack configuration show -c auth.project_id -f value
 1234567892b04ed38247bab7d808e214
