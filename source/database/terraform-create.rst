.. raw:: html

  <h3> Creating a database instance using Terraform </h3>

This tutorial assumes that you have some knowledge of how Terraform functions
and how to construct a Terraform template. If you have not used Terraform
before, or you are not sure of how to use it on the Catalyst Cloud, please look
through the :ref:`first instance<launching-your-first-instance-using-terraform>`
section of the documents for an introduction to the tool. If you would like an
even more in depth look, you can find more information in the
`Terraform documentation`_.

.. _Terraform documentation: https://www.terraform.io/

The template file we are using in this example will create a new database
instance and attach it to an existing network. It will also create an empty
MySQL 5.7.29 database and a new database user.

To begin creating a new database instance you will need to save the following
script and make changes to the *variables* list so that the script interacts
correctly with your project:

.. literalinclude:: _scripts/terraform/database.tf
    :language: shell
    :caption: terraform-database.tf

Once you have your template constructed correctly you can use the following
commands to create the detailed resources on your project.

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

    # openstack_db_instance_v1.test-db-instance will be created
    + resource "openstack_db_instance_v1" "test-db-instance" {
        + flavor_id = "99fb31cc-fdad-4636-b12b-b1e23e84fb25"
        + id        = (known after apply)
        + name      = "test-db-instance"
        + region    = "nz-hlz-1"
        + size      = 5

        + database {
            + name = "database-1"
          }

        + datastore {
            + type    = "mysql"
            + version = "5.7.29"
          }

        + network {
            + uuid = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
          }

        + user {
            + databases = [
                + "database-1",
              ]
            + name      = "new_user"
            + password  = (sensitive value)
          }
      }

  Plan: 1 to add, 0 to change, 0 to destroy.

  ------------------------------------------------------------------------

  Note: You didn't specify an "-out" parameter to save this plan, so Terraform
  can't guarantee that exactly these actions will be performed if
  "terraform apply" is subsequently run.
  -----------------------------

  # Next, once you have verified that your plan is correct you can use the following command to create your resources:

  $ terraform apply
  -----------------------------

.. raw:: html

  <h3> Deleting your database instance using Terraform </h3>


If you have created your resources using Terraform, it is also recommended that
you use Terraform the delete them. To remove all resources associated with your
Terraform plan, you can use the following:

.. code-block:: bash

  $ terraform destroy
