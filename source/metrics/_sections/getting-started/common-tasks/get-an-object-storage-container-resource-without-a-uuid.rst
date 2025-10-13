:ref:`Object Storage <object-storage>` containers, unlike other resource types,
do not have a UUID associated with them in the Object Storage service.
The Metrics Service, however, always uses UUIDs for accessing resources.

To resolve this, the Metrics Service generates a custom UUID based on the project ID and the name of the container.
A reference to the project ID and the container name is stored inside the resource as the ``original_resource_id``
field, in the format ``{project_id}_{container}``.

.. note::

  For more information, see the documentation for the :ref:`container resource type <metrics-containers>`.

Here is how to get object storage container resources in the Metrics Service without knowing the UUID.

.. tabs::

  .. group-tab:: OpenStack CLI

    Run the following command (substituting ``{container}`` for the name of the container to find):

    .. code-block:: bash

      openstack metric resource search --type swift_account "original_resource_id='${OS_PROJECT_ID}_{container}'"

    Example output:

    .. code-block:: console

      $ openstack metric resource search --type swift_account "original_resource_id='${OS_PROJECT_ID}_test-container'"
      +--------------------------------------+---------------+----------------------------------+---------+-------------------------------------------------+----------------------------------+----------+----------------------------------+--------------+-------------------------------------------------------------------+----------------+
      | id                                   | type          | project_id                       | user_id | original_resource_id                            | started_at                       | ended_at | revision_start                   | revision_end | creator                                                           | storage_policy |
      +--------------------------------------+---------------+----------------------------------+---------+-------------------------------------------------+----------------------------------+----------+----------------------------------+--------------+-------------------------------------------------------------------+----------------+
      | cc5d7d7c-c9c0-5b02-b7d1-cd6cc432358a | swift_account | 9864e20f92ef47238becfe06b869d2ac | None    | 9864e20f92ef47238becfe06b869d2ac_test-container | 2025-05-19T03:14:58.321610+00:00 | None     | 2025-05-19T03:14:58.321619+00:00 | None         | 42dcfd23b04a4006b9e2b08c0a835aeb:ceecc421f7994cc397380fae5e495179 | nz--o1--mr-r3  |
      +--------------------------------------+---------------+----------------------------------+---------+-------------------------------------------------+----------------------------------+----------+----------------------------------+--------------+-------------------------------------------------------------------+----------------+

    To get *just* the resource's UUID, you can add ``-c id -f value`` to the end of the command.

    .. code-block:: console

      $ openstack metric resource search --type swift_account "original_resource_id='${OS_PROJECT_ID}_test-container'" -c id -f value
      cc5d7d7c-c9c0-5b02-b7d1-cd6cc432358a

  .. group-tab:: Python Client

    Call the following method (substituting ``{project_id}`` for your project ID, and ``{container}`` for the name of the container to find):

    .. code-block:: python

      gnocchi_client.resource.search(
          resource_type="swift_account",
          query={"=": {"original_resource_id": "{project_id}_{container}"}},
      )

    Example output:

    .. code-block:: python

      >>> pprint(gnocchi_client.resource.search(resource_type="swift_account", query={"=": {"original_resource_id": "9864e20f92ef47238becfe06b869d2ac_test-container"}}))
      [{'created_by_project_id': 'ceecc421f7994cc397380fae5e495179',
        'created_by_user_id': '42dcfd23b04a4006b9e2b08c0a835aeb',
        'creator': '42dcfd23b04a4006b9e2b08c0a835aeb:ceecc421f7994cc397380fae5e495179',
        'ended_at': None,
        'id': 'cc5d7d7c-c9c0-5b02-b7d1-cd6cc432358a',
        'metrics': {'storage.containers.objects.size': 'f226f01f-fd2f-4ff8-9848-2fb7b4f1d7dc',
                    'storage.objects.download.size.internet': '22956258-cbe1-40a8-aace-5c954995b4af',
                    'storage.objects.upload.size.internet': 'b364abff-4c95-4c2d-8d05-59ea955c2c01'},
        'original_resource_id': '9864e20f92ef47238becfe06b869d2ac_test-container',
        'project_id': '9864e20f92ef47238becfe06b869d2ac',
        'revision_end': None,
        'revision_start': '2025-05-19T03:14:58.321619+00:00',
        'started_at': '2025-05-19T03:14:58.321610+00:00',
        'storage_policy': 'nz--o1--mr-r3',
        'type': 'swift_account',
        'user_id': None}]

  .. group-tab:: cURL

    Make the following request (substituting ``{project_id}`` for your project ID, and ``{container}`` for the name of the container to find):

    .. code-block:: bash

      curl -s \
           -X POST \
           -H "X-Auth-Token: ${OS_TOKEN}" \
           -H "Content-Type: application/json" \
           -H "Accept: application/json" \
           https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/search/resource/swift_account \
           -d '{"=": {"original_resource_id": "{project_id}_{container}"}}'

    Example output:

    .. code-block:: console

      $ curl -s -X POST -H "X-Auth-Token: ${OS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/search/resource/swift_account -d '{"=": {"original_resource_id": "9864e20f92ef47238becfe06b869d2ac_test-container"}}' | jq
      [
        {
          "id": "cc5d7d7c-c9c0-5b02-b7d1-cd6cc432358a",
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:ceecc421f7994cc397380fae5e495179",
          "started_at": "2025-05-19T03:14:58.321610+00:00",
          "revision_start": "2025-05-19T03:14:58.321619+00:00",
          "ended_at": null,
          "user_id": null,
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "original_resource_id": "9864e20f92ef47238becfe06b869d2ac_test-container",
          "type": "swift_account",
          "storage_policy": "nz--o1--mr-r3",
          "revision_end": null,
          "metrics": {
            "storage.containers.objects.size": "f226f01f-fd2f-4ff8-9848-2fb7b4f1d7dc",
            "storage.objects.download.size.internet": "22956258-cbe1-40a8-aace-5c954995b4af",
            "storage.objects.upload.size.internet": "b364abff-4c95-4c2d-8d05-59ea955c2c01"
          },
          "created_by_user_id": "42dcfd23b04a4006b9e2b08c0a835aeb",
          "created_by_project_id": "ceecc421f7994cc397380fae5e495179"
        }
      ]
