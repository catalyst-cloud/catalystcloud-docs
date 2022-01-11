###############
TLS Termination
###############

In this section, we cover how to use openstack tools to create a loadbalancer
<<<<<<< HEAD
which will handle TLS termination for your webservers.

***************
Prerequisites
***************

=======
that will handle TLS termination for your instances.

***************
Assumptions
***************

Before we begin this tutorial there are some assumptions this tutorial has:

>>>>>>> initial file for tls termination
Configuring your command line
=============================

To interact with the loadbalancer service on the cloud, you must have the
<<<<<<< HEAD
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

As this tutorial covers the steps on how to set up a TLS terminated
loadbalancer, you will need to have the following resources already available so
that we can use them as inputs later on in this guide. You will need:

- A webserver on the cloud that is currently running your desired application.
- The valid certificates and keys that relate to your webserver application/website.
- The UUID of the subnet that you want your loadbalancer to be hosted on.

You can acquire the UUID of your subnet by running the following command and
creating an environment variable for the ID:

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
of the prerequisite resources ready, we can begin creating our new load
balancer.

Creating a secret using the Barbican service
===================================================

First, we need to create a secret containing our TLS certificates and key,
which we can safely store on the cloud using the
`Barbican <https://docs.openstack.org/barbican/latest/>`_ service. To start,
we need to create a package that contains all of our required inputs.

Navigate to the folder containing your certificate, keyfile and any certificate
chains required. Once there, you can use the following command to create a
pkcs12 package:

.. code-block:: bash

  $ openssl pkcs12 -export -inkey <SERVER.key> -in <SERVER-CERTIFICATE.crt> -certfile <CERTIFICATE-CA-CHAIN.crt> -passout pass: -out <PACKAGE-NAME>.p12

Once this command finishes running, it will have created a pkcs12 file that
contains all of our certs and the corresponding key, packaged together. We can
then create a secret containing this package, which we will store on the cloud.
For this example we are going to name our secret *tls-secret-01*:

.. code-block:: bash

  # Substitute your package name for "PACKAGE-NAME.p12"

  $ openstack secret store --name="tls-secret-01" -t "application/octet-stream"
  -e "base64" --payload="$(base64 < PACKAGE-NAME.p12)"

  +---------------+--------------------------------------------------------------------------------------------+
  | Field         | Value                                                                                      |
  +---------------+--------------------------------------------------------------------------------------------+
  | Secret href   | https://api.nz-por-1.catalystcloud.io:9311/v1/secrets/beXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX |
  | Name          | tls-secret-01                                                                                 |
  | Created       | None                                                                                       |
  | Status        | None                                                                                       |
  | Content types | {'default': 'application/octet-stream'}                                                    |
  | Algorithm     | aes                                                                                        |
  | Bit length    | 256                                                                                        |
  | Secret type   | opaque                                                                                     |
  | Mode          | cbc                                                                                        |
  | Expiration    | None                                                                                       |
  +---------------+--------------------------------------------------------------------------------------------+

Now that we have our packaged certificates and key stored and kept in our
secret, we can move on to creating our loadbalancer.

Configuring a TLS terminated Load-balancer
===========================================

With our TLS Certificate and Key now stored on the cloud, there are only a few
steps left. Next we will need to create the loadbalancer that will look after
our instance and perform our TLS termination.

To do so, we use the following command, including the environment variable
we created before:

.. code-block:: bash

  $ openstack loadbalancer create --name tls-loadbalancer --vip-subnet-id $subnet_id

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

Once we run this command we need to wait for our loadbalancer to become
available. Once the ``provisioning_status`` of our loadbalancer is ``ACTIVE``
we can continue.

.. code-block:: bash

  $ openstack loadbalancer list
  +--------------------------------------+----------------------+----------------------------------+--------------+---------------------+------------------+----------+
  | id                                   | name                 | project_id                       | vip_address  | provisioning_status | operating_status | provider |
  +--------------------------------------+----------------------+----------------------------------+--------------+---------------------+------------------+----------+
  | aXXXXXXX-XXXX-XXXX-XXXX-XXXXX02562da | tls-loadbalancer     | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX | 192.168.0.45 | ACTIVE              | ONLINE           | amphora  |
  +--------------------------------------+----------------------+----------------------------------+--------------+---------------------+------------------+----------+

Now that our loadbalancer is ready, we can move on to the next step. We need
to create a listener for our loadbalancer. This is the part of the loadbalancer
that interacts with our secret and actually performs the TLS functions.

