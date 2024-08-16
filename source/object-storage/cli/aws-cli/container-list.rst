Use either the ``aws s3 ls`` or the ``aws s3api list-buckets`` commands to return a list of all containers.

.. code-block:: console

  $ aws s3 ls
  2009-02-04 05:45:09 mycontainer-1
  2009-02-04 05:45:09 mycontainer-2
  $ aws s3api list-buckets
  {
      "Buckets": [
          {
              "Name": "mycontainer-1",
              "CreationDate": "2009-02-03T16:45:09+00:00"
          },
          {
              "Name": "mycontainer-2",
              "CreationDate": "2009-02-03T16:45:09+00:00"
          }
      ],
      "Owner": {
          "DisplayName": "example.com:test@example.com",
          "ID": "example.com:test@example.com"
      }
  }
