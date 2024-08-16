To list all existing containers on your project, run the following command:

.. code-block:: bash

  curl -i -X GET -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL

The output will be as shown below. A number of related headers are also shown with useful information.

.. code-block:: console

  $ curl -i -X GET -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL
  HTTP/1.1 200 OK
  server: nginx/1.14.0 (Ubuntu)
  date: Fri, 16 Aug 2024 07:56:23 GMT
  content-type: text/plain; charset=utf-8
  content-length: 86
  x-account-container-count: 2
  x-account-object-count: 4
  x-account-bytes-used: 1908270
  x-timestamp: 1692919874.18591
  x-account-storage-policy-nz--o1--mr-r3-container-count: 2
  x-account-storage-policy-nz--o1--mr-r3-object-count: 4
  x-account-storage-policy-nz--o1--mr-r3-bytes-used: 1908270
  x-account-storage-policy-nz-hlz-1--o1--sr-r3-container-count: 0
  x-account-storage-policy-nz-hlz-1--o1--sr-r3-object-count: 0
  x-account-storage-policy-nz-hlz-1--o1--sr-r3-bytes-used: 0
  x-account-storage-policy-nz-por-1--o1--sr-r3-container-count: 0
  x-account-storage-policy-nz-por-1--o1--sr-r3-object-count: 0
  x-account-storage-policy-nz-por-1--o1--sr-r3-bytes-used: 0
  x-account-storage-policy-nz-wlg-2--o1--sr-r3-container-count: 0
  x-account-storage-policy-nz-wlg-2--o1--sr-r3-object-count: 0
  x-account-storage-policy-nz-wlg-2--o1--sr-r3-bytes-used: 0
  accept-ranges: bytes
  x-account-project-domain-id: default
  vary: Accept
  x-trans-id: tx3416961483f74f3b836d6-0066bf0627
  x-openstack-request-id: tx3416961483f74f3b836d6-0066bf0627

  mycontainer-1
  mycontainer-2

Responses can also be formatted in JSON or XML.

.. code-block:: bash

  curl -X GET -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL?format=json
  curl -X GET -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL?format=xml
