##########################################
Using Docker Machine on the Catalyst Cloud
##########################################

This tutorial shows you how to use Docker Machine with the OpenStack driver in
order to provision Docker Engines on Catalyst Cloud compute instances.

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

Once a Docker Engine has been provisioned on a VM instance the local docker
client can be configured to talk to the remote Docker Engine rather than
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
* You have a single private network and subnet within your tenant
* You will be setting up a Ubuntu 14.04 instance
* You will be using the ubuntu user
* You will be letting the driver create an SSH keypair for you
* You have sourced an openrc file, as described at :ref:`source-rc-file`

Install Docker Machine
======================

The first thing we need to do is install Docker Machine locally:

.. code-block:: bash

 $ curl -L https://github.com/docker/machine/releases/download/v0.4.0/docker-machine_linux-amd64 \
   | sudo tee /usr/local/bin/docker-machine > /dev/null
 $ sudo chmod +x /usr/local/bin/docker-machine

Check that docker machine is working:

.. code-block:: bash

 $ docker-machine -v
 docker-machine version 0.4.0 (9d0dc7a)

Create a Security Group and rules
=================================

.. note::

 We are assuming that your tenent has a private network, subnet and router setup, please see consult :ref:`launching-your-first-instance` if you do not have this configured already. We are also assuming that you have spare floating IPs available in your quota.

The next step is to setup a security group for our docker host, we will use the
command line clients to achieve this. First create a security group:

.. code-block:: bash

 $ neutron security-group-create --description 'network access for docker' docker-security-group
 Created a new security_group:
 +----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | Field                | Value                                                                                                                                                                                                                                                                                                                         |
 +----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | description          | network access for docker                                                                                                                                                                                                                                                                                                     |
 | id                   | 2fc1b247-3b2d-4f2d-9270-0d164302ebb7                                                                                                                                                                                                                                                                                          |
 | name                 | docker-security-group                                                                                                                                                                                                                                                                                                         |
 | security_group_rules | {"remote_group_id": null, "direction": "egress", "remote_ip_prefix": null, "protocol": null, "tenant_id": "0cb6b9b744594a619b0b7340f424858b", "port_range_max": null, "security_group_id": "2fc1b247-3b2d-4f2d-9270-0d164302ebb7", "port_range_min": null, "ethertype": "IPv4", "id": "100a67fb-a4df-48fc-b42c-c383aac849fc"} |
 |                      | {"remote_group_id": null, "direction": "egress", "remote_ip_prefix": null, "protocol": null, "tenant_id": "0cb6b9b744594a619b0b7340f424858b", "port_range_max": null, "security_group_id": "2fc1b247-3b2d-4f2d-9270-0d164302ebb7", "port_range_min": null, "ethertype": "IPv6", "id": "3a9eaed9-ae56-4f80-8123-1bbc47aed57b"} |
 | tenant_id            | 0cb6b9b744594a619b0b7340f424858b                                                                                                                                                                                                                                                                                              |
 +----------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Now we need to create three rules:

* Inbound access to TCP port 22 for SSH access
* Inbound access to TCP port 80 for web access so we can demonstrate Nginx
  running inside a docker container
* Inbound access to TCP port 2376 so our local client can communicate with the
  Docker Engine daemon

You can issue the ``neutron security-group-list`` command to find your
``SECURITY_GROUP_ID``:

.. code-block:: bash

 $ neutron security-group-list
 +--------------------------------------+-----------------------+---------------------------+
 | id                                   | name                  | description               |
 +--------------------------------------+-----------------------+---------------------------+
 | 2fc1b247-3b2d-4f2d-9270-0d164302ebb7 | docker-security-group | network access for docker |
 | 687512ab-f197-4f07-ae51-788c559883b9 | default               | default                   |
 +--------------------------------------+-----------------------+---------------------------+

 $ for port in 22 80 2376; do echo neutron security-group-rule-create --direction ingress --protocol tcp \
   --port-range-min $port --port-range-max $port --remote-ip-prefix YOUR_CIDR_NETWORK SECURITY_GROUP_ID; done

If you are unsure of what YOUR_CIDR_NETWORK should be, ask your network admin,
or visit http://ifconfig.me and get your IP address.  Use "IP_ADDRESS/32" as
YOUR_CIDR_NETWORK to allow traffic only from your current effective IP.

Create a Cloud VM using Docker Machine
======================================

The next step is to provision a compute instance using Docker Machine. Docker
machine will instantiate a VM, get SSH access to this VM and will then install
the Docker Engine on this host. This process can take quite a while, we
recommend using the ``--debug`` flag so you can monitor the installation
progress and see any errors that may occur.

