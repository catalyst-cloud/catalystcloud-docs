#############
Load Balancer
#############


********
Overview
********

Load balancing is the action of taking front-end requests and distributing
these across a pool of back-end servers for processing based on a series of
rules. The Catalyst Cloud Load Balancer as a Service (LBaaS) is aimed at
encapsulating the complexity of implementing a typical load balancing solution
into an easy to use cloud based service that natively provides a
multi-tenanted, highly scaleable programmable alternative.

Layer 4 vs Layer 7 Load balancing
=================================

Load balancers are typically grouped into two categories: Layer 4 or Layer 7,
which correspond to the layers of the `OSI model`_. The Layer 4 type act upon
data such as IP, TCP, UDP which are protocols found in the network and
transport layers whereas the Layer 7 type act upon requests that contain data
from application layer protocols such as HTTP.

In order to get started we need to first define some terminology as it applies
to this service:

* The ``load balancer`` is a logical grouping of listeners on one or more
  virtual ip addresses (VIP)
* A ``listener`` is the listening endpoint of a load balanced service. It
  requires port and protocol information but not an IP address.
* The ``pool`` is associated with a listener and is responsible for grouping
  the **members** which receive the client requests forwarded by the listener.
* A ``member`` is a single server or service. It can only be associated with
  a single pool.

For a more complete set of definitions take a look at the OpenStack LBaaS
`glossary`_.

.. _OSI model: https://en.wikipedia.org/wiki/OSI_model
.. _glossary: https://docs.openstack.org/octavia/pike/reference/glossary.html


**********************
Layer 4 load balancing
**********************

In this example we will create a simple scenario that load balances traffic
based on TCP port numbers to different service endpoints.

.. note::

  In order to work with the load balancer service it necessary to add the
  octaviaclient python module to your virtual environment. More information on
  installing commandline tools can be found at `CLI`_.

.. _CLI: http://docs.catalystcloud.nz/getting-started/cli.html#command-line-interface-cli

Assuming you have a virtual environment called ``venv``, simply follow the
steps below.

.. code-block:: bash

  source venv/bin/activate
  pip install python-octaviaclient


First lets create the loadbalancer. It will be called **lb_test_1** and it's
virtual IP address (VIP) will be attached to the local subnet
**private-subnet**.

.. code-block:: bash

  $ source example-openrc.sh
  $ export SUBNET=`openstack subnet list --name private-subnet -f value -c ID`
  $ openstack loadbalancer create --vip-subnet-id ${SUBNET} --name lb_test_1
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | admin_state_up      | True                                 |
  | created_at          | 2017-11-02T21:32:52                  |
  | description         |                                      |
  | flavor              |                                      |
  | id                  | 547deffe-55fc-49be-ac52-e24c7fd22ece |
  | listeners           |                                      |
  | name                | lb_test_1                            |
  | operating_status    | OFFLINE                              |
  | pools               |                                      |
  | project_id          | a3a9af91b9e547739bfcb02cc2acded0     |
  | provider            | octavia                              |
  | provisioning_status | PENDING_CREATE                       |
  | updated_at          | None                                 |
  | vip_address         | 10.0.0.3                             |
  | vip_network_id      | 6e743092-a06a-4234-9fce-25b747b14e9e |
  | vip_port_id         | 693039f6-1896-4094-8f96-18d0fbcfb99e |
  | vip_subnet_id       | 1c221166-3cb3-4534-915a-b75220ec1873 |
  +---------------------+--------------------------------------+

Once the load balancer is ``ACTIVE``, we will create two listeners,
both will use TCP as their protocol and they will listen on ports 80 and 90
respectively

.. code-block:: bash

  $ openstack loadbalancer list
  +--------------------------------------+-----------+----------------------------------+-------------+---------------------+----------+
  | id                                   | name      | project_id                       | vip_address | provisioning_status | provider |
  +--------------------------------------+-----------+----------------------------------+-------------+---------------------+----------+
  | 547deffe-55fc-49be-ac52-e24c7fd22ece | lb_test_1 | a3a9af91b9e547739bfcb02cc2acded0 | 10.0.0.16   | ACTIVE              | octavia  |
  +--------------------------------------+-----------+----------------------------------+-------------+---------------------+----------+

