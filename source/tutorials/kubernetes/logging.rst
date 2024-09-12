.. _kubernetes-logging:

####################################
Logging Kubernetes to Catalyst Cloud
####################################

.. contents::
    :depth: 2
    :local:
    :backlinks: none

************
Introduction
************

This is a tutorial for showing how you can setup centralised logging
to Catalyst Cloud for your applications running on Kubernetes.

**********
Background
**********

Given the nature of today's multi-cloud, distributed working it can be a
challenge for the people involved in running, deploying and maintaining
cloud-based systems. Part of this challenge is the need to aggregate
various metrics, across a wide range of sources and presenting these in a
'single pane of glass'.

One of the key data sources that typically need to be managed in this way is log
data. Whether this is system or application generated it is always desirable to
be able to forward all of these log output to specialised systems such as
Elasticsearch, Kibana or Grafana which can handle the display, searchability
and analysis of the received log data.

It is the role of the log collectors such as Fluentd or Logstash to forward
these logs from their origins on to the chosen analysis tools.


*******
Fluentd
*******

`Fluentd`_ is a `Cloud Native Computing Foundation (CNCF)`_ open source data
collector aimed at providing a unified logging layer with a pluggable
architecture.

It attempts to structure all data as JSON in order to unify the collecting,
filtering, buffering and outputting of log data from multiple sources and
destinations.

The flexible nature of the Fluentd plugin system allows users to make better
use of their log data in a much easier way through the use of the 500+
community created plugins that provide a wide range of supported `data source`_
and `data output`_ options.

This tutorial shows how you can use Fluentd to set up logging
for Kubernetes clusters backed by the Catalyst Cloud :ref:`object-storage` service.

.. _`Fluentd`: https://www.fluentd.org
.. _`Cloud Native Computing Foundation (CNCF)`: https://www.cncf.io
.. _`data source`: https://www.fluentd.org/datasources
.. _`data output`: https://www.fluentd.org/dataoutputs

Overview
========

We will be adding a Fluentd ``DaemonSet`` to our cluster so that we can export
the logs to a Catalyst Cloud Object Storage container via the S3 API,
using the `Fluentd S3 plugin`_.

This allows you to make log data available to any downstream analysis tool
that is able to use the supported :ref:`Object Storage APIs <object-storage-programmatic-methods>`.

.. _`Fluentd S3 plugin`: https://docs.fluentd.org/output/s3

Creating target container
=========================

First, we will create the Object Storage container that Fluentd will publish log files to.

For more information on how to create an Object Storage container in Catalyst Cloud,
please refer to :ref:`object-storage-using-containers`.

.. tabs::

  .. group-tab:: CLI

    Run the following command to create the ``fluentd`` container.

    .. code-block:: bash

      openstack container create fluentd

    By default, the container is created with the
    :ref:`multi-region replication policy <object-storage-replication-policies>`.
    To use one of the single-region replication policies,
    use the ``--storage-policy`` option to set a custom
    storage policy when creating the container.

    For example, for single-region replication to the ``nz-hlz-1`` region:

    .. code-block:: bash

      openstack container create fluentd --storage-policy nz-hlz-1--o1--sr-r3

    To confirm the container was created successfully,
    run ``openstack container show fluentd`` to list the properties of the container:

    .. code-block:: console

      $ openstack container show fluentd
      +----------------+---------------------------------------+
      | Field          | Value                                 |
      +----------------+---------------------------------------+
      | account        | AUTH_e5d4c3b2a1e5d4c3b2a1e5d4c3b2a1e5 |
      | bytes_used     | 0                                     |
      | container      | fluentd                               |
      | object_count   | 0                                     |
      | storage_policy | nz--o1--mr-r3                         |
      +----------------+---------------------------------------+

  .. group-tab:: Dashboard

    First, navigate to the **Project -> Object Store -> Containers** page,
    where you can view all of your currently existing containers.

    Press the **+ Container** button to create a new container for Fluentd.

    .. image:: _containers_assets/object-storage-containers.png

    Set **Container Name** to ``fluentd``,
    and the **Storage Policy** to the correct policy
    for your use case (for more information,
    refer to :ref:`Storage Policies <object-storage-storage-policies>`).
    Make sure **Container access** is set to **Not public**.

    .. image:: _containers_assets/object-storage-create-container.png

    Once you are done, click **Submit** to create the container.
    You will now be taken back to the **Containers** page,
    where you can interact with the new container.

    .. image:: _containers_assets/object-storage-containers-created.png

  .. group-tab:: Terraform

    Use the `openstack_objectstorage_container_v1`_ resource to create
    the new Object Storage container.

    .. _`openstack_objectstorage_container_v1`: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/objectstorage_container_v1

    .. code-block:: terraform

      # Create the target Object Storage container for Fluentd.
      resource "openstack_objectstorage_container_v1" "fluentd" {
        name           = "fluentd"
        storage_policy = "nz--o1--mr-r3"
      }

    The above resource definition will create the container using the
    :ref:`multi-region replication policy <object-storage-storage-policies>`.
    To use one of the single-region replication policies,
    change the ``region`` and ``storage_policy`` attributes
    to the region you want to create the container in.

    For example, for single-region replication to the ``nz-hlz-1`` region:

    .. code-block:: terraform

      # Create the target Object Storage container for Fluentd.
      resource "openstack_objectstorage_container_v1" "fluentd" {
        name           = "fluentd"
        region         = "nz-hlz-1"
        storage_policy = "nz-hlz-1--o1--sr-r3"
      }

