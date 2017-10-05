.. _using-docker-machine:

##########################################
Using Docker Machine on the Catalyst Cloud
##########################################

This tutorial shows you how to use Docker Machine with the OpenStack driver
to provision Docker Engines on Catalyst Cloud compute instances.

`Docker Engine`_ is the daemon at the core of the `Docker`_ platform. It is
responsible for providing the lightweight runtime on which containers are run.

.. _Docker: https://www.docker.com/

.. _Docker Engine: https://www.docker.com/docker-engine

`Docker Machine`_ is a tool that allows you to provision Docker Engines either
locally or hosted with a cloud provider. Docker Machine has a number of
different drivers to facilitate installing the Docker Engine on different cloud
providers. On the Catalyst Cloud we will be making use of the OpenStack
`driver`_.

.. _driver: https://docs.docker.com/machine/drivers/openstack/

.. _Docker Machine: https://www.docker.com/docker-machine

Once a Docker Engine has been provisioned on a VM instance, the local docker
client can be configured to talk to the remote Docker Engine, rather than
talking to the local Docker Engine. This is achieved using environment
variables.

Setup
=====

This tutorial assumes a number of things:

* You are familiar with Docker and its use case and wish to make use of
  Catalyst Cloud compute instances to run Docker Engines
* You already have Docker installed on your machine
* You are familiar with basic usage of the Catalyst Cloud (e.g. you have
  created your first instance as described at
  :ref:`launching-your-first-instance`)
* You have a single private network and subnet within your project
* You will be setting up a Ubuntu 14.04 instance
* You will be using the ubuntu user
* You will be letting the driver create an SSH keypair for you
* You have sourced an openrc file, as described at :ref:`source-rc-file`

Install Docker Machine
======================

The first thing you need to do is install Docker Machine locally:

.. code-block:: bash

 $ curl -L https://github.com/docker/machine/releases/download/v0.7.0/docker-machine-`uname -s`-`uname -m` | \
   sudo tee /usr/local/bin/docker-machine > /dev/null && sudo chmod +x /usr/local/bin/docker-machine

Check that Docker Machine is working:

.. code-block:: bash

 $ docker-machine -v
 docker-machine version 0.7.0, build a650a40

Create a Security Group and rules
=================================

.. note::

 Assumptions: your project has a private network, subnet and router set up. Please see    consult :ref:`launching-your-first-instance` if you do not have this configured already.
 It is also assumed that you have spare floating IPs available in your quota.

The next step is to set up a security group for your docker host. You will use the
command line clients to achieve this. First create a security group:

.. code-block:: bash

 $ openstack security group create --description 'network access for docker' docker-security-group
 +-------------+---------------------------------------------------------------------------------+
 | Field       | Value                                                                           |
 +-------------+---------------------------------------------------------------------------------+
 | description | network access for docker                                                       |
 | headers     |                                                                                 |
 | id          | f27b5889-8f43-4e57-ba99-8ea6b5d8da30                                            |
 | name        | docker-security-group                                                           |
 | project_id  | 3d5d40b4a6904e6db4dc5321f53d4f39                                                |
 | rules       | direction='egress', ethertype='IPv4', id='ffaea025-3511-492f-b8ce-096df4089fd7' |
 |             | direction='egress', ethertype='IPv6', id='00132465-6141-4842-ad5c-acd47c7a53f5' |
 +-------------+---------------------------------------------------------------------------------+

Now you need to create three rules:

* Inbound access to TCP port 22 for SSH access
* Inbound access to TCP port 80 for web access so you can demonstrate Nginx
  running inside a docker container
* Inbound access to TCP port 2376 so your local client can communicate with the
  Docker Engine daemon

You can issue the ``openstack security group list`` command to find your
``SECURITY_GROUP_ID``:

