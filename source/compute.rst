###############
Compute service
###############


****************************
Launching a compute instance
****************************

Instance initialisation with cloud-init
=======================================

A script called cloud-init is included in all images we provide on the Catalyst
Cloud. This script is there to assist you with instance configuration at boot
time. It communicates with the meta-data agent of our cloud and, for example,
configures the network of your cloud instance as defined by you via our APIs.

Cloud-init is very powerful and a defacto multi-distribution and multi-cloud
way of handling the early initialisation of a cloud instance.

For example, every time we launch a new instance we must apply security updates
to it, ensuring we are not exposed known security issues. The configuration
below, when passed as the user-data (either using ``--user-data`` parameter of
``nova boot``, or as post-creation customisation script via the web dashboard),
will tell cloud-init to update all software installed on the compute instance
at boot time: 

.. code-block:: bash
  #cloud-config
  # Run a package upgrade on the first boot
  package_upgrade: true

For more information on how to use cloud-init to initialise your compute
instances, please read: http://cloudinit.readthedocs.org/en/latest/index.html.


***************************
Resizing a compute instance
***************************

The resize operation can be used to change the flavor (increase or decrease the
amount of CPU and RAM) of a compute instance.

.. warning::
  The resize operation causes a brief downtime of the compute instance, as the
  guest operating system will be restarted to pick up the new configuration. If
  you need to scale your application without downtime, consider scaling it
  horizontally (add/remove compute instances) as opposed to vertically
  (add/remove resources to an existing instance).

To resize a compute instance, go to the Instances panel on the dashboard and
locate the instance to be resized. On the actions column, click on the downward
arrow to list more actions and then click on resize instance as shown below:

.. image:: _static/compute-resize-button.png
   :align: center

The resize dialogue will pop up, allowing you to chose a new flavour.

.. image:: _static/compute-resize-action.png
   :align: center

.. note::
  Before resizing down a compute instance, please consider if you need to
  change the configuration of your applications, so they can start up with less
  resources. For example: databases and Java virtual machines are often
  configured to allocate a certain amount memory and will fail to start if not
  enough memory is available.

The status of the instance will change to preparing to resize or migrate,
resized or migrated and finally “Confirm or Revert Resize/Migrate” as shown
below:

.. image:: _static/compute-confirm-resize.png
   :align: center

Once the resize operation has been completed, our cloud will prompt you to
confirm or revert the resize operation. Click on confirm to finish the resize
operation.


***************
Security groups
***************

A security group is a virtual firewall that controls network traffic to and
from compute instances. Your tenant comes with a default security group, which
cannot be deleted, and you can create additional security groups.

Security groups are made of security rules. You can add or modify security
rules at any time. When you modify a security group, the new rules are
automatically applied to all compute instances associated with it.

You can associate one or more security groups to your compute instances.

.. note::

  While it is possible to assign many security groups to a compute instance, we
  recommend you to consolidate your security groups and rules as much as
  possible.

Creating a security group
=========================

The default behaviour of security groups is to deny all traffic. Rules added to
security groups are all "allow" rules.

.. note::

  Failing to set up the appropriate security group rules is a common mistake
  that prevents users from reaching their compute instances, or compute
  instances to communicate with each other.

