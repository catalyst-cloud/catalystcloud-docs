.. raw:: html

  <h3> Creating a load balancer using an Ansible playbook </h3>

The following example assumes that you already have some understanding of how
Ansible playbooks work and how to construct your own. If you have not used
Ansible before or are not sure about how to use it on Catalyst Cloud, a
good starting point is our example under the
:ref:`first instance<launching-your-first-instance-using-terraform>`
section of the documents. You can also find more information about Ansible in
general on the `Ansible`_ homepage.

.. _Ansible: https://docs.ansible.com/

.. raw:: html

  <h3> Preparation </h3>

Unlike the other examples, our ansible playbook will create its own
webserver alongside the load balancer. Therefore we have to gather additional
information about our resources before we can start using our playbook.

We will need to prepare a number of variables for our playbook:

- A name for your webserver
- A name for your load balancer
- An image to use for your webserver:

.. code-block:: bash

    $ openstack image list
    +--------------------------------------+-----------------------------------------------------------------+--------+
    | ID                                   | Name                                                            | Status |
    +--------------------------------------+-----------------------------------------------------------------+--------+
    | 683f76b0-eec2-43c3-9143-xxxxxxxxxxxx | atomic-7-x86_64                                                 | active |
    | 7f352450-e87f-42b9-8238-xxxxxxxxxxxx | atomic-7-x86_64-20170502                                        | active |
    | bc84a4a4-d73c-44c8-a65e-xxxxxxxxxxxx | atomic-7-x86_64-20170608                                        | active |
    | 0be2db8d-017b-464f-8a46-xxxxxxxxxxxx | atomic-7-x86_64-20170714                                        | active |
    | eedefeab-34d3-4f73-8421-xxxxxxxxxxxx | atomic-7-x86_64-20181018                                        | active |
    | ... Truncated for brevity            |                                                                 |        |
    +--------------------------------------+-----------------------------------------------------------------+--------+

- A flavor to use for your webserver:

.. code-block:: bash

    $ openstack flavor list
    +--------------------------------------+------------+--------+------+-----------+-------+-----------+
    | ID                                   | Name       |    RAM | Disk | Ephemeral | VCPUs | Is Public |
    +--------------------------------------+------------+--------+------+-----------+-------+-----------+
    | 00e563b6-11e2-4468-ac55-xxxxxxxxxxxx | c1.c16r24  |  24576 |   10 |         0 |    16 | True      |
    | 01ecf2cc-2047-4606-a53b-xxxxxxxxxxxx | c1.c8r6    |   6144 |   10 |         0 |     8 | True      |
    | 02cb8214-2121-4d0d-b7fd-xxxxxxxxxxxx | c1.c4r24   |  24576 |   10 |         0 |     4 | True      |
    | 07585040-f887-4ddb-a0d5-xxxxxxxxxxxx | c1.c8r16   |  16384 |   10 |         0 |     8 | True      |
    | 1c558eba-0d8a-4d09-86dd-xxxxxxxxxxxx | c1.c32r24  |  24576 |   10 |         0 |    32 | True      |
    | ... Truncated for Brevity            |            |        |      |           |       |           |
    +--------------------------------------+------------+--------+------+-----------+-------+-----------+

- The name of an existing network &
- The name of the public net to connect to:

.. code-block::

    $ openstack network list
    +--------------------------------------+--------------------------+--------------------------------------+
    | ID                                   | Name                     | Subnets                              |
    +--------------------------------------+--------------------------+--------------------------------------+
    | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | public-net               | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |
    | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | existing-private-net     | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |
    +--------------------------------------+--------------------------+--------------------------------------+

- The name of an existing keypair:

.. code-block::

    $ openstack keypair list
    +-----------------+-------------------------------------------------+
    | Name            | Fingerprint                                     |
    +-----------------+-------------------------------------------------+
    | your-keypair    | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |
    +-----------------+-------------------------------------------------+


- A list of any security groups you want to attach to your load balancer

.. code-block::

    $ openstack security group list
    +--------------------------------------+-------------------+--------------------------------------------+---------+------+
    | ID                                   | Name              | Description                                | Project | Tags |
    +--------------------------------------+-------------------+--------------------------------------------+---------+------+
    | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx | sec-group         | security group to allow traffic on port 80 | None    | []   |
    +--------------------------------------+-------------------+--------------------------------------------+---------+------+


