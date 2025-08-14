.. _introduction-to-catalyst-cloud:

##################################
Introduction to the Cloud platform
##################################

This section of the documentation is for people that are entirely new to cloud
computing and/or Catalyst Cloud.


*****************************************
What is different about a Cloud platform?
*****************************************

While on the surface there are many similarities between the purchasing of VMs
from a host provider and using a cloud provider to provision compute instances;
looking closer at both platforms reveals that they have some striking
differences.

In the past you may have purchased a series of virtual machines with a specific
size for RAM and storage space. You would then pay a predefined amount for
these virtual machines on a monthly basis. If you wanted to increase the size
of your storage, RAM or the amount of virtual machines you are using, you would
have to renegotiate the price of your monthly bill. While you had this
‘subscription’ the virtual machines were yours and you paid the same price
regardless of how much you used them; meaning that if you only used them for a
week or anything less than 24/7 you were not getting the most out of your
monthly bill.

On a cloud based system you only pay for what is used and you can change your
resources on the fly. If you need to horizontally scale an instance you can
simply spin up more compute nodes. If you need to increase the size of your
block storage, then you can add a new volume to your instance, or you can use
our object storage service as an alternative. In a cloud environment your
instances and other resources are scheduled by the cloud and you are only
billed for the amount of resources you use.

For example: you need an instance to crunch numbers for a day. In a cloud
system you only pay for however long it takes to complete your task. In a
traditional system you would have to pay for an entire month of use.
On the Catalyst Cloud, you only pay your instances down to the minute. And if
you need more power for the instance during your number crunching you can
increase the compute capacity without having to confirm with your provider
first. Saving yourself money and the hassle of negotiating changes. Once you
are done with your task you can turn off your instance, release any other
resources, and the bill stops there.

***********************
What is Catalyst Cloud?
***********************

Catalyst Cloud is a cloud computing platform, based entirely in New Zealand.

Catalyst Cloud was built with the open source project, `OpenStack`_. Using
OpenStack our Cloud allows users like yourself to provision services.
Provisioning is similar to renting. You can provision things such as storage
space, compute capacity, or Internet access. The building blocks you need to
run a business's applications.

.. note::
   Openstack requires a python interpreter to function and
   is currently phasing out it's support for Python2. We therefore recommend
   running Openstack using Python3.

.. _`OpenStack`: https://www.openstack.org/software/

OpenStack gives you the ability to provision no more or less than what you
need, by allowing you to change how much you are using quickly, easily, and
automatically, through a variety of tools.

.. image:: assets/access_methods.png

To obtain resources on Catalyst Cloud, you provision services. Catalyst Cloud
services are pieces of hardware and software that we have in one of our data
centres. We make these easy and convenient to use through
a variety of tools including our Dashboard web application, the command
line interface or a number of orchestration services.

By exposing our hardware and software as services, we remove a lot of
complexity from your day to day work. For example: you need to give a
server it's own public IP address. You open a terminal and run:

.. code-block:: console

  $ openstack floating ip create public-net

  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | created_at          | None                                 |
  | description         | None                                 |
  | fixed_ip_address    | None                                 |
  | floating_ip_address | 150.242.41.224                       |
  | floating_network_id | 849ab1e9-7ac5-4618-8801-xxxxxxxxxxxx |
  | id                  | 415fa158-fd7d-4b43-9002-xxxxxxxxxxxx |
  | name                | 150.242.41.224                       |
  | port_id             | None                                 |
  | project_id          | 8ccc3286887e49cbxxxxxx23eba693b4     |
  | qos_policy_id       | None                                 |
  | revision_number     | None                                 |
  | router_id           | None                                 |
  | status              | DOWN                                 |
  | subnet_id           | None                                 |
  | tags                | []                                   |
  | updated_at          | None                                 |
  +---------------------+--------------------------------------+

Now you have provisioned a public IP address. Now you run:

.. code-block:: console

  $ openstack server add floating ip my_server_name 150.242.41.224

Just like that, your server has a public IP address in seconds. Quick, easy
and powerful. Every action on Catalyst Cloud can be performed just as quickly.

Now we understand the basic idea behind Catalyst Cloud, let's explore what
services Catalyst Cloud provides.


:ref:`Next page <services_on_the_catalyst_cloud>`
