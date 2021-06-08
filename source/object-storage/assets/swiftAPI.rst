For this section of the documentation, we will cover the basic features of
using the Swift object storage API. For a more in depth understanding of the
features that are offered via this API we recommend reading through the
official `OpenStack documentation
<http://developer.openstack.org/api-ref/object-storage/>`_

.. raw:: html

    <h3> API endpoints </h3>

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

.. raw:: html

    <h3> Requirements </h4>

    <h4> Sourcing the correct environment variables </h5>

Like the the other methods in this tutorial section, you will need to source an
openRC file to interact with your object storage container. However, there is
an additional environment variable that we must manually set to be able to
interact correctly with the swift API. We need to create an **OS_STORAGE_URL**
variable so that swift is able to correctly authenticate with your openstack
credentials. We do this by taking on of the API addresses from above, and adding
our user ID to it.

To get your user ID, you can run the following command with an already existing
container.

.. code-block:: bash

  $ openstack user show <username you sourced your OpenRC with>
  +------------+----------------------------------+
  | Field      | Value                            |
  +------------+----------------------------------+
  | created_on | 2021-1-02T03:12:43               |
  | domain_id  | default                          |
  | email      | XXXXXXXXXXXXXXXXXXXXXXXXX        |
  | enabled    | True                             |
  | id         | 421826cbdsa23deXXXXXXXXXXdedd30f |
  | name       | XXXXXXXXXXXXXXXXXXXXXXXXX        |
  +------------+----------------------------------+

We then take the id that we find from this output and we add it together with
the Auth API from earlier, and we name our environment variable OS_STORAGE_URL,
like so:

.. code-block:: bash

  $ export OS_STORAGE_URL="https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_421826cbdsa23deXXXXXXXXXXdedd30f"

.. raw:: html

  <h4> Installing the correct tools</h4>

After this file is edited and sourced, you will also need to install the
standard client library for swift, which in this case is
the Python Swiftclient. This can be added to your current Python environment;
the example below illustrates how:

.. code-block:: bash

  # Make sure you have pip and virtualenv installed
  sudo apt-get install python-pip python-virtualenv

  # Create a new virtual environment for Python and activate it
  virtualenv venv
  source venv/bin/activate

  # Install Python Swiftclient library on your virtual environment
  pip install python-swiftclient

.. raw:: html

    <h3> Sample code </h3>

The code below demonstrates how you can use the Python-Swiftclient to interact
with swift via the version 2 compatible (auth) API. This version uses
the same endpoint for all regions, but you have to specify which one you want
to use when connecting.

The code block will use the environment variables sourced from your openrc
file to:

1) create a container on your project
2) add a file to the container
3) list all of your containers and their contents.

To use this file, save it as a '.py' and run it from your command line.


.. code-block:: python

  #!/usr/bin/env python
  import os
  import swiftclient

  # Read configuration from environment variables (openstack.rc)
  auth_username = os.environ['OS_USERNAME']
  auth_password = os.environ['OS_PASSWORD']
  auth_url = os.environ['OS_AUTH_URL']
  project_name = os.environ['OS_PROJECT_NAME']
  region_name = os.environ['OS_REGION_NAME']
  options = {'tenant_name': project_name, 'region_name': region_name}

  # Establish the connection with the object storage API
  conn = swiftclient.Connection(
          authurl = auth_url,
          user = auth_username,
          key = auth_password,
          insecure = False,
          os_options = options,
          auth_version = '3'
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
      print ("container\t{0}".format(cname))
      for data in conn.get_container(cname)[1]:
          print ('\t{0}\t{1}\t{2}'.format(data['name'], data['bytes'], data['last_modified']))


To use the version 1 (auth) API you need to have previously authenticated,
and have remembered your token id (e.g using the keystone client). Also the
endpoint for the desired region must be used (por in this case). ::

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
