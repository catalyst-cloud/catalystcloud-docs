.. _apis:

#########################################
Application Programming Interfaces (APIs)
#########################################


The Catalyst Cloud follows the "API first" design principle. Every service we
implement on the Catalyst Cloud is first made available via an API, then the
command line interface (CLI) and finally the dashboard. As a result, it often
takes three to six months for a new feature or service to reach the dashboard.


*************
API reference
*************

The OpenStack API reference can be found at:
http://developer.openstack.org/api-ref.html

.. note::

  The OpenStack API complete reference guide covers versions of the APIs that
  are current, experimental and deprecated. Please make sure you are referring
  to the correct version of the API.


*************
API endpoints
*************

Once authenticated and operating from a :ref:`whitelisted IP address
<access-and-whitelist>`, you can obtain the service catalogue and the list of
API endpoints on the current region from the identity service.

From the dashboard, you can find the endpoints under Access and Security, API
endpoints.

From the command line tools, you can run ``openstack catalog list`` to list the
services and API endpoints of the current region.


Endpoints for “nz-por-1”
------------------------

+----------------+-------------------------------------------------------------------------+
| Service        | Endpoint                                                                |
+================+=========================================================================+
| cloudformation | https://api.nz-por-1.catalystcloud.io:8000/v1/                          |
+----------------+-------------------------------------------------------------------------+
| compute        | https://api.nz-por-1.catalystcloud.io:8774/v2/%tenantid%                |
+----------------+-------------------------------------------------------------------------+
| computev3      | https://api.nz-por-1.catalystcloud.io:8774/v3                           |
+----------------+-------------------------------------------------------------------------+
| ec2            | https://api.nz-por-1.catalystcloud.io:8773/services/Cloud               |
+----------------+-------------------------------------------------------------------------+
| identity       | https://api.nz-por-1.catalystcloud.io:5000/v2.0                         |
+----------------+-------------------------------------------------------------------------+
| image          | https://api.nz-por-1.catalystcloud.io:9292                              |
+----------------+-------------------------------------------------------------------------+
| metering       | http://api.nz-por-1.catalystcloud.io:8777                               |
+----------------+-------------------------------------------------------------------------+
| network        | https://api.nz-por-1.catalystcloud.io:9696/                             |
+----------------+-------------------------------------------------------------------------+
| object-store   | https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_%tenantid% |
+----------------+-------------------------------------------------------------------------+
| orchestration  | https://api.nz-por-1.catalystcloud.io:8004/v1/%tenantid%                |
+----------------+-------------------------------------------------------------------------+
| rating         | https://api.nz-por-1.catalystcloud.io:8788/                             |
+----------------+-------------------------------------------------------------------------+
| s3             | https://object-storage.nz-por-1.catalystcloud.io:443/swift/v1           |
+----------------+-------------------------------------------------------------------------+
| volume         | https://api.nz-por-1.catalystcloud.io:8776/v1/%tenantid%                |
+----------------+-------------------------------------------------------------------------+
| volumev2       | https://api.nz-por-1.catalystcloud.io:8776/v2/%tenantid%                |
+----------------+-------------------------------------------------------------------------+

Endpoints for “nz_wlg_2”
------------------------

+----------------+-------------------------------------------------------------------------+
| Service        | Endpoint                                                                |
+================+=========================================================================+
| cloudformation | https://api.cloud.catalyst.net.nz:8000/v1/                              |
+----------------+-------------------------------------------------------------------------+
| compute        | https://api.cloud.catalyst.net.nz:8774/v2/%tenantid%                    |
+----------------+-------------------------------------------------------------------------+
| computev3      | https://api.cloud.catalyst.net.nz:8774/v3                               |
+----------------+-------------------------------------------------------------------------+
| ec2            | https://api.cloud.catalyst.net.nz:8773/services/Cloud                   |
+----------------+-------------------------------------------------------------------------+
| identity       | https://api.cloud.catalyst.net.nz:5000/v2.0                             |
+----------------+-------------------------------------------------------------------------+
| image          | https://api.cloud.catalyst.net.nz:9292                                  |
+----------------+-------------------------------------------------------------------------+
| metering       | http://api.cloud.catalyst.net.nz:8777                                   |
+----------------+-------------------------------------------------------------------------+
| network        | https://api.cloud.catalyst.net.nz:9696/                                 |
+----------------+-------------------------------------------------------------------------+
| object-store   | https://object-storage.nz-wlg-2.catalystcloud.io:443/v1/AUTH_%tenantid% |
+----------------+-------------------------------------------------------------------------+
| orchestration  | https://api.cloud.catalyst.net.nz:8004/v1/%tenantid%                    |
+----------------+-------------------------------------------------------------------------+
| rating         | https://api.cloud.catalyst.net.nz:8788/                                 |
+----------------+-------------------------------------------------------------------------+
| s3             | https://object-storage.nz-wlg-2.catalystcloud.io:443/swift/v1           |
+----------------+-------------------------------------------------------------------------+
| volume         | https://api.cloud.catalyst.net.nz:8776/v1/%tenantid%                    |
+----------------+-------------------------------------------------------------------------+
| volumev2       | https://api.cloud.catalyst.net.nz:8776/v2/%tenantid%                    |
+----------------+-------------------------------------------------------------------------+

Endpoints for “nz-hlz-1”
------------------------

+----------------+-------------------------------------------------------------------------+
| Service        | Endpoint                                                                |
+================+=========================================================================+
| cloudformation | https://api.nz-hlz-1.catalystcloud.io:8000/v1/                          |
+----------------+-------------------------------------------------------------------------+
| compute        | https://api.nz-hlz-1.catalystcloud.io:8774/v2/%tenantid%                |
+----------------+-------------------------------------------------------------------------+
| computev3      | https://api.nz-hlz-1.catalystcloud.io:8774/v3                           |
+----------------+-------------------------------------------------------------------------+
| ec2            | https://api.nz-hlz-1.catalystcloud.io:8773/services/Cloud               |
+----------------+-------------------------------------------------------------------------+
| identity       | https://api.nz-hlz-1.catalystcloud.io:5000/v2.0                         |
+----------------+-------------------------------------------------------------------------+
| image          | https://api.nz-hlz-1.catalystcloud.io:9292                              |
+----------------+-------------------------------------------------------------------------+
| metering       | http://api.nz-hlz-1.catalystcloud.io:8777                               |
+----------------+-------------------------------------------------------------------------+
| network        | https://api.nz-hlz-1.catalystcloud.io:9696/                             |
+----------------+-------------------------------------------------------------------------+
| object-store   | https://object-storage.nz-hlz-1.catalystcloud.io:443/v1/AUTH_%tenantid% |
+----------------+-------------------------------------------------------------------------+
| orchestration  | https://api.nz-hlz-1.catalystcloud.io:8004/v1/%tenantid%                |
+----------------+-------------------------------------------------------------------------+
| rating         | https://api.nz-hlz-1.catalystcloud.io:8788/                             |
+----------------+-------------------------------------------------------------------------+
| s3             | https://object-storage.nz-hlz-1.catalystcloud.io:443/swift/v1           |
+----------------+-------------------------------------------------------------------------+
| volume         | https://api.nz-hlz-1.catalystcloud.io:8776/v1/%tenantid%                |
+----------------+-------------------------------------------------------------------------+
| volumev2       | https://api.nz-hlz-1.catalystcloud.io:8776/v2/%tenantid%                |
+----------------+-------------------------------------------------------------------------+
| volumev3       | https://api.nz-hlz-1.catalystcloud.io:8776/v3/%tenantid%                |
+----------------+-------------------------------------------------------------------------+
