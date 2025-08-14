.. _alarm-service-on-catalyst-cloud:

########
Overview
########

The alarm service allows a user to set up alarms that monitor the state of
various objects in the cloud. The alarms wait for specific events to occur;
then they change their state depending on pre set parameters. If a state change
occurs then actions that you predefine for the alarm take effect.

For example: You want to monitor a compute instance to see if the CPU
utilization exceeds 70% for more than 10 minutes. Once the alarm has met
this requirement, it changes its state to 'alarm'. The notifier then
tells your system to perform some action. In this scenario it could be to: spin
up a new instance with more CPU power, or increase the amount of VCPUs your
instance is using.

***************
Threshold rules
***************

These are the rules that you define for your alarms. With these you can
specify what events will require a state change to your alarms.

For conventional threshold-oriented alarms, state transitions are governed by:

- A static threshold value with a comparison operator such as greater than or
  less than. e.g. (CPU usage > 70%)

- A statistic selection to aggregate the data.

- A sliding time window to indicate how far back into the recent past you want
  to look. e.g. "test every ten minutes and if for thirty consecutive minutes
  then..."

After setting up your rules, your alarm should appear in one of the following
states:

- ``ok`` The rule governing the alarm has been evaluated as False.

- ``alarm`` The rule governing the alarm has been evaluated as True.

- ``insufficient data`` There are not enough datapoints available in the
  evaluation periods to meaningfully determine the alarm state.

Creating a Threshold Alarm
==========================

Alarms are created with the openstack commandline tool, using the command
``openstack alarm create``.

Suppose we want to create an alarm that changed state when the CPU usage
of a server was greater than 70% for ten minutes.  We could then create
the alarm with the following command:

.. code-block:: bash

    openstack alarm create --name "high cpu" --type threshold \
      --description "High CPU" --severity critical --meter_name cpu_util \
      --period 630 --statistic max --threshold 70 \
      --comparison-operator gt \
      --query resource_id=29a7a2ec-db72-4360-ad81-xxxxxxxxxxxx

Where:

* ``--meter_name cpu_util`` selects the meter to get data for.
* ``--period 630`` is the period to evaluate the alarm over in seconds.
* ``--statistic max`` is the statistic to use to aggregate the data over the evaluation period.
* ``--threshold 70`` is the threshold to determine the alarm state.
* ``--comparison-operator gt`` is the operator is use to compare the evaluated data against the threshold.
* ``--query resource_id=29a7a2ec-db72-4360-ad81-xxxxxxxxxxxx`` selects the server to get the data for.

The alarm create command will return output looking like the following:

.. code-block:: bash

    +---------------------------+--------------------------------------------------------+
    | Field                     | Value                                                  |
    +---------------------------+--------------------------------------------------------+
    | alarm_actions             | []                                                     |
    | alarm_id                  | b974b5b4-b7de-4012-82b8-xxxxxxxxxxxx                   |
    | comparison_operator       | gt                                                     |
    | description               | High CPU                                               |
    | enabled                   | True                                                   |
    | evaluate_timestamp        | 2022-11-10T21:48:10.604880                             |
    | evaluation_periods        | 1                                                      |
    | exclude_outliers          | False                                                  |
    | insufficient_data_actions | []                                                     |
    | meter_name                | cpu_util                                               |
    | name                      | high cpu                                               |
    | ok_actions                | []                                                     |
    | period                    | 630                                                    |
    | project_id                | b23a5e41d1af4c20974bxxxxxxxxxxxx                       |
    | query                     | resource_id = 29a7a2ec-db72-4360-ad81-xxxxxxxxxxxx AND |
    |                           | project_id = b23a5e41d1af4c20974bxxxxxxxxxxxx          |
    | repeat_actions            | False                                                  |
    | severity                  | critical                                               |
    | state                     | insufficient data                                      |
    | state_reason              | Not evaluated yet                                      |
    | state_timestamp           | 2022-11-10T21:48:10.567074                             |
    | statistic                 | max                                                    |
    | threshold                 | 70.0                                                   |
    | time_constraints          | []                                                     |
    | timestamp                 | 2022-11-10T21:48:10.567074                             |
    | type                      | threshold                                              |
    | user_id                   | bf7b8d2ad74e474eac37xxxxxxxxxxxx                       |
    +---------------------------+--------------------------------------------------------+

Note that it has added your project id to the query.

Updating a Threshold Alarm
==========================

The command ``openstack alarm update`` can to used to change the alarm.
For example the threshold of the alarm created above can be changed using the
command:

.. code-block:: bash

    openstack alarm update --threshold 50 b974b5b4-b7de-4012-82b8-xxxxxxxxxxxx

