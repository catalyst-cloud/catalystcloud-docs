#######################################################
Deploying RocketChat on Catalyst Cloud using Cloud-init
#######################################################

Rocket.Chat is an open source alternative to other chat apps such as Slack. It
allows us to install our own server and have control over its configuration.

Cloud-init is a system configuration tool that can be utilised to apply a
configuration to a system automatically upon initialisation.

This tutorial assumes the following:

* You have installed the OpenStack CLI and sourced an OpenStack
  RC file, as explained here - :ref:`source-rc-file`
* A basic knowledge of Bash and YAML.
* Have an SSH key already generated, preferably in :code:`/home/<user>/.ssh/`

Introduction
============

In this tutorial we're going to set up Rocket.Chat on a Catalyst Cloud instance
using nginx as an HTTPS reverse proxy to handle requests to and from the chat
server.

We'll be using a self signed certificate for HTTPS encryption.
Setting up a certificate from a CA such as `Let's Encrypt
<https://letsencrypt.org/>`_ is very easy and packages such as `Certbot
<http://certbot.eff.org>`_ make this process extremely user friendly.
This will require a domain name set up, and is outside the scope of this
tutorial.

For the purpose of this tutorial it's recommended that you follow along, create
a file to copy each code snippet into and try to understand what commands are
being executed.  Small code comments have been included so that the script is
more readable if you are not familiar with the OpenStack CLI or bash. Try to
hold off on running your script until you've reached the end and understand
what the entire script is trying to do.

Instructions for setting up the instances and related networks on Catalyst
Cloud have been included here for convenience. If you've already completed the
process of :ref:`launch-first-instance` and :ref:`using-a-bash-script`
then this part of the process may be extremely familiar to you, and you can
choose to skip to `Automating our install using Cloud-Init`_
if you wish.

Setting up the Network
======================

First we want to set a prefix value for all of our object names so we can avoid
future name conflicts. :code:`rocketchat` is a great choice because that's what
we're going to be installing on our system, although you might want to change
this.

.. code-block:: bash

 # We'll begin with a prefix value for all of our network and instance names.
 PREFIX="rocketchat"

Now we need a network for our instances, and a router to connect that network
to the public internet.

.. code-block:: bash

 # Create our virtual router.
 ROUTER_NAME="${PREFIX}-border-router"
 openstack router create $ROUTER_NAME
 # Connect the virtual router to the public net.
 openstack router set $ROUTER_NAME --external-gateway public-net

 # Create our virtual network
 PRIVATE_NETWORK_NAME="${PREFIX}-private-net"
 openstack network create "$PRIVATE_NETWORK_NAME"

Now we can create the subnet that our rocketchat instance will reside on.
In this case we're going to allocate the address range 10.0.0.10 - 10.0.0.20
of the 10.0.0.0/24 address space.

.. code-block:: bash

  # Allocate addresses 10.0.0.10-10.0.0.20 from our private network to our
  # rocketchat subnet.
  NETWORK="10.0.0"
  POOL_START_OCT="10"
  POOL_END_OCT="20"

  PRIVATE_SUBNET_NAME="${PREFIX}-private-subnet"
  # Create a subnet of our existing virtual network.
  openstack subnet create \
  --allocation-pool "start=${NETWORK}.${POOL_START_OCT},end=${NETWORK}.${POOL_END_OCT}" \
  --dhcp \
  --network "$PRIVATE_NETWORK_NAME" \
  --subnet-range "$NETWORK.0/24" \
  "$PRIVATE_SUBNET_NAME" \

  # Add our subnet to the router
  openstack router add subnet "$ROUTER_NAME" "$PRIVATE_SUBNET_NAME"

The network is now fully set up and configured. We'll connect our rocketchat
instance up later on. For now we need to create some security rules.

Security Settings
=================

It's important to consider what access is needed for our server to serve its
purpose. For the purposes of this tutorial we are keeping these rules fairly
simple.

First we need to create the security group and grab it's id:

.. code-block:: bash

  # Create Security Group
  SECURITY_GROUP_NAME="${PREFIX}-security-group"
  openstack security group create \
  --description 'HTTP/S and SSH access to our rocketchat instance.' \
  $SECURITY_GROUP_NAME
  CC_SECURITY_GROUP_ID=$( openstack security group show "$SECURITY_GROUP_NAME" -f value -c id )

We need to create 3 simple rules.

Firstly, SSH. It's important that we can administer the server via
SSH (potentially to apply updates or changes in future). We could harden these
rules further by restricting SSH access to our own ip address, but we're
assuming we don't have a static IP address.

