##############
Health monitor
##############

Health monitors perform pro-active checks on members of the load balancing pool
to pre-emptively detect failed members and temporarily take them out of
the pool.

.. note::

  While it is possible to create a listener without a health monitor this is
  not considered best practice, especially for production load balancers.
  Without a health monitor, the load balancer will continue to forward
  connections to unhealthy (offline) members of the pool, causing service
  disruption to clients.


************************
Types of health monitors
************************

The following health monitor types are supported by the load balancer service.

* ``HTTP``: Sends periodic HTTP requests to back-end servers, using the
  desirable HTTP method, and confirms the result returned matches the expected
  code.
* ``HTTPS``: Operates exactly like HTTP health monitors, but with SSL back-end
  servers. (Please note this will not work if the servers are performing client
  certificate validation. In this case, using TLS-HELLO type monitoring is
  recommended.)
* ``TLS-HELLO``: Ensures the back-end server responds to SSLv3 client hello
  messages. It will not check any other health metrics, like status code or
  body contents.
* ``PING``: Sends periodic ICMP PING requests to the back-end servers. Your
  back-end servers must be configured to allow ICMP PING in order for these
  health checks to pass.
* ``TCP``: Opens a TCP connection to the back-end servers on the specified
  port. Your custom TCP application should be written to respond OK to the load
  balancer connecting, opening a TCP connection, and closing it again after the
  TCP handshake without sending any data.


**********************
Health monitor options
**********************

Generic to all types
====================

All health monitors support the following configurable options:

* ``delay`` : Number of seconds to wait between health checks.
* ``timeout`` : Number of seconds to wait for any given health check to
  complete. timeout should always be smaller than delay.
* ``max-retries`` : Number of subsequent health checks a given back-end server
  must fail before it is considered down, or that a failed back-end server must
  pass to be considered up again.

Specific to HTTP
================

In addition to the above, HTTP health monitors also have the following options:

* ``url_path``: Path part of the URL that should be retrieved from the back-end
  server. By default this is “/”.
* ``http_method``: HTTP method that should be used to retrieve the url_path. By
  default this is “GET”.
* ``expected_codes``: List of HTTP status codes that indicate an OK health
  check. By default this is just “200”.


*************************
Creating a health monitor
*************************

By default, HTTP health monitor will check the “/” path on the application
server but this may not appropriate because that location may require
authorisation, be cached or cause the server to perform too much work for a
simple health check.

Typically the web application that is being load balanced will provide an
endpoint such as ``/health`` specifically for health checks. This could be as
simple as providing a basic static page which returns an HTTP status code of
200 to far more elaborate setups that provide a JSON packet containing a
variety of server status metrics.

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


**************
Best practices
**************

Please keep the following best practices in mind when writing the code that
generates the health check in your web application:

* The health monitor url_path should not require authentication to load.
* By default the health monitor url_path should return a HTTP 200 OK status
  code to indicate a healthy server unless you specify alternate
  expected_codes.
* The health check should do enough internal checks to ensure the application
  is healthy and no more. This may mean ensuring database or other external
  storage connections are up and running, server load is acceptable, the site
  is not in maintenance mode, and other tests specific to your application.
* The page generated by the health check should be very light weight:

  - It should return in a sub-second interval.
  - It should not induce significant load on the application server.

* The page generated by the health check should never be cached, though the
  code running the health check may reference cached data. For example, you may
  find it useful to run a more extensive health check via cron and store the
  results of this to disk. The code generating the page at the health monitor
  url_path would incorporate the results of this cron job in the tests it
  performs.
* Health checks only care about the HTTP status code returned. Since health
  checks are run so frequently, it may make sense to use the “HEAD” or
  “OPTIONS” HTTP methods to cut down on unnecessary processing of a whole page.
