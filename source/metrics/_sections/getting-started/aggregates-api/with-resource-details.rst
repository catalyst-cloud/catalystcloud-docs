You can append the current metadata of matching resources to any aggregate query using the ``details`` option.

This allows you to get both resource details and aggregations in a single query,
saving potentially multiple additional requests to get the metadata of found resources.

.. tabs::

  .. group-tab:: OpenStack CLI

    This functionality is not available using the OpenStack CLI.

  .. group-tab:: Python Client

    Run the following code:

    .. code-block:: python
      :emphasize-lines: 19

      start = "2025-08-09T00:00:00+00:00"
      stop = "2025-08-09T01:00:00+00:00"
      granularity = 600
      gnocchi_client.aggregates.fetch(
          operations=[
              "/",
              [
                  "/",
                  ["metric", "cpu", "rate:mean"],
                  ["metric", "vcpus", "mean"],
              ],
              1000000000 * granularity,
          ],
          search={"=": {"id": "af6b97d9-d172-4e06-b565-db1e97097340"}},
          resource_type="instance",
          start=start,
          stop=stop,
          granularity=granularity,
          details=True,
      )

    Example output:

    .. code-block:: python

      >>> start = "2025-08-09T00:00:00+00:00"
      >>> stop = "2025-08-09T01:00:00+00:00"
      >>> granularity = 600
      >>> pprint(gnocchi_client.aggregates.fetch(
      ...     operations=[
      ...         "/",
      ...         [
      ...             "/",
      ...             ["metric", "cpu", "rate:mean"],
      ...             ["metric", "vcpus", "mean"],
      ...         ],
      ...         1000000000 * granularity,
      ...     ],
      ...     search={"=": {"id": "af6b97d9-d172-4e06-b565-db1e97097340"}},
      ...     resource_type="instance",
      ...     start=start,
      ...     stop=stop,
      ...     granularity=granularity,
      ...     details=True,
      ... ))
      {'measures': {'aggregated': [(datetime.datetime(2025, 8, 9, 0, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    600.0,
                                    0.18333333333333332),
                                   (datetime.datetime(2025, 8, 9, 0, 10, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    600.0,
                                    0.14),
                                   (datetime.datetime(2025, 8, 9, 0, 20, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    600.0,
                                    0.14666666666666667),
                                   (datetime.datetime(2025, 8, 9, 0, 30, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    600.0,
                                    0.14666666666666667),
                                   (datetime.datetime(2025, 8, 9, 0, 40, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    600.0,
                                    0.13833333333333334),
                                   (datetime.datetime(2025, 8, 9, 0, 50, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    600.0,
                                    0.14333333333333334)]}}}},
       'references': [{'created_by_project_id': '70d50fbf0c2148689aa2c319351e634d',
                       'created_by_user_id': '42dcfd23b04a4006b9e2b08c0a835aeb',
                       'creator': '42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d',
                       'display_name': 'test-instance',
                       'ended_at': None,
                       'flavor_id': '28153197-6690-4485-9dbc-fc24489b0683',
                       'flavor_name': 'c1.c1r1',
                       'host': None,
                       'id': 'af6b97d9-d172-4e06-b565-db1e97097340',
                       'image_ref': None,
                       'metrics': {'compute.instance.booting.time': 'c418003f-5115-4bd3-a56e-270d90e26b2f',
                                   'cpu': '6febda4a-4a3f-485f-b6e2-5f94d55e39b0',
                                   'disk.ephemeral.size': 'd0add36c-6208-40d3-a8d0-2f5ab3a550bd',
                                   'disk.root.size': 'b4e3d818-444b-46a9-b874-c82fd78e3a66',
                                   'instance': '53c46abc-5336-49a8-ac76-fc5aed5e5154',
                                   'memory': '1e87f21e-2238-41f0-80fd-950e3e2f9bcf',
                                   'vcpus': '9d60abe7-b1d7-425d-8d89-6c0eecd38c47'},
                       'original_resource_id': 'af6b97d9-d172-4e06-b565-db1e97097340',
                       'os_distro': 'ubuntu',
                       'os_type': 'linux',
                       'project_id': '9864e20f92ef47238becfe06b869d2ac',
                       'revision_end': None,
                       'revision_start': '2025-03-18T22:00:58.683260+00:00',
                       'server_group': None,
                       'started_at': '2025-03-18T02:16:55.790609+00:00',
                       'type': 'instance',
                       'user_id': '517bcd700274432d96f43616ac1e37ea'}]}

  .. group-tab:: cURL

    First, save a file containing the request payload.

    .. code-block:: bash

      start="2025-08-09T00:00:00+00:00"
      stop="2025-08-09T01:00:00+00:00"
      granularity=600
      cat > payload.json << EOF
      {
        "operations": [
          "/",
          [
            "/",
            ["metric", "cpu", "rate:mean"],
            ["metric", "vcpus", "mean"]
          ],
          $(echo "1000000000 * $granularity" | bc)
        ],
        "search": {"=": {"id": "af6b97d9-d172-4e06-b565-db1e97097340"}},
        "resource_type": "instance"
      }
      EOF

    Here is what the payload should look like:

    .. code-block:: json

      {
        "operations": [
          "/",
          [
            "/",
            ["metric", "cpu", "rate:mean"],
            ["metric", "vcpus", "mean"]
          ],
          600000000000
        ],
        "search": {"=": {"id": "af6b97d9-d172-4e06-b565-db1e97097340"}},
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
           --url-query "granularity=${granularity}" \
           --url-query "details=true" \
           --data-binary "@payload.json"

    Example output:

    .. code-block:: console

      $ curl -s -X POST -H "X-Auth-Token: ${OS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/aggregates --url-query "start=${start}" --url-query "stop=${stop}" --url-query "granularity=${granularity}" --url-query "details=true" --data-binary "@payload.json" | jq
      {
        "measures": {
          "aggregated": [
            [
              "2025-08-09T00:00:00+00:00",
              600.0,
              0.0018333333333333333
            ],
            [
              "2025-08-09T00:10:00+00:00",
              600.0,
              0.0014
            ],
            [
              "2025-08-09T00:20:00+00:00",
              600.0,
              0.0014666666666666667
            ],
            [
              "2025-08-09T00:30:00+00:00",
              600.0,
              0.0014666666666666667
            ],
            [
              "2025-08-09T00:40:00+00:00",
              600.0,
              0.0013833333333333334
            ],
            [
              "2025-08-09T00:50:00+00:00",
              600.0,
              0.0014333333333333333
            ]
          ]
        },
        "references": [
          {
            "id": "af6b97d9-d172-4e06-b565-db1e97097340",
            "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
            "started_at": "2025-03-18T02:16:55.790609+00:00",
            "revision_start": "2025-03-18T22:00:58.683260+00:00",
            "ended_at": null,
            "user_id": "517bcd700274432d96f43616ac1e37ea",
            "project_id": "9864e20f92ef47238becfe06b869d2ac",
            "original_resource_id": "af6b97d9-d172-4e06-b565-db1e97097340",
            "type": "instance",
            "display_name": "test-instance",
            "image_ref": null,
            "flavor_id": "28153197-6690-4485-9dbc-fc24489b0683",
            "server_group": null,
            "flavor_name": "c1.c1r1",
            "os_distro": "ubuntu",
            "os_type": "linux",
            "host": None,
            "revision_end": null,
            "metrics": {
              "compute.instance.booting.time": "c418003f-5115-4bd3-a56e-270d90e26b2f",
              "cpu": "6febda4a-4a3f-485f-b6e2-5f94d55e39b0",
              "disk.ephemeral.size": "d0add36c-6208-40d3-a8d0-2f5ab3a550bd",
              "disk.root.size": "b4e3d818-444b-46a9-b874-c82fd78e3a66",
              "instance": "53c46abc-5336-49a8-ac76-fc5aed5e5154",
              "memory": "1e87f21e-2238-41f0-80fd-950e3e2f9bcf",
              "vcpus": "9d60abe7-b1d7-425d-8d89-6c0eecd38c47"
            },
            "created_by_user_id": "42dcfd23b04a4006b9e2b08c0a835aeb",
            "created_by_project_id": "70d50fbf0c2148689aa2c319351e634d"
          }
        ]
      }