.. code-block:: bash

  $ openstack loadbalancer listener create --name 80_listener --protocol TCP --protocol-port 80 lb_test_1
  +---------------------------+--------------------------------------+
  | Field                     | Value                                |
  +---------------------------+--------------------------------------+
  | admin_state_up            | True                                 |
  | connection_limit          | -1                                   |
  | created_at                | 2017-11-08T22:42:28                  |
  | default_pool_id           | None                                 |
  | default_tls_container_ref | None                                 |
  | description               |                                      |
  | id                        | de21c777-1c98-4061-aa86-f4b9faa7ea04 |
  | insert_headers            | None                                 |
  | l7policies                |                                      |
  | loadbalancers             | 547deffe-55fc-49be-ac52-e24c7fd22ece |
  | name                      | 80_listener                          |
  | operating_status          | OFFLINE                              |
  | project_id                | a3a9af91b9e547739bfcb02cc2acded0     |
  | protocol                  | TCP                                  |
  | protocol_port             | 80                                   |
  | provisioning_status       | PENDING_CREATE                       |
  | sni_container_refs        | []                                   |
  | updated_at                | None                                 |
  +---------------------------+--------------------------------------+

  $ openstack loadbalancer listener create --name 90_listener --protocol TCP --protocol-port 90 lb_test_1
  +---------------------------+--------------------------------------+
  | Field                     | Value                                |
  +---------------------------+--------------------------------------+
  | admin_state_up            | True                                 |
  | connection_limit          | -1                                   |
  | created_at                | 2017-11-08T22:45:14                  |
  | default_pool_id           | None                                 |
  | default_tls_container_ref | None                                 |
  | description               |                                      |
  | id                        | 12a4eed8-a5d1-465d-b947-b589c700d127 |
  | insert_headers            | None                                 |
  | l7policies                |                                      |
  | loadbalancers             | 547deffe-55fc-49be-ac52-e24c7fd22ece |
  | name                      | 90_listener                          |
  | operating_status          | OFFLINE                              |
  | project_id                | a3a9af91b9e547739bfcb02cc2acded0     |
  | protocol                  | TCP                                  |
  | protocol_port             | 90                                   |
  | provisioning_status       | PENDING_CREATE                       |
  | sni_container_refs        | []                                   |
  | updated_at                | None                                 |
  +---------------------------+--------------------------------------+

Then add a pool to each listener

.. code-block:: bash

  $ openstack loadbalancer pool create --name 80_pool --listener 80_listener --protocol TCP --lb-algorithm ROUND_ROBIN
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | admin_state_up      | True                                 |
  | created_at          | 2017-11-08T22:46:39                  |
  | description         |                                      |
  | healthmonitor_id    |                                      |
  | id                  | 1bac72f2-4a16-45ef-b3ec-eec49fe8eb28 |
  | lb_algorithm        | ROUND_ROBIN                          |
  | listeners           | de21c777-1c98-4061-aa86-f4b9faa7ea04 |
  | loadbalancers       | 547deffe-55fc-49be-ac52-e24c7fd22ece |
  | members             |                                      |
  | name                | 80_pool                              |
  | operating_status    | OFFLINE                              |
  | project_id          | a3a9af91b9e547739bfcb02cc2acded0     |
  | protocol            | TCP                                  |
  | provisioning_status | PENDING_CREATE                       |
  | session_persistence | None                                 |
  | updated_at          | None                                 |
  +---------------------+--------------------------------------+

  $ openstack loadbalancer pool create --name 90_pool --listener 90_listener --protocol TCP --lb-algorithm ROUND_ROBIN
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | admin_state_up      | True                                 |
  | created_at          | 2017-11-08T22:47:11                  |
  | description         |                                      |
  | healthmonitor_id    |                                      |
  | id                  | 2a0e5985-1d06-4e4e-9b51-700461b8ba7a |
  | lb_algorithm        | ROUND_ROBIN                          |
  | listeners           | 12a4eed8-a5d1-465d-b947-b589c700d127 |
  | loadbalancers       | 547deffe-55fc-49be-ac52-e24c7fd22ece |
  | members             |                                      |
  | name                | 90_pool                              |
  | operating_status    | OFFLINE                              |
  | project_id          | a3a9af91b9e547739bfcb02cc2acded0     |
  | protocol            | TCP                                  |
  | provisioning_status | PENDING_CREATE                       |
  | session_persistence | None                                 |
  | updated_at          | None                                 |
  +---------------------+--------------------------------------+

