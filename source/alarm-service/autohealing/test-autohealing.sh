# WGTN parameters
e044255f-40c2-48e5-a5f2-60d423e3ec54 | ubuntu-18.04-x86_64
e0ba6b88-5360-492c-9c3d-119948356fd3 | public-net
550677db-0232-418b-aeb5-f461cf907967 | private-net-1 | 0cc9ef08-6627-454f-842f-ecb84687cf92
584a384a-10db-4efa-9238-f2ead2239c0a | aodh-alarms

# HLZ parameters
0da75c8a-787d-48cd-bb74-e979fc5ceb58 | ubuntu-18.04-x86_64
f10ad6de-a26d-4c29-8c64-2a7418d47f8f | public-net
452fc8b7-218d-4279-99b2-3d46f9d016b7 | private-net | 0d10e475-045b-4b90-a378-d0dc2f66c150
4c8c6c80-2b3b-4258-8e96-cb5ddc70189d | aodh-alarms

# Set some command aliases and install jq
alias o="openstack"
alias lb="openstack loadbalancer"
alias osrl="openstack stack resource list"
alias osl="openstack stack list"
sudo apt install -y jq

# Download the autohealing examples to a folder, go to that folder
# if changes are made to the templates validate before running
openstack orchestration template validate -f yaml -t autohealing.yaml
openstack orchestration template validate -f yaml -t webserver.yaml

# First, create the Head stack using the template files and wait until it's created successfully
# Change the default value of the parameters defined in autohealing.yaml
o stack create autohealing-test -t autohealing.yaml -e env.yaml
export stackid=$(o stack show autohealing-test -c id -f value) && echo $stackid

watch openstack stack resource list $stackid
+----------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
| resource_name              | physical_resource_id                 | resource_type              | resource_status | updated_time         |
+----------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
| loadbalancer_public_ip     | d54dcfd2-944d-48e3-830f-8cdbc46373a2 | OS::Neutron::FloatingIP    | CREATE_COMPLETE | 2019-10-10T01:26:34Z |
| autoscaling_group          | 7a4f0dc9-5ff9-40ce-8bb8-e621574501b6 | OS::Heat::AutoScalingGroup | CREATE_COMPLETE | 2019-10-10T01:26:34Z |
| listener                   | 1a0f2cd2-0d45-42f2-929c-7efd3674dc34 | OS::Octavia::Listener      | CREATE_COMPLETE | 2019-10-10T01:26:35Z |
| loadbalancer_healthmonitor | 2773d0c1-bdcd-41c1-905d-a0c163e9c74c | OS::Octavia::HealthMonitor | CREATE_COMPLETE | 2019-10-10T01:26:34Z |
| loadbalancer_pool          | 30129a16-f6b7-434f-9648-09c306d699f8 | OS::Octavia::Pool          | CREATE_COMPLETE | 2019-10-10T01:26:35Z |
| loadbalancer               | 5f9ea90e-97ae-4844-867e-3de70b32abf3 | OS::Octavia::LoadBalancer  | CREATE_COMPLETE | 2019-10-10T01:26:35Z |
+----------------------------+--------------------------------------+----------------------------+-----------------+----------------------+

# Verify that we could send HTTP request to the load balancer VIP, the backend VMs IP addresses are shown alternatively.
# The VIP floating IP could be found in the stack output.
$ o stack output show $stackid --all
+-------+-----------------------------------------+
| Field | Value                                   |
+-------+-----------------------------------------+
| lb_ip | {                                       |
|       |   "output_value": "10.17.9.145",        |
|       |   "output_key": "lb_ip",                |
|       |   "description": "No description given" |
|       | }                                       |
+-------+-----------------------------------------+
$ while true; do curl $vip; sleep 2; done
Welcome to my 192.168.2.200
Welcome to my 192.168.2.201
Welcome to my 192.168.2.200
Welcome to my 192.168.2.201