.. note::

 We are making use of OpenStack environment variables in this command, ensure you have followed the steps described at :ref:`source-rc-file`

.. code-block:: bash

 $ docker-machine --debug create --driver openstack --openstack-ssh-user ubuntu --openstack-image-name ubuntu-14.04-x86_64 --openstack-flavor-name c1.c1r1 \
   --openstack-floatingip-pool public-net --openstack-sec-groups docker-security-group docker-engine-host

Now we need to tell our local client how to connect to the remote Docker Engine
we have created:

.. code-block:: bash

 $ eval "$(docker-machine env docker-engine-host)"

Now when you issue docker commands using the local client you will be
interacting with the docker daemon in the cloud instance:

.. code-block:: bash

 $ docker info
 Containers: 0
 Images: 0
 Storage Driver: aufs
  Root Dir: /var/lib/docker/aufs
  Backing Filesystem: extfs
  Dirs: 0
  Dirperm1 Supported: false
 Execution Driver: native-0.2
 Kernel Version: 3.13.0-63-generic
 Operating System: Ubuntu 14.04.3 LTS
 CPUs: 1
 Total Memory: 993.9 MiB
 Name: docker-engine-host
 ID: UGVP:U52P:ORYW:26VK:OCXE:33OI:LADQ:E4LQ:ML5L:SHGU:XQZH:WIE7
 Http Proxy:
 Https Proxy:
 No Proxy:
 WARNING: No swap limit support
 Labels:
  provider=openstack

.. note::

 Docker Engine stores configuration parameters including SSL and SSH keys under ~/.docker/machine/

Create a test container
=======================

Lets create a test image from which we will instantiate a container running in
the cloud. We will run a simple webserver by basing our image on the official
Nginx image. Lets create a custom index page and a ``Dockerfile`` for our
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

Now lets create a our image:

.. code-block:: bash

 $ docker build -t yourname/nginx .
 Sending build context to Docker daemon 24.37 MB
 Sending build context to Docker daemon
 Step 0 : FROM nginx
 latest: Pulling from library/nginx
 843e2bded498: Pull complete
 8c00acfb0175: Pull complete
 426ac73b867e: Pull complete
 d6c6bbd63f57: Pull complete
 4ac684e3f295: Pull complete
 91391bd3c4d3: Pull complete
 b4587525ed53: Pull complete
 0240288f5187: Pull complete
 28c109ec1572: Pull complete
 063d51552dac: Pull complete
 d8a70839d961: Pull complete
 ceab60537ad2: Pull complete
 Digest: sha256:9d0768452fe8f43c23292d24ec0fbd0ce06c98f776a084623d62ee12c4b7d58c
 Status: Downloaded newer image for nginx:latest
  ---> ceab60537ad2
 Step 1 : MAINTAINER Yourname Yoursurname <yourname@example.com>
  ---> Running in e273723984fc
  ---> 007bd52c229f
 Removing intermediate container e273723984fc
 Step 2 : COPY index.html /usr/share/nginx/html/index.html
  ---> c129a8d2eb17
 Removing intermediate container 649645c47ca9
 Successfully built c129a8d2eb17

.. note::

 At this point you are referencing a local ``Dockerfile`` but the image is being built on the remote Docker Engine cloud instance.

Now lets instantiate the image we have just built as a running container:

.. code-block:: bash

 $ docker run -d -p 80:80 yourname/nginx
 3f47ef854fbe7d58b0e14e8ce2407ddb00b0883399aa1ff434c50fcfe1406750

Lets check we have a running container:

.. code-block:: bash

 $ docker ps
 CONTAINER ID        IMAGE               COMMAND                CREATED                  STATUS              PORTS                         NAMES
 3f47ef854fbe        yourname/nginx      "nginx -g 'daemon of   Less than a second ago   Up About a minute   0.0.0.0:80->80/tcp, 443/tcp   naughty_bell

Now lets hit the external IP to verify we have everything working:

.. code-block:: bash

 $ curl $( nova show --minimal docker-engine-host | grep network | awk '{print $(NF-1)}' )
 <html>
 <h3>Hello, Docker World!</h3>
 </html>

Should you wish to log in to the remote instance using SSH you can use the key
generated by Docker Machine:

.. code-block:: bash

 $ ssh -i ~/.docker/machine/machines/docker-engine-host/id_rsa \
   ubuntu@$( nova show --minimal docker-engine-host | grep network | awk '{print $(NF-1)}' )

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

