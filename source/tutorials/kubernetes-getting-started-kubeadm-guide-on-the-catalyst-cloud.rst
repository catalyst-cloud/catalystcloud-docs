####################################################################################
Follow the "Installing Kubernetes on Linux with kubeadm" guide on the Catalyst Cloud
####################################################################################

`Kubernetes 1.4`_ released in September 2016 `introduced`_ the ``kubeadm``
command, which greatly simplifies setting up a Kubernetes cluster. Once Docker
and Kubernetes are installed on the nodes, cluster configuration is reduced to
two commands: ``kubeadm init`` which starts the master and ``kubeadm join``
which joins the nodes to the cluster.

This tutorial shows you how to easily set up Catalyst Cloud compute instances to
use with the `kubeadm getting started guide`_ tutorial available as part of
the `Kubernetes`_ `documentation`_.

.. _Kubernetes 1.4: http://blog.kubernetes.io/2016/09/kubernetes-1.4-making-it-easy-to-run-on-kuberentes-anywhere.html
.. _introduced: http://blog.kubernetes.io/2016/09/how-we-made-kubernetes-easy-to-install.html
.. _kubeadm getting started guide: https://kubernetes.io/docs/getting-started-guides/kubeadm/
.. _Kubernetes: https://kubernetes.io/
.. _documentation: https://kubernetes.io/docs/

This tutorial will use `Ansible`_ to create five nodes that correspond to the
examples used in the Kubernetes tutorial. After running the playbook, you will
have access to five hosts, exactly as described in the tutorial. A cleanup
playbook is provided to remove all resources when you have completed the
tutorial.

.. _Ansible: https://www.ansible.com/

.. warning::

 The ansible playbook creates four worker nodes using the c1.c1r1 flavor and
 one master node which uses the c1.c4r4 flavor. Remember to run the cleanup
 playbook after completing this tutorial to avoid incurring unnecessary costs.

Setup
=====

This tutorial assumes a number of things:

* You are interested in Kubernetes and wish to complete the tutorial.
* You are familiar with basic usage of the Catalyst Cloud (e.g. you have
  created your first instance as described at
  :ref:`launching-your-first-instance`)
* You have sourced an openrc file, as described at :ref:`source-rc-file`
* You have a basic understanding of how to use `Ansible`_ on the Catalyst Cloud
  as shown at :ref:`launching-your-first-instance-using-ansible`
* You have access to a suitable Catalyst Cloud project where you can create the
  cluster

Install Ansible
===============

Firstly you need to install Ansible as shown at
:ref:`launching-your-first-instance-using-ansible`.

When Ansible is installed, you should change directory to the
``example-playbooks/kubernetes-with-kubeadm`` directory within the
``catalystcloud-ansible`` git checkout.

.. code-block:: bash

 $ cd example-playbooks/kubernetes-with-kubeadm

Create the Nodes
================

We can now run the ``create-kubernetes-hosts.yaml`` playbook to create the
nodes:

.. code-block:: bash

 $ ansible-playbook create-kubernetes-hosts.yaml

The playbook run should take about 10 minutes. After it successfully completes
you are ready to follow the guide. As described in part one of the guide
`(1/4) Installing kubelet and kubeadm on your hosts`_, it:

* Provides five networked host machines running Ubuntu 16.04
* Ensures Docker Engine 1.11 or later is installed
* Ensures kubelet, kubectl and kubeadm are installed
* Provides host name resolution (master1, worker1-4) via SSH config on the
  management machine
* Provides in cluster name resolution using ``/etc/hosts`` on all nodes
* Installs the flannel pod network add-on yaml file on the master

.. _(1/4) Installing kubelet and kubeadm on your hosts: https://kubernetes.io/docs/getting-started-guides/kubeadm/#instructions


Initialising your master
========================

We will now follow the guide from section ``(2/4) Initializing your master``.

    The master is the machine where the “control plane” components run,
    including etcd (the cluster database) and the API server (which the kubectl
    CLI communicates with). All of these components run in pods started by
    kubelet.

