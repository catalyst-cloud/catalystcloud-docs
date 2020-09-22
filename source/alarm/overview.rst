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
  to look. e.g. "test every minute and if for three consecutive minutes
  then..."

After setting up your rules, your alarm should appear in one of the following
states:

- ``ok`` The rule governing the alarm has been evaluated as False.

- ``alarm`` The rule governing the alarm has been evaluated as True.

- ``insufficient data`` There are not enough datapoints available in the
  evaluation periods to meaningfully determine the alarm state.

****************
Composite alarms
****************

These enable users to have multiple triggering conditions, using
``and`` and ``or`` relations, on their alarms. For example, "if CPU usage >
70% for more than 10 minutes OR CPU usage > 90% for more than 1 minute..."

|

For more information on the Alarm service, you can visit `the openstack
documentation on aodh`_

.. _`the openstack documentation on aodh`: https://docs.openstack.org/aodh/latest/admin/telemetry-alarms.html
