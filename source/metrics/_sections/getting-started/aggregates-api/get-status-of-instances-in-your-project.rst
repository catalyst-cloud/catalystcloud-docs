In this example we show how to query the status of running instances in your project.

This is also possible by just listing all instances in your project using
the Compute API directly, but using the Metrics Service instead allows you
to query the status of instances at an arbitrary point in time in the past,
not just the current status of instances at the time the search query is made.
The Metrics Service also has more extensive options for filtering the results
of search queries.

This uses the ``instance`` metric, which is an integer representation of the
``status`` attribute of a compute instance. The measure values
:ref:`correspond to a specific instance status <metrics-instance-status>`.
For more information, see the Metrics Service documentation for the
:ref:`compute instance resource type <metrics-instances>`.

Similar queries can be made for resources of other types.
For more information on the available resource types and
their status metrics, see the :ref:`metrics-reference`.

.. tabs::

  .. group-tab:: OpenStack CLI

    Here are the commands we will run:

    .. code-block:: bash

      start="2025-08-09T00:00:00+00:00"
      stop="2025-08-09T01:00:00+00:00"
      openstack metric aggregates --start "${start}" \
                                  --stop "${stop}" \
                                  --resource-type instance \
                                  --granularity 600 \
                                  "(metric instance last)" \
                                  "started_at<'${stop}' and (ended_at>='${start}' or ended_at=null)"

    With the variables evaluated, this is what it looks like:

    .. code-block:: bash

      openstack metric aggregates --start "2025-08-09T00:00:00+00:00" \
                                  --stop "2025-08-09T01:00:00+00:00" \
                                  --resource-type instance \
                                  --granularity 600 \
                                  "(metric instance last)" \
                                  "started_at<'2025-08-09T01:00:00+00:00' and (ended_at>='2025-08-09T00:00:00+00:00' or ended_at=null)"

    Example output:

    .. code-block:: console

      $ openstack metric aggregates --start "2025-08-09T00:00:00+00:00" --stop "2025-08-09T01:00:00+00:00" --resource-type instance --granularity 600 "(metric instance last)" "started_at<'2025-08-09T01:00:00+00:00' and (ended_at>='2025-08-09T00:00:00+00:00' or ended_at=null)"
      +----------------------------------------------------+---------------------------+-------------+-------+
      | name                                               | timestamp                 | granularity | value |
      +----------------------------------------------------+---------------------------+-------------+-------+
      | af6b97d9-d172-4e06-b565-db1e97097340/instance/last | 2025-08-09T00:00:00+00:00 |       600.0 |   1.0 |
      | af6b97d9-d172-4e06-b565-db1e97097340/instance/last | 2025-08-09T00:10:00+00:00 |       600.0 |   1.0 |
      | af6b97d9-d172-4e06-b565-db1e97097340/instance/last | 2025-08-09T00:20:00+00:00 |       600.0 |   1.0 |
      | af6b97d9-d172-4e06-b565-db1e97097340/instance/last | 2025-08-09T00:30:00+00:00 |       600.0 |   1.0 |
      | af6b97d9-d172-4e06-b565-db1e97097340/instance/last | 2025-08-09T00:40:00+00:00 |       600.0 |   1.0 |
      | af6b97d9-d172-4e06-b565-db1e97097340/instance/last | 2025-08-09T00:50:00+00:00 |       600.0 |   1.0 |
      | 054c7b9c-1560-4a52-8e83-dddb6a3de291/instance/last | 2025-08-09T00:00:00+00:00 |       600.0 |   1.0 |
      | 054c7b9c-1560-4a52-8e83-dddb6a3de291/instance/last | 2025-08-09T00:10:00+00:00 |       600.0 |   1.0 |
      | 054c7b9c-1560-4a52-8e83-dddb6a3de291/instance/last | 2025-08-09T00:20:00+00:00 |       600.0 |   1.0 |
      | 054c7b9c-1560-4a52-8e83-dddb6a3de291/instance/last | 2025-08-09T00:30:00+00:00 |       600.0 |   1.0 |
      | 054c7b9c-1560-4a52-8e83-dddb6a3de291/instance/last | 2025-08-09T00:40:00+00:00 |       600.0 |   1.0 |
      | 054c7b9c-1560-4a52-8e83-dddb6a3de291/instance/last | 2025-08-09T00:50:00+00:00 |       600.0 |   1.0 |
      +----------------------------------------------------+---------------------------+-------------+-------+

  .. group-tab:: Python Client

    Run the following code:

    .. code-block:: python

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
                                                                                    1.0)]}},
                    '054c7b9c-1560-4a52-8e83-dddb6a3de291': {'instance': {'last': [(datetime.datetime(2025, 8, 9, 0, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
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
                                                                                    1.0)]}}}}

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

      curl -s \
           -X POST \
           -H "X-Auth-Token: ${OS_TOKEN}" \
           -H "Content-Type: application/json" \
           -H "Accept: application/json" \
           https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/aggregates \
           --url-query "start=${start}" \
           --url-query "stop=${stop}" \
           --url-query "granularity=600" \
           --data-binary "@payload.json"

    Example output:

    .. code-block:: console

      $ curl -s -X POST -H "X-Auth-Token: ${OS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/aggregates --url-query "start=${start}" --url-query "stop=${stop}" --url-query "granularity=600" --data-binary "@payload.json" | jq
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
          },
          "054c7b9c-1560-4a52-8e83-dddb6a3de291": {
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
        }
      }

