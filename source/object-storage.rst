##############
Object storage
##############


********
Overview
********

Object storage is a storage architecture that manages data as objects as
opposed to other approaches that may use a file hierarchy or blocks stored in
sectors and tracks.  Each object typically includes the data itself, a variable
amount of metadata, and a globally unique identifier. It is a relatively
inexpensive, scalable, highly available and simple to use. This makes it the
ideal place to persist the state of systems designed to run on the cloud or the
media assets for your web applications.

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

*********************************
Object storage from the dashboard
*********************************
Data must be stored in a container ( also referred to as a bucket ) so we need
to create at least one container prior to uploading data.  To create a new
container navigate to the "Containers" section and click "Create Container".

.. image:: _static/os-containers.png
   :align: center

|

Provide a name for the container and select the appropriate access level and
click "Create".

.. note::

  Setting "Public" level access on a container means that anyone
  with the containers URL can access the content of that container.

.. image:: _static/os-create-container.png
   :align: center

|

You should now see the newly created container. As this is a new container it
currently does not contain any data.  Click on "Upload Object" to add some
content.

.. image:: _static/os-view-containers.png
   :align: center

|

Click on the "Browse" button to select the file you wish to upload and click
"Upload Object"

.. image:: _static/os-upload-object.png
   :align: center

|

In the Containers view the Object Count has gone up to one and the size of
the container is now 69.9KB

.. image:: _static/os-data-uploaded.png
   :align: center

***********************************
Using the command line client tools
***********************************
First ensure that you have installed the correct version of the tools for your
operating system version and have sourced your OpenStack RC file
see :ref:`command-line-interface` for full details.

To view the containers currently in existence in your project:

.. code-block:: bash

    $ openstack container list
    mycontainer-1
    mycontainer-2

To view the objects stored within a container:
**openstack object list <container_name>**

.. code-block:: bash

    $ openstack object list mycontainer-1
    +-------------+
    | Name        |
    +-------------+
    | file-1.txt  |
    | image-1.png |
    +-------------+

To create a new container: **openstack container create <container_name>**

.. code-block:: bash

    $ openstack container create mynewcontainer
    +---------+----------------+----------------------------------------------------+
    | account | container      | x-trans-id                                         |
    +---------+----------------+----------------------------------------------------+
    | v1      | mynewcontainer | tx000000000000000146531-0057bb8fc9-2836950-default |
    +---------+----------------+----------------------------------------------------+


To add a new object to a container:
**openstack object create <container_name> <file_name>**

.. code-block:: bash

    $ openstack object create mynewcontainer hello.txt
    +-----------+----------------+----------------------------------+
    | object    | container      | etag                             |
    +-----------+----------------+----------------------------------+
    | hello.txt | mynewcontainer | d41d8cd98f00b204e9800998ecf8427e |
    +-----------+----------------+----------------------------------+


To delete an object: **openstack object delete <container> <object>**

.. code-block:: bash

    $ openstack object delete mynewcontainer hello.txt

To delete a container: **openstack container delete <container>**

.. note::

  this will only work if the container is empty.

.. code-block:: bash

    $ openstack container delete mycontainer-1

To delete a container and all of the objects within the container:
**openstack container delete --recursive <container>**

  $ openstack container delete --recursive mycontainer-1

**********
Using cURL
**********

To access object storage using cURL it will be necessary to provide credentials
to authenticate the request.

This can be done by sourcing a valid RC file ( see :ref:`command-line-interface` )
retrieving the account specific detail via the swift commandline tools then
exporting the required variables as shown below.

.. code-block:: bash

    $ source openstack-openrc.sh

    $ swift stat -v
     StorageURL: https://api.nz-por-1.catalystcloud.io:8443/v1/AUTH_0ef8ecaa78684c399d1d514b61698fda
                      Auth Token: 5f5a043e1bd24a8fa84b8785cca8e0fc
                         Account: AUTH_0ef8ecaa78684c399d1d514b61698fda
                      Containers: 48
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

    $ export storageURL="https://api.nz-por-1.catalystcloud.io:8443/v1/AUTH_0ef8ecaa78684c399d1d514b61698fda"
    $ export token="5f5a043e1bd24a8fa84b8785cca8e0fc"

Then run the following command to get a list of all available containers for
that tenant

.. code-block:: bash

    curl -i -X GET -H "X-Auth-Token: $token" $storageURL

You can optionally specify alternative output formats; for example to use XML
or JSON using the following syntax

.. code-block:: bash

    curl -i -X GET -H "X-Auth-Token: $token" $storageURL?format=xml
    curl -i -X GET -H "X-Auth-Token: $token" $storageURL?format=json

To view the objects within a container simply append the container name to
the cURL request

.. code-block:: bash

    curl -i -X GET -H "X-Auth-Token: $token" $storageURL/mycontainer

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
|          | 2       | https://api.cloud.catalyst.net.nz:5000/v2.0         |
+----------+---------+-----------------------------------------------------+
| nz_wlg_2 | 1       | https://api.cloud.catalyst.net.nz:8443/swift/v1     |
+----------+---------+-----------------------------------------------------+
|          | 2       | https://api.cloud.catalyst.net.nz:5000/v2.0         |
+----------+---------+-----------------------------------------------------+


Requirements
============

You need valid OpenStack credentials to interact using the Swift API.
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
with Swift via the version 2 compatible (auth) API. This version uses
the same endpoint for both regions, but you tell it which one you want
when connecting.

Before running this example ensure that you have sourced an openrc file, as
explained in :ref:`command-line-interface`.

.. code-block:: python

  #!/usr/bin/env python
  import os
  import swiftclient


  auth_username = os.environ['OS_USERNAME']
  auth_password = os.environ['OS_PASSWORD']
  auth_url = os.environ['OS_AUTH_URL']
  project_name = os.environ['OS_TENANT_NAME']
  region_name = os.environ['OS_REGION_NAME']

  options = {'tenant_name': project_name, 'region_name': region_name}


  conn = swiftclient.Connection(
          user = user,
          key = key,
          authurl = apiurl,
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
endpoint for the desired region must be used (here por).

https://api.nz-por-1.catalystcloud.io:8443/swift/v1/auth_tenant_id/container_name/object_name

.. code-block:: python

  #!/usr/bin/env python
  import swiftclient
  token = 'thetokenid'
  stourl = 'https://api.nz-por-1.catalystcloud.io:8443/v1/AUTH_<tenant_id>'

  conn = swiftclient.Connection(
          preauthtoken = token,
          preauthurl = stourl,
          insecure = False,
          auth_version = 1,
  )

  # ...rest of program is unchanged


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
