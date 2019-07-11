###########
Terminology
###########

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
