############################
Object storage with the APIs
############################


===================
Using the Swift API
===================

The Swift object storage service has a feature API that is fully documented on
the OpenStack website

.. seealso::

  The features supported by the Swift can be found on the `OpenStack
  documentation
  <http://developer.openstack.org/api-ref/object-storage/>`_

API endpoints
=============

+----------+---------+--------------------------------------------------------------------------+
| Region   | Version | Endpoint                                                                 |
+==========+=========+==========================================================================+
| nz-por-1 | 1       | https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_%tenantid%  |
+----------+---------+--------------------------------------------------------------------------+
|          | 2       | https://api.nz-por-1.catalystcloud.io:5000/v2.0                          |
+----------+---------+--------------------------------------------------------------------------+
| nz_wlg_2 | 1       | https://object-storage.nz-wlg-2.catalystcloud.io:443/v1/AUTH_%tenantid%  |
+----------+---------+--------------------------------------------------------------------------+
|          | 2       | https://api.cloud.catalyst.net.nz:5000/v2.0                              |
+----------+---------+--------------------------------------------------------------------------+
| nz-hlz-1 | 1       | https://object-storage.nz-hlz-1.catalystcloud.io:443/v1/AUTH_%tenantid%  |
+----------+---------+--------------------------------------------------------------------------+
|          | 2       | https://api.nz-hlz-1.catalystcloud.io:5000/v2.0                          |
+----------+---------+--------------------------------------------------------------------------+

Requirements
============

You need valid OpenStack credentials to interact using the Swift API.
These can be obtained from the RC file (under Access &
Security, API Access, or using the command line tools).

The standard client library is Python Swiftclient. This can be installed
into your current Python environment. The example below illustrates how:

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

The code below demonstrates how you can use Swiftclient to interact
with Swift via the version 2 compatible (auth) API. This version uses
the same endpoint for both regions, but you tell it which one you want
when connecting.

Before running this example, ensure that you have sourced an openrc file, as
explained in :ref:`command-line-interface`.

.. code-block:: python

  #!/usr/bin/env python
  import os
  import swiftclient

  # Read configuration from environment variables (openstack.rc)
  auth_username = os.environ['OS_USERNAME']
  auth_password = os.environ['OS_PASSWORD']
  auth_url = os.environ['OS_AUTH_URL']
  project_name = os.environ['OS_TENANT_NAME']
  region_name = os.environ['OS_REGION_NAME']
  options = {'tenant_name': project_name, 'region_name': region_name}

  # Establish the connection with the object storage API
  conn = swiftclient.Connection(
          user = auth_username,
          key = auth_password,
          authurl = auth_url,
          insecure = False,
          auth_version = 2,
          os_options = options,
  )

  # Create a new container
  container_name = 'mycontainer'
  conn.put_container(container_name)


  # Put an object in it
  conn.put_object(container_name, 'hello.txt',
                  contents='Hello World!',
                  content_type='text/plain')

  # List all containers and objects
  for container in conn.get_account()[1]:
      cname = container['name']
      print 'container\t{0}'.format(cname)

      for data in conn.get_container(cname)[1]:
          print '\t{0}\t{1}\t{2}'.format(data['name'], data['bytes'],
          data['last_modified'])


To use the version 1 (auth) API you need to have previously authenticated,
and have remembered your token id (e.g using the keystone client). Also the
endpoint for the desired region must be used (por in this case).::

  https://object-storage.nz-por-1.catalystcloud.io:443/swift/v1/auth_tenant_id/container_name/object_name

.. code-block:: python

  #!/usr/bin/env python
  import swiftclient
  token = 'thetokenid'
  stourl = 'https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_<tenant_id>'

  conn = swiftclient.Connection(
          preauthtoken = token,
          preauthurl = stourl,
          insecure = False,
          auth_version = 1,
  )

  # ...rest of program is unchanged

.. _s3-api-documentation:

================
Using the S3 API
================

The Swift object storage service has an Amazon S3 emulation layer that supports
common S3 calls and operations.

.. seealso::

  Swift3 middleware emulates the S3 REST API on top of OpenStack. Swift is
  documented fully `here
  <http://docs.openstack.org/mitaka/config-reference/object-storage/configure-s3.html>`_.

API endpoints
=============

+----------+------------------------------------------------------+
| Region   | Endpoint                                             |
+==========+======================================================+
| nz-por-1 | https://object-storage.nz-por-1.catalystcloud.io:443 |
+----------+------------------------------------------------------+
| nz_wlg_2 | https://object-storage.nz-wlg-2.catalystcloud.io:443 |
+----------+------------------------------------------------------+
| nz-hlz-1 | https://object-storage.nz-hlz-1.catalystcloud.io:443 |
+----------+------------------------------------------------------+

Requirements
============

You need valid EC2 credentials in order to interact with the S3 compatible API.
You can obtain your EC2 credentials from the dashboard (under Access &
Security, API Access), or using the command line tools:

.. code-block:: bash

  keystone ec2-credentials-create

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
      print key.name

  # List all buckets
  for bucket in conn.get_all_buckets():
      print "{name}\t{created}".format(
          name = bucket.name,
          created = bucket.creation_date,
      )

==========
Using cURL
==========

To access object storage using cURL it will be necessary to provide credentials
to authenticate the request.

This can be done by sourcing a valid RC file ( see
:ref:`command-line-interface` ), retrieving the account specific detail via the
Swift command line tools, then exporting the required variables as shown below.

.. code-block:: bash

    $ source openstack-openrc.sh

    $ swift stat -v
     StorageURL: https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_0ef8ecaa78684c399d1d514b61698fda
                      Auth Token: 5f5a043e1bd24a8fa84b8785cca8e0fc
                      Containers: 48
                         Account: AUTH_0ef8ecaa78684c399d1d514b61698fda
                         Objects: 156
                           Bytes: 11293750551
 Containers in policy "policy-0": 48
    Objects in policy "policy-0": 156
      Bytes in policy "policy-0": 11293750551
     X-Account-Project-Domain-Id: default
                          Server: nginx/1.8.1
                     X-Timestamp: 1466047859.45584
                      X-Trans-Id: tx4bdb5d859f8c47f18b44d-00578c0e63
                    Content-Type: text/plain; charset=utf-8
                   Accept-Ranges: bytes

    $ export storageURL="https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_0ef8ecaa78684c399d1d514b61698fda"
    $ export token="5f5a043e1bd24a8fa84b8785cca8e0fc"

Then run the following command to get a list of all available containers for
that tenant:

.. code-block:: bash

    curl -i -X GET -H "X-Auth-Token: $token" $storageURL

You can optionally specify alternative output formats; for example to use XML
or JSON using the following syntax:

.. code-block:: bash

    curl -i -X GET -H "X-Auth-Token: $token" $storageURL?format=xml
    curl -i -X GET -H "X-Auth-Token: $token" $storageURL?format=json

To view the objects within a container, simply append the container name to
the cURL request:

.. code-block:: bash

    curl -i -X GET -H "X-Auth-Token: $token" $storageURL/mycontainer