SSH (port 22):

.. code-block:: bash

  # SSH Rule
  openstack security group rule create \
  --ingress \
  --protocol tcp \
  --dst-port 22 \
  "$CC_SECURITY_GROUP_ID"

Next, because Rocket.Chat uses an in-browser client so we also need to allow
access on ports 80 and 443 for HTTP/S access.

.. code-block:: bash

  # HTTP Rule
  openstack security group rule create \
  --ingress \
  --protocol tcp \
  --dst-port 80 \
  "$CC_SECURITY_GROUP_ID"

  # HTTPS Rule
  openstack security group rule create \
  --ingress \
  --protocol tcp \
  --dst-port 443 \
  "$CC_SECURITY_GROUP_ID"

SSH Keys
--------

We'll use this key to access the Rocket.Chat instance via SSH. These will be
applied to the :code:`ubuntu` user on the Rocket.Chat instance.

.. code-block:: bash

  # Set Key Pair
  SSH_KEY_NAME="$PREFIX-key"
  openstack keypair create --public-key ~/.ssh/id_rsa.pub $SSH_KEY_NAME

Automating our install using Cloud-Init
============================================

Cloud Init is a system for configuring a new instance when it is first
created. It takes all it's directives from a simple YAML file.

Before we start, we should determine all the steps involved so we know exactly
what is happening on our new instance.

Our plan is to :

1) Install nginx
2) Set up nginx as a reverse proxy for rocketchat
3) Install rocketchat-server
4) Generate a Self-Signed SSL certificate for nginx.
5) Reboot to make sure all changes get applied.

Our cloud init file begins with some basic, straightforward settings.

.. code-block:: yaml

  #cloud-config
  hostname: HOST
  manage_etc_hosts: true
  apt_mirror: http://ubuntu.catalyst.net.nz/ubuntu
  timezone: Pacific/Auckland

Any packages we might need can be put in the next section. We only need to
get nginx from our package manager as we'll be getting Rocket.Chat as a snap
package.

.. code-block:: yaml

  packages:
    - nginx

We're going to configure out nginx proxy to redirect all HTTP traffic to HTTPS,
and pass all HTTPS traffic to our Rocket.Chat instance on port 3000.

.. code-block:: yaml

  write_files:
    - path: /etc/nginx/sites-available/rocketchat
      content: |
        server {
          listen 80;
          listen [::]:80;

          server_name IP_ADDRESS;
          return 301 https://$server_name$request_uri;
        }

        server {
          listen 443 ssl;
          listen [::]443 ssl;

          server_name IP_ADDRESS;

          ssl_certificate /etc/ssl/certs/nginx-self-signed.crt;
          ssl_certificate_key /etc/ssl/private/nginx-self-signed.key;

          #SSL Settings for added security.
          ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
          ssl_prefer_server_ciphers on;
          ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
          ssl_ecdh_curve secp384r1;
          ssl_session_cache shared:SSL:10m;
          ssl_session_tickets off;
          ssl_stapling on;
          ssl_stapling_verify on;
          resolver 8.8.8.8 8.8.4.4 valid=300s;
          resolver_timeout 5s;
          add_header Strict-Transport-Security "max-age=63072000;";
          add_header X-Frame-Options DENY;
          add_header X-Content-Type-Options nosniff;

          ssl_dhparam /etc/ssl/certs/dhparam.pem;

          location / {
            proxy_pass http://127.0.0.1:3000/;
          }
        }

Finally, we need to install the Rocket.Chat server, enable our nginx config,
and generate our SSL certificates. We'll finish with a reboot so that we can
restart everything.

.. code-block:: yaml

  runcmd:
    - apt-get update
    - snap install rocketchat-server
    - touch /etc/nginx/sites-available/rocketchat
    - ln -s /etc/nginx/sites-available/rocketchat
      /etc/nginx/sites-enabled/rocketchat
    - openssl req -x509 -nodes -days 365 -newkey rsa:2048
      -keyout /etc/ssl/private/nginx-self-signed.key
      -out /etc/ssl/certs/nginx-self-signed.crt
      -subj "HTTPS_CERT_SETTINGS"
    - openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
    - reboot
  #

Save this file as :code:`rocketchat.xenial`. This naming convention means if
we wanted to install this on another version of Ubuntu, such as Bionic(18.04)
or Trusty(14.04), then we can just make another cloud init file with that
distro as the file extension.

Creating the Rocket.Chat instance
=================================

