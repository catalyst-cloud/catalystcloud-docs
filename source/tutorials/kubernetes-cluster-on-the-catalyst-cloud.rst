###################################################
Building a Kubernetes Cluster on the Catalyst Cloud
###################################################

This tutorial shows you how to build and test a simple Kubernetes cluster on
the Catalyst Cloud.

`Kubernetes`_ is a set of tools for orchestrating and managing an arbitrary
number of containers, that may be organised as services. The user interface
for managing these clusters is abstracted away from the underlying compute
and storage resources, leaving that up to the master resource scheduler.

.. _Kubernetes: https://kubernetes.io/

The fundamental units that make up a `Kubernetes cluster`_ are:

* Pods
* Replication Controllers
* Services
* Nodes (Minions)

.. _Kubernetes cluster: http://kubernetes.io/docs/user-guide/

These resources can be organised and partitioned using namespaces, which
provides a convenient way of separating and scheduling virtual environments
such as Dev, Test, and Prod within the same infrastructure if desired.

The fundamental unit of a Pod is driven by the `Docker`_ container engine. This
gives the advantage of portability of application development between a vanilla
Docker environment and Kubernetes orchestration.

.. _Docker: https://www.docker.com

Setup
=====

This tutorial assumes a number of things:

* You are familiar with Docker and Kubernetes and its use case and wish to
  make use of Catalyst Cloud compute instances to run Kubenetes
* You are familiar with basic usage of the Catalyst Cloud (i.e. you have
  created your first instance as described at
  :ref:`launching-your-first-instance`)
* You will be setting up a cluster of Ubuntu 14.04 instances
* You will be using the ubuntu user
* You have sourced an openrc file, as described at :ref:`source-rc-file`



Installing a Kubernetes cluster
===============================

This repo guides you through the process of setting up your own Kubernetes
cluster on your existing OpenStack Cloud using its Orchestration Service, Heat.
This Kubernetes cluster is a proof of concept.


Technology involved:
--------------------

* Kubernetes: https://github.com/GoogleCloudPlatform/kubernetes
* Ubuntu: https://ubuntu.com/
* etcd: https://github.com/coreos/etcd
* flannel: https://github.com/coreos/flannel

Architecture
------------

The provisioned Cluster consists of five VMs. The first one, discovery, is a
dedicated etcd host. This allows easy etcd discovery thanks to a static
IP-Address.

A Kubernetes Master host is set up with the Kubernetes components apiserver,
scheduler, kube-register, controller-manager, kubelet as well as proxy.
This machine also gets a floating IP assigned and acts as an access point to
your Kubernetes cluster. The master also acts as a minion, which can be handy
for special case Pods that need specific dedicated storage etc.

Three further Kubernetes minion hosts are setup with the Kubernetes components
kubelet and proxy.

Start the cluster
-----------------

This Template was written for and tested on OpenStack Kilo. The architecture
is broken into three main stack components:

* Kubernetes network - a dedicated private network that the cluster runs on
* Master - the discovery and master nodes
* Minions - a stack that is repeated for each minion created

Each one of these components will appear in your Horizon dashboard ->
Orchestration -> Stacks list for management purposes.


Clone the Git Repo and prepare environment:
-------------------------------------------

Clone:

.. code-block:: bash

 $ git clone git@github.com:catalyst/catalystcloud-orchestration.git
 $ cd catalystcloud-orchestration/hot/ubuntu-14.04/kubernetes


Ensure that you have the kubectl command installed and in the PATH.
Follow the installation instructions here:
http://kubernetes.io/docs/user-guide/prereqs/ and test with:

.. code-block:: bash

 $ kubectl version


This will display the client version information and complain about the server
as you don't have one yet.

Next, set up your SSH agent, so that when it comes time to make the tunnel for
kubectl to reach the Kubernetes API, there will be no key issues.

Set up the agent, and add the key that will be used for access to the cluster
hosts:

.. code-block:: bash

 $ ssh-agent bash
 $ ssh-add /path/to/<your-key-pair>.pem


Following this, you will need to set the Open Stack environment (even if you
have already done this, do it again, as ssh-agent bash has reset ENV).
Re-source the rc file eg:

.. code-block:: bash

 $ . /path/to/rc/file/your-tenant-openrc.sh


Testing this will give a similar output to the following:

.. code-block:: bash

 $ openstack stack list
 +--------------------------------------+-----------------------+-----------------+----------------------+--------------+
 | ID                                   | Stack Name            | Stack Status    | Creation Time        | Updated Time |
 +--------------------------------------+-----------------------+-----------------+----------------------+--------------+
 | <STACK_ID>                           | a-stack               | CHECK_COMPLETE  | 2016-08-19T00:44:33Z | None         |
 +--------------------------------------+-----------------------+-----------------+----------------------+--------------+


