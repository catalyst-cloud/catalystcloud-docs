########################################################
Deploying Matrix Synapse on Catalyst Cloud using Ansible
########################################################

This tutorial assumes the following:

* Completed the first-instance Ansible tutorial
* Comfortable using SSH to access an instance and run commands.
* Have an instance set up already to host your chat server, with port 8448
  open in addition to ports 80 and 443.
* A domain with an A record with the hostname :code:`@` on the instance

  **OR**

* A sub-domain  with an A record with the hostname set to the subdomain and a 
  SRV record with the hostname :code:`_matrix._tcp` pointing to port 
  :code:`8448` on the target instance. 

Introduction
============

Matrix is an open source, decentralized, and encrypted communication protocol.
Data is not necessarily stored on a single server but in all servers 
participating in a particular room. The goal is to make it as easy to 
communicate as sending an email, meaning there is no requirement on using a
particular device or application, just support for the Matrix protocol.

Servers in matrix can be federated, allowing your server to communicate 
with other servers and your identity can be stored on your own homeserver, 
whilst allowing that identity to be used elsewhere.

Matrix also has support for bridging to other protocols (such as IRC!), 
however that is outside of the scope of this tutorial. If you're interested 
you can find more information at matrix.org/docs/guides/faq.html

We're going to use Ansible to automatically install Synapse, the reference 
server implementation of the Matrix protocol. It is implemented in Python and, 
at the time of writing, is the most installed Matrix homeserver implementation. 
We're not going set up an instance on Catalyst Cloud as this has already been 
covered by the first-instance tutorials.

Creating our Playbook
=====================

We want to begin by adding our hostname so that Ansible knows what to do with 
it. Open :code:`/etc/ansible/hosts` on your machine in your preferred text 
editor (this will require sudo/root access) and add the following block to 
the end:

.. code-block:: yaml

 [chatservers]
 mydomain.com ansible_user:ubuntu

This will tell Ansible which set of hosts to run our playbook on. If we 
wanted to deploy to multiple hosts they could all be added to the chatservers 
host group and the same playbook would run on them also.

Beginning the Installation
==========================

To begin with we're going to create a new file and save it as 
:code:`matrixchat-playbook.yml`

In this file we'll create our play for installing Synapse. To begin with we 
need to make sure that Python 2 is installed on the target machine because 
Ansible relies on it. Then we'll let it go through the setup stage of 
gathering gathering facts about the machine.

.. code-block:: yaml

 - name: Setup the Matrix Server
   hosts: chatservers
   become: yes
   gather_facts: no
   vars:
     server_name: "{{ inventory_hostname }}"
   pre_tasks:
     - name: 'Install Python 2'
       raw: sudo apt-get update && sudo apt-get -y install python-minimal
     - action: setup

We're going to want to use HTTPS later so we'll add the repository for certbot.

.. code-block:: yaml

   tasks:
     - name: Add certbot repo for Let's Encrypt Certs
       apt_repository:
         validate_certs: no
         repo: 'ppa:certbot/certbot'
         state: present
 
     - name: update aptitude cache
       apt:
         update_cache: yes


Installing Synapse & Dependencies
=================================

We're going to install and build Synapse. To do this we'll need a few 
dependencies. We're also doing to install nginx configured as a reverse proxy
to enable web access to the built in matrix client.

.. code-block:: yaml

     - name: Install Synapse Prerequisites and Nginx
       action: apt pkg={{ item }} state=present
       with_items:
         - nginx
         - python2.7-dev
         - build-essential
         - libffi-dev
         - python-pip
         - python-setuptools
         - sqlite3
         - libssl-dev
         - python-virtualenv
         - libjpeg-dev
         - libxslt1-dev
         - python-certbot-nginx
 
     - name: Install Synapse
       shell: |
         pip install --upgrade pip 
         pip install --upgrade setuptools 
         pip install https://github.com/matrix-org/synapse/tarball/master


Applying Configurations
=======================

Before our system can do anything, we need to configure it. We're going 
to point our server at port 8008 as this is the port our matrix client runs at.
We don't need to configure an SSL certificate or anything like that just yet, 
we'll do that later. We also need to enable the configuration and restart nginx.

.. code-block:: yaml

     - name: Configure Nginx
       copy:
         dest: "/etc/nginx/sites-available/matrixchat"
         content: |
           server {
               listen 80;
               listen [::]:80;
 
               root /var/www/html;
               index index.html index.htm index.nginx-debian.html;
 
               server_name {{ server_name }};
 
               location / {
                   return 302 https://$server_name/_matrix/client/;
               }
 
               location /_matrix {
                   proxy_pass http://localhost:8008;
               }
 
               location ~ /.well-known {
                   allow all;
               }
           }
 
     - name: Enable nginx configuration
       file:
         src: "/etc/nginx/sites-available/matrixchat"
         dest: "/etc/nginx/sites-enabled/matrixchat"
         state: link
       notify: 
         - Restart nginx

We'll also need to start synapse, generate the keys and configuration and 
also modify the configuration to allow registration. 

.. code-block:: yaml

     - name: Create Synapse Directory
       file: 
         path: /home/ubuntu/.synapse
         state: directory

     - name: Start Synapse
       shell: | 
         python -m synapse.app.homeserver \ 
           --server-name {{ server_name }} \
           --config-path /home/ubuntu/.synapse/homeserver.yaml \
           --generate-config \
           --report-stats=no
 
     - name: Enable Registration
       lineinfile:
         path: /home/ubuntu/.synapse/homeserver.yaml
         regexp: '^enable_registration: False'
         line: 'enable_registration: True'
       notify:
         - Restart Synapse
         - Restart nginx

Once you've reached this point, and hopefully you've been following along 
and saving each block of code as we go, should be able to run the playbook like
this: :code:`ansible-playbook matrixchat-playbook.yml` from a terminal. 

Hopefully nothing breaks and you should be able to go navigate a web browser to
:code:`http://yourdomain.com/_matrix/client/` and see the login for the 
default matrix client. This is served over http and currently HTTPS will fail.
We'll set that up next.


Free HTTPS with Certbot and Let's Encrypt
=========================================

We want to secure communication between users and our server, so to do so 
we'll get an SSL certificate. Earlier when we were installing dependencies 
and software, we also installed an nginx certbot package. Certbot is a tool 
for getting Let's Encrypt certificates without too much hassle.

To begin, SSH into your compute instance and run the following command:

.. code-block:: bash

 $ certbot --nginx -d www.example.com -d example.com

You'll be greeted by a couple of prompts that you'll want to read and answer. 
This automatically modifies the nginx configuration we created earlier. Once 
this is done we need to restart nginx:

.. code-block:: bash

 $ systemctl restart nginx.service 

Navigate to :code:`https://yourdomain.com` and you should see the exact same 
thing as before.


Registering a User
==================

Our server needs users, you can register a user via the web client, or you can 
create one using the command below. This will also prompt if you would 
like the user you are creating to become an admin (for this server) as well.

.. code-block:: bash

 $ register_new_matrix_user -c ~/.synapse/homeserver.yaml https://localhost:8448


Testing
========

Once you've created a user, attempt to login. If you'd like, we can test 
server federation by navigating to another client such as Riot, 
located at https://riot.im/app/

Check the radio button to use a custom server and adjust both server fields to 
your homeservers address and attempt to login with your credentials.
If this works, then your server is federated and you can go and participate on 
other servers with your personal identity.
