##############
Object storage
##############


********
Overview
********

Our object storage service is provided by a fully distributed storage system,
with no single points of failure and scalable to the exabyte level. The system
is self-healing and self-managing. Data is seamlessly replicated on three
different servers, making it fault tolerant and resilient. The loss of a node
or a disk leads to the data being quickly recovered on another disk or node.

Data stored on object storage is currently replicated on three different nodes
within the same region. However, with the introduction of the Porirua region
and the upcoming Auckland region, object storage will be soon replicated across
regions, providing even greater durability for your data.

The system runs frequent CRC checks to protect data from soft corruption. The
corruption of a single bit can be detected and automatically restored to a
healthy state.

Object storage is scalable, highly available and simple to use. This makes it
the ideal place to persist the state of systems designed to run on the cloud or
the media assets for your web applications.


*********
Swift API
*********

The object storage service has a Swift emulation layer that supports common
Swift calls and operations.

.. seealso::

  The features supported by the Swift emulation layer can be found at
  http://ceph.com/docs/master/radosgw/swift/.

API endpoints
=============

+----------+---------+-----------------------------------------------------+
| Region   | Version | Endpoint                                            |
+==========+=========+=====================================================+
| nz-por-1 | 1       | https://api.nz-por-1.catalystcloud.io:8443/swift/v1 |
+----------+---------+-----------------------------------------------------+
|          | 2       | https://api.api.nz-por-1.catalystcloud.io:5000/v2.0 |
+----------+---------+-----------------------------------------------------+
| nz_wlg_2 | 1       | https://api.cloud.catalyst.net.nz:8443/swift/v1     |
+----------+---------+-----------------------------------------------------+
|          | 2       | https://api.cloud.catalyst.net.nz:5000/v2.0         |
+----------+---------+-----------------------------------------------------+


Requirements
============

You need valid Openstack credentials to interact using the Swift API.
These can be obtained from the RC file (under Access &
Security, API Access, or using the command line tools).

The standard client library is Python Swiftclient. This can be installed
into your current Python environment. The example below illustrates:

.. code-block:: bash

  # Make sure you have pip and virtualenv installed
  sudo apt-get install python-pip python-virtualenv

  # Create a new virtual environment for Python and activate it
  virtualenv venv
  source venv/bin/activate

  # Install Python Swiftclient library on your virtual environment
  pip install python-swiftclient

Sample code
===========

The code below demonstrates how you can use swiftclient to interact
with the Swift version 2 compatible API.

.. code-block:: python

  #!/usr/bin/env python
  import swiftclient
  user = 'tenant:username'
  key = 'thepassword'
  apiurl = 'https://api.cloud.catalyst.net.nz:5000/v2.0'

  conn = swiftclient.Connection(
          user = user,
          key = key,
          authurl = apiurl,
          insecure = False,
          auth_version = 2,
  )

  # Create a new container
  container_name = 'con0'
  conn.put_container(container_name)

  # Put an object in it
  conn.put_object(container_name, 'hello.txt',
                  contents='Some text',
                  content_type='text/plain')

  # List all containers and objects
  for container in conn.get_account()[1]:
      cname = container['name']
      print 'container\t{0}'.format(cname)

      for data in conn.get_container(cname)[1]:
          print '\t{0}\t{1}\t{2}'.format(data['name'], data['bytes'], data['last_modified'])


******
S3 API
******

The object storage service has an Amazon S3 emulation layer that supports
common S3 calls and operations.

.. seealso::

  The features supported by the S3 emulation layer can be found at
  http://ceph.com/docs/master/radosgw/s3/.

API endpoints
=============

+----------+-----------------------------------------------------+
| Region   | Endpoint                                            |
+==========+=====================================================+
| nz-por-1 | https://api.nz-por-1.catalystcloud.io:8443          |
+----------+-----------------------------------------------------+
| nz_wlg_2 | https://api.cloud.catalyst.net.nz:8443              |
+----------+-----------------------------------------------------+

Requirements
============

You need valid EC2 credentials in order to interact with the S3 compatible API.
You can obtain your EC2 credentials from the dashboard (under Access &
Security, API Access), or using the command line tools:

.. code-block:: bash

  keystone ec2-credentials-create

If you are using boto to interact with the API, you need boto installed on your
current Python environment. The example below illustrates how intall boto on a
virtual environment:

.. code-block:: bash

  # Make sure you have pip and virtualenv installed
  sudo apt-get install python-pip python-virtualenv

  # Create a new virtual environment for Python and activate it
  virtualenv venv
  source venv/bin/activate

  # Install Amazon's boto library on your virtual environment
  pip install boto

Sample code
===========

The code below demonstrates how you can use boto to interact with the S3
compatible API.

.. code-block:: python

  #!/usr/bin/env python

  import boto
  import boto.s3.connection

  access_key = 'fffff8888fffff888ffff'
  secret = 'bbbb5555bbbb5555bbbb555'
  api_endpoint = 'api.cloud.catalyst.net.nz'
  port = 8443
  bucket = 'mytestbucket'

  conn = boto.connect_s3(aws_access_key_id=access_key,
                         aws_secret_access_key=secret,
                         host=api_endpoint, port=port,
                         calling_format=boto.s3.connection.OrdinaryCallingFormat())

  # Create new bucket
  bucket = conn.create_bucket(bucket)

  # Store hello world file in it
  key = bucket.new_key('hello.txt')
  key.set_contents_from_string('Hello World!')

  # List all files in test bucket
  for key in bucket.list():
      print key.name

  # List all buckets
  for bucket in conn.get_all_buckets():
      print "{name}\t{created}".format(
          name = bucket.name,
          created = bucket.creation_date,
      )
