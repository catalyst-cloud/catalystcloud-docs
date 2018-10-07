#######################
A More Advanced Example
#######################

Flask Hello World Example
=========================
For this example we are going to deploy a container running a simple flask app that will
respond with a basic 'Hello World' message that includes the host name and IP of the node
responding to the request. Once the initial deployment has been successful we will investigate
how to do a rolling update on the existing deployment and scale it out at the same time.

Each pod will run the following simple flask app that will expose the app on port 5000 which
will in turn be mapped to port 80

.. literalinclude:: ../_scripts/app.py

Create the deployment
---------------------
The deployment
3 replicas
helloworld version_1.1

deploy using helloworld-deployment_1.yaml


.. literalinclude:: _containers_assets/helloworld-deployment_1.yaml


.. code-block:: bash

  $ kubectl create -f helloworld-deployment_1.yaml
  deployment.apps/helloworld-deployment created

.. code-block:: bash

  kubectl describe deployment helloworld-deployment
  Name:                   helloworld-deployment
  Namespace:              default
  CreationTimestamp:      Mon, 16 Jul 2018 15:32:11 +1200
  Labels:                 app=helloworld
  Annotations:            deployment.kubernetes.io/revision=1
  Selector:               app=helloworld
  Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
  StrategyType:           RollingUpdate
  MinReadySeconds:        0
  RollingUpdateStrategy:  25% max unavailable, 25% max surge
  Pod Template:
    Labels:  app=helloworld
    Containers:
     helloworld:
      Image:        chelios/helloworld-flask:version_1.1
      Port:         5000/TCP
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
  NewReplicaSet:   helloworld-deployment-58d59d965b (3/3 replicas created)
  Events:
    Type    Reason             Age   From                   Message
    ----    ------             ----  ----                   -------
    Normal  ScalingReplicaSet  7s    deployment-controller  Scaled up replica set
    helloworld-deployment-58d59d965b to 3

create service
--------------
vim helloworld-service.yaml

.. code-block:: bash

  kubectl create -f helloworld-service.yaml
  service/helloworld-service created

.. code-block:: bash

  kubectl describe service helloworld-service
  Name:                     helloworld-service
  Namespace:                default
  Labels:                   <none>
  Annotations:              <none>
  Selector:                 app=helloworld
  Type:                     LoadBalancer
  IP:                       10.51.245.121
  Port:                     <unset>  80/TCP
  TargetPort:               helloworld-port/TCP
  NodePort:                 <unset>  30316/TCP
  Endpoints:                10.48.0.17:5000,10.48.1.27:5000,10.48.1.28:5000
  Session Affinity:         None
  External Traffic Policy:  Cluster
  Events:                   <none>

.. code-block:: bash

  kubectl describe service helloworld-service
  Name:                     helloworld-service
  Namespace:                default
  Labels:                   <none>
  Annotations:              <none>
  Selector:                 app=helloworld
  Type:                     LoadBalancer
  IP:                       10.51.245.121
  Port:                     <unset>  80/TCP
  TargetPort:               helloworld-port/TCP
  NodePort:                 <unset>  30316/TCP
  Endpoints:                10.48.0.17:5000,10.48.1.27:5000,10.48.1.28:5000
  Session Affinity:         None
  External Traffic Policy:  Cluster
  Events:
    Type    Reason                Age   From                Message
    ----    ------                ----  ----                -------
    Normal  EnsuringLoadBalancer  2s    service-controller  Ensuring load balancer

.. code-block:: bash

  kubectl describe service helloworld-service
  Name:                     helloworld-service
  Namespace:                default
  Labels:                   <none>
  Annotations:              <none>
  Selector:                 app=helloworld
  Type:                     LoadBalancer
  IP:                       10.51.245.121
  LoadBalancer Ingress:     35.189.56.128
  Port:                     <unset>  80/TCP
  TargetPort:               helloworld-port/TCP
  NodePort:                 <unset>  30316/TCP
  Endpoints:                10.48.0.17:5000,10.48.1.27:5000,10.48.1.28:5000
  Session Affinity:         None
  External Traffic Policy:  Cluster
  Events:
    Type    Reason                Age   From                Message
    ----    ------                ----  ----                -------
    Normal  EnsuringLoadBalancer  1m    service-controller  Ensuring load balancer
    Normal  EnsuredLoadBalancer   1s    service-controller  Ensured load balancer

