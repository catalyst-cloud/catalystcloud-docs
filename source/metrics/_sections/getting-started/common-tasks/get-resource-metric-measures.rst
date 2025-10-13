This shows how you can query :ref:`measures <metrics-measures>`
from resource :ref:`metrics <metrics-metrics>` for a given
:ref:`aggregation method <metrics-aggregation-methods>` and
:ref:`granularity <metrics-granularity>`.

This is a simple way of getting a sample of pre-aggregated measures
as we store them without going through the complexity of the
:ref:`metrics-aggregates-api`, but no additional processing on the
measures is supported.

Below is an example of getting ``cpu`` metric measures of an instance
for the hour of 2025-08-09 00:00-01:00 UTC, using the ``rate:mean``
aggregation method and a granularity of 600 seconds.

.. tabs::

  .. group-tab:: OpenStack CLI

    Run the following command:

    .. code-block:: bash

      openstack metric measures show --resource-id ${resource_id} \
                                     ${metric_name}
                                     --aggregation ${aggregation} \
                                     --granularity ${granularity} \
                                     --start ${start} \
                                     --stop ${stop} \
                                     --utc

    .. note::

      If no timezone offset (e.g. ``+12:00``) is specified on your
      ``--start`` and ``--stop`` timestamps, this command will automatically
      change the timestamps to UTC relative to your computer's system timezone.

      To prevent this behaviour, make sure that your ``--start``
      and ``--stop`` values have the correct timezone offset.

      Likewise, by default the timestamps returned by this command will be in your
      computer's system timezone. If you'd like to receive measure timestamps in UTC,
      set the ``--utc`` flag.

    .. warning::

      You should **always** set ``--start`` and ``--stop`` for your measure queries.

      Not doing so will result in an unbounded query being performed,
      causing more metrics to be retrieved than intended or a timeout.

    Example command with populated values:

    .. code-block:: bash

      openstack metric measures show --resource-id af6b97d9-d172-4e06-b565-db1e97097340 \
                                     cpu
                                     --aggregation rate:mean \
                                     --granularity 600 \
                                     --start "2025-08-09T00:00:00+00:00" \
                                     --stop "2025-08-09T01:00:00+00:00" \
                                     --utc

    Example output:

    .. code-block:: console

      $ openstack metric measures show --resource-id af6b97d9-d172-4e06-b565-db1e97097340 cpu --aggregation rate:mean --granularity 600 --start "2025-08-09T00:00:00+00:00" --stop "2025-08-09T01:00:00+00:00" --utc
      +---------------------------+-------------+--------------+
      | timestamp                 | granularity |        value |
      +---------------------------+-------------+--------------+
      | 2025-08-09T00:00:00+00:00 |       600.0 | 1100000000.0 |
      | 2025-08-09T00:10:00+00:00 |       600.0 |  840000000.0 |
      | 2025-08-09T00:20:00+00:00 |       600.0 |  880000000.0 |
      | 2025-08-09T00:30:00+00:00 |       600.0 |  880000000.0 |
      | 2025-08-09T00:40:00+00:00 |       600.0 |  830000000.0 |
      | 2025-08-09T00:50:00+00:00 |       600.0 |  860000000.0 |
      +---------------------------+-------------+--------------+

  .. group-tab:: Python Client

    Measures can be fetched directly using the `gnocchi_client.metric.get_measures`_ method.

    .. _`gnocchi_client.metric.get_measures`: https://gnocchi.osci.io/gnocchiclient/api/gnocchiclient.v1.metric.html#gnocchiclient.v1.metric.MetricManager.get_measures

    .. code-block:: python

      gnocchi_client.metric.get_measures(
          "{metric_name}",
          resource_id="{resource_id}",
          start="{start}",
          stop="{stop}",
          aggregation="{aggregation}",
          granularity=granularity,
      )

    .. warning::

      You should **always** set ``start`` and ``stop`` for your measure queries.

      Not doing so will result in an unbounded query being performed,
      causing more metrics to be retrieved than intended or a timeout.

    Example method call with populated values:

    .. code-block:: python

      gnocchi_client.metric.get_measures(
          "cpu",
          resource_id="af6b97d9-d172-4e06-b565-db1e97097340",
          start="2025-08-09T00:00:00+00:00",
          stop="2025-08-09T01:00:00+00:00",
          aggregation="rate:mean",
          granularity=600,
      )

    Example output:

    .. code-block:: python

      >>> gnocchi_client.metric.get_measures("cpu", resource_id="af6b97d9-d172-4e06-b565-db1e97097340", start="2025-08-09T00:00:00+00:00", stop="2025-08-09T01:00:00+00:00", aggregation="rate:mean", granularity=600)
      [(datetime.datetime(2025, 8, 9, 0, 0, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
        600.0,
        1100000000.0),
       (datetime.datetime(2025, 8, 9, 0, 10, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
        600.0,
        840000000.0),
       (datetime.datetime(2025, 8, 9, 0, 20, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
        600.0,
        880000000.0),
       (datetime.datetime(2025, 8, 9, 0, 30, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
        600.0,
        880000000.0),
       (datetime.datetime(2025, 8, 9, 0, 40, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
        600.0,
        830000000.0),
       (datetime.datetime(2025, 8, 9, 0, 50, tzinfo=datetime.timezone(datetime.timedelta(0), '+00:00')),
        600.0,
        860000000.0)]

    Note that the returned timestamps are timezone-aware ``datetime.datetime`` objects in UTC.

  .. group-tab:: cURL

    Make the following request:

    .. code-block:: bash

      curl -s \
           -H "X-Auth-Token: ${OS_TOKEN}" \
           -H "Accept: application/json" \
           "https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/resource/${resource_type}/${resource_id}/metric/${metric_name}/measures?start=${start}&stop=${stop}&aggregation=${aggregation}&granularity=${granularity}"

    .. warning::

      You should **always** set ``start`` and ``stop`` for your measure queries.

      Not doing so will result in an unbounded query being performed,
      causing more metrics to be retrieved than intended or a timeout.

    Example request with populated values (and required values URL-encoded):

    .. code-block:: bash

      curl -s \
           -H "X-Auth-Token: ${OS_TOKEN}" \
           -H "Accept: application/json" \
           "https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/resource/instance/af6b97d9-d172-4e06-b565-db1e97097340/metric/cpu/measures?start=2025-08-09T00%3A00%3A00%2B00%3A00&stop=2025-08-09T01%3A00%3A00%2B00%3A00&aggregation=rate%3Amean&granularity=600"

    Example output:

    .. code-block:: console

      $ curl -s -H "X-Auth-Token: ${OS_TOKEN}" -H "Accept: application/json" "https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/resource/instance/af6b97d9-d172-4e06-b565-db1e97097340/metric/cpu/measures?start=2025-08-09T00%3A00%3A00%2B00%3A00&stop=2025-08-09T01%3A00%3A00%2B00%3A00&aggregation=rate%3Amean&granularity=600" | jq
      [
        [
          "2025-08-09T00:00:00+00:00",
          600.0,
          1100000000.0
        ],
        [
          "2025-08-09T00:10:00+00:00",
          600.0,
          840000000.0
        ],
        [
          "2025-08-09T00:20:00+00:00",
          600.0,
          880000000.0
        ],
        [
          "2025-08-09T00:30:00+00:00",
          600.0,
          880000000.0
        ],
        [
          "2025-08-09T00:40:00+00:00",
          600.0,
          830000000.0
        ],
        [
          "2025-08-09T00:50:00+00:00",
          600.0,
          860000000.0
        ]
      ]

    Returned timestamps are in UTC.
