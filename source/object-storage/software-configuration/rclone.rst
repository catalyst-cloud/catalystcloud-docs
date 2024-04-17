******
Rclone
******

`Rclone <https://rclone.org/>`_ is a command-line program to manage files on
cloud storage. It is a feature-rich tool for interacting with object storage
provided by a broad range cloud providers, including Catalyst Cloud.

In addition to being able to put/get objects, it is can be used for copying
objects from one container (or cloud provider) to another.

It is easy to use with Catalyst Cloud.

For some operating systems, such as Debian and Ubuntu it is available from
the package managers, for others you'll need to down it from https://rclone.org/downloads/.
However, we recommend you run at least v1.73 as there are a couple of fixes
for working with our object storage system.

Create a configuration file called `$HOME/.config/rclone/rclone.conf` with
content like this (the cloud_location1 can be what you like, and you can
have multiple remotes configured):

.. code-block:: ini

  [cloud_location1]
  type = swift
  vfs_cache_mode = full
  use_segments_container = true
  domain = default
  auth_version = 3
  auth = https://api.nz-por-1.catalystcloud.io:5000/v3
  tenant = <your_project_name>
  user = <your_username>
  key = <your_password>

You may wish to replace the auth URL with another identity API URL from
:ref:`apis`. If you are using single region replication, please select the
identity API URL for the region your container is within.

Then you can copy files to object storage by running a command like:

.. code-block:: bash

  rclone copy file_to_copy cloud_location1:container1

There are many other options, including encryption.

You can mount a container as a local mount point, for example:

.. code-block:: bash

  mkdir cloud_mount1
  rclone mount cloud_location1:container1 cloud_mount1
