You can append the current metadata of matching resources to any aggregate query using the ``details`` option.

This allows you to get both resource details and aggregations in a single query,
saving potentially multiple additional requests to get the metadata of found resources.

.. note::

  Aggregates API queries with resource details will return the **current** state
  of the resource metadata as recorded by the Metrics Service, *not* the state
  of the resource metadata during the time period defined in the query.

  To find what state the metadata was in for resources during a
  given time period, use the :ref:`metrics-resource-history` API.

.. tabs::

  .. group-tab:: OpenStack CLI

    This functionality is not available using the OpenStack CLI.

  .. group-tab:: Python Client

    Run the following code:

    .. code-block:: python
      :emphasize-lines: 19

      start = "2025-08-09T00:00:00+00:00"
      stop = "2025-08-09T01:00:00+00:00"
      gnocchi_client.aggregates.fetch(
          operations=["metric", "instance", "last"],
          search={
              "and": [
                  {"<": {"started_at": stop}},
                  {
                      "or": [
                          {">=": {"ended_at": start}},
                          {"=": {"ended_at": None}},
                      ],
                  },
              ],
          },
          resource_type="instance",
          start=start,
          stop=stop,
          granularity=600,
          details=True,
      )

    Example output:

    .. code-block:: python

      >>> start = "2025-08-09T00:00:00+00:00"
      >>> stop = "2025-08-09T01:00:00+00:00"
      >>> pprint(gnocchi_client.aggregates.fetch(
      ...     operations=["metric", "instance", "last"],
      ...     search={
      ...         "and": [
      ...             {"<": {"started_at": stop}},
      ...             {
      ...                 "or": [
      ...                     {">=": {"ended_at": start}},
      ...                     {"=": {"ended_at": None}},
      ...                 ],
      ...             },
      ...         ],
      ...     },
      ...     resource_type="instance",
      ...     start=start,
      ...     stop=stop,
      ...     granularity=600,
      ...     details=True,
      ... ))
      {'measures': {'af6b97d9-d172-4e06-b565-db1e97097340': {'instance': {'last': [(datetime.datetime(2025, 8, 9, 0, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                                                                    600.0,
                                                                                    1.0),
                                                                                   (datetime.datetime(2025, 8, 9, 0, 10, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                                                                    600.0,
                                                                                    1.0),
                                                                                   (datetime.datetime(2025, 8, 9, 0, 20, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                                                                    600.0,
                                                                                    1.0),
                                                                                   (datetime.datetime(2025, 8, 9, 0, 30, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                                                                    600.0,
                                                                                    1.0),
                                                                                   (datetime.datetime(2025, 8, 9, 0, 40, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                                                                    600.0,
                                                                                    1.0),
                                                                                   (datetime.datetime(2025, 8, 9, 0, 50, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                                                                    600.0,
                                                                                    1.0)]}}},
       'references': [{'created_by_project_id': 'bca23858297d4db7b139fdcf7d9052e7',
                       'created_by_user_id': 'e5c19197e8ec4b988e57ae19369a97e6',
                       'creator': 'e5c19197e8ec4b988e57ae19369a97e6:bca23858297d4db7b139fdcf7d9052e7',
                       'display_name': 'test-instance',
                       'ended_at': None,
                       'flavor_id': '28153197-6690-4485-9dbc-fc24489b0683',
                       'flavor_name': 'c1.c1r1',
                       'host': None,
                       'id': 'af6b97d9-d172-4e06-b565-db1e97097340',
                       'image_ref': '80cd4507-8329-4a32-bb9e-d6105f1c3e72',
                       'metrics': {'compute.instance.booting.time': '09b622fe-2b9c-4755-b0b8-d827f3022a44',
                                   'cpu': 'd8d59f26-c797-41ab-b6e5-352bc018b821',
                                   'disk.root.size': '93fd530e-66cc-41bb-b205-b776e0be249b',
                                   'instance': '63abc108-294c-47f5-8236-cb15ac890598',
                                   'memory': '087a78bf-3e47-4135-9e70-727ec81e0959',
                                   'memory.available': '3f61989f-1501-4b29-9835-4dcb5641e307',
                                   'memory.swap.in': '15bb4ea3-9688-4898-8bc3-94defb285668',
                                   'memory.swap.out': '3c947f0d-adfe-4431-b88a-08660901b942',
                                   'memory.usage': '185c7529-2558-4cf3-9755-477e00ff9e39',
                                   'vcpus': '79186b56-50ea-4cad-896c-378fb8936932'},
                       'original_resource_id': 'af6b97d9-d172-4e06-b565-db1e97097340',
                       'os_distro': 'ubuntu',
                       'os_type': 'linux',
                       'project_id': '9864e20f92ef47238becfe06b869d2ac',
                       'revision_end': None,
                       'revision_start': '2025-08-07T02:07:08.868281+00:00',
                       'server_group': None,
                       'started_at': '2025-08-07T02:07:08.868274+00:00',
                       'type': 'instance',
                       'user_id': '8cc671f237e149888309495fa54d1efc'}]}

  .. group-tab:: cURL

    First, save a file containing the request payload.

    .. code-block:: bash

      start="2025-08-09T00:00:00+00:00"
      stop="2025-08-09T01:00:00+00:00"
      cat > payload.json << EOF
      {
        "operations": ["metric", "instance", "last"],
        "search": {
          "and": [
            {"<": {"started_at": "${stop}"}},
            {
              "or": [
                {">=": {"ended_at": "${start}"}},
                {"=": {"ended_at": null}}
              ]
            }
          ]
        },
        "resource_type": "instance"
      }
      EOF

    Here is what the payload should look like:

    .. code-block:: json

      {
        "operations": ["metric", "instance", "last"],
        "search": {
          "and": [
            {"<": {"started_at": "2025-08-09T01:00:00+00:00"}},
            {
              "or": [
                {">=": {"ended_at": "2025-08-09T00:00:00+00:00"}},
                {"=": {"ended_at": null}}
              ]
            }
          ]
        },
        "resource_type": "instance"
      }

    Now, run the command to make the request.

    .. code-block:: bash
      :emphasize-lines: 10

      curl -s \
           -X POST \
           -H "X-Auth-Token: ${OS_TOKEN}" \
           -H "Content-Type: application/json" \
           -H "Accept: application/json" \
           https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/aggregates \
           --url-query "start=${start}" \
           --url-query "stop=${stop}" \
           --url-query "granularity=600" \
           --url-query "details=true" \
           --data-binary "@payload.json"

    Example output:

    .. code-block:: console

      $ curl -s -X POST -H "X-Auth-Token: ${OS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/aggregates --url-query "start=${start}" --url-query "stop=${stop}" --url-query "granularity=600" --url-query "details=true" --data-binary "@payload.json" | jq
      {
        "measures": {
          "af6b97d9-d172-4e06-b565-db1e97097340": {
            "instance": {
              "last": [
                [
                  "2025-08-09T00:00:00+00:00",
                  600.0,
                  1.0
                ],
                [
                  "2025-08-09T00:10:00+00:00",
                  600.0,
                  1.0
                ],
                [
                  "2025-08-09T00:20:00+00:00",
                  600.0,
                  1.0
                ],
                [
                  "2025-08-09T00:30:00+00:00",
                  600.0,
                  1.0
                ],
                [
                  "2025-08-09T00:40:00+00:00",
                  600.0,
                  1.0
                ],
                [
                  "2025-08-09T00:50:00+00:00",
                  600.0,
                  1.0
                ]
              ]
            }
          }
        },
        "references": [
          {
            "created_by_project_id": "bca23858297d4db7b139fdcf7d9052e7",
            "created_by_user_id": "e5c19197e8ec4b988e57ae19369a97e6",
            "creator": "e5c19197e8ec4b988e57ae19369a97e6:bca23858297d4db7b139fdcf7d9052e7",
            "display_name": "test-instance",
            "ended_at": null,
            "flavor_id": "28153197-6690-4485-9dbc-fc24489b0683",
            "flavor_name": "c1.c1r1",
            "host": null,
            "id": "af6b97d9-d172-4e06-b565-db1e97097340",
            "image_ref": "80cd4507-8329-4a32-bb9e-d6105f1c3e72",
            "metrics": {
              "compute.instance.booting.time": "09b622fe-2b9c-4755-b0b8-d827f3022a44",
              "cpu": "d8d59f26-c797-41ab-b6e5-352bc018b821",
              "disk.root.size": "93fd530e-66cc-41bb-b205-b776e0be249b",
              "instance": "63abc108-294c-47f5-8236-cb15ac890598",
              "memory": "087a78bf-3e47-4135-9e70-727ec81e0959",
              "memory.available": "3f61989f-1501-4b29-9835-4dcb5641e307",
              "memory.swap.in": "15bb4ea3-9688-4898-8bc3-94defb285668",
              "memory.swap.out": "3c947f0d-adfe-4431-b88a-08660901b942",
              "memory.usage": "185c7529-2558-4cf3-9755-477e00ff9e39",
              "vcpus": "79186b56-50ea-4cad-896c-378fb8936932"
            },
            "original_resource_id": "af6b97d9-d172-4e06-b565-db1e97097340",
            "os_distro": "ubuntu",
            "os_type": "linux",
            "project_id": "9864e20f92ef47238becfe06b869d2ac",
            "revision_end": null,
            "revision_start": "2025-08-07T02:07:08.868281+00:00",
            "server_group": null,
            "started_at": "2025-08-07T02:07:08.868274+00:00",
            "type": "instance",
            "user_id": "8cc671f237e149888309495fa54d1efc"
          }
        ]
      }
