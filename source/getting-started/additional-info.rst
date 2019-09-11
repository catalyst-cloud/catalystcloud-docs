.. _additional-info:


**********************
Additional information
**********************

This section is to inform you on other information that we deem important but
does not fall under the categories of services, access or administration.


Quotas
======

The Catalyst Cloud provides customers with a quota mechanism to protect them
from accidentally launching too many resources. This helps prevent unexpected
and significant costs being invoiced to our customers. In fact, every cloud
provider has a similar mechanism, but most do not expose this information to
their customers.

We allow customers to see their current per region quota on the overview page
of the dashboard. Quotas are a soft cap that can be changed at any time
according to your needs. A quota change may be requested via the `Quota
Management`_ panel.

Catalyst may give you a call if you are about to exceed your quota and ask you
whether you would like us to pro-actively increase the quota for you.

.. _Quota Management: https://dashboard.cloud.catalyst.net.nz/management/quota/


Terminology
===========

Catalyst Cloud uses natural names for its services. For example, we call our
compute service “compute”, instead of Nova or EC2.

If you have previous cloud computing or OpenStack experience, the table below
describes how our services map back to OpenStack code-names and other cloud
providers.

+--------------------------------+-----------------+-----------------+
| Service                        | OpenStack       | Amazon AWS      |
+================================+=================+=================+
| Identity and Access Control    | Keystone        | IAM             |
+--------------------------------+-----------------+-----------------+
| Compute                        | Nova            | EC2             |
+--------------------------------+-----------------+-----------------+
| Network                        | Neutron         | VPC             |
+--------------------------------+-----------------+-----------------+
| Block Storage                  | Cinder          | EBS             |
+--------------------------------+-----------------+-----------------+
| Object Storage                 | Swift           | S3              |
+--------------------------------+-----------------+-----------------+
| Load Balancer                  | Octavia         | ELB             |
+--------------------------------+-----------------+-----------------+
| Orchestration                  | Heat            | Cloud Formation |
+--------------------------------+-----------------+-----------------+
| Telemetry                      | Ceilometer      | Cloud Watch     |
+--------------------------------+-----------------+-----------------+
| Billing                        | Distil          |                 |
+--------------------------------+-----------------+-----------------+
| Registration                   | StackTask       |                 |
+--------------------------------+-----------------+-----------------+

Please note that functionality between cloud providers differs. The table above
is only intended to map the broader domain space of each cloud service, as
opposed to specific features.
