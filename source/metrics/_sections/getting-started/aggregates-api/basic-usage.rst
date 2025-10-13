.. _`Dynamic Aggregates`: https://gnocchi.osci.io/rest.html#dynamic-aggregates

This section demonstrates how to use the Aggregates API to perform a simple query.

.. note::

  For more detailed explanations on what kind of queries can be done
  using the Aggregates API, see :ref:`metrics-aggregates-api-examples`.

.. tabs::

  .. group-tab:: OpenStack CLI

    The Aggregates API is available using the ``openstack metric aggregates`` command.

    .. code-block:: bash

      openstack metric aggregates --start "${start}" \
                                  --stop "${stop}" \
                                  --resource-type ${resource_type} \
                                  --granularity ${granularity} \
                                  "${operations}" \
                                  "${search}"

    The following basic parameters should be set for every query:

    * ``--start DATETIME`` - Start time of the period for which to query aggregates, as an ISO 8601 datetime (recommended) or Unix timestamp.
    * ``--stop DATETIME`` - End time of the period for which to query aggregates, as an ISO 8601 datetime (recommended) or Unix timestamp.
    * ``--resource-type TYPE`` - The :ref:`resource type <metrics-reference>` to query aggregates from.
    * ``--granularity SECONDS`` - The :ref:`granularity <metrics-granularity>` of the aggregates to query.
    * ``operations`` - The aggregate operations to perform to get the desired data, in string format (**not** JSON).
      We have examples defined below for common use cases, but if you'd like more information on what is
      possible using the Aggregates API, refer to the Gnocchi documentation on `Dynamic Aggregates`_.
    * ``search`` - Search filters to limit the output to desired resources only, in string format (**not** JSON).
      For more information, see :ref:`metrics-searching-resources`.

    .. warning::

      You should **always** set ``--start`` and ``--stop`` for your aggregate queries.

      Not doing so will result in an unbounded query being performed,
      causing more metrics to be retrieved than intended or a timeout.

    Here is a basic example of an aggregate query command against a single resource:

    .. code-block:: bash

      openstack metric aggregates --start "2025-08-09T00:00:00+00:00" \
                                  --stop "2025-08-09T01:00:00+00:00" \
                                  --resource-type instance \
                                  --granularity 600 \
                                  "(/ (/ (metric cpu rate:mean) (metric vcpus mean)) 600000000000)" \
                                  "id=af6b97d9-d172-4e06-b565-db1e97097340"

    All resources with matching metrics get measures returned in a table format.

    .. code-block:: console

      $ openstack metric aggregates --start "2025-08-09T00:00:00+00:00" --stop "2025-08-09T01:00:00+00:00" --resource-type instance --granularity 600 "(/ (/ (metric cpu rate:mean) (metric vcpus mean)) 600000000000)" "id=af6b97d9-d172-4e06-b565-db1e97097340"
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

    ``-f json`` can be used to change the output format to JSON.

    .. code-block:: console

      $ openstack metric aggregates --start "2025-08-09T00:00:00+00:00" --stop "2025-08-09T01:00:00+00:00" --resource-type instance --granularity 600 "(/ (/ (metric cpu rate:mean) (metric vcpus mean)) 600000000000)" "id=af6b97d9-d172-4e06-b565-db1e97097340" -f json
      [
        {
          "name": "aggregated",
          "timestamp": "2025-08-09T00:00:00+00:00",
          "granularity": 600.0,
          "value": 0.0018333333333333333
        },
        {
          "name": "aggregated",
          "timestamp": "2025-08-09T00:10:00+00:00",
          "granularity": 600.0,
          "value": 0.0014
        },
        {
          "name": "aggregated",
          "timestamp": "2025-08-09T00:20:00+00:00",
          "granularity": 600.0,
          "value": 0.0014666666666666667
        },
        {
          "name": "aggregated",
          "timestamp": "2025-08-09T00:30:00+00:00",
          "granularity": 600.0,
          "value": 0.0014666666666666667
        },
        {
          "name": "aggregated",
          "timestamp": "2025-08-09T00:40:00+00:00",
          "granularity": 600.0,
          "value": 0.0013833333333333334
        },
        {
          "name": "aggregated",
          "timestamp": "2025-08-09T00:50:00+00:00",
          "granularity": 600.0,
          "value": 0.0014333333333333333
        }
      ]

    Returned timestamps are in UTC.

    .. note::

      If no timezone offset (e.g. ``+12:00``) is specified on your
      ``--start`` and ``--stop`` timestamps, the CLI command for the
      Aggregates API will automatically change the timestamps to UTC
      relative to your computer's system timezone.

      To prevent this behaviour, make sure that your ``--start``
      and ``--stop`` values have the correct timezone offset.

    Other options are also available. For reference, here is the full output of ``--help``:

    .. code-block:: console

      $ openstack metric aggregates --help
      usage: openstack metric aggregates [-h] [-f {csv,json,table,value,yaml}] [-c COLUMN] [--quote {all,minimal,none,nonnumeric}] [--noindent] [--max-width <integer>] [--fit-width] [--print-empty]
                                        [--sort-column SORT_COLUMN] [--sort-ascending | --sort-descending] [--resource-type RESOURCE_TYPE] [--start START] [--stop STOP] [--granularity GRANULARITY]
                                        [--needed-overlap NEEDED_OVERLAP] [--groupby GROUPBY] [--fill FILL] [--use-history USE_HISTORY]
                                        operations [search]

      Get measurements of aggregated metrics.

      positional arguments:
        operations    Operations to apply to time series
        search        A query to filter resource. The syntax is a combination of attribute, operator and value. For example: id=90d58eea-70d7-4294-a49a-170dcdf44c3c would filter resource with a certain id. More complex queries can be built,
                              e.g.: not (flavor_id!="1" and memory>=24). Use "" to force data to be interpreted as string. Supported operators are: not, and, ∧ or, ∨, >=, <=, !=, >, <, =, ==, eq, ne, lt, gt, ge, le, in, like, ≠, ≥, ≤, like, in.

      options:
        -h, --help            show this help message and exit
        --resource-type RESOURCE_TYPE
                              Resource type to query
        --start START
                              beginning of the period
        --stop STOP           end of the period
        --granularity GRANULARITY
                              granularity to retrieve
        --needed-overlap NEEDED_OVERLAP
                              percentage of overlap across datapoints
        --groupby GROUPBY
                              Attribute to use to group resources
        --fill FILL           Value to use when backfilling timestamps with missing values in a subset of series. Value should be a float or 'null'.
        --use-history USE_HISTORY
                              Indicates if Gnocchi server should respond with the resource tags history for the aggregation query. If set to `False`, only the latest tag values will be returned. Otherwise, the measures will be split proportionally if a
                              tag has been changed in the `granularity` requested.

      output formatters:
        output formatter options

        -f {csv,json,table,value,yaml}, --format {csv,json,table,value,yaml}
                              the output format, defaults to table
        -c COLUMN, --column COLUMN
                              specify the column(s) to include, can be repeated to show multiple columns
        --sort-column SORT_COLUMN
                              specify the column(s) to sort the data (columns specified first have a priority, non-existing columns are ignored), can be repeated
        --sort-ascending      sort the column(s) in ascending order
        --sort-descending     sort the column(s) in descending order

      CSV Formatter:
        --quote {all,minimal,none,nonnumeric}
                              when to include quotes, defaults to nonnumeric

      json formatter:
        --noindent            whether to disable indenting the JSON

      table formatter:
        --max-width <integer>
                              Maximum display width, <1 to disable. You can also use the CLIFF_MAX_TERM_WIDTH environment variable, but the parameter takes precedence.
        --fit-width           Fit the table to the display width. Implied if --max-width greater than 0. Set the environment variable CLIFF_FIT_WIDTH=1 to always enable
        --print-empty         Print empty table if there is no data to show.

      This command is provided by the gnocchiclient plugin.

  .. group-tab:: Python Client

    The Aggregates API is available using the `gnocchi_client.aggregates.fetch`_ method.

    .. _`gnocchi_client.aggregates.fetch`: https://gnocchi.osci.io/gnocchiclient/api/gnocchiclient.v1.aggregates.html#gnocchiclient.v1.aggregates.AggregatesManager.fetch

    .. code-block:: python

      def fetch(
          operations: str | list[Operation],
          search: str | dict[str, SearchFilter] | None = None,
          resource_type: str = "generic",
          start: int | str | datetime.datetime | None = None,
          stop: int | str | datetime.datetime | None = None,
          granularity: int | None = None,
          needed_overlap: float | None = None,
          groupby: list[str] | None = None,
          details: bool = False,
          use_history: bool = False,
      ) -> dict[str, Any] | list[dict[str, Any]]

    The following basic parameters should be set for every query:

    * ``start`` - Start time of the period for which to query aggregates, as a ``datetime.datetime`` object (recommended), ISO 8601 datetime or Unix timestamp.
    * ``stop`` - End time of the period for which to query aggregates, as a ``datetime.datetime`` object (recommended), ISO 8601 datetime or Unix timestamp.
    * ``resource_type`` - The :ref:`resource type <metrics-reference>` to query aggregates from.
    * ``granularity`` - The :ref:`granularity <metrics-granularity>` of the aggregates to query.
    * ``operations`` - The aggregate operations to perform to get the desired data, in string or object format.
      We have examples defined below for common use cases, but if you'd like more information on what is
      possible using the Aggregates API, refer to the Gnocchi documentation on `Dynamic Aggregates`_.
    * ``search`` - Search filters to limit the output to desired resources only, in string or object format.
      For more information, see :ref:`metrics-searching-resources`.

    .. warning::

      You should **always** set ``start`` and ``stop`` for your aggregate queries.

      Not doing so will result in an unbounded query being performed,
      causing more metrics to be retrieved than intended or a timeout.

    Here is a basic example of an aggregate query command against a single resource:

    .. code-block:: python

      gnocchi_client.aggregates.fetch(
          operations=[
              "/",
              [
                  "/",
                  ["metric", "cpu", "rate:mean"],
                  ["metric", "vcpus", "mean"],
              ],
              6000000000,
          ],
          search={"=": {"id": "af6b97d9-d172-4e06-b565-db1e97097340"}},
          resource_type="instance",
          start="2025-08-09T00:00:00+00:00",
          stop="2025-08-09T01:00:00+00:00",
          granularity=600,
      )


    All resources with matching metrics usually get returned in the following format
    (this can change depending on the type of query).

    .. code-block:: python

      >>> pprint(gnocchi_client.aggregates.fetch(
      ...     operations=[
      ...         "/",
      ...         [
      ...             "/",
      ...             ["metric", "cpu", "rate:mean"],
      ...             ["metric", "vcpus", "mean"],
      ...         ],
      ...         6000000000,
      ...     ],
      ...     search={"=": {"id": "af6b97d9-d172-4e06-b565-db1e97097340"}},
      ...     resource_type="instance",
      ...     start="2025-08-09T00:00:00+00:00",
      ...     stop="2025-08-09T01:00:00+00:00",
      ...     granularity=600,
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

    Note that the returned timestamps are timezone-aware ``datetime.datetime`` objects in UTC.

  .. group-tab:: cURL

    The Aggregates API is available using the ``/v1/aggregates`` endpoint.

    Here is a basic example of an aggregate query command against a single resource:

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

    Example JSON payload (save this as ``payload.json``):

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

    The following basic parameters should be set for every query:

    * ``start`` - Start time of the period for which to query aggregates, as an ISO 8601 datetime (recommended) or Unix timestamp.
    * ``stop`` - End time of the period for which to query aggregates, as an ISO 8601 datetime (recommended) or Unix timestamp.
    * ``resource_type`` - The :ref:`resource type <metrics-reference>` to query aggregates from.
    * ``granularity`` - The :ref:`granularity <metrics-granularity>` of the aggregates to query.
    * ``operations`` - The aggregate operations to perform to get the desired data, in string or object format.
      We have examples defined below for common use cases, but if you'd like more information on what is
      possible using the Aggregates API, refer to the Gnocchi documentation on `Dynamic Aggregates`_.
    * ``search`` - Search filters to limit the output to desired resources only, in string or object format.
      For more information, see :ref:`metrics-searching-resources`.

    .. warning::

      You should **always** set ``start`` and ``stop`` for your aggregate queries.

      Not doing so will result in an unbounded query being performed,
      causing more metrics to be retrieved than intended or a timeout.

    All resources with matching metrics usually get returned in the following format
    (this can change depending on the type of query).

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

    Returned timestamps are in UTC.
