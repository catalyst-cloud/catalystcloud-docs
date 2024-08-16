Swift Client is automatically installed when installing the
Catalyst Cloud Client package. To use it, some minor configuration is required.

In addition to sourcing the OpenRC for your Catalyst Cloud project in your terminal session,
the ``OS_STORAGE_URL`` environment variable needs to be set, which stores the region-specific
object storage endpoint URL for your project.

.. include:: tutorial-scripts/endpoint-urls.rst

Once you have determined the correct endpoint URL, set the ``OS_STORAGE_URL``
environment variable, substituting ``${endpoint_url}`` below with the endpoint URL:

.. tabs::

  .. group-tab:: Linux / macOS

    .. code-block:: bash

      export OS_STORAGE_URL="${endpoint_url}/v1/AUTH_${OS_PROJECT_ID}"

  .. group-tab:: Windows

    .. code-block:: powershell

      $Env:OS_STORAGE_URL = "${endpoint_url}/v1/AUTH_${Env:OS_PROJECT_ID}"

At this point, you should now be able to use Swift Client to interact with
Catalyst Cloud Object Storage.
