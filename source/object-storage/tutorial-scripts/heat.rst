Using Heat you are able to manage a large number of resources by utilising a
stack that will construct and monitor your objects. You can create a stack by using a pre-designed template.
The following example assumes that you have some knowledge of Heat and how to use these
template files.

The following code snippet contains the minimum required components to construct
an object storage container using Heat:

.. code-block:: bash

    heat_template_version: 2015-04-30

    description: >
        Creating a swift container using HEAT

    resources:

      swift_container:
        type: OS::Swift::Container
        properties:
          PurgeOnDelete: FALSE
          name: heat-container

For more information on object storage containers and what
customization options you can select for them, please see the
`Openstack Heat`_  documentation.

.. _Openstack Heat: https://docs.openstack.org/heat/latest/template_guide/openstack.html#OS::Swift::Container

Once you have your template constructed, you should make sure to validate
it before creating any resources. You can do this by running the following code:

.. code-block:: bash

    $ openstack orchestration template validate -t <your-template-name>

If your template is constructed correctly then the output of this code
should print out a copy of your template. If there is an error inside your template
then you will be notified of the error in the output.

Once you have ensured your template is valid, you can construct your
stack:

.. code-block:: bash

    $ openstack stack create -t <template> <stack-name>

The ``stack_status`` indicates that creation is in progress. Use the
``event list`` command to check on the stack's orchestration progress:

.. code-block:: bash

    $ openstack stack event list <stack-name>
    2020-11-09 22:53:56Z [container-stack]: CREATE_IN_PROGRESS  Stack CREATE started
    2020-11-09 22:53:57Z [container-stack.swift_container]: CREATE_IN_PROGRESS  state changed
    2020-11-09 22:54:01Z [container-stack.swift_container]: CREATE_COMPLETE  state changed
    2020-11-09 22:54:01Z [container-stack]: CREATE_COMPLETE  Stack CREATE completed successfully


Once your status has reached CREATE_COMPLETE you should be able to see
the resources on your project.
