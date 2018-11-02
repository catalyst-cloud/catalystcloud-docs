############################
Object storage with the APIs
############################


***********************
Using the OpenStack API
***********************

The features supported by the object storage API can be found on the `OpenStack
documentation <http://developer.openstack.org/api-ref/object-storage/>`_

.. _object-store-endpoints:

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

OpenStack Python SDK example
============================

The standard means of interacting with object storage is using the Python
OpenStack SDK, however, you can also use the Swift Python SDK. Note that
OpenStack's object storage service is often referred to it's code-name: Swift,
hence the Swift SDK. We recommend the OpenStack Python SDK over the Swift python
SDK.


Requirements
------------

You need valid OpenStack credentials to interact with the OpenStack API. These
can be obtained from the :ref:`rc file <source-rc-file>`.

The standard client library is the OpenStack python SDK. This can be installed
into your current Python environment. The example below illustrates how:

.. code-block:: bash

  # Make sure you have pip and virtualenv installed
  sudo apt-get install python-pip python-virtualenv

  # Create a new virtual environment for Python and activate it
  virtualenv venv
  source venv/bin/activate

  # Install Python OpenStack SDK library on your virtual environment
  pip install openstacksdk

Sample code
-----------

The code below demonstrates how you can use the OpenStack python SDK to interact
with object storage.

Before running this example, ensure that you have sourced an openrc file and are
working from a whitelisted IP address, as explained in
:ref:`access-and-whitelist`.

.. literalinclude:: assets/api-python-example.py
   :language: python

.. _s3-api-documentation:

****************
Using the S3 API
****************

The object storage service also has an Amazon S3 emulation layer that supports
common S3 calls and operations. Swift3 middleware emulates the S3 REST API on
top of OpenStack. It is documented fully `here
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

Boto library example
====================

Requirements
------------

You need valid EC2 credentials in order to interact with the S3 compatible API.
You can obtain your EC2 credentials from the dashboard (under Access & Security,
API Access), or using the :ref:`OpenStack CLI <command-line-interface>`:

.. code-block:: bash

  openstack ec2 credentials create

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
-----------

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

**********
Using cURL
**********

To access object storage using cURL, or tools like cURL, it will be necessary to
provide credentials to authenticate the request. Specifically, we'll need an
object store endpoint and a token.

Among several methods, we can do this with the :ref:`OpenStack CLI
<command-line-interface>`.

Remember the API endpoints :ref:`earlier in the page? <object-store-endpoints>`
We can use the OpenStack CLI to get the `AUTH_%tenantid%` part of the endpoint:

.. code-block:: bash

  $ openstack object store account show

  +------------+---------------------------------------+
  | Field      | Value                                 |
  +------------+---------------------------------------+
  | Account    | AUTH_8cbc3296ASDsad90aDSn90asD89085SA |
  | Bytes      | 14002294                              |
  | Containers | 5                                     |
  | Objects    | 17                                    |
  +------------+---------------------------------------+

We can also use the OpenStack CLI to fetch a new token:

.. code-block:: bash

  $ openstack token issue

  +------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | Field      | Value                                                                                                                                                                                   |
  +------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | expires    | 2018-11-02T15:13:58+0000                                                                                                                                                                |
  | id         | gAAAAABb26TW-gWcM_tV7pdfhcR-SFIWA9hjkP4SDkUiQeboX8hD7rdUwG69jtqiNZxDzlqmCesAQys-kTy8ekWit7DVumgJ2X-xOaGkR2bCX3dHWH9aT63jOze_cgd5fFFl90OE_izG1Tzw8v6SvOn65yO_sfcLH7O3thjrUwfazMxRRR_ebLY |
  | project_id | 8ccc3286887e49cb9a40f023eba693b4                                                                                                                                                        |
  | user_id    | cc46fc021fe044c9b7bf2f9295a85019                                                                                                                                                        |
  +------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

By assigning the url and token to environment variables, we can use them more
easily in cURL commands:

.. code-block:: bash

  $ export storageURL="https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_8cbc3296ASDsad90aDSn90asD89085SA"
  $ export token="gAAAAABb26TW-gWcM_tV7pdfhcR-SFIWA9hjkP4SDkUiQeboX8hD7rdUwG69jtqiNZxDzlqmCesAQys-kTy8ekWit7DVumgJ2X-xOaGkR2bCX3dHWH9aT63jOze_cgd5fFFl90OE_izG1Tzw8v6SvOn65yO_sfcLH7O3thjrUwfazMxRRR_ebLY"

With these environment variables, we can now run the following command to get a
list of all available containers for that tenant:

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
