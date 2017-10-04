.. _launching-your-first-instance:

********
Overview
********

This section will demonstrate how to build an Ubuntu 14.04 server in a new
OpenStack project. After you have completed the steps, you will be able to log
on to the server via SSH from anywhere on the internet using an SSH key.

The following is assumed:

* A Catalyst Cloud account has been set up for you
* You have been assigned a project
* Your user in that project has permissions to create the required resources.

When a new project is created, a network, subnet, and router are built by default.
The process below outlines the steps required to do this if the
default setup has been deleted or an additional network is required.

.. note::

    Steps 1 & 2 below can be skipped on a new project where the default
    networking is still in place. The creation of your first instance
    can proceed from step 3.

Here are the steps for creating your first cloud instance:

1. Create a Network and Subnet
2. Create a Router
3. Upload an SSH Keypair
4. Create a Security Group
5. Launch an Instance
6. Associate a Floating IP
7. Log in to your Instance

There are a number of different ways to provision resources on the Catalyst
Cloud. We will show you how to complete these steps using the dashboard and the
command line tools. If you are not comfortable with the command line, it will
be easier to use the dashboard. As you become more familiar with the Catalyst
Cloud it is worth learning how to provision resources programmatically.

You are free to use whichever method suits you. You can use these methods in
isolation or they can be combined. If you do not use the dashboard to launch
the compute instance, it can still be useful to use it to verify the
stack you have created via another method.

Network Requirements
====================

Before launching an instance, it is necessary to have some network resources in
place. These may have already been created for you. In this documentation we
will assume you are starting from an unconfigured project and will demonstrate
how to set these up from scratch.

The requirements are:

* A Network
* A Subnet with addressing and DHCP/DNS servers configured
* A Router with a gateway set and an interface in a virtual network

Catalyst operates, free of charge, a number of recursive DNS servers in each
cloud region for use by Catalyst Cloud instances. They are:

.. _name_servers:

+----------+------------------------------------------------+
|  Region  | DNS Name Servers                               |
+==========+================================================+
| nz-por-1 | 202.78.247.197, 202.78.247.198, 202.78.247.199 |
+----------+------------------------------------------------+
| nz_wlg_2 | 202.78.240.213, 202.78.240.214, 202.78.240.215 |
+----------+------------------------------------------------+
| nz-hlz-1 | 202.78.244.85, 202.78.244.86, 202.78.244.87    |
+----------+------------------------------------------------+


When creating a router and network/subnet, keep any network requirements in mind
when choosing addressing for your networks. You may want to build a tunnel-mode
VPN in the future to connect your OpenStack private network to another private
network. Choosing a unique subnet now will ensure you will not experience
collisions that need renumbering in the future.

Compute Flavors
===============

The flavor of an instance is the CPU, memory and disk specifications of a
compute instance. Catalyst flavors are named 'cX.cYrZ', where X is the
'compute generation', Y is the number of vCPUs, and Z is the number of
gigabytes of memory.

.. note::

  Flavor names are identical across all regions, but the flavor IDs will
  vary.

Operating System Images
=======================

In order to create an instance, you will need to have a pre-built operating
system in the form of an Image.  Images are stored in the Image service
(Glance). The Catalyst Cloud provide a set of images for general use and also
allows you to upload your own images.

.. note::

 Image IDs for the same operating system will be different in each region.
 Further, images are periodically updated, receiving new IDs over time. You
 should always look up an image based on its name and then retrieve the ID
 for it.

Uploading an SSH key
====================

When an instance is created, OpenStack will pass an ssh key to the instance
which can be used for shell access. By default, Ubuntu will install this key
for the 'ubuntu' user. Other operating systems have different default users, as
listed here: :ref:`images`

.. Tip::

 Name your key using information such as the username and host on which the
 ssh key was generated so that it is easy to identify later.

Keypairs must be created in each region being used.

Security Groups
===============

Security groups are akin to a virtual firewall. All new instances are put in
the 'default' security group. When unchanged, the default security group allows
all egress (outbound) traffic, but will drop all ingress (inbound) traffic. In
order to allow inbound access to your instance via SSH, a security group rule is
required.

While you could create security group rules within the default group to allow
access to your instance, it is sensible to create a new group to hold the rules
specific to your instance. This is a useful way to group the rules associated
with your instance and provides a convenient way to delete all rules for an
instance when you need to clean up resources. It is also a useful way to assign
the same rules to subsequent instances that you may create.

.. warning::

  Note that by using the CIDR 0.0.0.0/0 as a remote, you are allowing access
  from any IP to your compute instance on the port and protocol selected. This
  is often desirable when exposing a web server (eg: allow HTTP and HTTPs
  access from the Internet), but is insecure when exposing other protocols,
  such as SSH, Telnet and FTP. We strongly recommend you to limit the exposure
  of your compute instances and services to IP addresses or subnets that are
  trusted.

Floating IPs
============

In order to connect to your instance, you will need to allocate a floating IP
to the instance. Alternately, you could create a VPN and save some money by
avoiding floating IPs altogether. VPNs are not feasible when the instance
will be offering a service to the greater internet.
