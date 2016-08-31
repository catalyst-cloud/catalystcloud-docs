###########
Terminology
###########

For simplicity and clarity, the Catalyst Cloud names its services after what
they do. For example, we call our compute service “compute”, instead of using
code-names like Nova or EC2.

However, it is important for you to know that our cloud is based on OpenStack
and that each service has a project name in OpenStack. This is because you may
want to refer to documentation or tutorials produced by other people on the
Internet, or use tools that refer to OpenStack’s native project names.

Below you will find a table with the services offered by the Catalyst Cloud and
how they map back to OpenStack project names, or services provided by other
cloud providers.

+--------------------------------+-----------------+-----------------+
| Service                        | OpenStack name  | Amazon AWS      |
+================================+=================+=================+
| Identity and access control    | Keystone        | IAM             |
+--------------------------------+-----------------+-----------------+
| Compute                        | Nova            | EC2             |
+--------------------------------+-----------------+-----------------+
| Network                        | Neutron         | VPC             |
+--------------------------------+-----------------+-----------------+
| Block storage                  | Cinder          | EBS             |
+--------------------------------+-----------------+-----------------+
| Object storage                 | Swift           | S3              |
+--------------------------------+-----------------+-----------------+
| Orchestration                  | Heat            | Cloud Formation |
+--------------------------------+-----------------+-----------------+
| Telemetry                      | Ceilometer      | Cloud Watch     |
+--------------------------------+-----------------+-----------------+
| Billing                        | Distil          |                 |
+--------------------------------+-----------------+-----------------+
| Registration                   | StackTask       |                 |
+--------------------------------+-----------------+-----------------+