Now add the members to the pools.

.. code-block:: bash

  $ openstack loadbalancer member create --name 80_member --address 10.0.0.4 --protocol-port 80  80_pool
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | address             | 10.0.0.4                             |
  | admin_state_up      | True                                 |
  | created_at          | 2017-11-08T22:49:46                  |
  | id                  | a895336a-0843-484f-923f-d9d74e7dee85 |
  | name                | 80_member                            |
  | operating_status    | NO_MONITOR                           |
  | project_id          | a3a9af91b9e547739bfcb02cc2acded0     |
  | protocol_port       | 80                                   |
  | provisioning_status | PENDING_CREATE                       |
  | subnet_id           | None                                 |
  | updated_at          | None                                 |
  | weight              | 1                                    |
  | monitor_port        | None                                 |
  | monitor_address     | None                                 |
  +---------------------+--------------------------------------+

  $ openstack loadbalancer member create --name 90_member --address 10.0.0.12 --protocol-port 90  90_pool
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | address             | 10.0.0.12                            |
  | admin_state_up      | True                                 |
  | created_at          | 2017-11-08T23:16:47                  |
  | id                  | 5a9ec068-4c68-4d56-b75f-f842b493dadc |
  | name                | 90_member                            |
  | operating_status    | NO_MONITOR                           |
  | project_id          | a3a9af91b9e547739bfcb02cc2acded0     |
  | protocol_port       | 90                                   |
  | provisioning_status | PENDING_CREATE                       |
  | subnet_id           | None                                 |
  | updated_at          | None                                 |
  | weight              | 1                                    |
  | monitor_port        | None                                 |
  | monitor_address     | None                                 |
  +---------------------+--------------------------------------+

The final step is to assign a floating ip address to the VIP port on the
loadbalancer. In order to do this we need to create a floating ip, find the
VIP Port ID and then assign it a floating ip address.

.. code-block:: bash

  export FIP=`openstack floating ip create public -f value -c floating_ip_address`
  export VIP_PORT_ID=`openstack loadbalancer show lb_test_1 -f value -c vip_port_id`
  openstack floating ip set --port $VIP_PORT_ID $FIP

As a simple mockup we have the commands shown below running on each of the
member servers, they will send a response when a connection is received on the
listening port. Make sure that you replace the PORT variable with the correct
value, i.e. 80 or 90, for each member server.

.. code-block:: bash

  export MYIP=$(/sbin/ifconfig eth0 |grep 'inet addr'|awk -F: '{print $2}'| awk '{print $1}');
  export PORT="80"
  sudo nc -lk -p ${PORT} -c 'echo -e "HTTP/1.1 200 OK\r\n$(date)\r\n\r\n\tThis is server : $(hostname)\n\n"'

To test, telnet to both of the ports at VIP of the listener, in response you
should expect to get an appropriate response for the targeted port indicating
that the correct server has responded to the request.

.. code-block:: bash

  $ telnet $FIP 80
  Trying 10.0.0.3...
  Connected to 10.0.0.3.
  Escape character is '^]'.
  HTTP/1.1 200 OK
  Thu Nov  9 01:25:08 UTC 2017

    This is server : <hostname>

  Connection closed by foreign host.


  $ telnet $FIP 90
  Trying 10.0.0.3...
  Connected to 10.0.0.3.
  Escape character is '^]'.
  HTTP/1.1 200 OK
  Thu Nov  9 01:25:55 UTC 2017

    This is server : <hostname>


  Connection closed by foreign host.


**********************
Layer 7 load balancing
**********************

Layer 7 load balancing takes its name from the OSI model, indicating that the
load balancer distributes requests to back-end pools based on layer 7
(application) data. Layer 7 load balancing s also known as
**request switching**, **application load balancing**, or
**content based routing or switching**.

A layer 7 load balancer consists of a listener that accepts requests on behalf
of a number of back-end pools and distributes those requests based on policies
that use application data to determine which pools should service any given
request. This allows for the application infrastructure to be specifically
tuned/optimized to serve specific types of content.

For example,

A site with "mydomain.nz/login" or a subdomain "login.mydomain.nz" will be
routed to a back-end pool running an identity provider and authentication
system, while "mydomain.nz/shop" or "shop.mydomain.nz" will be routed to a
commerce application".