# Get the resources IDs
lbid=$(lb list | grep webserver_lb | awk '{print $2}');
asgid=$(o stack resource list $stackid | grep autoscaling_group | awk '{print $4}');
poolid=$(lb status show $lbid | jq -r '.loadbalancer.listeners[0].pools[0].id')

# Verify the load balancer members are all healthy
$ lb member list $poolid
+--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
| id                                   | name | project_id                       | provisioning_status | address       | protocol_port | operating_status | weight |
+--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
| 4eeac1a8-7837-41d9-8299-8d8f9f691b69 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.200 |            80 | ONLINE           |      1 |
| 2acbd21e-39d5-41fe-8fb9-b3d61333f0c9 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.201 |            80 | ONLINE           |      1 |
+--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+

# perform the alarm setup using openstack cli
$ echo $lbid $asgid $poolid $stackid
0db8dcc8-77c1-4682-8213-21f4e90cafd1
9ec5bb8c-3b7f-4a71-858d-cb73d0d03b4e
0da0911a-0b07-4937-99ab-c6f6e3404c39
cc55271e-ddcd-4db0-8803-265f23297849

$ openstack alarm create --name test_lb_alarm \
--type loadbalancer_member_health \
--alarm-action trust+heat:// \
--repeat-actions false \
--autoscaling-group-id $asgid \
--pool-id $poolid \
--stack-id $stackid

+---------------------------+---------------------------------------+
| Field                     | Value                                 |
+---------------------------+---------------------------------------+
| alarm_actions             | ['trust+heat:']                       |
| alarm_id                  | 8c701d87-679a-4c27-939b-360ac356de58  |
| autoscaling_group_id      | 9ec5bb8c-3b7f-4a71-858d-cb73d0d03b4e  |
| description               | loadbalancer_member_health alarm rule |
| enabled                   | True                                  |
| insufficient_data_actions | []                                    |
| name                      | test_lb_alarm                         |
| ok_actions                | []                                    |
| pool_id                   | 0da0911a-0b07-4937-99ab-c6f6e3404c39  |
| project_id                | eac679e4896146e6827ce29d755fe289      |
| repeat_actions            | False                                 |
| severity                  | low                                   |
| stack_id                  | cc55271e-ddcd-4db0-8803-265f23297849  |
| state                     | insufficient data                     |
| state_reason              | Not evaluated yet                     |
| state_timestamp           | 2019-10-31T01:19:22.992154            |
| time_constraints          | []                                    |
| timestamp                 | 2019-10-31T01:19:22.992154            |
| type                      | loadbalancer_member_health            |
| user_id                   | 4b934c44d8b24e60acad9609b641bee3      |
+---------------------------+---------------------------------------+


# Log into one of the VMs and manually kill the webserver process
$ o server list
+--------------------------------------+-------------------------------------------------------+--------+-----------------------------------------+---------------------+---------+
| ID                                   | Name                                                  | Status | Networks                                | Image               | Flavor  |
+--------------------------------------+-------------------------------------------------------+--------+-----------------------------------------+---------------------+---------+
| 4a35a813-ac9a-4195-9b25-ad5d9381f68e | au-5z37-rowgvu2inhwa-25buammtmf2s-server-mkvfo7vxlv64 | ACTIVE | lingxian_net=192.168.2.200, 10.17.9.148 | cirros-0.3.1-x86_64 | m1.tiny |
| b80aa773-7330-4a00-9666-12980059050b | au-5z37-hlzbc66r2vrc-h6qxnp7n5wru-server-wyf3dksa6w3v | ACTIVE | lingxian_net=192.168.2.201, 10.17.9.147 | cirros-0.3.1-x86_64 | m1.tiny |
+--------------------------------------+-------------------------------------------------------+--------+-----------------------------------------+---------------------+---------+

