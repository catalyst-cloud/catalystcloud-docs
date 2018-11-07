# Python 3.5.2
import os
from time import time
from urllib.parse import urlparse 
import hashlib
import hmac

import openstack
import requests

# Connect to openstack using auth data in enviroment variables
connection = openstack.connect()

# Create a new container
container_name = 'private_bucket'
connection.object_store.create_container(container_name)

# Put an object in it
file_name = "secrets.txt"
file_contents = "Hello world! This is the contents of my very secret file!"
connection.object_store.upload_object(
    container=container_name,
    name=file_name,
    data=file_contents
)


# Define variables:

# Http method:
method = 'GET'

# Expiry time as UNIX timestamp
duration_in_seconds = 600
expiry_time = str(int(time() + duration_in_seconds))

# Path to object
base_url = connection.object_store.get_endpoint()
base_path = urlparse(base_url).path 
full_path = '/'.join([base_path, container_name, file_name])

# Key
private_key_value = "my-super-secret-key"

# Create body of HMAC signature, seperated by newline characters
hmac_body = '\n'.join([method, expiry_time, full_path])

# Generate signature
signature = hmac.new(str.encode(private_key_value), str.encode(hmac_body), hashlib.sha1).hexdigest()

# Request object from bucket
r = requests.get('/'.join([base_url, container_name, file_name]),
    params={
        'temp_url_sig': signature,
        'temp_url_expires': expiry_time
        })

print(r.text)
