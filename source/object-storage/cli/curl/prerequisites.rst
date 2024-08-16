The easiest way to interact with Catalyst Cloud using cURL is to use
Swift API.

This uses two environment variables in your terminal session:
the **storage URL** (``OS_STORAGE_URL``), which we will configure now,
and the **auth token** (``OS_TOKEN``), which is set when you source the
OpenRC file for your Catalyst Cloud project (which we have already done).

To get API requests using cURL working we now need to set the ``OS_STORAGE_URL``
environment variable, which stores the region-specific object storage endpoint URL
for your project.

.. include:: tutorial-scripts/endpoint-urls.rst

Once you have determined the correct endpoint URL, set the ``OS_STORAGE_URL``
environment variable, substituting ``${endpoint_url}`` below with the endpoint URL:

.. code-block:: bash

  export OS_STORAGE_URL="${endpoint_url}/v1/AUTH_${OS_PROJECT_ID}"

At this point, you will now be able to use the instructions below to send
API commands using cURL.