Unlike lower-level load balancing, layer 7 load balancing does not require
that all pools behind the load balancing service have the same content. In
fact, it is generally expected that a layer 7 load balancer expects the
back-end servers from different pools will have different content. Layer
7 load balancers are capable of directing requests based on URI, host, HTTP
headers, and other data in the application message.

L7 rule
=======
An L7 rule is a single, simple logical test that evaluates to true or false.
It consists of a rule type, a comparison type, a value and an optional key that
gets used depending on the rule type. An L7 rule must always be associated
with an L7 policy.

Rule types

* HOST_NAME: The rule does a comparison between the HTTP/1.1 hostname in the
  request against the value parameter in the rule.
* PATH: The rule compares the path portion of the HTTP URI against the value
  parameter in the rule.
* FILE_TYPE: The rule compares the last portion of the URI against the value
  parameter in the rule. (eg. “txt”, “jpg”, etc.)
* HEADER: The rule looks for a header defined in the key parameter and compares
  it against the value parameter in the rule.
* COOKIE: The rule looks for a cookie named by the key parameter and compares
  it against the value parameter in the rule.

Comparison types

- REGEX: Perl type regular expression matching
- STARTS_WITH: String starts with
- ENDS_WITH: String ends with
- CONTAINS: String contains
- EQUAL_TO: String is equal to

L7 policy
=========
An L7 Policy is a collection of L7 rules associated with a Listener, and which
may also have an association to a back-end pool. Policies describe actions that
should be taken by the load balancing software if all of the rules in the
policy return true.

L7 Policy Testing
=================

First lets create the loadbalancer. It will be called **lb_test_2** and it’s
virtual IP address (VIP) will be attached to the local subnet
**private-subnet**.

.. code-block:: bash

  $ export SUBNET=`openstack subnet list --name private-subnet -f value -c ID`
  $ openstack loadbalancer create --vip-subnet-id ${SUBNET} --name lb_test_2
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | admin_state_up      | True                                 |
  | created_at          | 2018-05-28T02:55:10                  |
  | description         |                                      |
  | flavor              |                                      |
  | id                  | fa1ba76a-f6eb-423d-b101-921ba439b4d1 |
  | listeners           |                                      |
  | name                | lb_test_2                            |
  | operating_status    | OFFLINE                              |
  | pools               |                                      |
  | project_id          | 0ef8ecaa78684c399d1d514b61698fda     |
  | provider            | octavia                              |
  | provisioning_status | PENDING_CREATE                       |
  | updated_at          | None                                 |
  | vip_address         | 10.0.0.9                             |
  | vip_network_id      | 908816f1-933c-4ff2-8595-f0f57c689e48 |
  | vip_port_id         | 1f6a4e91-36c7-43d9-ad77-97b771239f7c |
  | vip_qos_policy_id   |                                      |
  | vip_subnet_id       | af0f251c-0a36-4bde-b3bc-e6167eda3d1e |
  +---------------------+--------------------------------------+

Once the load balancer is ``Active``, Create the listener

.. code-block:: bash

  $ openstack loadbalancer list
  +--------------------------------------+-----------+----------------------------------+-------------+---------------------+----------+
  | id                                   | name      | project_id                       | vip_address | provisioning_status | provider |
  +--------------------------------------+-----------+----------------------------------+-------------+---------------------+----------+
  | fa1ba76a-f6eb-423d-b101-921ba439b4d1 | lb_test_2 | 0ef8ecaa78684c399d1d514b61698fda | 10.0.0.19   | ACTIVE              | octavia  |
  +--------------------------------------+-----------+----------------------------------+-------------+---------------------+----------+

.. code-block:: bash

  $ openstack loadbalancer listener create --name http_listener --protocol HTTP --protocol-port 80 lb_test_2
  +---------------------------+--------------------------------------+
  | Field                     | Value                                |
  +---------------------------+--------------------------------------+
  | admin_state_up            | True                                 |
  | connection_limit          | -1                                   |
  | created_at                | 2017-11-09T02:48:50                  |
  | default_pool_id           | None                                 |
  | default_tls_container_ref | None                                 |
  | description               |                                      |
  | id                        | eb1d781d-38d3-45e5-bc17-8e6ab53613f2 |
  | insert_headers            | None                                 |
  | l7policies                |                                      |
  | loadbalancers             | 547deffe-55fc-49be-ac52-e24c7fd22ece |
  | name                      | http_listener                        |
  | operating_status          | OFFLINE                              |
  | project_id                | a3a9af91b9e547739bfcb02cc2acded0     |
  | protocol                  | HTTP                                 |
  | protocol_port             | 80                                   |
  | provisioning_status       | PENDING_CREATE                       |
  | sni_container_refs        | []                                   |
  | updated_at                | None                                 |
  +---------------------------+--------------------------------------+

