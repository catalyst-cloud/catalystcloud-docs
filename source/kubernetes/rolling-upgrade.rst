##########################
Kubernetes rolling upgrade
##########################

The rolling upgrade allows for the upgrade for the underlying Kubernetes
version that is used across all pods in a given cluster. The intention is to
allow this action to be performed on a live system with no interuption to
services running on the cluster.

The caveat here is that in order for a service to remain uninterrupted it has
to be deployed as part of a replicated application through the likes of a
Deployment, or similar, that expects at least 2 replicas to be running at any
time.

*******************
The upgrade process
*******************

The upgrade process for each node in the cluster is identical regardless of
whether they are a master or a worker.

Each node will go through the following states:

* Cordon - the node being upgraded will be marked as unschedulable to ensure
  no new pods can be deployed on that node.
* Drain - evicts all running pods from the node. This requires that the API
  server supports ``disruptions``, the 'drain' process then waits for graceful
  termination of the running pods.
* Upgrade - the underlying Node containers are replaced with a later version
  that includes the new Kubernetes version.
* Uncordon - the node is marked as being available to take scheduled workloads.

The pod disruption policy
=========================

As part of this process it is possible to control how many pods of a given type
are required to be running at any given time through the use of a
PodDisruptionBudget policy. This limits the number of pods of a replicated
application that are down simultaneously from voluntary disruptions.

The updgrade process will use ``kubectl drain`` to remove a node from a
service, this will safely evict all of the pods from the node before
performing maintenance on the node. Safe evictions allow the pod’s containers
to gracefully terminate and will respect the PodDisruptionBudgets you have
specified.

*****************
A working example
*****************

Prerequisites:

* an application deployed with multiple replicas (> 1)
* Pod disruption budget policy stasting minimum replica count

The following YAML file will deploy an example service for us to monitor
while the upgrade occurs. It will create an application using the vanilla
Nginx container, with a replica count of 2.

It also defines:

* A ``postStart`` task to replace the standard Nginx welcome.
* A ``preStop`` command that allows the pod to shutdown in a graceful manner.
* A PodDisruptionBudget that ensure that there is a minimum of one pod running
  for this service at all times.
* A service of type loadbalancer to expose the application to the world.

Now we can run the following so will have a service to test while we run the
upgrade.

.. code-block:: bash

  cat <<EOF | kubectl apply -f -
  ---
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: nginx-deployment
    labels:
      app: nginx
  spec:
    replicas: 2
    selector:
      matchLabels:
        app: nginx
    template:
      metadata:
        labels:
          app: nginx
      spec:
        containers:
        - name: nginx
          image: nginx:1.15
          ports:
          - containerPort: 80
          lifecycle:
            postStart:
              exec:
                command: [
                  "sh", "-c",
                  "echo 'Hello World from Nginx' > /usr/share/nginx/html/index.html",
                ]
            preStop:
              exec:
                command: [
                  "sh", "-c",
                  # Introduce a delay to the shutdown sequence to wait for the
                  # pod eviction event to propagate. Then, gracefully shutdown
                  # nginx.
                  "sleep 5 && /usr/sbin/nginx -s quit",
                ]
  ---
  apiVersion: policy/v1beta1
  kind: PodDisruptionBudget
  metadata:
    name: nginx-pdb
  spec:
    minAvailable: 1
    selector:
      matchLabels:
        app: nginx
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name: nginx-service
  spec:
    selector:
      app: nginx
    type: LoadBalancer
    ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  EOF

Running the upgrade
===================

For our example we will be upgrading the cluster **k8s-upgrade-test** from
template version **v1.11.9** to **v1.12.7** . To perform the upgrade we need to
identify the ID of the new cluster template we wish to upgrade to and the ID
of the cluter we wish to upgrade.

It is important to note that when upgrading a cluster the label keys associated
with the cluster template need to be the same, though the version can vary.

If we compare out current tempalte with the new one we can see the label
content matches.

.. code-block:: bash

    v1.11.9
    | labels                | {'kube_tag': 'v1.11.9', 'cloud_provider_enabled': 'true', 'prometheus_monitoring': 'true', 'cloud_provider_tag': '1.14.0-catalyst', 'container_infra_prefix': 'docker.io/catalystcloud/', 'ingress_controller': 'octavia', 'octavia_ingress_controller_tag': '1.14.0-catalyst', 'heat_container_agent_tag': 'stein-dev', 'etcd_volume_size': '20'} |

    v1.12.7
    | labels                | {'kube_tag': 'v1.12.7', 'cloud_provider_enabled': 'true', 'prometheus_monitoring': 'true', 'cloud_provider_tag': '1.14.0-catalyst', 'container_infra_prefix': 'docker.io/catalystcloud/', 'ingress_controller': 'octavia', 'octavia_ingress_controller_tag': '1.14.0-catalyst', 'heat_container_agent_tag': 'stein-dev', 'etcd_volume_size': '20'} |

If we list the clusters available we can then view the details of the cluster
we wish to upgrade and the available templates so that we can get the
required IDs.

