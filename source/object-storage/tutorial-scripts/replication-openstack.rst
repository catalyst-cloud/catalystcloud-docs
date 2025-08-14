
The following is a tutorial that will show you how to create a container that
has a single region replication policy, using the OpenStack command line tools.
There are a number of prerequisites you will need to meet before we can
continue with this tutorial:

- You must have version 5.2.0 or above of the OpenStack command line tools installed.
- You need to have sourced an OpenRC file in your console.

Once you have met these requirements we can create our container. For this
container we are going to be using the Hamilton region. This means that when
we use the command ``openstack container create`` we need to specify our
policy with the ``--storage-policy`` flag.

.. Note::
    Even if a container only uses a single region for it's replication policy,
    you are still able to access the container from any region on Catalyst
    Cloud.

.. code-block:: bash

    $ openstack container create --storage-policy nz-hlz-1--o1--sr-r3 single-region-cli
    +---------------------------------------+-------------------+------------------------------------+
    | account                               | container         | x-trans-id                         |
    +---------------------------------------+-------------------+------------------------------------+
    | AUTH_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx | single-region-cli | tx4e6c8d8ec77248279a74a-005e94d751 |
    +---------------------------------------+-------------------+------------------------------------+

That is it. We have created a container with the single region policy. We can
see this if we use the following command:

.. code-block:: bash

    $ openstack container show single-region-cli
    +----------------+---------------------------------------+
    | Field          | Value                                 |
    +----------------+---------------------------------------+
    | account        | AUTH_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |
    | bytes_used     | 0                                     |
    | container      | single-region-cli                     |
    | object_count   | 0                                     |
    | storage_policy | nz-hlz-1--o1--sr-r3                   |
    +----------------+---------------------------------------+
