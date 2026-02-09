To access object storage using cURL it is necessary to provide credentials
to authenticate any requests you make.

This can be done by sourcing your OpenRC file, which will set the environment
variables you will need.

.. code-block:: bash

    $ source openstack-openrc.sh

You can view the details of you Object Storage access with the ``swift stat``
command:

.. code-block:: bash

    $ swift stat -v
     StorageURL: https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_1xxxxxxxxxxxxxxxxxxxxxxxxxxxxe54
                      Auth Token: 5f5a043e1bd24a8fa8xxxxxxcca8e0fc
                      Containers: 48
                         Account: AUTH_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                         Objects: 156
                           Bytes: 11293750551
 Containers in policy "policy-0": 48
    Objects in policy "policy-0": 156
      Bytes in policy "policy-0": 11293750551
     X-Account-Project-Domain-Id: default
                          Server: nginx/1.8.1
                     X-Timestamp: 1466047859.45584
                      X-Trans-Id: tx4bdb5d859f8c47f18b44d-00578c0e63
                    Content-Type: text/plain; charset=utf-8
                   Accept-Ranges: bytes

.. note::

    If this does not work check if your OpenRC file has set the ``OS_STORAGE_URL``
    variable.  If your OpenRC does not set the ``OS_STORAGE_URL`` then you are
    using an older OpenRC file. Please download a new OpenRC file from the dashboard.


To create a new container, use the following cURL request:

.. code-block:: bash

    curl -i -X PUT -H "X-Auth-Token: $OS_AUTH_TOKEN" "$OS_STORAGE_URL/mycontainer"

Then run the following command to get a list of all available containers for
your project:

.. code-block:: bash

    curl -i -X GET -H "X-Auth-Token: $OS_AUTH_TOKEN" "$OS_STORAGE_URL"

You can optionally specify alternative output formats. For example: to have XML
or JSON returned use the following syntax:

.. code-block:: bash

    curl -i -X GET -H "X-Auth-Token: $OS_AUTH_TOKEN" "$OS_STORAGE_URL?format=xml"
    curl -i -X GET -H "X-Auth-Token: $OS_AUTH_TOKEN" "$OS_STORAGE_URL?format=json"

To view the objects within a container, simply append the container name to
the cURL request:

.. code-block:: bash

    curl -i -X GET -H "X-Auth-Token: $OS_AUTH_TOKEN" "$OS_STORAGE_URL/mycontainer"

To upload a file to your container, use the following cURL format:

.. code-block:: bash

    curl -i -T <my_object> -X PUT -H "X-Auth-Token: $OS_AUTH_TOKEN" "$OS_STORAGE_URL/mycontainer"

To delete a file from your container, use this code:

.. code-block:: bash

   curl -X DELETE -H "X-Auth-Token: $OS_AUTH_TOKEN" "$OS_STORAGE_URL/mycontainer/myobject"

Finally, to delete a container you can use the following syntax.

.. Note::

   A container must be empty before you try and delete it. Otherwise the
   operation will fail.

.. code-block:: bash

    curl -X DELETE -H "X-Auth-Token: $OS_AUTH_TOKEN" "$OS_STORAGE_URL/mycontainer"
