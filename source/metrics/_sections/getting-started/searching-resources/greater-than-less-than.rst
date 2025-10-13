Number and datetime-type attributes allow filtering
based on whether or not the attribute is greater than
or less than the provided value (with optional "or equal to").

In this example, we are going to search for all instances
created within the month of July.

.. tabs::

  .. group-tab:: OpenStack CLI

    Run the following command:

    .. code-block:: bash

      openstack metric resource search --type instance "started_at>='2025-07-01T00:00:00+00:00' and started_at<'2025-08-01T00:00:00+00:00'"

    Example output:

    .. code-block:: console

      $ openstack metric resource search --type instance "started_at>='2025-07-01T00:00:00+00:00' and started_at<'2025-08-01T00:00:00+00:00'"
      +--------------------------------------+----------+----------------------------------+----------------------------------+--------------------------------------+----------------------------------+----------+----------------------------------+--------------+-------------------------------------------------------------------+------------------------+--------------------------------------+--------------------------------------+--------------+-------------+-----------+---------+------+
      | id                                   | type     | project_id                       | user_id                          | original_resource_id                 | started_at                       | ended_at | revision_start                   | revision_end | creator                                                           | display_name           | image_ref                            | flavor_id                            | server_group | flavor_name | os_distro | os_type | host |
      +--------------------------------------+----------+----------------------------------+----------------------------------+--------------------------------------+----------------------------------+----------+----------------------------------+--------------+-------------------------------------------------------------------+------------------------+--------------------------------------+--------------------------------------+--------------+-------------+-----------+---------+------+
      | 2a50f066-8e1e-44b1-b355-091d88fdac7f | instance | 9864e20f92ef47238becfe06b869d2ac | 517bcd700274432d96f43616ac1e37ea | 2a50f066-8e1e-44b1-b355-091d88fdac7f | 2025-07-23T04:30:10.527292+00:00 | None     | 2025-07-23T04:30:10.527296+00:00 | None         | 42dcfd23b04a4006b9e2b08c0a835aeb:ceecc421f7994cc397380fae5e495179 | test-instance-20250723 | ec8c7806-19d2-4791-b503-d6cdd2414187 | 28153197-6690-4485-9dbc-fc24489b0683 | None         | c1.c1r1     | ubuntu    | linux   | None |
      +--------------------------------------+----------+----------------------------------+----------------------------------+--------------------------------------+----------------------------------+----------+----------------------------------+--------------+-------------------------------------------------------------------+------------------------+--------------------------------------+--------------------------------------+--------------+-------------+-----------+---------+------+

  .. group-tab:: Python Client

    Call the following method:

    .. code-block:: python

      gnocchi_client.resource.search(
          resource_type="instance",
          query={
              "and": [
                    {">=": {"started_at": "2025-07-01T00:00:00+00:00"}},  # 'ge' can also be used.
                    {"<": {"started_at": "2025-08-01T00:00:00+00:00"}},  # 'lt' can also be used.
              ],
          },
      )

    Example output:

    .. code-block:: python

      >>> pprint(gnocchi_client.resource.search(resource_type="instance", query={"and": [{">=": {"started_at": "2025-07-01T00:00:00+00:00"}}, {"<": {"started_at": "2025-08-01T00:00:00+00:00"}}]}))
      [{'created_by_project_id': 'ceecc421f7994cc397380fae5e495179',
        'created_by_user_id': '42dcfd23b04a4006b9e2b08c0a835aeb',
        'creator': '42dcfd23b04a4006b9e2b08c0a835aeb:ceecc421f7994cc397380fae5e495179',
        'display_name': 'test-instance-20250723',
        'ended_at': None,
        'flavor_id': '28153197-6690-4485-9dbc-fc24489b0683',
        'flavor_name': 'c1.c1r1',
        'host': None,
        'id': '2a50f066-8e1e-44b1-b355-091d88fdac7f',
        'image_ref': 'ec8c7806-19d2-4791-b503-d6cdd2414187',
        'metrics': {'compute.instance.booting.time': '2f3fc7d3-60f9-41cb-93b8-4d08d2a9bdd1',
                    'cpu': 'afa729d2-3877-4589-88d7-f5da9debad46',
                    'disk.ephemeral.size': '4cdb7ab7-7799-46fe-b317-efa892a8b2a1',
                    'disk.root.size': '4e01f69c-ed8a-4ffc-9675-20f9c8538088',
                    'instance': '4cf621c4-bc18-47ea-a580-e33fcc94ce49',
                    'memory': '5a13e69e-e79e-4a69-b1e2-9f1f2075e279',
                    'vcpus': '44576b05-786e-421a-ae42-98de5872327f'},
        'original_resource_id': '2a50f066-8e1e-44b1-b355-091d88fdac7f',
        'os_distro': 'ubuntu',
        'os_type': 'linux',
        'project_id': '9864e20f92ef47238becfe06b869d2ac',
        'revision_end': None,
        'revision_start': '2025-07-23T04:30:10.527296+00:00',
        'server_group': None,
        'started_at': '2025-07-23T04:30:10.527292+00:00',
        'type': 'instance',
        'user_id': '517bcd700274432d96f43616ac1e37ea'}]

  .. group-tab:: cURL

    Example JSON payload (save this as ``payload.json``):

    .. code-block:: json

      {
        "and": [
          {">=": {"started_at": "2025-07-01T00:00:00+00:00"}},
          {"<": {"started_at": "2025-08-01T00:00:00+00:00"}}
        ]
      }

    Make the following request:

    .. code-block:: bash

      curl -s \
           -X POST \
           -H "X-Auth-Token: ${OS_TOKEN}" \
           -H "Content-Type: application/json" \
           -H "Accept: application/json" \
           https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/search/resource/instance \
           --data-binary "@payload.json"

    Example output:

    .. code-block:: console

      $ curl -s -X POST -H "X-Auth-Token: ${OS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/search/resource/instance ---data-binary "@payload.json" | jq
      [
        {
          "id": "2a50f066-8e1e-44b1-b355-091d88fdac7f",
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:ceecc421f7994cc397380fae5e495179",
          "started_at": "2025-07-23T04:30:10.527292+00:00",
          "revision_start": "2025-07-23T04:30:10.527296+00:00",
          "ended_at": null,
          "user_id": "517bcd700274432d96f43616ac1e37ea",
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "original_resource_id": "2a50f066-8e1e-44b1-b355-091d88fdac7f",
          "type": "instance",
          "display_name": "test-instance-20250723",
          "image_ref": "ec8c7806-19d2-4791-b503-d6cdd2414187",
          "flavor_id": "28153197-6690-4485-9dbc-fc24489b0683",
          "server_group": null,
          "flavor_name": "c1.c1r1",
          "os_distro": "ubuntu",
          "os_type": "linux",
          "host": null,
          "revision_end": null,
          "metrics": {
            "compute.instance.booting.time": "2f3fc7d3-60f9-41cb-93b8-4d08d2a9bdd1",
            "cpu": "afa729d2-3877-4589-88d7-f5da9debad46",
            "disk.ephemeral.size": "4cdb7ab7-7799-46fe-b317-efa892a8b2a1",
            "disk.root.size": "4e01f69c-ed8a-4ffc-9675-20f9c8538088",
            "instance": "4cf621c4-bc18-47ea-a580-e33fcc94ce49",
            "memory": "5a13e69e-e79e-4a69-b1e2-9f1f2075e279",
            "vcpus": "44576b05-786e-421a-ae42-98de5872327f"
          },
          "created_by_user_id": "42dcfd23b04a4006b9e2b08c0a835aeb",
          "created_by_project_id": "ceecc421f7994cc397380fae5e495179"
        }
      ]
