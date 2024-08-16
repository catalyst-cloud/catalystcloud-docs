To delete a container, run the following command,
substituting ``mycontainer-1`` for the unique name of the container:

.. code-block:: bash

  curl -i -X DELETE -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL/mycontainer-1

The API should return a ``204 No Content`` response.

.. code-block:: console

  $ curl -i -X DELETE -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL/mycontainer-1
  HTTP/1.1 204 No Content
  server: nginx/1.14.0 (Ubuntu)
  date: Fri, 16 Aug 2024 08:09:00 GMT
  content-type: text/html; charset=UTF-8
  x-trans-id: tx813318cbeb404fafbacec-0066bf091c
  x-openstack-request-id: tx813318cbeb404fafbacec-0066bf091c

.. note::

  Using this command you can only delete **empty** containers.
  If the container has objects in it, delete the objects first.
