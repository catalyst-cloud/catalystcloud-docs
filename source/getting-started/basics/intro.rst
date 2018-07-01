############
Introduction
############

This section of the documentation is for people that are entirely new to cloud
computing and/or the Catalyst Cloud.


***************************
What is the Catalyst Cloud?
***************************

Catalyst Cloud is a New Zealand cloud computing platform with three regions
on-shore and prices comparable to global cloud providers.

The Catalyst Cloud provides you with all the building blocks you need to deliver
digital services to New Zealanders. You can, for example, allocate compute
capacity, storage space, and network access to run your applications.

Every service on the Catalyst Cloud is charged by the hour. It is easy and quick
to change the amount of resources you allocate, so you can prevent waste and
reduce operational costs.


**************
Open by nature
**************

We strongly believe that open source software and open standards deliver
superior value and freedom to customers. Our cloud is built on `OpenStack`_ and
has an open API standard used by many cloud providers world-wide.

.. _`OpenStack`: https://www.openstack.org/software/

The OpenStack API standard is supported by favourite DevOps tools, such as
Ansible, Terraform, Chef, Puppet, etc.


***********
Ease of use
***********

We remove a lot of complexity from your day to day work, through services that
are easy to use. There are multiple ways you can interact with our services, as
demonstrated on the image below.

.. image:: assets/access_methods.png

While the dashboard is the easiest interface, the command line and the APIs are
also straightforward and intuitive to use.

For example, if you need to expose a compute instance to the public internet,
you can open a terminal and run the following command to obtain a public IP.

.. code-block:: console

  $ openstack floating ip create public-net

  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | created_at          | None                                 |
  | description         | None                                 |
  | fixed_ip_address    | None                                 |
  | floating_ip_address | 150.242.41.224                       |
  | floating_network_id | 849ab1e9-7ac5-4618-8801-e6176fbbcf30 |
  | id                  | 415fa158-fd7d-4b43-9002-0a55aa22a753 |
  | name                | 150.242.41.224                       |
  | port_id             | None                                 |
  | project_id          | 8ccc3286887e49cb9a40f023eba693b4     |
  | qos_policy_id       | None                                 |
  | revision_number     | None                                 |
  | router_id           | None                                 |
  | status              | DOWN                                 |
  | subnet_id           | None                                 |
  | tags                | []                                   |
  | updated_at          | None                                 |
  +---------------------+--------------------------------------+

Now that you have a public IP, you can associate it to one of your compute
instances using the following command:

.. code-block:: console

  $ openstack server add floating ip my_server_name 150.242.41.224

Just like that, your compute instance has a public IP address in seconds. Quick,
easy, and powerful. Every action on Catalyst Cloud can be performed just as
quickly.

Now that we understand the basic idea behind Catalyst Cloud, let's explore what
services Catalyst Cloud provides.

:ref:`Next page <services_on_the_catalyst_cloud>`
