# Create the Heat stack
openstack stack create autoscaling-test -t autoscaling.yaml -e env.yaml
stackid=7defea9b-f046-41f1-9101-8174e87cc520
watch -n 5 -d "openstack stack resource list $stackid"

# Wait until the stack creation is finished.
+---------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
| resource_name             | physical_resource_id                 | resource_type              | resource_status | updated_time         |
+---------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
| loadbalancer_public_ip    | 0be62e24-0d6b-4044-9a75-dba61b82a606 | OS::Neutron::FloatingIP    | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| scaleup_policy            | affc60f0704545b8a2812dfedc954a8f     | OS::Heat::ScalingPolicy    | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| scaledown_policy          | 7606b8985d2f4874bd77fbd3fceedac4     | OS::Heat::ScalingPolicy    | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| autoscaling_group         | 5b241e29-3ba1-4aa5-9140-ffd5e3598b6b | OS::Heat::AutoScalingGroup | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| listener                  | c4bf1a3c-b837-4f1d-90d4-894508dadc82 | OS::Octavia::Listener      | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| loadbalancer_pool         | 6e9d06c8-0cd8-45c2-a8e4-7f49ca649b91 | OS::Octavia::Pool          | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| ceilometer_cpu_low_alarm  | eacd0f48-9cfa-4c9b-973d-658a546ffebe | OS::Aodh::Alarm            | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| ceilometer_cpu_high_alarm | 86c30d0d-1f2f-40c2-b5e1-b9daffedd400 | OS::Aodh::Alarm            | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| loadbalancer              | a468fc94-0d78-471f-bc66-7f8fc203ccca | OS::Octavia::LoadBalancer  | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
+---------------------------+--------------------------------------+----------------------------+-----------------+----------------------+

# Wait for at least 10 min to make sure there are some cpu_util samples in Ceilometer.
# Using admin user, 'project_id' is Keystone project ID of the user who creates Heat stack, timestamp is the time in UTC.
$ ceilometer sample-list -q "meter=cpu_util; project_id=b23a5e41d1af4c20974bf58b4dff8e5a; timestamp>2019-11-24T10:00:00; metadata.user_metadata.stack=$stackid"
+--------------------------------------+--------------------------------------+----------+-------+---------------+------+---------------------+
| ID                                   | Resource ID                          | Name     | Type  | Volume        | Unit | Timestamp           |
+--------------------------------------+--------------------------------------+----------+-------+---------------+------+---------------------+
| a2c1636c-0f0d-11ea-a8eb-661e32309945 | 25947f8f-adfa-42a8-a95f-6b0b24230451 | cpu_util | gauge | 4.67079646018 | %    | 2019-11-24T22:56:22 |
| a2b44510-0f0d-11ea-a8eb-661e32309945 | fcd22172-753b-423c-a672-e6cc18159011 | cpu_util | gauge | 4.73982300885 | %    | 2019-11-24T22:56:22 |
+--------------------------------------+--------------------------------------+----------+-------+---------------+------+---------------------+

# Switch to the normal user, check the Aodh alarms
$ openstack alarm list
+--------------------------------------+-----------+---------------------------------------------------------+-------+----------+---------+
| alarm_id                             | type      | name                                                    | state | severity | enabled |
+--------------------------------------+-----------+---------------------------------------------------------+-------+----------+---------+
| eacd0f48-9cfa-4c9b-973d-658a546ffebe | threshold | autoscaling-test-ceilometer_cpu_low_alarm-rsx7mhm47og4  | ok    | low      | True    |
| 86c30d0d-1f2f-40c2-b5e1-b9daffedd400 | threshold | autoscaling-test-ceilometer_cpu_high_alarm-mkhdkjcilujh | ok    | low      | True    |
+--------------------------------------+-----------+---------------------------------------------------------+-------+----------+---------+

