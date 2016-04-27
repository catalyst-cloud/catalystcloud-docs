.. _ansible_openstack-dynamic-inventory:

#######################################################
Using Ansible Dynamic Inventories on the Catalyst Cloud
#######################################################

This tutorial assumes the following:

* You have installed the OpenStack command line tools and sourced an
  OpenStack RC file, as explained at :ref:`command-line-tools`
* You have a basic understanding of how to use `Ansible`_ on the Catalyst Cloud
  as shown at :ref:`launching-your-first-instance-using-ansible`

.. _Ansible: https://www.ansible.com/

Introduction
============

In order for Ansible to run playbooks and tasks it needs to know which machines
to operate on. The standard way that Ansible achieves this is to use an
`inventory file`_ which lists the hosts and groups that playbooks will run
against. This inventory is a plain text ini file that lives at
``/etc/ansible/hosts`` by default.

.. _inventory file: http://docs.ansible.com/ansible/intro_inventory.html

A `dynamic inventory`_ provides a way for Ansible to pull in inventory
information from other systems. This means that you do not need to manually
sync your local inventory with another source, rather you can invoke a script
that queries the source directly and makes the information available to
Ansible. Dynamic inventories are scripts that output JSON in a predefined
format that Ansible understands.

.. _Dynamic inventory: http://docs.ansible.com/ansible/intro_dynamic_inventory.html

The Ansible project has an OpenStack dynamic inventory script available which
we can make use of to integrate Ansible with the Catalyst Cloud. This allows us
to use Ansible for configuration management of Catalyst Cloud instances
irrespective of what method has been used to create those instances.

Donloading the dynamic inventory script
========================================

The latest version of the script is available here:
https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/openstack.py

Download it and make it executable:

.. code-block:: bash

 $ wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/openstack.py
 $ chmod +x openstack.py

Ansible supports replacing the standard inventory file with a dynamic inventory
script. Do this only if you wish the default Ansible inventory on your system
to be dynamically populated from your Catalyst Cloud project.

.. code-block:: bash

 $ sudo cp openstack.py /etc/ansible/hosts

Testing the dynaminc inventory script
========================================

Now we can test the script:

.. code-block:: bash

 $ ./openstack.py --list

This will output JSON data about your compute instances.

You can filter this output as required:

.. code-block:: bash

 $ ./openstack.py --list | grep ansible_ssh_host
         "ansible_ssh_host": "150.242.40.72",
         "ansible_ssh_host": "150.242.40.71",

or if you have ``jq`` installed:

.. code-block:: bash

 $ ./openstack.py --list | jq -r '._meta.hostvars[].ansible_ssh_host'
 150.242.40.72
 150.242.40.71
 $ ./openstack.py --list | jq -r '._meta.hostvars[].openstack.name'
 example-instance-02
 example-instance-01

Now that we have the inventory script working we can use it in a playbook, we
are going to use the following playbook:

.. code-block:: yaml

 #!/usr/bin/env ansible-playbook
 ---

 - name: Ping cloud instances
   hosts: all
   remote_user: ubuntu
   tasks:
     - name: Test connection to instance
       ping:

Lets run this playbook with the dynamic inventory:

.. code-block:: bash

 $ ansible-playbook -i ./openstack.py ping.yml

 PLAY [Ping cloud instances] ****************************************************

 TASK [setup] *******************************************************************
 ok: [ca13f6c2-600c-493d-936d-493ea9870b65]
 ok: [b495f9cc-47f9-49cc-9780-2aca72046837]

 TASK [Test connection to instance] *********************************************
 ok: [b495f9cc-47f9-49cc-9780-2aca72046837]
 ok: [ca13f6c2-600c-493d-936d-493ea9870b65]

 PLAY RECAP *********************************************************************
 b495f9cc-47f9-49cc-9780-2aca72046837 : ok=2    changed=0    unreachable=0    failed=0
 ca13f6c2-600c-493d-936d-493ea9870b65 : ok=2    changed=0    unreachable=0    failed=0

.. note::

 If you have replaced ``/etc/ansible/inventory`` then you don't need to call ``ansible-playbook`` with the ``-i`` flag.

You will notice in the output above that the inventory script is passing
instance IDs as the hostname. If you would prefer to use instance names you can
create a ``/etc/ansible/openstack.yml`` file with the following content:

.. code-block:: yaml

 ansible:
   use_hostnames: True
   expand_hostvars: True

.. note::

 The ``expand_hostvars`` option controls whether or not the inventory will make extra API calls to fill out additional information about each server.

With this file in place the output will change to use instance names rather
than IDs:

.. code-block:: bash

 $ ansible-playbook -i ./openstack.py ping.yml

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

You will notice that our playbook is configured to operate against all hosts
returned from the inventory script (set via ``hosts: all``). If you would like to
operate on a subset of hosts there are a number of options.

If we look at the JSON output again we can see the information about our
instances is contained under the ``_meta`` key. The other top level keys of the
returned JSON object point to lists of instances. These keys relate to various
properties of our instances and are output by the dynamic inventory script
dynamically.

In addition to the automatic key creation users can generate their own
groupings based on instance metadata. In this example we have added two
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

In the example below we are using ``jq`` to remove the data associated with the
``_meta`` key so we can view just the instance lists.

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
   "instance-b495f9cc-47f9-49cc-9780-2aca72046837": [
     "example-instance-02"
   ],
   "instance-ca13f6c2-600c-493d-936d-493ea9870b65": [
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

We can see a number of different groupings of instances are available including
groupings based on the metadata we passed. Metadata with the key ``group`` is a
special case that will be translated directly into an Ansible host group of that
name.

Any of these groups may be used within a playbook, for example lets make use of
the ``group01`` group to run our playbook against only ``example-instance-01``:

.. code-block:: yaml

 #!/usr/bin/env ansible-playbook
 ---

 - name: Ping cloud instances
   hosts: group01
   remote_user: ubuntu
   tasks:
     - name: Test connection to instance
       ping:

Lets run this playbook with the dynamic inventory:

.. code-block:: bash

 $ ansible-playbook -i ./openstack.py ping.yml

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

 Metadata keys do not natively suport lists as keys so you will overwrite the previous group if you reset a group.

An Ansible playbook for creating the instances used in this example is
available at
https://raw.githubusercontent.com/catalyst/catalystcloud-ansible/master/example-playbooks/two-instances-with-sequence.yml

Instance detection
==================

There are some quirks around which instances in an OpenStack project the
dynamic inventory script will report:

* Instances that do not have floating IPs are not included in the inventory
* Instances that do not have SSH access due to security group rules are
  included in the inventory
