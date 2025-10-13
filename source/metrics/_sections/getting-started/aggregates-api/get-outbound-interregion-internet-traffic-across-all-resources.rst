When performing aggregate queries, requests are normally made for a specific resource type,
so to perform queries for multiple resource types you would need to make multiple requests.

By using the special ``generic`` resource type you can perform aggregate queries
across multiple resource types, even across different metrics. This allows you to
get all the metrics you need in a single request, improving performance and saving
bandwidth and round trips.

.. note::

  When performing aggregate API queries
  :ref:`with resource details <metrics-aggregates-api-with-resource-details>`,
  you do not get any metadata specific to certain resource types when using
  the ``generic`` type.

  If you require both detailed resource metadata and aggregates, you will need
  to do one query per resource type.

In this example we show how to get the total outbound inter-region/Internet
network across routers and floating IPs, and object storage traffic for containers,
in a single aggregated time series.

.. tabs::

  .. group-tab:: OpenStack CLI

    Here are the commands we will run:

    .. code-block:: bash

      start="2025-08-09T00:00:00+00:00"
      stop="2025-08-10T00:00:00+00:00"
      openstack metric aggregates --start "${start}" \
                                  --stop "${stop}" \
                                  --resource-type generic \
                                  --granularity 3600 \
                                  "(aggregate sum (metric (router.traffic.outbound.interregion sum) (router.traffic.outbound.internet sum) (ip.floating.traffic.outbound.interregion sum) (ip.floating.traffic.outbound.internet sum) (storage.objects.download.size.interregion sum) (storage.objects.download.size.internet sum)))" \
                                  "started_at<'${stop}' and (ended_at>='${start}' or ended_at=null)"

    With the variables evaluated, this is what it looks like:

    .. code-block:: bash

      openstack metric aggregates --start "2025-08-09T00:00:00+00:00" \
                                  --stop "2025-08-10T00:00:00+00:00" \
                                  --resource-type generic \
                                  --granularity 3600 \
                                  "(aggregate sum (metric (router.traffic.outbound.interregion sum) (router.traffic.outbound.internet sum) (ip.floating.traffic.outbound.interregion sum) (ip.floating.traffic.outbound.internet sum) (storage.objects.download.size.interregion sum) (storage.objects.download.size.internet sum)))" \
                                  "started_at<'2025-08-10T00:00:00+00:00' and (ended_at>='2025-08-09T00:00:00+00:00' or ended_at=null)"

    Example output:

    .. code-block:: console

      $ openstack metric aggregates --start "2025-08-09T00:00:00+00:00" --stop "2025-08-10T00:00:00+00:00" --resource-type generic --granularity 3600 "(aggregate sum (metric (router.traffic.outbound.interregion sum) (router.traffic.outbound.internet sum) (ip.floating.traffic.outbound.interregion sum) (ip.floating.traffic.outbound.internet sum) (storage.objects.download.size.interregion sum) (storage.objects.download.size.internet sum)))" "started_at<'2025-08-10T00:00:00+00:00' and (ended_at>='2025-08-09T00:00:00+00:00' or ended_at=null)"
      +------------+---------------------------+-------------+-----------+
      | name       | timestamp                 | granularity |     value |
      +------------+---------------------------+-------------+-----------+
      | aggregated | 2025-08-09T00:00:00+00:00 |      3600.0 | 4410824.0 |
      | aggregated | 2025-08-09T01:00:00+00:00 |      3600.0 | 3977323.0 |
      | aggregated | 2025-08-09T02:00:00+00:00 |      3600.0 | 3919881.0 |
      | aggregated | 2025-08-09T03:00:00+00:00 |      3600.0 | 4223212.0 |
      | aggregated | 2025-08-09T04:00:00+00:00 |      3600.0 | 4319391.0 |
      | aggregated | 2025-08-09T05:00:00+00:00 |      3600.0 | 4019030.0 |
      | aggregated | 2025-08-09T06:00:00+00:00 |      3600.0 | 4251845.0 |
      | aggregated | 2025-08-09T07:00:00+00:00 |      3600.0 | 4036213.0 |
      | aggregated | 2025-08-09T08:00:00+00:00 |      3600.0 | 4241722.0 |
      | aggregated | 2025-08-09T09:00:00+00:00 |      3600.0 | 4230418.0 |
      | aggregated | 2025-08-09T10:00:00+00:00 |      3600.0 | 4111389.0 |
      | aggregated | 2025-08-09T11:00:00+00:00 |      3600.0 | 4027456.0 |
      | aggregated | 2025-08-09T12:00:00+00:00 |      3600.0 | 4447734.0 |
      | aggregated | 2025-08-09T13:00:00+00:00 |      3600.0 | 4045877.0 |
      | aggregated | 2025-08-09T14:00:00+00:00 |      3600.0 | 3950913.0 |
      | aggregated | 2025-08-09T15:00:00+00:00 |      3600.0 | 4237583.0 |
      | aggregated | 2025-08-09T16:00:00+00:00 |      3600.0 | 4186324.0 |
      | aggregated | 2025-08-09T17:00:00+00:00 |      3600.0 | 3974627.0 |
      | aggregated | 2025-08-09T18:00:00+00:00 |      3600.0 | 4111303.0 |
      | aggregated | 2025-08-09T19:00:00+00:00 |      3600.0 | 3985836.0 |
      | aggregated | 2025-08-09T20:00:00+00:00 |      3600.0 | 4224432.0 |
      | aggregated | 2025-08-09T21:00:00+00:00 |      3600.0 | 4215721.0 |
      | aggregated | 2025-08-09T22:00:00+00:00 |      3600.0 | 4044900.0 |
      | aggregated | 2025-08-09T23:00:00+00:00 |      3600.0 | 3973582.0 |
      +------------+---------------------------+-------------+-----------+

  .. group-tab:: Python Client

    Run the following code:

    .. code-block:: python

      start = "2025-08-09T00:00:00+00:00"
      stop = "2025-08-10T00:00:00+00:00"
      gnocchi_client.aggregates.fetch(
          operations=[
              "aggregate",
              "sum",
              [
                  "metric",
                  ["router.traffic.outbound.interregion", "sum"],
                  ["router.traffic.outbound.internet", "sum"],
                  ["ip.floating.traffic.outbound.interregion", "sum"],
                  ["ip.floating.traffic.outbound.internet", "sum"],
                  ["storage.objects.download.size.interregion", "sum"],
                  ["storage.objects.download.size.internet", "sum"],
              ],
          ],
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
          resource_type="generic",
          start=start,
          stop=stop,
          granularity=3600,
      )

    Example output:

    .. code-block:: python

      >>> start = "2025-08-09T00:00:00+00:00"
      >>> stop = "2025-08-10T00:00:00+00:00"
      >>> gnocchi_client.aggregates.fetch(
      ...     operations=[
      ...         "aggregate",
      ...         "sum",
      ...         [
      ...             "metric",
      ...             ["router.traffic.outbound.interregion", "sum"],
      ...             ["router.traffic.outbound.internet", "sum"],
      ...             ["ip.floating.traffic.outbound.interregion", "sum"],
      ...             ["ip.floating.traffic.outbound.internet", "sum"],
      ...             ["storage.objects.download.size.interregion", "sum"],
      ...             ["storage.objects.download.size.internet", "sum"],
      ...         ],
      ...     ],
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
      ...     resource_type="generic",
      ...     start=start,
      ...     stop=stop,
      ...     granularity=3600,
      ... )
      {'measures': {'aggregated': [(datetime.datetime(2025, 8, 9, 0, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4410824.0),
                                   (datetime.datetime(2025, 8, 9, 1, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    3977323.0),
                                   (datetime.datetime(2025, 8, 9, 2, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    3919881.0),
                                   (datetime.datetime(2025, 8, 9, 3, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4223212.0),
                                   (datetime.datetime(2025, 8, 9, 4, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4319391.0),
                                   (datetime.datetime(2025, 8, 9, 5, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4019030.0),
                                   (datetime.datetime(2025, 8, 9, 6, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4251845.0),
                                   (datetime.datetime(2025, 8, 9, 7, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4036213.0),
                                   (datetime.datetime(2025, 8, 9, 8, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4241722.0),
                                   (datetime.datetime(2025, 8, 9, 9, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4230418.0),
                                   (datetime.datetime(2025, 8, 9, 10, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4111389.0),
                                   (datetime.datetime(2025, 8, 9, 11, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4027456.0),
                                   (datetime.datetime(2025, 8, 9, 12, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4447734.0),
                                   (datetime.datetime(2025, 8, 9, 13, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4045877.0),
                                   (datetime.datetime(2025, 8, 9, 14, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    3950913.0),
                                   (datetime.datetime(2025, 8, 9, 15, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4237583.0),
                                   (datetime.datetime(2025, 8, 9, 16, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4186324.0),
                                   (datetime.datetime(2025, 8, 9, 17, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    3974627.0),
                                   (datetime.datetime(2025, 8, 9, 18, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4111303.0),
                                   (datetime.datetime(2025, 8, 9, 19, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    3985836.0),
                                   (datetime.datetime(2025, 8, 9, 20, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4224432.0),
                                   (datetime.datetime(2025, 8, 9, 21, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4215721.0),
                                   (datetime.datetime(2025, 8, 9, 22, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    4044900.0),
                                   (datetime.datetime(2025, 8, 9, 23, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
                                    3600.0,
                                    3973582.0)]}}

  .. group-tab:: cURL

    First, save a file containing the request payload.

    .. code-block:: bash

      start="2025-08-09T00:00:00+00:00"
      stop="2025-08-10T00:00:00+00:00"
      cat > payload.json << EOF
      {
        "operations": [
            "aggregate",
            "sum",
            [
                "metric",
                ["router.traffic.outbound.interregion", "sum"],
                ["router.traffic.outbound.internet", "sum"],
                ["ip.floating.traffic.outbound.interregion", "sum"],
                ["ip.floating.traffic.outbound.internet", "sum"],
                ["storage.objects.download.size.interregion", "sum"],
                ["storage.objects.download.size.internet", "sum"]
            ]
        ],
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
        "resource_type": "generic"
      }
      EOF

    Here is what the payload should look like:

    .. code-block:: json

      {
        "operations": [
            "aggregate",
            "sum",
            [
                "metric",
                ["router.traffic.outbound.interregion", "sum"],
                ["router.traffic.outbound.internet", "sum"],
                ["ip.floating.traffic.outbound.interregion", "sum"],
                ["ip.floating.traffic.outbound.internet", "sum"],
                ["storage.objects.download.size.interregion", "sum"],
                ["storage.objects.download.size.internet", "sum"]
            ]
        ],
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
        "resource_type": "generic"
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
              4410824.0
            ],
            [
              "2025-08-09T01:00:00+00:00",
              3600.0,
              3977323.0
            ],
            [
              "2025-08-09T02:00:00+00:00",
              3600.0,
              3919881.0
            ],
            [
              "2025-08-09T03:00:00+00:00",
              3600.0,
              4223212.0
            ],
            [
              "2025-08-09T04:00:00+00:00",
              3600.0,
              4319391.0
            ],
            [
              "2025-08-09T05:00:00+00:00",
              3600.0,
              4019030.0
            ],
            [
              "2025-08-09T06:00:00+00:00",
              3600.0,
              4251845.0
            ],
            [
              "2025-08-09T07:00:00+00:00",
              3600.0,
              4036213.0
            ],
            [
              "2025-08-09T08:00:00+00:00",
              3600.0,
              4241722.0
            ],
            [
              "2025-08-09T09:00:00+00:00",
              3600.0,
              4230418.0
            ],
            [
              "2025-08-09T10:00:00+00:00",
              3600.0,
              4111389.0
            ],
            [
              "2025-08-09T11:00:00+00:00",
              3600.0,
              4027456.0
            ],
            [
              "2025-08-09T12:00:00+00:00",
              3600.0,
              4447734.0
            ],
            [
              "2025-08-09T13:00:00+00:00",
              3600.0,
              4045877.0
            ],
            [
              "2025-08-09T14:00:00+00:00",
              3600.0,
              3950913.0
            ],
            [
              "2025-08-09T15:00:00+00:00",
              3600.0,
              4237583.0
            ],
            [
              "2025-08-09T16:00:00+00:00",
              3600.0,
              4186324.0
            ],
            [
              "2025-08-09T17:00:00+00:00",
              3600.0,
              3974627.0
            ],
            [
              "2025-08-09T18:00:00+00:00",
              3600.0,
              4111303.0
            ],
            [
              "2025-08-09T19:00:00+00:00",
              3600.0,
              3985836.0
            ],
            [
              "2025-08-09T20:00:00+00:00",
              3600.0,
              4224432.0
            ],
            [
              "2025-08-09T21:00:00+00:00",
              3600.0,
              4215721.0
            ],
            [
              "2025-08-09T22:00:00+00:00",
              3600.0,
              4044900.0
            ],
            [
              "2025-08-09T23:00:00+00:00",
              3600.0,
              3973582.0
            ]
          ]
        }
      }
