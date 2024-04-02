.. raw:: html

  <h3> Preparation </h3>

This example illustrates how to load balance traffic on port 80 and 443 for two
compute instances running a mock Python Flask web application.

If you already have two or more compute instances running a web application
listening on ports 80 and 443, you can skip this step. Otherwise,
:ref:`launch two compute instances<quickstart_for_compute>` and follow the
instructions below to run a simple Flask web application in each.

The Flask app binds to ports 80 and 443 respectively and will send a simple
HTTP response when a request is received on the listening ports.

First we will have to create a copy of the flask_app.py script (shown below) on
each server. The easiest way to do this, is to have a program like vim so you
can copy paste the code into the new file you create on your instances.

.. note::

  You must also make sure that you have a security group that allows access
  to your instances from both the HTTP port (80) and the HTTPS port (443)
  otherwise the listeners and members (which are explained further on) won't be
  able to access your instances, meaning you will not be able to test the
  results of the load-balancer.

**script** flask_app.py

.. literalinclude:: /load-balancer/_scripts/layer4-files/flask_app.py

Once you have a copy of the flask_app.py file, ssh to your instances and
follow the instructions below to install the required dependencies.

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

|

In **each** compute instance, start **two** instances of the application
(each in their own terminal session) ensuring that there is one listening on
port 80 and the other on port 443.

.. code-block:: bash

  # sudo to the root account
  $ sudo -i

  # activate the virtual environment
  $ source venv/bin/activate

  # run the flask app - providing the correct port numbers
  $ python flask_app.py -p <port_number>

The output for the services running on port 80 will look similar to this:

.. code-block:: bash

  root@server-1:~# python flask_app.py -p 80
   * Serving Flask app "flask_app" (lazy loading)
   * Environment: production
     WARNING: Do not use the development server in a production environment.
     Use a production WSGI server instead.
   * Debug mode: off
   * Running on http://0.0.0.0:80/ (Press CTRL+C to quit)
  10.0.0.9 - - [28/Jun/2018 06:09:43] "GET /health HTTP/1.0" 200 -

.. raw:: html

  <h3> Create a load balancer </h3>

Now, we create the loadbalancer. It will be called **lb_test_1** and it's
virtual IP address (VIP) will be attached to the local subnet
**private-subnet**.

.. note::

  If you wish to run the tests included with this example, you will need to
  have root access on the test instances. If you do not have that level of access
  then substitute 8080 and 8443 wherever you see 80 and 443 respectively.

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
  | id                  | 547deffe-55fc-49be-ac52-xxxxxxxxxxxx |
  | listeners           |                                      |
  | name                | lb_test_1                            |
  | operating_status    | OFFLINE                              |
  | pools               |                                      |
  | project_id          | a3a9af91b9e547739xxxxxxcc2acded0     |
  | provider            | octavia                              |
  | provisioning_status | PENDING_CREATE                       |
  | updated_at          | None                                 |
  | vip_address         | 10.0.0.3                             |
  | vip_network_id      | 6e743092-a06a-4234-9fce-xxxxxxxxxxxx |
  | vip_port_id         | 693039f6-1896-4094-8f96-xxxxxxxxxxxx |
  | vip_subnet_id       | 1c221166-3cb3-4534-915a-xxxxxxxxxxxx |
  +---------------------+--------------------------------------+

.. raw:: html

  <h3> Create a listener </h3>

Once the ``operating_status`` of the load balancer is ``ACTIVE``, we will
create two listeners, both will use TCP as their protocol and they will listen
on ports 80 and 443 respectively.