# Get the VM floating IPs, ssh into a VM and run a cpu-consuming task
$ openstack stack resource list $stackid
+---------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
| resource_name             | physical_resource_id                 | resource_type              | resource_status | updated_time         |
+---------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
| loadbalancer_public_ip    | 0be62e24-0d6b-4044-9a75-dba61b82a606 | OS::Neutron::FloatingIP    | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| scaleup_policy            | affc60f0704545b8a2812dfedc954a8f     | OS::Heat::ScalingPolicy    | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| scaledown_policy          | 7606b8985d2f4874bd77fbd3fceedac4     | OS::Heat::ScalingPolicy    | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| autoscaling_group         | 5b241e29-3ba1-4aa5-9140-ffd5e3598b6b | OS::Heat::AutoScalingGroup | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| listener                  | c4bf1a3c-b837-4f1d-90d4-894508dadc82 | OS::Octavia::Listener      | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| loadbalancer_pool         | 6e9d06c8-0cd8-45c2-a8e4-7f49ca649b91 | OS::Octavia::Pool          | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| ceilometer_cpu_low_alarm  | eacd0f48-9cfa-4c9b-973d-658a546ffebe | OS::Aodh::Alarm            | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| ceilometer_cpu_high_alarm | 86c30d0d-1f2f-40c2-b5e1-b9daffedd400 | OS::Aodh::Alarm            | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
| loadbalancer              | a468fc94-0d78-471f-bc66-7f8fc203ccca | OS::Octavia::LoadBalancer  | CREATE_COMPLETE | 2019-11-24T22:37:13Z |
+---------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
$ openstack stack resource list 5b241e29-3ba1-4aa5-9140-ffd5e3598b6b # autoscaling_group ID
+---------------+--------------------------------------+----------------+-----------------+----------------------+
| resource_name | physical_resource_id                 | resource_type  | resource_status | updated_time         |
+---------------+--------------------------------------+----------------+-----------------+----------------------+
| twcxj3dyged2  | b0c5132f-dc11-4b15-b0bd-486ef805c63a | OS::LB::Server | CREATE_COMPLETE | 2019-11-24T22:38:20Z |
| zhe22npzqc57  | d6d21520-23b6-440e-a8a8-f72699869b19 | OS::LB::Server | CREATE_COMPLETE | 2019-11-24T22:38:20Z |
+---------------+--------------------------------------+----------------+-----------------+----------------------+
$ o server list | grep twcxj3dyged2; o server list | grep zhe22npzqc57 # resource name
| 25947f8f-adfa-42a8-a95f-6b0b24230451 | au-dchs-twcxj3dyged2-c3rjmd766iwg-server-azbhcmeut2re | ACTIVE            | lingxian_net=10.0.10.24, 103.197.62.7                                                                                                            | cirros-0.4.0                 | c1.c1r05 |
| fcd22172-753b-423c-a672-e6cc18159011 | au-dchs-zhe22npzqc57-lkm2c2ea4sch-server-qbywu6dy6jqt | ACTIVE            | lingxian_net=10.0.10.25, 103.197.62.81                                                                                                           | cirros-0.4.0                 | c1.c1r05 |

# Log into a VM and run a task
$ ssh cirros@103.197.62.7
Warning: Permanently added '103.197.63.10' (ECDSA) to the list of known hosts.
$ while [ 1 ] ; do echo $((13**99)) 1>/dev/null 2>&1; done &
$ Connection to 103.197.63.10 closed.

# Wait for at least 10 min