Execution
---------

The entire process of running the cluster build is driven through using make
configured with a Makefile. While make is calling the appropriate Heat
stack-create commands, as would normally be done manually, it also helps ensure
the order of execution, and monitors the completion of each step before
continuing with the next process.

It is necessary to pass at least one parameter to the make process, of the
KEY_PAIR. This is the same key file name (without the .pem) as used in the
environment setup above. Check the other default values in the
templates/environment.yaml file (don't worry about NET_ID as it will be
substituted by the build process).

Start the build:

.. code-block:: bash

 $ cd /path/to/catalystcloud-orchestration/hot/ubuntu-14.04/kubernetes
 $ make KEY_PAIR=<your-key-pair>


The output will be something similar to the following:

.. code-block:: bash

 $:~/openstack/kubernetes-on-openstack-ubuntu$ make KEY_PAIR=piers-analytics
 heat stack-create -f templates/kubernetes-network.yaml -e templates/environment.yaml -P key-pair=piers-analytics k8s-network
 +--------------------------------------+-------------+--------------------+----------------------+
 | id                                   | stack_name  | stack_status       | creation_time        |
 +--------------------------------------+-------------+--------------------+----------------------+
 | xxxxxxxx-xxxx-4f5f-99f1-9734280c7a4f | k8s-network | CREATE_IN_PROGRESS | 2016-01-21T01:57:39Z |
 +--------------------------------------+-------------+--------------------+----------------------+

 #wait for 5 seconds so atleast the network is up
 sleep 5
 NETWORK_EXISTS=`heat stack-list 2>/dev/null | grep k8s-network | grep CREATE_COMPLETE`; \
        while [ -z "$NETWORK_EXISTS" ] ; \
        do \
    echo "waiting ..."; \
    heat stack-list 2>/dev/null | grep k8s-network; \
    sleep 3; \
    NETWORK_EXISTS=`heat stack-list 2>/dev/null | grep k8s-network | grep CREATE_COMPLETE` ; \
        done ; true
 waiting ...
 | xxxxxxxx-xxxx-4f5f-99f1-9734280c7a4f | k8s-network | CREATE_COMPLETE | 2016-01-21T01:57:39Z |
 heat output-show k8s-network private_net_id
 "xxxxxxxx-2a9a-4870-ab30-b1d9d8d4e7ce"
 NET_ID=`heat output-show k8s-network private_net_id | tr -d '"'`; \
        heat stack-create -f templates/kubernetes-master.yaml -e templates/environment.yaml \
        -P key-pair=piers-analytics -P private_net_id=${NET_ID} k8s-master
 +--------------------------------------+-------------+--------------------+----------------------+
 | id                                   | stack_name  | stack_status       | creation_time        |
 +--------------------------------------+-------------+--------------------+----------------------+
 | xxxxxxxx-xxxx-4f5f-99f1-9734280c7a4f | k8s-network | CREATE_COMPLETE    | 2016-01-21T01:57:39Z |
 | xxxxxxxx-9e26-4022-b3e9-96ec0bc7f9e0 | k8s-master  | CREATE_IN_PROGRESS | 2016-01-21T01:57:53Z |
 +--------------------------------------+-------------+--------------------+----------------------+
 # wait for 15 seconds so atleast the network is up
 sleep 15
 MASTER_EXISTS=`heat stack-list 2>/dev/null | grep k8s-master | grep CREATE_COMPLETE`; \
        while [ -z "$MASTER_EXISTS" ] ; \
        do \
    echo "waiting ..."; \
    heat stack-list 2>/dev/null | grep k8s-master; \
    sleep 3; \
    MASTER_EXISTS=`heat stack-list 2>/dev/null | grep k8s-master | grep CREATE_COMPLETE` ; \
        done ; true
 waiting ...
 | xxxxxxxx-9e26-4022-b3e9-96ec0bc7f9e0 | k8s-master  | CREATE_IN_PROGRESS | 2016-01-21T01:57:53Z |
 waiting ...
 | xxxxxxxx-9e26-4022-b3e9-96ec0bc7f9e0 | k8s-master  | CREATE_IN_PROGRESS | 2016-01-21T01:57:53Z |
 heat output-show k8s-master floating_ip
 "150.242.40.128"
 #  heat stack-create -f templates/kubernetes-minion.yaml -e templates/environment.yaml k8s-minion1; \
   heat stack-create -f templates/kubernetes-minion.yaml -e templates/environment.yaml k8s-minion2; \
     heat stack-create -f templates/kubernetes-minion.yaml -e templates/environment.yaml k8s-minion3;
 NET_ID=`heat output-show k8s-network private_net_id | tr -d '"'`; \
        echo "Minions to build: 1/3/1 2 3"; \
        for MINION in  1 2 3 ; \
        do \
        MINONS_EXIST=`heat stack-list 2>/dev/null | grep k8s-minion${MINION}`; \
        if [ -z "$MINONS_EXIST" ] ; then \
        heat stack-create -f templates/kubernetes-minion.yaml -e templates/environment.yaml \
         -P key-pair=piers-analytics -P private_net_id=${NET_ID} k8s-minion${MINION}; \
        while [ -z "$MINONS_EXIST" ] ; \
        do \
    echo "waiting ..."; \
    heat stack-list 2>/dev/null | grep k8s-minion; \
    sleep 3; \
    MINONS_EXIST=`heat stack-list 2>/dev/null | grep k8s-minion${MINION} | grep CREATE_COMPLETE` ; \
        done ; \
        fi ; \
        done ; true
 Minions to build: 1/3/1 2 3
 +--------------------------------------+-------------+--------------------+----------------------+
 | id                                   | stack_name  | stack_status       | creation_time        |
 +--------------------------------------+-------------+--------------------+----------------------+
 | xxxxxxxx-xxxx-4f5f-99f1-9734280c7a4f | k8s-network | CREATE_COMPLETE    | 2016-01-21T01:57:39Z |
 | xxxxxxxx-9e26-4022-b3e9-96ec0bc7f9e0 | k8s-master  | CREATE_COMPLETE    | 2016-01-21T01:57:53Z |
 | xxxxxxxx-1cff-4133-9809-6ae7a14cd64c | k8s-minion1 | CREATE_IN_PROGRESS | 2016-01-21T01:58:41Z |
 +--------------------------------------+-------------+--------------------+----------------------+
 waiting ...
 | xxxxxxxx-1cff-4133-9809-6ae7a14cd64c | k8s-minion1 | CREATE_IN_PROGRESS | 2016-01-21T01:58:41Z |
 waiting ...
 | xxxxxxxx-1cff-4133-9809-6ae7a14cd64c | k8s-minion1 | CREATE_IN_PROGRESS | 2016-01-21T01:58:41Z |
 +--------------------------------------+-------------+--------------------+----------------------+
 | id                                   | stack_name  | stack_status       | creation_time        |
 +--------------------------------------+-------------+--------------------+----------------------+
 | xxxxxxxx-xxxx-4f5f-99f1-9734280c7a4f | k8s-network | CREATE_COMPLETE    | 2016-01-21T01:57:39Z |
 | xxxxxxxx-9e26-4022-b3e9-96ec0bc7f9e0 | k8s-master  | CREATE_COMPLETE    | 2016-01-21T01:57:53Z |
 | xxxxxxxx-1cff-4133-9809-6ae7a14cd64c | k8s-minion1 | CREATE_COMPLETE    | 2016-01-21T01:58:41Z |
 | xxxxxxxx-af4d-4ccf-ac8b-f95ee264a616 | k8s-minion2 | CREATE_IN_PROGRESS | 2016-01-21T01:59:05Z |
 +--------------------------------------+-------------+--------------------+----------------------+
 waiting ...
 | xxxxxxxx-1cff-4133-9809-6ae7a14cd64c | k8s-minion1 | CREATE_COMPLETE    | 2016-01-21T01:58:41Z |
 | xxxxxxxx-af4d-4ccf-ac8b-f95ee264a616 | k8s-minion2 | CREATE_IN_PROGRESS | 2016-01-21T01:59:05Z |
 waiting ...
 | xxxxxxxx-1cff-4133-9809-6ae7a14cd64c | k8s-minion1 | CREATE_COMPLETE    | 2016-01-21T01:58:41Z |
 | xxxxxxxx-af4d-4ccf-ac8b-f95ee264a616 | k8s-minion2 | CREATE_IN_PROGRESS | 2016-01-21T01:59:05Z |
 +--------------------------------------+-------------+--------------------+----------------------+
 | id                                   | stack_name  | stack_status       | creation_time        |
 +--------------------------------------+-------------+--------------------+----------------------+
 | xxxxxxxx-xxxx-4f5f-99f1-9734280c7a4f | k8s-network | CREATE_COMPLETE    | 2016-01-21T01:57:39Z |
 | xxxxxxxx-9e26-4022-b3e9-96ec0bc7f9e0 | k8s-master  | CREATE_COMPLETE    | 2016-01-21T01:57:53Z |
 | xxxxxxxx-1cff-4133-9809-6ae7a14cd64c | k8s-minion1 | CREATE_COMPLETE    | 2016-01-21T01:58:41Z |
 | xxxxxxxx-af4d-4ccf-ac8b-f95ee264a616 | k8s-minion2 | CREATE_COMPLETE    | 2016-01-21T01:59:05Z |
 | xxxxxxxx-91df-4ea0-9071-574c007dcd28 | k8s-minion3 | CREATE_IN_PROGRESS | 2016-01-21T01:59:25Z |
 +--------------------------------------+-------------+--------------------+----------------------+
 waiting ...
 | xxxxxxxx-1cff-4133-9809-6ae7a14cd64c | k8s-minion1 | CREATE_COMPLETE    | 2016-01-21T01:58:41Z |
 | xxxxxxxx-af4d-4ccf-ac8b-f95ee264a616 | k8s-minion2 | CREATE_COMPLETE    | 2016-01-21T01:59:05Z |
 | xxxxxxxx-91df-4ea0-9071-574c007dcd28 | k8s-minion3 | CREATE_IN_PROGRESS | 2016-01-21T01:59:25Z |
 waiting ...
 | xxxxxxxx-1cff-4133-9809-6ae7a14cd64c | k8s-minion1 | CREATE_COMPLETE    | 2016-01-21T01:58:41Z |
 | xxxxxxxx-af4d-4ccf-ac8b-f95ee264a616 | k8s-minion2 | CREATE_COMPLETE    | 2016-01-21T01:59:05Z |
 | xxxxxxxx-91df-4ea0-9071-574c007dcd28 | k8s-minion3 | CREATE_IN_PROGRESS | 2016-01-21T01:59:25Z |
 heat stack-list
 +--------------------------------------+-------------+-----------------+----------------------+
 | id                                   | stack_name  | stack_status    | creation_time        |
 +--------------------------------------+-------------+-----------------+----------------------+
 | xxxxxxxx-xxxx-4f5f-99f1-9734280c7a4f | k8s-network | CREATE_COMPLETE | 2016-01-21T01:57:39Z |
 | xxxxxxxx-9e26-4022-b3e9-96ec0bc7f9e0 | k8s-master  | CREATE_COMPLETE | 2016-01-21T01:57:53Z |
 | xxxxxxxx-1cff-4133-9809-6ae7a14cd64c | k8s-minion1 | CREATE_COMPLETE | 2016-01-21T01:58:41Z |
 | xxxxxxxx-af4d-4ccf-ac8b-f95ee264a616 | k8s-minion2 | CREATE_COMPLETE | 2016-01-21T01:59:05Z |
 | xxxxxxxx-91df-4ea0-9071-574c007dcd28 | k8s-minion3 | CREATE_COMPLETE | 2016-01-21T01:59:25Z |
 +--------------------------------------+-------------+-----------------+----------------------+
 heat output-show k8s-master floating_ip
 "150.242.xxx.xxx"