.. code-block:: bash

  $ openstack loadbalancer list
  +--------------------------------------+-----------+----------------------------------+-------------+---------------------+----------+
  | id                                   | name      | project_id                       | vip_address | provisioning_status | provider |
  +--------------------------------------+-----------+----------------------------------+-------------+---------------------+----------+
  | 547deffe-55fc-49be-ac52-xxxxxxxxxxxx | lb_test_1 | a3a9af91b9e547739xxxxxxcc2acded0 | 10.0.0.16   | ACTIVE              | octavia  |
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
  | id                        | de21c777-1c98-4061-aa86-xxxxxxxxxxxx |
  | insert_headers            | None                                 |
  | l7policies                |                                      |
  | loadbalancers             | 547deffe-55fc-49be-ac52-xxxxxxxxxxxx |
  | name                      | 80_listener                          |
  | operating_status          | OFFLINE                              |
  | project_id                | a3a9af91b9e547739xxxxxxcc2acded0     |
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
  | id                        | 724816cc-2dbd-42c8-9b61-xxxxxxxxxxxx |
  | insert_headers            | None                                 |
  | l7policies                |                                      |
  | loadbalancers             | bfc1a299-3ec2-4681-974a-xxxxxxxxxxxx |
  | name                      | 443_listener                         |
  | operating_status          | OFFLINE                              |
  | project_id                | eac679e489614xxxxxxce29d755fe289     |
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

To view the newly created listeners.

.. code-block:: bash

  $ openstack loadbalancer listener list
  +--------------------------------------+-----------------+--------------+----------------------------------+----------+---------------+----------------+
  | id                                   | default_pool_id | name         | project_id                       | protocol | protocol_port | admin_state_up |
  +--------------------------------------+-----------------+--------------+----------------------------------+----------+---------------+----------------+
  | 380ea1df-e043-4167-90ca-xxxxxxxxxxxx | None            | 80_listener  | eac679e489614xxxxxxce29d755fe289 | TCP      |            80 | True           |
  | 724816cc-2dbd-42c8-9b61-xxxxxxxxxxxx | None            | 443_listener | eac679e489614xxxxxxce29d755fe289 | TCP      |           443 | True           |
  +--------------------------------------+-----------------+--------------+----------------------------------+----------+---------------+----------------+

.. raw:: html

  <h3> Create a pool </h3>

Then add a pool to each listener.

.. code-block:: bash

  $ openstack loadbalancer pool create --name 80_pool --listener 80_listener --protocol TCP --lb-algorithm ROUND_ROBIN
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | admin_state_up      | True                                 |
  | created_at          | 2018-06-25T01:30:17                  |
  | description         |                                      |
  | healthmonitor_id    |                                      |
  | id                  | 96dde7c5-77c5-4ffe-9542-xxxxxxxxxxxx |
  | lb_algorithm        | ROUND_ROBIN                          |
  | listeners           | 380ea1df-e043-4167-90ca-xxxxxxxxxxxx |
  | loadbalancers       | bfc1a299-3ec2-4681-974a-xxxxxxxxxxxx |
  | members             |                                      |
  | name                | 80_pool                              |
  | operating_status    | OFFLINE                              |
  | project_id          | eac679e489614xxxxxxce29d755fe289     |
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
  | id                  | da26844d-921d-4045-af24-xxxxxxxxxxxx |
  | lb_algorithm        | ROUND_ROBIN                          |
  | listeners           | 724816cc-2dbd-42c8-9b61-xxxxxxxxxxxx |
  | loadbalancers       | bfc1a299-3ec2-4681-974a-xxxxxxxxxxxx |
  | members             |                                      |
  | name                | 443_pool                             |
  | operating_status    | OFFLINE                              |
  | project_id          | eac679e489614xxxxxxce29d755fe289     |
  | protocol            | TCP                                  |
  | provisioning_status | PENDING_CREATE                       |
  | session_persistence | None                                 |
  | updated_at          | None                                 |
  +---------------------+--------------------------------------+

.. raw:: html

  <h3> Add members </h3>

Now add the members to the pools... When creating members, make sure that you
use the local addresses of your instances. In our example we use ``10.0.0.4``
and ``10.0.0.6``
however this may be different for your instances, it almost certainly will be
different, so you should double check the following code before putting it in
the command line.

