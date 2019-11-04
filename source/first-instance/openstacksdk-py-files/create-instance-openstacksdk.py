#!/usr/bin/env python
"""
Connect to an Catalyst cloud.
You must have your open.rc file sourced in your command line before running
this file.
"""

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
print(conn)

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
        name=ROUTER,external_gateway_info={'network_id':'e0ba6b88-5360-492c-9c3d-119948356fd3'}
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
    # wait for the volume to be created and become ready to attach.
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
    print('Allocated a floating IP. TO access your instance use : ssh -i {key} ubuntu@{ip}'.format(key=PRIVATE_KEYPAIR_FILE, ip=floating_IP.floating_ip_address))
  else:
    conn.network.create_ip(floating_network_id='e0ba6b88-5360-492c-9c3d-119948356fd3')
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

  #create the compute instance
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