All five stacks need to show CREATE_COMPLETE. On top of this, as the cloud-init
scripts for each host completes, each will be rebooted and need to settle into
the cluster. It may take a few minutes (actually 5-10) before Kubernetes is
up and running, so best to have a cup of tea at this stage.

Next Steps
==========

The next steps are to:

* create a tunnel for secure access to the Kubernetes API
* Setup cluster DNS
* Setup the Kubernetes UI service for process monitoring
* test the DNS service

Make the tunnel
---------------

The tunnel is created over ssh:

.. code-block:: bash

 $ make start_tunnel KEY_PAIR=<your-key-pair>


If the tunnel has been created successfully then you can test it with:

.. code-block:: bash

 $ kubectl cluster-info
 Kubernetes master is running at http://localhost:8080


The tunnel must be functioning before any of the subsequent steps can be
executed.


Test it
-------

To verify that the cluster is up, list all minions:

.. code-block:: bash

 $ kubectl get nodes

It should show you four minions (10.101.1.12 is the master):

.. code-block:: bash

 NAME          LABELS                               STATUS    AGE
 10.101.1.12   kubernetes.io/hostname=10.101.1.12   Ready     16m
 10.101.1.23   kubernetes.io/hostname=10.101.1.23   Ready     16m
 10.101.1.24   kubernetes.io/hostname=10.101.1.24   Ready     15m
 10.101.1.25   kubernetes.io/hostname=10.101.1.25   Ready     14m


