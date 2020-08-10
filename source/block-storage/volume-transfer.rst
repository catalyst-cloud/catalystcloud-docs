########################################
Transferring a volume to another project
########################################

In this example, we will cover how to transfer volumes between different
projects on the Catalyst Cloud.

Before we begin, there are some things that you have to check:

- Does the project your moving the volume to, have a large enough quota to
  support the new volume?
- Does the volume have any dependencies? (attachments, snapshots, images etc.)

***************************************
Transferring a volume via the dashboard
***************************************

First we have to select the volume we are wanting to transfer to our other
project:

.. image:: _assets/transfer-volume.png

Once we have our volume we click on the dropdown menu to the right and we
select the "create transfer" option from our list.

.. image:: _assets/transfer-dropdown.png

Our transfer needs a name and once this is done and you click
**Create volume transfer** a transfer ID and key will be issued to you. You
will need these to accept the transfer from your other project:

.. image:: _assets/create-transfer-name.png

Once you have these details saved to accept the transfer, you can swap to your
other project and click on the *accept transfer* button:

.. image:: _assets/accept-transfer.png

Then we input our details from previously and our transfer will be complete.

.. image:: _assets/input-id-and-key.png

***************************************
Transferring a volume via the CLI
***************************************

When using the CLI you will have to source two different shell environments
that have been set up using the openRC files from your different projects.

For the rest of this example we will refer to the shell that is sourced from
the project that originally had the volume as ``console one`` and the shell
that is sourced from our project that we are trying to move the volume too as
``console two``.

.. Note::

  You must have both of your projects sourced in the same region to be able to
  transfer a volume between them.

In console one, we have to find the volume that we want to transfer:

.. code-block:: bash

   $ openstack volume list
   +--------------------------------------+----------------------------+-----------+------+-------------------------------------------+
   | ID                                   | Name                       | Status    | Size | Attached to                               |
   +--------------------------------------+----------------------------+-----------+------+-------------------------------------------+
   | e58527cf-34d2-42bc-85fd-e689cc088dbd | transfer-example           | available |   10 |                                           |
   +--------------------------------------+----------------------------+-----------+------+-------------------------------------------+

Once we have the volume that we want to transfer, in console one, we create the
following transfer request:

.. code-block:: bash

   $ openstack volume transfer request create --name transfer_name <volume_ID>
   +------------+--------------------------------------+
   | Field      | Value                                |
   +------------+--------------------------------------+
   | auth_key   | XXXXXXXXXXXXXXXX                     |
   | created_at | 2020-08-10T01:28:29.581644           |
   | id         | 0ead79fc-62f2-482d-bb3e-75101843555b |
   | name       | transfer_name                        |
   | volume_id  | e58527cf-34d2-42bc-85fd-e689cc088dbd |
   +------------+--------------------------------------+

Now we have our transfer ID and our auth_key for our transfer. We swap over
to console two and we use the following to accept the transfer request.

.. code-block:: bash

   $ openstack volume transfer request accept --auth-key XXXXXXXXXXXXXXXX 0ead79fc-62f2-482d-bb3e-75101843555b
   +-----------+--------------------------------------+
   | Field     | Value                                |
   +-----------+--------------------------------------+
   | id        | 0ead79fc-62f2-482d-bb3e-75101843555b |
   | name      | transfer_name                        |
   | volume_id | e58527cf-34d2-42bc-85fd-e689cc088dbd |
   +-----------+--------------------------------------+

If we then check on console two, for the volumes we have available, we can
see that our volume has now been transferred to our second project:

.. code-block:: bash

   $ openstack volume list
   +--------------------------------------+----------------------------+-----------+------+-------------------------------------------+
   | ID                                   | Name                       | Status    | Size | Attached to                               |
   +--------------------------------------+----------------------------+-----------+------+-------------------------------------------+
   | e58527cf-34d2-42bc-85fd-e689cc088dbd | transfer-example           | available |   10 |                                           |
   +--------------------------------------+----------------------------+-----------+------+-------------------------------------------+