.. code-block:: bash

  $ openstack coe cluster template list
  +--------------------------------------+------------------+------------+------------+--------------+-----------------+---------------+
  | uuid                                 | name             | keypair    | node_count | master_count | status          | health_status |
  +--------------------------------------+------------------+------------+------------+--------------+-----------------+---------------+
  | b43ffae2-2d35-4951-b3f1-17a7acec3ade | k8s-upgrade-test | glyndavies |          3 |            3 | CREATE_COMPLETE | HEALTHY       |
  +--------------------------------------+------------------+------------+------------+--------------+-----------------+---------------+


  $ openstack coe cluster show k8s-upgrade-test
  +----------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | Field                | Value                                                                                                                                                                                                                                                                                                                                                         |
  +----------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | status               | CREATE_COMPLETE                                                                                                                                                                                                                                                                                                                                               |
  | health_status        | HEALTHY                                                                                                                                                                                                                                                                                                                                                       |
  | cluster_template_id  | 889fdf85-cf31-4369-a047-aa798e54d2f8                                                                                                                                                                                                                                                                                                                          |
  | node_addresses       | ['103.197.61.112', '103.197.61.114', '103.197.61.113']                                                                                                                                                                                                                                                                                                        |
  | uuid                 | b43ffae2-2d35-4951-b3f1-17a7acec3ade                                                                                                                                                                                                                                                                                                                          |
  | stack_id             | 63bc0612-83fd-4c61-bd6c-b73ebf07320d                                                                                                                                                                                                                                                                                                                          |
  | status_reason        | Stack CREATE completed successfully                                                                                                                                                                                                                                                                                                                           |
  | created_at           | 2019-08-21T19:05:16+00:00                                                                                                                                                                                                                                                                                                                                     |
  | updated_at           | 2019-08-21T19:19:51+00:00                                                                                                                                                                                                                                                                                                                                     |
  | coe_version          | v1.11.9                                                                                                                                                                                                                                                                                                                                                       |
  | labels               | {'cloud_provider_enabled': 'true', 'prometheus_monitoring': 'true', 'kube_tag': 'v1.11.9', 'heat_container_agent_tag': 'stein-dev', 'container_infra_prefix': 'docker.io/catalystcloud/', 'ingress_controller': 'octavia', 'cloud_provider_tag': '1.14.0-catalyst', 'etcd_volume_size': '20', 'octavia_ingress_controller_tag': '1.14.0-catalyst'}            |
  | faults               |                                                                                                                                                                                                                                                                                                                                                               |
  | keypair              | glyndavies                                                                                                                                                                                                                                                                                                                                                    |
  | api_address          | https://103.197.61.0:6443                                                                                                                                                                                                                                                                                                                                     |
  | master_addresses     | ['103.197.61.111', '103.197.61.1', '103.197.61.10']                                                                                                                                                                                                                                                                                                           |
  | create_timeout       | 60                                                                                                                                                                                                                                                                                                                                                            |
  | node_count           | 3                                                                                                                                                                                                                                                                                                                                                             |
  | discovery_url        | https://discovery.etcd.io/a9d7ad4dcc8ed9cdbc5a37d00b012c3d                                                                                                                                                                                                                                                                                                    |
  | master_count         | 3                                                                                                                                                                                                                                                                                                                                                             |
  | container_version    | 1.12.6                                                                                                                                                                                                                                                                                                                                                        |
  | name                 | k8s-upgrade-test                                                                                                                                                                                                                                                                                                                                              |
  | master_flavor_id     | c1.c2r4                                                                                                                                                                                                                                                                                                                                                       |
  | flavor_id            | c1.c4r8                                                                                                                                                                                                                                                                                                                                                       |
  | health_status_reason | {'k8s-upgrade-test-zcuuaiib6nqt-minion-1.Ready': 'True', 'k8s-upgrade-test-zcuuaiib6nqt-minion-0.Ready': 'True', 'k8s-upgrade-test-zcuuaiib6nqt-minion-2.Ready': 'True', 'k8s-upgrade-test-zcuuaiib6nqt-master-1.Ready': 'True', 'api': 'ok', 'k8s-upgrade-test-zcuuaiib6nqt-master-0.Ready': 'True', 'k8s-upgrade-test-zcuuaiib6nqt-master-2.Ready': 'True'} |
  | project_id           | eac679e4896146e6827ce29d755fe289                                                                                                                                                                                                                                                                                                                              |
  +----------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

  $ openstack coe cluster template list
  +--------------------------------------+----------------------------------+
  | uuid                                 | name                             |
  +--------------------------------------+----------------------------------+
  | 7f01d58a-ba9b-41a4-b53a-b5064c235852 | kubernetes-v1.12.7-prod-20190403 |
  | e18108b4-e33e-4bb1-bf02-77fc704371fa | kubernetes-v1.11.9-dev-20190402  |
  | 889fdf85-cf31-4369-a047-aa798e54d2f8 | kubernetes-v1.11.9-prod-20190402 |
  | 257050d6-57ba-474a-ac55-be06524bd289 | kubernetes-v1.12.7-dev-20190403  |
  +--------------------------------------+----------------------------------+

