#############################
Deploying a HPC SLURM cluster
#############################


Introduction
============

In this tutorial you will learn how to deploy a high performance computing
(`HPC`_) cluster on the `Catalyst Cloud`_ using `elasticluster`_ and `SLURM`_.

.. _HPC: https://en.wikipedia.org/wiki/High-performance_computing
.. _Catalyst Cloud: https://catalystcloud.nz/
.. _elasticluster: https://gc3-uzh-ch.github.io/elasticluster/
.. _SLURM: https://computing.llnl.gov/linux/slurm/

ElastiCluster is an open source tool to create and manage compute clusters on
cloud infrastructures. The project was originally created by the `Grid
Computing Competence Center`_ from the University of Zurich.

.. _Grid Computing Competence Center: https://www.gc3.uzh.ch/

SLURM is a highly scalable cluster management and resource manager, used by
many of the world's supercomputers and computer clusters (it is the workload
manager on about 60% of the `TOP500 supercomputers`_).

.. _TOP500 supercomputers: http://www.top500.org/

The following video outlines what you will learn in this tutorial. It shows a
SLURM HPC cluster being deployed automatically by ElastiCluster on the Catalyst
Cloud, a data set being uploaded, the cluster being scaled on demand from 2 to
10 nodes, the execution of an embarrassingly parallel job, the results being
downloaded, and finally, the cluster being destroyed.

.. raw:: html

  <iframe width="560" height="315" src="https://www.youtube.com/embed/gkXkcHDd588?html5=1" frameborder="0" allowfullscreen></iframe>

.. warning::

  This tutorial assumes you are starting with a blank project and using your VPC
  only for ElastiCluster. You may need to adjust things (e.g. create a dedicated
  elasticluster security group), if you are doing this in a shared VPC.

Prerequisites
==============

Install Python development tools:

.. code-block:: bash

  sudo apt-get install python-dev virtualenv gcc

Create a virtual environment to install the software:

.. code-block:: bash

  cd ~
  virtualenv elasticluster
  source elasticluster/bin/activate

Install Elasticluster on the virtual environment:

.. code-block:: bash

  git clone https://github.com/gc3-uzh-ch/elasticluster src
  cd src
  pip install -e .
  pip install ndg-httpsclient

Install the Catalyst Cloud OpenStack client tools:

.. code-block:: bash

  pip install python-keystoneclient python-novaclient python-cinderclient \
      python-glanceclient python-ceilometerclient python-heatclient       \
      python-neutronclient python-swiftclient python-openstackclient

Configuring ElastiCluster
=========================

Create template configuration files for ElastiCluster:

.. code-block:: bash

  elasticluster list-templates 1> /dev/null 2>&1

Edit the ElastiCluster configuration file (~/.elasticluster/config). A sample
configuration file compatible with the Catalyst Cloud is provided below:

.. code-block:: ini

  [cloud/catalyst]
  provider=openstack
  auth_url=auth_url
  username=username
  password=password
  project_name=projectname
  request_floating_ip=True

  [login/ubuntu]
  image_user=ubuntu
  image_user_sudo=root
  image_sudo=True
  user_key_name=elasticluster
  user_key_private=~/elasticluster/id_rsa
  user_key_public=~/elasticluster/id_rsa.pub

  [setup/slurm]
  provider=ansible
  frontend_groups=slurm_master
  compute_groups=slurm_worker

  [cluster/slurm]
  cloud=catalyst
  login=ubuntu
  setup_provider=slurm
  security_group=default
  # Ubuntu image - Use the ID from running (as of June 2018, 18.04 doesn't work):
  #   openstack image show -c id ubuntu-16.04-x86_64
  image_id=<image UUID>
  # Use the correct network UUID from: openstack network list
  network_ids=<network UUID>
  flavor=c1.c1r1
  frontend_nodes=1
  compute_nodes=2
  ssh_to=frontend

  [cluster/slurm/frontend]
  # The frontend shares /home via NFS to the compute nodes.
  boot_disk_type=b1.standard
  boot_disk_size=50

  [cluster/slurm/compute]
  # Use whatever flavour you'd like to use for your compute nodes.
  flavor=c1.c16r64


