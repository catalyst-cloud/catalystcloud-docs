######################
Layer 4 load balancing
######################

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

***********************
Adding a health monitor
***********************

While it is possible to create a listener without a health monitor this is not
considered best practice to do so, especially for production load balancers.
The reason behind this is that should a back-end pool member go offline it will
not be detected or removed from the pool for a while leading to possible
service disruption for web clients.

The health monitors role is to perform pro-active checks on each back-end
server to pre-emptively detect failed servers and temporarily take them out of
the pool.


HTTP health monitors
====================

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


*****************
Assigning the VIP
*****************
The final step is to assign a floating ip address to the VIP port on the
loadbalancer. In order to do this we need to create a floating ip, find the
VIP Port ID and then assign it a floating ip address.

.. code-block:: bash

  export FIP=`openstack floating ip create public-net -f value -c floating_ip_address`
  export VIP_PORT_ID=`openstack loadbalancer show lb_test_1 -f value -c vip_port_id`
  openstack floating ip set --port $VIP_PORT_ID $FIP

*****************
Testing the setup
*****************
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