When we create an instance we have to decide what specifications we want.
In this case we're going to install Ubuntu 16.04 (Xenial), with a 1vCPU and
1GB RAM setup. This should be enough resources for a Rocket.Chat install.

We're also going to set the name of our instance, and get the id of our
private network, so that we can generate an IP address for the instance.

.. code-block:: bash

  # Parameters for instance
  INSTANCE_NAME="${PREFIX}-chat1"
  FLAVOR="c1.c1r1"
  IMAGE_NAME="ubuntu-16.04-x86_64"

  # Relevant ID values for instance parameters
  CC_FLAVOR_ID=$( openstack flavor show "$FLAVOR" -f value -c id )
  CC_IMAGE_ID=$( openstack image show "$IMAGE_NAME" -f value -c id )
  CC_PRIVATE_NETWORK_ID=$( openstack network show "$PRIVATE_NETWORK_NAME" -f value -c id )

We need an IP address so we're going to check if we have any free, or request
that one be allocated to us.

.. code-block:: bash

  # Get an IP address.
  CC_FLOATING_IP_ID=$( openstack floating ip list -f value -c ID --status 'DOWN' | head -n 1 )
  if [ -z "$CC_FLOATING_IP_ID" ]; then
      echo No floating ip found creating a floating ip:
      CC_PUBLIC_NETWORK_ID=$( openstack network show public-net -f value -c id )
      openstack floating ip create "$CC_PUBLIC_NETWORK_ID"
      echo Getting floating ip id:
      CC_FLOATING_IP_ID=$( openstack floating ip list -f value -c ID --status 'DOWN' | head -n 1 )
  fi

  CC_PUBLIC_IP=$( openstack floating ip show "$CC_FLOATING_IP_ID" -f value -c floating_ip_address )

We have all the necessary details to set up our SSL Certificate.
You should modify these values to your own, bearing in mind that the
:code:`COUNTRY` value will always be a 2 letter code.

.. code-block:: bash

  # OpenSSL settings so we can have a self signed certificate
  CN="NZ"                     #Country
  ST="My Province"            #State
  LC="My City"                #Locality
  ON="My Organisation"        #Organisation Name
  OD="My Organisations Dept"  #Organisation Dept

  CERT_SETTINGS="\/C=${CN}\/ST=${ST}\/L=${LC}\/O=${ON}\/OU=${OD}\/CN=${CC_PUBLIC_IP}"

Now, we need to overwrite a few of the default settings we put in the
cloud init file. These are related to our hostname, ip address and ssl cert
details.

.. code-block:: bash

  CLOUD_INIT_FILE=`pwd`/rocketchat.xenial

  sed -i "s/HOST/${INSTANCE_NAME}/" $CLOUD_INIT_FILE
  sed -i "s/IP_ADDRESS/${CC_PUBLIC_IP}/" $CLOUD_INIT_FILE
  sed -i "s/HTTPS_CERT_SETTINGS/${CERT_SETTINGS}/" $CLOUD_INIT_FILE

Now we can create our Rocket.Chat instance.

.. code-block:: bash

  openstack server create \
  --flavor "$CC_FLAVOR_ID" \
  --image "$CC_IMAGE_ID" \
  --key-name "$SSH_KEY_NAME" \
  --security-group default \
  --security-group "$SECURITY_GROUP_NAME" \
  --nic "net-id=$CC_PRIVATE_NETWORK_ID" \
  --user-data "$CLOUD_INIT_FILE" \
  "$INSTANCE_NAME"

  until [ "$INSTANCE_STATUS" == 'ACTIVE' ]
  do
    INSTANCE_STATUS=$( openstack server show "$INSTANCE_NAME" -f value -c status )
    sleep 2;
  done

The last thing to do is apply our floating IP address to our server, so
that we can SSH into it.

.. code-block:: bash

  openstack server add floating ip "$INSTANCE_NAME" "$CC_PUBLIC_IP"
  echo "ssh ubuntu@${CC_PUBLIC_IP}"

Run from a shell using

.. code-block:: bash

  $ bash setup.sh

The cloud-init script may take some time to run, so hold tight and wait for
the server to complete its set up and reboot.

If the install has worked, you should be able to open your IP address in a
browser and see an SSL certificate warning. You can add an exception as we know
that we signed the certificate ourselves. After that you should see the setup
for your Rocket.Chat server.

If anything goes wrong, you should be able to find a log file under
:code:`/var/log/cloud-init-output.log` which may help determine which
command isn't running properly.
