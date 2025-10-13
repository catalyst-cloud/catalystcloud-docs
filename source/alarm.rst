.. _alarm:

#####
Alarm
#####

The Catalyst Cloud Alarm Service allows you to add cloud-based monitoring
for resource metrics in your project.

Alarms are used to track the state of resource metrics
published to the :ref:`Catalyst Cloud Metrics Service <metrics>`.
By setting up actions to perform when the alarm is triggered such as
sending notifications to external webhook URLs, this allows for easy
integration with your chosen monitoring and alerting systems and
saves some hassle trying to setup metric polling separately.

There are a number of alarm types available, with a variety of useful
configuration options that allow the Alarm Service to monitor
aspects of practically any kind of workload or resource on Catalyst Cloud.

The Alarm Service is also used by the :ref:`Catalyst Cloud Orchestration Service <cloud-orchestration>`
to power its auto-scaling and auto-healing features.

Table of Contents:

.. toctree::
   :maxdepth: 1

   alarm/overview
   alarm/faq

*********
Tutorials
*********

Instructions on how to create alarms for common use cases
are provided in the :ref:`Examples <alarm-examples>` section.
