To view the objects stored within a container, run the following command,
substituting ``mycontainer-1`` for the container name:

.. code-block:: bash

  curl -i -X GET -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL/mycontainer-1

The body of the response will contain a list of the objects stored within the
container, one per line.
A number of related headers are also included with useful information.

.. code-block:: console

  $ curl -i -X GET -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL/mycontainer-1
  HTTP/1.1 200 OK
  server: nginx/1.14.0 (Ubuntu)
  date: Fri, 16 Aug 2024 08:02:19 GMT
  content-type: text/plain; charset=utf-8
  content-length: 22
  x-container-object-count: 2
  x-container-bytes-used: 28
  x-timestamp: 1723782306.51716
  last-modified: Fri, 16 Aug 2024 07:55:28 GMT
  accept-ranges: bytes
  x-storage-policy: nz--o1--mr-r3
  vary: Accept
  x-trans-id: tx3ca25d3285344a0188612-0066bf078a
  x-openstack-request-id: tx3ca25d3285344a0188612-0066bf078a

  file-1.txt
  image-1.png

Responses can also be formatted in JSON or XML.

.. code-block:: bash

  curl -X GET -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL/mycontainer-1?format=json
  curl -X GET -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL/mycontainer-1?format=xml
