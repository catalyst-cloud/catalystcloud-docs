#############################################################################
Use Ansible in-memory inventory to create 'x' number of VMs on Catalyst Cloud
#############################################################################

This tutorial assumes the following:

* You have installed the OpenStack command line tools and sourced an
  OpenStack RC file, as explained at :ref:`command-line-tools`
* You have a basic understanding of how to use `Ansible`_ on the Catalyst Cloud
  as shown at :ref:`launching-your-first-instance-using-ansible`

.. _Ansible: https://www.ansible.com/

Introduction
============

Normally Ansible requires an `inventory file`_ to be created to know which
machines it is meant to operate on.

This is typically a manual process but can be greatly improved by using the
likes of the `dynamic inventory`_  to pull inventory information from other
systems. Details for this approach are shown here
:ref:`ansible_openstack-dynamic-inventory`.

.. _inventory file: http://docs.ansible.com/ansible/intro_inventory.html
.. _Dynamic inventory: http://docs.ansible.com/ansible/intro_dynamic_inventory.html

Suppose, however, you needed to create 'x' number of instances which were
transient in nature and had no existing details available to populate an
inventory file for Ansible to utilise? If 'x' was just a small number you could
quite easily hand-craft the inventory file but once this number gets into tens
of instances then it starts becoming quite onerous.

To get around this problem we can make use of Ansible's ability to populate an
in-memory inventory, using the `add_host`_ module, with information it
generates while creating new instances.

.. _add_host: http://docs.ansible.com/ansible/add_host_module.html

How does it work?
=================
The add_host module makes use of variables to create an in-memory inventory of
new hosts and groups that can be used in subsequent plays within the same
playbook.

+-----------+----------+---------+---------+---------------------------------+
| parameter | required | default | choices | comments                        |
+===========+==========+=========+=========+=================================+
| groups    | no       |         |         |The groups to add the hostname   |
|           |          |         |         |to, comma separated.             |
|           |          |         |         |aliases: groupname, group        |
+-----------+----------+---------+---------+---------------------------------+
| name      |yes       |         |         |The hostname/ip of the host to   |
|           |          |         |         |add to the inventory, can include|
|           |          |         |         |a colon and a port number.       |
|           |          |         |         |aliases: hostname, host          |
+-----------+----------+---------+---------+---------------------------------+

The table above shows the basic parameters required for using add_host:

- name can be the hostname or IP address that will be used to reference the
  newly created instances
- groups is optional and creates group labels to access the new instances using
  the *'host:'* directive in subsequent plays

It is also possible to add custom variables at this time to help further
define the new hosts.

.. code-block:: yaml

  # add host to group 'created_vms' with a variable foo=42
  - add_host: name={{ public_v4 }} groups=created_vms foo=42

A working example
=================
The Goal
--------
The requirements of this playbook are as follows:

- create a variable number of Openstack instances on the Catalyst cloud
- carry out identical configuration across all nodes
- pause the playbook to allow for interaction with the new nodes,
  i.e. processing/testing etc.
- on resuming playback terminate all new instances

This makes the following assumptions:

- an RC file has already been sourced
- a private network called example-net already exists
- a security-group called example-sg already exists
- an access key called example-key has already been uploaded

The Approach
------------
**Play 1:**
The number of instances to be created is controlled by a *'count'* variable. As
the instances are created the results are captured in a registered variable
called 'newnodes'. This is in turn iterated over using a *'with_items'* loop to
add the required details to the in-memory inventory as shown in this snippet...

.. code-block:: yaml

  - add_host: name={{ item.server.public_v4 }}
              groups=created_nodes
              ansible_user=ubuntu
              instance_name={{ item.server.name }}
    with_items: "{{ newnodes.results }}"

**Play 2:**
The newly created group *'created_nodes'* is used to iterate over the new
instances. Firstly it checks to see that SSH is responding and then begins the
configuration of the nodes.

For the purposes of this example the configuration involves simply installing
some packages on to each node.  Once this has been completed the playbook is
paused and will remain that way until told to either continue or abort.

**Play 3:**
Assuming that playback is continued rather than aborted the final play will
delete all of the nodes in the created_nodes group.


The Playbook
------------
Here is the complete playbook containing the 3 plays outlined above:

.. code-block:: yaml

  #!/usr/bin/env ansible-playbook
  ---

  ##############################################################################
  # Play 1 - Create 'x' instances in Openstack based on 'count' var
  ##############################################################################

  - name: Deploy a cloud instance in OpenStack
    hosts: localhost

    vars:
      image: ubuntu-14.04-x86_64
      network: example-net
      key_name: example-key
      flavor: c1.c1r1
      security_groups: example-sg
      count: 3

    tasks:
      - name: Connect to the Catalyst Cloud
        # assume RC file has already been sourced
        os_auth:

      - name: launch web instances
        os_server:
          name: test0{{ item }}
          flavor: "{{ flavor }}"
          image: "{{ image }}"
          key_name: "{{ key_name }}"
          state: present
          wait: true
          network: "{{ network }}"
          security_groups: "{{ security_groups }}"
          auto_ip: true
          meta: ansible_group=workernodes
        register: newnodes
        with_sequence:
          count={{ count }}

      - add_host: name={{ item.server.public_v4 }}
                  groups=created_nodes
                  ansible_user=ubuntu
                  instance_name={{ item.server.name }}
        with_items: "{{ newnodes.results }}"

  ##############################################################################
  # Play 2 - configure nodes from in-memory inventory
  ##############################################################################
  - name: Configure nodes
    hosts: created_nodes
    become: yes
    become_method: sudo
    gather_facts: false
    tasks:
      - name: "Wait for SSH banners"
        local_action: wait_for port=22 host="{{ inventory_hostname }}" search_regex=OpenSSH delay=5
        become: False

      - name: install apps
        apt: name={{ item }} update_cache=yes state=latest
        with_items:
          - htop
          - git

      - name: Pause play to interact with the server
        pause: prompt="Playbook paused... hit <enter> to continue or <ctrl-c a> to abort"

  ##############################################################################
  # Play 3 - destroy nodes
  ##############################################################################

  - name: Destroy nodes
    hosts: localhost

    tasks:
    - name: Destroy instances
      os_server:
        name: "{{ hostvars[item].instance_name }}"
        state: absent
      with_items: "{{ groups['created_nodes'] }}"
