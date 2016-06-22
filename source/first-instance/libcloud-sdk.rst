****************************************************
Launching your first instance using the libcloud SDK
****************************************************

The Catalyst Cloud is built on top of the OpenStack project. There are many
Software Development Kits for a variety of different languages available for
OpenStack. Some of these SDKs are written specifically for OpenStack while
others are multi cloud SDKs that have an OpenStack provider. Some of these
libraries are written to support a particular service like Compute, while
others attempt to provide a unified interface to all services.

You will find an up to date list of recommended SDKs at
http://developer.openstack.org/. A more exhaustive list that includes in
development SDKs is available at https://wiki.openstack.org/wiki/SDKs.

In this section we will use the Apache Libcloud Python library to provision our
first instance. Libcloud is a python library for interacting with many of the
popular cloud service providers using a unified API. For more information see
https://libcloud.apache.org. Documentation for the OpenStack Libcloud driver is
available at
http://libcloud.readthedocs.org/en/latest/compute/drivers/openstack.html.

.. warning::

 Libcloud does not support the OpenStack Networking API.

As libcloud does not support the OpenStack Networking API we will need complete
the following two steps using one of the other documented methods.

1. Create a Network and Subnet
2. Create a Router

After you have setup the networks and router as described above we need to
install and configure libcloud.

Install libcloud
================

The recommended way to install an up to date version of apache libcloud is to
use pythons pip installer. In this example we will do this inside a python
virtual environment.

.. note::

 This document shows how to setup pip and the python virtual environment on
 Ubuntu 14.04. You will need to substitute appropriate steps for other
 operating systems.

Firstly we will install the required python packages:

.. code-block:: bash

 $ sudo apt-get install python-pip python-virtualenv

Next we will configure a python virtual environment:

.. code-block:: bash

 $ mkdir libcloud-first-instance
 $ cd libcloud-first-instance/
 $ virtualenv -p python2.7 .
 $ . bin/activate
 $ pip install apache-libcloud

You should now have libcloud installed, remember that you will need to invoke
your script from a shell that has sourced this virtualenv in order for the
libcloud libraries to be available.

.. code-block:: python

 from libcloud.compute.types import Provider
 from libcloud.compute.providers import get_driver

 provider = get_driver(Provider.OPENSTACK)

OpenStack credentials
=====================

The first step in getting our first instance running is to provide our python
script with the correct credentials and configuration appropriate for our
tenant. The easiest way to achieve this is to make use of environment
variables, we will make use of the standard variables provided by an OpenStack
RC file as described at :ref:`source-rc-file`.

We can reference these from our python script:

.. code-block:: python

 import os

 auth_username = os.environ['OS_USERNAME']
 auth_password = os.environ['OS_PASSWORD']
 auth_url = os.environ['OS_AUTH_URL']
 project_name = os.environ['OS_TENANT_NAME']
 region_name = os.environ['OS_REGION_NAME']

 # strip /v2.0
 if auth_url[-5:] == '/v2.0': auth_url = auth_url[:-5]

 conn = provider(
     auth_username,
     auth_password,
     ex_force_auth_url=auth_url,
     ex_force_auth_version='2.0_password',
     ex_tenant_name=project_name,
     ex_force_service_region=region_name,
 )

Using the interactive interpreter
=================================

.. note::

 This section is optional, if you do not wish to interact with the Catalyst
 Cloud interactively you can safely skip it.

We can use the code above to allow us to interact with the Catalyst Cloud via
the python interactive interpreter. Lets define a connection object called
``conn.py``:

.. code-block:: python

 #!/usr/bin/env python

 from libcloud.compute.types import Provider
 from libcloud.compute.providers import get_driver

 import os

 auth_username = os.environ['OS_USERNAME']
 auth_password = os.environ['OS_PASSWORD']
 auth_url = os.environ['OS_AUTH_URL']
 project_name = os.environ['OS_TENANT_NAME']
 region_name = os.environ['OS_REGION_NAME']

 # strip /v2.0
 if auth_url[-5:] == '/v2.0': auth_url = auth_url[:-5]

 print "creating a connection with the following credentials:"
 print "auth_username = " + auth_username
 print "project_name = " + project_name

 provider = get_driver(Provider.OPENSTACK)
 conn = provider(
     auth_username,
     auth_password,
     ex_force_auth_url=auth_url,
     ex_force_auth_version='2.0_password',
     ex_tenant_name=project_name,
     ex_force_service_region=region_name,
 )

