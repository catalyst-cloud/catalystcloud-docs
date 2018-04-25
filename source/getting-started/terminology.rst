###########
Terminology
###########

Catalyst Cloud names its services after what they do. As an example, we call
our compute service “compute”, which clearly describes its function. This is
more straightforward, and easier to remember than unintuitive code-names such
as Nova or EC2.

Since Catalyst Cloud is based on OpenStack, it is important and useful to be
familiar with the names that apply to each part of OpenStack. This is practical
when searching for, and referring to, supplementary OpenStack documentation.
Many resources on the Internet will refer to OpenStack’s native project titles.

Below you will find a table listing the services offered by Catalyst Cloud and
how they map back to OpenStack project names, or services provided by other
cloud providers.

+--------------------------------+-----------------+-----------------+
| Service                        | OpenStack name  | Amazon AWS      |
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