$ ssh ubuntu@103.197.62.142
$ curl localhost
Welcome to my 10.0.0.105
$ ps -ef |grep bash|grep script|grep -v grep
root      1149  1117  0 19:24 ?        00:00:00 /bin/bash /var/lib/cloud/instance/scripts/part-001
ubuntu    3233  3230  0 19:50 pts/0    00:00:00 -bash
$ sudo kill -9 1149
$ curl localhost
curl: (7) couldnt connect to host


# After a few seconds, you should see there is one load balancer member in ERROR operating_status.
$ lb member list $poolid
+--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
| id                                   | name | project_id                       | provisioning_status | address       | protocol_port | operating_status | weight |
+--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
| 4eeac1a8-7837-41d9-8299-8d8f9f691b69 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.200 |            80 | ONLINE           |      1 |
| 2acbd21e-39d5-41fe-8fb9-b3d61333f0c9 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.201 |            80 | ERROR            |      1 |
+--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+

# Aodh will automatically trigger Heat stack update, keep checking the autoscaling_group resource status. At the same time, there should be only one IP address in the http response.
$ while true; do curl $vip; sleep 2; done
Welcome to my 192.168.2.200
Welcome to my 192.168.2.200
Welcome to my 192.168.2.200
Welcome to my 192.168.2.200
$ osrl $stackid
+----------------------------+--------------------------------------+----------------------------+--------------------+----------------------+
| resource_name              | physical_resource_id                 | resource_type              | resource_status    | updated_time         |
+----------------------------+--------------------------------------+----------------------------+--------------------+----------------------+
| loadbalancer_public_ip     | d54dcfd2-944d-48e3-830f-8cdbc46373a2 | OS::Neutron::FloatingIP    | CREATE_COMPLETE    | 2019-10-10T01:26:34Z |
| autoscaling_group          | 7a4f0dc9-5ff9-40ce-8bb8-e621574501b6 | OS::Heat::AutoScalingGroup | UPDATE_IN_PROGRESS | 2019-10-10T01:53:06Z |
| listener                   | 1a0f2cd2-0d45-42f2-929c-7efd3674dc34 | OS::Octavia::Listener      | CREATE_COMPLETE    | 2019-10-10T01:26:35Z |
| loadbalancer_healthmonitor | 2773d0c1-bdcd-41c1-905d-a0c163e9c74c | OS::Octavia::HealthMonitor | CREATE_COMPLETE    | 2019-10-10T01:26:34Z |
| loadbalancer_pool          | 30129a16-f6b7-434f-9648-09c306d699f8 | OS::Octavia::Pool          | CREATE_COMPLETE    | 2019-10-10T01:26:35Z |
| loadbalancer               | 5f9ea90e-97ae-4844-867e-3de70b32abf3 | OS::Octavia::LoadBalancer  | CREATE_COMPLETE    | 2019-10-10T01:26:35Z |
+----------------------------+--------------------------------------+----------------------------+--------------------+----------------------+

