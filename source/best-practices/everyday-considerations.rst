
#######################
Everyday considerations
#######################

**********************
Getting the correct ID
**********************

For user created objects within the cloud it is always advisable to lookup ID
values before using them in any type of command to ensure that the correct
element has been identified. While it is very rare, it should be noted that it
is possible for underlying system generated cloud objects, such as flavor and
image IDs to also change.

With this in mind, if you are running commands from the CLI tools or one of the
support SDKs, it is recommended to lookup the ID before using it to ensure that
the correct object is referenced.

The following example shows how this could be done using the OpenStack CLI
tool. It can query both images and flavors by name to retrieve their ID
and then it stores the resulting ID into an environment variable so that
it can be reused in subsequent commands.

.. code-block:: bash

    export CC_IMAGE_ID=$( openstack image show ubuntu-18.04-x86_64 -f value -c id )
    export CC_FLAVOR_ID=$( openstack flavor show c1.c1r2 -f value -c id )

Similar mechanisms exist for doing this with other tool sets such as Ansible,
Terraform and the various supported development SDKs.

************************************
Create an incident response playbook
************************************

An incident response playbook is a tool that companies use to deal with
issues in a routine and standardised way. There are a variety of different
playbooks you can create; Typical examples would be a guide or process of what
to avoid doing if you are using root access to keep your system safe.
The objective of having these playbooks is to provide your staff with a routine
way of dealing with tasks and a clear path on what to do in the event of
something going wrong.

For incidents that occur with your projects on the Catalyst Cloud. We
recommended this documentation be one of the first places you check to solving
your issues. The documentation is comprehensive and deals with most of the
frequently encountered problems. Should you be unable to find your solution
here, the next step involving catalyst would be to raise a ticket via our
`support service`_

.. _`support service`: https://catalystcloud.nz/support/support-centre/

************
Back up data
************

This is a standard practice for any business. Making sure that if some form
of catastrophe were to befall you system, that you have backups to recover
to a working state. When it comes to the Catalyst Cloud, there are several
unique things that ensure data backup.

Our Object and Block storage services create copies of the data stored on them
and distribute these copies to the different regions available.
If any physical damage or soft corruption (bit rot) were to occur, the data
would be restored through the self-healing and self-managing storage
systems that we have.

However, you may still want to create explicit backups for your data. More
information on backups can be found under the :ref:`backups section <backups>`
of the documentation or under the section on the specific service you seek to
backup.
