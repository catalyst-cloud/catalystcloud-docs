######################
Layer 7 load balancing
######################

Layer 7 load balancing takes its name from the OSI model, indicating that the
load balancer distributes requests to back-end pools based on layer 7
(application) data. Layer 7 load balancing is also known as
**request switching**, **application load balancing**, or
**content based routing or switching**.

A layer 7 load balancer consists of a listener that accepts requests on behalf
of a number of back-end pools and distributes those requests based on policies
that use application data to determine which pools should service any given
request. This allows for the application infrastructure to be specifically
tuned/optimized to serve specific types of content.

For example, a site with "mydomain.nz/login" or a subdomain "login.mydomain.nz"
will be routed to a back-end pool running an identity provider and
authentication system, while "mydomain.nz/shop" or "shop.mydomain.nz" will be
routed to an e-commerce web application.

Unlike lower-level load balancing, layer 7 load balancing does not require
that all pools behind the load balancing service have the same content. In
fact, it is generally expected that a layer 7 load balancer expects the
back-end servers from different pools will have different content. Layer
7 load balancers are capable of directing requests based on URI, host, HTTP
headers, and other data in the application message.

********
Overview
********

L7 rule
=======

An L7 rule is a single, simple logical test that evaluates to true or false.
It consists of a rule type, a comparison type, a value and an optional key that
gets used depending on the rule type. An L7 rule must always be associated
with an L7 policy.

Rule types

* ``HOST_NAME``: The rule does a comparison between the HTTP/1.1 hostname in
  the request against the value parameter in the rule.
* ``PATH``: The rule compares the path portion of the HTTP URI against the
  value parameter in the rule.
* ``FILE_TYPE``: The rule compares the last portion of the URI against the
  value parameter in the rule. (eg. “txt”, “jpg”, etc.)
* ``HEADER``: The rule looks for a header defined in the key parameter and
  compares it against the value parameter in the rule.
* ``COOKIE``: The rule looks for a cookie named by the key parameter and
  compares it against the value parameter in the rule.

Comparison types

* ``REGEX``: Perl type regular expression matching
* ``STARTS_WITH``: String starts with
* ``ENDS_WITH``: String ends with
* ``CONTAINS``: String contains
* ``EQUAL_TO``: String is equal to


L7 policy
=========

An L7 Policy is a collection of L7 rules associated with a Listener, and which
may also have an association to a back-end pool. Policies describe actions that
should be taken by the load balancing software if all of the rules in the
policy return true.


***********
Preparation
***********

If you already have two or more compute instances running a web application
listening on port 80, you can skip this step. Otherwise, launch two compute
instances and follow the instructions below to run a simple Flask web
application in each.

Create a copy of the flask_app.py script (shown below) on each server.

**script** flask_app.py

.. literalinclude:: _scripts/layer4-files/flask_app.py

Follow the instructions below to install the required dependencies.

.. note::

  In order to be able to bind to ports 80 & 443 the application needs to run as
  the root user.

.. code-block:: bash

  # sudo to the root account
  $ sudo -i
  # install the required system packages
  $ apt install virtualenv python-pip

  # create a virtual environment
  $ virtualenv venv

  # activate the virtual environment
  $ source venv/bin/activate

  # install Flask into the virtual environment
  $ pip install flask

  # exit the virtual environment
  $ deactivate

In each compute instance, start a copy of the application (each in their own
terminal session) ensuring that both listening on port 80 and that each is
given a unique endpoint_url. If you are intending on following along with
the example below these will be:

* login.example.com
* shop.example.com

.. code-block:: bash

  # sudo to the root account
  $ sudo -i

  # activate the virtual environment
  $ source venv/bin/activate

  # run the flask app - providing the correct port number and url
  $ python flask_app.py -p <port_number> -u <endpoint_url>

The output for the services running on port 80 will look similar to this

.. code-block:: bash

  root@server-1:~# python flask_app.py -p 80
   * Serving Flask app "flask_app" (lazy loading)
   * Environment: production
     WARNING: Do not use the development server in a production environment.
     Use a production WSGI server instead.
   * Debug mode: off
   * Running on http://0.0.0.0:80/ (Press CTRL+C to quit)

**********************
Create a load balancer
**********************

First lets create the loadbalancer. It will be called **lb_test** and it's
virtual IP address (VIP) will be attached to the local subnet
**private-subnet**.

.. code-block:: bash

  $ export SUBNET=`openstack subnet list --name private-subnet -f value -c ID`
  $ openstack loadbalancer create --vip-subnet-id ${SUBNET} --name lb_test
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | admin_state_up      | True                                 |
  | created_at          | 2018-06-27T03:47:29                  |
  | description         |                                      |
  | flavor              |                                      |
  | id                  | afa1cd14-03e7-4bff-afed-8001d196b9df |
  | listeners           |                                      |
  | name                | lb_test                              |
  | operating_status    | OFFLINE                              |
  | pools               |                                      |
  | project_id          | eac679e4896146e6827ce29d755fe289     |
  | provider            | octavia                              |
  | provisioning_status | PENDING_CREATE                       |
  | updated_at          | None                                 |
  | vip_address         | 10.0.0.11                            |
  | vip_network_id      | 452fc8b7-218d-4279-99b2-3d46f9d016b7 |
  | vip_port_id         | 095c4d86-7051-4618-967a-ddae50820118 |
  | vip_qos_policy_id   |                                      |
  | vip_subnet_id       | 0d10e475-045b-4b90-a378-d0dc2f66c150 |
  +---------------------+--------------------------------------+