# After a few minutes, the stack status goes back to healthy. The ERROR load balancer member is replaced.
$ osrl $stackid
+----------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
| resource_name              | physical_resource_id                 | resource_type              | resource_status | updated_time         |
+----------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
| loadbalancer_public_ip     | d54dcfd2-944d-48e3-830f-8cdbc46373a2 | OS::Neutron::FloatingIP    | CREATE_COMPLETE | 2019-10-10T01:26:34Z |
| autoscaling_group          | 7a4f0dc9-5ff9-40ce-8bb8-e621574501b6 | OS::Heat::AutoScalingGroup | UPDATE_COMPLETE | 2019-10-10T01:53:06Z |
| listener                   | 1a0f2cd2-0d45-42f2-929c-7efd3674dc34 | OS::Octavia::Listener      | CREATE_COMPLETE | 2019-10-10T01:26:35Z |
| loadbalancer_healthmonitor | 2773d0c1-bdcd-41c1-905d-a0c163e9c74c | OS::Octavia::HealthMonitor | CREATE_COMPLETE | 2019-10-10T01:26:34Z |
| loadbalancer_pool          | 30129a16-f6b7-434f-9648-09c306d699f8 | OS::Octavia::Pool          | CREATE_COMPLETE | 2019-10-10T01:26:35Z |
| loadbalancer               | 5f9ea90e-97ae-4844-867e-3de70b32abf3 | OS::Octavia::LoadBalancer  | CREATE_COMPLETE | 2019-10-10T01:26:35Z |
+----------------------------+--------------------------------------+----------------------------+-----------------+----------------------+
$ lb member list $poolid
+--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
| id                                   | name | project_id                       | provisioning_status | address       | protocol_port | operating_status | weight |
+--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
| 4eeac1a8-7837-41d9-8299-8d8f9f691b69 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.200 |            80 | ONLINE           |      1 |
| f354fe18-c801-4729-90bb-0af29048ef46 |      | bb609fa4634849919b0192c060c02cd7 | ACTIVE              | 192.168.2.202 |            80 | ONLINE           |      1 |
+--------------------------------------+------+----------------------------------+---------------------+---------------+---------------+------------------+--------+
$ while true; do curl $vip; sleep 2; done
Welcome to my 192.168.2.200
Welcome to my 192.168.2.202
Welcome to my 192.168.2.200
Welcome to my 192.168.2.202

$ o stack delete $stackid



# Auto-scaling example

As for auto-scaling  :

Once scaling group deployed

ssh to one server

install stress

$ stress -c 8 -t 1200s

c
+--------------------------------------+-----------+---------------------------------------------------------+-------------------+----------+---------+
| alarm_id                             | type      | name                                                    | state             | severity | enabled |
+--------------------------------------+-----------+---------------------------------------------------------+-------------------+----------+---------+
| 9c245bcc-d31e-4219-ab50-f19d2dd8d0e9 | threshold | autohealing-test-ceilometer_cpu_high_alarm-hpik52fcq7xc | insufficient data | low      | True    |
| 11578915-f140-4095-a977-51ae861f1cd2 | threshold | autohealing-test-ceilometer_cpu_low_alarm-xzclw6ejci64  | insufficient data | low      | True    |
+--------------------------------------+-----------+---------------------------------------------------------+-------------------+----------+---------+

$ openstack alarm list
+--------------------------------------+-----------+---------------------------------------------------------+-------+----------+---------+
| alarm_id                             | type      | name                                                    | state | severity | enabled |
+--------------------------------------+-----------+---------------------------------------------------------+-------+----------+---------+
| 9c245bcc-d31e-4219-ab50-f19d2dd8d0e9 | threshold | autohealing-test-ceilometer_cpu_high_alarm-hpik52fcq7xc | alarm | low      | True    |
| 11578915-f140-4095-a977-51ae861f1cd2 | threshold | autohealing-test-ceilometer_cpu_low_alarm-xzclw6ejci64  | ok    | low      | True    |
+--------------------------------------+-----------+---------------------------------------------------------+-------+----------+---------+


