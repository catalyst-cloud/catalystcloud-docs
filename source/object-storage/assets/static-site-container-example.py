# Python 3.6.6
import openstack

# Connect to openstack using enviroment variables
connection = openstack.connect()

# Create a new container
container_name = 'mystaticsite'
connection.object_store.create_container(container_name)

# Set container read_ACL metadata to allow serving contents as static site
read_acl_string = '.r:*,.rlistings'
connection.object_store.set_container_metadata(container_name, read_ACL=read_acl_string)

html_name = 'index.html'
html_contents = """
<!DOCTYPE html>
<html lang="en" dir="ltr">
  <head>
    <meta charset="utf-8">
    <title>My static site</title>
    <link rel="stylesheet" href="main.css">
  </head>
  <body>
    <h1>Welcome to my static site!</h1>
    <p>We hope you enjoy it.</p>
  </body>
</html>
"""

css_name = 'main.css'
css_contents = """
h1 {
  text-align: center;
  font-family: lato;
}

p {
  text-align: center;
  font-family: lato;
}
"""

# Upload the files you want to serve as a static site
connection.object_store.upload_object(container_name, html_name, data=html_contents)
connection.object_store.upload_object(container_name, css_name, data=css_contents)

# Get a url to serve the graph from
base_url = connection.object_store.get_endpoint()
full_url = '/'.join([base_url, container_name, html_name])

print(full_url)
