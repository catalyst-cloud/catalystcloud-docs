#########################
Production considerations
#########################

There are several considerations that you need to make before deciding how and
where to deploy your cluster.
This section of the documentation will discuss different common practices and
considerations that are important to creating a cluster that is able to handle
the demands of a production environment.

**********************
Network considerations
**********************

The first things you need to consider before creating your cluster is the
specifications around networking. The following are common and important
questions that you must answer before you begin building any production
clusters.

Where is your cluster going to live?
====================================

A cluster, like most of the resources on the Catalyst Cloud, must sit on a
network inside your project. However, it is up to you whether you want to have
your cluster sitting on its own network isolated from your other resources, or
if you want to have your cluster sitting on the same network as other objects;
so that they are able to interact with one another. This decision is dependant
on what resources your cluster is going to be using or interacting with and
how you want to construct your system.

Publicly accessible or private?
===============================

Another consideration that you need to make in regards to networking is,
whether you want the cluster to be publicly or privately accessible. The
majority of the time, production clusters are deployed in an internal network
and do not have access to the outside world; this is for security purposes and
are talked about in detail later on. However, there may be times when you want
to take advantage of the features offered by the kubernetes platform for a
service that you want to provide public access to. It is important to know
before creating your cluster what the intended purpose is, so
you can take the time to learn the security practices necessary to run a
public cluster.

What is the address?
====================

The final thing to consider about networking is the actual address of the
cluster itself. Before creating a cluster it is important to consider which
subnet you are going to use for the network that the kubernetes cluster
creates; both for the cluster address itself and the internal supernet that
the cluster creates. The internal supernet uses the address 10.100.0.0/16 and
shouldn't conflict with any networks that you normally use but you do need to
be mindful of this in the event that it does clash. If you maintain a table of
the subnets that your company has in use, it is recommended that you update
this list to include the new subnet space that is created with your cluster.

There are two important CIDR ranges that are defined in the cluster template.
The first is the ``fixed_subnet_cidr`` which controls the address range that
is used by the cluster nodes. The default value for this is **10.0.0.0/24**.
The second is ``calico_ipv4pool`` which controls the address range used for
the Pod IP address pool. The default for this **10.100.0.0./16**.

It is possible to modify either of these two address space by supplying a new
label value a the time the cluster is created. For example, if we wished to
use the range 172.16.0.0/24 for our pod IP addresses we would change the label
to the following:

.. code-block:: bash

    calico_ipv4pool=172.16.0.0/24

For the specifics on how to change label values in a cluster template when
creating your cluster please see :ref:`here<modifying_a_cluster_with_labels>`.

********
Security
********

The security of a cluster is mainly affected by how many access points there
are to the cluster. As such, the following mainly speaks on important options
for access to your cluster that you should consider.

The first issue which follows on from your networking considerations is, where
am I going to be able to access the cluster? Because you have the option to
make the cluster publicly accessible, you could create it so that you and those
who need access to the cluster can do so wherever they are. This does come with
the same risks as exposing anything to the public internet however.

Alternatively, if you are creating a private cluster, you can refine the
location from where you are able to access the cluster. This customization goes
beyond just your internal network. You could limit the access to the API's from
only a fixed ip address range, whether this is for your entire company's subnet
or you may only want the APIs visible from a management subnet? Or an office
specific subnet? Regardless of where you may want the cluster exposed, the
options are there for you to decide.


.. _limiting_access:

Limiting access to the API
==========================

If you have already opted to go with a private cluster then this consideration
is of less importance to you. If, however, you have deployed a publicly
accessible cluster you can minimise your exposure to risk by applying the
following.

To restrict access to the cluster API we can supply a comma separated list of
CIDR values to the ``master_lb_allowed_cidrs`` label when we create the cluster.
This limits which IP addresses the load balancer will accept external requests
from.

The default value is “” which means access is open to 0.0.0.0/0.

.. Note::

    This will only work when the cluster has been deployed with a loadbalancer
    in front of the Kubernetes API as is the case for all of the Catalyst Cloud
    production templates.

As an example of what the create command could look like, let's assume we wish
to create a cluster based on the following conditions:

- It is based on a production template
- It is publicly accessible via the internet
- That access will be restricted to to a single IP address

The resulting command would look like this.

.. code-block:: console

    $ openstack coe cluster create k8s-cluster \
    --cluster-template kubernetes-v1.18.2-prod-20200630 \
    --labels master_lb_floating_ip_enabled=true,master_lb_allowed_cidrs=203.109.145.15/32 \
    --merge-labels \
    --keypair glyndavies \
    --node-count 2 \
    --master-count 3

********
Capacity
********

Your capacity needs will vary wildly depending on what you need to utilize a
cluster for. Therefore when we talk about capacity considerations for
*a production cluster* it is difficult to be specific, as each users needs will
differ. However, there are some key factors and options that are available that
you should know in regards to the size of your clusters and the scale of how
many nodes you need.

For the size of your individual nodes. The templates that we provide for
your clusters have a default flavor set that should be sufficient for most
uses. Generally, we do not use a large flavor size as tasks performed in a
kubernetes cluster are more reliant on scaling horizontally than on each
individual node requiring a large amount of resources.

In the case of scaling, this is entirely dependant on what action you are
trying to perform using your cluster. For any individual cluster we recommended
that your master node count is at minimum three nodes, but always an odd number
if you can help it. This is to ensure that your cluster always remains
*highly available* as the fault tolerance for your system will scale as the
cluster does. For scaling to meet the demands of your system, we recommended
using the autoscaling feature, as this will allow your cluster to perform
optimally no matter the amount of work it needs to complete.

Both of these capacity considerations are reliant on having a sufficient
:ref:`quota<quota-info>` for your project. If you are utilizing autoscaling but
are working with a quota that is smaller than your demand requires than you
will run in to errors constantly. That is why it is also important that you
increase your quota size based on demand.

**********
Monitoring
**********

An important part of running a production cluster is making sure that it is
healthy and that you can track what actions have taken place on your clusters.
You can monitor the status of your cluster at any time using the
**container infra** or the orchestration tabs via the Dashboard.

Additionally, if you need to review or set up logging for your cluster, you
can find more information on this topic under the
:ref:`logging<kubernetes-logging>` tab of this documentation.