Now we can issue the upgrade command for our cluster, using the IDs gathered
above.

.. code-block:: bash

  $ openstack coe cluster upgrade b43ffae2-2d35-4951-b3f1-17a7acec3ade 7f01d58a-ba9b-41a4-b53a-b5064c235852

At the same time, in another session, we can curl the service on it's IP
address to confirm that there is no interruption during the process.

.. code-block:: bash

  $ while true; do curl -Is <service_ip> | head -n 1; sleep 2; done
  HTTP/1.1 200 OK
  HTTP/1.1 200 OK
  HTTP/1.1 200 OK


At any point it is possible to check on the state of the nodes within the
cluster to see how things are progressing by running the following.

.. code-block:: bash

  $ kubectl get node -w

Once the ``openstack coe cluster upgrade`` completes we can confirm that our
cluster now has a new Kubernetes version. The value we need to check is the
``kube_tag`` in the labels field.

For the record the ``curl`` we were running in the second session did not
display a single interruption during the entire upgrade process.

.. code-block:: bash

  $openstack coe cluster show k8s-upgrade-test
  +----------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | Field                | Value                                                                                                                                                                                                                                                                                                                                                         |
  +----------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | status               | UPDATE_COMPLETE                                                                                                                                                                                                                                                                                                                                               |
  | health_status        | HEALTHY                                                                                                                                                                                                                                                                                                                                                       |
  | cluster_template_id  | 7f01d58a-ba9b-41a4-b53a-b5064c235852                                                                                                                                                                                                                                                                                                                          |
  | node_addresses       | ['103.197.61.112', '103.197.61.114', '103.197.61.113']                                                                                                                                                                                                                                                                                                        |
  | uuid                 | b43ffae2-2d35-4951-b3f1-17a7acec3ade                                                                                                                                                                                                                                                                                                                          |
  | stack_id             | 63bc0612-83fd-4c61-bd6c-b73ebf07320d                                                                                                                                                                                                                                                                                                                          |
  | status_reason        | Stack UPDATE completed successfully                                                                                                                                                                                                                                                                                                                           |
  | created_at           | 2019-08-21T19:05:16+00:00                                                                                                                                                                                                                                                                                                                                     |
  | updated_at           | 2019-08-26T00:45:40+00:00                                                                                                                                                                                                                                                                                                                                     |
  | coe_version          | v1.11.9                                                                                                                                                                                                                                                                                                                                                       |
  | labels               | {'cloud_provider_tag': '1.14.0-catalyst', 'cloud_provider_enabled': 'true', 'prometheus_monitoring': 'true', 'kube_tag': 'v1.12.7', 'container_infra_prefix': 'docker.io/catalystcloud/', 'ingress_controller': 'octavia', 'octavia_ingress_controller_tag': '1.14.0-catalyst', 'heat_container_agent_tag': 'stein-dev', 'etcd_volume_size': '20'}            |
  | faults               |                                                                                                                                                                                                                                                                                                                                                               |
  | keypair              | glyndavies                                                                                                                                                                                                                                                                                                                                                    |
  | api_address          | https://103.197.61.0:6443                                                                                                                                                                                                                                                                                                                                     |
  | master_addresses     | ['103.197.61.111', '103.197.61.1', '103.197.61.10']                                                                                                                                                                                                                                                                                                           |
  | create_timeout       | 60                                                                                                                                                                                                                                                                                                                                                            |
  | node_count           | 3                                                                                                                                                                                                                                                                                                                                                             |
  | discovery_url        | https://discovery.etcd.io/a9d7ad4dcc8ed9cdbc5a37d00b012c3d                                                                                                                                                                                                                                                                                                    |
  | master_count         | 3                                                                                                                                                                                                                                                                                                                                                             |
  | container_version    | 1.12.6                                                                                                                                                                                                                                                                                                                                                        |
  | name                 | k8s-upgrade-test                                                                                                                                                                                                                                                                                                                                              |
  | master_flavor_id     | c1.c2r4                                                                                                                                                                                                                                                                                                                                                       |
  | flavor_id            | c1.c4r8                                                                                                                                                                                                                                                                                                                                                       |
  | health_status_reason | {'k8s-upgrade-test-zcuuaiib6nqt-minion-1.Ready': 'True', 'k8s-upgrade-test-zcuuaiib6nqt-minion-0.Ready': 'True', 'k8s-upgrade-test-zcuuaiib6nqt-minion-2.Ready': 'True', 'k8s-upgrade-test-zcuuaiib6nqt-master-1.Ready': 'True', 'api': 'ok', 'k8s-upgrade-test-zcuuaiib6nqt-master-0.Ready': 'True', 'k8s-upgrade-test-zcuuaiib6nqt-master-2.Ready': 'True'} |
  | project_id           | eac679e4896146e6827ce29d755fe289                                                                                                                                                                                                                                                                                                                              |
  +----------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
