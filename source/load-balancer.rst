#############
Load Balancer
#############


********
Overview
********

Load balancing is the action of taking front-end requests and distributing these
across a pool of back-end servers for processing based on a series of rules. The
load balancer service encapsulates the complexity of implementing a typical load
balancing solution into an easy to use cloud based service that natively
provides a multi-tenanted, highly scaleable programmable alternative.

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
* As members may go offline it is possible to use ``health monitors`` to detect
  their state and divert traffic away from members that are not responding properly.
  A health monitors is associated with a pool.

Load Balancing Algorithms
-------------------------
There are several load balancing algorithms available, their role is to decide
on how the back-end services are selected.

* ``Round Robin`` The algorithm chooses the server sequentially in the list.
  Once it reaches the end of the server, the algorithm forwards the new request
  to the first server in the list.
* ``Source`` This algorithm selects the server based on the source IP address
  using the hash to connect it to the matching server.
* ``Least connection`` algorithm This algorithm selects the server with few
  active transactions and then forwards the user request to the back end.


See this `glossary`_ for more information and terminology.

.. _OSI model: https://en.wikipedia.org/wiki/OSI_model
.. _glossary: https://docs.openstack.org/octavia/queens/reference/glossary.html


**********************
Layer 4 load balancing
**********************

In this example we will create a simple scenario that load balances traffic
based on TCP port numbers to different service endpoints. There will be 2
servers both with services running on ports 80 & 443.

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

Once the ``operating_status`` of the load balancer is ``ACTIVE``, we will create
two listeners, both will use TCP as their protocol and they will listen on ports
80 and 443 respectively.

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

.. code-block:: bash

  $ openstack loadbalancer listener create --name 443_listener --protocol TCP --protocol-port 443 lb_test_1
  +---------------------------+--------------------------------------+
  | Field                     | Value                                |
  +---------------------------+--------------------------------------+
  | admin_state_up            | True                                 |
  | connection_limit          | -1                                   |
  | created_at                | 2018-06-25T01:13:06                  |
  | default_pool_id           | None                                 |
  | default_tls_container_ref | None                                 |
  | description               |                                      |
  | id                        | 724816cc-2dbd-42c8-9b61-19f49fa48165 |
  | insert_headers            | None                                 |
  | l7policies                |                                      |
  | loadbalancers             | bfc1a299-3ec2-4681-974a-b7c47b52529f |
  | name                      | 443_listener                         |
  | operating_status          | OFFLINE                              |
  | project_id                | eac679e4896146e6827ce29d755fe289     |
  | protocol                  | TCP                                  |
  | protocol_port             | 443                                  |
  | provisioning_status       | PENDING_CREATE                       |
  | sni_container_refs        | []                                   |
  | timeout_client_data       |                                      |
  | timeout_member_connect    |                                      |
  | timeout_member_data       |                                      |
  | timeout_tcp_inspect       |                                      |
  | updated_at                | None                                 |
  +---------------------------+--------------------------------------+

To view the newly created listeners

.. code-block:: bash

  $ openstack loadbalancer listener list
  +--------------------------------------+-----------------+--------------+----------------------------------+----------+---------------+----------------+
  | id                                   | default_pool_id | name         | project_id                       | protocol | protocol_port | admin_state_up |
  +--------------------------------------+-----------------+--------------+----------------------------------+----------+---------------+----------------+
  | 380ea1df-e043-4167-90ca-03f044b620a3 | None            | 80_listener  | eac679e4896146e6827ce29d755fe289 | TCP      |            80 | True           |
  | 724816cc-2dbd-42c8-9b61-19f49fa48165 | None            | 443_listener | eac679e4896146e6827ce29d755fe289 | TCP      |           443 | True           |
  +--------------------------------------+-----------------+--------------+----------------------------------+----------+---------------+----------------+

Then add a pool to each listener

.. code-block:: bash

  $ openstack loadbalancer pool create --name 80_pool --listener 80_listener --protocol TCP --lb-algorithm ROUND_ROBIN
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | admin_state_up      | True                                 |
  | created_at          | 2018-06-25T01:30:17                  |
  | description         |                                      |
  | healthmonitor_id    |                                      |
  | id                  | 96dde7c5-77c5-4ffe-9542-226714f5c58d |
  | lb_algorithm        | ROUND_ROBIN                          |
  | listeners           | 380ea1df-e043-4167-90ca-03f044b620a3 |
  | loadbalancers       | bfc1a299-3ec2-4681-974a-b7c47b52529f |
  | members             |                                      |
  | name                | 80_pool                              |
  | operating_status    | OFFLINE                              |
  | project_id          | eac679e4896146e6827ce29d755fe289     |
  | protocol            | TCP                                  |
  | provisioning_status | PENDING_CREATE                       |
  | session_persistence | None                                 |
  | updated_at          | None                                 |
  +---------------------+--------------------------------------+

