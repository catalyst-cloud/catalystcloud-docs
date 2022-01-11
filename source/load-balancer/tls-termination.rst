###############
TLS Termination
###############

.. Warning::

  The following tutorial makes use of the Secret storage service on the cloud.
  This service is currently at a technical preview stage. To make use of this
  service, you will need to raise a :ref:`support ticket<admin-support>` to
  request access for your project.

In this section, we cover how to use openstack tools to create a load balancer
which will handle TLS termination for your webservers.

***************
Prerequisites
***************

Configuring your command line
=============================

To interact with the loadbalancer service on the cloud, you must have the
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
