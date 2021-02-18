.. raw:: html

  <h3> Creating a load balancer using Terraform </h3>

For this example, we assume that you already have some knowledge of how
Terraform functions and that you know how to construct a Terraform template.
If you have not used terraform before, or are not sure how to use it on the
Catalyst Cloud, you can find a good starting example under the
:ref:`first instance<launching-your-first-instance-using-terraform>`
section of the documents. If you are wanting an even more in depth look at
Terraform, you can also check the `Terraform documentation`_.

.. _Terraform documentation: https://www.terraform.io/


.. raw:: html

  <h3> Preparation </h3>

As we mentioned earlier, this tutorial assumes that you already have installed
the necessary tools to work with a terraform template. If you have not
downloaded and installed terraform, you can follow our guide in the
:ref:`getting started<launching-your-first-instance-using-terraform>` section
of the docs.

Once you have the correct tools ready, we can start working on our template.
The template file that we are going to use for this example, is going to create
a load balancer to manage a pair of webservers. You can use the script
explained in the CLI example to create your own set of simulated webservers.

A key difference between this example and the CLI example is that we are
focusing on having the webservers respond and balanced only on port 80. Which
means that we can ignore the instructions from the CLI example referencing
port 443.

Once you have a set of webservers that are serving traffic on port 80, we need
to gather the necessary information that our template requires. Lets start with
getting our subnet ID for the network we are going to have our loadbalancer
on:

.. code-block:: bash

  $ source example-openRC.sh
  $ openstack subnet list
  +--------------------------------------+---------------------+--------------------------------------+-----------------+
  | ID                                   | Name                | Network                              | Subnet          |
  +--------------------------------------+---------------------+--------------------------------------+-----------------+
  | aaa43782v-auih-d3hak4i7-bfmdb-jmu2r3 | lb-docs-test-subnet | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | 192.168.0.0/24  |
  +--------------------------------------+---------------------+--------------------------------------+-----------------+

Once you have your subnet ID, next you will need to get the local IP of your
webservers:

.. code-block:: bash

  $ openstack server list
  +--------------------------------------+--------------------+--------+----------------------------+--------------------------+---------+
  | ID                                   | Name               | Status | Networks                   | Image                    | Flavor  |
  +--------------------------------------+--------------------+--------+----------------------------+--------------------------+---------+
  | 28ad54af-e0d2-47c9-8855-4245dbfa3628 | webserver-2        | ACTIVE | private-net=192.168.3.41   | N/A (booted from volume) | c1.c1r1 |
  | 6ea96e5e-8b67-4ec3-80a3-460b5b116bad | webserver-1        | ACTIVE | private-net=192.168.3.40   | N/A (booted from volume) | c1.c1r1 |
  +--------------------------------------+--------------------+--------+----------------------------+--------------------------+---------+

  # From this output, we can find the IP addresses under the "Networks" section:
  # Member_1 = 192.168.3.41 , Member_2 = 192.168.3.40

.. raw:: html

  <h3> Creating resources </h3>

After you have gathered this information, you need to construct a template to
create your loadbalancer. You can use the following as a base and insert the
information we gathered earlier into the variables provided:

.. literalinclude:: /load-balancer/_scripts/layer4-files/terraform/load-balancing.tf

Once you have your template ready with the correct variables, you can run the
``terraform plan`` command to get an output of what resources your template is
going to construct for you:

.. literalinclude:: /load-balancer/_scripts/layer4-files/terraform/terraform-plan.txt

At this point, after you have checked the plan and made sure all of the
resources are correct and that the template is has no formatting problems, you
can run the ``terraform apply`` command and begin creating your resources:

.. code-block::

  $ terraform apply

  ... # truncated output for brevity.
  Plan: 10 to add, 0 to change, 0 to destroy.

  Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value: yes

  openstack_networking_secgroup_v2.secgroup_1: Creating...
  openstack_networking_floatingip_v2.fip_1: Creating...
  openstack_networking_secgroup_v2.secgroup_1: Creation complete after 2s [id=04a48ceb-44c4-4f71-9c16-ac7805a070d3]
  openstack_networking_secgroup_rule_v2.secgroup_rule_1: Creating...
  openstack_lb_loadbalancer_v2.terra_load_balancer: Creating...
  openstack_networking_secgroup_rule_v2.secgroup_rule_1: Creation complete after 0s [id=46f0734a-0468-4e03-a5fa-16d462c6f089]
  openstack_networking_floatingip_v2.fip_1: Creation complete after 7s [id=cd8006d1-1010-47d8-b6af-a69ee7a349ea]
  openstack_lb_loadbalancer_v2.terra_load_balancer: Still creating... [10s elapsed]
  openstack_lb_loadbalancer_v2.terra_load_balancer: Still creating... [20s elapsed]
  openstack_lb_loadbalancer_v2.terra_load_balancer: Still creating... [30s elapsed]
  openstack_lb_loadbalancer_v2.terra_load_balancer: Still creating... [40s elapsed]
  openstack_lb_loadbalancer_v2.terra_load_balancer: Still creating... [50s elapsed]
  openstack_lb_loadbalancer_v2.terra_load_balancer: Still creating... [1m0s elapsed]
  openstack_lb_loadbalancer_v2.terra_load_balancer: Still creating... [1m10s elapsed]
  openstack_lb_loadbalancer_v2.terra_load_balancer: Creation complete after 1m11s [id=5529a920-c32e-4eda-b533-98ece771fb0b]
  openstack_networking_floatingip_associate_v2.fip_associate: Creating...
  openstack_lb_listener_v2.listener_1: Creating...
  openstack_networking_floatingip_associate_v2.fip_associate: Creation complete after 1s [id=cd8006d1-1010-47d8-b6af-a69ee7a349ea]
  openstack_lb_listener_v2.listener_1: Creation complete after 9s [id=56b09389-bcd5-4e02-9eeb-e3d0f72e13e5]
  openstack_lb_pool_v2.pool_1: Creating...
  openstack_lb_pool_v2.pool_1: Creation complete after 5s [id=be81e2b6-927f-4f7a-affb-95d926355e9d]
  openstack_lb_member_v2.member_1: Creating...
  openstack_lb_member_v2.member_2: Creating...
  openstack_lb_monitor_v2.monitor_1: Creating...
  openstack_lb_member_v2.member_1: Creation complete after 8s [id=9190707b-2358-422d-8cdd-90fd2b5a2d98]
  openstack_lb_monitor_v2.monitor_1: Creation complete after 9s [id=67c133f7-3857-425c-8f4a-781c3b11a6f1]
  openstack_lb_member_v2.member_2: Still creating... [10s elapsed]
  openstack_lb_member_v2.member_2: Creation complete after 17s [id=d30ee7dc-63f4-4e41-8f27-bd2484383ab5]

  Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

.. raw:: html

  <h3> Deleting resources </h3>


Should you wish to remove these resources, you can use the command:

.. code-block::

  $ terraform destroy

  Plan: 0 to add, 0 to change, 10 to destroy.

  Do you really want to destroy all resources?
    Terraform will destroy all your managed infrastructure, as shown above.
    There is no undo. Only 'yes' will be accepted to confirm.

    Enter a value: yes

  openstack_networking_secgroup_rule_v2.secgroup_rule_1: Destroying... [id=46f0734a-0468-4e03-a5fa-16d462c6f089]
  openstack_networking_floatingip_associate_v2.fip_associate: Destroying... [id=cd8006d1-1010-47d8-b6af-a69ee7a349ea]
  openstack_lb_member_v2.member_2: Destroying... [id=d30ee7dc-63f4-4e41-8f27-bd2484383ab5]
  openstack_lb_member_v2.member_1: Destroying... [id=9190707b-2358-422d-8cdd-90fd2b5a2d98]
  openstack_lb_monitor_v2.monitor_1: Destroying... [id=67c133f7-3857-425c-8f4a-781c3b11a6f1]
  openstack_networking_floatingip_associate_v2.fip_associate: Destruction complete after 1s
  openstack_networking_floatingip_v2.fip_1: Destroying... [id=cd8006d1-1010-47d8-b6af-a69ee7a349ea]
  openstack_networking_secgroup_rule_v2.secgroup_rule_1: Destruction complete after 6s
  openstack_networking_floatingip_v2.fip_1: Destruction complete after 6s
  openstack_lb_monitor_v2.monitor_1: Destruction complete after 8s
  openstack_lb_member_v2.member_1: Destruction complete after 9s
  openstack_lb_member_v2.member_2: Still destroying... [id=d30ee7dc-63f4-4e41-8f27-bd2484383ab5, 10s elapsed]
  openstack_lb_member_v2.member_2: Destruction complete after 11s
  openstack_lb_pool_v2.pool_1: Destroying... [id=be81e2b6-927f-4f7a-affb-95d926355e9d]
  openstack_lb_pool_v2.pool_1: Destruction complete after 3s
  openstack_lb_listener_v2.listener_1: Destroying... [id=56b09389-bcd5-4e02-9eeb-e3d0f72e13e5]
  openstack_lb_listener_v2.listener_1: Destruction complete after 5s
  openstack_lb_loadbalancer_v2.terra_load_balancer: Destroying... [id=5529a920-c32e-4eda-b533-98ece771fb0b]
  openstack_lb_loadbalancer_v2.terra_load_balancer: Destruction complete after 7s
  openstack_networking_secgroup_v2.secgroup_1: Destroying... [id=04a48ceb-44c4-4f71-9c16-ac7805a070d3]
  openstack_networking_secgroup_v2.secgroup_1: Destruction complete after 9s

  Destroy complete! Resources: 10 destroyed.
