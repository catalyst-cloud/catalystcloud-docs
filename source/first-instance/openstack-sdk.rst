The Catalyst Cloud is built on top of the OpenStack project. There are many
Software Development Kits for a variety of different languages available for
OpenStack. Some of these SDKs are written specifically for OpenStack while
others are multi cloud SDKs that have an OpenStack provider. Some of these
libraries are written to support a particular service like compute, while
others attempt to provide a unified interface to all services.

You will find an up to date list of recommended SDKs at
http://developer.openstack.org/. A more exhaustive list that includes in
development SDKs is available at https://wiki.openstack.org/wiki/SDKs.

This section covers the OpenstackSDK which is a python based SDK with
support currently only provided for python3. This sdk came out of 3
separate libraries originally: shade, os-client-config and
python-openstacksdk. They each have their own history on how they
were created but after awhile it was clear that there was a lot
to be gained by merging the three projects.

|

Firstly, we have to install the OpenstackSDK. The recommended way to get the
up to date version of the SDK is to use Python's pip installer. Simply run:

.. code-block:: bash

 pip install openstacksdk

It is recommended that you use the openstack sdk from a virtual
environment. More information can be found here: :ref:`python-virtual-env`

Now that we have the OpenstackSDK installed, the next step in getting an
instance running is to provide your Python script with the correct credentials
and configuration for your project. If you have already sourced
your OpenRC file, then this step has been taken care
of. If you still need to source your OpenRC, there is a link above in
the requirements section of this document.

|

Once your environment variables have been set, we are able to create an
instance using the openstack-SDK. We have prepared below a python script that
will create all the various resources needed to set up a blank ubuntu-18
instance with a block storage volume attached. If you want to create an
instance with different parameters, you can find information on how to
create your own scripts on the `OpenstackSDK documentation`_:

.. _OpenstackSDK documentation: https://docs.openstack.org/openstacksdk/latest/

The following code block assumes a few things:

* You are using an RC file that does not use 2-factor-authentication.
  if you are using 2FA then you would need to change the `password` variable
  to be a `token`
* The region your instance is going to be made is the Porirua region.
* You have downloaded and installed a version of python3 on your machine.
* You don't already have a private SSH key that you want to associate with your
  instance. To change this you will have to alter the code relating to the
  'create_keypair' function.