.. code-block:: bash

  $ openstack loadbalancer pool create --name 443_pool --listener 443_listener --protocol TCP --lb-algorithm ROUND_ROBIN
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | admin_state_up      | True                                 |
  | created_at          | 2018-06-25T01:31:04                  |
  | description         |                                      |
  | healthmonitor_id    |                                      |
  | id                  | da26844d-921d-4045-af24-017f07107934 |
  | lb_algorithm        | ROUND_ROBIN                          |
  | listeners           | 724816cc-2dbd-42c8-9b61-19f49fa48165 |
  | loadbalancers       | bfc1a299-3ec2-4681-974a-b7c47b52529f |
  | members             |                                      |
  | name                | 443_pool                             |
  | operating_status    | OFFLINE                              |
  | project_id          | eac679e4896146e6827ce29d755fe289     |
  | protocol            | TCP                                  |
  | provisioning_status | PENDING_CREATE                       |
  | session_persistence | None                                 |
  | updated_at          | None                                 |
  +---------------------+--------------------------------------+

Now add the members to the pools.

.. code-block:: bash

  $ openstack loadbalancer member create --name 80_member_1 --address 10.0.0.4 --protocol-port 80  80_pool
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | address             | 10.0.0.4                             |
  | admin_state_up      | True                                 |
  | created_at          | 2018-06-25T01:37:46                  |
  | id                  | 5ce83425-9d85-4da4-a057-4023e603ab2e |
  | name                | 80_member_1                          |
  | operating_status    | NO_MONITOR                           |
  | project_id          | eac679e4896146e6827ce29d755fe289     |
  | protocol_port       | 80                                   |
  | provisioning_status | PENDING_CREATE                       |
  | subnet_id           | None                                 |
  | updated_at          | None                                 |
  | weight              | 1                                    |
  | monitor_port        | None                                 |
  | monitor_address     | None                                 |
  +---------------------+--------------------------------------+

.. code-block:: bash

  $ openstack loadbalancer member create --name 80_member_2 --address 10.0.0.6 --protocol-port 80  80_pool
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | address             | 10.0.0.6                             |
  | admin_state_up      | True                                 |
  | created_at          | 2018-06-25T01:38:48                  |
  | id                  | 5f973af6-7d59-4f64-a0b8-df5680d1bf78 |
  | name                | 80_member_2                          |
  | operating_status    | NO_MONITOR                           |
  | project_id          | eac679e4896146e6827ce29d755fe289     |
  | protocol_port       | 80                                   |
  | provisioning_status | PENDING_CREATE                       |
  | subnet_id           | None                                 |
  | updated_at          | None                                 |
  | weight              | 1                                    |
  | monitor_port        | None                                 |
  | monitor_address     | None                                 |
  +---------------------+--------------------------------------+

Check that the members were created

.. code-block:: bash

  $ openstack loadbalancer member list 80_pool
  +--------------------------------------+-------------+----------------------------------+---------------------+----------+---------------+------------------+--------+
  | id                                   | name        | project_id                       | provisioning_status | address  | protocol_port | operating_status | weight |
  +--------------------------------------+-------------+----------------------------------+---------------------+----------+---------------+------------------+--------+
  | 5ce83425-9d85-4da4-a057-4023e603ab2e | 80_member_1 | eac679e4896146e6827ce29d755fe289 | ACTIVE              | 10.0.0.4 |            80 | NO_MONITOR       |      1 |
  | 5f973af6-7d59-4f64-a0b8-df5680d1bf78 | 80_member_2 | eac679e4896146e6827ce29d755fe289 | ACTIVE              | 10.0.0.6 |            80 | NO_MONITOR       |      1 |
  +--------------------------------------+-------------+----------------------------------+---------------------+----------+---------------+------------------+--------+

Now repeat for the service on port 443

