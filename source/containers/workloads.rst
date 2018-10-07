.. _workloads:

#########
Workloads
#########

While containers may be the underlying mechanism used in deploying applications on Kubernetes,
there are other layers of abstraction above the container interface that provide functionality
such as resiliency, scaling, storage and life cycle management.

Workloads are the applications deployed to the cluster by way of these higher level primitives
provided by the Kubernetes object model.This approach allows us to define and interact with
workloads that are composed of these objects rather than dealing with containers directly.

The following section will provide an overview of the most basic object, the Pod before splitting
off to elaborate further on some of the other higher level abstractions.

*******************************************
The declarative model and the desired state
*******************************************

This is a key concept behind how Kubernetes does what it does. The ``declarative model`` is
where we provide Kubernetes with a YAML or JSON **configuration** or **manifest** file, via the
API server, that declares only the desired state for the application to be deployed and not how to
do it.

Once the configuration has been received, it is stored in the cluster store as a record of the
application's ``desired state``, and then the application is deployed to the cluster. The cluster
store is a highly available key-value store, typically this will be `etcd`_ , though there are
alternatives available. The Catalyst Cloud uses **etcd**.

.. _`etcd`: https://coreos.com/etcd/

The final piece of this is the creation of background watch loops that are responsible for
monitoring the state of the cluster on a constant basis looking for any variations that differ
from the desired state.

****
Pods
****

The pod is the basic building block inside a Kubernetes cluster. It is the smallest, simplest
unit in the Kubernetes object model that can be created or deployed. It's purpose is to
encapsulate an application container or containers along with storage resources, networking and
configuration that governs how the container(s) should run.

The most common container runtime, and the one that is used on the Catalyst Cloud, is ``Docker``
but others, such as rkt, are also available.

Pods typically contains a single container but there are cases where several tightly coupled
containers may be deployed in the same pod. The pod provides a **shared execution environment**
which means that all containers running within the pod share all of it's resources, such as
memory, IP address, hostname and volumes to name a few. This is achieved through the use of
**namespaces**.

A pod typically represents a single instance of an application.

Pod networks
============

Each pod is given a unique IP address that can be used to communicate with it. The containers
within a pod use a shared network namespace that they can all access via ``localhost``, they use
this to communicate with each other. To communicate outside of the pod they utilise the shared
network resources in a coordinated fashion, here a is a link to a more in depth discussion on
`pod networking`_


.. _`pod networking`: https://medium.com/google-cloud/understanding-kubernetes-networking-pods-7117dd28727


.. _pod_storage:

Pod storage
===========

The container file system is ephemeral, meaning it only lives as long as the container does.
If your application needs it's running state to survive events such as reboots, and crashes, it
will require some kind of persistent storage. Another limitation of the on-disk container storage
is that it is tied to the individual container it does not provide any means to share data between
containers.

A Pod, however, is capable of utilising a Kubernetes ``volume``, which is an abstraction that
solves both of the issues mentioned above. Kubernetes volumes have an explicit lifetime which the
same as the Pod that hosts it. As a result volumes outlive any Containers that run within the Pod,
and data is preserved across Container restarts. When the pod ceases to exist the volume will
disappear as well.

More information on this can be found in the :ref:`storage` section.

Creating a simple Pod
=====================
To create a very simple pod we need to create a file that describes the pod. This can be done
using YAML or JSON, though typically YAML is used as it is more human readable.

The following file will create a pod that hosts a container running the latest version of the
Nginx container image.

There are a few required fields in this file that will always be present in and configuration file
and as such deserve some explanation.

- **apiVersion** : Kubernetes supports multiple API versions so you must declare the one you wish
  to use. The base API is called core and can be excluded as it is the default, e.g instead of
  using **core/v1** simply using v1 is acceptable.
- **kind** : dictates what sort of resource you want to create
- **metadata** : defines the name/labels associated with the pod
- **spec** : is the data that describes the resource to be created, based on the **kind**

For more information on Kubernetes APIs take a look at this helpful `API guide`_ or alternatively
the official `Kubernetes API documentation`_.

.. _`API guide`: https://matthewpalmer.net/kubernetes-app-developer/articles/kubernetes-apiversion-definition-guide.html
.. _`Kubernetes API documentation`: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#-strong-api-overview-strong-

.. literalinclude:: _containers_assets/pod1.yaml
  :emphasize-lines: 3-5,9

In the above example we are using the API version 'v1' and we will be creating a resource that is
of the **kind** 'Pod'.

We then gave the pod the name 'basic-pod' and we have also added a ``label`` to the pod with the
same name. We will cover labels in more detail when we look at services and controllers.

The final section is the **spec**. This is where the we specify the desired behaviour of the
objects, in this case the pod, to be deployed. In this example we will deploy the latest version
of the Nginx container and we will make it available on TCP port 80.


To deploy this we will need to ensure that we have ``kubectl`` installed, details for that can be
found at :ref:`Setting up Kubernetes CLI <kube_cli>`.

Run the following to create a new pod in your cluster

.. code-block:: bash

  $ kubectl create -f pod.yaml
  pod/basic-pod created

