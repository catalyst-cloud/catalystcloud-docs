################
GPU Acceleration
################

GPU acceleration can be utilised in cluster worker nodes with little
additional effort. This document describes the details for using
GPU acceleration in Kubernetes.

For additional documentation on GPU, see :ref:`GPU Support in Virtual
Servers<gpu-support>`.

GPU support is available beginning from the following CCKS cluster
versions:

* v1.31.12
* v1.32.8
* v1.33.4

.. note::

    C2-GPU flavors are not currently supported in CCKS. If a worker node is
    deployed using a C2-GPU flavor, the nodes will start but GPU acceleration
    will be unavailable.

******************
Creating a Cluster
******************

For the most part this is the same as :ref:`deploying a standard Kubernetes cluster
<deploying-kubernetes-cluster>`, except that a suitable GPU flavor needs to be
provided for the worker nodes. The following example deploys a simple cluster with
two GPU-backed worker nodes using the ``c3-gpu.c24r96g1`` flavor:

.. code-block:: bash

  openstack coe cluster create cluster1 \
  --cluster-template kubernetes-v1.33.4 \
  --master-count 3 \
  --node-count 2 \
  --flavor c3-gpu.c24r96g1

Alternatively, GPU :ref:`clusters-nodegroups` can be added to an existing cluster:

.. code-block:: bash

  openstack coe nodegroup create cluster1 gpu \
  --node-count 2 \
  --flavor c3-gpu.c24r96g1

Once the Cluster or Nodegroup is created, monitor the Cluster status until it reports healthy:

.. code-block:: bash

  $ openstack coe cluster show cluster1 -f value -c health_status
  HEALTHY

Download the Kubernetes config file for the cluster from the Catalyst Cloud
dashboard.

Run the NVIDIA CUDA Helm chart to install CUDA support. Note that the version
used can be quite particular; the current version tested by Catalyst Cloud is
v24.6.2.

.. code-block:: bash

    helm repo add nvidia https://nvidia.github.io/gpu-operator

    helm install --generate-name -n gpu-operator --create-namespace nvidia/gpu-operator --version=v24.6.2 --set driver.enabled=false --set toolkit.enabled=true

At this point the cluster is ready to run GPU accelerated applications.

************************
Testing GPU Acceleration
************************

A simple method for testing GPU acceleration is to use `NVIDIA's CUDA sample apps
<https://catalog.ngc.nvidia.com/orgs/nvidia/teams/k8s/containers/cuda-sample>`_.

For example, run the following to create a pod running vectorAdd:

.. code-block:: bash

    $ kubectl create -f - << EOF
    apiVersion: v1
    kind: Pod
    metadata:
      name: cuda-vectoradd
    spec:
      restartPolicy: OnFailure
      containers:
      - name: cuda-vectoradd
        image: "nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda12.5.0-ubi8"
        resources:
          limits:
            nvidia.com/gpu: 1
    EOF



After a minute or two the cuda-vectoradd pod logs should show a successful result:

.. code-block:: text

    $ kubectl logs cuda-vectoradd

    [Vector addition of 50000 elements]
    Copy input data from the host memory to the CUDA device
    CUDA kernel launch with 196 blocks of 256 threads
    Copy output data from the CUDA device to the host memory
    Test PASSED
    Done