.. code-block:: bash

  $ openstack loadbalancer member create --name 443_member_1 --address 10.0.0.4 --protocol-port 443  443_pool
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | address             | 10.0.0.4                             |
  | admin_state_up      | True                                 |
  | created_at          | 2018-06-25T01:43:41                  |
  | id                  | ec245cb0-7548-4b25-881f-5a7dcd0c6e89 |
  | name                | 443_member_1                         |
  | operating_status    | NO_MONITOR                           |
  | project_id          | eac679e4896146e6827ce29d755fe289     |
  | protocol_port       | 443                                  |
  | provisioning_status | PENDING_CREATE                       |
  | subnet_id           | None                                 |
  | updated_at          | None                                 |
  | weight              | 1                                    |
  | monitor_port        | None                                 |
  | monitor_address     | None                                 |
  +---------------------+--------------------------------------+


  $ openstack loadbalancer member create --name 443_member_2 --address 10.0.0.6 --protocol-port 443  443_pool
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | address             | 10.0.0.6                             |
  | admin_state_up      | True                                 |
  | created_at          | 2018-06-25T01:44:19                  |
  | id                  | f91e7d8e-a932-43da-8c9f-c37c0d58d864 |
  | name                | 443_member_2                         |
  | operating_status    | NO_MONITOR                           |
  | project_id          | eac679e4896146e6827ce29d755fe289     |
  | protocol_port       | 443                                  |
  | provisioning_status | PENDING_CREATE                       |
  | subnet_id           | None                                 |
  | updated_at          | None                                 |
  | weight              | 1                                    |
  | monitor_port        | None                                 |
  | monitor_address     | None                                 |
  +---------------------+--------------------------------------+


  $ openstack loadbalancer member list 443_pool
  +--------------------------------------+--------------+----------------------------------+---------------------+----------+---------------+------------------+--------+
  | id                                   | name         | project_id                       | provisioning_status | address  | protocol_port | operating_status | weight |
  +--------------------------------------+--------------+----------------------------------+---------------------+----------+---------------+------------------+--------+
  | ec245cb0-7548-4b25-881f-5a7dcd0c6e89 | 443_member_1 | eac679e4896146e6827ce29d755fe289 | ACTIVE              | 10.0.0.4 |           443 | NO_MONITOR       |      1 |
  | f91e7d8e-a932-43da-8c9f-c37c0d58d864 | 443_member_2 | eac679e4896146e6827ce29d755fe289 | ACTIVE              | 10.0.0.6 |           443 | NO_MONITOR       |      1 |
  +--------------------------------------+--------------+----------------------------------+---------------------+----------+---------------+------------------+--------+

Adding a health monitor
=======================

While it is possible to create a listener without a health monitor this is not
considered best practice to do so, especially for production load balancers.
The reason behind this is that should a back-end pool member go offline it will
not be detected or removed from the pool for a while leading to possible
service disruption for web clients.

The health monitors role is to perform pro-active checks on each back-end
server to pre-emptively detect failed servers and temporarily take them out of
the pool.


HTTP health monitors
--------------------

By default, the Catalyst load balancer service will check the “/” path on the
application server but this may not appropriate because that location may
require authorisation, be cached or cause the server to perform too much work
for a simle health check.

Typically the web application that is being load balanced will provide an
endpoint such as ``/health`` specifically for health checks. This could be as
simple as providing a basic static page which returns an HTTP status code of
200 to far more elaborate setups that provide a JSON packet containing a
variety of server status metrics.

There are also other health monitor types available including
* PING
* TCP
* HTTPS
* TLS-HELLO

To create a health monitor to check the state of the back-end servers providing
the on port 80. These services are proving a simple static response at the URL
path '/health'

.. code-block:: bash

  $ openstack loadbalancer healthmonitor create --name 80_healthcheck --delay 60 --timeout 20 --max-retries 2 --url-path /health --type http  80_pool
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | project_id          | eac679e4896146e6827ce29d755fe289     |
  | name                | 80_healthcheck                       |
  | admin_state_up      | True                                 |
  | pools               | 96dde7c5-77c5-4ffe-9542-226714f5c58d |
  | created_at          | 2018-06-25T21:22:25                  |
  | provisioning_status | PENDING_CREATE                       |
  | updated_at          | None                                 |
  | delay               | 60                                   |
  | expected_codes      | 200                                  |
  | max_retries         | 2                                    |
  | http_method         | GET                                  |
  | timeout             | 20                                   |
  | max_retries_down    | 3                                    |
  | url_path            | /health                              |
  | type                | HTTP                                 |
  | id                  | d8c8c074-574a-4e41-8c43-f0633a4e828d |
  | operating_status    | OFFLINE                              |
  +---------------------+--------------------------------------+

  Here is a brief description of some of the parameters used in the health
  monitor examle.

  * ``url_path`` : Path part of the URL that should be retrieved from the
    back-end server. By default this is “/”.
  * ``delay`` : Number of seconds to wait between health checks.
  * ``timeout`` : Number of seconds to wait for any given health check to
    complete. timeout should always be smaller than delay.
  * ``max-retries`` : Number of subsequent health checks a given back-end server
    must fail before it is considered down, or that a failed back-end server
    must pass to be considered up again.


