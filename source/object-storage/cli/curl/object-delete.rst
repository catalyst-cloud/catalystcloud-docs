To delete an object from a container, run the following command,
substituting ``mycontainer-1`` for the container name
and ``file-1.txt`` for the unique object name:

.. code-block:: bash

  curl -i -X DELETE -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL/mycontainer-1/file-1.txt

The API should return a ``204 No Content`` response.

.. code-block:: console

  $ curl -i -X DELETE -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL/mycontainer-1/file-1.txt
  HTTP/1.1 204 No Content
  server: nginx/1.14.0 (Ubuntu)
  date: Fri, 16 Aug 2024 12:19:49 GMT
  content-type: text/html; charset=UTF-8
  x-trans-id: tx89613718a38a4a2db45b4-0066bf43e5
  x-openstack-request-id: tx89613718a38a4a2db45b4-0066bf43e5
