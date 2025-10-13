.. _metrics-faq:

###
FAQ
###

**********************
How much does it cost?
**********************

The Catalyst Cloud Metrics Service is free to use for all customers.

You will not be charged for the collection of metrics your cloud
resources generate, or accessing them via the metrics API.

********************************************************
Do you have any dashboards for viewing resource metrics?
********************************************************

Sorry, we do not provide any dashboards that allow customers
to visualise resource metrics for their projects at this time.

*****************************
Can I publish my own metrics?
*****************************

Unfortunately we do not support customers publishing their own metrics
to the Metrics Service at this time.

***********************************************
Is an agent required/installed on my instances?
***********************************************

With the exception of memory usage (see below), the Metrics Service
does not use or require an agent to be installed on customer instances.

Metrics are collected external to workloads using non-invasive methods,
and none of your personal data stored on the cloud is read or inspected
by our telemetry services.

Memory usage metrics
====================

Memory usage metrics are exposed to our telemetry services using a
device driver pre-installed into our operating system images.

These metrics are collected securely and anonymously on a hypervisor level.
Only aggregated metrics such as total memory usage are collected; no additional information
(such as the applications running on your system) are exposed or collected.

You can opt-out of this functionality by disabling
the ``virtio_balloon`` kernel driver in your instance.

.. note::

  Memory usage metrics are not collected for Windows instances by default.
  Collecting memory usage metrics requires additional drivers to be installed.

  For more information, see :ref:`metrics-tutorials-memory-usage-metrics-on-windows`.

*************************************
Do you collect metrics for GPU usage?
*************************************

With :ref:`Compute C3-GPU <gpu-support>` and the other GPU-accelerated
compute flavours, instances use PCI passthrough to access physical GPUs.
This means that we are unable to collect metrics related to GPUs as they
are under the full control of your compute instance.

We recommend collecting your own metrics using the `NVIDIA DCGM Prometheus Exporter`_.
If you're using :ref:`GPU acceleration on Catalyst Cloud Kubernetes Service <kubernetes-gpu-acceleration>`,
a Helm chart is available for `installing the exporter into your cluster`_.

.. _`NVIDIA DCGM Prometheus Exporter`: https://docs.nvidia.com/datacenter/cloud-native/gpu-telemetry/latest/dcgm-exporter.html
.. _`installing the exporter into your cluster`: https://github.com/NVIDIA/dcgm-exporter#quickstart-on-kubernetes

*******************************************
Deleted resources are not marked as "ended"
*******************************************

The following resource types currently do not have the "ended at"
timestamp set when they are deleted:

* VPNs
* Load balancers
* Database instances
* Object storage containers

This will be implemented in the future, but in the meantime
it is possible to infer that resources no longer exist
through the absence of measures being published for their metrics.

On rare occasions the notifications that trigger the resource delete
events might not be  processed correctly. This means that every once
in a while you might see that a deleted resource has not been marked
as "ended" in the Metrics Service, even if it is not one of the above
resource types. Applications using the Metrics Service should be
implemented in such a way that it handles this case without any errors.

Once 90 days has passed after the resource is deleted, the Metrics Service
will expire the corresponding resource metadata and metrics.

*****************************************
One or more resource metrics do not exist
*****************************************

Please note that **it is normal for a metric to not exist for newly created resources**.

Metrics are only created for a resource if measures have been published for it;
when the metric does not exist, that means that no measures have been published
for it yet. Applications using the Metrics Service should be implemented with
this in mind.

New metrics should be created with measures populated shortly.

.. note::

  If the resource has existed for some time (more than 2 hours) and the resource
  or metric still does not exist in the Metrics Service, or exists but is not
  receiving new measures when it should, please raise a ticket via the `Support Centre`_.

  .. _`Support Centre`: https://catalystcloud.nz/support/support-centre