.. Note::

  While it is possible to deploy a pod directly, this is not advisable as it has no way to recover
  if it were to crash or fail to schedule correctly.
  ``Controllers`` , which we will discuss later, are a higher level abstraction
  that will provide a means to handle the creation of pods and also manage these types of
  shortcomings , and more.

Now let's check the status of the new pod

.. code-block:: bash

  $ kubectl get pods
  NAME        READY     STATUS    RESTARTS   AGE
  basic-pod   1/1       Running   0          23s

If the returned status says *ContainerCreating*, wait a moment as the pod is still deploying. Once
the status says *Running* your pod is online.

It is also possible to see more detailed information about a pod by using the describe command.

.. code-block:: bash

  $ kubectl describe pod basic-pod
  Name:         basic-pod
  Namespace:    default
  Node:         minikube/192.168.122.135
  Start Time:   Tue, 25 Sep 2018 14:17:34 +1200
  Labels:       app=basic-pod
  Annotations:  <none>
  Status:       Running
  IP:           172.17.0.4
  Containers:
    server:
      Container ID:   docker://fe5ab688d680e1dccc090d7488a41597194c05372e631378217b61d46c41e153
      Image:          nginx:latest
      Image ID:       docker-pullable://nginx@sha256:24a0c4b4a4c0eb97a1aabb8e29f18e917d05abfe1b7a7c07857230879ce7d3d3
      Port:           80/TCP
      Host Port:      0/TCP
      State:          Running
        Started:      Tue, 25 Sep 2018 14:17:51 +1200
      Ready:          True
      Restart Count:  0
      Environment:    <none>
      Mounts:
        /var/run/secrets/kubernetes.io/serviceaccount from default-token-f4b8q (ro)
  Conditions:
    Type           Status
    Initialized    True
    Ready          True
    PodScheduled   True
  Volumes:
    default-token-f4b8q:
      Type:        Secret (a volume populated by a Secret)
      SecretName:  default-token-f4b8q
      Optional:    false
  QoS Class:       BestEffort
  Node-Selectors:  <none>
  Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                   node.kubernetes.io/unreachable:NoExecute for 300s
  Events:
    Type    Reason                 Age   From               Message
    ----    ------                 ----  ----               -------
    Normal  Scheduled              30m   default-scheduler  Successfully assigned basic-pod to minikube
    Normal  SuccessfulMountVolume  30m   kubelet, minikube  MountVolume.SetUp succeeded for volume "default-token-f4b8q"
    Normal  Pulling                30m   kubelet, minikube  pulling image "nginx:latest"
    Normal  Pulled                 29m   kubelet, minikube  Successfully pulled image "nginx:latest"
    Normal  Created                29m   kubelet, minikube  Created container
    Normal  Started                29m   kubelet, minikube  Started container

This provides lots of useful information and is a great way to check or confirm settings. The
upper section displays the settings such as pod name, labels, container image and ports, that we
defined in our configuration file. For things that were not specifically defined standard pod
defaults are assigned. It also includes other settings, such as the secret, that Kubernetes deems
necessary to make things work. The bottom section is the event log which describes that actions
taken to create the requested resource and the outcome of those actions.

We can see in the above output we have both an IP address and a port assigned to our pod but at
this stage we are still unable to interact with our pod as this IP address and port is only
accessible from within the cluster itself.

To overcome this we could intentionally expose the pod by adding the following **hostPort** entry
to our pod's configuration file

.. literalinclude:: _containers_assets/pod2.yaml
  :emphasize-lines: 13

.. Note::

  KUbernetes cannot update ports on a running pod, to detect these changes the pod will need to
  be deleted and recreated

To pick up the changes to the ports delete the existing pod and recreate it as we did earlier.

.. code-block:: bash

  $ kubectl delete pod basic-pod
  $ kubectl create -f pod.yaml

This now exposes port 8080 on the pod itself. If we look at the **describe** output about we can
see a line similar to the following

.. code-block:: bash

  Node:         minikube/192.168.122.135

This is the actual IP address of the node itself. Now with this information we should be able to
connect to the Nginx instance in our pod and see the standard Nginx success message.

.. code-block:: bash

  $ curl 192.168.122.148:8080
  <!DOCTYPE html>
  <html>
  <head>
  <title>Welcome to nginx!</title>
  <style>
      body {
          width: 35em;
          margin: 0 auto;
          font-family: Tahoma, Verdana, Arial, sans-serif;
      }
  </style>
  </head>
  <body>
  <h1>Welcome to nginx!</h1>
  <p>If you see this page, the nginx web server is successfully installed and
  working. Further configuration is required.</p>

  <p>For online documentation and support please refer to
  <a href="http://nginx.org/">nginx.org</a>.<br/>
  Commercial support is available at
  <a href="http://nginx.com/">nginx.com</a>.</p>

  <p><em>Thank you for using nginx.</em></p>
  </body>
  </html>


The problem with this approach is that it is not permanent. If the pod dies and gets recreated it
will come back with a new ID and IP making referring to them in this manner unreliable. This is
where :ref:`Services <services>` come in to the picture.
