.. _access_to_catalyst_cloud:

############################
Accessing the Catalyst Cloud
############################

In the previous section, we learned about the various services the Catalyst
Cloud offers. Now we'll learn about the various ways you can interact with
these services.


*****************
The web dashboard
*****************

The web dashboard is a simple way to interact with The Catalyst Cloud. It can
be found at https://dashboard.cloud.catalyst.net.nz.

.. image:: assets/dashboard_view.png

One advantage to the web dashboard is that it is accessible from any IP address,
making it a quick way to perform tasks on the Catalyst Cloud while you're away
from your normal work station.


**************************
The command line interface
**************************

The command line interface (CLI) is a very powerful, efficent way to interact
with Catalyst Cloud. To use the CLI you will need to:

1. Install the OpenStack CLI.
2. Tell the OpenStack CLI who you are, and which OpenStack cloud you want to
   connect to. This is typically done by sourcing a configuration file that sets
   environment variables to configure the CLI.

You can find instructions on how to install and set up the CLI :ref:`here
<command-line-interface>`.

We're also working on a containerised version of the CLI designed to help you
get up and running as quickly and intuitively as possible. You can `try it here
<https://github.com/catalyst-cloud/openstackclient-container>`_.

After installing and configuring the CLI, you may want to familiarise yourself
with it's functioning by following :ref:`this tutorial
<using-the-command-line-interface>` to use it to deploy a compute instance.

For more in depth documentation, the official OpenStack Client documentation is
the most thorough source of information. You can `find it here
<https://docs.openstack.org/python-openstackclient>`_.


****************
Automation tools
****************

To utilise the most valuable aspects of cloud computing, or to manage and
orchestrate a cloud computing environment at scale, automation tools are
invaluable. Because Catalyst Cloud is based on the world's most popular open
source cloud computing platform, OpenStack, many automation tools work with the
Catalyst Cloud, or have plugins to work with the Catalyst Cloud.

Among our prefered automation tools are:

- :ref:`Ansible <launching-your-first-instance-using-ansible>`
- Chef
- :ref:`Puppet <bootstrapping-puppet-from-heat>`
- :ref:`Terraform <launching-your-first-instance-using-terraform>`


**********
API access
**********

Behind the scenes, all of the access methods to the Catalyst Cloud are just
accessing the Catalyst Cloud APIs. They just provide convenient abstractions to
do so. Every action you perform on the Catalyst Cloud can be performed via the
APIs.

This means that you can incorporate custom logic into your applications to
modify your infrastructure. This is important for `SaaS
<https://en.wikipedia.org/wiki/Software_as_a_service>`_ applications, or
applications that otherwise need to scale to meet demand.

To make this integration easier, the OpenStack community has developed a range
of software development kits (SDKs) for numerious languages. You can find a list
`here <https://wiki.openstack.org/wiki/SDKs>`_.

|

Now that you understand how you can access the Catalyst Cloud, there are a few
small administrative concerns to be aware of before we dive into a hands on
demonstration.

:ref:`Next page <administrating_the_catalyst_cloud>`