Additional search filters can be defined to limit the results to certain
types of instances, e.g. instances that use GPU-accelerated flavours.

.. tabs::

  .. group-tab:: OpenStack CLI

    Here are the commands we will run:

    .. code-block:: bash

      start="2025-08-09T00:00:00+00:00"
      stop="2025-08-09T01:00:00+00:00"
      openstack metric aggregates --start "${start}" \
                                  --stop "${stop}" \
                                  --resource-type instance \
                                  --granularity 600 \
                                  "(metric instance last)" \
                                  "started_at<'${stop}' and (ended_at>='${start}' or ended_at=null)"

    With the variables evaluated, this is what it looks like:

    .. code-block:: bash

      openstack metric aggregates --start "2025-08-09T00:00:00+00:00" \
                                  --stop "2025-08-09T01:00:00+00:00" \
                                  --resource-type instance \
                                  --granularity 600 \
                                  "(metric instance last)" \
                                  "flavor_name like 'c%-gpu.%' and started_at<'2025-08-09T01:00:00+00:00' and (ended_at>='2025-08-09T00:00:00+00:00' or ended_at=null)"

    Example output:

    .. code-block:: console

      $ openstack metric aggregates --start "2025-08-09T00:00:00+00:00" --stop "2025-08-09T01:00:00+00:00" --resource-type instance --granularity 600 "(metric instance last)" "flavor_name like 'c%-gpu.%' and started_at<'2025-08-09T01:00:00+00:00' and (ended_at>='2025-08-09T00:00:00+00:00' or ended_at=null)"
      +----------------------------------------------------+---------------------------+-------------+-------+
      | name                                               | timestamp                 | granularity | value |
      +----------------------------------------------------+---------------------------+-------------+-------+
      | 054c7b9c-1560-4a52-8e83-dddb6a3de291/instance/last | 2025-08-09T00:00:00+00:00 |       600.0 |   1.0 |
      | 054c7b9c-1560-4a52-8e83-dddb6a3de291/instance/last | 2025-08-09T00:10:00+00:00 |       600.0 |   1.0 |
      | 054c7b9c-1560-4a52-8e83-dddb6a3de291/instance/last | 2025-08-09T00:20:00+00:00 |       600.0 |   1.0 |
      | 054c7b9c-1560-4a52-8e83-dddb6a3de291/instance/last | 2025-08-09T00:30:00+00:00 |       600.0 |   1.0 |
      | 054c7b9c-1560-4a52-8e83-dddb6a3de291/instance/last | 2025-08-09T00:40:00+00:00 |       600.0 |   1.0 |
      | 054c7b9c-1560-4a52-8e83-dddb6a3de291/instance/last | 2025-08-09T00:50:00+00:00 |       600.0 |   1.0 |
      +----------------------------------------------------+---------------------------+-------------+-------+

  .. group-tab:: Python Client

    Run the following code:

    .. code-block:: python

      start = "2025-08-09T00:00:00+00:00"
      stop = "2025-08-09T01:00:00+00:00"
      gnocchi_client.aggregates.fetch(
          operations=["metric", "instance", "last"],
          search={
              "and": [
                  {"like": {"flavor_name": "c%-gpu.%"}},
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
      )

    Example output:

    .. code-block:: python

      >>> start = "2025-08-09T00:00:00+00:00"
      >>> stop = "2025-08-09T01:00:00+00:00"
      >>> pprint(gnocchi_client.aggregates.fetch(
      ...     operations=["metric", "instance", "last"],
      ...     search={
      ...         "and": [
      ...             {"like": {"flavor_name": "c%-gpu.%"}},
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
      ... ))
      {'measures': {'054c7b9c-1560-4a52-8e83-dddb6a3de291': {'instance': {'last': [(datetime.datetime(2025, 8, 9, 0, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
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
                                                                                    1.0)]}}}}

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
            {"like": {"flavor_name": "c%-gpu.%"}},
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
            {"like": {"flavor_name": "c%-gpu.%"}},
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

      curl -s \
           -X POST \
           -H "X-Auth-Token: ${OS_TOKEN}" \
           -H "Content-Type: application/json" \
           -H "Accept: application/json" \
           https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/aggregates \
           --url-query "start=${start}" \
           --url-query "stop=${stop}" \
           --url-query "granularity=600" \
           --data-binary "@payload.json"

    Example output:

    .. code-block:: console

      $ curl -s -X POST -H "X-Auth-Token: ${OS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/aggregates --url-query "start=${start}" --url-query "stop=${stop}" --url-query "granularity=600" --data-binary "@payload.json" | jq
      {
        "measures": {
          "054c7b9c-1560-4a52-8e83-dddb6a3de291": {
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
        }
      }

You can also perform this query
:ref:`with resource details <metrics-aggregates-api-with-resource-details>`,
to return the metadata for the found instances in the same query.

.. tabs::

  .. group-tab:: OpenStack CLI

    This functionality is not available using the OpenStack CLI.

  .. group-tab:: Python Client

    Run the following code:

    .. code-block:: python

      start = "2025-08-09T00:00:00+00:00"
      stop = "2025-08-09T01:00:00+00:00"
      gnocchi_client.aggregates.fetch(
          operations=["metric", "instance", "last"],
          search={
              "and": [
                  {"like": {"flavor_name": "c%-gpu.%"}},
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
      ...             {"like": {"flavor_name": "c%-gpu.%"}},
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
      {'measures': {'054c7b9c-1560-4a52-8e83-dddb6a3de291': {'instance': {'last': [(datetime.datetime(2025, 8, 9, 0, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
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
                       'display_name': 'test-instance-gpu',
                       'ended_at': None,
                       'flavor_id': 'feed34b8-25e2-435d-b49b-eba449f389dc',
                       'flavor_name': 'c3-gpu.c24r96g1',
                       'host': None,
                       'id': '054c7b9c-1560-4a52-8e83-dddb6a3de291',
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
                       'original_resource_id': '054c7b9c-1560-4a52-8e83-dddb6a3de291',
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
            {"like": {"flavor_name": "c%-gpu.%"}},
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
            {"like": {"flavor_name": "c%-gpu.%"}},
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
          "054c7b9c-1560-4a52-8e83-dddb6a3de291": {
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
            "display_name": "test-instance-gpu",
            "ended_at": null,
            "flavor_id": "feed34b8-25e2-435d-b49b-eba449f389dc",
            "flavor_name": "c3-gpu.c24r96g1",
            "host": null,
            "id": "054c7b9c-1560-4a52-8e83-dddb6a3de291",
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
            "original_resource_id": "054c7b9c-1560-4a52-8e83-dddb6a3de291",
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
