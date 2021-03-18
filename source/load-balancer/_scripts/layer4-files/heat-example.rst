.. raw:: html

  <h3> Creating a load balancer using Heat </h3>


Heat is the native Openstack orchestration tool and functions by reading a
template file and creating the resources defined within. In the following
example, we are going to use a template to create a loadbalancer which will
look after two webserver instances on ports 80 and 443 (for both webservers).

.. raw:: html

  <h3> Preparation </h3>

If you do not have the underlying resources required to run a set of
webservers i.e. a network and a router; you can find the instructions for
creating them in :ref:`this section<launching-your-first-instance-using-heat>`
of the documents. Given that there is a heat template in that section, you
could even take a snippet of that template and include it in your own here,
allowing you to construct your own template for future use. Additionally, if
you need to create the simulated webservers themselves, there are instructions
in the CLI section of this page on how to set them up correctly.

.. raw:: html

  <h4> Gathering information for your heat template </h4>

Once you have these resources created, we are going to need to gather some
information about them before we can construct our heat template.
We will need to find the following variables for our template:


- The subnet ID of the network your webservers are on. You can find this
  information using the following:

.. code-block::

    $ openstack subnet list
    +--------------------------------------+---------------------+--------------------------------------+-----------------+
    | ID                                   | Name                | Network                              | Subnet          |
    +--------------------------------------+---------------------+--------------------------------------+-----------------+
    | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx | private-subnet      | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx | 192.168.3.0/24  |
    +--------------------------------------+---------------------+--------------------------------------+-----------------+

- You will need the internal IP addresses of your two webservers:

.. code-block::

    $ openstack server list
    +--------------------------------------+-----------------------+--------+----------------------------------------------+--------------------------+---------+
    | ID                                   | Name                  | Status | Networks                                     | Image                    | Flavor  |
    +--------------------------------------+-----------------------+--------+----------------------------------------------+--------------------------+---------+
    | 52d0d0af-8d0b-4bf8-8264-xxxxxxxxxxxx | webserver-heat-test-2 | ACTIVE | lb-docs-tests=192.168.0.43                   | N/A (booted from volume) | c1.c1r1 |
    | bfc4e791-717f-4777-a7f3-xxxxxxxxxxxx | webserver-heat-test   | ACTIVE | lb-docs-tests=192.168.0.42                   | N/A (booted from volume) | c1.c1r1 |
    +--------------------------------------+-----------------------+--------+----------------------------------------------+--------------------------+---------+

    # We are taking the IP addresses: 192.168.0.43 and 192.168.0.42

Now that we have these variables, we can begin constructing out template.

.. raw:: html

  <h3> Building and running a Heat template </h3>

For this example, we are going to provide a template which you can use to
create your load balancer. You will have to change the "parameters" section
of this file to include the variables you collected in the previous step:

.. literalinclude:: /load-balancer/_scripts/layer4-files/heat/load-balancer-layer-4.yaml

Reading through the template you can see which resources are being created and
how they relate to one another. Once you have saved this template and changed
the necessary parameters, we can verify the syntax of our template is correct
by using the following code:

.. code-block:: bash

    $ openstack orchestration template validate -t heat-load-balancer.yaml
    Environment:
      event_sinks: []
      parameter_defaults: {}
      parameters: {}
      resource_registry:
        resources: {}
    Description: 'The heat template is used to create a load balancer for a basic webserver'

    Parameters:
      pool_member_1:
        Default: 192.168.0.43
        Description: the first webserver that you want the loadbalancer to balance
        Label: pool_member_1
        NoEcho: 'false'
        Type: String
      pool_member_2:
        Default: 192.168.0.42
        Description: the second webserver that you want to be loadbalanced
        Label: pool_member_2
        NoEcho: 'false'
        Type: String
      public_network:
        Default: public-net
        Description: Public network name, could get by 'openstack network list --external'
        Label: public_network
        NoEcho: 'false'
        Type: String
      vip_subnet_id:
        Default: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        Description: Should be a subnet of webserver_network_id
        Label: vip_subnet_id
        NoEcho: 'false'
        Type: String

Once you have confirmed that your template is formatted correctly and that it
is going to create the correct resources, we can run the following command to
create our stack:

.. code-block::

    $ openstack stack create -t heat-load-balancer.yaml heat-lb-stack
    +---------------------+---------------------------------------------------------------------------+
    | Field               | Value                                                                     |
    +---------------------+---------------------------------------------------------------------------+
    | id                  | bedbf02b-0094-44c8-a423-xxxxxxxxxxxx                                      |
    | stack_name          | heat-lb-stack                                                             |
    | description         | The heat template is used to create a load balancer for a basic webserver |
    |                     |                                                                           |
    | creation_time       | 2021-01-28T21:36:20Z                                                      |
    | updated_time        | None                                                                      |
    | stack_status        | CREATE_IN_PROGRESS                                                        |
    | stack_status_reason | Stack CREATE started                                                      |
    +---------------------+---------------------------------------------------------------------------+

Now we should have our stack created and our loadbalancer running on our
webserver instances.

.. raw:: html

  <h3> Deleting your resources </h3>

If you have created resources using Heat then it is also a good idea to
remove them using Heat as well. This is so that your stack is not left with
missing resources or in a faulty state.

To remove all the resources created with our template; you can run the
following command:

.. code-block::

    $ openstack stack delete <name of your stack>>
    Are you sure you want to delete this stack(s) [y/N]? y