.. code-block:: bash

  # Ensure that you are using the right name for your TLS secret when sourcing the default container.
  # In this tutorial we used the name 'tls-secret-01'

  $ openstack loadbalancer listener create --protocol-port 443 --protocol
  TERMINATED_HTTPS --name tls-listener --default-tls-container=$(openstack secret
  list | awk '/ tls-secret-01 / {print $2}') tls-loadbalancer

  +-----------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | Field                       | Value                                                                                                                                                                                                                                                                              |
  +-----------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | admin_state_up              | True                                                                                                                                                                                                                                                                               |
  | connection_limit            | -1                                                                                                                                                                                                                                                                                 |
  | created_at                  | 2022-01-11T00:54:51                                                                                                                                                                                                                                                                |
  | default_pool_id             | None                                                                                                                                                                                                                                                                               |
  | default_tls_container_ref   | https://api.nz-por-1.catalystcloud.io:9311/v1/secrets/beXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                                                                                                                                                                                         |
  | description                 |                                                                                                                                                                                                                                                                                    |
  | id                          | 9aXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX                                                                                                                                                                                                                                               |
  | insert_headers              | None                                                                                                                                                                                                                                                                               |
  | l7policies                  |                                                                                                                                                                                                                                                                                    |
  | loadbalancers               | aXXXXXXX-XXXX-XXXX-XXXX-XXXXX02562da                                                                                                                                                                                                                                               |
  | name                        | tls-listener                                                                                                                                                                                                                                                                          |
  | operating_status            | OFFLINE                                                                                                                                                                                                                                                                            |
  | project_id                  | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                                                                                                                                                                                                                                                   |
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

Next we need to create a pool for our loadbalancer and add our webserver as a
member. The important thing to consider about your pool is which algorithm you
want to use for your traffic to be sorted. In this case we are going to stick
to the round robin algorithm.

.. code-block:: bash

  $ openstack loadbalancer pool create --name tls-pool --lb-algorithm ROUND_ROBIN
  --listener tls-listener --protocol HTTP

  +----------------------+--------------------------------------+
  | Field                | Value                                |
  +----------------------+--------------------------------------+
  | admin_state_up       | True                                 |
  | created_at           | 2022-01-11T01:06:25                  |
  | description          |                                      |
  | healthmonitor_id     |                                      |
  | id                   | eb9df502-7abb-42c9-bf35-e893a683071b |
  | lb_algorithm         | ROUND_ROBIN                          |
  | listeners            | 9aXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX |
  | loadbalancers        | aXXXXXXX-XXXX-XXXX-XXXX-XXXXX02562da |
  | members              |                                      |
  | name                 | tls-pool                                |
  | operating_status     | OFFLINE                              |
  | project_id           | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     |
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

Now we add our webserver as a member to the pool:

.. code-block:: bash

  $ openstack loadbalancer member create --subnet-id
  $subnet_id --address 192.168.0.40 --protocol-port 80 tls-pool

  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | address             | 192.168.0.40                         |
  | admin_state_up      | True                                 |
  | created_at          | 2022-01-11T01:07:45                  |
  | id                  | b0f00795-8162-49e2-828b-2d585a04543e |
  | name                |                                      |
  | operating_status    | NO_MONITOR                           |
  | project_id          | XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     |
  | protocol_port       | 80                                   |
  | provisioning_status | PENDING_CREATE                       |
  | subnet_id           | aaaXXXXXX-XXXX-XXXXXXXX-XXXXX-jmu2r3 |
  | updated_at          | None                                 |
  | weight              | 1                                    |
  | monitor_port        | None                                 |
  | monitor_address     | None                                 |
  | backup              | False                                |
  | tags                |                                      |
  +---------------------+--------------------------------------+

Once that is done we should have a functioning loadbalancer that will perform
TLS termination for our webserver.
=======
following:

- Your :ref:`openstack CLI<command-line-interface>` set up.
- You must have :ref:`Sourced an openRC file<configuring-the-cli>` on your
  current command line environment
- You must have installed the `python barbican-client tools
  <https://pypi.org/project/python-barbicanclient/>`_.

Once you have the necessary tools installed and your environment ready, you can
proceed with the next step:


- You already have a webserver prepared
- You have the proper certs, keys etc.
- you have openssl installed
- you have some existing knowledge about TLS termination

*****************************************************
Preparing a secret store using the Barbican service
*****************************************************

- Package everything together in a pkcs12
- then store that pkcs12 as a secret in Barbican


******************************************
Creating the TLS terminated Load-balancer
******************************************