Creating namespace and service account
======================================

Now in Kubernetes, we will create the namespace that Fluentd will run in,
along with dedicated service accounts that grant Fluentd the required privileges.

.. tabs::

  .. group-tab:: kubectl

    Create a YAML file named ``fluentd-rbac.yml`` with the content
    as shown below.

    A ``logging`` namespace is created for Fluentd to run in,
    along with a ``fluentd`` service account.
    A matching new cluster role is also created with the required permissions,
    along with a binding for the cluster role to the service account.

    .. literalinclude:: _containers_assets/fluentd-rbac.yml
        :language: yaml

    Run ``kubectl apply -f fluentd-rbac.yml`` to create the resources in the Kubernetes cluster.

    .. code-block:: console

        $ kubectl apply -f fluentd-rbac.yml
        namespace/logging created
        serviceaccount/fluentd created
        clusterrole.rbac.authorization.k8s.io/fluentd created
        clusterrolebinding.rbac.authorization.k8s.io/fluentd created

  .. group-tab:: Terraform (Kubernetes)

    Below is an example of how to define the required Kubernetes resources using Terraform.

    A ``logging`` namespace is created for Fluentd to run in,
    along with a ``fluentd`` service account.
    A matching new cluster role is also created with the required permissions,
    along with a binding for the cluster role to the service account.

    .. literalinclude:: _containers_assets/fluentd_rbac.tf
        :language: terraform

Configuring Fluentd
===================

We now need to create the ``ConfigMap`` that will hold the configuration for Fluentd.

The configuration file featured below sets up Fluentd to:

* Upload all logs to a Catalyst Cloud Object Storage container.
* Read the following parameters from environment variables:

  * Object Storage container name, region, and an optional path prefix.
  * Access Key ID and Secret Access Key.
  * Optional partitioning configuration overrides (e.g. upload frequency, chunk size).

..
  fluentd.conf modified from the standard file inside the container image:
  https://github.com/fluent/fluentd-kubernetes-daemonset/blob/798f283f96e640f22a9ecb2f07ac9bbbbda004e7/docker-image/v1.16/debian-s3/conf/fluent.conf

.. tabs::

  .. group-tab:: kubectl

    Create a YAML file named ``fluentd-configmap.yml`` with the content
    as shown below.

    .. literalinclude:: _containers_assets/fluentd-configmap.yml
        :language: yaml

    Run ``kubectl apply -f fluentd-configmap.yml`` to create the config map.

    .. code-block:: console

        $ kubectl apply -f fluentd-configmap.yml
        configmap/fluentd created

  .. group-tab:: Terraform (Kubernetes)

    Create a file named ``fluent.conf`` in your Terraform project:

    .. literalinclude:: _containers_assets/fluent.conf

    Then create a `kubernetes_config_map_v1`_ resource for the configuration,
    referencing the namespace resource created earlier.

    .. literalinclude:: _containers_assets/fluentd_configmap.tf
        :language: terraform

    .. _`kubernetes_config_map_v1`: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1

