To upload a new object to a container, run ``openstack object create``,
run the following command.

In the URL, substitute ``mycontainer-1`` for the target container,
and ``file-1.txt`` for the unique name for the object to create.
The value of ``--upload-file`` should be the path of the file to upload.

.. code-block:: bash

  curl -i -X PUT -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL/mycontainer-1/file-1.txt --upload-file ./file-1.txt

If the upload is successful, you will receive a ``201 Created`` response,
along with an ``etag`` header containing the generated ETag for the object.

.. code-block:: console

  $ curl -i -X PUT -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL/mycontainer-1/file-1.txt --upload-file ./file-1.txt
  HTTP/1.1 100 Continue

  HTTP/1.1 201 Created
  server: nginx/1.14.0 (Ubuntu)
  date: Fri, 16 Aug 2024 12:06:36 GMT
  content-type: text/html; charset=UTF-8
  content-length: 0
  etag: 746308829575e17c3331bbcb00c0898b
  last-modified: Fri, 16 Aug 2024 12:06:37 GMT
  x-trans-id: tx9a26f494bfc148a8a5ab6-0066bf40cb
  x-openstack-request-id: tx9a26f494bfc148a8a5ab6-0066bf40cb
