###############
Private Cluster
###############

As one of the security best practices, isolating Kubernetes clusters from
internet access is the most desired feature by enterprise users.
On Catalyst Cloud, all the public templates after our Beta relase (since
10 September, 2019) will create private clusters by default.

**************************************
Attributes/Labels of cluster isolation
**************************************

There are several attributes and labels related to this topic and they can be
set on both cluster template and clusters.

.. note::

  You cannot convert an existing, non-private cluster to a private cluster.

* ``master_lb_enabled: true``
  As multiple master nodes may exist in a cluster, a load balancer is created
  to provide the API endpoint for the cluster and to direct requests to the
  masters. Where the load balancer service is not available, this option can be
  set to ‘false’ thus creating a cluster without the load balancer. In this
  case, one of the masters will serve as the API endpoint. The default for
  load balancer is True for our prod templates.

  This is an attribute of cluster template, it *can not* be override when
  creating cluster.

* ``floating_ip_enabled: false``
  Whether enable or not assigning floating IP for cluster master and worker
  nodes. When it's set with True, which means the node is accessible from
  Internet. That's is not recommended.

  It's an attribute of cluster template, but it *can* be override when creating
  cluster.

* ``master_lb_floating_ip_enabled: false``
  If it's allowed to allocate floating IP for the load balancer of master
  nodes. This label only takes effect when the template property
  master_lb_enabled is set. If not specified, the default value is the same as
  template property floating_ip_enabled.

  This is a label, and it can be override when creating cluster.

* ``fixed_network``
  The name or network ID of a Neutron network to provide connectivity to the
  internal network for the cluster.

  When creating cluster, you can set the fixed_network to create the cluster
  in an existing network.

* ``fixed_subnet``
  Fixed subnet that are using to allocate network address for nodes in cluster.

  When creating cluster, you can set the fixed_subnet to create the cluster
  in an existing subnet.

***************************
Cluster isolation scenarios
***************************

There are 4 typical scenarios as below:

.. code-block:: bash

 +-----------------+---------------------------------------+---------------------------------------+
 |                 | prod template                         | dev template                          |
 +=================+=======================================+=======================================+
 | private cluster | master_lb_enabled = True              | master_lb_enabled = False             |
 |                 | floating_ip_enabled = False           | floating_ip_enabled = False           |
 |                 | master_lb_floating_ip_enabled = False | master_lb_floating_ip_enabled = False |
 +-----------------+---------------------------------------+---------------------------------------+
 | public cluster  | master_lb_enabled = True              | master_lb_enabled = False             |
 |                 | floating_ip_enabled = False           | floating_ip_enabled = True            |
 |                 | master_lb_floating_ip_enabled = True  | master_lb_floating_ip_enabled = False |
 +-----------------+---------------------------------------+---------------------------------------+



Use the ``openstack coe cluster create`` command to set the existing network
and subnet:

.. code-block:: console

  $ openstack coe cluster create my-cluster --cluster-template <Template ID> \
                                            --fixed-network <network ID> \
                                            --fixed-subnet <subnet ID>

Meanwhile, you can enable or disable floating IP when creating a new cluster,
no matter what's the setting for floating IP in the cluste template. To enable
floating IP you can run command as below:

.. code-block:: console

  $ openstack coe cluster create my-cluster --cluster-template <Template ID> \
                                            --floatingip-enabled

or

.. code-block:: console

  $ openstack coe cluster create my-cluster --cluster-template <Template ID> \
                                            --floatingip-disabled
