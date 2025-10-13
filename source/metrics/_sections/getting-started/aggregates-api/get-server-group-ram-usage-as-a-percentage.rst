In this example we show how to get the 10 minute mean RAM usage
across instances in a :ref:`server group <anti-affinity>` as a
singular decimal percentage (0-1).

The query takes into account the mean amount of memory
each instance ran with in each aggregated datapoint, to allow
:ref:`instance resizes <resize-server>` to be handled gracefully.

.. tabs::

  .. group-tab:: OpenStack CLI

    Here are the commands we will run:

    .. code-block:: bash

      server_group_id="7a612ef2-ad1d-49fa-a72d-51253761cdda"
      start="2025-08-09T00:00:00+00:00"
      stop="2025-08-09T01:00:00+00:00"
      granularity=600
      openstack metric aggregates --start "${start}" \
                                  --stop "${stop}" \
                                  --resource-type instance \
                                  --granularity ${granularity} \
                                  "(/ (metric memory.usage mean) (metric memory.available mean))" \
                                  "server_group='${server_group_id}' and (started_at<'${stop}' and (ended_at>='${start}' or ended_at=null))"

    With the variables evaluated, this is what it looks like:

    .. code-block:: bash

      openstack metric aggregates --start "2025-08-09T00:00:00+00:00" \
                                  --stop "2025-08-09T01:00:00+00:00" \
                                  --resource-type instance \
                                  --granularity 600 \
                                  "(/ (metric memory.usage mean) (metric memory.available mean))" \
                                  "server_group='7a612ef2-ad1d-49fa-a72d-51253761cdda' and (started_at<'2025-08-09T01:00:00+00:00' and (ended_at>='2025-08-09T00:00:00+00:00' or ended_at=null))"

    Example output:

    .. code-block:: console

      $ openstack metric aggregates --start "2025-08-09T00:00:00+00:00" --stop "2025-08-09T01:00:00+00:00" --resource-type instance --granularity 600 "(/ (metric memory.usage mean) (metric memory.available mean))" "server_group='7a612ef2-ad1d-49fa-a72d-51253761cdda' and (started_at<'2025-08-09T01:00:00+00:00' and (ended_at>='2025-08-09T00:00:00+00:00' or ended_at=null))"
      +------------+---------------------------+-------------+---------------------+
      | name       | timestamp                 | granularity |               value |
      +------------+---------------------------+-------------+---------------------+
      | aggregated | 2025-08-09T00:00:00+00:00 |       600.0 | 0.32466181061394384 |
      | aggregated | 2025-08-09T00:10:00+00:00 |       600.0 | 0.32362122788761705 |
      | aggregated | 2025-08-09T00:20:00+00:00 |       600.0 | 0.32362122788761705 |
      | aggregated | 2025-08-09T00:30:00+00:00 |       600.0 | 0.32362122788761705 |
      | aggregated | 2025-08-09T00:40:00+00:00 |       600.0 | 0.32362122788761705 |
      | aggregated | 2025-08-09T00:50:00+00:00 |       600.0 |  0.3537981269510926 |
      +------------+---------------------------+-------------+---------------------+

  .. group-tab:: Python Client

    Run the following code:

    .. code-block:: python

      server_group_id = "7a612ef2-ad1d-49fa-a72d-51253761cdda"
      start = "2025-08-09T00:00:00+00:00"
      stop = "2025-08-09T01:00:00+00:00"
      granularity = 600
      gnocchi_client.aggregates.fetch(
          operations=[
              "/",
              ["metric", "memory.usage", "mean"],
              ["metric", "memory.available", "mean"],
          ],
          search={
              "and": [
                  {"=": {"server_group": server_group_id}},
                  {
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
              ],
          },
          resource_type="instance",
          start=start,
          stop=stop,
          granularity=granularity,
      )

    Example output:

    .. code-block:: python

      >>> server_group_id = "7a612ef2-ad1d-49fa-a72d-51253761cdda"
      >>> start = "2025-08-09T00:00:00+00:00"
      >>> stop = "2025-08-09T01:00:00+00:00"
      >>> granularity = 600
      >>> pprint(gnocchi_client.aggregates.fetch(
      ...     operations=[
      ...         "/",
      ...         ["metric", "memory.usage", "mean"],
      ...         ["metric", "memory.available", "mean"],
      ...     ],
      ...     search={
      ...         "and": [
      ...             {"=": {"server_group": server_group_id}},
      ...             {
      ...                 "and": [
      ...                     {"<": {"started_at": stop}},
      ...                     {
      ...                         "or": [
      ...                             {">=": {"ended_at": start}},
      ...                             {"=": {"ended_at": None}},
      ...                         ],
      ...                     },
      ...                 ],
      ...             },
      ...         ],
      ...     },
      ...     resource_type="instance",
      ...     start=start,
      ...     stop=stop,
      ...     granularity=granularity,
      ... ))
      {'measures': {'aggregated': [(datetime.datetime(2025, 8, 9, 0, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    600.0,
                                    0.32466181061394384),
                                   (datetime.datetime(2025, 8, 9, 0, 10, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    600.0,
                                    0.32362122788761705),
                                   (datetime.datetime(2025, 8, 9, 0, 20, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    600.0,
                                    0.32362122788761705),
                                   (datetime.datetime(2025, 8, 9, 0, 30, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    600.0,
                                    0.32362122788761705),
                                   (datetime.datetime(2025, 8, 9, 0, 40, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    600.0,
                                    0.32362122788761705),
                                   (datetime.datetime(2025, 8, 9, 0, 50, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    600.0,
                                    0.3537981269510926)]}}}}

  .. group-tab:: cURL

    First, save a file containing the request payload.

    .. code-block:: bash

      server_group_id="7a612ef2-ad1d-49fa-a72d-51253761cdda"
      start="2025-08-09T00:00:00+00:00"
      stop="2025-08-09T01:00:00+00:00"
      granularity=600
      cat > payload.json << EOF
      {
        "operations": [
            "/",
            ["metric", "memory.usage", "mean"],
            ["metric", "memory.available", "mean"]
        ],
        "search": {
          "and": [
            {"=": {"server_group": "${server_group_id}"}},
            {
              "and": [
                {"<": {"started_at": "${stop}"}},
                {
                  "or": [
                    {">=": {"ended_at": "${start}"}},
                    {"=": {"ended_at": null}}
                  ]
                }
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
        "operations": [
            "/",
            ["metric", "memory.usage", "mean"],
            ["metric", "memory.available", "mean"]
        ],
        "search": {
          "and": [
            {"=": {"server_group": "7a612ef2-ad1d-49fa-a72d-51253761cdda"}},
            {
              "and": [
                {"<": {"started_at": "2025-08-09T01:00:00+00:00"}},
                {
                  "or": [
                    {">=": {"ended_at": "2025-08-09T00:00:00+00:00"}},
                    {"=": {"ended_at": null}}
                  ]
                }
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
           --url-query "granularity=${granularity}" \
           --data-binary "@payload.json"

    Example output:

    .. code-block:: console

      $ curl -s -X POST -H "X-Auth-Token: ${OS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/aggregates --url-query "start=${start}" --url-query "stop=${stop}" --url-query "granularity=${granularity}" --data-binary "@payload.json" | jq
      {
        "measures": {
          "aggregated": [
            [
              "2025-08-09T00:00:00+00:00",
              600.0,
              0.32466181061394384
            ],
            [
              "2025-08-09T00:10:00+00:00",
              600.0,
              0.32362122788761705
            ],
            [
              "2025-08-09T00:20:00+00:00",
              600.0,
              0.32362122788761705
            ],
            [
              "2025-08-09T00:30:00+00:00",
              600.0,
              0.32362122788761705
            ],
            [
              "2025-08-09T00:40:00+00:00",
              600.0,
              0.32362122788761705
            ],
            [
              "2025-08-09T00:50:00+00:00",
              600.0,
              0.3537981269510926
            ]
          ]
        }
      }
