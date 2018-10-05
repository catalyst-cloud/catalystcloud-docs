# Python 3.6.6
import openstack

# Connect to openstack using enviroment variables
connection = openstack.connect()

# Create a new container, and an archive container
container_name = 'mycontainer'
archive_container_name = container_name + '-archive'
connection.object_store.create_container(container_name)
connection.object_store.create_container(archive_container_name)

# Set the 'versions_location' metadata
connection.object_store.set_container_metadata(container_name,
    versions_location=archive_container_name)

# Upload a first object version
file_name = "test.txt"
file_contents = "Hello, this is the first version."
connection.object_store.upload_object(container_name, file_name, data=file_contents)

# Upload a new object version
new_file_contents = "Hello, this is the second version."
connection.object_store.upload_object(container_name, file_name, data=new_file_contents)

def print_contents(container_name):
    print("{} contents:".format(container_name))
    objects = connection.object_store.objects(container_name)
    for object in objects:
        print("Name: {} - Hash: {}".format(object.name, object.etag))
    print()

# View objects in bucket
print_contents(container_name)

# View objects in archive
print_contents(archive_container_name)

# Delete object in main container
connection.object_store.delete_object(file_name, container=container_name)

# Check to see if the archive has changed
print_contents(archive_container_name)