Create the first pool

.. code-block:: bash

  $ openstack loadbalancer pool create --name http_pool --listener http_listener --protocol HTTP --lb-algorithm ROUND_ROBIN
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | admin_state_up      | True                                 |
  | created_at          | 2017-11-09T02:50:04                  |
  | description         |                                      |
  | healthmonitor_id    |                                      |
  | id                  | 77d958cd-d2ba-4bbc-b5dc-ebba82963bdc |
  | lb_algorithm        | ROUND_ROBIN                          |
  | listeners           | eb1d781d-38d3-45e5-bc17-8e6ab53613f2 |
  | loadbalancers       | 547deffe-55fc-49be-ac52-e24c7fd22ece |
  | members             |                                      |
  | name                | http_pool                            |
  | operating_status    | OFFLINE                              |
  | project_id          | a3a9af91b9e547739bfcb02cc2acded0     |
  | protocol            | HTTP                                 |
  | provisioning_status | PENDING_CREATE                       |
  | session_persistence | None                                 |
  | updated_at          | None                                 |
  +---------------------+--------------------------------------+

Add the member to the pool

.. code-block:: bash

  $ openstack loadbalancer member create --name www.example.com --subnet private-subnet --address 10.0.0.4 --protocol-port 80  http_pool
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | address             | 10.0.0.4                             |
  | admin_state_up      | True                                 |
  | created_at          | 2017-11-09T02:50:39                  |
  | id                  | 02d4c636-cc38-42d3-a7fd-2339e0acd536 |
  | name                | www.example.com                      |
  | operating_status    | NO_MONITOR                           |
  | project_id          | a3a9af91b9e547739bfcb02cc2acded0     |
  | protocol_port       | 80                                   |
  | provisioning_status | PENDING_CREATE                       |
  | subnet_id           | 1c221166-3cb3-4534-915a-b75220ec1873 |
  | updated_at          | None                                 |
  | weight              | 1                                    |
  | monitor_port        | None                                 |
  | monitor_address     | None                                 |
  +---------------------+--------------------------------------+

Create the second pool

.. code-block:: bash

  $ openstack loadbalancer pool create --name http_pool_2 --loadbalancer lb_test_2 --protocol HTTP --lb-algorithm ROUND_ROBIN
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | admin_state_up      | True                                 |
  | created_at          | 2017-11-09T02:51:21                  |
  | description         |                                      |
  | healthmonitor_id    |                                      |
  | id                  | af13eb62-d4a1-44e5-8a9d-d7df0595b8bb |
  | lb_algorithm        | ROUND_ROBIN                          |
  | listeners           |                                      |
  | loadbalancers       | 547deffe-55fc-49be-ac52-e24c7fd22ece |
  | members             |                                      |
  | name                | http_pool_2                          |
  | operating_status    | OFFLINE                              |
  | project_id          | a3a9af91b9e547739bfcb02cc2acded0     |
  | protocol            | HTTP                                 |
  | provisioning_status | PENDING_CREATE                       |
  | session_persistence | None                                 |
  | updated_at          | None                                 |
  +---------------------+--------------------------------------+

Add the other member to the second pool

.. code-block:: bash

  $ openstack loadbalancer member create --name www2.example.com --subnet private-subnet --address 10.0.0.12 --protocol-port 80  http_pool_2
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | address             | 10.0.0.12                            |
  | admin_state_up      | True                                 |
  | created_at          | 2017-11-09T02:51:51                  |
  | id                  | 60edcc97-5afe-43e1-9c8e-e164ec381274 |
  | name                | www2.example.com                     |
  | operating_status    | NO_MONITOR                           |
  | project_id          | a3a9af91b9e547739bfcb02cc2acded0     |
  | protocol_port       | 80                                   |
  | provisioning_status | PENDING_CREATE                       |
  | subnet_id           | 1c221166-3cb3-4534-915a-b75220ec1873 |
  | updated_at          | None                                 |
  | weight              | 1                                    |
  | monitor_port        | None                                 |
  | monitor_address     | None                                 |
  +---------------------+--------------------------------------+

