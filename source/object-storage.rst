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

Our object storage is provided by the native OpenStack object storage, known
as Swift.

Our object storage service is backed by a fully distributed storage system,
with no single points of failure and scalable to the exabyte level. The system
is self-healing and self-managing. Data is seamlessly replicated on three
different servers, making it fault tolerant and resilient. The loss of a node
or a disk leads to the data being quickly recovered on another disk or node.

Data stored on object storage is automatically replicated on to the other
Catalyst Cloud regions, currently, Porirua and Wellington.  Auckland will be
available soon and replication between Auckland, Porirua and Wellington will
happen automatically.  Having object storage replicated across three
geogaphically disparate regions will provide even greater durability for
your data.

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

This can be done by sourcing a valid RC file ( see
:ref:`command-line-interface` ) retrieving the account specific detail via the
swift commandline tools then exporting the required variables as shown below.

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

The Swift object storage service has a feature API that is fully documented on
the OpenStack website

.. seealso::

  The features supported by the Swift can be found at
  http://developer.openstack.org/api-ref/object-storage/

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

The Swift object storage service has an Amazon S3 emulation layer that supports
common S3 calls and operations.

.. seealso::

  The features supported by the S3 emulation layer can be found at
  https://wiki.openstack.org/wiki/Swift/APIFeatureComparison

  In addition, Swift3 middleware emulates the S3 REST API on top of OpenStack
  Swift is docmented fully at
  http://docs.openstack.org/mitaka/config-reference/object-storage/configure-s3.html

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

*****************
Object Versioning
*****************
This provides a means by which multiple versions of your content can be stored
allowing for recovery from unintended overwrites.

First we need to create an archive container to store the older versions of our
objects

.. code-block:: bash

  $ curl -i -X PUT -H "X-Auth-Token: $token" $storageURL/archive

Now we can create a container to hold our objects. We must include the
``X-Versions-Location`` header which defines the container that holds the
previous versions of your objects.

.. code-block:: bash

  $ curl -i -X PUT -H "X-Auth-Token: $token" -H 'X-Versions-Location: archive' $storageURL/my-container
  HTTP/1.1 201 Created
  Server: nginx/1.10.1
  Date: Mon, 05 Dec 2016 23:50:00 GMT
  Content-Type: text/html; charset=UTF-8
  Content-Length: 0
  X-Trans-Id: txe6d2f4e289654d02a7329-005845fd28

Once the ``X-Versions-Location`` header has been applied to the container any
changes to objects in the container automatically result in a copy of the
original object being placed in the archive container. The backed up version
will have the following format:

.. code-block:: bash

  <length><object_name>/<timestamp>

Where <length> is the length of the object name ( as a 3 character zero padded
hex number ), <object_name> is the original object name and <timestamp> is the
unix timestamp of the original file creation.

<length> and <object_name> are then combined to make a new container
(pseudo-folder in the dashboard) with the backed up object stored within using
the timestamp as it's name.

.. note::

  You must UTF-8-encode and then URL-encode the container name before you
  include it in the X-Versions-Location header.

If we list out current containers we can see that we now have 2 empty
containers.

.. code-block:: bash

  $ openstack container list --long
  +--------------+-------+-------+
  | Name         | Bytes | Count |
  +--------------+-------+-------+
  | archive      |     0 |     0 |
  | my-container |     0 |     0 |
  +--------------+-------+-------+

If we upload a sample file in to my-container we can see the confirmation of
this operation which includes the etag, which is an MD5 hash of the objects
contents.

.. code-block:: bash

  $ openstack object create my-container file1.txt
  +-----------+--------------+----------------------------------+
  | object    | container    | etag                             |
  +-----------+--------------+----------------------------------+
  | file1.txt | my-container | 2767104ea585e1a98a23c52addeeae4a |
  +-----------+--------------+----------------------------------+

Now if the original file is modified and uploaded to the same container, we get
a successful confirmation except this time we get a new etag as the contents of
the file have changed.

.. code-block:: bash

  $ openstack object create my-container file1.txt
  +-----------+--------------+----------------------------------+
  | object    | container    | etag                             |
  +-----------+--------------+----------------------------------+
  | file1.txt | my-container | 9673f4c3efc2ee8dd9edbc2ba60c76c4 |
  +-----------+--------------+----------------------------------+

If we show the containers again we can see now that even though we only
uploaded the file into my-container we now also have a file present in the
archive container.