We can then export this script in the ``PYTHONSTARTUP`` environment variable:

.. code-block:: bash

 $ export PYTHONSTARTUP=/path/to/conn.py

Now when we invoke the python interpreter we will have this connection object
available to us:

.. code-block:: bash

 $ python
 Python 2.7.6 (default, Jun 22 2015, 17:58:13)
 [GCC 4.8.2] on linux2
 Type "help", "copyright", "credits" or "license" for more information.
 creating a connection with the following credentials:
 auth_username = <your-username>
 project_name = <your-project-name>
 >>>

Choosing a Flavor
=================

The flavor of an instance is the disk, CPU, and memory specifications of an
instance. Use ``conn.list_sizes()`` to get a list:

.. code-block:: python

 >>> for flavor in conn.list_sizes():
 ...     if flavor.name == "c1.c1r1":
 ...         print(flavor)
 ...
 <OpenStackNodeSize: id=28153197-6690-4485-9dbc-fc24489b0683, name=c1.c1r1, ram=1024, disk=10, bandwidth=None, price=0.0, driver=OpenStack, vcpus=1,  ...>
 >>>

Lets store the flavor id in an environment variable:

.. code-block:: bash

 $ export CC_FLAVOR_ID=28153197-6690-4485-9dbc-fc24489b0683

We can use this variable in our script using the following code:

.. code-block:: python

 flavor_id = os.environ['CC_FLAVOR_ID']
 flavor = conn.ex_get_size(flavor_id)

Choosing an Image
=================

In order to create an instance, you will need to have a pre-built Operating
System in the form of an Image. Use ``conn.list_images()`` to get a list:

.. code-block:: python

 >>> for image in conn.list_images():
 ...     if image.name == "ubuntu-14.04-x86_64":
 ...         print(image)
 ...
 <NodeImage: id=9f2a6a6d-3e68-4914-8e53-b0079d77bb9d, name=ubuntu-14.04-x86_64, driver=OpenStack  ...>
 >>>

Lets store the image id in an environment variable:

.. code-block:: bash

 $ export CC_IMAGE_ID=9f2a6a6d-3e68-4914-8e53-b0079d77bb9d

We can use this variable in our script using the following code:

.. code-block:: python

 image_id = os.environ['CC_IMAGE_ID']
 image = conn.get_image(image_id)

Uploading an SSH key
====================

The following code uploads an SSH key:

.. code-block:: python

 keypair_name = 'first-instance-key'
 pub_key_file = '~/.ssh/id_rsa.pub'
 conn.import_key_pair_from_file(keypair_name, pub_key_file)

Configure Instance Security Group
=================================

The following code will create a security group and a rule within that group:

.. code-block:: python

 first_instance_security_group = conn.ex_create_security_group('first-instance-sg', 'network access for our first instance.')
 conn.ex_create_security_group_rule(first_instance_security_group, 'TCP', 22, 22)

.. warning::

 The code above does not specify a source IP range for this rule, this will
 create a rule with 0.0.0.0/0 as the source, in doing so you are allowing access
 from any IP to your compute instance on the port and protocol selected. This is
 often desirable when exposing a web server (eg: allow HTTP and HTTPs access
 from the Internet), but is insecure when exposing other protocols, such as SSH,
 Telnet and FTP. We strongly recommend you to limit the exposure of your compute
 instances and services to IP addresses or subnets that are trusted.

 See
 http://libcloud.readthedocs.org/en/latest/compute/drivers/openstack.html#libcloud.compute.drivers.openstack.OpenStack_1_1_NodeDriver.ex_create_security_group_rule
 for documentation on setting the source IP range for this rule.

Booting an Instance
===================

The following code will launch an instance using libcloud:

.. code-block:: python

 instance_name = 'first-instance'
 first_instance = conn.create_node(
     name=instance_name,
     image=image,
     size=flavor,
     ex_keyname=keypair_name,
     ex_security_groups=[first_instance_security_group],
 )

 conn.wait_until_running([first_instance])

Allocate a Floating IP
======================

We can associate a floating IP with the following code:

