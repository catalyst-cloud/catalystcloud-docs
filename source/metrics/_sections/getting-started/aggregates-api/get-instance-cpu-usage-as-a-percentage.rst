In this example we show how to get the 10 minute mean CPU usage of an instance as a decimal percentage (0-1).

The query takes into account the mean number of vCPUs the instance ran with in each aggregated
datapoint, to allow :ref:`instance resizes <resize-server>` to be handled gracefully.

.. tabs::

  .. group-tab:: OpenStack CLI

    Here are the commands we will run:

    .. code-block:: bash

      resource_id="af6b97d9-d172-4e06-b565-db1e97097340"
      start="2025-08-09T00:00:00+00:00"
      stop="2025-08-09T01:00:00+00:00"
      granularity=600
      openstack metric aggregates --start "${start}" \
                                  --stop "${stop}" \
                                  --resource-type instance \
                                  --granularity ${granularity} \
                                  "(/ (/ (metric cpu rate:mean) (metric vcpus mean)) $(echo "1000000000 * ${granularity}" | bc))" \
                                  "id='${resource_id}'"

    With the variables evaluated, this is what it looks like:

    .. code-block:: bash

      openstack metric aggregates --start "2025-08-09T00:00:00+00:00" \
                                  --stop "2025-08-09T01:00:00+00:00" \
                                  --resource-type instance \
                                  --granularity 600 \
                                  "(/ (/ (metric cpu rate:mean) (metric vcpus mean)) 600000000000)" \
                                  "id='af6b97d9-d172-4e06-b565-db1e97097340'"

    Example output:

    .. code-block:: console

      $ openstack metric aggregates --start "2025-08-09T00:00:00+00:00" --stop "2025-08-09T01:00:00+00:00" --resource-type instance --granularity 600 "(/ (/ (metric cpu rate:mean) (metric vcpus mean)) 600000000000)" "id='af6b97d9-d172-4e06-b565-db1e97097340'"
      +------------+---------------------------+-------------+-----------------------+
      | name       | timestamp                 | granularity |                 value |
      +------------+---------------------------+-------------+-----------------------+
      | aggregated | 2025-08-09T00:00:00+00:00 |       600.0 | 0.0018333333333333333 |
      | aggregated | 2025-08-09T00:10:00+00:00 |       600.0 |                0.0014 |
      | aggregated | 2025-08-09T00:20:00+00:00 |       600.0 | 0.0014666666666666667 |
      | aggregated | 2025-08-09T00:30:00+00:00 |       600.0 | 0.0014666666666666667 |
      | aggregated | 2025-08-09T00:40:00+00:00 |       600.0 | 0.0013833333333333334 |
      | aggregated | 2025-08-09T00:50:00+00:00 |       600.0 | 0.0014333333333333333 |
      +------------+---------------------------+-------------+-----------------------+

  .. group-tab:: Python Client

    Run the following code:

    .. code-block:: python

      resource_id = "af6b97d9-d172-4e06-b565-db1e97097340"
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
          search={"=": {"id": resource_id}},
          resource_type="instance",
          start=start,
          stop=stop,
          granularity=granularity,
      )

    Example output:

    .. code-block:: python

      >>> resource_id = "af6b97d9-d172-4e06-b565-db1e97097340"
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
      ...     search={"=": {"id": resource_id}},
      ...     resource_type="instance",
      ...     start=start,
      ...     stop=stop,
      ...     granularity=granularity,
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
                                    0.14333333333333334)]}}}}

  .. group-tab:: cURL

    First, save a file containing the request payload.

    .. code-block:: bash

      resource_id="af6b97d9-d172-4e06-b565-db1e97097340"
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
        "search": {"=": {"id": "${resource_id}"}},
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
        }
      }
