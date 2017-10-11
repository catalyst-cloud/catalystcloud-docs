*******************
Using the shade SDK
*******************

The Catalyst Cloud is built on top of the OpenStack project. There are many
Software Development Kits for a variety of different languages available for
OpenStack. Some of these SDKs are written specifically for OpenStack while
others are multi cloud SDKs that have an OpenStack provider. Some of these
libraries are written to support a particular service like Compute, while
others attempt to provide a unified interface to all services.

You will find an up to date list of recommended SDKs at
http://developer.openstack.org/. A more exhaustive list that includes in
development SDKs is available at https://wiki.openstack.org/wiki/SDKs.

In this section we will use the Shade library to provision our first instance.
Shade is a Python library for interacting with OpenStack clouds. Shade began
its life in the Ansible project when duplicated code inside of the many
OpenStack modules was refactored into an internal library. It was recognised
that this library was useful beyond Ansible and it was subsequently moved to
standalone library. Shade is maintained by the OpenStack Infra team.

Documentation for Shade is available at
https://docs.openstack.org/shade/latest/index.html. Comprehensive `usage`_
information is provided.

.. _usage: https://docs.openstack.org/shade/latest/user/usage.html

Installing Shade
================

The recommended way to install an up to date version of Shade is to use Python's
pip installer. The easiest way to achieve this is to follow the instructions
for installing Ansible at :ref:`install-ansible` as Shade will be installed as
a dependency.

.. note::

  Ansible relies on python2 in order to provide long term backwards
  compatibilty, consequently this tutorial is using a python2 virtual
  environemnt. Shade can make use of python3 if you prefer.

OpenStack credentials
=====================

The first step in getting an instance running is to provide your Python script
with the correct credentials and configuration appropriate for your project. The
easiest way to achieve this is to make use of environment variables. You will
make use of the standard variables provided by an OpenStack RC file as
described at :ref:`source-rc-file`.

You will use the `os_client_config`_ OpenStack client configuration library.
This library reads environment variables and config files. In this case you will
use environment variables. Ensure you have sourced an OpenStack RC file before
running the following code

.. _os_client_config: https://pypi.python.org/pypi/os-client-config

.. code-block:: python

 import os_client_config
 import shade

 cloud_config = os_client_config.OpenStackConfig().get_one_cloud()
 cloud = os_client_config.make_shade()

You now have a ``cloud`` object representing your cloud

Using an interactive interpreter
================================

.. note::

 This section is optional. If you do not wish to engage with the Catalyst
 Cloud interactively, you can safely skip it.

The following code allows you to engage with the Catalyst Cloud via
the Python interactive interpreter. First, define a cloud object called
``cloud``:

.. literalinclude:: ../_scripts/cloud.py

You can then export this script in the ``PYTHONSTARTUP`` environment variable:

.. code-block:: bash

 $ export PYTHONSTARTUP=/path/to/cloud.py

Now when you invoke the Python interpreter, you will have this cloud object
available to you:

.. code-block:: bash

 $ python
 Python 2.7.12 (default, Nov 19 2016, 06:48:10)
 [GCC 5.4.0 20160609] on linux2
 Type "help", "copyright", "credits" or "license" for more information.
 Created a cloud with the following credentials:
 auth_username = <your-username>
 project_name = <your-project-name>
 >>>

Choosing a Flavor
=================

The flavor of an instance is the disk, CPU, and memory specifications of an
instance. Use ``cloud.list_flavors()`` to get a list and
``cloud.get_flavor(flavor_name)`` to get a flavor:

.. code-block:: python

 >>> flavor = cloud.get_flavor('c1.c1r1')
 >>> cloud.pprint(flavor)
 {u'OS-FLV-DISABLED:disabled': False,
  u'OS-FLV-EXT-DATA:ephemeral': 0,
  'disk': 10,
  'ephemeral': 0,
  'extra_specs': {u'production': u'true'},
  'id': u'6371ec4a-47d1-4159-a42f-83b84b80eea7',
  'is_disabled': False,
  'is_public': True,
  'location': {'cloud': 'envvars',
               'project': {'domain_id': None,
                           'domain_name': None,
                           'id': u'0cb6b9b744594a619b0b7340f424858b',
                           'name': 'os-training.catalyst.net.nz'},
               'region_name': 'nz_wlg_2',
               'zone': None},
  'name': u'c1.c1r1',
  u'os-flavor-access:is_public': True,
  'properties': {u'OS-FLV-DISABLED:disabled': False,
                 u'OS-FLV-EXT-DATA:ephemeral': 0,
                 u'os-flavor-access:is_public': True},
  'ram': 1024,
  'rxtx_factor': 1.0,
  'swap': 0,
  'vcpus': 1}

Let's store the flavor name in a variable:

.. code-block:: python

 flavor_name = 'c1.c1r1'


Choosing an Image
=================

In order to create an instance, you will need to have a pre-built Operating
System in the form of an Image. Use ``cloud.list_images()`` to get a list and
``cloud.get_image(image_name)`` to get an image:

.. code-block:: python

 >>> image = cloud.get_image('ubuntu-16.04-x86_64')
 >>> cloud.pprint(image)
 {'checksum': u'50cbac72860d9370b38af822936677ab',
  'container_format': u'bare',
  'created': u'2017-08-13T22:25:25Z',
  'created_at': u'2017-08-13T22:25:25Z',
  'direct_url': u'rbd://b5bc0fb6-f490-4018-abd3-a984ca3dd6a4/images/d105d837-67b7-4db6-8aeb-41d92ecb31e1/snap',
  'disk_format': u'raw',
  'file': u'/v2/images/d105d837-67b7-4db6-8aeb-41d92ecb31e1/file',
  'id': u'd105d837-67b7-4db6-8aeb-41d92ecb31e1',
  'is_protected': True,
  'is_public': True,
  'location': {'cloud': 'envvars',
               'project': {'domain_id': None,
                           'domain_name': None,
                           'id': u'94b566de52f9423fab80ceee8c0a4a23',
                           'name': None},
               'region_name': 'nz_wlg_2',
               'zone': None},
  'locations': [],
  'metadata': {u'schema': u'/v2/schemas/image',
               u'self': u'/v2/images/d105d837-67b7-4db6-8aeb-41d92ecb31e1'},
  'minDisk': 10,
  'minRam': 1024,
  'min_disk': 10,
  'min_ram': 1024,
  'name': u'ubuntu-16.04-x86_64',
  'owner': u'94b566de52f9423fab80ceee8c0a4a23',
  'properties': {u'schema': u'/v2/schemas/image',
                 u'self': u'/v2/images/d105d837-67b7-4db6-8aeb-41d92ecb31e1'},
  'protected': True,
  u'schema': u'/v2/schemas/image',
  u'self': u'/v2/images/d105d837-67b7-4db6-8aeb-41d92ecb31e1',
  'size': 10737418240,
  'status': u'active',
  'tags': [],
  'updated': u'2017-08-13T22:27:30Z',
  'updated_at': u'2017-08-13T22:27:30Z',
  'virtual_size': 0,
  'visibility': u'public'}

Let's store the image name in a variable:

.. code-block:: python

 image_name = 'ubuntu-16.04-x86_64'

Uploading an SSH key
====================

The following code uploads an SSH key:

.. code-block:: python

 keypair_name = 'first-instance-key'
 pub_key_file = os.environ['HOME'] + '/.ssh/id_rsa.pub'
 public_key = open(pub_key_file).read()
 cloud.create_keypair(keypair_name, public_key)


Configure an Instance Security Group
====================================

The following code will create a security group and a rule within that group:

.. code-block:: python

 restricted_cidr_range = '0.0.0.0/32'
 security_group = cloud.create_security_group(
     security_group_name,
     'First instance security group',
 )
 cloud.create_security_group_rule(
     security_group.id,
     protocol='tcp',
     port_range_min=22,
     port_range_max=22,
     remote_ip_prefix=restricted_cidr_range,
 )

The code above specifys 0.0.0.0/0 as the source. In doing so, you are allowing
access from any IP to your compute instance on the port and protocol selected.
This is often desirable when exposing a web server (eg: allow HTTP and HTTPs
access from the Internet), but is insecure when exposing other protocols, such
as SSH. We strongly recommend you limit the exposure of your compute
instances and services to IP addresses or subnets that are trusted.

The following code will set restricted_cidr_range to your external IP address
if you have the dig command available.

.. code-block:: python

 # set restricted_cidr_range to our external address if we can
 try:
     external_ip = check_output(
         ['dig', '+short', 'myip.opendns.com', '@resolver1.opendns.com']
     ).rstrip()
     try:
         socket.inet_aton(external_ip)
         restricted_cidr_range = external_ip + '/32'
     except socket.error:
         pass
 except:
     pass

Booting an Instance
===================

The following code will launch an instance using Shade:

.. code-block:: python

 instance_name = 'first-instance'
 # assumes you have a private network named private-net
 private_network = get_network('private-net')
 # Create the instance
 server =cloud.create_server(
     name=instance_name,
     image=image.id,
     wait=True,
     auto_ip=False,
     flavor=flavor.id,
     security_groups=[security_group.id, 'default'],
     network=private_network.id,
     key_name=keypair_name,
 )


Allocate a Floating IP
======================

You can associate a floating IP with the following code:

.. code-block:: python

 floating_ip_address = cloud.add_auto_ip(server, wait=True)

Complete script
===============

The complete script is included below:

.. warning::

 Note that this script is creating the network, subnet and router. This is not
 necessary if you already have these resources.

.. literalinclude:: ../_scripts/create-first-instance-shade.py

Connect to the new Instance
===========================

You can connect to the SSH service using the floating public IP that has been
associated with your instance. The script will print this address if it succeeds
in associating a floating IP with the newly created instance:

.. code-block:: bash

 Your first instance is available: you can ssh to ubuntu@PUBLIC_IP

You should be able to interact with this instance as you would any Ubuntu
server.

Deleting resources using Shade
==============================

The following script shows how you can delete resources using Shade.

.. warning::

 Note that this script deletes the network, subnet and router. You may not
 wish to delete these resources. If so, you should comment out the relevant
 lines.


.. literalinclude:: ../_scripts/create-first-instance-shade.py