.. code-block:: bash

 $ openstack security group list
 +--------------------------------------+-----------------------+-----------------------------------------+----------------------------------+
 | ID                                   | Name                  | Description                             | Project                          |
 +--------------------------------------+-----------------------+-----------------------------------------+----------------------------------+
 | 87426623-b895-4fa8-bf1b-b3ea6f074328 | default               | default                                 | 3d5d40b4a6904e6db4dc5321f53d4f39 |
 | f27b5889-8f43-4e57-ba99-8ea6b5d8da30 | docker-security-group | network access for docker               | 3d5d40b4a6904e6db4dc5321f53d4f39 |
 +--------------------------------------+-----------------------+-----------------------------------------+----------------------------------+


 $ for port in 22 80 2376; do openstack security group rule create --dst-port $port --ingress \
   --protocol tcp --src-ip YOUR_CIDR_NETWORK SECURITY_GROUP_ID; done

 +-------------------+--------------------------------------+
 | Field             | Value                                |
 +-------------------+--------------------------------------+
 | direction         | ingress                              |
 | ethertype         | IPv4                                 |
 | headers           |                                      |
 | id                | d988e327-01c7-4c80-8b72-8625b0ce425d |
 | port_range_max    | 22                                   |
 | port_range_min    | 22                                   |
 | project_id        | 3d5d40b4a6904e6db4dc5321f53d4f39     |
 | protocol          | tcp                                  |
 | remote_group_id   | None                                 |
 | remote_ip_prefix  | 114.110.38.54/32                     |
 | security_group_id | f27b5889-8f43-4e57-ba99-8ea6b5d8da30 |
 +-------------------+--------------------------------------+
 +-------------------+--------------------------------------+
 | Field             | Value                                |
 +-------------------+--------------------------------------+
 | direction         | ingress                              |
 | ethertype         | IPv4                                 |
 | headers           |                                      |
 | id                | 01fad37d-518f-48f2-93d6-3eeb29b4fda5 |
 | port_range_max    | 80                                   |
 | port_range_min    | 80                                   |
 | project_id        | 3d5d40b4a6904e6db4dc5321f53d4f39     |
 | protocol          | tcp                                  |
 | remote_group_id   | None                                 |
 | remote_ip_prefix  | 114.110.38.54/32                     |
 | security_group_id | f27b5889-8f43-4e57-ba99-8ea6b5d8da30 |
 +-------------------+--------------------------------------+
 +-------------------+--------------------------------------+
 | Field             | Value                                |
 +-------------------+--------------------------------------+
 | direction         | ingress                              |
 | ethertype         | IPv4                                 |
 | headers           |                                      |
 | id                | 3b4e03a7-4d3e-4d88-afc8-ecd968469b06 |
 | port_range_max    | 2376                                 |
 | port_range_min    | 2376                                 |
 | project_id        | 3d5d40b4a6904e6db4dc5321f53d4f39     |
 | protocol          | tcp                                  |
 | remote_group_id   | None                                 |
 | remote_ip_prefix  | 114.110.38.54/32                     |
 | security_group_id | f27b5889-8f43-4e57-ba99-8ea6b5d8da30 |
 +-------------------+--------------------------------------+


If you are unsure of what ``YOUR_CIDR_NETWORK`` should be, ask your network
admin, or visit http://ifconfig.me and get your IP address. Use
"IP_ADDRESS/32" as YOUR_CIDR_NETWORK to allow traffic only from your current
effective IP.

Create a Cloud VM using Docker Machine
======================================

The next step is to provision a compute instance using Docker Machine. Docker
Machine will instantiate a VM, get SSH access to this VM and will then install
the Docker Engine on this host. As this process can take quite a while, it's
a good idea to use the ``--debug`` flag so you can monitor the installation
progress and see any errors that may occur.

.. note::

 You are making use of OpenStack environment variables in this command. Ensure you have followed the steps described at :ref:`source-rc-file`

.. code-block:: bash

 $ docker-machine --debug create --driver openstack --openstack-ssh-user ubuntu --openstack-image-name ubuntu-14.04-x86_64 --openstack-flavor-name c1.c1r1 \
   --openstack-net-name PRIVATE-NET-NAME --openstack-floatingip-pool public-net --openstack-sec-groups docker-security-group docker-engine-host

.. note::

  If your cloud tenant only has one private network defined, then the
  ``--openstack-net-name PRIVATE-NET-NAME`` can be omitted. If there is more
  than one private network defined, then ``PRIVATE-NET-NAME`` should be replaced
  with the network you wish to connect the docker-engine-host to

Now you need to tell your local client how to connect to the remote Docker Engine
you have created:

.. code-block:: bash

 $ eval "$(docker-machine env docker-engine-host)"

Now, when you issue docker commands using the local client, you will be
interacting with the Docker daemon in the cloud instance:

