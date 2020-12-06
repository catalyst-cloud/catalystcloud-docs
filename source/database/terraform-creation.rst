.. raw:: html

  <h3> Using a Terraform template </h3>

This tutorial assumes that you have knowledge of how Terraform works and
how it manages the resources it creates. The following section will provide you
with a template that will create a new database instance which has a single
database running on it. Through each step we will explain how to create each
resource using a terraform template.

.. raw:: html

  <h3> Gathering necessary information for your template </h3>

To resize an instance using terraform, there are two things that we will
need to change in our template. We need to update the flavor ID to match
the new size we want to use, and we need to add an optional argument to
our resource deceleration; to ignore the need to confirm our instance
resize.

First, we need to find the flavor ID that we will resize our instance to:

.. code-block::

  # The following output has been truncated for brevity
  $ openstack flavor list

  +--------------------------------------+------------+--------+------+-----------+-------+-----------+
  | ID                                   | Name       |    RAM | Disk | Ephemeral | VCPUs | Is Public |
  +--------------------------------------+------------+--------+------+-----------+-------+-----------+
  | 01d5b414-14d5-4349-b823-aa46afb6d628 | c1.c4r32   |  32768 |   10 |         0 |     4 | True      |
  | 02d12ad8-badc-4a41-9dae-5cdfbb10f75e | c1.c1r4    |   4096 |   10 |         0 |     1 | True      |
  | 374fc408-7a30-483c-a8ce-fbaacef8cefd | c1.c32r16  |  16384 |   10 |         0 |    32 | True      |
  | 3d11be79-5788-4d70-9058-4ccd20c750ee | c1.c1r05   |    512 |   10 |         0 |     1 | True      |
  | 3df41a1b-fe84-4876-a1ef-fcde4df334dd | c1.c16r24  |  24576 |   10 |         0 |    16 | True      |
  | 5643df3f-7a6d-476d-b035-acaecd54cfda | c1.c32r96  |  98304 |   10 |         0 |    32 | True      |
  | 589b9451-ccc9-4b4c-b6c8-6e7da8149847 | c1.c32r256 | 262144 |   10 |         0 |    32 | True      |
  | 59ae6d98-aee7-4595-8bf0-25d119dded9b | c1.c2r8    |   8192 |   10 |         0 |     2 | True      |
  | 5eb576f1-3f61-4121-a5a5-09874103b721 | c1.c4r6    |   6144 |   10 |         0 |     4 | True      |
  | 5ff0b09b-684c-4212-8edc-826f26f9ab78 | c1.c2r4    |   4096 |   10 |         0 |     2 | True      |
  | 6104d093-4c74-4493-adb9-b2e0bd087628 | c1.c8r32   |  32768 |   10 |         0 |     8 | True      |
  | 6371ec4a-47d1-4159-a42f-83b84b80eea7 | c1.c1r1    |   1024 |   10 |         0 |     1 | True      |
  | a18d0408-f2cb-410d-a941-e200837961d2 | c1.c1r2    |   2048 |   10 |         0 |     1 | True      |
  | ...                                  |            |        |      |           |       |           |
  +--------------------------------------+------------+--------+------+-----------+-------+-----------+

Once we have the flavor we want our instance to be resized to
(for this example we will use the c1.c1r2 flavor) we need to look at our
template and change the flavor ID that we are using. For the following
example, we are using a template that has declared the flavor as a
variable.

.. code-block::

  variable "compute_flavor_ID" {
  default = "6371ec4a-47d1-4159-a42f-83b84b80eea7"
  }

  # We will replace the default value with our new flavor ID so that it will look like this:

  variable "compute_flavor_ID" {
  default = "a18d0408-f2cb-410d-a941-e200837961d2"
  }

After we have changed our flavorID, we will need to add a
``vendor option`` to our ``openstack_compute_instance_v2`` resource so
that we bypass the need to confirm our resize:

.. code-block::

  # The section that we are adding is the "ignore_resize_confirmation = true"

  resource "openstack_compute_instance_v2" "instance_1" {
      name = "terraform-instance"
      #image_id = "${var.compute_image_ID}"
      flavor_id = "${var.compute_flavor_ID}"
      network {
          name = "${openstack_networking_network_v2.network_1.name}"
      }
      key_pair = "${openstack_compute_keypair_v2.keypair_1.name}"
      security_groups = ["${openstack_compute_secgroup_v2.secgroup_1.name}","default"]
      vendor_options {
        ignore_resize_confirmation = true
      }
  }

Once this is done we can perform our terraform apply command and our
instance should resize correctly.
