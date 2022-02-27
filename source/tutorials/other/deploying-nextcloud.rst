##################################
Deploying Nextcloud on an instance
##################################



This tutorial assumes the following:

* Have an SSH key.

* Have a domain name.

* An A record pointing to localhost (127.0.0.1) under a chosen host name.

* Completed creating and using volumes (if using own volume).

* Have a volume created for storing Nextcloud data (if using terraform).

************
Introduction
************

Nextcloud is a free and open source suite of client-server software which
manages the creation and hosting of files. It is becoming a popular alternative
to similar software such as Dropbox and Google Drive. This tutorial will guide
you through setting up a Nextcloud instance on Catalyst Cloud.

*******************
Launching with Heat
*******************

Note: This requires knowledge of the dashboard

============
Instructions
============

1. Go to `Launch a stack`_.
2. Select "URL" from the "Template Source" drop down menu.
3. Copy and paste

.. code-block:: bash

  https://raw.githubusercontent.com/catalyst-cloud/catalystcloud-orchestration/master/nextcloud/heat/nextcloud-combined.yaml

in the "Template URL" box.

4. Click "Next"
5. Fill out the following fields as required.
6. Click "Launch"

It will take about 5 - 6 minutes for the instance to configure, but after that
put the domain name in the browser to access your Nextcloud instance.

*************************
Launching with Terraform
*************************

Note: This requires knowledge of the Linux command line

=================
Install Terraform
=================

.. code-block:: bash

  sudo apt-get update && sudo apt-get install -y gnupg \
  software-properties-common curl
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com \
  $(lsb_release -cs) main"
  sudo apt-get update && sudo apt-get install terraform


===================================
Download template files from Github
===================================

The template files to download are found at `catalyst cloud orchestration`_.
Open up a terminal and paste the following, as well as instructions at each step (if applicable)

.. code-block:: bash

  sudo su
  mkdir /nextcloud-terraform
  cd /nextcloud-terraform
  wget https://raw.githubusercontent.com/yvonnewat/catalystcloud-orchestration/new/add-systemd-services/nextcloud/terraform/nextcloud.tf

  wget https://raw.githubusercontent.com/yvonnewat/catalystcloud-orchestration/new/add-systemd-services/nextcloud/terraform/cloud-init-nextcloud.tpl


====================================
Write a terraform configuration file
====================================

This file should describe all the aspects you want to set up as well as the
instance. These include aspects such as the network, subnet, router, ssh key,
server etc. It is recommended to use the template provided, just make sure to
change the key name, domain name, host name and ddns password to your own. This
template can be found at `catalyst cloud orchestration`_, as well as the instructions
on how to run it. The terraform guide to writing a configuration file such as the
one used for this template can be found at

`Terraform documentation`_

The user_data section should also be changed so the the template file contains
the file path of the cloud-init configuration file you intend to use.

=======================
Write a cloud init file
=======================

The `cloud init`_ file configures the software on the instance when it
starts for the first time. In our case we want to install Nextcloud,
so the cloud init file installs docker and writes systemd services
to the instance.

The containers started in the setup script are Nextcloud, `NGINX`_ and the
`NGINX_proxy_acme_companion`_. The NGINX container is a reverse proxy for Nextcloud, and
ensures communication with the Nextcloud server is encrypted. The acme companion
automatically configures the letsencrypt certificates for the server using the
ACME protocol.

================================
Create the stack using terraform
================================

.. code-block:: bash

  cd nextcloud-terraform
  terraform init
  terraform plan
  terraform apply --var domain_name="<your-domain-name>" --var host_name="<your-host-name>" --var ddns_password="<your-ddns-password>" --var file_upload_size="<size in mega-bytes>m" --var keyname="<your-key-name>" --var volume_uuid="<volume id>" --var image_type="<preferred-image-type>" --var flavor_type="<preferred-flavor-type>"

Note:
a) If you choose to use an existing volume, replace volume id with the id of your previously created volume for the
Nextcloud database.

b) Only change the `file_upload_size` if you require more than the default (1024MB).

c) Floating IP should be generated and printed after this step, it is
recommended you take note of this as you may need it later.

=======================================================
Check that Nextcloud has finished installing (Optional)
=======================================================

Open a terminal and type,

``ssh ubuntu@<floating-ip-address>``

When prompted if you'd like to connect to this ip address, answer yes.

When this is finished you should find yourself accessing the server remotely.
Next type,

``test -f /deploy-complete && echo "OK"``

If the terminal prints, "OK" Nextcloud is installed. Otherwise you may have to
wait a few more minutes until it is finished.

==============================
Access your Nextcloud instance
==============================

After waiting around 5-10 minutes, you can now access Nextcloud by typing the
domain name into a browser!

*******************
Configure Nextcloud
*******************

Upon first accessing Nextcloud, you will find it asks for an admin to sign up.
Please choose the appropriate person in your organisation to complete this step.
The admin role can add and remove users as well as enable and disable services.

Services that the Nextcloud container installs with:

* Dashboard

* Files

* Photos

* Activity

* Talk

* Mail

* Contacts

* Calendar

For a complete view of all the services Nextcloud offers, visit `Nextcloud apps`_.

How to configure each service:

* Dashboard

  - The dashboard can be changed to show updates on services via the **customise** button at the bottom of the screen.

* Files

  - Files can be added by pressing the plus in the upper left hand corner, these files can be up to 100MB in size.

* Mail

  - Manual set up is recommended.

  - See `Thunderbird documentation`_ for setting up Nextcloud with Thunderbird mail &calendar.

* Calendar

  - You can import a calendar as a file or synchronize the Nextcloud calendar with one of your own.

  - See the `Thunderbird documentation`_ if you want to set up Thunderbird mail.

* Contacts

  - You can import a vCard file or add your contacts manually.

  - Contacts are added automatically when you send emails.

****************
Nextcloud Mobile
****************

If you would like to use Nextcloud on your phone, there is an app available for
Android and iOS. It is recommended you set this up by scanning the QR code which
can be found by going into Settings -> Security -> Create new app password ->
Show QR code for mobile apps.

The Nextcloud mobile application is primarily for accessing files and does not
have the same tools as the desktop version. There is also a Nextcloud Talk
application available.

***************
Further Reading
***************

`Nextcloud Manual`_

***************
Link References
***************

.. target-notes::

.. _`Launch a stack`: https://dashboard.cloud.catalyst.net.nz/project/stacks/select_template
.. _`catalyst cloud orchestration`: https://github.com/catalyst-cloud/catalystcloud-orchestration/tree/master/nextcloud/terraform
.. _`Terraform documentation`: https://www.terraform.io/docs/language/index.html
.. _`cloud init`: https://cloudinit.readthedocs.io/en/latest/topics/examples.html
.. _`NGINX`: https://nginx.org/en/docs/
.. _`NGINX_proxy_acme_companion`: https://github.com/nginx-proxy/acme-companion
.. _`Nextcloud apps`: https://apps.nextcloud.com/
.. _`Thunderbird documentation`: https://docs.nextcloud.com/server/latest/Nextcloud_User_Manual.pdf#section.5.6
.. _`Nextcloud Manual`: https://docs.nextcloud.com/server/latest/Nextcloud_User_Manual.pdf
