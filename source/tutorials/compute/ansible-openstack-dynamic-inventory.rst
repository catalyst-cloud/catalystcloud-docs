.. _ansible_openstack-dynamic-inventory:

###################################################
Using ansible dynamic inventories on Catalyst Cloud
###################################################

This tutorial assumes the following:

* You have installed the OpenStack command line tools and sourced an
  OpenStack RC file, as explained at :ref:`command-line-interface`
* You have a basic understanding of how to use `Ansible`_ on Catalyst Cloud
  as shown :ref:`here<launching-your-first-instance-using-ansible>`

.. _Ansible: https://docs.ansible.com/

************
Introduction
************

In order for Ansible to run playbooks and tasks, it needs to know which
machines to operate on. The standard way that Ansible achieves this is to use
an `inventory file`_ which lists the hosts and groups that playbooks will run
against. This inventory is a plain text ini or yaml file that lives at
``/etc/ansible/hosts`` by default.

.. _inventory file: https://docs.ansible.com/projects/ansible/latest/inventory_guide/intro_inventory.html

A `dynamic inventory`_ provides a way for Ansible to pull in inventory
information from other systems. This means that you do not need to manually
sync your local inventory with another source, rather you can invoke a tool
that queries the source directly and makes the information available to
Ansible. Dynamic inventories are scripts or plugins that output JSON in a predefined
format that Ansible understands.

.. _Dynamic inventory: https://docs.ansible.com/projects/ansible/latest/inventory_guide/intro_dynamic_inventory.html

The Ansible project has an OpenStack dynamic inventory plugin available which
we can use to integrate Ansible with Catalyst Cloud. This allows us
to use Ansible for configuration management of Catalyst Cloud instances
irrespective of what method has been used to create those instances.

****************************************
Install the OpenStack Ansible collection
****************************************

Use the ansible-galaxy command to install the openstack.cloud collection.
The collection includes modules for using Ansible with OpenStack as well as the inventory plugin.

.. code-block:: bash

  $ ansible-galaxy collection install openstack.cloud

You can verify that the inventory plugin is available by running the following command to
list inventory plugins:

.. code-block:: bash

  $ ansible-doc -t inventory -l

You should see ``openstack.cloud.openstack`` listed in the available plugins.


************************************
Testing the dynamic inventory plugin
************************************

Create an inventory file named ``openstack.yml`` with the following contents:

.. code-block:: yaml

 plugin: openstack.cloud.openstack
 expand_hostvars: yes
 fail_on_errors: yes

Now we can test the plugin:

.. code-block:: bash

 $ ansible-inventory -i openstack.yml --list

This will output JSON data about your compute instances.

You can filter this output as required:

.. code-block:: bash

 $ ansible-inventory -i openstack.yml --list | grep ansible_ssh_host
         "ansible_ssh_host": "150.242.40.72",
         "ansible_ssh_host": "150.242.40.71",

or if you have ``jq`` installed:

.. code-block:: bash

 $ ansible-inventory -i openstack.yml --list | jq -r '._meta.hostvars[].ansible_ssh_host'
 150.242.40.72
 150.242.40.71
 $ ansible-inventory -i openstack.yml --list | jq -r '._meta.hostvars[].openstack.name'
 example-instance-02
 example-instance-01

Now that you have the inventory plugin working, you can use it in a playbook.
You are going to use the following playbook:

.. code-block:: yaml

 ---

 - name: Ping cloud instances
   hosts: all
   remote_user: ubuntu
   tasks:
     - name: Test connection to instance
       ping:

Let's run this playbook with the dynamic inventory:

.. code-block:: bash

 $ ansible-playbook -i ./openstack.yml ping.yml

 PLAY [Ping cloud instances] ****************************************************

 TASK [setup] *******************************************************************
 ok: [example-instance-02]
 ok: [example-instance-01]

 TASK [Test connection to instance] *********************************************
 ok: [example-instance-01]
 ok: [example-instance-02]

 PLAY RECAP *********************************************************************
 example-instance-01        : ok=2    changed=0    unreachable=0    failed=0
 example-instance-02        : ok=2    changed=0    unreachable=0    failed=0

