# Set some command aliases and install jq
alias o="openstack"
alias lb="openstack loadbalancer"
alias osrl="openstack stack resource list"
sudo apt install -y jq

# Download the autohealing example yamls to a folder, go to that folder

# First, create the Head stack using the template files and wait until it's created successfully
# Change the default value of the parameters defined in autohealing.yaml
o stack create autohealing-test -t autohealing.yaml -e env.yaml
$ osrl $stackid
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
lbid=$(lb list | grep webserver_lb | awk '{print $2}')
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

# Now, create an Aodh alarm (not supported in CLI for now)
aodh_prefix="https://api.ostst.wgtn.cat-it.co.nz:8042"
token=$(openstack token issue -f yaml -c id | awk '{print $2}')
cat <<EOF | http post ${aodh_prefix}/v2/alarms X-Auth-Token:$token
{
  "alarm_actions": ["trust+heat://"],
  "name": "test_lb_alarm",
  "repeat_actions": false,
  "loadbalancer_member_health_rule": {
    "pool_id": "$poolid",
    "stack_id": "$stackid",
    "autoscaling_group_id": "$asgid"
  },
  "type": "loadbalancer_member_health"
}
EOF

# Log into one of the VMs and manually kill the webserver process
$ o server list
+--------------------------------------+-------------------------------------------------------+--------+-----------------------------------------+---------------------+---------+
| ID                                   | Name                                                  | Status | Networks                                | Image               | Flavor  |
+--------------------------------------+-------------------------------------------------------+--------+-----------------------------------------+---------------------+---------+
| 4a35a813-ac9a-4195-9b25-ad5d9381f68e | au-5z37-rowgvu2inhwa-25buammtmf2s-server-mkvfo7vxlv64 | ACTIVE | lingxian_net=192.168.2.200, 10.17.9.148 | cirros-0.3.1-x86_64 | m1.tiny |
| b80aa773-7330-4a00-9666-12980059050b | au-5z37-hlzbc66r2vrc-h6qxnp7n5wru-server-wyf3dksa6w3v | ACTIVE | lingxian_net=192.168.2.201, 10.17.9.147 | cirros-0.3.1-x86_64 | m1.tiny |
+--------------------------------------+-------------------------------------------------------+--------+-----------------------------------------+---------------------+---------+
$ ssh cirros@$fip
$ ps -ef | grep user-data | grep -v grep
  284 root     {user-data} /bin/sh /run/cirros/datasource/data/user-data
$ curl localhost
Welcome to my 192.168.2.201
$ sudo kill -9 284
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
