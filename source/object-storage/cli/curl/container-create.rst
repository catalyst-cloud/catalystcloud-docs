To create a new Object Storage container, run the following command,
substituting ``mycontainer-1`` for the unique name of the container:

.. code-block:: bash

  curl -i -X PUT -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL/mycontainer-1

The API should return a ``201 Created`` response.

.. code-block:: console

  $ curl -i -X PUT -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL/mycontainer-1
  HTTP/1.1 201 Created
  server: nginx/1.14.0 (Ubuntu)
  date: Fri, 16 Aug 2024 07:53:19 GMT
  content-type: text/html; charset=UTF-8
  content-length: 0
  x-trans-id: tx200ef08930e04367b5103-0066bf056f
  x-openstack-request-id: tx200ef08930e04367b5103-0066bf056f
