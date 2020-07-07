######################################
Quickstart
######################################

The following code blocks can be used to create a new instance, with all of the
required resources, on your project.
For each code block, you will need to :ref:`source-rc-file` before you can
begin.

.. note::

 This documentation refers to values using place holders (such as ``<PRIVATE_SUBNET_ID>``)
 in the example command output. The majority of these values will be displayed as UUIDs
 in your output. Many of these values will be stored in bash variables prefixed with
 ``CC_`` so you do not have to cut and paste them. The prefix ``CC_`` (Catalyst Cloud)
 is used to  distinguish these variables from the ``OS_`` (OpenStack) variables obtained
 from an OpenRC file.


.. tabs::

    .. tab:: Openstack CLI

        Before we start creating our instance, we have to set up the resources
        that are required to support it. To start we need to create a
        network and it's required dependencies:

        .. literalinclude:: _scripts/command-line/cli-network-create.sh
            :language: shell
            :caption: cli-network-create.sh

        Set your :ref:`DNS Name Servers <name_servers>` variables. Then create a subnet
        of the "private-net" network, assigning the appropriate DNS server to that subnet:

        .. literalinclude:: _scripts/command-line/cli-dns-variables.sh
            :language: shell
            :caption: cli-dns-variables.sh

        Once we have our network, we can start to set the variables for the instance
        itself. We'll start with the flavor, which specifies the disk, CPU and
        memory allocated to an instance.

        .. literalinclude:: _scripts/command-line/cli-flavor.sh
            :language: shell
            :caption: cli-flavor.sh

        After we have selected our flavor, we will need to supply a pre-built
        operating system known as an *image* to create our instance. In this
        example we are going to be using an ubuntu image:

        .. literalinclude:: _scripts/command-line/cli-image.sh
            :language: shell
            :caption: cli-image.sh

        .. note::

            The amount of images that Catalyst provides can be quite large, if you know what Operating System you want for your
            image you can use the command ``openstack image list -- public | grep <OPERATING SYSTEM>``
            to find it quicker than looking through this list. Another thing to note is that;
            Image IDs will be different in each region. Furthermore, images are periodically updated so
            Image IDs will change over time. Remember always to check what is available
            using ``openstack image list --public``.

        The next variable that we need to have for our instance is an SSH key.
        When an instance is created, OpenStack places an SSH key on the instance which
        we can use for shell access to our instance. By default, Ubuntu will install this key for the
        "ubuntu" user. Other operating systems have a different default user, as listed
        here: :ref:`images`

        .. literalinclude:: _scripts/command-line/cli_upload_key.sh
            :language: shell
            :caption: cli_upload_key.sh

        .. note::

            Keypairs must be created in each region they being used.

        Now that all of those snippets are completed, we can begin to build our
        instance. We can use the following code block to build our instance:

        .. literalinclude:: _scripts/command-line/cli-secgroup-server-floating-ip.sh
            :language: shell
            :caption: cli-secgroup-server-floating-ip.sh

        The final part after you have create your instance is to connect to it
        via ssh:

        Connecting to the Instance should be as easy as:

        .. code-block:: bash

            $ ssh ubuntu@$CC_PUBLIC_IP


        After creating your instance and testing with it through the ssh
        connection you can use the following code to clear your resources:

        .. warning::

            The following commands will delete all the resources you have
            created including networks and routers. Do not run these commands
            unless you wish to delete all these resources.

        .. literalinclude:: _scripts/command-line/resource-cleanup.sh
            :language: shell
            :caption: cli-resource-cleanup.sh

    .. tab:: Heat

        .. literalinclude:: _scripts/heat/heat_env.yaml
            :language: yaml
            :caption: heat_env.yaml

        .. literalinclude:: _scripts/heat/heat_basic_compute.yaml
            :language: yaml
            :caption: heat_basic_compute.yaml


    .. tab:: Terraform

        .. _launching-your-first-instance-using-terraform:

        The following assumes that you have already sourced an openRC file.

        `Terraform`_ is an open source infrastructure configuration and provisioning
        tool developed by `Hashicorp`_. Terraform supports the configuration of many
        kinds of infrastructure, including the Catalyst Cloud. It achieves this by
        using components known as `providers`_. In the case of the Catalyst Cloud, this
        is the `Openstack provider`_.

        .. _Terraform: https://www.terraform.io/
        .. _Hashicorp: https://www.hashicorp.com/
        .. _providers: https://www.terraform.io/docs/providers/index.html
        .. _Openstack provider: https://www.terraform.io/docs/providers/openstack/index.html

        For further information on using Terraform with OpenStack, see the linked
        `video`_ and `blog`_ post:

        * https://www.openstack.org/videos/tokio-2015/tokyo-3141
        * http://blog.scottlowe.org/2015/11/25/intro-to-terraform/

        .. _video: https://www.openstack.org/videos/tokio-2015/tokyo-3141
        .. _blog: http://blog.scottlowe.org/2015/11/25/intro-to-terraform/

        **Installing Terraform**

        Installation of Terraform is very simple. Go to the `Terraform download`_
        page and choose the zip file that matches your operating system and
        architecture. Unzip this file to the location where Terraform's binaries
        will reside on your system. Terraform is written in `Go`_, so it has minimal
        dependencies. Please refer to https://www.terraform.io/intro/getting-started/install.html
        for detailed install instructions.

        .. _Terraform download: https://www.terraform.io/downloads.html
        .. _Go: https://golang.org/


        **Creating your instance**

        The template file below will create an instance, all the dependencies
        that are required for it, and attach a floating IP so that you can ssh
        to your new instance.

        .. literalinclude:: _scripts/terraform/terraform-variables.tf
            :language: shell
            :caption: terraform-variables.tf

        You will need to run the following commands in the same directory as the
        above terraform plan:

        .. literalinclude:: _scripts/terraform/terraform-create.sh
            :language: shell
            :caption: terraform-create.sh

        If you want to delete the instance that you create and ALL the resources
        that were created in the process; You can run the following command:

        .. literalinclude:: _scripts/terraform/terraform-destroy.sh
            :language: shell
            :caption: terraform-destroy.sh
