This example shows how to get more details for a resource :ref:`metric <metrics-metrics>` by name.

.. note::

  Metrics can only be fetched using their own unique ID, or by name in combination with a resource ID.

  Fetching metrics only by name is not supported.

.. tabs::

  .. group-tab:: OpenStack CLI

    Run the following command:

    .. code-block:: bash

      openstack metric show --resource-id ${resource_id} ${metric_name}

    Example output:

    .. code-block:: console

      $ openstack metric show --resource-id af6b97d9-d172-4e06-b565-db1e97097340 cpu
      +--------------------------------+-------------------------------------------------------------------+
      | Field                          | Value                                                             |
      +--------------------------------+-------------------------------------------------------------------+
      | id                             | 6febda4a-4a3f-485f-b6e2-5f94d55e39b0                              |
      | creator                        | 42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d |
      | name                           | cpu                                                               |
      | unit                           | ns                                                                |
      | archive_policy/name            | met1.telemetry-high-rate                                          |
      | resource/id                    | af6b97d9-d172-4e06-b565-db1e97097340                              |
      | resource/creator               | 42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d |
      | resource/started_at            | 2025-03-18T02:16:55.790609+00:00                                  |
      | resource/revision_start        | 2025-03-18T22:00:58.683260+00:00                                  |
      | resource/ended_at              | None                                                              |
      | resource/user_id               | 517bcd700274432d96f43616ac1e37ea                                  |
      | resource/project_id            | 9864e20f92ef47238becfe06b869d2ac                                  |
      | resource/original_resource_id  | af6b97d9-d172-4e06-b565-db1e97097340                              |
      | resource/type                  | instance                                                          |
      | resource/revision_end          | None                                                              |
      | resource/created_by_user_id    | 42dcfd23b04a4006b9e2b08c0a835aeb                                  |
      | resource/created_by_project_id | 70d50fbf0c2148689aa2c319351e634d                                  |
      +--------------------------------+-------------------------------------------------------------------+

  .. group-tab:: Python Client

    Call the following method:

    .. code-block:: python

      gnocchi_client.metric.get("{metric_name}", resource_id="{resource_id}")

    Example output:

    .. code-block:: python

      >>> pprint(gnocchi_client.metric.get("cpu", resource_id="af6b97d9-d172-4e06-b565-db1e97097340"))
      {'archive_policy': {'aggregation_methods': ['rate:mean', 'mean'],
                          'back_window': 0,
                          'definition': [{'granularity': '0:01:00',
                                          'points': 7200,
                                          'timespan': '5 days, 0:00:00'},
                                         {'granularity': '0:10:00',
                                          'points': 4320,
                                          'timespan': '30 days, 0:00:00'},
                                         {'granularity': '1:00:00',
                                          'points': 2160,
                                          'timespan': '90 days, 0:00:00'}],
                          'name': 'met1.telemetry-high-rate'},
      'created_by_project_id': '70d50fbf0c2148689aa2c319351e634d',
      'created_by_user_id': '42dcfd23b04a4006b9e2b08c0a835aeb',
      'creator': '42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d',
      'id': '6febda4a-4a3f-485f-b6e2-5f94d55e39b0',
      'name': 'cpu',
      'resource': {'created_by_project_id': '70d50fbf0c2148689aa2c319351e634d',
                   'created_by_user_id': '42dcfd23b04a4006b9e2b08c0a835aeb',
                   'creator': '42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d',
                   'ended_at': None,
                   'id': 'af6b97d9-d172-4e06-b565-db1e97097340',
                   'original_resource_id': 'af6b97d9-d172-4e06-b565-db1e97097340',
                   'project_id': '9864e20f92ef47238becfe06b869d2ac',
                   'revision_end': None,
                   'revision_start': '2025-03-18T22:00:58.683260+00:00',
                   'started_at': '2025-03-18T02:16:55.790609+00:00',
                   'type': 'instance',
                   'user_id': '517bcd700274432d96f43616ac1e37ea'},
      'unit': 'ns'}

  .. group-tab:: cURL

    Make the following request:

    .. code-block:: bash

      curl -s \
           -H "X-Auth-Token: ${OS_TOKEN}" \
           -H "Accept: application/json" \
           https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/resource/${resource_type}/${resource_id}/metric/${metric_name}

    Example output:

    .. code-block:: console

      $ curl -s -H "X-Auth-Token: ${OS_TOKEN}" -H "Accept: application/json" https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/resource/instance/af6b97d9-d172-4e06-b565-db1e97097340/metric/cpu | jq
      {
        "id": "6febda4a-4a3f-485f-b6e2-5f94d55e39b0",
        "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
        "name": "cpu",
        "unit": "ns",
        "resource": {
          "id": "af6b97d9-d172-4e06-b565-db1e97097340",
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
          "started_at": "2025-03-18T02:16:55.790609+00:00",
          "revision_start": "2025-03-18T22:00:58.683260+00:00",
          "ended_at": null,
          "user_id": "517bcd700274432d96f43616ac1e37ea",
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "original_resource_id": "af6b97d9-d172-4e06-b565-db1e97097340",
          "type": "instance",
          "revision_end": null,
          "created_by_user_id": "42dcfd23b04a4006b9e2b08c0a835aeb",
          "created_by_project_id": "70d50fbf0c2148689aa2c319351e634d"
        },
        "archive_policy": {
          "name": "met1.telemetry-high-rate",
          "back_window": 0,
          "definition": [
            {
              "timespan": "5 days, 0:00:00",
              "granularity": "0:01:00",
              "points": 7200
            },
            {
              "timespan": "30 days, 0:00:00",
              "granularity": "0:10:00",
              "points": 4320
            },
            {
              "timespan": "90 days, 0:00:00",
              "granularity": "1:00:00",
              "points": 2160
            }
          ],
          "aggregation_methods": [
            "rate:mean",
            "mean"
          ]
        },
        "created_by_user_id": "42dcfd23b04a4006b9e2b08c0a835aeb",
        "created_by_project_id": "70d50fbf0c2148689aa2c319351e634d"
      }
