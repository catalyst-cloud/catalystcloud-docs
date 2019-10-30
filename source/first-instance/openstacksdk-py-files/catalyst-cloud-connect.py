#!/usr/bin/env python
"""
Connect to the Catalyst cloud.
You must have your open.rc file sourced in your command line before running
this file.
"""

#import needed packages
import os
import sys
import openstack
from openstack.config import loader
config = loader.OpenStackConfig()

#enables logging
openstack.enable_logging(True, stream=sys.stdout)

def _get_resource_value(resource_key, default):
    return config.get_extra_config('example').get(resource_key, default)

#Define some of the variables for the following
SERVER_NAME = 'openstacksdk-example'
IMAGE_NAME = _get_resource_value('image_name', 'ubuntu-18.04-x86_64')
FLAVOR_NAME = _get_resource_value('flavor_name', 'c1.c1r1')
NETWORK_NAME = _get_resource_value('network_name', 'private-net')
KEYPAIR_NAME = _get_resource_value('keypair_name', 'openstacksdk-example')
SSH_DIR = _get_resource_value(
    'ssh_dir', '{home}/.ssh'.format(home=os.path.expanduser("~")))
PRIVATE_KEYPAIR_FILE = _get_resource_value(
    'private_keypair_file', '{ssh_dir}/id_rsa.{key}'.format(
        ssh_dir=SSH_DIR, key=KEYPAIR_NAME))

#connect to the cloud using local variables.
auth = os.environ['OS_AUTH_URL']
region_name = os.environ['OS_REGION_NAME']
project_name = os.environ['OS_PROJECT_NAME']
username = os.environ['OS_USERNAME']
password = os.environ['OS_PASSWORD']

print('The environment variables this script has found:')
print(auth)
print(region_name)
print(project_name)
print(username)
print(password[:1])


conn = openstack.connect(
        auth_url=auth,
        project_name=project_name,
        username=username,
        password=password,
        region_name=region_name,
        app_name='examples',
        app_version='1.0',
    )

def list_servers(conn):
    print("List Servers:")

    for server in conn.compute.servers():
        print(server)


def list_images(conn):
    print("List Images:")

    for image in conn.compute.images():
        print(image)


def list_flavors(conn):
    print("List Flavors:")

    for flavor in conn.compute.flavors():
        print(flavor)


def list_keypairs(conn):
    print("List Keypairs:")

    for keypair in conn.compute.keypairs():
        print(keypair)



#print the current network to prove that the connectivity is successful
print(conn)
'''
list_servers(conn)
list_images(conn)
list_flavors(conn)
list_keypairs(conn)
'''
