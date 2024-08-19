To view the details for a specific container,
use ``swift stat`` followed by the container name.

.. code-block:: console

  $ swift stat mycontainer-1
                Account: AUTH_1a2b3c4d5e1a2b3c4d5e1a2b3c4d5e1a
              Container: mycontainer-1
                Objects: 2
                  Bytes: 2453477
                Read ACL:
              Write ACL:
                Sync To:
                Sync Key:
                  Server: nginx/1.14.0 (Ubuntu)
            Content-Type: text/plain; charset=utf-8
            X-Timestamp: 1723782306.51716
          Last-Modified: Fri, 16 Aug 2024 04:25:07 GMT
          Accept-Ranges: bytes
        X-Storage-Policy: nz--o1--mr-r3
                    Vary: Accept
              X-Trans-Id: tx9abcd62799254073ad405-0066bef1b2
  X-Openstack-Request-Id: tx9abcd62799254073ad405-0066bef1b2