Configuring the cloud
=====================

Create SSH keys for ElastiCluster (no passphrase):

.. code-block:: bash

  ssh-keygen -t rsa -b 4096 -f ~/elasticluster/id_rsa

Source your openrc file, as explained on :ref:`command-line-interface`.

Allow ElastiCluster to connect to instances over SSH:

.. code-block:: bash

  nova secgroup-add-group-rule default default tcp 22 22

Using ElastiCluster
===================

The following commands are provided as examples of how to use ElastiCluster to
create and interact with a simple SLURM cluster. For more information on
ElastiCluster, please refer to https://elasticluster.readthedocs.org/.

Deploy a SLURM cluster on the cloud using the configuration provided:

.. code-block:: bash

  elasticluster start slurm -n cluster

List information about the cluster:

.. code-block:: bash

  elasticluster list-nodes cluster

Connect to the front-end node of the SLURM cluster over SSH:

.. code-block:: bash

  elasticluster ssh cluster

Connect to the front-end node of the SLURM cluster over SFTP, to upload (put
file-name) or download (get file-name) data sets:

.. code-block:: bash

  elasticluster sftp cluster

Grow the cluster to 10 nodes (add another 8 nodes):

.. code-block:: bash

  elasticluster resize cluster -a 8:compute

Terminate (destroy) the cluster:

.. code-block:: bash

  elasticluster stop cluster

Using SLURM
===========

Connect to the front-end node of the SLURM cluster over SSH as described on the
previous section.

The following example demonstrates how to create a simple, embarrassingly
parallel workload job that will trigger four tasks and write its output to
results.txt.

.. code-block:: bash

 #!/bin/bash
 #
 #SBATCH --job-name=test
 #SBATCH --output=results.txt
 #
 #SBATCH --ntasks=4
 #SBATCH --time=10:00
 #SBATCH --mem-per-cpu=100

 srun hostname
 srun printenv SLURM_PROCID
 srun sleep 15

Submit a job:

.. code-block:: bash

  sbatch job.sh

List the jobs in the queue:

.. code-block:: bash

  squeue


Using anti-affinity groups
==========================
There is an options to use elasticluster with server group anti-affinity groups to
ensure best load distribution in Opentack cluster.
To use this feature clone elasticluster from the repository shown below, this is a
temporary step until the feature gets merged upstream.

.. code-block:: bash

  git clone https://github.com/flashvoid/elasticluster --branch=feature/openstack-aaf
  cd src
  pip install -e .
  pip install ndg-httpsclient

And then set `anti_affinity_group_prefix` property in `[cloud/catalyst]` section.

.. code-block:: ini

  [cloud/catalyst]
  provider=openstack
  auth_url=auth_url
  username=username
  password=password
  project_name=projectname
  request_floating_ip=True
  anti_affinity_group_prefix=elasticluster

  [login/ubuntu]
  image_user=ubuntu
  image_user_sudo=root
  image_sudo=True
  user_key_name=elasticluster
  user_key_private=~/elasticluster/id_rsa
  user_key_public=~/elasticluster/id_rsa.pub

  [setup/slurm]
  provider=ansible
  frontend_groups=slurm_master
  compute_groups=slurm_worker

  [cluster/slurm]
  cloud=catalyst
  login=ubuntu
  setup_provider=slurm
  security_group=default
  # Ubuntu image - Use the ID from running (as of June 2018, 18.04 doesn't work):
  #   openstack image show -c id ubuntu-16.04-x86_64
  image_id=<image UUID>
  # Use the correct network UUID from: openstack network list
  network_ids=<network UUID>
  flavor=c1.c1r1
  frontend_nodes=1
  compute_nodes=2
  ssh_to=frontend

  [cluster/slurm/frontend]
  # The frontend shares /home via NFS to the compute nodes.
  boot_disk_type=b1.standard
  boot_disk_size=50

  [cluster/slurm/compute]
  # Use whatever flavour you'd like to use for your compute nodes.
  flavor=c1.c16r64