Creating application credentials
================================

We now need to create the application EC2 credentials that Fluentd will use to authenticate
with the Object Storage S3 API.

This consists of an **Access Key ID** and a **Secret Access Key**.

.. tabs::

  .. group-tab:: CLI

    Run the following command to create the EC2 credentials:

    .. code-block:: bash

      openstack ec2 credentials create

    The credentials are returned in the output. ``access`` is the Access Key ID,
    and ``secret`` is the Secret Access Key.

    Copy these values, as they will be used in the next step.

    .. code-block:: console

      $ openstack ec2 credentials create
      +-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------+
      | Field           | Value                                                                                                                                                |
      +-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------+
      | access          | ee55dd44cc33bb2211aaee55dd44cc33                                                                                                                     |
      | access_token_id | None                                                                                                                                                 |
      | app_cred_id     | None                                                                                                                                                 |
      | links           | {'self': 'https://api.nz-por-1.catalystcloud.io:5000/v3/users/e5d4c3b2a1e5d4c3b2a1e5d4c3b2a1e5/credentials/OS-EC2/1a2b3c4d5e1a2b3c4d5e1a2b3c4d5e1a'} |
      | project_id      | e5d4c3b2a1e5d4c3b2a1e5d4c3b2a1e5                                                                                                                     |
      | secret          | 11aa22bb33cc44dd55ee11aa22bb33cc                                                                                                                     |
      | trust_id        | None                                                                                                                                                 |
      | user_id         | 1a2b3c4d5e1a2b3c4d5e1a2b3c4d5e1a                                                                                                                     |
      +-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------+

  .. group-tab:: Dashboard

    .. note::

      It is recommended to use the CLI for this step, as from the dashboard
      you can only create and manage a single set of EC2 credentials
      at a time.

      If you have already created a set of EC2 credentials, an option called
      **Recreate EC2 Credentials** will be shown, which while creating
      a new set of credentials, **will also delete the existing credentials**,
      so be careful.

      From the CLI, you can create and have multiple sets of EC2 credentials
      active at a time.

    Navigate to the **Project -> API Access** page, and press **View Credentials**
    to open the User Credentials window.

    .. image:: _containers_assets/fluentd-dashboard-api-access.png

    **EC2 Access Key** and **EC2 Secret Key** are the required values.
    Copy these values, as they will be used in the next step.

    .. image:: _containers_assets/fluentd-dashboard-user-credentials.png

  .. group-tab:: Terraform

    Use the `openstack_identity_ec2_credential_v3`_ resource to create
    the EC2 credentials to use with Fluentd.

    .. _`openstack_identity_ec2_credential_v3`: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/identity_ec2_credential_v3

    .. code-block:: terraform

      resource "openstack_identity_ec2_credential_v3" "fluentd" {}

    If you are not using Terraform to manage Kubernetes resources,
    after creating the resource using ``terraform apply``,
    run the following command to fetch the Access Key ID
    and Secret Access Key.

    Copy these values, as they will be used in the next step.

    .. code-block:: bash

      terraform state show openstack_identity_ec2_credential_v3.fluentd

We now need to create a ``Secret`` containing the Access Key ID and Secret Access Key.
This ``Secret`` will be referenced by the ``DaemonSet`` to provide the values
to the Fluentd configuration as environment variables.

.. tabs::

  .. group-tab:: kubectl

    Create a YAML file named ``fluentd-secrets.yml``, pasting in
    the correct values for ``aws_access_key_id`` and ``aws_secret_access_key``.

    .. literalinclude:: _containers_assets/fluentd-secrets.yml
        :language: yaml

    Run ``kubectl apply -f fluentd-secrets.yml`` to create the secrets.

    .. code-block:: console

        $ kubectl apply -f fluentd-secrets.yml
        secret/fluentd created

  .. group-tab:: Terraform (Kubernetes)

    Create a `kubernetes_secret_v1`_ resource for the secrets.

    This definition references the credential resource created in the previous step,
    so you do not need to explicitly define the Access Key ID or Secret Access Key anywhere.

    .. literalinclude:: _containers_assets/fluentd_secrets.tf
        :language: terraform

    .. _`kubernetes_secret_v1`: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1

