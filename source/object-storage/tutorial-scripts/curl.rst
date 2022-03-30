To access object storage using cURL it is necessary to provide credentials
to authenticate any requests you make.

This can be done by sourcing your OpenRC file and retrieving your account
specific details via the Swift command line tools; then exporting the required
variables as shown below.


.. code-block:: bash

    $ source openstack-openrc.sh

    # we then need to create a OS_STORAGE_URL environment variable.
    # To create this variable we will need to find our project ID:

    $ openstack project show <name of the project you sourced your OpenRC with>
    +-------------+----------------------------------+
    | Field       | Value                            |
    +-------------+----------------------------------+
    | description |                                  |
    | domain_id   | default                          |
    | enabled     | True                             |
    | id          | 1xxxxxxxxxxxxxxxxxxxxxxxxxxxxe54 |
    | tags        | []                               |
    +-------------+----------------------------------+

We then export this ID with the storage API for the region we are working in.
For this example we will use the Porirua region:

.. code-block:: bash

    $ export OS_STORAGE_URL="https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_1xxxxxxxxxxxxxxxxxxxxxxxxxxxxe54

    # Then we grab our auth token for later use:

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

    $ export token="5f5a043e1bd24a8fa8xxxxxxcca8e0fc"

To create a new container, use the following cURL request:

.. code-block:: bash

    curl -i -X PUT -H "X-Auth-Token: $token" $storageURL/mycontainer

Then run the following command to get a list of all available containers for
your project:

.. code-block:: bash

    curl -i -X GET -H "X-Auth-Token: $token" $storageURL

You can optionally specify alternative output formats. For example: to have XML
or JSON returned use the following syntax:

.. code-block:: bash

    curl -i -X GET -H "X-Auth-Token: $token" $storageURL?format=xml
    curl -i -X GET -H "X-Auth-Token: $token" $storageURL?format=json

To view the objects within a container, simply append the container name to
the cURL request:

.. code-block:: bash

    curl -i -X GET -H "X-Auth-Token: $token" $storageURL/mycontainer

To upload a file to your container, use the following cURL format:

.. code-block:: bash

    curl -i -T <my_object> -X PUT -H "X-Auth-Token: $token" $storageURL/mycontainer

To delete a file from your container, use this code:

.. code-block:: bash

   curl -X DELETE -H "X-Auth-Token: <token>" <storage url>/mycontainer/myobject

Finally, to delete a container you can use the following syntax.

.. Note::

   A container must be empty before you try and delete it. Otherwise the
   operation will fail.

.. code-block:: bash

    curl -X DELETE -H "X-Auth-Token: <token>" <storage url>/mycontainer
