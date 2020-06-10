.. _private-cluster:

###############
Private cluster
###############

As a security best practice, isolating Kubernetes clusters from internet
access is one of the most desired features for enterprise users. On Catalyst
Cloud, all the public templates after our Beta release
(from 10 September, 2019) will create private clusters by default.

***************************************
Controlling levels of cluster isolation
***************************************

There are several attributes and labels related to this topic and they can be
set on both the cluster template and cluster level.

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
  When enabled it will assign a floating IP to all cluster master and worker
  nodes. This means that all nodes are accessible from the internet, which
  is not recommended.

  It's an attribute of cluster template, but it *can* be override when creating
  cluster.

* ``master_lb_floating_ip_enabled: false``
  If it is enabled it will allocate a floating IP on the load balancer of the
  master nodes. This label only takes effect when the template property
  master_lb_enabled is set. If not specified, the default value is the same
  as template property floating_ip_enabled.

  This is a label, and it can be override when creating the cluster.s

* ``fixed_network``
  The name or network ID of a network to provide connectivity to the
  internal network for the cluster.

  When creating cluster, you can set the fixed_network to create the cluster
  in an existing network.

* ``fixed_subnet``
  This defines the fixed subnet that will be used to allocate network addresses
  for nodes in the cluster.

  When creating a cluster, you can set the fixed_subnet to create the cluster
  in an existing subnet.

***************************
Cluster isolation scenarios
***************************

There are 4 typical scenarios as below:

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

.. _cluster-on-existing-net:

**********************************
Create cluster in existing network
**********************************

Use the ``openstack coe cluster create`` command to set the existing network
and subnet:

.. code-block:: console

  $ openstack coe cluster create my-cluster --cluster-template <Template ID> \
                                            --fixed-network <network ID> \
                                            --fixed-subnet <subnet ID>

*********************************************
Turn on/off floating ip when creating cluster
*********************************************

Though it is not recommended, it is possible to enable or disable floating
IP when creating a new cluster. This will override the floating IP behaviour
defined in the cluster template. To enable floating IP you can run command
as below:

.. code-block:: console

  $ openstack coe cluster create my-cluster --cluster-template <Template ID> \
                                            --floating-ip-enabled

or disable floating IP (if it's enabled in the cluster template):

.. code-block:: console

  $ openstack coe cluster create my-cluster --cluster-template <Template ID> \
                                            --floating-ip-disabled

***************************************
Access Kubernetes API from the internet
***************************************

.. warning::

  Again, it's not recommended to make your Kubernetes cluster accessible from
  the Internet for security reasons.

As mentioned above, by default cluster created based on Catalyst Cloud prod
templates are not accessible from Internet. It can be reachable by adding a
label `master_lb_floating_ip_enabled=True` to allocate a floating IP address
to the load balancer of Kubernetes API with below command:

.. code-block:: console

  $ openstack coe cluster create my-cluster --cluster-template <Template ID> \
                                            --labels <existing labels>,master_lb_floating_ip_enabled=True

.. note::

  To update a label when creating a cluster, you have to set all the labels
  from the template to do override.

For clusters created based on dev cluster template, instead of setting the
`master_lb_floating_ip_enabled` label, you have to enable the floating IP
as we mentioned above and manually changed security group rule for master nodes
to allow ingress traffic on port 6443.

