############################################################################
Using Ansible's in-memory inventory to create a variable number of instances
############################################################################

This tutorial assumes the following:

* You have installed the OpenStack command line tools and sourced an
  OpenStack RC file, as explained at :ref:`command-line-interface`
* You have a basic understanding of how to use `Ansible`_ on the Catalyst Cloud
  as shown :ref:`here<launching-your-first-instance-using-ansible>`

.. _Ansible: https://www.ansible.com/

************
Introduction
************

Normally Ansible requires an `inventory file`_ to be created, to know which
machines it is meant to operate on.

This is typically a manual process but can be greatly improved by using the
likes of the `dynamic inventory`_  to pull inventory information from other
systems. Details for this approach are shown at
:ref:`ansible_openstack-dynamic-inventory`.

.. _inventory file: https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html
.. _Dynamic inventory: https://docs.ansible.com/ansible/latest/inventory_guide/intro_dynamic_inventory.html

Suppose, however, you needed to create 'x' number of instances which were
transient in nature and had no existing details available to populate an
inventory file for Ansible to utilise? If 'x' is a small number, you could
easily hand-craft the inventory file, but once this number gets into tens
of instances it becomes onerous.

To get around this problem, we can make use of Ansible's ability to populate an
in-memory inventory, using the `add_host`_ module, with information it
generates while creating new instances.

.. _add_host: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/add_host_module.html

*****************
How does it work?
*****************

The *add_host* module makes use of variables to create an in-memory inventory
of new hosts and groups that can be used in subsequent plays within the same
playbook.

+-----------+----------+-----------------------------------+
| Parameter | Required | Comments                          |
+===========+==========+===================================+
| groups    | no       | The groups to add the hostname    |
|           |          | to, comma separated.              |
|           |          | aliases: groupname, group         |
+-----------+----------+-----------------------------------+
| name      | yes      | The hostname/ip of the host to    |
|           |          | add to the inventory, can include |
|           |          | a colon and a port number.        |
|           |          | aliases: hostname, host           |
+-----------+----------+-----------------------------------+

The table above shows the basic parameters required for using *add_host*:

- *name* can be the hostname or IP address that will be used to reference the
  newly created instances
- *groups* is optional and creates group labels to access the new instances
  using the *'host:'* directive in subsequent plays

It is also possible to add custom variables at this time to help further
define the new hosts.

.. code-block:: yaml

  # add host to group 'created_vms' with a variable foo=42
  - add_host:
      name: "{{ public_v4 }}"
      groups: created_vms
      foo: 42

*****************
A working example
*****************

The goal
========

The requirements of this playbook are as follows:

* create a variable number of OpenStack instances on the Catalyst cloud
* carry out identical configuration across all nodes
* pause the playbook to allow for interaction with the new nodes,
  i.e. processing/testing etc.
* on resuming playback, terminate all new instances

This makes the following assumptions:

* an RC file has already been sourced
* a private network called *example-net* already exists
* a security group called *example-sg* already exists
* an access key called *example-key* has already been uploaded

The approach
============

Play 1
------

The number of instances to be created is controlled by a *'count'* variable. As
the instances are created, the results are captured in a registered variable
called *'newnodes'*. This is in turn iterated over using a *'loop'* to add the
required details to the in-memory inventory, as shown in this snippet:

.. literalinclude:: ../../../playbooks/create-x-servers.yml
  :language: yaml
  :lines: 36-42

Play 2
------

The newly created group *'created_nodes'* is used to iterate over the new
instances. Firstly it checks to see that SSH is responding and then it begins
the configuration of the nodes.

For the purposes of this example, the configuration involves simply installing
some packages onto each node. Once this has been completed, the playbook is
paused and will remain that way until told to either continue or abort.

Play 3
------

Assuming that playback is continued rather than aborted, the final play will
delete all of the nodes in the *'created_nodes'* group.

The playbook
============

Here is the complete playbook containing the three plays outlined above:

.. literalinclude:: ../../../playbooks/create-x-servers.yml
  :language: yaml