.. code-block:: bash

 $ docker info
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 0
 Server Version: 1.12.1
 Storage Driver: aufs
  Root Dir: /var/lib/docker/aufs
  Backing Filesystem: extfs
  Dirs: 0
  Dirperm1 Supported: false
 Logging Driver: json-file
 Cgroup Driver: cgroupfs
 Plugins:
  Volume: local
  Network: null bridge host overlay
 Swarm: inactive
 Runtimes: runc
 Default Runtime: runc
 Security Options: apparmor
 Kernel Version: 3.13.0-95-generic
 Operating System: Ubuntu 14.04.5 LTS
 OSType: linux
 Architecture: x86_64
 CPUs: 1
 Total Memory: 993.9 MiB
 Name: docker-engine-host
 ID: UERI:SGSA:5SDC:W7HF:Z3DC:Y5H3:FOKJ:OQO5:YSYG:BPYR:BOBY:4VDV
 Docker Root Dir: /var/lib/docker
 Debug Mode (client): false
 Debug Mode (server): false
 Registry: https://index.docker.io/v1/
 WARNING: No swap limit support
 Labels:
  provider=openstack
 Insecure Registries:
  127.0.0.0/8

.. note::

 Docker Engine stores configuration parameters including SSL and SSH keys under ~/.docker/machine/

Create a test container
=======================

Next, create a test image from which you will instantiate a container running in
the cloud. You will run a simple webserver by basing your image on the official
Nginx image. To create a custom index page and a ``Dockerfile`` for our
image:

.. code-block:: bash

 $ cat index.html
 <html>
 <h3>Hello, Docker World!</h3>
 </html>
 $ cat Dockerfile
 FROM nginx
 MAINTAINER Yourname Yoursurname <yourname@example.com>
 COPY index.html /usr/share/nginx/html/index.html

Now create your image:

.. code-block:: bash

  $ docker build -t yourname/nginx .
  Sending build context to Docker daemon 3.072 kB
  Step 1 : FROM nginx
  latest: Pulling from library/nginx

  8ad8b3f87b37: Pull complete
  c6b290308f88: Pull complete
  f8f1e94eb9a9: Pull complete
  Digest: sha256:aa5ac743d65e434c06fff5ceaab6f35cc8519d80a5b6767ed3bdb330f47e4c31
  Status: Downloaded newer image for nginx:latest
   ---> 4a88d06e26f4
  Step 2 : MAINTAINER Yourname Yoursurname <yourname@example.com>
   ---> Running in 0ec25b1c7689
   ---> 9e2a7f2166b4
  Removing intermediate container 0ec25b1c7689
  Step 3 : COPY index.html /usr/share/nginx/html/index.html
   ---> 11bcf58d424a
  Removing intermediate container 642408c201d3
  Successfully built 11bcf58d424a


.. note::

 At this point you are referencing a local ``Dockerfile`` but the image is being built on the remote Docker Engine cloud instance.

Now instantiate the image you have just built as a running container:

.. code-block:: bash

 $ docker run -d -p 80:80 yourname/nginx
 3f47ef854fbe7d58b0e14e8ce2407ddb00b0883399aa1ff434c50fcfe1406750

Check you have a running container:

.. code-block:: bash

 $ docker ps
 CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                         NAMES
 eac317f0642b        yourname/nginx    "nginx -g 'daemon off"   10 seconds ago      Up 9 seconds        0.0.0.0:80->80/tcp, 443/tcp   amazing_pike


Now hit the external IP to verify you have everything working:

.. code-block:: bash

 $ curl $( openstack server show docker-engine-host | grep addresses | awk '{print $(NF-1)}' )
 <html>
 <h3>Hello, Docker World!</h3>
 </html>

Should you wish to log in to the remote instance using SSH you can use the key
generated by Docker Machine:

.. code-block:: bash

 $ ssh -i ~/.docker/machine/machines/docker-engine-host/id_rsa \
   ubuntu@$( openstack server show docker-engine-host | grep addresses | awk '{print $(NF-1)}' )

If you wish to interact with the Docker Engine on the cloud instance you will
need to use ``sudo``:

.. code-block:: bash

 ubuntu@docker-engine-host:~$ sudo docker ps
 CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                         NAMES
 3f47ef854fbe        dojo/nginx          "nginx -g 'daemon off"   52 minutes ago      Up 52 minutes       0.0.0.0:80->80/tcp, 443/tcp   naughty_bell

Documentation
=============

* `Docker Machine Documentation`_
* `Docker Machine Installation Documentation`_
* `Docker Machine OpenStack Driver Documentation`_

.. _Docker Machine Documentation: https://www.docker.com/docker-machine
.. _Docker Machine Installation Documentation: https://docs.docker.com/machine/install-machine/
.. _Docker Machine OpenStack Driver Documentation: https://docs.docker.com/machine/drivers/openstack/
