To get the details of a specific object in a container,
run ``swift stat``, specifying the container name
and the unique object name.

.. code-block:: console

  $ swift stat test-container-mr file-1.txt
                Account: AUTH_1a2b3c4d5e1a2b3c4d5e1a2b3c4d5e1a
              Container: test-container-mr
                  Object: file-1.txt
            Content Type: text/plain
          Content Length: 14
          Last Modified: Fri, 16 Aug 2024 02:22:26 GMT
                    ETag: 746308829575e17c3331bbcb00c0898b
                  Server: nginx/1.14.0 (Ubuntu)
            X-Timestamp: 1723774945.30427
          Accept-Ranges: bytes
              X-Trans-Id: txa8dcd12eb0cd4c7caa153-0066bef7cb
  X-Openstack-Request-Id: txa8dcd12eb0cd4c7caa153-0066bef7cb
