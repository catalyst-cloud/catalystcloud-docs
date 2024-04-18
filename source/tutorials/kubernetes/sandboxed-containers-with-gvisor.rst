.. _k8s-sandboxed-containers:

***************************************
Security - Running Sandboxed Containers
***************************************

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
==============================

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