- Using that secret, create a loadbalancer that does TLS termination using that
secret.
- create a pool for your lB
- add your webserver as a member to the pool for your lB
- That should be it.



$ openstack secret store --name="tls-secret-test1" -t "application/octet-stream" -e "base64" --payload="$(base64 < server.p12)"\
+---------------+--------------------------------------------------------------------------------------------+
| Field         | Value                                                                                      |
+---------------+--------------------------------------------------------------------------------------------+
| Secret href   | https://api.nz-por-1.catalystcloud.io:9311/v1/secrets/bea75b1b-b1e2-4504-b4e3-ddf7c41929b2 |
| Name          | tls-secret-test1                                                                           |
| Created       | None                                                                                       |
| Status        | None                                                                                       |
| Content types | {'default': 'application/octet-stream'}                                                    |
| Algorithm     | aes                                                                                        |
| Bit length    | 256                                                                                        |
| Secret type   | opaque                                                                                     |
| Mode          | cbc                                                                                        |
| Expiration    | None                                                                                       |
+---------------+--------------------------------------------------------------------------------------------+

$ openstack loadbalancer create --name barbican-secret-test --vip-subnet-id 823053b3-f92d-407b-a2cd-2f392ecf8d69
+---------------------+--------------------------------------+
| Field               | Value                                |
+---------------------+--------------------------------------+
| admin_state_up      | True                                 |
| availability_zone   | None                                 |
| created_at          | 2022-01-11T00:50:03                  |
| description         |                                      |
| flavor_id           | None                                 |
| id                  | a148f0b9-038a-4277-bdb7-f38df02562da |
| listeners           |                                      |
| name                | barbican-secret-test                 |
| operating_status    | OFFLINE                              |
| pools               |                                      |
| project_id          | 773284c6936d4bdea37beedf5b832e54     |
| provider            | amphora                              |
| provisioning_status | PENDING_CREATE                       |
| updated_at          | None                                 |
| vip_address         | 192.168.0.45                         |
| vip_network_id      | 4f719fe1-a770-49fc-80f7-93a50b748238 |
| vip_port_id         | 0732125c-6321-4302-b3aa-91b09109092f |
| vip_qos_policy_id   | None                                 |
| vip_subnet_id       | 823053b3-f92d-407b-a2cd-2f392ecf8d69 |
| tags                |                                      |
+---------------------+--------------------------------------+

$ openstack loadbalancer list
+--------------------------------------+----------------------+----------------------------------+--------------+---------------------+------------------+----------+
| id                                   | name                 | project_id                       | vip_address  | provisioning_status | operating_status | provider |
+--------------------------------------+----------------------+----------------------------------+--------------+---------------------+------------------+----------+
| a148f0b9-038a-4277-bdb7-f38df02562da | barbican-secret-test | 773284c6936d4bdea37beedf5b832e54 | 192.168.0.45 | ACTIVE              | ONLINE           | amphora  |
+--------------------------------------+----------------------+----------------------------------+--------------+---------------------+------------------+----------+

$ openstack loadbalancer listener create --protocol-port 443 --protocol TERMINATED_HTTPS --name listener1 --default-tls-container=$(openstack secret list | awk '/ tls-secret-test1 / {print $2}') barbican-secret-test
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

openstack loadbalancer pool create --name pool1 --lb-algorithm ROUND_ROBIN --listener listener1 --protocol HTTP
/usr/lib/python3/dist-packages/secretstorage/dhcrypto.py:15: CryptographyDeprecationWarning: int_from_bytes is deprecated, use int.from_bytes instead
  from cryptography.utils import int_from_bytes
/usr/lib/python3/dist-packages/secretstorage/util.py:19: CryptographyDeprecationWarning: int_from_bytes is deprecated, use int.from_bytes instead
  from cryptography.utils import int_from_bytes
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

openstack loadbalancer member create --subnet-id 823053b3-f92d-407b-a2cd-2f392ecf8d69 --address 192.168.0.40 --protocol-port 80 pool1
/usr/lib/python3/dist-packages/secretstorage/dhcrypto.py:15: CryptographyDeprecationWarning: int_from_bytes is deprecated, use int.from_bytes instead
  from cryptography.utils import int_from_bytes
/usr/lib/python3/dist-packages/secretstorage/util.py:19: CryptographyDeprecationWarning: int_from_bytes is deprecated, use int.from_bytes instead
  from cryptography.utils import int_from_bytes
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
>>>>>>> initial file for tls termination
