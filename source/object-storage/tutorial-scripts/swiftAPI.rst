For this section of the documentation, we will cover the basic features of
using the Swift object storage API. For a more in depth understanding of the
features that are offered via this API we recommend reading through the
official `OpenStack documentation
<https://docs.openstack.org/api-ref/object-store/>`_

.. raw:: html

    <h3> API endpoints </h3>

+----------+---------+--------------------------------------------------------------------------+
| Region   | Version | Endpoint                                                                 |
+==========+=========+==========================================================================+
| nz-por-1 | 1       | https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_%tenantid%  |
+----------+---------+--------------------------------------------------------------------------+
|          | 3       | https://api.nz-por-1.catalystcloud.io:5000                               |
+----------+---------+--------------------------------------------------------------------------+
| nz-hlz-1 | 1       | https://object-storage.nz-hlz-1.catalystcloud.io:443/v1/AUTH_%tenantid%  |
+----------+---------+--------------------------------------------------------------------------+
|          | 3       | https://api.nz-hlz-1.catalystcloud.io:5000                               |
+----------+---------+--------------------------------------------------------------------------+

.. Note::

  While our geo-replicated storage does backup to all three of our cloud regions (Porirua, Hamilton
  and Wellington) It is preferable that you interact with the service with either the Porirua or
  Hamilton region endpoints. Your data will still be replicated/stored in the Wellington region if
  that is the replication policy you have opted for even if you access it from either of the other
  regions.

.. raw:: html

    <h3> Requirements </h4>

    <h4> Sourcing the correct environment variables </h5>

Like the the other methods in this tutorial section, you will need to source an
openRC file to interact with the object storage APIs. However, there is
an additional environment variable that we must manually set to be able to
interact correctly with the swift API. We need to create an **OS_STORAGE_URL**
variable so that swift is able to correctly authenticate using your Catalyst Cloud
credentials. We do this by taking one of the API endpoints from above, and
adding our project_ID to it.

To get your project_ID, you can run the following command:

.. code-block:: bash

  $ openstack project show <name of the project you sourced your OpenRC with>
  +-------------+----------------------------------+
  | Field       | Value                            |
  +-------------+----------------------------------+
  | description |                                  |
  | domain_id   | default                          |
  | enabled     | True                             |
  | id          | 7xxxxxxxxxxxxxxxxxxxxxxxxxxxxe54 |
  | tags        | []                               |
  +-------------+----------------------------------+

We then take the ID that we find from this output and we combine it with
the Auth API from the region we want to operate in; in this case we are using
the Porirua region. We then export this environment variable as
"*OS_STORAGE_URL*" like so:

.. code-block:: bash

  $ export OS_STORAGE_URL="https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_7xxxxxxxxxxxxxxxxxxxxxxxxxxxxe54"

.. raw:: html

  <h4> Installing the correct tools</h4>


After you have your environment variables sourced, you will also need to
install the standard client library for swift, which in this case is
the **python-swiftclient**. You can add this library to your current Python
environment using the code snippet below:

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

The code below demonstrates how you can use the python-swiftclient to interact
with your object storage containers while making use of the environment
variables that we have already created. The following script will:

1) create a container on your project
2) add a file to the container
3) list all of your containers and their contents.

To use this file, save it as a '.py' and run it from your command line.

.. code-block:: python

  #!/usr/bin/env python
  import swiftclient
  import os
  token = os.environ['OS_TOKEN']
  stourl = os.environ['OS_STORAGE_URL']

  conn = swiftclient.Connection(
          preauthtoken = token,
          preauthurl = stourl,
          insecure = False,
          auth_version = 1,
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

If you are using an username and password to authenticate with the
Swift API rather than a token, you will need to make some changes to the start
of the script above. Once these changes have been made you should be able to
authenticate and perform the same actions using username and password
authentication instead of token authentication.

.. Note::

  You may need to change or set some additional environment variables for the following code snippet to work. However, if you have
  authenticate using the ``--no-token`` flag on your openRC file, these should already be set.

Replace the starting section of the previous file with the following:

.. code-block:: python

  #!/usr/bin/env python
  import swiftclient
  import os
  # Read configuration from environment variables (openstack.rc)
  auth_username = os.environ['OS_USERNAME']
  auth_password = os.environ['OS_PASSWORD']
  auth_url = os.environ['OS_AUTH_URL']

  options = {
          'tenant_name': os.environ['OS_PROJECT_NAME'],
          'region_name': os.environ['OS_REGION_NAME'],
          'user_domain_name': os.environ['OS_USER_DOMAIN_NAME'],
          'project_domain_id': os.environ['OS_PROJECT_DOMAIN_ID']
  }


  # Establish the connection with the object storage API
  conn = swiftclient.Connection(
          authurl = auth_url,
          user = auth_username,
          key = auth_password,
          insecure = False,
          os_options = options,
          auth_version = '3'
  )


  # ...You will then need to remove the previous piece of code that created a "conn=swiftclient.Connection" using the os_token variable.