Creating the daemon set
=======================

Finally, we will create the ``DaemonSet`` to run the Fluentd service.
This will create one pod per worker node.

The Fluentd container definition mounts the previously created config map
as the Fluentd configuration file, which then loads credentials,
container/bucket parameters and other options from the environment variables
passed to the container from the daemon set.

.. note::

  This daemon set is designed to be used on a Kubernetes cluster hosted on
  :ref:`Catalyst Cloud Kubernetes Service <kubernetes>`.

  If you are using your own Kubernetes clusters, the container
  environment variables may need some slight changes.
  Check the daemon set definition below for more information.

.. tabs::

  .. group-tab:: kubectl

    Create a YAML file named ``fluentd-daemonset.yml``.

    Make sure to change the values for the following environment variables
    (highlighted below) to the correct values:

    * ``S3_BUCKET_NAME`` - Name of the Object Storage container to save logs to.
    * ``OS_REGION_NAME`` - Catalyst Cloud region to use to connect to the Object Storage S3 API.

      * If the container uses a
        :ref:`single-region replication policy <object-storage-replication-policies>`,
        set this to the region the container is located in.

        * For example, if the container is located in the ``nz-hlz-1`` region,
          set this to ``nz-hlz-1``.

      * If the container uses the multi-region replication policy
        **AND** the Kubernetes cluster is also hosted on Catalyst Cloud,
        set this to the same region in which the Kubernetes cluster is located.

        * For example, if the Kubernetes cluster is hosted in the ``nz-hlz-1``
          region, set this to ``nz-hlz-1``.

      * If none of the above apply, set this to ``nz-por-1``.

    .. literalinclude:: _containers_assets/fluentd-daemonset.yml
        :language: yaml
        :emphasize-lines: 30-33

    Run ``kubectl apply -f fluentd-daemonset.yml`` to create the daemon set.

    .. code-block:: console

        $ kubectl apply -f fluentd-daemonset.yml
        daemonset.apps/fluentd created

  .. group-tab:: Terraform (Kubernetes)

    Create a `kubernetes_daemon_set_v1`_ resource for the Fluentd daemon set.

    As all of the Terraform resources created up until this point are referenced
    by this resource definition, you do not need to set any values.
    Just use the definition as is.

    Some of the parameters may be changed, and additional optional environment variables
    may be configured, if you like. For more information, check the comments
    in the resource definition below.

    .. literalinclude:: _containers_assets/fluentd_daemonset.tf
        :language: terraform

    .. _`kubernetes_daemon_set_v1`: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/daemon_set_v1

Testing Fluentd
===============

Once the daemon set has been created, one Fluentd pod will be started on
all Kubernetes control plane and worker nodes.

Run ``kubectl get pod -n logging`` to check the status of all pods
in the ``logging`` namespace.

.. code-block:: console

  $ kubectl get pod -n logging
  NAME            READY   STATUS    RESTARTS   AGE
  fluentd-5mkjp   1/1     Running   0          4m35s
  fluentd-mggwm   1/1     Running   0          4m35s
  fluentd-vwvf9   1/1     Running   0          4m35s
  fluentd-zgskc   1/1     Running   0          4m35s

Once they reach the ``Running`` state we can query the pod logs
to make sure they are running correctly.

.. code-block:: console

  $ kubectl logs -n logging pod/fluentd-mggwm | grep "fluentd worker is now running"
  2024-04-11 04:10:26 +0000 [info]: #0 fluentd worker is now running worker=0

At this point Fluentd should start logging to Object Storage,
with compressed log files being saved at the end of the hour.

Once the hour has finished, check the Object Storage container to see
if log files were uploaded.

.. tabs::

  .. group-tab:: CLI (Object Storage)

    Run ``openstack object list fluentd`` to list all files in the ``fluentd`` container.

    .. code-block:: console

      $ openstack object list fluentd
      +-----------------------------+
      | Name                        |
      +-----------------------------+
      | 2024/04/11/cluster-log-0.gz |
      | 2024/04/11/cluster-log-1.gz |
      | 2024/04/11/cluster-log-2.gz |
      +-----------------------------+

  .. group-tab:: Dashboard (Object Storage)

    Navigate to the **Project -> Object Store -> Containers** page,
    where the ``fluentd`` container should be listed.

    .. image:: _containers_assets/object-storage-containers-list.png

    Open the ``fluentd`` container, and check that a folder with
    the current year has been created.

    .. image:: _containers_assets/object-storage-containers-fluentd.png

    Navigate into the folders, and check that compress log files have been
    created.

    .. image:: _containers_assets/object-storage-containers-fluentd-logs.png

