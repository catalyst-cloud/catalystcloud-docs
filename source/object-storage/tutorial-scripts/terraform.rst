This tutorial assumes that you have some familiarity with `Terraform`_.
The minimum knowledge this tutorial assumes is an understanding of how
Terraform scripts are written and how they function. We also assume that you
have installed all of the prerequisite tools to run Terraform scripts.

.. _Terraform: https://www.terraform.io/

Below is an example template that contains the basic information required
for Terraform to create an object storage container on the cloud. You can
view the full list of customization options for this resource on the
`Terraform documentation`_

.. _Terraform documentation: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/objectstorage_container_v1

.. code-block:: bash

    provider "openstack" {
    }
    resource "openstack_objectstorage_container_v1" "container_1" {
      name   = "tf-test-container-1"
      metadata = {
        test = "true"
      }
      content_type = "application/json"
    }

Once you have saved this script you will need to switch to the correct
directory and run the following commands to create your new object storage
container. The first command will outline what resources are going to be made
and managed by Terraform and what their outputs will be:

.. code-block:: bash

    $ terraform plan
      Refreshing Terraform state in-memory prior to plan...
      The refreshed state will be used to calculate this plan, but will not be
      persisted to local or remote state storage.
      ------------------------------------------------------------------------
      An execution plan has been generated and is shown below.
      Resource actions are indicated with the following symbols:
        + create

      Terraform will perform the following actions:

        # openstack_objectstorage_container_v1.container_1 will be created
        + resource "openstack_objectstorage_container_v1" "container_1" {
            + content_type  = "application/json"
            + force_destroy = false
            + id            = (known after apply)
            + metadata      = {
                + "test" = "true"
              }
            + name          = "tf-test-container-1"
            + region        = (known after apply)
          }

      Plan: 1 to add, 0 to change, 0 to destroy.
      ------------------------------------------------------------------------
      Note: You didn't specify an "-out" parameter to save this plan, so Terraform
      can't guarantee that exactly these actions will be performed if
      "terraform apply" is subsequently run.

After you review the Terraform plan and ensure that it has all the
resources you want to be created, you can use the following code to
create your new objects:

.. code-block:: bash

    $ terraform apply
      ... #truncated for brevity
      Do you want to perform these actions?
      Terraform will perform the actions described above.
      Only 'yes' will be accepted to approve.

      Enter a value: yes

      openstack_objectstorage_container_v1.container_1: Creating...
      openstack_objectstorage_container_v1.container_1: Creation complete after 5s [id=tf-test-container-1]

      Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Once you have reached this step, you should have an object storage container
created
and managed by Terraform. If you want to delete this container in the future, as
well as any other resources created in your plan, you can use the following
code to
delete them:

.. code-block:: bash

    $ terraform destroy
      ... # truncated for brevity
      Do you really want to destroy all resources?
      Terraform will destroy all your managed infrastructure, as shown above.
      There is no undo. Only 'yes' will be accepted to confirm.

      Enter a value: yes

      openstack_objectstorage_container_v1.container_1: Destroying... [id=tf-test-container-1]
      openstack_objectstorage_container_v1.container_1: Destruction complete after 1s

      Destroy complete! Resources: 1 destroyed.

