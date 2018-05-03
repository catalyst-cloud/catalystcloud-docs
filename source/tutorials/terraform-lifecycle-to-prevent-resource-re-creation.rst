###################################################
Terraform - prevent accidental resource re-creation
###################################################

This tutorial shows you how to use Terraform lifecycle option to prevent
undesirable resource re-creation.

`Terraform`_ is an infrastructure as a code software that can be used to
manage Catalyst Cloud.

.. _Terraform: https://www.terraform.io/


Problem
=======

In Catalyst Cloud we provide OS images that users can use to start their
virtual machines. We update our images regularily so the image name stays
the same but image contents changes. Users who manage Catalyst Cloud using
Terraform, will notice that when they use certain images to start compute
instances Terraform will periodically offer to re-create an entire instance
in response to image id change.

.. code-block:: bash

  resource "openstack_compute_instance_v2" "instance-name" {
    ...
    # re-created every time image "ubuntu-18.04-x86_64" is updated.
    image_name      = "ubuntu-18.04-x86_64"
  }

.. code-block:: bash

  vm1:~/idempotency-test-terraform$ terraform plan
  Refreshing Terraform state in-memory prior to plan...
  The refreshed state will be used to calculate this plan, but will not be
  persisted to local or remote state storage.

  openstack_compute_instance_v2.basic: Refreshing state... (ID: dca5cf20-70bd-474c-a05b-1939f0db557c)

  ------------------------------------------------------------------------

  An execution plan has been generated and is shown below.
  Resource actions are indicated with the following symbols:
  -/+ destroy and then create replacement

  Terraform will perform the following actions:

  -/+ openstack_compute_instance_v2.basic (new resource required)
        id:                  "dca5cf20-70bd-474c-a05b-1939f0db557c" => <computed> (forces new resource)
        ...
        image_id:            "ad091b52-742f-469e-8f3c-fd81cadf0743"  => "ed6468b1-0ebf-4b67-97cf-e9f67bf627ef" (forces new resource)
        image_name:          "ubuntu-18.04-x86_64"
        ...


  Plan: 1 to add, 0 to change, 1 to destroy.

  ------------------------------------------------------------------------

Lifecycle or image ID
=====================
One possible solution is to use `image_id` in Terraform manifes, this will

.. code-block:: bash

  resource "openstack_compute_instance_v2" "instance-name" {
    ...
    image_id        = "ad091b52-742f-469e-8f3c-fd81cadf0743"
  }

while this solution works some people - others prefer to use `image_name` field
for descriptive purposes, in this case another possible solution is to tell
Terraform to ignore changes in `image_name`

.. code-block:: bash

  resource "openstack_compute_instance_v2" "instance-name" {
    ...
    image_name      = "ubuntu-18.04-x86_64"
    lifecycle {
      ignore_changes = ["image_name"]
    }
  }

This will prevent Terraform from re-creating the instance when image_id changes.
