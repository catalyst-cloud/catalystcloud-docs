The Swift object storage service has an Amazon S3 emulation layer that supports
common S3 calls and operations.

.. seealso::

  Swift3 middleware emulates the S3 REST API on top of OpenStack. Swift is
  documented fully `here
  <http://docs.openstack.org/mitaka/config-reference/object-storage/configure-s3.html>`_.

.. raw:: html

    <h4> API endpoints </h4>

+----------+------------------------------------------------------+
| Region   | Endpoint                                             |
+==========+======================================================+
| nz-por-1 | https://object-storage.nz-por-1.catalystcloud.io:443 |
+----------+------------------------------------------------------+
| nz_wlg_2 | https://object-storage.nz-wlg-2.catalystcloud.io:443 |
+----------+------------------------------------------------------+
| nz-hlz-1 | https://object-storage.nz-hlz-1.catalystcloud.io:443 |
+----------+------------------------------------------------------+

.. raw:: html

    <h4> Requirements </h4>

You need valid EC2 credentials in order to interact with the S3 compatible API.
You can obtain your EC2 credentials from the dashboard (under Access &
Security, API Access), or using the command line tools:

.. code-block:: bash

  $ openstack ec2 credentials create

If you are using boto to interact with the API, you need boto installed on your
current Python environment. The example below illustrates how to install boto
on a virtual environment:

.. code-block:: bash

  # Make sure you have pip and virtualenv installed
  sudo apt-get install python-pip python-virtualenv

  # Create a new virtual environment for Python and activate it
  virtualenv venv
  source venv/bin/activate

  # Install Amazon's boto library on your virtual environment
  pip install boto

.. raw:: html

    <h4> Sample code </h4>


The code below demonstrates how you can use boto to interact with the S3
compatible API.

.. code-block:: python

  #!/usr/bin/env python

  import boto
  import boto.s3.connection

  access_key = 'fffff8888fffff888ffff'
  secret = 'bbbb5555bbbb5555bbbb555'
  api_endpoint = 'object-storage.nz-por-1.catalystcloud.io'
  port = 443
  mybucket = 'mytestbucket'

  conn = boto.connect_s3(aws_access_key_id=access_key,
                    aws_secret_access_key=secret,
                    host=api_endpoint, port=port,
                    calling_format=boto.s3.connection.OrdinaryCallingFormat())

  # Create new bucket if not already existing
  bucket = conn.lookup(mybucket)
  if bucket is None:
      bucket = conn.create_bucket(mybucket)

  # Store hello world file in it
  key = bucket.new_key('hello.txt')
  key.set_contents_from_string('Hello World!')

  # List all files in test bucket
  for key in bucket.list():
      print (key.name)

  # List all buckets
  for bucket in conn.get_all_buckets():
      print ("{name}\t{created}".format(
          name = bucket.name,
          created = bucket.creation_date,
      ))