*******************
Create the listener
*******************

Once the ``provisioning_status`` of the load balancer is ``Active``, create the
listener.

.. code-block:: bash

  $ openstack loadbalancer list
  +--------------------------------------+-----------+----------------------------------+-------------+---------------------+----------+
  | id                                   | name      | project_id                       | vip_address | provisioning_status | provider |
  +--------------------------------------+-----------+----------------------------------+-------------+---------------------+----------+
  | afa1cd14-03e7-4bff-afed-8001d196b9df | lb_test   | eac679e4896146e6827ce29d755fe289 | 10.0.0.11   | ACTIVE              | octavia  |
  +--------------------------------------+-----------+----------------------------------+-------------+---------------------+----------+
.. code-block:: bash

  $ openstack loadbalancer listener create --name http_listener --protocol HTTP --protocol-port 80 lb_test
  +---------------------------+--------------------------------------+
  | Field                     | Value                                |
  +---------------------------+--------------------------------------+
  | admin_state_up            | True                                 |
  | connection_limit          | -1                                   |
  | created_at                | 2018-06-27T03:48:52                  |
  | default_pool_id           | None                                 |
  | default_tls_container_ref | None                                 |
  | description               |                                      |
  | id                        | b35681df-5bea-4f14-aa11-1dcb4396a8df |
  | insert_headers            | None                                 |
  | l7policies                |                                      |
  | loadbalancers             | afa1cd14-03e7-4bff-afed-8001d196b9df |
  | name                      | http_listener                        |
  | operating_status          | OFFLINE                              |
  | project_id                | eac679e4896146e6827ce29d755fe289     |
  | protocol                  | HTTP                                 |
  | protocol_port             | 80                                   |
  | provisioning_status       | PENDING_CREATE                       |
  | sni_container_refs        | []                                   |
  | timeout_client_data       |                                      |
  | timeout_member_connect    |                                      |
  | timeout_member_data       |                                      |
  | timeout_tcp_inspect       |                                      |
  | updated_at                | None                                 |
  +---------------------------+--------------------------------------+

****************
Create the pools
****************

Create the first pool.

.. code-block:: bash

  $ openstack loadbalancer pool create --name http_pool_1 --listener http_listener --protocol HTTP --lb-algorithm ROUND_ROBIN
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | admin_state_up      | True                                 |
  | created_at          | 2018-06-27T03:51:37                  |
  | description         |                                      |
  | healthmonitor_id    |                                      |
  | id                  | e61c9da3-ef83-4aaf-88d0-326d2ee56b11 |
  | lb_algorithm        | ROUND_ROBIN                          |
  | listeners           | b35681df-5bea-4f14-aa11-1dcb4396a8df |
  | loadbalancers       | afa1cd14-03e7-4bff-afed-8001d196b9df |
  | members             |                                      |
  | name                | http_pool_1                          |
  | operating_status    | OFFLINE                              |
  | project_id          | eac679e4896146e6827ce29d755fe289     |
  | protocol            | HTTP                                 |
  | provisioning_status | PENDING_CREATE                       |
  | session_persistence | None                                 |
  | updated_at          | None                                 |
  +---------------------+--------------------------------------+

Create the second pool.

.. code-block:: bash

  $ openstack loadbalancer pool create --name http_pool_2 --loadbalancer lb_test --protocol HTTP --lb-algorithm ROUND_ROBIN
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | admin_state_up      | True                                 |
  | created_at          | 2018-06-27T04:09:22                  |
  | description         |                                      |
  | healthmonitor_id    |                                      |
  | id                  | 3efc552b-8cfd-43a8-be06-dddfb903d285 |
  | lb_algorithm        | ROUND_ROBIN                          |
  | listeners           |                                      |
  | loadbalancers       | afa1cd14-03e7-4bff-afed-8001d196b9df |
  | members             |                                      |
  | name                | http_pool_2                          |
  | operating_status    | OFFLINE                              |
  | project_id          | eac679e4896146e6827ce29d755fe289     |
  | protocol            | HTTP                                 |
  | provisioning_status | PENDING_CREATE                       |
  | session_persistence | None                                 |
  | updated_at          | None                                 |
  +---------------------+--------------------------------------+

***************
Add the members
***************

Add the first member to the first pool. When creating members, make sure that
you use the local addresses of your instances. In our example we use
``10.0.0.5`` and ``10.0.0.7``


