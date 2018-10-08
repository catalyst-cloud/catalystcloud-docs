####################
Basic Nginx example
####################

In this example we will expand on the simple Nginx example that we have used previously in the
:ref:`workloads` section.

We will still deploy the standard Nginx container image as before except now we will use the
``Deployment`` controller. This will mean that Kubernetes will take care of managing the state of
out pods for us and will ensure that they are always healthy and accessible. It will also ensure
that the number of replicas we specify will always be available.

Should a pod become inaccessible Kubernetes will terminate the pod and replace it with a fresh
one. This is also the case if a pod were die or fail to schedule for some reason. The primary
objective is to ensure that the ``desired state`` is always met.

Create a deployment configuration
=================================
Lets create a configuration file to describe our deployment. The structure is similar to what we
have seen before with some minor changes to existing fields as well as the addition of some new
ones.

- **apiVersion** : changes to apps/v1 as this is the API required by the resource type
  *Deployment*
- **kind** : is now Deployment
- **metadata** : *name* now reflects the purpose and the *label* refers to what the app is that is
  being deployed. These can be anything you like but the use of meaningful names makes debugging
  issues with kubectl much easier down the track



.. literalinclude:: _containers_assets/nginx-deployment.yaml
  :emphasize-lines: 1-3,7


.. code-block:: bash

  $ kubectl create -f nginx-deployment.yaml
  deployment.apps/nginx-deployment created

  $ kubectl describe deployment nginx-deployment
  Name:                   nginx-deployment
  Namespace:              default
  CreationTimestamp:      Mon, 08 Oct 2018 14:05:18 +1300
  Labels:                 <none>
  Annotations:            deployment.kubernetes.io/revision=1
  Selector:               app=nginx
  Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
  StrategyType:           RollingUpdate
  MinReadySeconds:        0
  RollingUpdateStrategy:  25% max unavailable, 25% max surge
  Pod Template:
    Labels:  app=nginx
    Containers:
     nginx:
      Image:        nginx:latest
      Port:         80/TCP
      Host Port:    0/TCP
      Environment:  <none>
      Mounts:       <none>
    Volumes:        <none>
  Conditions:
    Type           Status  Reason
    ----           ------  ------
    Available      True    MinimumReplicasAvailable
    Progressing    True    NewReplicaSetAvailable
  OldReplicaSets:  <none>
  NewReplicaSet:   nginx-deployment-884c7fc54 (2/2 replicas created)
  Events:
    Type    Reason             Age   From                   Message
    ----    ------             ----  ----                   -------
    Normal  ScalingReplicaSet  1m    deployment-controller  Scaled up replica set nginx-deployment-884c7fc54 to 2


create a service configuration
==============================

.. literalinclude:: _containers_assets/nginx-service.yaml

.. code-block:: bash

  $ kubectl create -f nginx-service.yaml
  service/nginx-service created

  kubectl describe service nginx-service


Other commands
--------------
.. code-block:: bash

  kubectl delete service nginx-service
  kubectl delete deployment nginx-deployment
  kubectl get deployments
