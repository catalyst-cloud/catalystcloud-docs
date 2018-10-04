# Python 3.5.2
import os
import openstack

# Connect to openstack using enviroment variables
connection = openstack.connect()

# Create a new container
container_name = 'mycontainer'
connection.object_store.create_container(container_name)

# Put an object in it
file_name = "test.txt"
file_contents = "Hello world! This is the contents of my file!"
connection.object_store.upload_object(
    container=container_name,
    name=file_name,
    data=file_contents
)

# List all containers
all_containers = [x for x in connection.object_store.containers()]

for container in all_containers:
    print("{name} - Object count: {obj_num} - Bytes: {bytes}".format(
        name=container.name,
        obj_num=container.object_count,
        bytes=container.bytes_used
    ))

# List all objects in all containers
for container in all_containers:
    all_objects = connection.object_store.objects(container)
    print("\n" + container.name)

    for object in all_objects:
        print("\t{name}\t{type}".format(
            name=object.name,
            type=object.content_type
            ))
