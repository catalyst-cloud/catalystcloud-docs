#################
Cloning Instances
#################

There are often occasions when you may need more than one of a particular
instance, and want the installation and configuration of operating systems and
software to be carried forward into additional instances. This can be achieved
by using what are called **golden images**. They allow you to set a default
state that your instances will then be created with, meaning that you can
guarantee uniform configuration between multiple instances when they are first
spun up.

.. note::

    The method below assume that your operating system and other
    software installed on your instance reside entirely on the first volume
    attached to the instance, also known as the boot volume. There
    is no support for copying and starting instances with multiple
    attached volumes.

The steps required to create a *golden image* are:

#. Prepare the source instance to be copied. The steps needed here depend
   on the OS and software installed.
#. Shut down the instance.
#. Create a new volume using the existing boot volume as a source.
#. Create an image from the new volume.
#. Delete the duplicated volume created above.
#. Use the *golden image* you created in the previous step to then create your
   new instances.

Some steps can be performed using the dashboard, though some require the use
of the command line. As such, we have only documented an example using the
command-line tools:

*****************************
Preparing the source instance
*****************************

In general, we want any new instances that we create using a golden image to
perform certain steps like it is a new instance despite the source we are using
having already been launched and configured

For Linux operating systems, the tools in the OS images provided by
Catalyst Cloud will detect that our new instance has been launched as a
new copy, and reset the hostname and other details according to what the cloud
has configured for these attributes.

For other software installed in the instance, you will need  to add scripts to
the system to reset the state when tooling detects a new instance has been
created.

The `cloud-init` tool in most Linux images provides detection of a
new instance and performs the reset of hostname and other details as
described above. However, it can also be used to run scripts within
the image without needing to have these passed into the instance.

Consult `cloud-init's documentation`_ for more information on how
to hook these scripts into the process.

.. _`cloud-init's documentation`: https://cloudinit.readthedocs.io/en/latest/index.html

************************
Create a new volume copy
************************

.. note::

  Before running the CLI commands documented below, make sure
  you have the ``openstack`` command available in your environment,
  and sourced the OpenRC file for your project.

  For more information, please refer to the :ref:`cli` documentation.

First, you need to identify the volume ID that you need to copy. This is done
by retrieving the volumes attached to the instance you are cloning, then
creating a copy of the first volume. For example:

.. literalinclude:: _scripts/cli/cli_copy-vol.sh
    :language: shell

In the example above, the volume attached to the instance has the ID
`0a8f8181-5c92-4367-ae26-XXXXXXXXXXXX`, and so we created a new volume
using that ID as our source.

*****************************
Create image from volume copy
*****************************

Next we create a new image from the volume copy. By default the image
will not be shared anywhere except your own project, although it will
be marked as ``shared``.

.. literalinclude:: _scripts/cli/cli_make-image.sh
    :language: shell

.. note::

    The name of the image should be something easily identified for
    what it contains. However it does not have to be unique. This can
    be used combined with some tools to enable selecting a "latest"
    image version by using the same name.

After this is complete, the image should be available which you can verify
using the command below:

.. literalinclude:: _scripts/cli/cli_check-image.sh
    :language: shell

**********************
Delete the volume copy
**********************

Before you start launching instances, it is recommended that you clean up the
volume that was created earlier, so that it does not get used for any other
purposes. This is important as the copied volume has a dependency on the
original volume it was sourced from. You cannot delete the original volume
until all dependant copies are also deleted. It can be hard to identify where
volumes have dependencies on each other and so it is recommended to clean up
your volume immediately as you only need the image that was created
going forward.

.. literalinclude:: _scripts/cli/cli_delete-vol.sh
    :language: shell

*******************************
Create new instance using image
*******************************

You can now create a new instance using the image you have created.
The image will appear in the dashboard when creating an instance,
or you can use the command-line for any image option with
the ``openstack server create`` command.
