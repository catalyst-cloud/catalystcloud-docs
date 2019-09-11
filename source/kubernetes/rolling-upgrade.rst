###############
Rolling upgrade
###############

You can easily upgrade the version of a running Kubernetes cluster with minimum
or no impact to running applications. As long as the application deployment
best practices described in `Avoiding application downtime`_ are followed,
running applications will have no downtime during the upgrade.

When an upgrade is triggered, the following steps are \ performed to master and
worker nodes (one by one):

1. **Cordon**: The node becomes unavailable to schedule new workloads.
2. **Drain**: All workloads are evicted from the node.
3. **Upgrade**: The Kubernetes components are upgraded on the node.
4. **Uncordon**: The node becomes available to schedule workloads.

The upgrade process will safely evict all of the pods from the node before
performing maintenance on the node. Safe evictions allow the pod's containers
to gracefully terminate and will respect the ``PodDisruptionBudgets`` defined.

.. note::

    Rolling upgrades are only supported when using production Kubernetes
    cluster templates provided by the Catalyst Cloud without modifications.


*****************************
Avoiding application downtime
*****************************

It is possible to perform a Kubernetes upgrade without causing impact or
downtime to applications during the process. To do so, the best practices
below have to  be followed:

1. The application must be deployed and managed by a controller
   (such as a Deployment or ReplicaSet) with multiple replicas (replicas > 1).
2. A pod disruption budget policy must be applied and define the minimum
   number of pods required for the application to function properly
   (such as minAvailable > 1).
3. The container definition must have a liveness probe defined, to ensure the
   pod disruption policy budget is accounting for healthy replicas only.
4. The container definition must have a readiness probes defined, preventing
   pods from being re-introduced to the loadbalancer prematurely (before the
   application is ready to respond to requests).
5. Ideally the application should support the ``SIGTERM`` signal for graceful
   shutdown, or alternatively a ``preStop`` hook should be defined.

A :ref:`sample yaml file <example-yaml>` following these best practices is
provided as part of step by step tutorial at the end of this document.

*******************
Upgrading a cluster
*******************

Identify the cluster that needs to be upgraded
==============================================

The following command will list all Kubernetes clusters, so you can identify
the ID of the cluster that needs to be upgraded:

.. code-block:: bash

    $ openstack coe cluster list
    +--------------------------------------+------------------------------+-----------------+------------+--------------+-----------------+---------------+
    | uuid                                 | name                         | keypair         | node_count | master_count | status          | health_status |
    +--------------------------------------+------------------------------+-----------------+------------+--------------+-----------------+---------------+
    | b2b13567-2441-40da-852a-8a92f178ea42 | test_cluster                 | my_keypair      |          3 |            3 | CREATE_COMPLETE | HEALTHY       |
    +--------------------------------------+------------------------------+-----------------+------------+--------------+-----------------+---------------+

Identify the version of Kubernetes you want to upgrade to
=========================================================

The following command will list the Kubernetes cluster template versions
available, so you can choose the ID of the version you want to upgrade to:

.. code-block:: bash

    $ openstack coe template list
    +--------------------------------------+----------------------------------------------------------------------+
    | uuid                                 | name                                                                 |
    +--------------------------------------+----------------------------------------------------------------------+
    | 9c6e9df7-955a-465e-8460-e84e386624a0 | kubernetes-v1.11.6-prod-20190130                                     |
    | 4fcb04bd-22ba-4e1c-ab21-ff0339051d15 | kubernetes-v1.11.6-dev-20190130                                      |
    | b1d124db-b7cc-4085-8e56-859a0a7796e6 | kubernetes-v1.11.9-dev-20190402                                      |
    | cf337c0a-86e6-45de-9985-17914e78f181 | kubernetes-v1.11.9-prod-20190402                                     |
    | 967a2b86-8709-4c07-ae89-c0fe6d69d62d | kubernetes-v1.12.7-dev-20190403                                      |
    | f8fc0c67-84af-4bb8-89fb-d29f4c926975 | kubernetes-v1.12.7-prod-20190403                                     |
    +--------------------------------------+----------------------------------------------------------------------+

Upgrade a running Kubernetes cluster
====================================

Before upgrading, confirm the status of the cluster is ``CREATE_COMPLETE``
using the following command:

.. code-block:: bash

    $ openstack coe cluster show ${cluster_id} -c status
    +--------+-----------------+
    | Field  | Value           |
    +--------+-----------------+
    | status | CREATE_COMPLETE |
    +--------+-----------------+

Then, upgrade Kubernetes to a new version using the following command:

.. code-block:: bash

  $ openstack coe cluster upgrade ${cluster_id} ${cluster_template_id}


*****************
A working example
*****************

This tutorial will take you through the end-to-end process of upgrading a
Kubernetes cluster while monitoring the availability of a running application
(deployed according to best practices).