- The name of your subnet

.. code-block::

    $ openstack subnet list
    +--------------------------------------+---------------------+--------------------------------------+-----------------+
    | ID                                   | Name                | Network                              | Subnet          |
    +--------------------------------------+---------------------+--------------------------------------+-----------------+
    | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx | private-subnet      | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx | 192.168.3.0/24  |
    +--------------------------------------+---------------------+--------------------------------------+-----------------+

Once you have all of these resources you can move on to constructing your
playbook.

.. raw:: html

  <h3> Creating your Ansible playbook </h3>

For this example we will provide a template for your playbook. You will need to
add the variables you collected in the previous step to the ``vars`` section
of the template, but once this is done you should have a fully functioning
Ansible playbook you can use to create a simulated webserver and a loadbalancer
which looks after it:

.. literalinclude:: /load-balancer/_scripts/layer4-files/ansible/loadbalancer_playbook.yaml

Once you have changed the variables in your template we can move on to
building the resources on your project.

.. raw:: html

  <h3> Running your Ansible playbook </h3>

Firstly, we need to know exactly what tasks our playbook is going to take. We
can use the following command to display each of our playbook's tasks:

.. code-block:: bash

    $ ansible-playbook --list-tasks create_loadbalancer_playbook.yaml
    [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

    playbook: create_loadbalancer_playbook.yaml

    play #1 (localhost): Create loadbalancer and add a simple webserver	TAGS: []
      tasks:
        Create a simple webserver	TAGS: []
        Gather facts about webserver	TAGS: []
        Create the openstack loadbalancer	TAGS: []
        Create a health monitor for our load balancer	TAGS: []


Now that we know what tasks our playbook is going to perform, we can run our
playbook and create our webserver and load balancer.

To run our playbook we use the following:

.. code-block::

    $ ansible-playbook create_loadbalancer_playbook.yaml
    [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

    PLAY [Create loadbalancer and add a simple webserver] ***************************************************************************************************************

    TASK [Gathering Facts] **********************************************************************************************************************************************
    ok: [localhost]

    TASK [Create a simple webserver] ************************************************************************************************************************************
    ok: [localhost]

    TASK [Gather facts about webserver] *********************************************************************************************************************************
    ok: [localhost]

    TASK [Create the OpenStack loadbalancer] ****************************************************************************************************************************
    ok: [localhost]

    TASK [Create a health monitor for our load balancer] ****************************************************************************************************************
    ok: [localhost]

    PLAY RECAP **********************************************************************************************************************************************************
    localhost                  : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

Once your playbook has completed, you should be able to see your loadbalancer
on your project:

.. code-block::

    $ openstack loadbalancer list
    +--------------------------------------+------------+----------------------------------+--------------+---------------------+------------------+----------+
    | id                                   | name       | project_id                       | vip_address  | provisioning_status | operating_status | provider |
    +--------------------------------------+------------+----------------------------------+--------------+---------------------+------------------+----------+
    | a797a67d-bab5-4ae5-af30-xxxxxxxxxxxx | ansible-lb | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | 192.168.0.39 | ACTIVE              | ONLINE           | amphora  |
    +--------------------------------------+------------+----------------------------------+--------------+---------------------+------------------+----------+

.. raw:: html

  <h3> Deleting your resources </h3>

To delete your resources you will need to construct another Ansible playbook.
With the variable names that you used in the previous playbook, you will need
to fill out the following template.This playbook will delete the webserver,
loadbalancer, and healthmonitor created in the previous playbook:

.. literalinclude:: /load-balancer/_scripts/layer4-files/ansible/remove_loadbalancer_playbook.yaml

Once you have set your variables you simply run the playbook like we did
previously:

.. code-block::

    $ ansible-playbook remove_loadbalancer_playbook.yaml
    [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

    PLAY [Clean up the resources from the previous playbook] ************************************************************************************************************

    TASK [Gathering Facts] **********************************************************************************************************************************************
    ok: [localhost]

    TASK [Gather facts about webserver] *********************************************************************************************************************************
    ok: [localhost]

    TASK [Remove the openstack loadbalancer] ****************************************************************************************************************************
    changed: [localhost]

    PLAY RECAP **********************************************************************************************************************************************************
    localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