Set up cluster DNS
-------------------

.. code-block:: bash

 $ make start_dns KEY_PAIR=<your-key-pair>

You must wait 30 seconds or so for the DNS process to settle, as this launches
a series of pods that need to download their images etc. before starting.

Setup the Kubernetes UI service for process monitoring
------------------------------------------------------

.. code-block:: bash

 $ make start_ui KEY_PAIR=<your-key-pair>

Check that the UI service (and other services) have started correctly with:

.. code-block:: bash

 $ kubectl get svc,pods,ep,rc --all-namespaces
 NAMESPACE     NAME                CLUSTER_IP                      EXTERNAL_IP   PORT(S)         SELECTOR           AGE
 default       kubernetes          10.100.0.1                      <none>        443/TCP         <none>             20m
 kube-system   kube-dns            10.100.0.10                     <none>        53/UDP,53/TCP   k8s-app=kube-dns   6m
 kube-system   kube-ui             10.100.242.90                   <none>        80/TCP          k8s-app=kube-ui    1m
 NAMESPACE     NAME                READY                           STATUS        RESTARTS        AGE
 kube-system   kube-dns-v9-5cy3h   4/4                             Running       0               6m
 kube-system   kube-ui-v4-thn08    1/1                             Running       0               1m
 NAMESPACE     NAME                ENDPOINTS                       AGE
 default       kubernetes          10.101.1.12:6443                20m
 kube-system   kube-dns            10.100.50.2:53,10.100.50.2:53   6m
 kube-system   kube-ui             10.100.98.2:8080                1m
 NAMESPACE     CONTROLLER          CONTAINER(S)  IMAGE(S)                                          SELECTOR                      REPLICAS   AGE
 kube-system   kube-dns-v9         etcd          gcr.io/google_containers/etcd:2.0.9               k8s-app=kube-dns,version=v9   1          6m
                                   kube2sky      gcr.io/google_containers/kube2sky:1.11
                                   skydns        gcr.io/google_containers/skydns:2015-03-11-001
                                   healthz       gcr.io/google_containers/exechealthz:1.0
 kube-system   kube-ui-v4          kube-ui       gcr.io/google_containers/kube-ui:v4               k8s-app=kube-ui,version=v4    1         1m


