.. _metrics:

#######
Metrics
#######

The Catalyst Cloud Metrics Service provides observability into the cloud resources running in your project.

We collect telemetry on all running cloud resources on a regular basis.
The Metrics Service provides an API that allows you to:

* Find out what resources currently exist, or previously existed, in your project
* Access useful metrics for monitoring the health, resource consumption and
  performance of resources running in your project

We keep resource metrics for up to 90 days, which makes the Metrics Service
useful for looking at historical data in addition to monitoring currently
running resources.

The :ref:`Alarm <alarm>` and :ref:`Orchestration <cloud-orchestration>` services also make use
of the Metrics Service to allow actions to be performed when metric thresholds are reached, such as
:ref:`auto-scaling <autoscaling-on-catalyst-cloud>` and sending notifications to webhook URLs.

.. note::

  The Metrics Service is currently in **Beta**.

  If you encounter any issues while using this service,
  please get in touch via the `Support Centre`_.

  .. _`Support Centre`: https://catalystcloud.nz/support/support-centre

Table of Contents:

.. toctree::
   :maxdepth: 1

   metrics/getting-started
   metrics/overview
   metrics/reference
   metrics/faq

*********
Tutorials
*********

Additional examples of using the Catalyst Cloud Metrics Service
can be found in the :ref:`Metrics Tutorials <metrics-tutorials>` section.
