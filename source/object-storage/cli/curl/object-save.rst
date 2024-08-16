To return the contents of an object, run the following command,
substituting ``mycontainer-1`` for the container name
and ``file-1.txt`` for the unique object name.

.. code-block:: bash

  curl -i -X GET -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL/mycontainer-1/file-1.txt

The contents of the file, and related headers, will be output to the console.

.. code-block:: console

  $ curl -i -X GET -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL/mycontainer-1/file-1.txt
  HTTP/1.1 200 OK
  server: nginx/1.14.0 (Ubuntu)
  date: Fri, 16 Aug 2024 11:54:40 GMT
  content-type: text/plain
  content-length: 14
  x-object-meta-mtime: 1723794919.810479
  etag: 746308829575e17c3331bbcb00c0898b
  last-modified: Fri, 16 Aug 2024 11:54:35 GMT
  x-timestamp: 1723809274.03068
  accept-ranges: bytes
  x-trans-id: txa3cd4a2343c644d994397-0066bf3e00
  x-openstack-request-id: txa3cd4a2343c644d994397-0066bf3e00

  Hello, world!

If you'd like to save the object to a file use the following command instead,
setting the value of ``--output`` to the destination file to save the object to.

.. code-block:: console

  $ curl -X GET -H "X-Auth-Token: $OS_TOKEN" $OS_STORAGE_URL/mycontainer-1/file-1.txt --output file-1.txt
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                  Dload  Upload   Total   Spent    Left  Speed
  100    14  100    14    0     0     10      0  0:00:01  0:00:01 --:--:--    10

The object will now be saved to the specified file.

.. code-block:: console

  $ cat file-1.txt
  Hello, world!
