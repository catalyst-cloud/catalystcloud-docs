In many of the examples on this page, we use this search filter pattern:

.. tabs::

  .. group-tab:: OpenStack CLI

    .. code-block:: python

      started_at<'${stop}' and (ended_at>='${start}' or ended_at=null)

  .. group-tab:: Python Client

    .. code-block:: python

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
      }

  .. group-tab:: cURL

    .. code-block:: json

      {
        "and": [
          {"<": {"started_at": "{stop}"}},
          {
            "or": [
              {">=": {"ended_at": "{start}"}},
              {"=": {"ended_at": null}}
            ]
          }
        ]
      }

This filter sets two major conditions:

* Select resources that were started *before* the specified stop time.
* Select resources that are either still active, or were deleted *after* the specified start time.

The effect of this is that only resources that were known to be active
during the queried time period will have results returned.

This is important because during :ref:`metrics-aggregates-api` queries, if they
satisfy the search conditions, resources that exist in the Metrics Service will
still be evaluated for measures during the search period *even if they did not
exist yet, or no longer existed*.

This causes the response to contain references to those resources, along with
empty data structures signifying they have no aggregates for the query (which
can sometimes be useful information to know, but not for most use cases).

The bigger issue with this, however, is performance. Aggregate queries
that match with resources that don't need to be searched take much longer
to complete, so to ensure resource searches and aggregate queries are lightweight
**it is highly recommended you make search filters as specific as possible**.
