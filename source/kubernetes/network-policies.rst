################
Network policies
################

As Catalyst Cloud uses `Calico`_ for the default network driver it is
possible to define network policies to control what and how resources are
accessed within the cluster.

In the following example we look at adding a default policy that denies all
access to the cluster network and then look at how to add an exception to
this.

.. _`Calico`: docs.projectcalico.org/v2.6/introduction/



**************************
Create a simple deployment
**************************

First create a simple deployment with 2 replicas.

.. Note::

  We will be using the ``default namespace``. This could be done in any
  `namespace`_ however by first creating a new namespace and then using the
  ``-n <namespace>`` parameter for the kubectl commands or by adding a
  namespace declaration in manifest files.

.. _`namespace`: kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/

The image
``gcr.io/google-samples/hello-app:1.0`` provides a simple web app, listening
on port 8080, that returns the app version, hostname and a 'Hello world'
message.

.. code-block:: bash

  $ kubectl create -f - <<EOF
  kind: Deployment
  apiVersion: extensions/v1beta1
  metadata:
    name: app-deployment
  spec:
    replicas: 2
    selector:
      matchLabels:
        app: test-app
    template:
      metadata:
        labels:
          app: test-app
      spec:
        containers:
        - name: test-app
          image: gcr.io/google-samples/hello-app:1.0
          ports:
          - containerPort: 8080
  EOF

Create a service expose the app by mapping the container port 8080 to 80 on
the cluster network.

.. code-block:: bash

  $ kubectl create -f - <<EOF
  kind: Service
  apiVersion: v1
  metadata:
    name: app-service
  spec:
    ports:
    - port: 80
      protocol: TCP
      targetPort: 8080
    selector:
      app: test-app
  EOF


Now create a simple busybox pod that will allow us to access a shell
environment within the cluster so that we can see and test the network from
the same context as the application pods.

Once in the shell use ``wget`` to query the application service and confirm it
is accessible.

.. code-block:: text

  $ kubectl run --generator=run-pod/v1 -it --rm  busybox \--image=busybox -- sh
  If you don't see a command prompt, try pressing enter.
  / # wget -q app-service -O -
  Hello, world!
  Version: 1.0.0
  Hostname: app-pod
  / #

**************************
Create the deny all policy
**************************

First we need to create a default ``deny all`` network policy.

As the policy does not explicitly specify policyTypes for ingress or egress
they will both be enabled by default with no rules defined which means that
all traffic is blocked.

The empty podSelector ``matchLabels: {}`` means that this policy applies to all
pods in this namespace.

.. code-block:: bash

  $ kubectl create -f - <<EOF
  kind: NetworkPolicy
  apiVersion: networking.k8s.io/v1
  metadata:
    name: netpol-default-deny
  spec:
    podSelector:
      matchLabels: {}
  EOF

.. code-block:: bash

  $ kubectl get networkpolicies
  NAME           POD-SELECTOR   AGE
  netpol-default-deny   <none>         53s

If we describe the policy we can confirm that no ingress or egress traffic is
allowed and that this will apply to all pods.

.. code-block:: bash

  $ kubectl describe networkpolicies netpol-default-deny
  Name:         netpol-default-deny
  Namespace:    default
  Created on:   2018-11-07 16:36:00 +1300 NZDT
  Labels:       <none>
  Annotations:  <none>
  Spec:
    PodSelector:     <none> (Allowing the specific traffic to all pods in this namespace)
    Allowing ingress traffic:
      <none> (Selected pods are isolated for ingress connectivity)
    Allowing egress traffic:
      <none> (Selected pods are isolated for egress connectivity)
    Policy Types: Ingress

Let's connect to the busybox pod again and try to access the app-pod service.
This time we will add a timeout to our wget command as it will not succeed.

.. code-block:: text

  $ kubectl run --generator=run-pod/v1 -it --rm  busybox --image=busybox -- sh
  If you don't see a command prompt, try pressing enter.
  / # wget -q --timeout=10 app-service -O -
  wget: download timed out
  / #

**************************
Create the policy override
**************************

Now let's add a new policy that allows ingress to the deployment. We will
match the pods to allow access to using the labels ``app: test-app`` and we
will limit this access to only pods with the label ``run: busybox``.

.. code-block:: bash

  kubectl create -f - <<EOF
  kind: NetworkPolicy
  apiVersion: networking.k8s.io/v1
  metadata:
    name: netpol-access-app
  spec:
    podSelector:
      matchLabels:
        app: test-app
    ingress:
      - from:
        - podSelector:
            matchLabels:
              run: busybox
  EOF


The final step is to run the busybox pod again and confirm that our access to
the application pods has been restored.

.. code-block:: text

  $ kubectl run --generator=run-pod/v1 -it --rm  busybox --image=busybox -- sh
  If you don't see a command prompt, try pressing enter.
  / # wget -q app-service -O -
  Hello, world!
  Version: 1.0.0
  Hostname: app-pod
  / #