os alarm show autohealing-test-ceilometer_cpu_high_alarm-hpik52fcq7xc
+---------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field                     | Value                                                                                                                                                                                                                                                                                                                                                                       |
+---------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| alarm_actions             | ['https://api.nz-hlz-1.catalystcloud.io:8004/v1/eac679e4896146e6827ce29d755fe289/stacks/autohealing-test/13f0119d-2b7c-4406-91b5-b646369ca03b/resources/scaleup_policy/signal']                                                                                                                                                                                             |
| alarm_id                  | 9c245bcc-d31e-4219-ab50-f19d2dd8d0e9                                                                                                                                                                                                                                                                                                                                        |
| description               | Alarm when cpu_util is gt a avg of 5.0 over 60 seconds                                                                                                                                                                                                                                                                                                                      |
| enabled                   | True                                                                                                                                                                                                                                                                                                                                                                        |
| insufficient_data_actions | []                                                                                                                                                                                                                                                                                                                                                                          |
| name                      | autohealing-test-ceilometer_cpu_high_alarm-hpik52fcq7xc                                                                                                                                                                                                                                                                                                                     |
| ok_actions                | []                                                                                                                                                                                                                                                                                                                                                                          |
| project_id                | eac679e4896146e6827ce29d755fe289                                                                                                                                                                                                                                                                                                                                            |
| repeat_actions            | False                                                                                                                                                                                                                                                                                                                                                                       |
| severity                  | low                                                                                                                                                                                                                                                                                                                                                                         |
| state                     | alarm                                                                                                                                                                                                                                                                                                                                                                       |
| state_reason              | Transition to alarm due to 1 samples outside threshold, most recent: 5.26166666667                                                                                                                                                                                                                                                                                          |
| state_timestamp           | 2019-11-07T01:02:52.083002                                                                                                                                                                                                                                                                                                                                                  |
| threshold_rule            | {'meter_name': 'cpu_util', 'evaluation_periods': 1, 'period': 60, 'statistic': 'avg', 'threshold': 5.0, 'query': [{'field': 'metadata.user_metadata.server_group', 'value': '13f0119d-2b7c-4406-91b5-b646369ca03b', 'op': 'eq'}, {'field': 'project_id', 'value': 'eac679e4896146e6827ce29d755fe289', 'op': 'eq'}], 'comparison_operator': 'gt', 'exclude_outliers': False} |
| time_constraints          | []                                                                                                                                                                                                                                                                                                                                                                          |
| timestamp                 | 2019-11-07T01:02:52.083002                                                                                                                                                                                                                                                                                                                                                  |
| type                      | threshold                                                                                                                                                                                                                                                                                                                                                                   |
| user_id                   | 4b934c44d8b24e60acad9609b641bee3                                                                                                                                                                                                                                                                                                                                            |
+---------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

os stack resource show autohealing-test scaleup_policy
+------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field                  | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
+------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| attributes             | {'signal_url': 'https://api.nz-hlz-1.catalystcloud.io:8004/v1/eac679e4896146e6827ce29d755fe289/stacks/autohealing-test/13f0119d-2b7c-4406-91b5-b646369ca03b/resources/scaleup_policy/signal', 'alarm_url': 'https://api.nz-hlz-1.catalystcloud.io:8000/v1/signal/arn%3Aopenstack%3Aheat%3A%3Aeac679e4896146e6827ce29d755fe289%3Astacks/autohealing-test/13f0119d-2b7c-4406-91b5-b646369ca03b/resources/scaleup_policy?Timestamp=2019-11-07T01%3A01%3A19Z&SignatureMethod=HmacSHA256&AWSAccessKeyId=a8551ce97a5744b3baf238ed603febc5&SignatureVersion=2&Signature=RTpBm40JegQmZ6b5YEOOOqeizNZEa7id2YMpUM1Iu8k%3D'} |
| creation_time          | 2019-11-07T01:01:19Z                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| description            |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| links                  | [{'href': 'https://api.nz-hlz-1.catalystcloud.io:8004/v1/eac679e4896146e6827ce29d755fe289/stacks/autohealing-test/13f0119d-2b7c-4406-91b5-b646369ca03b/resources/scaleup_policy', 'rel': 'self'}, {'href': 'https://api.nz-hlz-1.catalystcloud.io:8004/v1/eac679e4896146e6827ce29d755fe289/stacks/autohealing-test/13f0119d-2b7c-4406-91b5-b646369ca03b', 'rel': 'stack'}]                                                                                                                                                                                                                                        |
| logical_resource_id    | scaleup_policy                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| physical_resource_id   | 2099d91fdf0147d1ae6fc5cbfdd6b4eb                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| required_by            | ['ceilometer_cpu_high_alarm']                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| resource_name          | scaleup_policy                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| resource_status        | CREATE_COMPLETE                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| resource_status_reason | state changed                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| resource_type          | OS::Heat::ScalingPolicy                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| updated_time           | 2019-11-07T01:01:19Z                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
+------------------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+


