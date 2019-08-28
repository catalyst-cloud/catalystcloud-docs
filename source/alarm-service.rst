.. _alarm-service-on-Sky-tv_cloud:


*************
Alarm Service
*************

The alarm service available through the SKY-TV cloud, allows a user to set
up alarms that are listening on certain objects in the cloud, waiting for
specific parameters to occur. The alarm then changes their state from either
'ok' to 'alarm' or 'insufficient data' depending on your parameters.

For example: If you wanted to monitor a compute instance to see if the CPU
utilization exceeds 70% for more than 10 minutes. You could use an alarm to do
so. Then once the allarm has met this requirement, it can tell your system to
perform some action, parhaps spin up a new instance with more CPU power, or
increase the amount of VCPU's your instance is using. Whatever your goal is
the alarm keeps you informed of the state of your machine so you can impliment
things such as auto-scaling.

For more information on the Alarm service, you can visit `the openstack
documentation on aodh`_

.. _`the openstack documentation on aodh`: https://docs.openstack.org/aodh/latest/admin/telemetry-alarms.html
