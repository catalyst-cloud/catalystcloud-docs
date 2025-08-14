.. _services_on_the_catalyst_cloud:

####################################
What services are on Catalyst Cloud?
####################################

In the previous section, we learned that services on Catalyst Cloud are
pieces of hardware and software that we make easy and convenient to use by
controlling them through means such as our Dashboard or the CLI (Command line
interface). Now we'll discuss the various services
offered by Catalyst Cloud so that we know *what* we can do on Catalyst
Cloud, even if right now we don't know *how* we can do it yet.


*************
The services
*************

Compute service
===============

The compute service provides compute power on demand, in the form of
"instances". If you like to think about physical computers, you can imagine an
instance as one or more CPUs and GB of RAM that you have provisioned usage of.
Instances come in many sizes, as you can see on Catalyst Cloud's `compute
page`_.

.. _`compute page`: https://catalystcloud.nz/services/iaas/compute/#prices

Image service
=============

It is a common task to install an operating system onto a block storage volume,
so that you can boot the instance into the operating system. The image service
was created to make this as easy as possible.

An image is a "pre-made" operating system installation that can be used
immediately by an instance, rather than spending time installing the operating
system, the drivers, miscellaneous files, and configurations that help the
instance integrate better with Catalyst Cloud. Images allow you to know
that your preferred operating system will work on Catalyst Cloud the first
time you try.

Among the operating systems provided out of the box on Catalyst Cloud image
service are Ubuntu, Microsoft Windows Server, Debian, and CentOS. You can
also create your own custom images to account for your own specific needs.

Block storage service
=====================

The block storage service provides volumes of data storage that you can attach
to instances. You could imagine block storage volumes as hard disk drives and
solid state drives on a physical computer. Block storage volumes can be as
large or as small as you want them to be, however they are not dynamic; you
decide beforehand how much storage you want to partition. In addition,
block volumes are automatically replicated multiple times across the data
centre to make your data very durable, and very available.

By attaching a volume to an instance, you mount it, making the file system
available to the CPU and memory.

Object storage service
======================

Object storage is a storage system unique to cloud computing. Instead of
provisioning a volume of storage capacity, you just upload a file, and Catalyst
Cloud handles it's storage.

One of object storage's biggest advantages is it's price. As an illustration,
imagine you're provisioning a block storage volume for a database. Many of the
bits you've provisioned within that volume are unused 0s, not yet used by the
database to store any data. With object storage, you only pay for bits your
files are using, not any empty, unproductive bits. This allows you to minimise
your costs. Secondarily, data stored in object storage can be more efficiently
stored than block storage, allowing Catalyst Cloud to charge less for it.

Network service
===============

The network service allows you to perform networking tasks easily, flexibly,
and quickly. You are given the ability to create, edit, assign, and delete the
basic elements of a network, like:

* Private networks;
* Sub-networks;
* Routers;
* Firewalls (called security groups);
* IP addresses;
* Site-to-site VPNs.

Load balancer service
=====================

Applications trying to deliver at scale with high service levels on the cloud
typically do so by delivering their services from numerous compute instances at
once.

However in order to balance requests between the many compute instances, a load
balancer is needed. The load balancer service makes managing this additional
component easy.

The load balancer assures requests are handled quickly, performs health checks
to assure compute instances are still available, handles the durability and
updates for the load balancer, and provides a convenient interface to make
setting up load balancing is as smooth and intuitive as possible.

Orchestration service
=====================

The orchestration service allows you to upload a template defining an
application's infrastructure stack. The orchestration service will then work to
deploy infrastructure that matches the definition in the template.

Interestingly, you don't need to tell the orchestration service how to achieve
your definition. Instead, the orchestration service will intelligently
determine the actions it needs to take to make the stack match your definition.

The orchestration service can either be used on it's own, or as another
resource that automation tools can make use of to more easily do their job.

Alarm service
=============

The alarm service allows you to create alarms that monitor custom parameters on
your project and alert you if these parameters are met. An alarm when
triggered, will inform some other service or software of a state change.
Services contacted by the alarm should be set up to perform some action based
on this alert. This typically is used alongside the orchestration service to
implement autohealing and autoscaling protocols for your compute instances.

Kubernetes service
==================

Kubernetes is a system that is designed to manage the deployment, scaling, and
health of containerised applications. The Catalyst Cloud Kubernetes Service is a
fully managed service and opens up the use of Kubernetes clusters to developers
without needing to have specialist knowledge of the platform. It also frees you
up to focus on what really matters to your business, knowing that the
Kubernetes service is monitored and managed by us 24/7.

On top of this, our Kubernetes service has been certified by the cloud native
computing foundation. Meaning that you are able to take any clusters you have
built on other cloud platforms and transfer them onto Catalyst Cloud with
ease.

**********************************
What can you do with each service?
**********************************

Catalyst Cloud is an entirely automated platform that adheres to the NIST
definition of `true cloud computing <https://csrc.nist.gov/publications/d
etail/sp/800-145/final>`_. Among other things, that means you have total and
near instant control over all the services you use on Catalyst Cloud. You
don't need to wait for a human to do things for you.

.. note::
  There are a few exceptions where human help *is* required for security
  reasons. Signing up for the first time, and increasing your
  :ref:`quota <additional-info>` are the most common.
  We intend to automate these in the future.

Resources on Catalyst Cloud can be created, deleted, assigned, resized,
copied, and edited at your convenience using one of the many tools available to
interact with Catalyst Cloud. Performing these administrative actions do
not cost anything.

With Catalyst Cloud, you have total control over your infrastructure. You
have root/console access to your instances, and Catalyst Cloud places no
restrictions on what software you use. This is because each
:ref:`project <admin-projects>` on Catalyst Cloud is
isolated from all the other projects. Isolation means that the resources and
the actions taken in one project can't effect anything else outside of that
project.

***************************************
How much do I need to pay for services?
***************************************

It's important to discuss how a true cloud computing platform like, Catalyst
Cloud charges you for the resources you use; because it strongly effects the
way you'll use it.

Catalyst Cloud charges by the hour. Each hour, we check what resources you're
using, and add a small amount to your bill. Each month, we send you an invoice
for the bill you've accumulated that month. This means you can save money by
disabling your resources for even short periods of time, such as overnight.

This is useful information to apply for situations like automated testing, for
example. Many organisations will have a staging server running 24/7 where they
will deploy their application to test it before applying changes to the main,
production server. Running the staging server 24/7 is wasteful, however.
Instead, the organisation could implement an automated process that will only
create a staging server when they are actively testing their application. This
will save costs greatly.

There is no minimum limit for the resources you need to consume on Catalyst
Cloud per hour. In fact, we encourage you to disable your resources if you
don't need them. This flexibility is one of the biggest reasons so many
in-the-know organisations are building and migrating their applications to
Catalyst Cloud.

|

Now that we've discussed what services are available on Catalyst Cloud, we
can discuss how to use them.


:ref:`Previous page <introduction-to-catalyst-cloud>` -
:ref:`Next page <access_to_catalyst_cloud>`