.. code-block:: bash

  $ os container list --long
  +--------------+-------+-------+
  | Name         | Bytes | Count |
  +--------------+-------+-------+
  | archive      |    70 |     1 |
  | my-container |    73 |     1 |
  +--------------+-------+-------+

Further investigation of the archive container reveals that we have a new
object, that was created automatically and named in accordance with the
convention outlined above

.. code-block:: bash

  $ openstack object list archive
  +-------------------------------+
  | Name                          |
  +-------------------------------+
  | 009file1.txt/1480982072.29403 |
  +-------------------------------+

*************
Temporary URL
*************
This a means by which a temporary URL can be generated to allow unauthenticated
access to the Swift object at the given path. The access is via the given HTTP
method (e.g. GET, PUT) and is valid for the number of seconds provided when the
URL is created.

The expiry time can be expressed as valid for the given number of seconds from
now or if the optional --absolute argument is provided, seconds is instead
interpreted as a Unix timestamp at which the URL should expire.

The syntax for the tempurl creation command is

**swift tempurl [command-option] method seconds path key**

This generates  a  temporary URL allowing unauthenticated access to the Swift
object at the given path, using the given HTTP method, for the given number of
seconds, using the given TempURL key. If optional --absolute argument is
provided, seconds is instead interpreted as a Unix timestamp at which the URL
should expire.

**Example:**

.. code-block:: bash

  swift tempurl GET $(date -d "Jan 1 2017" +%s) /v1/AUTH_foo/bar_container/quux.md my_secret_tempurl_key --absolute

- sets the expiry using the absolute method to be Jan 1 2017
- for the object : quux.md
- in the nested container structure : bar_container/quux.mdbar_container/
- with key : my_secret_tempurl_key

Creating Temporary URLs in the Catalyst Cloud
=============================================
At the time of writing the only method currently available for the creation of
temporary URLs is using the command line tools.

Firstly we need to associate a secret key with our object store account.

.. code-block:: bash

  $ openstack object store account set --property Temp-Url-Key='testkey'

You can then confirm the details of the key.

.. code-block:: bash

  $ openstack object store account show
  +------------+---------------------------------------+
  | Field      | Value                                 |
  +------------+---------------------------------------+
  | Account    | AUTH_b24e9ee3447e48eab1bc99cb894cac6f |
  | Bytes      | 128                                   |
  | Containers | 4                                     |
  | Objects    | 8                                     |
  | properties | Temp-Url-Key='testkey'                |
  +------------+---------------------------------------+

Then using the syntax outlined above you can create a temporary URL to access
an object residing in the object store.

We will create a URL that will be valid for 600 seconds and provide access to
the object "file2.txt" that is located in the container "my-container"

.. code-block:: bash

  $ swift tempurl GET 600 /v1/AUTH_b24e9ee3447e48eab1bc99cb894cac6f/my-container/file2.txt "testkey"
  /v1/AUTH_b24e9ee3447e48eab1bc99cb894cac6f/my-container/file2.txt?temp_url_sig=2dbc1c2335a53d5548dab178d59ece7801e973b4&temp_url_expires=1483990005

We can test this using cURL and appending the generated URL to the Catalyst
Cloud's server URL "https://api.nz-por-1.catalystcloud.io:8443". If it is
successful the request should return the contents of the object.

.. code-block:: bash

  $ curl -i "https://api.nz-por-1.catalystcloud.io:8443/v1/AUTH_b24e9ee3447e48eab1bc99cb894cac6f/my-container/file2.txt?temp_url_sig=2dbc1c2335a53d5548dab178d59ece7801e973b4&temp_url_expires=1483990005"
  HTTP/1.1 200 OK
  Server: nginx/1.10.1
  Date: Mon, 09 Jan 2017 19:22:05 GMT
  Content-Type: text/plain
  Content-Length: 501
  Accept-Ranges: bytes
  Last-Modified: Mon, 09 Jan 2017 19:18:47 GMT
  Etag: 137eed1d424a58831892172f5433594a
  X-Timestamp: 1483989526.71129
  Content-Disposition: attachment; filename="file2.txt"; filename*=UTF-8''file2.txt
  X-Trans-Id: tx9aa84268bd984358b6afe-005873e2dd

  "For those who have seen the Earth from space, and for the hundreds and perhaps thousands more who will, the experience most certainly changes your perspective. The things that we share in our world are far more valuable than those which divide us." "For those who have seen the Earth from space, and for the hundreds and perhaps thousands more who will, the experience most certainly changes your perspective. The things that we share in our world are far more valuable than those which divide us."

We could also access the object by taking the same URL that we passed to cURL
and pasting it into a web browser.