.. code-block:: bash

  kubectl get deployments
  NAME                    DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
  helloworld-deployment   3         3         3            3           2m

.. code-block:: bash

  kubectl get pods
  NAME                                     READY     STATUS    RESTARTS   AGE
  helloworld-deployment-58d59d965b-hb7vh   1/1       Running   0          2m
  helloworld-deployment-58d59d965b-l8cr5   1/1       Running   0          2m
  helloworld-deployment-58d59d965b-qsh7w   1/1       Running   0          2m

.. code-block:: bash

  kubectl get rs
  kubectl get rs
  NAME                               DESIRED   CURRENT   READY     AGE
  helloworld-deployment-58d59d965b   3         3         3         3m

Clean up
---------
.. code-block:: bash

  kubectl delete service helloworld-service
  kubectl delete deployment helloworld-deployment

Rolling upgrade example
========================

6 replicas
helloworld version_1.2 / latest
deploy using helloworld-deployment_2.yaml with helloworld-service.yaml

.. code-block:: yaml

  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: helloworld-deployment
    labels:
      app: helloworld
  spec:
    replicas: 6
    minReadySeconds: 20
    strategy:
      type: RollingUpdate
      rollingUpdate:
        maxUnavailable: 1
        maxSurge: 1
    selector:
      matchLabels:
        app: helloworld
    template:
      metadata:
        labels:
          app: helloworld
      spec:
        containers:
        - name: helloworld
          image: chelios/helloworld-flask:latest
          ports:
          - name: helloworld-port
            containerPort: 5000


.. code-block:: bash

  kubectl create -f helloworld-deployment_2.yaml
  deployment.apps/helloworld-deployment created


::

  kubectl describe deployment helloworld-deployment
  Name:                   helloworld-deployment
  Namespace:              default
  CreationTimestamp:      Mon, 16 Jul 2018 15:17:41 +1200
  Labels:                 app=helloworld
  Annotations:            deployment.kubernetes.io/revision=1
  Selector:               app=helloworld
  Replicas:               6 desired | 6 updated | 6 total | 0 available | 6 unavailable
  StrategyType:           RollingUpdate
  MinReadySeconds:        20
  RollingUpdateStrategy:  1 max unavailable, 1 max surge
  Pod Template:
    Labels:  app=helloworld
    Containers:
     helloworld:
      Image:        chelios/helloworld-flask:latest
      Port:         5000/TCP
      Host Port:    0/TCP
      Environment:  <none>
      Mounts:       <none>
    Volumes:        <none>
  Conditions:
    Type           Status  Reason
    ----           ------  ------
    Available      False   MinimumReplicasUnavailable
    Progressing    True    ReplicaSetUpdated
  OldReplicaSets:  <none>
  NewReplicaSet:   helloworld-deployment-7c49cc6dc4 (6/6 replicas created)
  Events:
    Type    Reason             Age   From                   Message
    ----    ------             ----  ----                   -------
    Normal  ScalingReplicaSet  9s    deployment-controller  Scaled up replica set
    helloworld-deployment-7c49cc6dc4 to 6

.. code-block:: bash

  kubectl get pods
  NAME                                     READY     STATUS    RESTARTS   AGE
  helloworld-deployment-7c49cc6dc4-4pxcq   1/1       Running   0          45s
  helloworld-deployment-7c49cc6dc4-5m2dv   1/1       Running   0          45s
  helloworld-deployment-7c49cc6dc4-k8t64   1/1       Running   0          45s
  helloworld-deployment-7c49cc6dc4-knvzr   1/1       Running   0          45s
  helloworld-deployment-7c49cc6dc4-n5vpc   1/1       Running   0          45s
  helloworld-deployment-7c49cc6dc4-vt6zw   1/1       Running   0          45s


.. code-block:: bash

  kubectl create -f helloworld-service.yaml
  service/helloworld-service created

.. code-block:: bash

  kubectl describe service helloworld-service
  Name:                     helloworld-service
  Namespace:                default
  Labels:                   <none>
  Annotations:              <none>
  Selector:                 app=helloworld
  Type:                     LoadBalancer
  IP:                       10.51.252.175
  Port:                     <unset>  80/TCP
  TargetPort:               helloworld-port/TCP
  NodePort:                 <unset>  31803/TCP
  Endpoints:                10.48.0.15:5000,10.48.1.21:5000,10.48.1.22:5000 + 3 more...
  Session Affinity:         None
  External Traffic Policy:  Cluster
  Events:
    Type    Reason                Age   From                Message
    ----    ------                ----  ----                -------
    Normal  EnsuringLoadBalancer  15s   service-controller  Ensuring load balancer

