.. _compute:

#######
Compute
#######

The compute service provides scalable on-demand compute capacity for your
applications in the form of compute instances. Functioning similarly to virtual
computers, these instances provide compute capacity for whatever task you need.
The key difference between the two is the *on-demand* nature of the cloud. Our
compute instances can be scaled up, down, or horizontally (by adding and
removing more compute instances) at any time; meaning that you are able to
meet the demands of your business faster and more efficiently.

Another important feature that the compute service provides is the level of
abstraction between you as a user and the physical machines you consume.
When you provision a compute instance, you are given access to an instance that
has all of the preferences you specify, provided that the resources you
request do not exceed your :ref:`quota.<quota_management>` However, you do not
have to worry about the physical condition of the instance or the resources it
uses, that is all taken care of by the Cloud. So should some maintenance need
to be performed on the physical components your system lies on, there should
be no impact to your instances or your business while it is performed. This
means that your system is overall more resilient and reliable.

Please refer to the :ref:`launch-first-instance` tutorial for step by step
guidance on how to launch your first compute instance (and the pre-requisites
to do so).

Table of Contents

.. toctree::
  :maxdepth: 1

  compute/quickstart
  compute/instance-types
  compute/launch-compute-instance
  compute/console
  compute/resize-instance
  compute/stop-instance
  compute/create-new-from-existing
  compute/gpu-support
  compute/anti-affinity-groups-ha
  compute/faq
  Best practices <compute/compute-bp>