To initialise the master, ssh to ``master1`` and run ``kubeadm init``.

.. code-block:: bash

 $ ssh master1
 ubuntu@master1:~$ sudo -i
 root@master1:~# kubeadm init
 [kubeadm] WARNING: kubeadm is in alpha, please do not use it for production clusters.
 [preflight] Running pre-flight checks
 [init] Using Kubernetes version: v1.5.3
 [tokens] Generated token: "347c61.ec190798c6001d04"
 [certificates] Generated Certificate Authority key and certificate.
 [certificates] Generated API Server key and certificate
 [certificates] Generated Service Account signing keys
 [certificates] Created keys and certificates in "/etc/kubernetes/pki"
 [kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/kubelet.conf"
 [kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/admin.conf"
 [apiclient] Created API client, waiting for the control plane to become ready
 [apiclient] All control plane components are healthy after 67.819478 seconds
 [apiclient] Waiting for at least one node to register and become ready
 [apiclient] First node is ready after 5.003500 seconds
 [apiclient] Creating a test deployment
 [apiclient] Test deployment succeeded
 [token-discovery] Created the kube-discovery deployment, waiting for it to become ready
 [token-discovery] kube-discovery is ready after 26.003861 seconds
 [addons] Created essential addon: kube-proxy
 [addons] Created essential addon: kube-dns

 Your Kubernetes master has initialised successfully!

 You should now deploy a pod network to the cluster.
 Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
     http://kubernetes.io/docs/admin/addons/

 You can now join any number of machines by running the following on each node:

 kubeadm join --token=<TOKEN> 192.168.99.100

Alternatively if you wish to use the ``flannel`` pod network add-on use the
``--pod-network-cidr`` flag to define the flannel subnet. If omitted,
``kube-dns`` pod will not start.

.. code-block:: bash

 root@master1:~# kubeadm init --pod-network-cidr 10.244.0.0/16

|

    Make a record of the kubeadm join command that kubeadm init outputs. You
    will need this in a moment. The key included here is secret; keep it safe —
    anyone with this key can add authenticated nodes to your cluster.

    The key is used for mutual authentication between the master and the
    joining nodes.

Installing a pod network
========================

    You must install a pod network add-on so that your pods can communicate
    with each other.

    **It is necessary to do this before you try to deploy any applications to
    your cluster, and before kube-dns starts up. Note also that kubeadm
    only supports CNI based networks and therefore kubenet based networks will
    not work.**

Using weave (recommended)
-------------------------

To use the weave pod network add-on issue the following command:

.. code-block:: bash

 root@master1:~# kubectl apply -f https://git.io/weave-kube
 daemonset "weave-net" created

Using flannel
-------------

.. note::

 If you wish to use flannel, ensure you specified a --pod-network-cidr when
 running kubeadm init

As an alternative, you can use the ``flannel`` pod network add-on. Ansible
installed the yaml file in roots home directory on the master node, so you can
simply issue the following command:

.. code-block:: bash

 root@master1:~# kubectl apply -f kube-flannel.yml
 serviceaccount "flannel" created
 configmap "kube-flannel-cfg" created
 daemonset "kube-flannel-ds" created

Ensure kube-dns is running
==========================

Once a pod network has been installed, confirm that it is working by checking
that the kube-dns pod is running:

.. code-block:: bash

 root@master1:~# kubectl get pods --all-namespaces
 NAMESPACE     NAME                              READY     STATUS    RESTARTS   AGE
 default       kube-flannel-ds-3hsdj             2/2       Running   0          1m
 kube-system   dummy-2088944543-69gpw            1/1       Running   0          4m
 kube-system   etcd-master1                      1/1       Running   0          3m
 kube-system   kube-apiserver-master1            1/1       Running   0          4m
 kube-system   kube-controller-manager-master1   1/1       Running   0          3m
 kube-system   kube-discovery-1769846148-n4fjq   1/1       Running   0          4m
 kube-system   kube-dns-2924299975-fx7lv         4/4       Running   0          3m
 kube-system   kube-proxy-k87q7                  1/1       Running   0          3m
 kube-system   kube-scheduler-master1            1/1       Running   0          3m

Add worker nodes to cluster
===========================

Now that we have the ``kube-dns`` pod running we can add our workers to the
cluster. Consult the output of ``kubeadm init`` to find the command to execute
on the workers.

.. code-block:: bash

 $ ssh worker1
 ubuntu@worker1:~$ sudo -i
 root@worker1:~# kubeadm join --token=<TOKEN> 192.168.99.100
 [kubeadm] WARNING: kubeadm is in alpha, please do not use it for production clusters.
 [preflight] Running pre-flight checks
 [tokens] Validating provided token
 [discovery] Created cluster info discovery client, requesting info from "http://192.168.99.100:9898/cluster-info/v1/?token-id=347c61"
 [discovery] Cluster info object received, verifying signature using given token
 [discovery] Cluster info signature and contents are valid, will use API endpoints [https://192.168.99.100:6443]
 [bootstrap] Trying to connect to endpoint https://192.168.99.100:6443
 [bootstrap] Detected server version: v1.5.3
 [bootstrap] Successfully established connection with endpoint "https://192.168.99.100:6443"
 [csr] Created API client to obtain unique certificate for this node, generating keys and certificate signing request
 [csr] Received signed certificate from the API server:
 Issuer: CN=kubernetes | Subject: CN=system:node:worker1 | CA: false
 Not before: 2017-02-18 03:08:00 +0000 UTC Not After: 2018-02-18 03:08:00 +0000 UTC
 [csr] Generating kubelet configuration
 [kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/kubelet.conf"

 Node join complete:
 * Certificate signing request sent to master and response
   received.
 * Kubelet informed of new secure connection details.

 Run 'kubectl get nodes' on the master to see this machine join.

Repeat this process on the remaining workers. You can run kubectl get nodes to
observe workers joining the cluster:

.. code-block:: bash

 root@master1:~# kubectl get nodes
 NAME      STATUS         AGE
 master1   Ready,master   13m
 worker1   Ready          2m
 worker2   Ready          0s

Installing a sample application
===============================

You are going to install the sock shop sample microservice application:

.. code-block:: bash

 root@master1:~# kubectl create namespace sock-shop
 namespace "sock-shop" created
 root@master1:~# kubectl apply -n sock-shop -f "https://github.com/microservices-demo/microservices-demo/blob/master/deploy/kubernetes/complete-demo.yaml?raw=true"
 namespace "sock-shop" configured
 deployment "cart-db" created
 service "cart-db" created
 deployment "cart" created
 service "cart" created
 deployment "catalogue-db" created
 service "catalogue-db" created
 deployment "catalogue" created
 service "catalogue" created
 deployment "front-end" created
 service "front-end" created
 deployment "orders-db" created
 service "orders-db" created
 deployment "orders" created
 service "orders" created
 deployment "payment" created
 service "payment" created
 deployment "queue-master" created
 service "queue-master" created
 deployment "rabbitmq" created
 service "rabbitmq" created
 deployment "shipping" created
 service "shipping" created
 deployment "user-db" created
 service "user-db" created
 deployment "user" created
 service "user" created
 deployment "zipkin" created
 service "zipkin" created
 deployment "zipkin-mysql" created
 service "zipkin-mysql" created
 deployment "zipkin-cron" created

Run ``kubectl get pods`` and wait for the STATUS of all the pods to be
``Running``.

.. code-block:: bash

 root@master1:~# watch -n 2 kubectl get pods --all-namespaces
 Every 2.0s: kubectl get pods --all-namespaces

 NAMESPACE     NAME                              READY     STATUS    RESTARTS   AGE
 default       kube-flannel-ds-4cwcf             2/2       Running   0          6m
 default       kube-flannel-ds-j6q5b             2/2       Running   0          5m
 default       kube-flannel-ds-kdv9k             2/2       Running   0          5m
 default       kube-flannel-ds-nzf9t             2/2       Running   3          5m
 default       kube-flannel-ds-q53qg             2/2       Running   0          5m
 kube-system   dummy-2088944543-mqwk1            1/1       Running   0          7m
 kube-system   etcd-master1                      1/1       Running   0          6m
 kube-system   kube-apiserver-master1            1/1       Running   2          7m
 kube-system   kube-controller-manager-master1   1/1       Running   0          7m
 kube-system   kube-discovery-1769846148-r5spl   1/1       Running   0          7m
 kube-system   kube-dns-2924299975-gz5dp         4/4       Running   0          7m
 kube-system   kube-proxy-28frl                  1/1       Running   0          5m
 kube-system   kube-proxy-3t3r6                  1/1       Running   0          5m
 kube-system   kube-proxy-4t0kr                  1/1       Running   0          5m
 kube-system   kube-proxy-6b3k9                  1/1       Running   0          5m
 kube-system   kube-proxy-hkjkt                  1/1       Running   0          7m
 kube-system   kube-scheduler-master1            1/1       Running   0          7m
 sock-shop     cart-2733362716-s5x3n             1/1       Running   0          4m
 sock-shop     cart-db-2053818980-4zw8c          1/1       Running   0          4m
 sock-shop     catalogue-3179692907-2nbh0        1/1       Running   0          4m
 sock-shop     catalogue-db-2290683463-45lr0     1/1       Running   0          4m
 sock-shop     front-end-2489554388-djgjf        1/1       Running   0          4m
 sock-shop     orders-3248148685-3zg5s           1/1       Running   0          4m
 sock-shop     orders-db-3277638702-xdjs5        1/1       Running   0          4m
 sock-shop     payment-1230586184-7v195          1/1       Running   0          4m
 sock-shop     queue-master-1190579278-5g2qz     1/1       Running   0          4m
 sock-shop     rabbitmq-3472039365-wlhvd         1/1       Running   0          4m
 sock-shop     shipping-595972932-hm0d8          1/1       Running   0          4m
 sock-shop     user-937712604-wxdbj              1/1       Running   0          4m
 sock-shop     user-db-431019311-l32tr           1/1       Running   0          4m
 sock-shop     zipkin-3759864772-x9ctj           1/1       Running   0          4m
 sock-shop     zipkin-cron-1577918700-kdgpx      1/1       Running   0          4m
 sock-shop     zipkin-mysql-1199230279-p8tx5     1/1       Running   0          4m

Now you can describe the service:

.. code-block:: bash

 root@master1:~# kubectl describe svc front-end -n sock-shop
 Name:			front-end
 Namespace:		sock-shop
 Labels:			name=front-end
 Selector:		name=front-end
 Type:			NodePort
 IP:			10.102.173.98
 Port:			<unset>	80/TCP
 NodePort:		<unset>	30001/TCP
 Endpoints:		<none>
 Session Affinity:	None
 No events.

The Ansible playbook you ran previously created a security group rule to allow
incoming TCP traffic to port ``30001`` on the master node. Look up the IP
address of the master so we can browse to the sock shop demo application. You
can run the following command to find the floating IP address of the master
node:

.. code-block:: bash

 $ grep master1 ~/.ssh/config -A 1 | awk '/Hostname/{ print $2 }'
 <IP>

You can now access the application at http://<IP>:30001

Cleanup
=======

To remove the socks shop demo you can issue the following command:

.. code-block:: bash

 root@master1:~# kubectl delete namespace sock-shop

When you have completed the guide, you can run the
``remove-kubernetes-hosts.yaml`` playbook to remove all the Catalyst Cloud
resources you have been using.

.. code-block:: bash

 $ ansible-playbook remove-kubernetes-hosts.yaml

