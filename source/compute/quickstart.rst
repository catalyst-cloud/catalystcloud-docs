##########
Quickstart
##########

********
Overview
********

The purpose of this quickstart is to help you launch a compute instance that
you can test and experiment with, in order to get a better understanding of
how the compute service works.

In order to this, we will provide a simple, single instance example using some
of the most common options that are being used by our customers. These are:

- The Catalyst Cloud `web dashboard`_.
- The Openstack `command line tools`_.
- The Openstack `Heat`_ orchestration tool.
- Red hat `Ansible`_ orchestration tool.
- The Hashicorp `Terraform`_ orchestration tool.

.. _command line tools: https://docs.openstack.org/newton/user-guide/cli.html
.. _web dashboard: https://dashboard.cloud.catalyst.net.nz
.. _Heat: https://wiki.openstack.org/wiki/Heat
.. _Ansible: https://www.ansible.com/
.. _Terraform: https://www.terraform.io/

Configuration
=============

The configuration we will use for these examples, is based on the settings that
would be found in a brand new cloud project, which will have been provisioned
with a single network.

We will launch a compute instance using an Ubuntu 20.04 image and will
connected it to the default network mentioned above. We will also create a
security group to allow inbound SSH traffic

The configuration details are as follows:

- region name : nz-hlz-1
- external network name : public-net
- internal network name : private-net
- image name: ubuntu-20.04-x86_64
- flavor name : c1.c1r1


Assumptions
===========

These guides assume the following:

- You have whitelisted the public facing IP address that you will be using to
  access the Catalyst Cloud APIs. Alternatively you can work from or via an
  instance based in your cloud project, as it will have API access by default.

- You have implemented an appropriate authentication method to allow you to
  interact with your Catalyst Cloud project. There are several options
  available to you depending on your tool of choice, some of these are:

  - Using the openrc file
  - Using a clouds.yaml

- You have uploaded or created an SSH key.

The following is a set of different templates that you can use as create
your own compute instances. These instances will be the same as if you followed
the instructions from the :ref:`first instance <launch-first-instance>` section
of the documents.

You will need to change some of the variables in these templates so that they
fit your own project variables; and you will need to :ref:`source-rc-file` so
you can interact correctly with your project.

.. tabs::

    .. tab:: Openstack CLI

        .. literalinclude:: _scripts/cli/cli_basic_compute_create.sh
            :language: shell
            :caption: cli_basic_compute_create.sh

        .. literalinclude:: _scripts/cli/cli_basic_compute_destroy.sh
            :language: shell
            :caption: cli_basic_compute_destroy.sh

    .. tab:: Heat

        .. literalinclude:: _scripts/heat/heat_env.yaml
            :language: yaml
            :caption: heat_env.yaml

        .. literalinclude:: _scripts/heat/heat_basic_compute.yaml
            :language: yaml
            :caption: heat_basic_compute.yaml

    .. tab:: Terraform

        The following assumes that you have already sourced an openRC file and
        that you have downloaded and installed terraform.

        The template file that you will be running is:

        .. literalinclude:: _scripts/terraform/terraform-variables.tf
            :language: shell
            :caption: terraform-variables.tf

        The commands you will need to use are:

        .. literalinclude:: _scripts/terraform/terraform-create.sh
            :language: shell
            :caption: terraform-create.sh

        .. literalinclude:: _scripts/terraform/terraform-destroy.sh
            :language: shell
            :caption: terraform-destroy.sh