.. code-block:: bash

  $ openstack loadbalancer member create --name login.example.com --subnet private-subnet --address 10.0.0.5 --protocol-port 80  http_pool
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | address             | 10.0.0.5                             |
  | admin_state_up      | True                                 |
  | created_at          | 2018-06-27T04:02:06                  |
  | id                  | d2497d5a-0c80-4037-84bf-6e3cb498126e |
  | name                | login.example.com                    |
  | operating_status    | NO_MONITOR                           |
  | project_id          | eac679e4896146e6827ce29d755fe289     |
  | protocol_port       | 80                                   |
  | provisioning_status | PENDING_CREATE                       |
  | subnet_id           | 0d10e475-045b-4b90-a378-d0dc2f66c150 |
  | updated_at          | None                                 |
  | weight              | 1                                    |
  | monitor_port        | None                                 |
  | monitor_address     | None                                 |
  +---------------------+--------------------------------------+


Add the second member to the second pool.

.. code-block:: bash

  $ openstack loadbalancer member create --name shop.example.com --subnet private-subnet --address 10.0.0.7 --protocol-port 80 http_pool_2
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | address             | 10.0.0.7                             |
  | admin_state_up      | True                                 |
  | created_at          | 2018-06-27T04:55:08                  |
  | id                  | 4c6cb13c-a68d-45fd-9c72-3e34e38f50e9 |
  | name                | shop.example.com                     |
  | operating_status    | NO_MONITOR                           |
  | project_id          | eac679e4896146e6827ce29d755fe289     |
  | protocol_port       | 80                                   |
  | provisioning_status | PENDING_CREATE                       |
  | subnet_id           | 0d10e475-045b-4b90-a378-d0dc2f66c150 |
  | updated_at          | None                                 |
  | weight              | 1                                    |
  | monitor_port        | None                                 |
  | monitor_address     | None                                 |
  +---------------------+--------------------------------------+

********************
Create the L7 policy
********************

Create the layer 7 policy.

.. code-block:: bash

  $ openstack loadbalancer l7policy create --action REDIRECT_TO_POOL --redirect-pool http_pool_2 --name policy1 http_listener
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | listener_id         | b35681df-5bea-4f14-aa11-1dcb4396a8df |
  | description         |                                      |
  | admin_state_up      | True                                 |
  | rules               |                                      |
  | project_id          | eac679e4896146e6827ce29d755fe289     |
  | created_at          | 2018-06-27T04:55:47                  |
  | provisioning_status | PENDING_CREATE                       |
  | updated_at          | None                                 |
  | redirect_pool_id    | 3efc552b-8cfd-43a8-be06-dddfb903d285 |
  | redirect_url        | None                                 |
  | action              | REDIRECT_TO_POOL                     |
  | position            | 1                                    |
  | id                  | 2aa69093-b82a-4e2d-8013-0ec224f9a142 |
  | operating_status    | OFFLINE                              |
  | name                | policy1                              |
  +---------------------+--------------------------------------+

******************
Create the L7 rule
******************

Create a rule for the policy.

.. code-block:: bash

  $ openstack loadbalancer l7rule create --compare-type EQUAL_TO --type HOST_NAME --value shop.example.com policy1
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | created_at          | 2018-06-27T04:56:39                  |
  | compare_type        | EQUAL_TO                             |
  | provisioning_status | PENDING_CREATE                       |
  | invert              | False                                |
  | admin_state_up      | True                                 |
  | updated_at          | None                                 |
  | value               | shop.example.com                     |
  | key                 | None                                 |
  | project_id          | eac679e4896146e6827ce29d755fe289     |
  | type                | HOST_NAME                            |
  | id                  | 4924fcf2-c508-47f1-a40a-afab0bca9e5f |
  | operating_status    | OFFLINE                              |
  +---------------------+--------------------------------------+

************
Assign a VIP
************

The final step is to assign a floating ip address to the VIP port on the
loadbalancer. In order to do this we need to create a floating ip, find the
VIP Port ID and then assign it a floating ip address.

.. code-block:: bash

  export FIP=`openstack floating ip create public-net -f value -c floating_ip_address`
  export VIP_PORT_ID=`openstack loadbalancer show lb_test -f value -c vip_port_id`
  openstack floating ip set --port $VIP_PORT_ID $FIP

**************
Test the setup
**************

In your workstation or in a separate test compute instance add entries to the
/etc/hosts file to provide name resolution. The value for
<loadbalancer_floating_ip> in the following examples
will be the value of $FIP from the final step of setting up the loadbalancer
above.These entries essentially become an alias for these IPs when added to
/etc/hosts in this way.

/etc/host entries

.. code-block:: bash

  <loadbalancer_floating_ip> login.example.com
  <loadbalancer_floating_ip> shop.example.com


Test connectivity to the 2 web endpoints either through your browser or using
curl from the command line.

.. code-block:: bash

  $ curl login.example.com
  Welcome to login.example.com

  $ curl shop.example.com
  Welcome to shop.example.com