You will notice that your playbook is configured to operate against all hosts
returned from the inventory plugin (set via ``hosts: all``). If you would like to
operate on a subset of hosts, there are a number of options.

****************************************
Using metadata to create groups of hosts
****************************************

If you look at the JSON output again, you can see the information about your
instances is contained under the ``_meta`` key. The other top level keys of the
returned JSON object point to lists of instances. These keys relate to various
properties of your instances and are output by the inventory plugin dynamically.

In addition to the automatic key creation, users can generate their own
groupings based on instance metadata. In the following example, you have added two
metadata items to each instance:

.. code-block:: bash

 $ nova show example-instance-01 | grep metadata | awk -F'|' '{ print $3 }' | jq '.'
 {
   "group": "group01",
   "example": "foobar"
 }
 $ nova show example-instance-02 | grep metadata | awk -F'|' '{ print $3 }' | jq '.'
 {
   "group": "group02",
   "example": "foobar"
 }

In the example below, you are using ``jq`` to remove the data associated with
the ``_meta`` key so you can view just the instance lists.

.. code-block:: bash

 $ ./openstack.py --list | jq -r '. | del(._meta)'
 {
   "envvars": [
     "example-instance-01",
     "example-instance-02"
   ],
   "envvars_nz-por-1": [
     "example-instance-01",
     "example-instance-02"
   ],
   "envvars_nz-por-1_nz-por-1a": [
     "example-instance-01",
     "example-instance-02"
   ],
   "flavor-c1.c1r1": [
     "example-instance-01",
     "example-instance-02"
   ],
   "group01": [
     "example-instance-01"
   ],
   "group02": [
     "example-instance-02"
   ],
   "image-ubuntu-14.04-x86_64": [
     "example-instance-01",
     "example-instance-02"
   ],
   "instance-b495f9cc-47f9-49cc-9780-xxxxxxxxxxxx": [
     "example-instance-02"
   ],
   "instance-ca13f6c2-600c-493d-936d-xxxxxxxxxxxx": [
     "example-instance-01"
   ],
   "meta-example_foobar": [
     "example-instance-01",
     "example-instance-02"
   ],
   "meta-group_group01": [
     "example-instance-01"
   ],
   "meta-group_group02": [
     "example-instance-02"
   ],
   "nz-por-1": [
     "example-instance-01",
     "example-instance-02"
   ],
   "nz-por-1_nz-por-1a": [
     "example-instance-01",
     "example-instance-02"
   ],
   "nz-por-1a": [
     "example-instance-01",
     "example-instance-02"
   ]
 }

You can see a number of different groupings of instances are available,
including groupings based on the metadata you passed. Metadata with the key
``group`` is a special case that will be translated directly into an Ansible
host group of that name.

Any of these groups may be used within a playbook. For example, let's make use
of the ``group01`` group to run our playbook against only
``example-instance-01``:

.. code-block:: yaml

 ---

 - name: Ping cloud instances
   hosts: group01
   remote_user: ubuntu
   tasks:
     - name: Test connection to instance
       ping:

Let's run this playbook with the dynamic inventory:

.. code-block:: bash

 $ ansible-playbook -i ./openstack.yml ping.yml

 PLAY [Ping cloud instances] ****************************************************

 TASK [setup] *******************************************************************
 ok: [example-instance-01]

 TASK [Test connection to instance] *********************************************
 ok: [example-instance-01]

 PLAY RECAP *********************************************************************
 example-instance-01        : ok=2    changed=0    unreachable=0    failed=0

You can associate metadata with an instance at instance creation time. It is
also possible to add metadata to an instance after it has been created, for
example using the nova command line client:

.. code-block:: bash

 $ nova meta example-instance-01 set example-key=example-value
 $ nova show example-instance-01 | grep metadata | awk -F'|' '{ print $3 }' | jq '.'
 {
   "example-key": "example-value",
   "group": "group01",
   "example": "foobar"
 }

.. note::

 Metadata keys do not natively support lists as keys, so you will overwrite the previous group if you reset a group.

An Ansible playbook for creating the instances used in this example is
available at
https://raw.githubusercontent.com/catalyst/catalystcloud-ansible/master/example-playbooks/two-instances-with-sequence.yml
