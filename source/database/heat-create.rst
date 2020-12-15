.. raw:: html

  <h3> Creating a database using a heat template </h3>


Heat is the native Openstack orchestration tool and functions by reading a
template file and creating the resources defined within.  By having
your resources managed in this way, you can treat your infrastructure as code
and deploy any changes you wish to make to your system through heat.

In the following example, we are going to use a template to create
a database instance on our project. The
template we will use only covers the creation of the database resources
themselves. If you do not have the underlying resources required to run an
instance (a network and a router) you can find the instructions for creating
them in
:ref:`this section<launching-your-first-instance-using-heat>`.

Using heat you can manage all of your resources together using one template.
If you wanted to, you could adapt the
following script to include both a router and network resource as well as a
database instance.

Whether you want to add your networking resources to
the following template or not, you will still need to make changes to the
template so that you create your resources on the correct region, and with the
correct specifications for your project. The parts you will need to change in
the template are identified using: *<angled brackets>*.

Save the following file and change the parameters as necessary

.. literalinclude:: _scripts/heat/heat-stack-create-database.yaml
   :language: yaml

Once you have this file saved and have changed the parameters to match your
project, you can begin creating your stack.

First you should validate your template to confirm that it has been written
correctly and that it is going to create the right resources.

.. code-block:: bash

    # Navigate to the directory that contains your yaml file and run the following:

    $ openstack orchestration template validate -t database-template-file.yaml

If the output from this command is a copy of your template this means that it
is valid. If you receive an error, then you will need to fix the error before
you can continue.

Once you have a valid template, you can run the following code to create a new
stack named ``new-database-stack``:

.. code-block:: bash

    $ openstack stack create -t database-template-file.yaml new-database-stack

Use the
``event list`` command to check on the stack's orchestration progress.
The ``stack_status`` should indicate that creation is in progress:

.. code-block:: bash

    $  openstack stack event list new-database-stack
    # Output truncated for brevity:
    2020-12-08 21:59:51Z [new-database-stack]: CREATE_IN_PROGRESS  Stack CREATE started
    ...
    2020-12-08 22:00:30Z [new-database-stack]: CREATE_COMPLETE  state changed


.. raw:: html

  <h3> Adding or removing databases from your DB instance </h3>

To make changes to the database that you create using the heat template, you
will need to edit the template file to include your new database or remove
your old one.

The relevant section for this in the template is:

.. code-block:: yaml

  resources:
      database:
      type: OS::Trove::Instance
      properties:
          databases: [{name: DB-1}] # This property defines your individual databases.

After you have either added or deleted the databases that you want, you will
need to run the following code to update your stack:

.. code-block:: bash

  $ openstack stack update -t database-updated-template.yaml new-database-stack

.. raw:: html

  <h3> Deleting your stack </h3>

If a stack has been orchestrated using Heat, it is generally a good idea to
also use Heat to delete that stack's resources. Deleting components of a Heat
orchestrated stack manually, whether using the other command line tools or the
web interface, can result in resources or stacks being left in an inconsistent
state.

To delete the ``new-database-stack`` you can use the following code:

.. code-block:: bash

    $ openstack stack delete new-database-stack
    Are you sure you want to delete this stack(s) [y/N]? y
