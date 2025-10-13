In this example we show how get the size of all existing
block storage volumes in your project for a given hour.

This kind of request would be useful for plotting the
usage trends of each volume in a graph.

.. tabs::

  .. group-tab:: OpenStack CLI

    Here are the commands we will run:

    .. code-block:: bash

      start="2025-08-09T00:00:00+00:00"
      stop="2025-08-09T01:00:00+00:00"
      openstack metric aggregates --start "${start}" \
                                  --stop "${stop}" \
                                  --resource-type volume \
                                  --granularity 3600 \
                                  "(metric volume.size max)" \
                                  "started_at<'${stop}' and (ended_at>='${start}' or ended_at=null)"

    With the variables evaluated, this is what it looks like:

    .. code-block:: bash

      openstack metric aggregates --start "2025-08-09T00:00:00+00:00" \
                                  --stop "2025-08-09T01:00:00+00:00" \
                                  --resource-type volume \
                                  --granularity 3600 \
                                  "(metric volume.size max)" \
                                  "started_at<'2025-08-09T01:00:00+00:00' and (ended_at>='2025-08-09T00:00:00+00:00' or ended_at=null)"

    Example output:

    .. code-block:: console

      $ openstack metric aggregates --start "2025-08-09T00:00:00+00:00" --stop "2025-08-09T01:00:00+00:00" --resource-type volume --granularity 3600 "(metric volume.size max)" "started_at<'2025-08-09T01:00:00+00:00' and (ended_at>='2025-08-09T00:00:00+00:00' or ended_at=null)"
      +------------------------------------------------------+---------------------------+-------------+-------+
      | name                                                 | timestamp                 | granularity | value |
      +------------------------------------------------------+---------------------------+-------------+-------+
      | c8b2efc5-fb26-4bf8-851a-05f141b2f6f5/volume.size/max | 2025-08-09T00:00:00+00:00 |      3600.0 |  10.0 |
      | fadcd6d9-5e1f-44ee-9957-f4139f87e437/volume.size/max | 2025-08-09T00:00:00+00:00 |      3600.0 |   1.0 |
      +------------------------------------------------------+---------------------------+-------------+-------+

  .. group-tab:: Python Client

    Run the following code:

    .. code-block:: python

      start = "2025-08-09T00:00:00+00:00"
      stop = "2025-08-09T01:00:00+00:00"
      gnocchi_client.aggregates.fetch(
          operations=["metric", "volume.size", "max"],
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
      >>> stop = "2025-08-09T01:00:00+00:00"
      >>> pprint(gnocchi_client.aggregates.fetch(
      ...     operations=["metric", "volume.size", "max"],
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
      {'measures': {'4ee78fdc-6682-4023-8fb1-a9abc70bd8aa': {'volume.size': {'max': [(datetime.datetime(2025, 8, 9, 0, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                                                                      3600.0,
                                                                                      10.0)]}},
                    'fadcd6d9-5e1f-44ee-9957-f4139f87e437': {'volume.size': {'max': [(datetime.datetime(2025, 8, 9, 0, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                                                                      3600.0,
                                                                                      1.0)]}}}}

  .. group-tab:: cURL

    First, save a file containing the request payload.

    .. code-block:: bash

      start="2025-08-09T00:00:00+00:00"
      stop="2025-08-09T01:00:00+00:00"
      cat > payload.json << EOF
      {
        "operations": ["metric", "volume.size", "max"],
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
        "operations": ["metric", "volume.size", "max"],
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
          "c8b2efc5-fb26-4bf8-851a-05f141b2f6f5": {
            "volume.size": {
              "max": [
                [
                  "2025-08-09T00:00:00+00:00",
                  3600.0,
                  10.0
                ]
              ]
            }
          },
          "fadcd6d9-5e1f-44ee-9957-f4139f87e437": {
            "volume.size": {
              "max": [
                [
                  "2025-08-09T00:00:00+00:00",
                  3600.0,
                  1.0
                ]
              ]
            }
          }
        }
      }