.. code-block:: python

 pool = conn.ex_list_floating_ip_pools()[0]
 unused_floating_ip = pool.create_floating_ip()
 conn.ex_attach_floating_ip_to_node(first_instance, unused_floating_ip)

Complete script
===============

Putting everything together:

.. code-block:: python

 from libcloud.compute.types import Provider
 from libcloud.compute.providers import get_driver
 from libcloud.common.exceptions import BaseHTTPError

 import os

 auth_username = os.environ['OS_USERNAME']
 auth_password = os.environ['OS_PASSWORD']
 auth_url = os.environ['OS_AUTH_URL']
 project_name = os.environ['OS_TENANT_NAME']
 region_name = os.environ['OS_REGION_NAME']

 # strip /v2.0
 if auth_url[-5:] == '/v2.0': auth_url = auth_url[:-5]

 provider = get_driver(Provider.OPENSTACK)
 conn = provider(
     auth_username,
     auth_password,
     ex_force_auth_url=auth_url,
     ex_force_auth_version='2.0_password',
     ex_tenant_name=project_name,
     ex_force_service_region=region_name,
 )

 image_id = os.environ['CC_IMAGE_ID']
 image = conn.get_image(image_id)
 print(image)

 flavor_id = os.environ['CC_FLAVOR_ID']
 flavor = conn.ex_get_size(flavor_id)
 print(flavor)

 print('Checking for existing SSH key pair...')
 keypair_name = 'first-instance-key'
 pub_key_file = '~/.ssh/id_rsa.pub'
 keypair_exists = False
 for keypair in conn.list_key_pairs():
     if keypair.name == keypair_name:
         keypair_exists = True

 if keypair_exists:
     print('Keypair already exists. Skipping import.')
 else:
     print('adding keypair...')
     conn.import_key_pair_from_file(keypair_name, pub_key_file)

 for keypair in conn.list_key_pairs():
     if keypair.name == keypair_name:
         print(keypair)

 security_group_exists = False
 security_group_name = 'first-instance-sg'
 for security_group in conn.ex_list_security_groups():
     if security_group.name == security_group_name:
         first_instance_security_group = security_group
         security_group_exists = True

 if security_group_exists:
     print('Security Group already exists. Skipping creation.')
 else:
     first_instance_security_group = conn.ex_create_security_group(security_group_name, 'network access for our first instance.')
     conn.ex_create_security_group_rule(first_instance_security_group, 'TCP', 22, 22)

 instance_name = 'first-instance'
 print('Creating instance {}'.format(instance_name))
 first_instance = conn.create_node(
     name=instance_name,
     image=image,
     size=flavor,
     ex_keyname=keypair_name,
     ex_security_groups=[first_instance_security_group],
 )

 conn.wait_until_running([first_instance])

 print('Checking for unused Floating IP...')
 unused_floating_ip = None
 for floating_ip in conn.ex_list_floating_ips():
     if not floating_ip.node_id:
         print('found unassociated floating ip:')
         print(floating_ip)
         unused_floating_ip = floating_ip
         break

 # we did not find an unassociated floating ip in our project so we will try and allocate one
 if not unused_floating_ip:
     pool = conn.ex_list_floating_ip_pools()[0]
     print('Retrieving new Floating IP from pool: {}'.format(pool))
     try:
         unused_floating_ip = pool.create_floating_ip()
     except BaseHTTPError, e:
         print('Error creating floating IP: ' + str(e))
     except:
         raise

 if unused_floating_ip:
     if conn.ex_attach_floating_ip_to_node(first_instance, unused_floating_ip):
         print('Allocated new Floating IP: {} to instance {}'.format(unused_floating_ip.ip_address, instance_name))
     else:
         print('Could not attach Floating IP')

     print('Your first instance is available you can ssh to ubuntu@%s' % unused_floating_ip.ip_address)
 else:
     print('Could not find an unused floating ip, please check your quota')


Connect to the new Instance
===========================

We can connect to the SSH service using the floating public IP that has been
associated with our instance. The script will print this address if it succeeds
in associating a floating IP with the newly created instance:

.. code-block:: bash

 Your first instance is available you can ssh to ubuntu@PUBLIC_IP

You should be able to interact with this instance as you would any Ubuntu
server.
