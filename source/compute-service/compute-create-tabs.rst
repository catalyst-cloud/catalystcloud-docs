######################################################################
Page to test literal includes and tabs for creating a compute instance
######################################################################



.. tabs::

    .. tab:: Openstack CLI

        .. literalinclude:: _scripts/cli_basic_compute_create.sh
            :language: shell
            :caption: cli_basic_compute_create.sh

        .. literalinclude:: _scripts/cli_basic_compute_destroy.sh
            :language: shell
            :caption: cli_basic_compute_destroy.sh

    .. tab:: Heat

        .. literalinclude:: _scripts/heat_env.yaml
            :language: yaml
            :caption: heat_env.yaml

        .. literalinclude:: _scripts/heat_basic_compute.yaml
            :language: yaml
            :caption: heat_basic_compute.yaml


    .. tab:: Python SDK

        .. code-block:: bash

    .. tab:: Ansible

        .. code-block:: bash

    .. tab:: Terraform

        The following assumes that you have already sourced an openRC file and
        that you have downloaded and installed terraform.

        The template file that you will be running is:

        .. literalinclude:: _scripts/terraform-variables.tf
            :language: shell
            :caption: terraform-variables.tf

        The commands you will need to use are:

        .. literalinclude:: _scripts/terraform-create.sh
            :language: shell
            :caption: terraform-create.sh

        .. literalinclude:: _scripts/terraform-destroy.sh
            :language: shell
            :caption: terraform-destroy.sh