.. code-block:: python3

  #!/usr/bin/env python

  #import needed packages
  import os
  import sys
  import openstack
  from openstack.config import loader
  import errno
  config = loader.OpenStackConfig()

  #Variables for the creation of an instance
  prefix = 'openstacksdk-' #Change this prefix if you're wanting a different name
  NETWORK_PREFIX = '10.10.0'
  SERVER_NAME = prefix + 'instance'
  PRIVATE_NETWORK = prefix + 'private-net'
  PRIVATE_SUBNET = prefix + 'private-subnet'
  ROUTER = prefix + 'router'
  SECURITY_GROUP = prefix + 'sg'
  NETWORK_NAME = prefix + 'private-net'
  KEYPAIR_NAME = prefix + 'keypair'
  VOLUME_NAME = prefix + 'volume'

  IMAGE_NAME = 'ubuntu-18.04-x86_64'
  FLAVOR_NAME = 'c1.c1r1'
  SSH_DIR = '{home}/.ssh'.format(home=os.path.expanduser("~"))
  PUBLIC_KEYPAIR_FILE = '{ssh_dir}/openstacksdk.id_rsa.pub'.format(ssh_dir=SSH_DIR)
  PRIVATE_KEYPAIR_FILE = '{ssh_dir}/openstacksdk.id_rsa.private'.format(ssh_dir=SSH_DIR)
  RESTRICTED_CIDR_RANGE = '0.0.0.0/32'

  #connect to the cloud using local variables.
  auth = os.environ['OS_AUTH_URL']
  region_name = os.environ['OS_REGION_NAME']
  project_name = os.environ['OS_PROJECT_NAME']
  username = os.environ['OS_USERNAME']
  password = os.environ['OS_PASSWORD']

  print('The environment variables this script has found:')
  print('Auth URL:',auth)
  print('Region name:',region_name)
  print('Project name',project_name)
  print('Username',username)
  print('Password',password[:1])

  conn = openstack.connect(
          auth_url=auth,
          project_name=project_name,
          username=username,
          password=password,
          region_name=region_name,
          app_name='examples',
          app_version='1.0',
      )

  #print the current network to prove that the connectivity is successful
  print('------------------------------------------------------------------------')
  print('Connection to the catalyst server:')
  print(conn,'\n')

  def ssh_port(conn):
    sec_group = conn.network.find_security_group(SECURITY_GROUP)
    if not sec_group:
      print("Create a security group and set up SSH ingress:")
      print('------------------------------------------------------------------------\n')

      sec_group = conn.network.create_security_group(
          name=SECURITY_GROUP)

      ssh_rule = conn.network.create_security_group_rule(
          security_group_id=sec_group.id,
          direction='ingress',
          remote_ip_prefix='114.110.38.54/32',
          protocol='TCP',
          port_range_max='22',
          port_range_min='22',
          ethertype='IPv4')

    return sec_group

  def create_router(conn):
    router = conn.network.find_router(ROUTER)
    if not router:
      print("Create a Router:")
      print('------------------------------------------------------------------------\n')

      router = conn.network.create_router(
          name=ROUTER,external_gateway_info={'network_id':'849ab1e9-7ac5-4618-8801-xxxxxxxxxxxx'}
      )
      router.add_interface(conn.network,subnet_id=conn.network.find_subnet(PRIVATE_SUBNET).id)

    return router

  def create_network(conn):
    network = conn.network.find_network(NETWORK_NAME)
    if not network:
      print("Create a Network and subnet:")
      print('------------------------------------------------------------------------\n')
      network = conn.network.create_network(
          name=NETWORK_NAME)

      example_subnet = conn.network.create_subnet(
          name=PRIVATE_SUBNET,
          network_id=network.id,
          ip_version='4',
          cidr='10.0.0.0/24',
          gateway_ip='10.0.0.2')

    router=create_router(conn)
    security_group=ssh_port(conn)

    return network

  def create_keypair(conn):
    keypair = conn.compute.find_keypair(KEYPAIR_NAME)
    if not keypair:
        print("Create a Key Pair:")
        print('------------------------------------------------------------------------\n')
        keypair = conn.compute.create_keypair(name=KEYPAIR_NAME)

        try:
            os.mkdir(SSH_DIR)
        except OSError as e:
            if e.errno != errno.EEXIST:
                raise e

        with open(PRIVATE_KEYPAIR_FILE, 'w') as f:
            f.write("%s" % keypair.private_key)

        os.chmod(PRIVATE_KEYPAIR_FILE, 0o400)

    return keypair

  def create_volume(conn):
    print("Creating and attaching Volume:")
    print('------------------------------------------------------------------------\n')
    volume = conn.volume_exists(VOLUME_NAME)
    instance = conn.compute.find_server(SERVER_NAME)
    loop_val = True
    if not volume:
      volume = conn.volume.create_volume(name=VOLUME_NAME, size=10,volume_type='b1.standard',wait=True)
      # The following loop, waits for your volume to be built before attaching it to your instance.
      while loop_val == True:
        volume_stat = conn.get_volume(VOLUME_NAME).status
        if volume_stat == 'available':
          loop_val = False
      # attach the volume to your instance
      volume = conn.get_volume(VOLUME_NAME)
      conn.attach_volume(server=instance,volume=volume,wait=True)

    return volume

  def attach_floating_ip(conn):
    print('Attaching floating IP to instance:')
    print('------------------------------------------------------------------------\n')
    instance = conn.compute.find_server(SERVER_NAME)
    floating_IP = conn.network.find_available_ip()

    if floating_IP:
      conn.compute.add_floating_ip_to_server(instance,floating_IP.floating_ip_address)
      print('Allocated a floating IP. To access your instance use : ssh -i {key} ubuntu@{ip}'.format(key=PRIVATE_KEYPAIR_FILE, ip=floating_IP.floating_ip_address))
    else:
      conn.network.create_ip(floating_network_id='849ab1e9-7ac5-4618-8801-xxxxxxxxxxxx')
      floating_IP = conn.network.find_available_ip()
      conn.compute.add_floating_ip_to_server(instance,floating_IP.floating_ip_address)
      print('Created a floating IP. To access your instance use : ssh -i {key} ubuntu@{ip}'.format(key=PRIVATE_KEYPAIR_FILE, ip=floating_IP.floating_ip_address))


    return floating_IP

  def create_instance(conn):
    print('Building resources for create:')
    print('------------------------------------------------------------------------\n')

    image = conn.compute.find_image(IMAGE_NAME)
    flavor = conn.compute.find_flavor(FLAVOR_NAME)
    network = create_network(conn)
    security_group = conn.network.find_security_group(SECURITY_GROUP)
    keypair = create_keypair(conn)

    print('Creating Instance')
    print('------------------------------------------------------------------------\n')
    server = conn.compute.create_server(
    name=SERVER_NAME, image_id=image.id, flavor_id=flavor.id,
    networks=[{"uuid": network.id}], key_name=keypair.name, security_groups=[security_group])
    server = conn.compute.wait_for_server(server)

  def main(conn):
    #run this function to create your instance.

    #creates your instance:
    create_instance(conn)
    #creates and attaches a volume
    create_volume(conn)
    #attaches a floating_IP to your instance.
    attach_floating_ip(conn)

  main(conn)

You'll need to save this script as a python file and run the following command
from your the directory of your file:

.. code-block:: bash

  python3 script-file-name.py

After this is completed you should be able to see your new instance on your
project in the catalyst cloud.