Create the layer 7 policy

.. code-block:: bash

  openstack loadbalancer l7policy create --action REDIRECT_TO_POOL --redirect-pool http_pool_2 --name policy1 http_listener
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | listener_id         | eb1d781d-38d3-45e5-bc17-8e6ab53613f2 |
  | description         |                                      |
  | admin_state_up      | True                                 |
  | rules               |                                      |
  | project_id          | a3a9af91b9e547739bfcb02cc2acded0     |
  | created_at          | 2017-11-09T02:52:16                  |
  | provisioning_status | PENDING_CREATE                       |
  | updated_at          | None                                 |
  | redirect_pool_id    | af13eb62-d4a1-44e5-8a9d-d7df0595b8bb |
  | redirect_url        | None                                 |
  | action              | REDIRECT_TO_POOL                     |
  | position            | 1                                    |
  | id                  | 7b191c4f-cc22-4896-8b16-0c703d8b5220 |
  | operating_status    | OFFLINE                              |
  | name                | policy1                              |
  +---------------------+--------------------------------------+

Create a rule for the policy

.. code-block:: bash

  openstack loadbalancer l7rule create --compare-type EQUAL_TO --type HOST_NAME --value www2.example.com policy1
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | created_at          | 2017-11-09T02:52:58                  |
  | compare_type        | EQUAL_TO                             |
  | provisioning_status | PENDING_CREATE                       |
  | invert              | False                                |
  | admin_state_up      | True                                 |
  | updated_at          | None                                 |
  | value               | www2.example.com                     |
  | key                 | None                                 |
  | project_id          | a3a9af91b9e547739bfcb02cc2acded0     |
  | type                | HOST_NAME                            |
  | id                  | 6a8c5d53-1e21-4bf4-b0fc-6f168f600f91 |
  | operating_status    | OFFLINE                              |
  +---------------------+--------------------------------------+

The final step is to assign a floating ip address to the VIP port on the
loadbalancer. In order to do this we need to create a floating ip, find the
VIP Port ID and then assign it a floating ip address.

.. code-block:: bash

  export FIP=`openstack floating ip create public -f value -c floating_ip_address`
  export VIP_PORT_ID=`openstack loadbalancer show lb_test_2 -f value -c vip_port_id`
  openstack floating ip set --port $VIP_PORT_ID $FIP

Testing the setup
=================
Place a copy of the files below on to each of the endpoint servers.

Server 1

.. code-block:: bash

  #!/bin/sh
  URL="www.example.com"
  MYIP=$(/sbin/ifconfig eth0 |grep 'inet addr'|awk -F: '{print $2}'| awk '{print $1}');
  OUTPUT="Welcome to www.example.com\r"
  LEN=${#OUTPUT}
  while true; do echo -e "HTTP/1.1 200 OK\r\nContent-Length: ${LEN}\r\n\r\n${OUTPUT}" | sudo nc
  -l -p 80; done

Server 2

.. code-block:: bash

  #!/bin/sh
  URL="www2.example.com"
  MYIP=$(/sbin/ifconfig eth0 |grep 'inet addr'|awk -F: '{print $2}'| awk '{print $1}');
  OUTPUT="Welcome to www2.example.com\r"
  LEN=${#OUTPUT}
  while true; do echo -e "HTTP/1.1 200 OK\r\nContent-Length: ${LEN}\r\n\r\n${OUTPUT}" | sudo nc
  -l -p 80; done


On the test server add entries to /etc/hosts to provide name resolution. The
value for <loadbalancer_floating_ip> will be the value of $FIP from the final
step of setting up the loadbalancer above.

/etc/host entries

.. code-block:: bash

  <loadbalancer_floating_ip> www.example.com
  <loadbalancer_floating_ip> www2.example.com


Test connectivity to the 2 web endpoints.

.. code-block:: bash

  $ curl www.example.com
  Welcome to 10.0.0.4 the URL is www.example.com

  $ curl www2.example.com
  Welcome to 10.0.0.12 the URL is www2.example.com


***************
TLS termination
***************

At present the load balancer service does not support TLS termination. It can
however forward encrypted traffic so that it can be terminated at the
application layer.

TLS termination is in our roadmap and should be available in the next version
of the load balancer service.
