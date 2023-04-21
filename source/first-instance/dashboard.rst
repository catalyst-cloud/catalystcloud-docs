#######################
Using the web dashboard
#######################

.. _first-instance-with-dashboard:

The web dashboard is the easiest way of creating an instance as you can
visually see your resources being built with each step. The dashboard itself is
also easy to navigate and you should be able to follow the steps below
regardless of your background with cloud based systems.

****************
Before you begin
****************

1) We assume you've already `signed up <https://catalystcloud.nz/signup/>`_ to
   the Catalyst Cloud.
2) Log in to the dashboard at https://dashboard.catalystcloud.nz/
3) As a new user to the Catalyst Cloud your initial cloud project will come with
   a pre-configured private network and a router connected to the internet in
   the Hamilton region. We still cover the proper steps to creating these
   networking resources in this tutorial; in the case you wish to follow these
   steps to create a network on a different region.

Otherwise, let's proceed with building your first instance.

********************
Networking resources
********************

This section will cover how to create the networking resources required to host
your instance. Should you already have them available on your project, then you
can ignore this section of the tutorial and move on to "uploading an ssh key"

.. include:: ../network/_scripts/create-network-dashboard.rst

********************
Uploading an SSH key
********************

The first thing we need to do is to have a way to access the instances we
create. Typically this is done by a Secure Shell tunnel, or SSH. To allow our
instance to accept our workstation's SSH tunnel request, we must add our SSH
public key to our instance. We can do this right from the dashboard.

You can either import an existing public key or have the Catalyst Cloud
create a key pair for you. We document both below.

Creating a new key pair
=======================

If you haven't generated a SSH key pair before, Catalyst Cloud can create one
for you.

Navigate to the ``Key Pairs`` tab.

.. image:: dashboard_assets/key-pair-tab.png

Select the ``Create Key Pair`` button.

.. image:: dashboard_assets/key-pair-buttons.png

Name and create the key pair.

.. image:: dashboard_assets/new-key-pair.png

Click ``Copy Private Key to Clipboard`` and paste it into a text file in a
secure location. Make sure the file is saved as plain text.

Importing an existing key pair
==============================

If you already have an SSH key pair, you can import the public key into
Catalyst Cloud.

Navigate to the ``Key Pairs`` tab.

.. image:: dashboard_assets/key-pair-tab.png

Select the ``Import Key Pair`` button.

.. image:: dashboard_assets/key-pair-buttons.png

Name the key pair, and paste your public key into the box.

.. image:: dashboard_assets/import-key-pair.png


Now that you've either imported or created an SSH key pair, we can continue.

*********************************
Configure instance security group
*********************************

By default, instances are inaccessible from all external IP addresses on all
ports. So we'll need to create an extra security group to let us SSH into the
instance we're about to create.

Navigate to the ``Security Groups`` tab.

.. image:: dashboard_assets/security-group-tab.png

Now we'll create a new security group, specific to allowing SSH access.
Select ``Create Security Group`` , give it a name, and create it.

.. image:: dashboard_assets/create-security-group.png

Now select manage rules for your new security group.

.. image:: dashboard_assets/select-manage-rules.png

As you can tell, by default security rules allow egress of all traffic, and
allow no ingress of traffic. By adding additional rules, we can whitelist new
types of traffic, coming from new IP addresses. Note that you can assign more
than one security group to an instance.

Select add rule.

.. image:: dashboard_assets/sec-rule-list.png

Here we can see the add rule screen. Many options are available to us.

.. image:: dashboard_assets/add_rule_screen.png

Change the ``Rule`` dropdown to ``SSH``. If you'd like to restrict SSH requests
to just your IP address, you could change the ``CIDR`` option to your IP
address. Here however, I've left it as ``0.0.0.0/0``, to allow SSH access
**from all IP addresses**. Obviously, this would be an insecure thing to do
when working in a real production environment, but I'm leaving it like this for
convenience.

When you're happy, select ``Add`` to add the rule to the security group.

.. image:: dashboard_assets/add-ssh-rule.png


We now have a security group that will allow SSH access to our soon to be
created instance.

*******************
Booting an instance
*******************

We are now ready to launch our first instance! Navigate to the ``Instances``
page.

.. image:: dashboard_assets/instances-tab.png

Select launch instance.

.. image:: dashboard_assets/launch-instance-button.png

Name your instance.

.. image:: dashboard_assets/name-instance.png

Navigate to the ``Source`` tab.

There are many types of sources you can use for your instance. In this case,
we'll use an Image to create a standard Ubuntu installation.

.. image:: dashboard_assets/vanilla-image.png

Search for Ubuntu.

Select the image for Ubuntu 18.

By default the volume will just be large enough to hold the image's files.
We'll increase it to 100GB so we have enough space for later.

.. image:: dashboard_assets/ubuntu-source.png

Navigate to the ``Flavor`` tab. This is where we select the compute resources
we want to assign to our compute instance.

Order the flavors by ``VCPUS``, and select an appropriate size.

.. image:: dashboard_assets/setting-flavor.png

Navigate to the ``Security Groups`` tab. Add your new security group.

.. image:: dashboard_assets/setting-sec-rules.png

Navigate to the ``Key Pair`` tab. Your key pair should already be assigned, but
if it's not, do it now. This will inject your public key into the new instance,
so that your private key will be accepted for SSH connections.

.. image:: dashboard_assets/setting-key-pair.png

All the other tabs are for advanced features, and we can safely ignore them for
now.

Select ``Launch Instance``.

Wait for your instance to launch.

.. image:: dashboard_assets/launching-instance.png

Finally, to make your instance accessible, we need to give it a publicly
available, static IP address, because currently the instance only has an
internal IP address from instance's subnet. These are ``Floating IPs``.

Use the instance's dropdown to find the ``Associate Floating IP`` option and
select it.

.. image:: dashboard_assets/finding-floating-ip.png

Select the ``+`` to create a new floating IP address.

.. image:: dashboard_assets/assigning-floating-ip.png

Select ``Allocate IP`` to provision yourself a floating IP address.

.. image:: dashboard_assets/creating-floating-ip.png

The new floating IP should already be assigned.

Select ``Associate`` to associate it to your instance.

The floating IP is a way to access your new instance.

.. image:: dashboard_assets/set-floating-ip.png

|

Congratulations, you've now booted an instance. Now we'll connect to it with an
SSH tunnel so you can start using it.

***************************
Connect to the new instance
***************************

Before we SSH in, we should give the private SSH key the correct, more secure
permissions.

.. code-block:: bash

  $ chmod 600 <path to private key>

You can now connect to the SSH service using the floating IP that you
associated with your instance. This address is visible in
the Instances list, or under the ``Floating IPs`` window.

.. code-block:: bash

 $ ssh -i <path to private key> ubuntu@<your floating ip>

You should be able to SSH into, and interact with this instance as you would
any Ubuntu server.

***********************
Learning more from here
***********************

Now you've learned a great deal about Catalyst Cloud instances, security groups
, floating ips, SSH key pairs, and images. To move forward from here, you might
want to:

* :ref:`Install the command line interface. <command-line-interface>`
* :ref:`Install Ansible, and use it to deploy a new instance.
  <launching-your-first-instance-using-ansible>`
