##############
Access Control
##############


It is possible to have the load balancer restrict access to the content sitting
behind it by applying IP address based restrictions by providing the CIDR of the
allowed network.

**************************
Enabling CIDR Resrtictions
**************************

By default the listeners associated with a loadbalancer will accept traffic
from all network addresses. If you wish to restrict access this can be enabled
on a per CIDR basis.

To do this we can use the **--allowed-cidr** parameter. It can be passed
either at creation time or subsequently applied to an existing listener. Setting
this parameter will deny any access from addresses outside of the allowed
range/s.

To apply it when the listener is created.

.. code-block::

    openstack loadbalancer listener create --name http_listener \
    --protocol HTTP \
    --protocol-port 80
    --allowed-cidr 203.0.113.0/25
    lb_test

If we then view the listener we should see

.. code-block::

    +-----------------------------+--------------------------------------+
    | Field                       | Value                                |
    +-----------------------------+--------------------------------------+
    | admin_state_up              | True                                 |
    | connection_limit            | -1                                   |
    | created_at                  | 2020-03-30T00:33:06                  |
    | default_pool_id             | 11fcf1df-a1dd-44c6-875d-e3d0b4fde179 |
    | default_tls_container_ref   | None                                 |
    | description                 |                                      |
    | id                          | 98daa436-a16a-4497-800f-06945005061c |
    | insert_headers              | None                                 |
    | l7policies                  | a3d03787-88e0-4d64-92ef-e4f83b1cf359 |
    | loadbalancers               | 75dbce10-6848-4b6d-8237-31cc17948973 |
    | name                        | http_listener                        |
    | operating_status            | ONLINE                               |
    | project_id                  | eac679e4896146e6827ce29d755fe289     |
    | protocol                    | HTTP                                 |
    | protocol_port               | 80                                   |
    | provisioning_status         | ACTIVE                               |
    | sni_container_refs          | []                                   |
    | timeout_client_data         | 50000                                |
    | timeout_member_connect      | 5000                                 |
    | timeout_member_data         | 50000                                |
    | timeout_tcp_inspect         | 0                                    |
    | updated_at                  | 2020-03-30T00:57:38                  |
    | client_ca_tls_container_ref | None                                 |
    | client_authentication       | NONE                                 |
    | client_crl_container_ref    | None                                 |
    | allowed_cidrs               | 203.0.113.0/25                       |
    +-----------------------------+--------------------------------------+

If we wanted to add an allowed CIDR range to an existing listener we can do that
using the set command, like so.

.. code-block::

    openstack loadbalancer listener set \
    --allowed-cidr 203.0.113.0/25 \
    http_listener

To add multiple allowed ranges simply repeat the parameter multiple times,
one for each address range that needs to be added.

.. Note::

    If there are existing allowed CIDR ranges already defined on the listener
    they need to be included in the **set** command as it will override the
    settings with what gets passed in.

.. code-block::

    openstack loadbalancer listener set \
    --allowed-cidr 203.0.113.0/25 \
    --allowed-cidr 203.0.113.128/25 \
    http_listener

Viewing the listener, we can see that we now have 2 allowed network address
ranges applied to the listener.

.. code-block::

    olb listener show http_listener
    +-----------------------------+--------------------------------------+
    | Field                       | Value                                |
    +-----------------------------+--------------------------------------+
    | admin_state_up              | True                                 |
    | connection_limit            | -1                                   |
    | created_at                  | 2020-03-30T00:33:06                  |
    | default_pool_id             | 11fcf1df-a1dd-44c6-875d-e3d0b4fde179 |
    | default_tls_container_ref   | None                                 |
    | description                 |                                      |
    | id                          | 98daa436-a16a-4497-800f-06945005061c |
    | insert_headers              | None                                 |
    | l7policies                  | a3d03787-88e0-4d64-92ef-e4f83b1cf359 |
    | loadbalancers               | 75dbce10-6848-4b6d-8237-31cc17948973 |
    | name                        | http_listener                        |
    | operating_status            | ONLINE                               |
    | project_id                  | eac679e4896146e6827ce29d755fe289     |
    | protocol                    | HTTP                                 |
    | protocol_port               | 80                                   |
    | provisioning_status         | ACTIVE                               |
    | sni_container_refs          | []                                   |
    | timeout_client_data         | 50000                                |
    | timeout_member_connect      | 5000                                 |
    | timeout_member_data         | 50000                                |
    | timeout_tcp_inspect         | 0                                    |
    | updated_at                  | 2020-03-30T00:58:48                  |
    | client_ca_tls_container_ref | None                                 |
    | client_authentication       | NONE                                 |
    | client_crl_container_ref    | None                                 |
    | allowed_cidrs               | 202.78.240.7/32                      |
    |                             | 203.109.145.15/32                    |
    +-----------------------------+--------------------------------------+