# Switch to the admin user, check the samples again
$ ceilometer sample-list -q "meter=cpu_util; project_id=b23a5e41d1af4c20974bf58b4dff8e5a; timestamp>2019-11-24T10:00:00; metadata.user_metadata.stack=$stackid"
+--------------------------------------+--------------------------------------+----------+-------+---------------+------+---------------------+
| ID                                   | Resource ID                          | Name     | Type  | Volume        | Unit | Timestamp           |
+--------------------------------------+--------------------------------------+----------+-------+---------------+------+---------------------+
| 4515d374-0cce-11ea-999d-faf51046c147 | 1d64271e-4314-4a3d-8505-8a17a20eda6d | cpu_util | gauge | 81.1510067114 | %    | 2019-11-22T02:17:44 |
| 12092e68-0cce-11ea-a8eb-661e32309945 | e62d2fb5-79ad-4867-87df-9abb965aef97 | cpu_util | gauge | 4.25125628141 | %    | 2019-11-22T02:16:19 |
| e1b07df8-0ccc-11ea-999d-faf51046c147 | 1d64271e-4314-4a3d-8505-8a17a20eda6d | cpu_util | gauge | 3.52317880795 | %    | 2019-11-22T02:07:48 |
| ae5f613a-0ccc-11ea-a8eb-661e32309945 | e62d2fb5-79ad-4867-87df-9abb965aef97 | cpu_util | gauge | 4.2056384743  | %    | 2019-11-22T02:06:22 |
| 79869ae2-0ccb-11ea-999d-faf51046c147 | 1d64271e-4314-4a3d-8505-8a17a20eda6d | cpu_util | gauge | 3.51273344652 | %    | 2019-11-22T01:57:44 |
+--------------------------------------+--------------------------------------+----------+-------+---------------+------+---------------------+

# Switch to the normal user, check the alarms
$ openstack alarm list
+--------------------------------------+-----------+---------------------------------------------------------+-------+----------+---------+
| alarm_id                             | type      | name                                                    | state | severity | enabled |
+--------------------------------------+-----------+---------------------------------------------------------+-------+----------+---------+
| eacd0f48-9cfa-4c9b-973d-658a546ffebe | threshold | autoscaling-test-ceilometer_cpu_low_alarm-rsx7mhm47og4  | ok    | low      | True    |
| 86c30d0d-1f2f-40c2-b5e1-b9daffedd400 | threshold | autoscaling-test-ceilometer_cpu_high_alarm-mkhdkjcilujh | alarm | low      | True    |
+--------------------------------------+-----------+---------------------------------------------------------+-------+----------+---------+

# Check the members of the autoscaling group.
$ openstack stack resource list 5b241e29-3ba1-4aa5-9140-ffd5e3598b6b # autoscaling_group ID
+---------------+--------------------------------------+----------------+--------------------+----------------------+
| resource_name | physical_resource_id                 | resource_type  | resource_status    | updated_time         |
+---------------+--------------------------------------+----------------+--------------------+----------------------+
| twcxj3dyged2  | b0c5132f-dc11-4b15-b0bd-486ef805c63a | OS::LB::Server | UPDATE_COMPLETE    | 2019-11-24T23:06:30Z |
| tptp7be7ou2q  | 0158105c-15d0-4343-8e99-ec1250f3e054 | OS::LB::Server | CREATE_IN_PROGRESS | 2019-11-24T23:06:29Z |
| zhe22npzqc57  | d6d21520-23b6-440e-a8a8-f72699869b19 | OS::LB::Server | UPDATE_COMPLETE    | 2019-11-24T23:06:32Z |
+---------------+--------------------------------------+----------------+--------------------+----------------------+
$ openstack stack resource list 5b241e29-3ba1-4aa5-9140-ffd5e3598b6b
+---------------+--------------------------------------+----------------+-----------------+----------------------+
| resource_name | physical_resource_id                 | resource_type  | resource_status | updated_time         |
+---------------+--------------------------------------+----------------+-----------------+----------------------+
| twcxj3dyged2  | b0c5132f-dc11-4b15-b0bd-486ef805c63a | OS::LB::Server | UPDATE_COMPLETE | 2019-11-24T23:06:30Z |
| tptp7be7ou2q  | 0158105c-15d0-4343-8e99-ec1250f3e054 | OS::LB::Server | CREATE_COMPLETE | 2019-11-24T23:06:29Z |
| zhe22npzqc57  | d6d21520-23b6-440e-a8a8-f72699869b19 | OS::LB::Server | UPDATE_COMPLETE | 2019-11-24T23:06:32Z |
+---------------+--------------------------------------+----------------+-----------------+----------------------+
