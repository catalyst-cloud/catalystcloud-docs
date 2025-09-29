###################################################################
Docker "getting started with swarm mode" tutorial on Catalyst Cloud
###################################################################

The Docker Engine 1.12 includes a new feature known as `swarm mode`_ which
allows the native management of a cluster of Docker Engines. This cluster of
Docker Engines or nodes is known as a swarm. Swarm Mode allows you to
orchestrate services across all the nodes in a swarm. This is useful for the
scaling, load balancing, distribution and availability of your services.

This tutorial shows you how to easily set up Catalyst Cloud compute instances
to use with the `Getting started with swarm mode`_ tutorial, available as part
of the `docker`_ `documentation`_.

.. _swarm mode: https://docs.docker.com/engine/swarm/
.. _Getting started with swarm mode: https://docs.docker.com/engine/swarm/swarm-tutorial/
.. _docker: https://www.docker.com/
.. _documentation: https://docs.docker.com/

This tutorial will use `Ansible`_ to create three swarm nodes that correspond
to the examples used in the Docker tutorial. After running the playbook, you
will have access to three hosts exactly as described in the tutorial. A cleanup
playbook is provided to remove all resources when you have completed the
tutorial.

.. _Ansible: https://www.ansible.com/

*****
Setup
*****

This tutorial assumes a number of things:

* You are interested in Docker Swarm Mode and wish to complete the tutorial.
* You are familiar with basic usage of Catalyst Cloud (e.g. you have
  created your first instance as described at
  :ref:`launching-your-first-instance`)
* You have sourced an openrc file, as described at :ref:`source-rc-file`
* You have a basic understanding of how to use `Ansible`_ on Catalyst Cloud
  as shown at :ref:`launching-your-first-instance-using-ansible`

***************
Install ansible
***************

Firstly you need to install Ansible as shown at
:ref:`launching-your-first-instance-using-ansible`.

When Ansible is installed, you should change directory to the
``example-playbooks/docker-swarm-mode`` directory within the
``catalystcloud-ansible`` git checkout.

.. code-block:: bash

 $ cd example-playbooks/docker-swarm-mode

****************
Create the swarm
****************

We can now run the ``create-swarm-hosts.yaml`` playbook to create the swarm:

.. code-block:: bash

 $ ansible-playbook --ask-sudo-pass create-swarm-hosts.yaml

After this playbook successfully completes, you are ready to complete the
tutorial. As described in the tutorial `setup`_ instructions, it provides:

* three networked host machines
* Docker Engine 1.12 or later installed
* the IP address of the manager machine
* open ports between the hosts

.. _setup: https://docs.docker.com/engine/swarm/swarm-tutorial/#set-up

*********************
Complete the tutorial
*********************

Start the tutorial with the `Create a swarm`_ section. For example the first
two commands are:

.. _Create a swarm: https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/

.. code-block:: bash

 $ ssh manager1
 $ docker swarm init --advertise-addr 192.168.99.100
 Swarm initialized: current node (dxn1zf6l61qsb1josjja83ngz) is now a manager.

 To add a worker to this swarm, run the following command:

     docker swarm join \
     --token SWMTKN-1-49nj1cmql0jkz5s954yi3oex3nedyz0fb0xx14ie39trti4wxv-8vxv8rssmk743ojnwacrr2e7c \
     192.168.99.100:2377

 To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.


.. note::

 The tutorial uses ``docker-machine ssh``, you should omit ``docker-machine`` from the command as we did not create these nodes using Docker machine. If you would prefer to use Docker machine to set up the nodes you can follow the tutorial at :ref:`using-docker-machine`.

****************
Delete the swarm
****************

When you have completed the tutorial you can remove the swarm and its
associated resources by running the ``remove-swarm-hosts.yaml`` playbook:

.. code-block:: bash

 $ ansible-playbook --ask-sudo-pass remove-swarm-hosts.yaml

