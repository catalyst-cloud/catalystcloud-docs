.. _alarm-faq:

###
FAQ
###

**********************************************
My alarm is stuck in "not evaluated yet" state
**********************************************

If an alarm stays in ``insufficent data`` state with the reason "Not evaluated yet"
for a long time after being created, this is usually caused by one of two things:

#. The resource being monitored, or the selected metric, is not
   generating any measures. Use the :ref:`Metrics Service <metrics>`
   to perform a query for the metrics you're trying to monitor, and
   make sure the data actually exists.
#. The query options configured on the alarm are incorrect.
   :ref:`Double check the alarm <alarm-get-details>` to make sure
   it is configured correctly, and if settings need to be changed,
   :ref:`update the alarm <alarm-update>` accordingly.