After the UI service and pods have been started, you can access it on:
http://localhost:8080/api/v1/proxy/namespaces/kube-system/services/kube-ui


Test the DNS service
--------------------

.. code-block:: bash

 $ make test_dns KEY_PAIR=<your-key-pair>

This will create a busybox pod and run a few ping tests, before tearing it down
again.


Further examples
----------------

For further Kubernetes examples, have a look at the `guestbook examples`_ .

.. _guestbook examples: https://github.com/kubernetes/kubernetes/blob/master/examples/guestbook/README.md


Expanding your minions!
-----------------------

More minion worker nodes can be created by specifying a start and stop range -
eg:

.. code-block:: bash

 $ make build_minions START=4 FINISH=5 KEY_PAIR=<your-key-pair>

This will give you two new nodes. Test that they have joined the cluster
(after an appropriate wait for the cloud-init build and reboot to complete):

.. code-block:: bash

 $ kubectl get nodes
 NAME          LABELS                               STATUS     AGE
 10.101.1.12   kubernetes.io/hostname=10.101.1.12   Ready      15m
 10.101.1.23   kubernetes.io/hostname=10.101.1.23   Ready      15m
 10.101.1.24   kubernetes.io/hostname=10.101.1.24   Ready      14m
 10.101.1.25   kubernetes.io/hostname=10.101.1.25   Ready      14m
 10.101.1.26   kubernetes.io/hostname=10.101.1.26   Ready      2m
 10.101.1.27   kubernetes.io/hostname=10.101.1.27   NotReady   1m

You may see a NotReady status for a new node - this should mean that it is up
but has not settled into the cluster yet. Wait and check again.


Cleaning Up
===========

Each component will be registered under orchestration in the Horizon dashboard,
so they are fully available there from a management perspective at `Stacks`_

.. _Stacks: https://dashboard.cloud.catalyst.net.nz/project/stacks/

Additionally, the Makefile has a set of actions for deleting each component:

* make clean_minions KEY_PAIR=<your-key-pair> - remove all the minons.
* make clean KEY_PAIR=  <your-key-pair> - remove the minions and master
* make realclean KEY_PAIR=<your-key-pair> - remove minons, master, and private
  network


Documentation
=============

* `Docker Documentation`_
* `Kubernetes Documentation`_

.. _Docker Documentation: https://www.docker.com
.. _Kubernetes Documentation: http://kubernetes.io/v1.1/docs/user-guide/README.html