.. code-block:: bash

  $ openstack loadbalancer member create --name 80_member_1 --address 10.0.0.4 --protocol-port 80  80_pool
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | address             | 10.0.0.4                             |
  | admin_state_up      | True                                 |
  | created_at          | 2018-06-25T01:37:46                  |
  | id                  | 5ce83425-9d85-4da4-a057-xxxxxxxxxxxx |
  | name                | 80_member_1                          |
  | operating_status    | NO_MONITOR                           |
  | project_id          | eac679e489614xxxxxxce29d755fe289     |
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
  | id                  | 5f973af6-7d59-4f64-a0b8-xxxxxxxxxxxx |
  | name                | 80_member_2                          |
  | operating_status    | NO_MONITOR                           |
  | project_id          | eac679e489614xxxxxxce29d755fe289     |
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
  | 5ce83425-9d85-4da4-a057-xxxxxxxxxxxx | 80_member_1 | eac679e489614xxxxxxce29d755fe289 | ACTIVE              | 10.0.0.4 |            80 | NO_MONITOR       |      1 |
  | 5f973af6-7d59-4f64-a0b8-xxxxxxxxxxxx | 80_member_2 | eac679e489614xxxxxxce29d755fe289 | ACTIVE              | 10.0.0.6 |            80 | NO_MONITOR       |      1 |
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
  | id                  | ec245cb0-7548-4b25-881f-xxxxxxxxxxxx |
  | name                | 443_member_1                         |
  | operating_status    | NO_MONITOR                           |
  | project_id          | eac679e489614xxxxxxce29d755fe289     |
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
  | id                  | f91e7d8e-a932-43da-8c9f-xxxxxxxxxxxx |
  | name                | 443_member_2                         |
  | operating_status    | NO_MONITOR                           |
  | project_id          | eac679e489614xxxxxxce29d755fe289     |
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
  | ec245cb0-7548-4b25-881f-xxxxxxxxxxxx | 443_member_1 | eac679e489614xxxxxxce29d755fe289 | ACTIVE              | 10.0.0.4 |           443 | NO_MONITOR       |      1 |
  | f91e7d8e-a932-43da-8c9f-xxxxxxxxxxxx | 443_member_2 | eac679e489614xxxxxxce29d755fe289 | ACTIVE              | 10.0.0.6 |           443 | NO_MONITOR       |      1 |
  +--------------------------------------+--------------+----------------------------------+---------------------+----------+---------------+------------------+--------+

.. raw:: html

  <h3> Add a health monitor </h3>

Create a health monitor to check the state of the members of the pool. This
example performs a simple static request at the URL path '/health'.

.. code-block:: bash

  $ openstack loadbalancer healthmonitor create --name 80_healthcheck --delay 60 --timeout 20 --max-retries 2 --url-path /health --type http  80_pool
  +---------------------+--------------------------------------+
  | Field               | Value                                |
  +---------------------+--------------------------------------+
  | project_id          | eac679e489614xxxxxxce29d755fe289     |
  | name                | 80_healthcheck                       |
  | admin_state_up      | True                                 |
  | pools               | 96dde7c5-77c5-4ffe-9542-xxxxxxxxxxxx |
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
  | id                  | d8c8c074-574a-4e41-8c43-xxxxxxxxxxxx |
  | operating_status    | OFFLINE                              |
  +---------------------+--------------------------------------+

Here is a brief description of some of the parameters used in the health
monitor example.

* ``url_path`` : Path part of the URL that should be retrieved from the
  back-end server. By default this is “/”.
* ``delay`` : Number of seconds to wait between health checks.
* ``timeout`` : Number of seconds to wait for any given health check to
  complete. Timeout should always be smaller than delay.
* ``max-retries`` : Number of subsequent health checks a given back-end server
  must fail before it is considered down, or that a failed back-end server
  must pass to be considered up again.


.. raw:: html

  <h3> Assign a VIP </h3>

The final step is to assign a floating ip address to the VIP port on the
loadbalancer. In order to do this we need to create a floating ip, find the
VIP Port ID and then assign it a floating ip address.

.. code-block:: bash

  export FIP=`openstack floating ip create public-net -f value -c floating_ip_address`
  export VIP_PORT_ID=`openstack loadbalancer show lb_test_1 -f value -c vip_port_id`
  openstack floating ip set --port $VIP_PORT_ID $FIP

.. raw:: html

  <h3> Test the setup </h3>

If you need to retrieve the VIP for the loadbalancer

.. code-block:: bash

  export VIP=$(openstack loadbalancer show lb_test_1 -f value -c vip_address)
  openstack floating ip list | grep $VIP | awk '{ print $4}'

Test the following:

* Connect to the loadbalancer VIP from a browser. The output should alternate
  between both back-end servers on port 80.
* Connect to the healtmonitor URL on $VIP/health
* Connect to $VIP:443 to confirm that the second service is also loadbalanced
