#########################################################
Using an openstack vagrant provider on the Catalyst Cloud
#########################################################

`Vagrant`_ is a popular development tool that makes it easy to create and
configure lightweight, reproducible, and portable development environments. It
allows developers to easily manage virtual machines for development or staging
environments. Vagrant provides a plugin mechanism through which different VM
`providers`_ can be used. These providers can either be local (e.g. VirtualBox,
LXC, Docker) or remote (AWS, OpenStack). This tutorial shows you how to use
OpenStack as a remote provider for Vagrant.

.. _Vagrant: https://www.vagrantup.com/

.. _providers: https://docs.vagrantup.com/v2/providers/index.html

***************************
Vagrant OpenStack providers
***************************

Currently there are two different Vagrant OpenStack providers in common usage:
`vagrant-openstack-plugin`_ and `vagrant-openstack-provider`_. The
configuration for both these providers is similar, which can lead to confusion.
Be sure you know which provider you are using.

.. _vagrant-openstack-plugin: https://github.com/cloudbau/vagrant-openstack-plugin

.. _vagrant-openstack-provider: https://github.com/ggiamarchi/vagrant-openstack-provider

This tutorial uses the ``vagrant-openstack-provider``.

*****
Setup
*****

This tutorial assumes a number of things:

* You are familiar with Vagrant and its use case and wish to make use of
  OpenStack as a provider
* You are familiar with basic usage of the Catalyst Cloud (e.g. you have
  created your first instance as described at
  :ref:`launching-your-first-instance`)
* You already have Vagrant installed on your machine
* You have a single private network and subnet within your project
* You have an appropriate security group that allows inbound SSH connections
* You will be setting up a Ubuntu 14.04 instance
* You will be using the ubuntu user
* You will be letting the provider create an SSH keypair for you
* You have sourced an openrc file, as described at :ref:`source-rc-file`

******************
Install the plugin
******************

The first step is to install the ``vagrant-openstack-provider`` plugin:

.. code-block:: bash

 $ vagrant plugin install vagrant-openstack-provider

********************
Create a Vagrantfile
********************

The next step is to create a ``Vagrantfile`` in the root of your repository:

.. note::

 You are referencing environment variables in this configuration. Ensure you have followed the steps described at :ref:`source-rc-file`.
 Also note that the auth api has updated to v3. This Vagrantfile has been updated to use this version of the api. If your Vagrantfile has stopped working, compare it to the following. The changes are minor.

.. code-block:: ruby

 require 'vagrant-openstack-provider'

 Vagrant.configure("2") do |config|

   config.ssh.username = 'ubuntu'
   config.vm.provision :shell, path: "bootstrap.sh"

   config.vm.provider :openstack do |os|
     os.identity_api_version = "3"
     os.openstack_auth_url   = "#{ENV['OS_AUTH_URL']}/auth/tokens"
     os.domain_name          = "#{ENV['OS_USER_DOMAIN_NAME']}"
     os.username             = "#{ENV['OS_USERNAME']}"
     os.password             = "#{ENV['OS_PASSWORD']}"
     os.project_name         = "#{ENV['OS_PROJECT_NAME']}"
     os.region               = "#{ENV['OS_REGION_NAME']}"
     # Set your own hostname.
     os.server_name          = "a-host-for-#{ENV['OS_USERNAME']}"
     # Select a flavour from the list.
     # https://catalystcloud.nz/pricing/price-list/
     os.flavor               = 'c1.c1r1'
     # Select an image to start with.
     # https://dashboard.cloud.catalyst.net.nz/project/images
     os.image                = 'ubuntu-14.04-x86_64'
     # Select from what you have available.
     # https://dashboard.cloud.catalyst.net.nz/project/security_groups/
     os.security_groups      = ['default', 'dev']
     os.floating_ip_pool     = 'public-net'
   end

 end

******************
Create an instance
******************

Now you can run ``vagrant up`` to create your instance:

.. code-block:: bash

 $ vagrant up --provider=openstack
 Bringing machine 'default' up with 'openstack' provider...
 ==> default: Finding flavor for server...
 ==> default: Finding image for server...
 ==> default: Launching a server with the following settings...
 ==> default:  -- Tenant          : example-tenant
 ==> default:  -- Name            : my-vagrant-box
 ==> default:  -- Flavor          : c1.c1r1
 ==> default:  -- FlavorRef       : 28153197-6690-4485-9dbc-xxxxxxxxxxxx
 ==> default:  -- Image           : ubuntu-14.04-x86_64
 ==> default:  -- ImageRef        : 9f2a6a6d-3e68-4914-8e53-xxxxxxxxxxxx
 ==> default:  -- KeyPair         : vagrant-generated-tsbqz367
 ==> default: Waiting for the server to be built...
 ==> default: Using floating IP 150.242.41.75
 ==> default: Waiting for SSH to become available...
 ==> default: Waiting for SSH to become available...
 Connection to 150.242.41.75 closed.
 ==> default: The server is ready!
 ==> default: Rsyncing folder: /home/myuser/src/openstack-vagrant-test/ => /vagrant
 ==> default: Running provisioner: shell...
 default: Running: /tmp/vagrant-shell20151005-31547-1cps4pe.sh

.. note::

 This provider uses `rsync`_ to sync the local folder to the instance over SSH

.. _rsync: https://rsync.samba.org/

*******************
SSH to the instance
*******************

You can now connect to your instance via SSH:

.. code-block:: bash

 $ vagrant ssh
 Welcome to Ubuntu 14.04.3 LTS (GNU/Linux 3.13.0-63-generic x86_64)

  * Documentation:  https://help.ubuntu.com/

   System information as of Mon Oct  5 01:59:49 UTC 2015

   System load:  0.83             Processes:           81
   Usage of /:   7.7% of 9.81GB   Users logged in:     0
   Memory usage: 7%               IP address for eth0: 10.0.0.52
   Swap usage:   0%

   Graph this data and manage this system at:
     https://landscape.canonical.com/

   Get cloud support with Ubuntu Advantage Cloud Guest:
     http://www.ubuntu.com/business/services/cloud

 0 packages can be updated.
 0 updates are security updates.


 Last login: Mon Oct  5 01:59:48 2015 from wlg-office-ffw.catalyst.net.nz
 ubuntu@my-vagrant-box:~$ logout
 Connection to 150.242.41.75 closed.

Documentation
*************

For Vagrant documentation, consult https://docs.vagrantup.com/v2/. For
documentation on the Vagrant OpenStack provider, consult
https://github.com/ggiamarchi/vagrant-openstack-provider. You may also find
this `presentation`_ by the developer of the plugin useful.

.. _presentation: https://www.openstack.org/summit/openstack-paris-summit-2014/session-videos/presentation/use-openstack-as-a-vagrant-provider