Prerequisites:

#. An existing Kubernetes cluster running a cluster template older than the
   latest template available. See the :ref:`quick start guide <k8s-quickstart>`
   for more information.
#. The `Kubernetes`_ and :ref:`OpenStack CLI installed <installing-the-cli>`.
#. An OpenStack and Kubernetes environment configuration set up. Check out
   :ref:`this guide <source-rc-file>` for setting up the OpenStack environment.

.. _`Kubernetes`: https://kubernetes.io/docs/tasks/tools/install-kubectl/

Deploying a sample application
==============================

The following command will deploy an example service for us to monitor while
the upgrade occurs. It will create an application using the vanilla Nginx
container, with a replica count of 2. It also defines:

* A ``postStart`` task to replace the standard Nginx welcome.
* A ``preStop`` command that allows the pod to shutdown in a graceful manner.
* A ``PodDisruptionBudget`` that ensure that there is a minimum of one pod
  running for this service at all times.
* A service of type ``LoadBalancer`` to expose the application to the world.

.. _example-yaml:

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
              exec:
                command: [
                  "sh", "-c",
                  "touch /tmp/healthy && sleep 3600",
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
          livenessProbe:
            httpGet:
              path: /healthz
              port: 80
              httpHeaders:
              - name: X-Custom-Header
                value: Awesome
            initialDelaySeconds: 3
            periodSeconds: 3
          readinessProbe:
            exec:
              command:
              - cat
              - /tmp/healthy
            initialDelaySeconds: 5
            periodSeconds: 5

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

In this example we will be upgrading an existing cluster called
**k8s-upgrade-test** from template version **v1.11.9** to **v1.12.7**.

In preparation for the upgrade, we need to identify the ID of the cluter we
wish to upgrade and the ID of the new cluster template we wish to upgrade to.

The ``openstack coe cluster list`` command will list all Kubernetes clusters
present in the current project and region:

.. code-block:: bash

  $ openstack coe cluster list
  +--------------------------------------+------------------+------------+------------+--------------+-----------------+---------------+
  | uuid                                 | name             | keypair    | node_count | master_count | status          | health_status |
  +--------------------------------------+------------------+------------+------------+--------------+-----------------+---------------+
  | b43ffae2-2d35-4951-b3f1-17a7acec3ade | k8s-upgrade-test | glyndavies |          3 |            3 | CREATE_COMPLETE | HEALTHY       |
  +--------------------------------------+------------------+------------+------------+--------------+-----------------+---------------+

.. note::

    Note the status of the cluster is ``CREATE_COMPLETE``, indicating an
    upgrade can be performed. Upgrades cannot be performed to a cluster while
    other orchestration actions are in progress.

We can check the current Kubernetes version that our cluster is running by
looking at the ``kube_tag`` label, like this.

.. code-block:: bash

  $ openstack coe cluster show k8s-upgrade-test -c labels -f yaml | grep kube_tag
  kube_tag: v1.11.9

The ``openstack coe cluster template list`` command will list the available
template versions:

.. code-block:: bash

  $ openstack coe cluster template list
  +--------------------------------------+----------------------------------+
  | uuid                                 | name                             |
  +--------------------------------------+----------------------------------+
  | 7f01d58a-ba9b-41a4-b53a-b5064c235852 | kubernetes-v1.12.7-prod-20190403 |
  | e18108b4-e33e-4bb1-bf02-77fc704371fa | kubernetes-v1.11.9-dev-20190402  |
  | 889fdf85-cf31-4369-a047-aa798e54d2f8 | kubernetes-v1.11.9-prod-20190402 |
  | 257050d6-57ba-474a-ac55-be06524bd289 | kubernetes-v1.12.7-dev-20190403  |
  +--------------------------------------+----------------------------------+

Before we start the upgrade, in another session, we can monitor the
availability of our sample application to confirm there is no interruption
during the process.

.. code-block:: bash

  $ while true; do curl -Is <service_ip> | head -n 1; sleep 2; done
  HTTP/1.1 200 OK
  HTTP/1.1 200 OK
  HTTP/1.1 200 OK

Now we can issue the upgrade command for our cluster, using the IDs gathered
above.

.. code-block:: bash

  $ openstack coe cluster upgrade b43ffae2-2d35-4951-b3f1-17a7acec3ade 7f01d58a-ba9b-41a4-b53a-b5064c235852

At any point it is possible to check on the state of the nodes within the
cluster to see how things are progressing by running the following.

.. code-block:: bash

  $ kubectl get node -w

Once the ``openstack coe cluster upgrade`` completes we can confirm that our
cluster now has a new Kubernetes version. The value we need to check is the
``kube_tag`` in the labels field.

.. code-block:: bash

  $ openstack coe cluster show k8s-upgrade-test -c labels -f yaml | grep kube_tag
  kube_tag: v1.12.7
