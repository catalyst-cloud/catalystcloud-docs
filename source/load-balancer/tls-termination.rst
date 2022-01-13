###############
TLS Termination
###############

In this section, we cover how to use openstack tools to create a loadbalancer
that will handle TLS termination for your instances.

***************
Prerequisites
***************

Configuring your command line
=============================

To interact with the loadbalancer service on the cloud, you must have the
following prepared:

- Your :ref:`openstack CLI<command-line-interface>` installed and set up.
- You must have :ref:`Sourced an openRC file<configuring-the-cli>` on your
  current command line environment
- For this tutorial, you must also have the following installed in your environment:

  - the `python barbican-client tools
    <https://pypi.org/project/python-barbicanclient/>`_.

  - the `openssl client <https://help.ubuntu.com/community/OpenSSL>`_.

Gathering the necessary inputs
===============================

As this tutorial is focused on how to set up a TLS terminated loadbalancer, you
will need to have the following resources already available to proceed with the
rest of the tutorial.

- A webserver on the cloud that is currently running your desired application.
- The valid certificates and keys that relate to your webserver application/website.
- You will also need the UUID of a subnet that you want your loadbalancer to be hosted on.

You can acquire that UUID by running the command and creating a environment
variable for the ID:

.. code-block:: bash

  $ openstack subnet list

  +--------------------------------------+---------------------+--------------------------------------+-----------------+
  | ID                                   | Name                | Network                              | Subnet          |
  +--------------------------------------+---------------------+--------------------------------------+-----------------+
  | aaaXXXXXX-XXXX-XXXXXXXX-XXXXX-jmu2r3 | lb-docs-test-subnet | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | 192.168.0.0/24  |
  +--------------------------------------+---------------------+--------------------------------------+-----------------+

  $ subnet_id=aaaXXXXXX-XXXX-XXXXXXXX-XXXXX-jmu2r3
  $ echo $subnet_id

***************************************
Creating a TLS terminated Load Balancer
***************************************

Once you have set up your command line correctly and ensured that you have all
of  the prerequisite resources ready, we can begin creating our new load
balancer.

Creating a secret using the Barbican service
===================================================

First, we need to create a secret containing our certificates and keys,
which we can safely store on the cloud using the Barbican service. To start,
we need to create a package that contains all of our required inputs.

Navigate to the folder containing your certificate,
keyfile and any certificate chains required. Once there, you can use the
following command to create a pkcs12 package:

.. code-block:: bash

  $ openssl pkcs12 -export -inkey server.key -in server.crt -certfile ca-chain.crt -passout pass: -out <package_name>.p12

Once we have this our pkcs12 file, we can create a secret, which we will store
on the cloud. To do so, you need to construct a command like the following:

.. code-block:: bash

  # make sure to substitute your package name in where it says "package_name.p12"
  $ openstack secret store --name="tls-secret" -t "application/octet-stream"
  -e "base64" --payload="$(base64 < package_name.p12)"

  +---------------+--------------------------------------------------------------------------------------------+
  | Field         | Value                                                                                      |
  +---------------+--------------------------------------------------------------------------------------------+
  | Secret href   | https://api.nz-por-1.catalystcloud.io:9311/v1/secrets/beXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |
  | Name          | tls-secret                                                                                 |
  | Created       | None                                                                                       |
  | Status        | None                                                                                       |
  | Content types | {'default': 'application/octet-stream'}                                                    |
  | Algorithm     | aes                                                                                        |
  | Bit length    | 256                                                                                        |
  | Secret type   | opaque                                                                                     |
  | Mode          | cbc                                                                                        |
  | Expiration    | None                                                                                       |
  +---------------+--------------------------------------------------------------------------------------------+

Now that we have our package created and kept in our secret, we can move on to
creating our loadbalancer.

Configuring a TLS terminated Load-balancer
===========================================

With our secret stored on the cloud, there are only a few more steps left. Next
we will need to create the loadbalancer that will look after our instance and
perform our tls termination.