If the log files are successfully being saved, congratulations!
Fluentd is now working on your Kubernetes cluster to upload logging
to Catalyst Cloud Object Storage.

Cleanup
=======

And that's the end of this tutorial!

If you'd like to cleanup your work done in this tutorial, keep reading.


.. tabs::

  .. group-tab:: kubectl

    Run the following command to delete all created Kubernetes resources.

    .. code-block:: bash

      kubectl delete -f fluentd-daemonset.yml -f fluentd-secrets.yml -f fluentd-configmap.yml -f fluentd-rbac.yml

    Once the command has finished running, all of the resources will have been deleted.

    .. code-block:: console

      $ kubectl delete -f fluentd-daemonset.yml -f fluentd-secrets.yml -f fluentd-configmap.yml -f fluentd-rbac.yml
      daemonset.apps "fluentd" deleted
      secret "fluentd" deleted
      configmap "fluentd" deleted
      namespace "logging" deleted
      serviceaccount "fluentd" deleted
      clusterrole.rbac.authorization.k8s.io "fluentd" deleted
      clusterrolebinding.rbac.authorization.k8s.io "fluentd" deleted

  .. group-tab:: Terraform (Kubernetes)

    Simply remove the Kubernetes resource definitions created
    in this tutorial from your Terraform project, and run ``terraform apply``.

    As the resources will still exist in the Terraform state,
    Terraform will destroy them on the apply run.

You will also need to delete the resources you made on Catalyst Cloud.

.. tabs::

  .. group-tab:: CLI

    Delete the EC2 credentials created for Fluentd by running
    ``openstack ec2 credentials delete`` and passing it the Access Key ID.

    .. code-block:: bash

      openstack ec2 credentials delete ee55dd44cc33bb2211aaee55dd44cc33

    Run the following command to delete the ``fluentd`` container,
    and all objects stored within it.

    .. code-block:: bash

      openstack container delete fluentd --recursive

    Once this has been done, the ``fluentd`` should no longer be returned by
    ``openstack container list``.

  .. group-tab:: Dashboard

    .. note::

      EC2 credentials cannot be deleted from the dashboard.

      To make sure the EC2 credentials used in this tutorial are no longer usable,
      you may roll the EC2 credentials for your project by navigating to the
      **Project -> API Access** page, and pressing the **Recreate EC2 Credentials** button.

    To delete the Object Storage container used by Fluentd,
    navigate to the **Project -> Object Store -> Containers** page,
    where the ``fluentd`` container should be listed.

    .. image:: _containers_assets/object-storage-containers-list.png

    Click on the ``fluentd`` container to open the container properties.

    .. image:: _containers_assets/object-storage-containers-fluentd.png

    To delete a container using the dashboard, you must delete all files
    inside the container first.

    Click the tickbox next to **Name** to select all files in the container,
    then press the red Trash Can button in the top right of the page.

    .. image:: _containers_assets/object-storage-containers-fluentd-delete-files.png

    A confirmation window will open, asking if you'd like to delete the files.
    Press **Delete** to confirm.

    .. image:: _containers_assets/object-storage-containers-fluentd-delete-files-confirm.png

    Now you should be able to delete the container.
    Press the Trash Can button in the top right of the container properties window.

    .. image:: _containers_assets/object-storage-containers-created.png

    A confirmation window will open, asking if you'd like to delete the container.
    Press **Delete** to confirm.

    .. image:: _containers_assets/object-storage-containers-fluentd-delete.png

    The container should no longer be listed on the **Containers** page.

    .. image:: _containers_assets/object-storage-containers.png

  .. group-tab:: Terraform

    Simply remove the EC2 credential and Object Storage container
    resource definitions from your Terraform project, and run ``terraform apply``.

    As the resources will still exist in the Terraform state,
    Terraform will destroy them on the apply run.