Assigning the VIP
=================
The final step is to assign a floating ip address to the VIP port on the
loadbalancer. In order to do this we need to create a floating ip, find the
VIP Port ID and then assign it a floating ip address.

.. code-block:: bash

  export FIP=`openstack floating ip create public-net -f value -c floating_ip_address`
  export VIP_PORT_ID=`openstack loadbalancer show lb_test_1 -f value -c vip_port_id`
  openstack floating ip set --port $VIP_PORT_ID $FIP


Testing the setup
=================
As a simple mockup we have the setup shown below running on each of the
member servers.

There are 2 basic python Flask apps running on each instance, they bind to
ports 80 and 443 respectively and  will send a response when a request is
received on the listening port.

To try out the example, create a copy of both of the flasky_80.py and
flasky_443.py scripts (shown below) on each server, then run each script from
its own terminal session. Each server should have both scripts running at the
same time.

Ideally these should be run in a `virtual environment`_, below are the basic
steps required to do this and install the required `Flask`_ package.

.. _virtual environment: https://virtualenv.pypa.io/en/stable/
.. _Flask: http://flask.pocoo.org/

.. code-block:: bash

  # install the required system packages
  $ sudo apt install virtualenv python-pip

  # create a virtual environment
  $ virtualenv venv

  # activate the virtual environment
  $ source venv/bin/activate

  # install Flask into the virtul environment
  $ pip install flask

  # exit the virtual environment
  $ deactivate


**script** flask_80.py

.. code-block:: python

  from flask import Flask
  import socket


  host_name = socket.gethostname()
  host_ip = socket.gethostbyname(host_name)

  app = Flask(__name__)

  @app.route("/")
  def hello():
      #return "Hello World!"
      return "Server : {} @ {}".format(host_name, host_ip)

  @app.route("/health")
  def health():
      return "healthy!"

  if __name__ == "__main__":
      app.run(host='0.0.0.0', port=443)

**script** flask_443.py

.. code-block:: python

  from flask import Flask
  import socket


  host_name = socket.gethostname()
  host_ip = socket.gethostbyname(host_name)

  app = Flask(__name__)

  @app.route("/")
  def hello():
      #return "Hello World!"
      return "Server : {} @ {}".format(host_name, host_ip)

  @app.route("/health")
  def health():
      return "healthy!"

  if __name__ == "__main__":
      app.run(host='0.0.0.0', port=80)


Run the scripts, each in their own terminal session, in the following manner:

.. code-block:: bash

  source venv/bin/activate

  sudo python <script_name>.py

The output for the services running on port 80 will look similar to this

.. code-block:: bash

  $ sudo python flasky_80.py
   * Serving Flask app "flasky_80" (lazy loading)
   * Environment: production
     WARNING: Do not use the development server in a production environment.
     Use a production WSGI server instead.
   * Debug mode: off
   * Running on http://0.0.0.0:80/ (Press CTRL+C to quit)
  10.0.0.9 - - [27/Jun/2018 00:36:33] "GET /health HTTP/1.0" 200 -
  10.0.0.10 - - [27/Jun/2018 00:36:35] "GET /health HTTP/1.0" 200 -
  10.0.0.9 - - [27/Jun/2018 00:37:33] "GET /health HTTP/1.0" 200 -
  10.0.0.10 - - [27/Jun/2018 00:37:35] "GET /health HTTP/1.0" 200 -

The first few 'GET' requests are the loadbalancer's health check querying the
service on port 80, once this has been successful the member will be added to
the pool.

If you need to retrieve the VIP for the loadbalancer

.. code-block:: bash

  export VIP=$(openstack loadbalancer show lb_test_1 -f value -c vip_address)
  openstack floating ip list | grep $VIP | awk '{ print $4}'

Test the following:

* connect to the loadbalancer VIP from a browser. The output
  should alternate between both back-end servers on port 80.

* connect to the healtmonitor url on $VIP/health
* connect to $VIP:443 to confirm that the second service is also loadbalanced

**********************
Layer 7 load balancing
**********************

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

