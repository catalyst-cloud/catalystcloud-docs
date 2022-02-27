##################################
Deploying Nextcloud on an instance
##################################

This tutorial assumes that you have the following prepared:

* An SSH key.

* A domain name.

You may also need the following depending on your preference:

* Knowledge of how to create and use volumes (if you are using your own
  volume).

* A volume created for storing Nextcloud data (if you are using terraform).

************
Introduction
************

Nextcloud is a free and open source suite of client-server software which
manages the creation and hosting of files. It is becoming a popular alternative
to similar software such as Dropbox and Google Drive. This tutorial will guide
you through the process of setting up a Nextcloud instance on the Catalyst
Cloud.

****************************************
Creating a Nextcloud instance using Heat
****************************************

============
Instructions
============

1. Navigate to the `Launch a stack`_ section of the dashboard.
2. Select "URL" from the "Template Source" drop down menu.
3. Copy and paste the following address in the "Template URL" box:

.. code-block:: bash

  https://raw.githubusercontent.com/catalyst-cloud/catalystcloud-orchestration/master/nextcloud/heat/nextcloud-combined.yaml

4. Click "Next"
5. Fill out the fields here as required. You will need to include your
   domain-name and hostname at this stage.
6. Click "Launch"

It will take roughly 5 - 6 minutes for the instance to configure. After which,
putting the domain name into your browser will take you to your Nextcloud
instance.

*************************
Launching with Terraform
*************************

.. Note::

  This requires knowledge of the Linux command line and how to use terraform templates.

====================
Installing Terraform
====================

First, before we jump in to creating any resources using terraform, we'll need
to prepare all of the tools that we're going to use in this tutorial. For that
we can use the following code snippets:

First, before we jump in to creating any resources using terraform, we'll need
to prepare all of the tools that we're going to use in this tutorial. For that
we can use the following code snippets:

.. code-block:: bash

  $ sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
  $ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  $ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  $ sudo apt-get update && sudo apt-get install terraform


======================================
Downloading template files from Github
======================================

Our next step is to gather a set of terraform template files, from which we can
create our resources. For this example, we will be downloading a set of
template files from the Catalyst Cloud github found at
`catalyst cloud orchestration`_. Open up a terminal and run the following:


.. code-block:: bash

  $ sudo su
  $ mkdir /nextcloud-terraform
  $ cd /nextcloud-terraform
  $ wget https://raw.githubusercontent.com/yvonnewat/catalystcloud-orchestration/new/add-systemd-services/nextcloud/terraform/nextcloud.tf
  $ wget https://raw.githubusercontent.com/yvonnewat/catalystcloud-orchestration/new/add-systemd-services/nextcloud/terraform/cloud-init-nextcloud.tpl

=======================================
Using a terraform configuration file
=======================================

A template file should describe all the aspects of your system that you want to
be constructed by Terraform. These aspects are resources such as the network,
subnet, router, ssh key, and of course your instance itself. It is recommended
to use the template provided above as it contains all of the necessary
resources you will need for this tutorial.

Before using the template, you will only need to make sure to
change the following to your own so that the template functions on your
project:

- key name,
- domain name,
- host name
- and ddns password

The terraform guide to writing your own configuration files, such as the one
used for this template can be found at: `Terraform documentation`_

The user_data section should also be changed so the the template file contains
the file path of the cloud-init configuration file you intend to use.


==========================
Using a cloud init file
==========================

The `cloud init`_ file configures the software on an instance when it
boots for the first time. In our case we want to install Nextcloud at runtime,
so our cloud init file is set up to install docker and write systemd services
to the instance. This is because we will be using a containerized version of
Nextcloud.

The containers started in the setup script are Nextcloud, `NGINX`_ and the
`NGINX_proxy_acme_companion`_. The NGINX container is a reverse proxy for
Nextcloud, and ensures communication with the Nextcloud server is encrypted.
The acme companion automatically configures some letsencrypt certificates for
the server using the ACME protocol.

===================================
Creating your stack using terraform
===================================

The `cloud init`_ file configures the software on the instance when it
starts for the first time. In our case we want to install Nextcloud,
so the cloud init file installs docker and writes systemd services
to the instance.

The containers started in the setup script are Nextcloud, `NGINX`_ and the
`NGINX_proxy_acme_companion`_. The NGINX container is a reverse proxy for
Nextcloud, and ensures communication with the Nextcloud server is encrypted.
The acme companion automatically configures the letsencrypt certificates for
the server using the ACME protocol.


Now that we have all of the required software installed and our resources
defined in our template files, we can use Terraform to construct our resources
on the cloud.

.. code-block:: bash

  $ cd nextcloud-terraform
  $ terraform init
  $ terraform plan
  $ terraform apply --var domain_name="<your-domain-name>" --var host_name="<your-host-name>" --var ddns_password="<your-ddns-password>" --var file_upload_size="<size in mega-bytes>m" --var keyname="<your-key-name>" --var volume_uuid="<volume id>" --var image_type="<preferred-image-type>" --var flavor_type="<preferred-flavor-type>"


.. Note::

  a) If you choose to use an existing volume, replace ``volume id`` with the id of your previously created volume for the Nextcloud database.

  b) Only change the ``file_upload_size`` if you require more than the default (1024MB).

  c) A floating IP should be generated and printed after this step, it is recommended you take note of this as you may need it later.

=======================================================
Check that Nextcloud has finished installing (Optional)
=======================================================

Open a terminal and type,

.. code-block:: bash

  $ ssh ubuntu@<floating-ip-address>

When prompted if you'd like to connect to this ip address, answer yes.

When this is finished you should find yourself accessing the server remotely.
Next type,

.. code-block:: bash

  $ test -f /deploy-complete && echo "OK"

If the terminal prints, "OK" Nextcloud is installed. Otherwise you may have to
wait a few more minutes until it is finished.

==============================
Access your Nextcloud instance
==============================

After waiting around 5-10 minutes, you can now access Nextcloud by typing the
domain name into a browser!

**********************
Configuring Nextcloud
**********************

Upon first accessing Nextcloud, you will find it asks for an admin to sign up.
Please choose the appropriate person in your organisation to complete this
step. The admin role can add and remove users as well as enable and disable
services.

Services that the Nextcloud container installs with:

* Dashboard

* Files

* Photos

* Activity

* Talk

* Mail

* Contacts

* Calendar

For a complete view of all the services Nextcloud offers, visit
`Nextcloud apps`_.

How to configure each service:

* Dashboard

  - The dashboard can be changed to show updates on services you're interested
    in via the **customise** button at the bottom of the screen.

* Files

  - Files can be added by pressing the plus in the upper left hand corner,
    these files can be up to 100MB in size.

* Mail

  - Manual set up is recommended.

  - See `Thunderbird documentation`_ for setting up Nextcloud with Thunderbird
    mail &calendar.

* Calendar

  - You can import a calendar as a file or synchronize the Nextcloud calendar
    with one of your own.

  - If you want to synch it with a Thunderbird calendar, see the `Thunderbird
    documentation`_ for setting up Thunderbird mail.

* Contacts

  - You can import a vCard file or add your contacts manually.

  - Contacts are added automatically when you send emails.

****************
Nextcloud Mobile
****************

If you would like to use Nextcloud on your phone, there is an app available for
Android and iOS. It is recommended you set this up by scanning the QR code
which can be found by going into Settings -> Security -> Create new app
password -> Show QR code for mobile apps.

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
