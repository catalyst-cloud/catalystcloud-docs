.. _tutorial_terraform:

###################################
Using Terraform with Catalyst Cloud
###################################

Terraform is a cloud-agnostic infrastructure lifecycle tool commonly
used to implement Infrastructure as Code practices. You can read
more about Terraform on their website at http://terraform.io/.

The OpenStack provider in Terraform is used to manage resources on 
Catalyst Cloud. 

.. note::

    While Catalyst Cloud has tested and makes contributions to 
    Terraform, we do not guarantee that Terraform will always
    support our platform versions or correctly implements 
    OpenStack support. Where we know of issues, we will note
    those issues on the service pages in this documentation.

Basic Configuration
===================

A provider block is needed to interact with Catalyst Cloud from your
Terraform template. A simple example, which uses authentication 
from your environment, would be:

.. code-block::

    terraform {
        required_providers {
            openstack = {
                source = "terraform-provider-openstack/openstack"
                version = "1.48.0"
            }
        }
    }

    provider "openstack" {
        use_octavia = true
        max_retries = 10
    }

In the example above, you may need to change the version number to
reflect the latest version of the provider available in Terraform.

.. note::

    We have set ``use_octavia = true`` as Catalyst Cloud uses Octavia
    to provide load balancer support. This setting is needed to ensure
    load balancers created by Terraform operate correctly.

    Additionally, we have set ``max_retries = 10`` to ensure that if
    rate-limiting is applied to your requests, Terraform will retry
    instead of fail when a backoff message is recieved.

We suggest that credentials are not configured in the template. Instead,
they should be sourced from:

* the environment, using the standard OpenStack environment variables; or
* using the ``cloud`` parameter within the ``provider "openstack"`` block 
  to refer to an entry in ``clouds.yaml``, the standard OpenStack
  configuration file for clients.

Remote State
============

Terraform maintains the current state of the infrastructure to compute
the differences between the template and the infrastructure actually
deployed, so that the smallest number of changes can be made to update
the infrastructure.

For simple configurations, state is stored locally. However, when using
Terraform with teams and CI/CD tools, it may be useful to store state
remotely. 

Which remote state storage system is best is your choice, however we
strongly recommend against using the ``swift`` backend. This backend
has been deprecated by Terraform.

Remote state backends we suggest for Catalyst Cloud are:

* ``pg``, the PostgreSQL backend, which you can easily create using
  our Database as a Service feature;
* ``http``, which is paired with a source management platform such as
  GitLab or GitHub.