L7 policy testing
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
  | created_at          | 2018-06-27T03:47:29                  |
  | description         |                                      |
  | flavor              |                                      |
  | id                  | afa1cd14-03e7-4bff-afed-8001d196b9df |
  | listeners           |                                      |
  | name                | lb_test_2                            |
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

Once the ``provisioning_status`` of the load balancer is ``Active``, create the
listener.

.. code-block:: bash

  $ openstack loadbalancer list
  +--------------------------------------+-----------+----------------------------------+-------------+---------------------+----------+
  | id                                   | name      | project_id                       | vip_address | provisioning_status | provider |
  +--------------------------------------+-----------+----------------------------------+-------------+---------------------+----------+
  | afa1cd14-03e7-4bff-afed-8001d196b9df | lb_test_2 | eac679e4896146e6827ce29d755fe289 | 10.0.0.11   | ACTIVE              | octavia  |
  +--------------------------------------+-----------+----------------------------------+-------------+---------------------+----------+
.. code-block:: bash

  $ openstack loadbalancer listener create --name http_listener --protocol HTTP --protocol-port 80 lb_test_2
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

Create the first pool.

.. code-block:: bash

  $ openstack loadbalancer pool create --name http_pool --listener http_listener --protocol HTTP --lb-algorithm ROUND_ROBIN
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
  | name                | http_pool                            |
  | operating_status    | OFFLINE                              |
  | project_id          | eac679e4896146e6827ce29d755fe289     |
  | protocol            | HTTP                                 |
  | provisioning_status | PENDING_CREATE                       |
  | session_persistence | None                                 |
  | updated_at          | None                                 |
  +---------------------+--------------------------------------+

Add the member to the pool.

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

Create the second pool.

.. code-block:: bash

  $ openstack loadbalancer pool create --name http_pool_2 --loadbalancer lb_test_2 --protocol HTTP --lb-algorithm ROUND_ROBIN
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

Add the other member to the second pool.

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

The final step is to assign a floating ip address to the VIP port on the
loadbalancer. In order to do this we need to create a floating ip, find the
VIP Port ID and then assign it a floating ip address.

.. code-block:: bash

  export FIP=`openstack floating ip create public-net -f value -c floating_ip_address`
  export VIP_PORT_ID=`openstack loadbalancer show lb_test_2 -f value -c vip_port_id`
  openstack floating ip set --port $VIP_PORT_ID $FIP

Testing the setup
=================
Place a copy of the files below on to each of the endpoint servers.

Server 1

**script** flask_login.py

.. code-block:: python

  from flask import Flask
  app = Flask(__name__)

  @app.route("/")
  def hello():
      return "Welcome to login.example.com"

  if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)

Server 2

**script** flask_shop.py

.. code-block:: python

  from flask import Flask
  app = Flask(__name__)

  @app.route("/")
  def hello():
      return "Welcome to shop.example.com"

  if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)



On the test server add entries to /etc/hosts to provide name resolution. The
value for <loadbalancer_floating_ip> will be the value of $FIP from the final
step of setting up the loadbalancer above.

/etc/host entries

.. code-block:: bash

  <loadbalancer_floating_ip> login.example.com
  <loadbalancer_floating_ip> shop.example.com


Test connectivity to the 2 web endpoints.

.. code-block:: bash

  $ curl login.example.com
  Welcome to login.example.com

  $ curl shop.example.com
  Welcome to shop.example.com

*******************
Connection Draining
*******************
When needing to perform maintenance tasks on an active pool member it is
preferrable to be able to remove that member from the pool in a graceful manner
which does not abruptly terminate client connections. The usual approach to
this is a process known as connection draining, where a member's state is set
so that it will no longer accept new connections requests. This allows for any
existing connections to complete their current tasks and close, then once there
are no remaining connections the member server can be worked on safely.

To achieve this on the Catalyst Cloud Load Balancer service set the ``weight``
for the target member to 0.

.. code-block:: bash

  $ openstack loadbalancer member set http_pool login.example.com --weight 0

Once the member is ready to go back in to the pool simply reset its weight
value back the the same as the other members in the pool.

To check the weight values for existing pool members run

.. code-block:: bash

  $ openstack loadbalancer member list http_pool_2 -c name -c weight
  +------------------+--------+
  | name             | weight |
  +------------------+--------+
  | shop.example.com |      1 |
  +------------------+--------+


***************
TLS termination
***************

At present the load balancer service does not support TLS termination. It can
however forward encrypted traffic so that it can be terminated at the
application layer.

TLS termination is in our roadmap and should be available in the next version
of the load balancer service.
