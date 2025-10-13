In this example we show how to get the total amount of block storage
being consumed in your project on an hourly basis over 1 day as a single figure.

.. tabs::

  .. group-tab:: OpenStack CLI

    Here are the commands we will run:

    .. code-block:: bash

      start="2025-08-09T00:00:00+00:00"
      stop="2025-08-10T00:00:00+00:00"
      openstack metric aggregates --start "${start}" \
                                  --stop "${stop}" \
                                  --resource-type volume \
                                  --granularity 3600 \
                                  "(aggregate sum (metric volume.size max))" \
                                  "started_at<'${stop}' and (ended_at>='${start}' or ended_at=null)"

    With the variables evaluated, this is what it looks like:

    .. code-block:: bash

      openstack metric aggregates --start "2025-08-09T00:00:00+00:00" \
                                  --stop "2025-08-10T00:00:00+00:00" \
                                  --resource-type volume \
                                  --granularity 3600 \
                                  "(aggregate sum (metric volume.size max))" \
                                  "started_at<'2025-08-10T00:00:00+00:00' and (ended_at>='2025-08-09T00:00:00+00:00' or ended_at=null)"

    Example output:

    .. code-block:: console

      $ openstack metric aggregates --start "2025-08-09T00:00:00+00:00" --stop "2025-08-10T00:00:00+00:00" --resource-type volume --granularity 3600 "(aggregate sum (metric volume.size max))" "started_at<'2025-08-10T00:00:00+00:00' and (ended_at>='2025-08-09T00:00:00+00:00' or ended_at=null)"
      +------------+---------------------------+-------------+-------+
      | name       | timestamp                 | granularity | value |
      +------------+---------------------------+-------------+-------+
      | aggregated | 2025-08-09T00:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T01:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T02:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T03:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T04:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T05:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T06:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T07:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T08:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T09:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T10:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T11:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T12:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T13:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T14:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T15:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T16:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T17:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T18:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T19:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T20:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T21:00:00+00:00 |      3600.0 |  81.0 |
      | aggregated | 2025-08-09T22:00:00+00:00 |      3600.0 |  84.0 |
      | aggregated | 2025-08-09T23:00:00+00:00 |      3600.0 |  84.0 |
      +------------+---------------------------+-------------+-------+

  .. group-tab:: Python Client

    Run the following code:

    .. code-block:: python

      start = "2025-08-09T00:00:00+00:00"
      stop = "2025-08-10T00:00:00+00:00"
      gnocchi_client.aggregates.fetch(
          operations=["aggregate", "sum", ["metric", "volume.size", "max"]],
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
          resource_type="volume",
          start=start,
          stop=stop,
          granularity=3600,
      )

    Example output:

    .. code-block:: python

      >>> start = "2025-08-09T00:00:00+00:00"
      >>> stop = "2025-08-10T00:00:00+00:00"
      >>> pprint(gnocchi_client.aggregates.fetch(
      ...     operations=["aggregate", "sum", ["metric", "volume.size", "max"]],
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
      ...     resource_type="volume",
      ...     start=start,
      ...     stop=stop,
      ...     granularity=3600,
      ... ))
      {'measures': {'aggregated': [(datetime.datetime(2025, 8, 9, 0, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 1, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 2, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 3, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 4, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 5, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 6, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 7, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 8, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 9, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 10, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 11, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 12, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 13, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 14, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 15, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 16, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 17, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 18, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 19, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 20, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 21, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    81.0),
                                   (datetime.datetime(2025, 8, 9, 22, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    84.0),
                                   (datetime.datetime(2025, 8, 9, 23, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    84.0)]}}

  .. group-tab:: cURL

    First, save a file containing the request payload.

    .. code-block:: bash

      start="2025-08-09T00:00:00+00:00"
      stop="2025-08-10T00:00:00+00:00"
      cat > payload.json << EOF
      {
        "operations": ["aggregate", "sum", ["metric", "volume.size", "max"]],
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
        "resource_type": "volume"
      }
      EOF

    Here is what the payload should look like:

    .. code-block:: json

      {
        "operations": ["aggregate", "sum", ["metric", "volume.size", "max"]],
        "search": {
          "and": [
            {"<": {"started_at": "2025-08-10T00:00:00+00:00"}},
            {
              "or": [
                {">=": {"ended_at": "2025-08-09T00:00:00+00:00"}},
                {"=": {"ended_at": null}}
              ]
            }
          ]
        },
        "resource_type": "volume"
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
           --url-query "granularity=3600" \
           --data-binary "@payload.json"

    Example output:

    .. code-block:: console

      $ curl -s -X POST -H "X-Auth-Token: ${OS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/aggregates --url-query "start=${start}" --url-query "stop=${stop}" --url-query "granularity=3600" --data-binary "@payload.json" | jq
      {
        "measures": {
          "aggregated": [
            [
              "2025-08-09T00:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T01:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T02:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T03:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T04:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T05:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T06:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T07:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T08:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T09:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T10:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T11:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T12:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T13:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T14:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T15:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T16:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T17:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T18:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T19:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T20:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T21:00:00+00:00",
              3600.0,
              81.0
            ],
            [
              "2025-08-09T22:00:00+00:00",
              3600.0,
              84.0
            ],
            [
              "2025-08-09T23:00:00+00:00",
              3600.0,
              84.0
            ]
          ]
        }
      }
