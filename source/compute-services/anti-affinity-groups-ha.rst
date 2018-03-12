.. _anti-affinity:

###########################
Anti-affinity groups for HA
###########################

..
  Affinity and anti-affinity groups allow you to ensure compute instances are
  placed on the same or different hypervisors (physical servers).

Anti-affinity groups allow you to ensure compute instances are placed on
different physical servers.

..
  Server affinity is useful when you want to ensure that the data transfer
  amongst compute instances is as fast as possible. On the other hand it may
  reduce the availability of your application (a single server going down affects
  all compute instances in the group) or increase CPU contention.

Server anti-affinity is useful when you want to increase the availability of an
application within a region. Compute instances in an anti-affinity group are
placed on different physical servers, ensuring that the failure of a server
will not affect all your compute instances simultaneously.

**********************
Managing server groups
**********************

Via the APIs
============

Please refer to the server groups API calls at http://developer.openstack.org/api-ref/compute/#server-groups-os-server-groups.

Via the command line tools
==========================

To create a server group:

.. code-block:: bash

  openstack server group create $groupname $policy

Where:

* ``$groupname`` is a name you choose (eg: app-servers)
* ``$policy`` is ``anti-affinity``

.. * ``$policy`` is either ``affinity`` or ``anti-affinity``

To list server groups:

.. code-block:: bash

  openstack server group list

To delete a server group:

.. code-block:: bash

  openstack server group delete $groupid

Deleting a server group does not delete the compute instances that belong to
the group.

Add compute instance to server group
====================================

Via the command line tools
--------------------------

When launching a compute instance, you can pass a hint to our cloud scheduler
to indicate it belongs to a server group. This is done using the ``--hint
group=$GROUP_ID`` parameter, as indicated below.

.. code-block:: bash

  openstack server create --flavor $CC_FLAVOR_ID --image $CC_IMAGE_ID
  --key-name $KEY_NAME --security-group default --security-group $SEC_GROUP
  --nic net-id=$CC_PRIVATE_NETWORK_ID --hint group=$GROUP_ID first-instance

.. note::

  If you receive a `No valid host was found` error, it means that the cloud
  scheduler could not find a suitable server to honour the policy of the server
  group. For example, we may not have enough capacity on the same hypervisor to
  place another instance in affinity, or enough hypervisors with sufficient
  capacity to place instances in anti-affinity.

Via Ansible
-----------

The example below illustrates how the server group hint can be passed in an
Ansible playbook using the os_server module:

.. code-block:: yaml

  - name: Create a compute instance on the Catalyst Cloud
    os_server:
      state: present
      name: "{{ instance_name }}"
      image: "{{ image }}"
      key_name: "{{ keypair_name }}"
      flavor: "{{ flavor }}"
      nics:
        - net-name: "{{ private_network_name }}"
      security_groups: "default,{{ security_group_name }}"
      scheduler_hints: "group=78f2aabc-e73a-4c72-88fd-79185797548c"