To do so, we use the following command, making use of the environment variable
we created before:

.. code-block:: bash

  $ openstack loadbalancer create --name tls-loadbalancer --vip-subnet-id
  $subnet_id

  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | admin_state_up      | True                                 |
  | availability_zone   | None                                 |
  | created_at          | 2022-01-11T00:50:03                  |
  | description         |                                      |
  | flavor_id           | None                                 |
  | id                  | aXXXXXXX-XXXX-XXXX-XXXX-XXXXX02562da |
  | listeners           |                                      |
  | name                | tls-loadbalancer                     |
  | operating_status    | OFFLINE                              |
  | pools               |                                      |
  | project_id          | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    |
  | provider            | amphora                              |
  | provisioning_status | PENDING_CREATE                       |
  | updated_at          | None                                 |
  | vip_address         | 192.168.0.45                         |
  | vip_network_id      | 4f719fe1-XXXX-XXXX-XXXX-XXXXXXXXXXXX |
  | vip_port_id         | 0732125c-XXXX-XXXX-XXXX-XXXXXXXXXXXX |
  | vip_qos_policy_id   | None                                 |
  | vip_subnet_id       | aaaXXXXXX-XXXX-XXXXXXXX-XXXXX-jmu2r3 |
  | tags                |                                      |
  +---------------------+--------------------------------------+

Wait for it to be active

.. code-block:: bash

  $ openstack loadbalancer list
  +--------------------------------------+----------------------+----------------------------------+--------------+---------------------+------------------+----------+
  | id                                   | name                 | project_id                       | vip_address  | provisioning_status | operating_status | provider |
  +--------------------------------------+----------------------+----------------------------------+--------------+---------------------+------------------+----------+
  | aXXXXXXX-XXXX-XXXX-XXXX-XXXXX02562da | tls-loadbalancer     | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | 192.168.0.45 | ACTIVE              | ONLINE           | amphora  |
  +--------------------------------------+----------------------+----------------------------------+--------------+---------------------+------------------+----------+

Create a listener that uses the secret and deals with the traffic

.. code-block:: bash

  $ openstack loadbalancer listener create --protocol-port 443 --protocol
  TERMINATED_HTTPS --name listener1 --default-tls-container=$(openstack secret
  list | awk '/ tls-secret-test1 / {print $2}') tls-loadbalancer

  +-----------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | Field                       | Value                                                                                                                                                                                                                                                                              |
  +-----------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | admin_state_up              | True                                                                                                                                                                                                                                                                               |
  | connection_limit            | -1                                                                                                                                                                                                                                                                                 |
  | created_at                  | 2022-01-11T00:54:51                                                                                                                                                                                                                                                                |
  | default_pool_id             | None                                                                                                                                                                                                                                                                               |
  | default_tls_container_ref   | https://api.nz-por-1.catalystcloud.io:9311/v1/secrets/bea75b1b-b1e2-4504-b4e3-ddf7c41929b2                                                                                                                                                                                         |
  | description                 |                                                                                                                                                                                                                                                                                    |
  | id                          | 9a3bbd3c-ed72-4267-8322-ad5c5c4f931c                                                                                                                                                                                                                                               |
  | insert_headers              | None                                                                                                                                                                                                                                                                               |
  | l7policies                  |                                                                                                                                                                                                                                                                                    |
  | loadbalancers               | a148f0b9-038a-4277-bdb7-f38df02562da                                                                                                                                                                                                                                               |
  | name                        | listener1                                                                                                                                                                                                                                                                          |
  | operating_status            | OFFLINE                                                                                                                                                                                                                                                                            |
  | project_id                  | 773284c6936d4bdea37beedf5b832e54                                                                                                                                                                                                                                                   |
  | protocol                    | TERMINATED_HTTPS                                                                                                                                                                                                                                                                   |
  | protocol_port               | 443                                                                                                                                                                                                                                                                                |
  | provisioning_status         | PENDING_CREATE                                                                                                                                                                                                                                                                     |
  | sni_container_refs          | []                                                                                                                                                                                                                                                                                 |
  | timeout_client_data         | 50000                                                                                                                                                                                                                                                                              |
  | timeout_member_connect      | 5000                                                                                                                                                                                                                                                                               |
  | timeout_member_data         | 50000                                                                                                                                                                                                                                                                              |
  | timeout_tcp_inspect         | 0                                                                                                                                                                                                                                                                                  |
  | updated_at                  | None                                                                                                                                                                                                                                                                               |
  | client_ca_tls_container_ref | None                                                                                                                                                                                                                                                                               |
  | client_authentication       | NONE                                                                                                                                                                                                                                                                               |
  | client_crl_container_ref    | None                                                                                                                                                                                                                                                                               |
  | allowed_cidrs               | None                                                                                                                                                                                                                                                                               |
  | tls_ciphers                 | TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256 |
  | tls_versions                | ['TLSv1.2', 'TLSv1.3']                                                                                                                                                                                                                                                             |
  | alpn_protocols              | ['http/1.1', 'http/1.0']                                                                                                                                                                                                                                                           |
  | tags                        |                                                                                                                                                                                                                                                                                    |
  +-----------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Create a pool with the right protocol