Auto-scaling policy never triggered even though the alrm did. Then alarm state reverts back even though the load average at this time is 8.00 7.68 6.21

$ openstack alarm list
+--------------------------------------+-----------+---------------------------------------------------------+-------------------+----------+---------+
| alarm_id                             | type      | name                                                    | state             | severity | enabled |
+--------------------------------------+-----------+---------------------------------------------------------+-------------------+----------+---------+
| 9c245bcc-d31e-4219-ab50-f19d2dd8d0e9 | threshold | autohealing-test-ceilometer_cpu_high_alarm-hpik52fcq7xc | insufficient data | low      | True    |
| 11578915-f140-4095-a977-51ae861f1cd2 | threshold | autohealing-test-ceilometer_cpu_low_alarm-xzclw6ejci64  | insufficient data | low      | True    |
+--------------------------------------+-----------+---------------------------------------------------------+-------------------+----------+---------+

os alarm show autohealing-test-ceilometer_cpu_high_alarm-hpik52fcq7xc
+---------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field                     | Value                                                                                                                                                                                                                                                                                                                                                                       |
+---------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| alarm_actions             | ['https://api.nz-hlz-1.catalystcloud.io:8004/v1/eac679e4896146e6827ce29d755fe289/stacks/autohealing-test/13f0119d-2b7c-4406-91b5-b646369ca03b/resources/scaleup_policy/signal']                                                                                                                                                                                             |
| alarm_id                  | 9c245bcc-d31e-4219-ab50-f19d2dd8d0e9                                                                                                                                                                                                                                                                                                                                        |
| description               | Alarm when cpu_util is gt a avg of 5.0 over 60 seconds                                                                                                                                                                                                                                                                                                                      |
| enabled                   | True                                                                                                                                                                                                                                                                                                                                                                        |
| insufficient_data_actions | []                                                                                                                                                                                                                                                                                                                                                                          |
| name                      | autohealing-test-ceilometer_cpu_high_alarm-hpik52fcq7xc                                                                                                                                                                                                                                                                                                                     |
| ok_actions                | []                                                                                                                                                                                                                                                                                                                                                                          |
| project_id                | eac679e4896146e6827ce29d755fe289                                                                                                                                                                                                                                                                                                                                            |
| repeat_actions            | False                                                                                                                                                                                                                                                                                                                                                                       |
| severity                  | low                                                                                                                                                                                                                                                                                                                                                                         |
| state                     | insufficient data                                                                                                                                                                                                                                                                                                                                                           |
| state_reason              | 1 datapoints are unknown                                                                                                                                                                                                                                                                                                                                                    |
| state_timestamp           | 2019-11-07T01:02:52.083002                                                                                                                                                                                                                                                                                                                                                  |
| threshold_rule            | {'meter_name': 'cpu_util', 'evaluation_periods': 1, 'period': 60, 'statistic': 'avg', 'threshold': 5.0, 'query': [{'field': 'metadata.user_metadata.server_group', 'value': '13f0119d-2b7c-4406-91b5-b646369ca03b', 'op': 'eq'}, {'field': 'project_id', 'value': 'eac679e4896146e6827ce29d755fe289', 'op': 'eq'}], 'comparison_operator': 'gt', 'exclude_outliers': False} |
| time_constraints          | []                                                                                                                                                                                                                                                                                                                                                                          |
| timestamp                 | 2019-11-07T01:02:52.083002                                                                                                                                                                                                                                                                                                                                                  |
| type                      | threshold                                                                                                                                                                                                                                                                                                                                                                   |
| user_id                   | 4b934c44d8b24e60acad9609b641bee3                                                                                                                                                                                                                                                                                                                                            |
+---------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
