#############
Alarm service
#############

.. _alarm-service:

The alarm service allows you to create alarms that monitor objects on your
project and can inform other services or programs of any state changes that
occur. Because you are able to define the trigger conditions of your alarms,
you can customize how your system will react to certain events. The two most
common uses for the alarm service are for autohealing and autoscaling, each of
which are important for having a highly available and robust system.

By creating an alarm that is set up to monitor the health status of your
objects, you are able to inform the orchestration engine of any unhealthy
changes that may occur. Meaning that if any of the resources your alarm is
monitoring where to experience difficulties, your system can react instantly
with an automated process in place that will attempt to heal your resources as
soon as the issue arises.

Autoscaling works in much the same way, but instead of creating an alarm
that monitors the health of the resources, you create an alarm that monitors
the CPU usage of individual compute nodes. When you create your alarms, you can
specify the threshold values of what the CPU usage has to exceed before you
want to inform the orchestration engine that it needs to scale your instances;
whether it is scaling up or down.


.. toctree::
   :maxdepth: 1

   alarm-service/alarm-service-intro
   alarm-service/autohealing-example
   alarm-service/autoscaling