.. code-block:: bash

  $ openstack loadbalancer pool create --name pool1 --lb-algorithm ROUND_ROBIN
  --listener listener1 --protocol HTTP

  +----------------------+--------------------------------------+
  | Field                | Value                                |
  +----------------------+--------------------------------------+
  | admin_state_up       | True                                 |
  | created_at           | 2022-01-11T01:06:25                  |
  | description          |                                      |
  | healthmonitor_id     |                                      |
  | id                   | eb9df502-7abb-42c9-bf35-e893a683071b |
  | lb_algorithm         | ROUND_ROBIN                          |
  | listeners            | 9a3bbd3c-ed72-4267-8322-ad5c5c4f931c |
  | loadbalancers        | a148f0b9-038a-4277-bdb7-f38df02562da |
  | members              |                                      |
  | name                 | pool1                                |
  | operating_status     | OFFLINE                              |
  | project_id           | 773284c6936d4bdea37beedf5b832e54     |
  | protocol             | HTTP                                 |
  | provisioning_status  | PENDING_CREATE                       |
  | session_persistence  | None                                 |
  | updated_at           | None                                 |
  | tls_container_ref    | None                                 |
  | ca_tls_container_ref | None                                 |
  | crl_container_ref    | None                                 |
  | tls_enabled          | False                                |
  | tls_ciphers          | None                                 |
  | tls_versions         | None                                 |
  | tags                 |                                      |
  | alpn_protocols       |                                      |
  +----------------------+--------------------------------------+

Add your webserver to the pool as a member

.. code-block:: bash

  $ openstack loadbalancer member create --subnet-id
  823053b3-f92d-407b-a2cd-2f392ecf8d69 --address 192.168.0.40
  --protocol-port 80 pool1

  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | address             | 192.168.0.40                         |
  | admin_state_up      | True                                 |
  | created_at          | 2022-01-11T01:07:45                  |
  | id                  | b0f00795-8162-49e2-828b-2d585a04543e |
  | name                |                                      |
  | operating_status    | NO_MONITOR                           |
  | project_id          | 773284c6936d4bdea37beedf5b832e54     |
  | protocol_port       | 80                                   |
  | provisioning_status | PENDING_CREATE                       |
  | subnet_id           | 823053b3-f92d-407b-a2cd-2f392ecf8d69 |
  | updated_at          | None                                 |
  | weight              | 1                                    |
  | monitor_port        | None                                 |
  | monitor_address     | None                                 |
  | backup              | False                                |
  | tags                |                                      |
  +---------------------+--------------------------------------+

