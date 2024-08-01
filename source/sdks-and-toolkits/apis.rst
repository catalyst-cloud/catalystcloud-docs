.. _apis:

#########################################
Application programming interfaces (APIs)
#########################################

The Catalyst Cloud follows the "API first" design principle. Every service we
implement on the Catalyst Cloud is first made available via an API, then the
command line interface (CLI) and finally the dashboard. As a result, it often
takes three to six months for a new feature or service to reach the dashboard.

.. note::

  The API is rate limited to prevent one customer from denying access to
  other customers. When the rate limit is hit, the endpoint will return
  a standard HTTP error response (code 429), and a header indicating how
  much to back-off before retrying. Not all tools correctly implement
  backing off in response to this message.

*************
API reference
*************

The OpenStack API reference can be found at:
https://docs.openstack.org/api-quick-start/index.html

.. note::

  The OpenStack API complete reference guide covers versions of the APIs that
  are current, experimental and deprecated. Please make sure you are referring
  to the correct version of the API.

*************
API endpoints
*************

Once authenticated, you can obtain the service catalogue and the list of
API endpoints on the current region from the identity service.

From the dashboard, you can find the endpoints under Access and Security, API
endpoints.

From the command line tools, you can run ``openstack catalog list`` to list the
services and API endpoints of the current region.

Endpoints for ``nz-por-1``
==========================

.. list-table::
   :header-rows: 1

   * - Service Name
     - Service Type
     - Endpoint
   * - Identity
     - ``identity``
     - ``https://api.nz-por-1.catalystcloud.io:5000``
   * - Compute
     - ``compute``
     - ``https://api.nz-por-1.catalystcloud.io:8774/v2.1``
   * - Compute
     - ``computev3``
     - ``https://api.nz-por-1.catalystcloud.io:8774/v3``
   * - Networking
     - ``network``
     - ``https://api.nz-por-1.catalystcloud.io:9696/``
   * - Load Balancer
     - ``load-balancer``
     - ``https://api.nz-por-1.catalystcloud.io:9876``
   * - Block Storage
     - ``volume``
     - ``https://api.nz-por-1.catalystcloud.io:8776/v1/%project_id%``
   * - Block Storage
     - ``volumev2``
     - ``https://api.nz-por-1.catalystcloud.io:8776/v2/%project_id%``
   * - Block Storage
     - ``volumev3``
     - ``https://api.nz-por-1.catalystcloud.io:8776/v3/%project_id%``
   * - Image
     - ``image``
     - ``https://api.nz-por-1.catalystcloud.io:9292``
   * - Database
     - ``database``
     - ``https://api.nz-por-1.catalystcloud.io:8779/v1.0/%project_id%``
   * - Orchestration
     - ``orchestration``
     - ``https://api.nz-por-1.catalystcloud.io:8004/v1/%project_id%``
   * - Orchestration
     - ``cloudformation``
     - ``https://api.nz-por-1.catalystcloud.io:8000/v1/``
   * - Kubernetes
     - ``container-infra``
     - ``https://api.nz-por-1.catalystcloud.io:9511/v1``
   * - Object Storage
     - ``object-store``
     - ``https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_%project_id%``
   * - Object Storage
     - ``s3``
     - ``https://object-storage.nz-por-1.catalystcloud.io:443``
   * - Telemetry
     - ``alarming``
     - ``https://api.nz-por-1.catalystcloud.io:8042``
   * - Billing
     - ``ratingv2``
     - ``https://api.nz-por-1.catalystcloud.io:9999``
   * - Administration
     - ``registration``
     - ``https://api.cloud.catalyst.net.nz:8040/v1``

Endpoints for ``nz-hlz-1``
==========================

.. list-table::
   :header-rows: 1

   * - Service Name
     - Service Type
     - Endpoint
   * - Identity
     - ``identity``
     - ``https://api.nz-hlz-1.catalystcloud.io:5000``
   * - Compute
     - ``compute``
     - ``https://api.nz-hlz-1.catalystcloud.io:8774/v2.1``
   * - Compute
     - ``computev3``
     - ``https://api.nz-hlz-1.catalystcloud.io:8774/v3``
   * - Networking
     - ``network``
     - ``https://api.nz-hlz-1.catalystcloud.io:9696/``
   * - Load Balancer
     - ``load-balancer``
     - ``https://api.nz-hlz-1.catalystcloud.io:9876``
   * - Block Storage
     - ``volume``
     - ``https://api.nz-hlz-1.catalystcloud.io:8776/v1/%project_id%``
   * - Block Storage
     - ``volumev2``
     - ``https://api.nz-hlz-1.catalystcloud.io:8776/v2/%project_id%``
   * - Block Storage
     - ``volumev3``
     - ``https://api.nz-hlz-1.catalystcloud.io:8776/v3/%project_id%``
   * - Image
     - ``image``
     - ``https://api.nz-hlz-1.catalystcloud.io:9292``
   * - Database
     - ``database``
     - ``https://api.nz-hlz-1.catalystcloud.io:8779/v1.0/%project_id%``
   * - Orchestration
     - ``orchestration``
     - ``https://api.nz-hlz-1.catalystcloud.io:8004/v1/%project_id%``
   * - Orchestration
     - ``cloudformation``
     - ``https://api.nz-hlz-1.catalystcloud.io:8000/v1/``
   * - Kubernetes
     - ``container-infra``
     - ``https://api.nz-hlz-1.catalystcloud.io:9511/v1``
   * - Object Storage
     - ``object-store``
     - ``https://object-storage.nz-hlz-1.catalystcloud.io:443/v1/AUTH_%project_id%``
   * - Object Storage
     - ``s3``
     - ``https://object-storage.nz-hlz-1.catalystcloud.io:443``
   * - Telemetry
     - ``alarming``
     - ``https://api.nz-hlz-1.catalystcloud.io:8042``
   * - Billing
     - ``ratingv2``
     - ``https://api.nz-hlz-1.catalystcloud.io:9999``
   * - Administration
     - ``registration``
     - ``https://api.cloud.catalyst.net.nz:8040/v1``

Endpoints for ``nz_wlg_2``
==========================

.. list-table::
   :header-rows: 1

   * - Service Name
     - Service Type
     - Endpoint
   * - Identity
     - ``identity``
     - ``https://api.cloud.catalyst.net.nz:5000``
   * - Object Storage
     - ``object-store``
     - ``https://object-storage.nz-wlg-2.catalystcloud.io:443/v1/AUTH_%project_id%``
   * - Object Storage
     - ``s3``
     - ``https://object-storage.nz-wlg-2.catalystcloud.io:443``
   * - Administration
     - ``registration``
     - ``https://api.cloud.catalyst.net.nz:8040/v1``