Note that if you want to change the query of the threshold alarm then you must
also set the ``--type threshold`` otherwise the command will try to interpret
the query as a different type and return an error:

.. code-block:: bash

    openstack alarm update --query resource_id=d7839cb3-67a7-4258-a232-xxxxxxxxxxxx \
      b974b5b4-b7de-4012-82b8-xxxxxxxxxxxx
    Invalid input for field/attribute data. Value:
    ...
    Value not a valid list: resource_id=d7839cb3-67a7-4258-a232-xxxxxxxxxx
    (HTTP 400) (Request-ID: req-645dada5-fc8d-4c1d-b948-xxxxxxxxxxxx)

Useful Meters
=============

The following is an incomplete list of meters that can be used to create a
threshold alarm.

Compute Resources
-----------------

* `cpu_util` - Average CPU utilization (%)
* `disk.read.bytes.rate` - Average rate of reads (Bytes/second)
* `disk.read.requests.rate` - Average rate of read requests (requests/second)
* `disk.write.bytes.rate` - Average rate of writes (Bytes/second)
* `disk.write.requests.rate` - Average rate of write requests (requests/second)
* `memory.usage` - Volume of RAM used by the instance from the amount of its allocated memory (MegaBytes)

Object Storage
--------------

* `storage.containers.objects.size` - Total size of stored objects (Bytes)

The following meters will only be available if the container has uploads or downloads of the specific type.

* `storage.objects.download.size.international` - International download traffic from the container (Bytes)
* `storage.objects.upload.size.international` - International upload traffic to the container (Bytes)
* `storage.objects.upload.size.national` - National upload traffic to the container (Bytes)
* `storage.objects.download.size.national` - National download traffic to the container (Bytes)

Router
------

Note that the following meters are only available from routers that are connected to the public Internet.

* `traffic.outbound.international` - Outbound International Traffic(Bytes)
* `traffic.inbound.international` - Inbound International Traffic (Bytes)
* `traffic.inbound.national` - Inbound National Traffic (Bytes)
* `traffic.outbound.national` - Outbound National Traffic (Bytes)

Meter Resolution
================

Please be aware that the temporal resolution for meter data is approximately
10 minutes. Creating alarms that have a period of less than 600 seconds can
result in alarms that may not get enough data to be evaluated.

****************
Composite alarms
****************

These enable users to have multiple triggering conditions, using
``and`` and ``or`` relations, on their alarms. For example, "if CPU usage >
70% for more than 10 minutes OR CPU usage > 90% for more than 1 minute..."

*********************
Supported Alarm Types
*********************

Please be aware that Catalyst Cloud supports the following alarm types:

- event

- composite

- threshold

- loadbalancer_member_health

The following alarm types are not supported:

- gnocchi_resources_threshold

- gnocchi_aggregation_by_metrics_threshold

- gnocchi_aggregation_by_resources_threshold

**************************
Useful Commands For Alarms
**************************

Listing Alarms
==============

The command ``openstack alarm list`` will print a summary of your alarms:

.. code-block:: bash

    openstack alarm list
    +--------------------------------------+-----------+------------------+-------------------+----------+---------+
    | alarm_id                             | type      | name             | state             | severity | enabled |
    +--------------------------------------+-----------+------------------+-------------------+----------+---------+
    | b974b5b4-b7de-4012-82b8-xxxxxxxxxxxx | threshold | high cpu         | ok                | critical | True    |
    +--------------------------------------+-----------+------------------+-------------------+----------+---------+

Alarm Details
=============

The command ``openstack alarm show <alarm id>`` will print the details of a
single alarm:

.. code-block:: bash

    openstack alarm show b974b5b4-b7de-4012-82b8-xxxxxxxxxxxx

    +---------------------------+--------------------------------------------------------------------------------+
    | Field                     | Value                                                                          |
    +---------------------------+--------------------------------------------------------------------------------+
    | alarm_actions             | []                                                                             |
    | alarm_id                  | b974b5b4-b7de-4012-82b8-xxxxxxxxxxxx                                           |
    | comparison_operator       | gt                                                                             |
    | description               | High CPU                                                                       |
    | enabled                   | True                                                                           |
    | evaluate_timestamp        | 2022-11-10T23:41:08                                                            |
    | evaluation_periods        | 1                                                                              |
    | exclude_outliers          | False                                                                          |
    | insufficient_data_actions | []                                                                             |
    | meter_name                | cpu_util                                                                       |
    | name                      | high cpu                                                                       |
    | ok_actions                | []                                                                             |
    | period                    | 630                                                                            |
    | project_id                | b23a5e41d1af4c20974bxxxxxxxxxxxx                                               |
    | query                     | resource_id = ba7dd28f-073f-4c71-9a1e-xxxxxxxxxxxx AND                         |
    |                           | project_id = b23a5e41d1af4c20974bxxxxxxxxxxxx                                  |
    | repeat_actions            | False                                                                          |
    | severity                  | critical                                                                       |
    | state                     | ok                                                                             |
    | state_reason              | Transition to ok due to 1 samples inside threshold, most recent: 10.3036912752 |
    | state_timestamp           | 2022-11-10T21:48:10.567074                                                     |
    | statistic                 | max                                                                            |
    | threshold                 | 50.0                                                                           |
    | time_constraints          | []                                                                             |
    | timestamp                 | 2022-11-10T22:20:31.232071                                                     |
    | type                      | threshold                                                                      |
    | user_id                   | bf7b8d2ad74e474eac37xxxxxxxxxxxx                                               |
    +---------------------------+--------------------------------------------------------------------------------+

Be aware that there is a bug that means that the state_timestamp does not get
updated when the state changes.

Alarm History
=============

The command ``openstack alarm-history show <alarm id>`` will print a complete
history of the alarm, including any changes to the alarm configuration and all
the state changes.

.. code-block:: bash

    openstack alarm-history show b974b5b4-b7de-4012-82b8-xxxxxxxxxxxx

    +----------------------------+------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------+
    | timestamp                  | type             | detail                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | event_id                             |
    +----------------------------+------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------+
    | 2022-11-10T22:20:38.685075 | state transition | {"transition_reason": "Transition to ok due to 1 samples inside threshold, most recent: 10.3036912752", "state": "ok"}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | 3532e29e-aae2-4b7a-8067-xxxxxxxxxxxx |
    | 2022-11-10T22:20:31.232071 | rule change      | {"rule": {"meter_name": "cpu_util", "evaluation_periods": 1, "period": 630, "statistic": "max", "threshold": 50.0, "query": [{"field": "resource_id", "type": "", "value": "ba7dd28f-073f-4c71-9a1e-xxxxxxxxxxxx", "op": "eq"}, {"field": "project_id", "value": "b23a5e41d1af4c20974bxxxxxxxxxxxx", "op": "eq"}], "comparison_operator": "gt", "exclude_outliers": false}}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | 495d5fec-2a2b-406e-a81b-xxxxxxxxxxxx |
    | 2022-11-10T22:06:27.673645 | rule change      | {"rule": {"meter_name": "cpu_util", "evaluation_periods": 1, "period": 630, "statistic": "max", "threshold": 50.0, "query": [{"field": "resource_id", "type": "", "value": "29a7a2ec-db72-4360-ad81-xxxxxxxxxxxx", "op": "eq"}, {"field": "project_id", "value": "b23a5e41d1af4c20974bxxxxxxxxxxxx", "op": "eq"}], "comparison_operator": "gt", "exclude_outliers": false}}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | 69086892-6cb3-4afa-9784-xxxxxxxxxxxx |
    | 2022-11-10T21:48:10.567074 | creation         | {"state_reason": "Not evaluated yet", "user_id": "bf7b8d2ad74e474eac37xxxxxxxxxxxx", "name": "high cpu", "state": "insufficient data", "timestamp": "2022-11-10T21:48:10.567074", "description": "High CPU", "enabled": true, "state_timestamp": "2022-11-10T21:48:10.567074", "rule": {"meter_name": "cpu_util", "evaluation_periods": 1, "period": 630, "statistic": "max", "threshold": 70.0, "query": [{"field": "resource_id", "type": "", "value": "29a7a2ec-db72-4360-ad81-xxxxxxxxxxxx", "op": "eq"}, {"field": "project_id", "value": "b23a5e41d1af4c20974bxxxxxxxxxxxx", "op": "eq"}], "comparison_operator": "gt", "exclude_outliers": false}, "alarm_id": "b974b5b4-b7de-4012-82b8-xxxxxxxxxxxx", "time_constraints": [], "insufficient_data_actions": [], "repeat_actions": false, "ok_actions": [], "project_id": "b23a5e41d1af4c20974bxxxxxxxxxxxx", "type": "threshold", "alarm_actions": [], "severity": "critical"} | e44fa797-bef0-4460-9fa8-xxxxxxxxxxxx |
    +----------------------------+------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------+

***************
Further Reading
***************

For more information on the Alarm service, you can visit `the OpenStack
documentation on Aodh`_

.. _`the OpenStack documentation on Aodh`: https://docs.openstack.org/aodh/latest/admin/telemetry-alarms.html
