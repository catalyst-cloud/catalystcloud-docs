########
Security
########

*****************
Admission Control
*****************

When the Kubernetes API server receives a request from a client, the request
must pass through a series of checks to ensure that the client is who it claims
to be and that it is allowed to perform a certain action. The first steps in
the series are `authentication`_ and `authorisation`_.

.. _`authentication`: https://kubernetes.io/docs/reference/access-authn-authz/authentication/#users-in-kubernetes
.. _`authorisation`: https://kubernetes.io/docs/reference/access-authn-authz/authorization/#determine-whether-a-request-is-allowed-or-denied

Once the request has been authenticated and authorized it is then passed onto
the `admission controllers`_. There can be a number of admission controllers that the request must
first pass through before anything is persisted to etcd. These might simply
validate the request, in which case they are called *validating* admission controllers.
Alternatively they might instead modify parts of the request. Such admission controllers are
called *mutating* admission controllers.

.. _`admission controllers`: https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/


Catalyst Cloud Kubernetes Service supports setting admission controllers
when creating a new cluster by specifying labels. The following 
admission controllers are enabled by default:

* CertificateApproval
* CertificateSigning
* CertificateSubjectRestriction
* DefaultIngressClass
* DefaultStorageClass
* DefaultTolerationSeconds
* LimitRanger
* MutatingAdmissionWebhook
* NamespaceLifecycle
* PersistentVolumeClaimResize
* PodSecurity
* Priority
* ResourceQuota
* RuntimeClass
* ServiceAccount
* StorageObjectInUseProtection
* TaintNodesByCondition
* ValidatingAdmissionPolicy
* ValidatingAdmissionWebhook

.. note:: 
   The exact set of admission controllers may vary depending on which version
   of Kubernetes you are using.

How to turn on an admission controller
======================================

There are some other useful admission controller can be enabled to enhance
the security of Kubernetes cluster. To turn on an admission controllers, user
can do it by either command line or dashboard with label ``admission_control_list``.

Command Line
~~~~~~~~~~~~

When creating a new Kubernetes cluster on the command line you can use the label
``admission_control_list`` to supplement or override the default labels.  Don't forget to use ``--merge-labels`` when 
adding or overriding specific labels.

.. code-block:: bash

  openstack coe cluster create k8s-1 \
  --merge-labels --labels admission_control_list=PodSecurity,ValidatingAdmissionPolicy,ValidatingAdmissionWebhook \
  --cluster-template kubernetes-v1.28.2-prod-20230630

Dashboard
~~~~~~~~~

When using dashboard to create Kubernetes cluster, on the last Advanced tag,
you can set additional labels as below:

.. image:: _containers_assets/k8s_admission_controller.png

*********
Sandboxed Containers
*********

Containers typically share kernel resources of the host VM with other
containers. While this is generally considered to be one of the key benefits of
containers as it makes them more lightweight, it also makes them less secure
than traditional VMs.

For additional security in a Kubernetes cluster it can be useful to run certain
containers in a restricted runtime environment known as a *sandbox*. A sandboxed
container is isolated from the host kernel as well as other containers. One
approach to acheiving this is to use a lightweight virtual machine to
isolate the container. This is the method used by `Kata Containers`_.  

.. _`Kata Containers`: https://katacontainers.io

Another approach is to intercept calls between the containerised application
and the host kernel. This is the method used by `gVisor`_. gVisor acts much
like a mini kernel. It receives system calls from the containerised application
and decides whether to respond to them, pass them on to the host kernel or just
ignore them. Unlike Kata Containers which require nested virtualisation,
``gVisor`` just requires ``runsc``, the executable implemented in Golang. 

.. _`gVisor`: https://gvisor.dev/docs

Running containers with gVisor
=============================

All Catalyst Cloud Kubernetes cluster nodes come with the gVisor executable,
``runsc``, installed and configured for ``containerd``. The only thing
you need to in order to begin running sandboxed containers is create a
``RuntimeClass`` object in your cluster as follows:

.. code-block:: bash

  cat <<EOF | kubectl apply -f -
  ---
  apiVersion: node.k8s.io/v1
  kind: RuntimeClass
  metadata:
    # The name the RuntimeClass will be referenced by.
    # RuntimeClass is a non-namespaced resource.
    name: gvisor
  handler: gvisor
  EOF

Now, to run any pod in the sandboxed environment you just need to specify the name of the RuntimeClass
using ``runtimeClassName`` in the Pod spec:

.. code-block:: bash

  cat <<EOF | kubectl create -f -
  ---
  apiVersion: v1
  kind: Pod
  metadata:
    name: test-sandboxed-pod
  spec:
    runtimeClassName: gvisor
    containers:
      - name: sandboxed-container
        image: nginx
   EOF

Once the pod is up and running, you can verify by using ``kubectl exec`` to start a shell on the
pod and run ``dmesg``. If the container sandbox is running correctly you should see output similar
to the following:

.. code-block:: bash

   $ kubectl exec test-sandboxed-pod -- dmesg

   [    0.000000] Starting gVisor...
   [    0.511752] Digging up root...
   [    0.910192] Recruiting cron-ies...
   [    1.075793] Rewriting operating system in Javascript...
   [    1.351495] Mounting deweydecimalfs...
   [    1.648946] Searching for socket adapter...
   [    2.115789] Checking naughty and nice process list...
   [    2.351749] Granting licence to kill(2)...
   [    2.627640] Creating bureaucratic processes...
   [    2.954404] Constructing home...
   [    3.396065] Segmenting fault lines...
   [    3.812981] Setting up VFS...
   [    4.164302] Setting up FUSE...
   [    4.224418] Ready!

You are running a sandboxed container.



Resources:
`Container Sandboxing | gVisor`_

.. _`Container Sandboxing | gVisor`: https://medium.com/geekculture/container-sandboxing-gvisor-b191dafdc8a2
