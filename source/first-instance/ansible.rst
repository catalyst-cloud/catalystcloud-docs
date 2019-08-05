.. _launching-your-first-instance-using-ansible:

*************
Using Ansible
*************

`Ansible`_ is a popular open source configuration management and application
deployment tool. Ansible provides a set of core modules for interacting with
OpenStack. This makes Ansible an ideal tool for providing both OpenStack
orchestration and instance configuration, letting you use a single tool to
set up the underlying infrastructure and configure instances. As such Ansible
can replace other tools, such as Heat for OpenStack orchestration, and Puppet
for instance configuration.

.. _Ansible: http://www.ansible.com/

Comprehensive documentation of the Ansible OpenStack modules is available at
https://docs.ansible.com/ansible/list_of_cloud_modules.html#openstack
And for any troubleshooting issues you may face using ansbile you can refer to
the following https://docs.ansible.com/ansible-tower/2.2.0/html/administration/troubleshooting.html



.. _install-ansible:

Install Ansible
===============

A script is provided by Catalyst which installs the required Ansible and
OpenStack libraries within a Python virtual environment. This script is part of
the `catalystcloud-ansible`_ git repository. Clone this repository and run the
install script in order to install Ansible.

.. _catalystcloud-ansible: https://github.com/catalyst/catalystcloud-ansible

.. code-block:: bash

 $ git clone https://github.com/catalyst/catalystcloud-ansible.git && CC_ANSIBLE_DIR="$(pwd)/catalystcloud-ansible" && echo $CC_ANSIBLE_DIR
 $ cd catalystcloud-ansible
 $ ./install-ansible.sh
 Installing stable version of Ansible
 ...
 Ansible installed successfully!

 To activate run the following command:

 source /home/yourname/src/catalystcloud-ansible/ansible-venv/bin/activate

 $ source $CC_ANSIBLE_DIR/ansible-venv/bin/activate
 $ ansible --version
 ansible 2.1.1.0
   config file = /etc/ansible/ansible.cfg
   configured module search path = Default w/o overrides

.. note::

  Catalyst recommends customers use Ansible >= 2.0 and Shade >= 1.4 with the
  Catalyst Cloud.


OpenStack credentials
=====================

Before running the Ansible playbooks, ensure your OpenStack credentials have
been set up. The easiest way to achieve this is by making use of environment
variables. Use the standard variables provided by an OpenStack RC file as
described in :ref:`source-rc-file`. These variables are read by the
Ansible ``os_auth`` module, and will provide Ansible with the credentials
required to access the Catalyst Cloud APIs.

.. note::

 If credentials are not set up by sourcing an OpenStack RC file, a few
 mandatory authentication attributes will need to be included in the playbooks.
 See the "vars" section of the playbooks for details.

Once the Ansible installation includes the required OpenStack modules, and the
OpenStack credentials have been set up, a first instance may be built.

The first instance playbooks are located under the `example-playbooks`
directory and have been split up as follows:

* The first playbook, ``create-network.yml`` creates the required network
  components.
* The second playbook, ``launch-instance.yml`` launches the instance.


Run the create network playbook
===============================

These are the tasks the ``create-network.yml`` playbook will perform:

.. code-block:: bash

 $ ansible-playbook --list-tasks create-network.yml

 playbook: create-network.yml

  play #1 (localhost): Create a network in the Catalyst Cloud   TAGS: []
    tasks:
      Connect to the Catalyst Cloud TAGS: []
      Create a network  TAGS: []
      Create a subnet   TAGS: []
      Create a router   TAGS: []
      Create a security group   TAGS: []
      Create a security group rule for SSH access   TAGS: []
      Import an SSH keypair TAGS: []



In order for this playbook to work, the path to a valid SSH key must be
provided. Edit ``create-network.yml`` and update the ``ssh_public_key``
variable, or override the variable when running the playbook as shown below:

.. code-block:: bash

 $ ansible-playbook --extra-vars "ssh_public_key=$HOME/.ssh/id_rsa.pub" create-network.yml

 PLAY [Deploy a cloud instance in OpenStack] ************************************

 TASK [setup] *******************************************************************
 ok: [localhost]

 TASK [Connect to the Catalyst Cloud] *******************************************
 ok: [localhost]

 TASK [Create a network] ********************************************************
 changed: [localhost]

 TASK [Create a subnet] *********************************************************
 changed: [localhost]

 TASK [Create a router] *********************************************************
 changed: [localhost]

 TASK [Create a security group] *************************************************
 changed: [localhost]

 TASK [Create a security group rule for SSH access] *****************************
 changed: [localhost]

 TASK [Import an SSH keypair] ***************************************************
 changed: [localhost]

 PLAY RECAP *********************************************************************
 localhost                  : ok=8    changed=6    unreachable=0    failed=0



.. tip::

  Pay careful attention to the console output. It provides lots of useful information.


Run the launch instance playbook
================================

After the network has been set up successfully, run the ``launch-instance.yml``
playbook:

.. code-block:: bash

 $ ansible-playbook launch-instance.yml

 PLAY [Deploy a cloud instance in OpenStack] ************************************

 TASK [setup] *******************************************************************
 ok: [localhost]

 TASK [Connect to the Catalyst Cloud] *******************************************
 ok: [localhost]

 TASK [Create a compute instance on the Catalyst Cloud] *************************
 changed: [localhost]

 TASK [Assign a floating IP] ****************************************************
 changed: [localhost]

 TASK [Output floating IP] ******************************************************
 ok: [localhost] => {
     "floating_ip_info.floating_ip.floating_ip_address": "150.242.41.75"
 }

 PLAY RECAP *********************************************************************
 localhost                  : ok=4    changed=2    unreachable=0    failed=1



The new instance is accessible using SSH. Retrieve the instance's IP address
from the console output. It is echoed by the example ``Output floating IP`` task
above as "150.242.41.75". Login using SSH (using the username appropriate to the
build image):

.. code-block:: bash

 $ ssh ubuntu@150.242.41.75


.. tip::

  Additional Ansible playbooks may now be used to configure this instance
  further, as required.


Resource cleanup with an Ansible playbook
=========================================

This playbook will remove all resources created by the previous playbooks.

It has been included in the `catalystcloud-ansible`_ git repository referenced
earlier, but may also be downloaded as follows:

.. code-block:: bash

 $ wget -q https://raw.githubusercontent.com/catalyst/catalystcloud-ansible/master/remove-stack.yml


Run the playbook to remove all resources created previously:

.. code-block:: bash

 $ ansible-playbook remove-stack.yml --extra-vars "floating_ip=<ip-address>"

Replace ``<ip-address>`` with the floating-ip assigned by
the ``launch-instance.yml`` playbook.


.. note::

 This cleanup playbook assumes that all resources have been created using the
 default names defined in the original playbooks. If the original names have
 been changed, it will be necessary to edit the cleanup playbook to reflect
 these changes.