.. code-block:: bash

  kubectl describe service helloworld-service
  Name:                     helloworld-service
  Namespace:                default
  Labels:                   <none>
  Annotations:              <none>
  Selector:                 app=helloworld
  Type:                     LoadBalancer
  IP:                       10.51.252.175
  LoadBalancer Ingress:     35.197.161.128
  Port:                     <unset>  80/TCP
  TargetPort:               helloworld-port/TCP
  NodePort:                 <unset>  31803/TCP
  Endpoints:                10.48.0.15:5000,10.48.1.21:5000,10.48.1.22:5000 + 3 more...
  Session Affinity:         None
  External Traffic Policy:  Cluster
  Events:
    Type    Reason                Age   From                Message
    ----    ------                ----  ----                -------
    Normal  EnsuringLoadBalancer  1m    service-controller  Ensuring load balancer
    Normal  EnsuredLoadBalancer   1s    service-controller  Ensured load balancer


.. code-block:: bash

  kubectl describe service helloworld-service
  Name:                     helloworld-service
  Namespace:                default
  Labels:                   <none>
  Annotations:              <none>
  Selector:                 app=helloworld
  Type:                     LoadBalancer
  IP:                       10.51.252.175
  LoadBalancer Ingress:     35.197.161.128
  Port:                     <unset>  80/TCP
  TargetPort:               helloworld-port/TCP
  NodePort:                 <unset>  31803/TCP
  Endpoints:                10.48.0.15:5000,10.48.1.21:5000,10.48.1.22:5000 + 3 more...
  Session Affinity:         None
  External Traffic Policy:  Cluster
  Events:
    Type    Reason                Age   From                Message
    ----    ------                ----  ----                -------
    Normal  EnsuringLoadBalancer  2m    service-controller  Ensuring load balancer
    Normal  EnsuredLoadBalancer   1m    service-controller  Ensured load balancer

.. code-block:: bash

  kubectl apply -f helloworld-deployment_2.yaml  --record
  Warning: kubectl apply should be used on resource created by either kubectl create --save-config
  or kubectl apply
  deployment.apps/helloworld-deployment configured



::

  kubectl rollout status  deployment helloworld-deployment
  Waiting for deployment "helloworld-deployment" rollout to finish: 2 out of 6 new replicas have been updated...
  Waiting for deployment "helloworld-deployment" rollout to finish: 4 out of 6 new replicas have been updated...
  Waiting for deployment "helloworld-deployment" rollout to finish: 4 out of 6 new replicas have been updated...
  Waiting for deployment "helloworld-deployment" rollout to finish: 4 out of 6 new replicas have been updated...
  Waiting for deployment "helloworld-deployment" rollout to finish: 1 old replicas are pending termination...
  Waiting for deployment "helloworld-deployment" rollout to finish: 1 old replicas are pending termination...
  deployment "helloworld-deployment" successfully rolled out


Check the deployment

::

  kubectl get deploy helloworld-deployment
  NAME                    DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
  helloworld-deployment   6         6         6            6           4h


View the details of the deployment

.. literalinclude:: _containers_assets/stdout_desc_hw_deploy.txt
  :emphasize-lines: 1, 11
  :linenos:


.. code-block:: bash

  kubectl rollout history deployment helloworld-deployment
  deployments "helloworld-deployment"
  REVISION  CHANGE-CAUSE
  1         <none>
  2         kubectl apply --filename=helloworld-deployment_2.yaml --record=true

.. code-block:: bash

  kubectl get rs
  NAME                               DESIRED   CURRENT   READY     AGE
  helloworld-deployment-5896b9988    6         6         6         5m
  helloworld-deployment-58d59d965b   0         0         0         4h

.. code-block:: bash

  kubectl rollout undo deployment helloworld-deployment --to-revision=1
  deployment.extensions/helloworld-deployment

.. code-block:: bash

  kubetl get deploy helloworld-deployment
  NAME                    DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
  helloworld-deployment   6         7         2            5           4d

::

  kubectl rollout status deployment helloworld-deployment
  Waiting for deployment "helloworld-deployment" rollout to finish: 1 old replicas are pending termination...
  deployment "helloworld-deployment" successfully rolled out
