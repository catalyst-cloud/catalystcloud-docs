####################################################
Replacing ephemeral storage with a persistent volume
####################################################

When creating an instance you have the option to attach a persistent volume
to it or use an ephemeral volume. If you chose an ephemeral volume, whenever
you shelve your instance the system creates a snapshot; to keep your data from
being flushed and deleted. But each time you shelve your instance you create a
new snapshot that contains the incremental changes from the previous snapshot.

Over time these start to stack up if you consistently shelve your instance.
This in turn slows the process of booting the instance from its shelved state.
You could add a persistent volume to the instance, but this means you now have
both ephemeral and persistent storage. So even if you start saving things to
your volume, the instance will still make snapshots of the ephemeral side.

The easiest solution to this is creating a new instance that does not contain
an ephemeral volume using a snapshot from the old instance. We detail how to
complete this action, using both the dashboard and the command line, below:

*****************
Via the Dashboard
*****************

The first thing that you will need is the snapshot of your instance. This is
automatically created for you when you shelve your instance:

.. image:: block-storage-assets/Snapshot-ephemeral.png

After this, navigate to the **Images** section of the dashboard and locate your
snapshot. For this example our snapshot is named 'Ephemeral-snapshot'.
Click create volume and follow the steps to creating a volume from this
snapshot.

.. image:: block-storage-assets/images-create-volume-red.png

Next, navigate to the volume section of the dashboard and click
*launch as instance* from your selected volume. In our case:
"Ephemeral-Snapshot"

.. image:: block-storage-assets/volume-create-as-instance-red.png

Then create a new instance making sure that when you arrive at picking a
source, you use the volume as your source type and not an image. Our
volume should already be selected by default, but double check that this is
true. Make sure the the other options for your instance match your previous
one and hit create instance.

.. image:: block-storage-assets/create-with-vol.png

Once your new instance is up and running you should be able to see all of your
old files and you will be able to shelve your instance without creating
incremental snapshots.

***********
Via the CLI
***********

The following is assumed:

* You have installed the openstack command line tools
* You have sourced an :ref:`OpenRC file<source-rc-file>`


The first thing you need to do is shelve your instance; which will create a
current snapshot.

.. code-block:: bash

   # Find the ID of the instance you want to create a snapshot of
   $ openstack server list
   +--------------------------------------+--------------------+-------------------+------------------------------------------+------------------------------+---------+
   | ID                                   | Name               | Status            | Networks                                 | Image                        | Flavor  |
   +--------------------------------------+--------------------+-------------------+------------------------------------------+------------------------------+---------+
   | 9896d5e5-116f-4aa2-b962-xxxxxxxxxxxx | ephemeral-instance | ACTIVE            | private-net-1=10.0.0.17, 103.254.156.188 | ubuntu-18.04-x86_64          | c1.c1r1 |
   +--------------------------------------+--------------------+-------------------+------------------------------------------+------------------------------+---------+

   # Then use the shelve command with the instance ID
   $ openstack server shelve 9896d5e5-116f-4aa2-b962-xxxxxxxxxxxx


After this, we will create a volume from our snapshot.

.. code-block:: bash

   # Find the correct snapshot (replace 'ephemeral' with your instance name)
   $ openstack image list | grep ephemeral
   +--------------------------------------+--------------------------------------+--------+
   | ID                                   | Name                                 | Status |
   +--------------------------------------+--------------------------------------+--------+
   | aa1e6f8d-0689-4eaf-9a13-xxxxxxxxxxxx | ephemeral-instance-shelved           | active |
   +--------------------------------------+--------------------------------------+--------+


   # then we execute the following command, changing the --image to be the ID of your snapshot.
   $ openstack volume create persistent-volume-bootable --size 20 --image aa1e6f8d-0689-4eaf-9a13-xxxxxxxxxxxx \
   --description volume-from-ephemeral-shelved --bootable --os-project-id eac679e489614xxxxxxce29d755fe289 \
   --availability-zone NZ-WLG-2 --type b1.standard


At this point, we now have a volume that contains all of the information from
our previous instance. From here we need to create our new instance. To do so,
we use the create server command, adding the --volume flag:

.. code-block:: bash

   # get the ID of your old instance
   $ openstack server list
   +--------------------------------------+--------------------+-------------------+------------------------------------------+------------------------------+---------+
   | ID                                   | Name               | Status            | Networks                                 | Image                        | Flavor  |
   +--------------------------------------+--------------------+-------------------+------------------------------------------+------------------------------+---------+
   | 9896d5e5-116f-4aa2-b962-xxxxxxxxxxxx | ephemeral-instance | SHELVED_OFFLOADED | private-net-1=10.0.0.17, 103.254.156.188 | ubuntu-18.04-x86_64          | c1.c1r1 |
   +--------------------------------------+--------------------+-------------------+------------------------------------------+------------------------------+---------+

   # then we get the flavor and image ID's along with the security and network information from the previous instance
   $ openstack server show 9896d5e5-116f-4aa2-b962-xxxxxxxxxxxx
   +-----------------------------+------------------------------------------------------------+
   | Field                       | Value                                                      |
   +-----------------------------+------------------------------------------------------------+
   | OS-DCF:diskConfig           | AUTO                                                       |
   | OS-EXT-AZ:availability_zone | NZ-WLG-2                                                   |
   | OS-EXT-STS:power_state      | Shutdown                                                   |
   | OS-EXT-STS:task_state       | None                                                       |
   | OS-EXT-STS:vm_state         | shelved_offloaded                                          |
   | OS-SRV-USG:launched_at      | 2019-09-18T22:58:52.000000                                 |
   | OS-SRV-USG:terminated_at    | None                                                       |
   | accessIPv4                  |                                                            |
   | accessIPv6                  |                                                            |
   | addresses                   | private-net-1=10.0.0.17, 103.254.156.188                   |
   | config_drive                |                                                            |
   | created                     | 2019-09-16T00:21:39Z                                       |
   | flavor                      | c1.c1r1 (6371ec4a-47d1-4159-a42f-xxxxxxxxxxxx)             |
   | hostId                      |                                                            |
   | id                          | 9896d5e5-116f-4aa2-b962-xxxxxxxxxxxx                       |
   | image                       | ubuntu-18.04-x86_64 (102172df-9872-47df-b66b-xxxxxxxxxxxx) |
   | key_name                    | security-key                                               |
   | name                        | ephemeral-instance                                         |
   | project_id                  | eac679e489614xxxxxxce29d755fe289                           |
   | properties                  |                                                            |
   | security_groups             | name='default'                                             |
   |                             | name='security-group'                                      |
   | status                      | SHELVED_OFFLOADED                                          |
   | updated                     | 2019-09-18T23:11:59Z                                       |
   | user_id                     | 53b94a52e9dcxxxxxxx0079a9a3d6434                           |
   | volumes_attached            | id='09975851-7bb4-4935-814b-xxxxxxxxxxxx'                  |
   +-----------------------------+------------------------------------------------------------+

   # you will also need to get your private-net id using the following command:
   $ openstack network show private-net -f value -c id

   # we then create our new instance with these parameters.
   $ openstack server create --flavor 6371ec4a-47d1-4159-a42f-xxxxxxxxxxxx \
   --volume 666707a2-0835-449a-a093-xxxxxxxxxxxx --nic net-id=550677db-0232-418b-aeb5-xxxxxxxxxxxx \
   --security-group default --security-group security-group persistent-volume-instance

After this is completed, you should be able to assign a floating IP to your
instance and SSH to it. We should find all of our data intact, the only
difference now being that our instance uses a persistent volume for storage
instead of ephemeral.

.. code-block:: bash

   $ openstack floating ip list
   +--------------------------------------+---------------------+------------------+------+--------------------------------------+----------------------------------+
   | ID                                   | Floating IP Address | Fixed IP Address | Port | Floating Network                     | Project                          |
   +--------------------------------------+---------------------+------------------+------+--------------------------------------+----------------------------------+
   | 50e0c050-db2a-47bf-a478-xxxxxxxxxxxx | 103.254.156.188     | None             | None | e0ba6b88-5360-492c-9c3d-xxxxxxxxxxxx | eac679e489614xxxxxxce29d755fe289 |
   +--------------------------------------+---------------------+------------------+------+--------------------------------------+----------------------------------+

   $ openstack server add floating ip persistent-volume-instance 103.254.156.188

   # then you can SSH to your instance
   $ ssh ubuntu@103.254.156.188
