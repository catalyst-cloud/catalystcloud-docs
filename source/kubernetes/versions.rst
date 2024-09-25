.. _kubernetes-versions:

########
Versions
########

***************************
Kubernetes Versions on CCKS
***************************

Kubernetes community releases currently happen approximately three times per year.
These are called **minor version releases** (the ``y`` in ``v1.y.0``),
and contain new features and bug fixes.

**Patch version releases** (the ``z`` in ``v1.28.z``) are released more frequently,
and include minor bug fixes, and patches for critical security vulnerabilities.

Catalyst Cloud Kubernetes Service supports each **minor** version for *at least*
**6** months before it transitions to unsupported, giving users enough time to upgrade
their clusters. See the table below for currently supported versions and the expected
date they become unsupported.

.. _supported-kubernetes-versions:

**********************************
Supported CCKS Kubernetes Versions
**********************************

This table documents Catalyst Cloud Kubernetes Service minor versions, and their supported status.
It does not show patch versions, as all patch versions for a supported minor version are supported.


.. list-table::
   :widths: 11 20 30 30
   :header-rows: 1

   * - Version
     - Current Status
     - Initial Release Date
     - Unsupported Date
   * - ``1.24``
     - Unsupported
     - 2023-04-05
     - 2024-01-22
   * - ``1.25``
     - Unsupported
     - 2023-04-05
     - 2024-04-18
   * - ``1.26``
     - Unsupported
     - 2023-09-11
     - 2024-05-27
   * - ``1.27``
     - Unsupported
     - 2024-01-22
     - 2024-08-26
   * - ``1.28``
     - Supported
     - 2024-04-18
     - Expected 2024-10-28
   * - ``1.29``
     - Supported
     - 2024-05-27
     - Expected 2025-02-28
   * - ``1.30``
     - Supported
     - 2024-08-26
     - Expected 2025-06-28
   * - ``1.31``
     - In development
     - Expected 2024-10-31
     - Expected 2025-10-28


**********************
Version upgrade notes
**********************

Version v1.29 to v1.30
======================

Kubernetes `release changelog for v1.30 since v1.29`_.

.. _`release changelog for v1.30 since v1.29`: https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.30.md

In addition to the Kubernetes changes, we have:

* Upgraded minor version of Calico CNI.
* Upgraded minor version of Cinder CSI and Cloud Provider Openstack.


Note that skipping minor versions when upgrading a cluster is unsupported and
should not be attempted. For example, before upgrading to v1.30.x, you must
have upgraded to v1.29.x.


Version v1.28 to v1.29
======================

This is the first minor version upgrade of CCKS that supports upgrade of existing clusters.

Kubernetes `release changelog for v1.29 since v1.28`_.

In addition to the Kubernetes changes, we have:

* Extended :ref:`k8s-rbac-roles` to deny access to namespaces created by CCKS in addition to `kube-system`.
  These include `openstack-system`, `tigera-operator`, `calico-apiserver` and `calico-system`.
  This affects users with roles `k8s_viewer` and `k8s_developer`.
* Upgraded patch version of Calico CNI.
* Upgraded minor version of Cinder CSI and Cloud Provider Openstack.

Note: There is an outstanding issue during this upgrade where the cluster control plane may become
unavailable for a short duration.

To read more about performing a cluster upgrade, refer to :ref:`cluster-upgrade-upgrading`.


.. _`release changelog for v1.29 since v1.28`: https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.29.md


Version v1.27 to v1.28
======================

The upgrade path for clusters of version v1.27 and prior is to build a new cluster and migrate your workloads.
For more information see :ref:`cluster-upgrade-rebuild-vs-inplace`.

There are several changes to be aware of when deploying your workloads onto a newly built v1.28 cluster that
are different to the older v1.27 and below clusters.

Kubernetes `release changelog for v1.28 since v1.27`_.

In addition to the Kubernetes changes, CCKS has had a significant change in the driver used to create clusters
and several aspects have been revised.

The major differences are:

* The operating system for control plane and worker nodes is replaced with Flatcar Container OS (was Fedora Core OS).
* CCKS now runs several operations from within a management cluster. This is largely not visible to end users, but
  includes cluster operations such as:

  * Auto-scaling pods (if configured) run within the management cluster.
  * Auto-healing events (if configured) are monitored and actions taken from within the management cluster.
  * Reconciliation loops within the management cluster keep resources in the desired state.
    This means temporary failures are re-tried so cluster operations succeed more often, and
    some cluster resources are re-created if they are inadvertently deleted.
* Heat Stacks are no longer created in the customer project (in fact, they aren't created anywhere)
* Customer SSH Keypairs are no longer placed on all nodes.
* CCKS no longer offers Prometheus and Grafana stack as a managed deployment.
  You can gain the same features by installing the `kube-prometheus-stack`_ helm charts, and gain customisation options.
* The Octavia Ingress Controller is no longer installed as a managed deployment.
  CCKS supports Kubernetes ``Service`` objects with ``type: Loadbalancer``.
  This creates a single Octavia Loadbalancer for that service.
  For ingress solutions that loadbalance to multiple services within your cluster you can install
  `Ingress-NGINX`_, `Traefik Ingress`_, `Octavia Ingress controller`_ or another controller.

As with all upgrades you are advised to test this in a non-production environment, and ensure all workloads and
operations remain functional for your use-case.

.. _`release changelog for v1.28 since v1.27`: https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.28.md
.. _`kube-prometheus-stack`: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack/
.. _`Ingress-NGINX`: https://kubernetes.github.io/ingress-nginx/
.. _`Traefik Ingress`: https://doc.traefik.io/traefik/getting-started/install-traefik/#use-the-helm-chart
.. _`Octavia Ingress controller`: https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/octavia-ingress-controller/using-octavia-ingress-controller.md

Version 1.26 and below
======================

The upgrade path for clusters of version v1.27 and prior is build a new cluster and migrate your workloads.

For more information see :ref:`cluster-upgrade-rebuild-vs-inplace`.

**********************
Kubernetes Versioning
**********************

Kubernetes versions follow `Semantic Versioning`_ terminology.
Versions are expressed as ``x.y.z``, where ``x`` is the major version, ``y`` is the minor version
and ``z`` is the patch version.

.. list-table::
   :widths: 10 10 50
   :header-rows: 1

   * - Version Part
     - Example
     - Description
   * - Major
     - ``x`` in ``x.y.z``
     - Versions that may make incompatible API changes
   * - Minor
     - ``y`` in ``x.y.z``
     - Versions that adds functionality in a backwards compatible manner
   * - Patch
     - ``z`` in ``x.y.z``
     - Versions that makes backwards compatible bug fixes

Catalyst Cloud Kubernetes Service uses Cluster Templates to manage each Kubernetes
version, and the matrix of addons that make up our a managed Kubernetes cluster.

Users are able to see the Kubernetes version from the Cluster Template name. For
example:

.. code-block:: text

  kubernetes-v1.28.9-20240416

  Here, the Kubernetes version is v1.28.9 (Major version 1, Minor version 28 and Patch version 9).
  The template creation date is 16th April 2024.

The Cluster Template name contains the specific Kubernetes semantic version,
and a date in ``YYYYMMDD`` format which represents the release date of the template on Catalyst Cloud.

A Cluster Template with the same Kubernetes version and a later release date should always
be preferred over an older release date. This is to allow for bug fixes or Operating System
upgrades within the same Kubernetes patch version.

For more information, see `Kubernetes Releases`_.

.. _`Semantic Versioning`: https://semver.org
.. _`Kubernetes Releases`: https://kubernetes.io/releases

**********************************
Kubernetes Versions Support Policy
**********************************

Catalyst Cloud Kubernetes Service supports at least **3** minor versions.

When there is a new minor version released by the Kubernetes project, Catalyst
Cloud Kubernetes Service will work get it certified (passing the CNCF conformance
test) and Cluster Templates will be created.

When a new minor version is released, we will update the section
:ref:`Supported Kubernetes Versions <supported-kubernetes-versions>` with the new version and the expected
date it will become unsupported. There are times we will extend this date, and
the table will be updated.

An unsupported version means when users ask for support, you will be asked
to upgrade your cluster to a supported version first.

Catalyst Cloud Kubernetes Service create new Cluster Templates when a new
Kubernetes patch version is released, or an Operating System updated is available
on our cloud. When a new Cluster Template is created, any existing Cluster Templates
for the same minor version will be hidden.

For example, when releasing patch version ``v1.28.9``, the Cluster Template for
the previous patch version, ``v1.28.8`` will be marked as hidden.

.. note::

    Hiding a ``patch`` Cluster Template does **not** mean it is out of support.
    It simply means we are motivating customers to always create new clusters
    using the latest Cluster Template for that supported minor version.

Users should aim to run the latest patch for each minor version to get the latest
security and bug fixes.

.. note::

  Catalyst Cloud reserves the right to add/remove a new/existing Cluster
  Template, if there is a critical issue identified in the version,
  without further notice.

Finding Available Versions
==========================

You can find the set of Cluster Templates which are currently available on
Catalyst Cloud Kubernetes Service in the web interface as well as on the command line.

.. code-block:: console

  $ openstack coe cluster template list
  +--------------------------------------+-----------------------------------+---------------------------------------------------------------------------------+
  | uuid                                 | name                              | tags                                                                            |
  +--------------------------------------+-----------------------------------+---------------------------------------------------------------------------------+
  | 456a5390-67c3-4a89-b1e8-ba8dbf529506 | kubernetes-v1.26.14-prod-20240218 | environment:prod,build_id:20240218,pipeline_id:40826,created_at:20240218T183133 |
  | b922a741-099a-4987-bc32-d5f3e3a4beed | kubernetes-v1.27.11-prod-20240218 | environment:prod,build_id:20240218,pipeline_id:40827,created_at:20240218T183254 |
  | dafe4576-8de0-4024-a12a-1bc5197b474f | kubernetes-v1.28.9-20240416       | None                                                                            |
  +--------------------------------------+-----------------------------------+---------------------------------------------------------------------------------+

Upgrading Kubernetes Versions
=============================

When upgrading a cluster to a new version, skipping minor versions is **unsupported**.

For example, if the current cluster version is v1.28.x, then you cannot
upgrade directly to a v1.30.x. You have to upgrade to v1.29.x first,
and then perform another upgrade to v1.30.x.

This is in line with the `Kubernetes Version Skew policy`_, and also takes into account the
additional components that Catalyst Cloud Kubernetes Service is formed with.

.. warning::

    Catalyst Cloud reserves the right to force a *patch* version upgrade if
    there is an urgent critical security vulnerability
    (`CVE`_ rated as ``HIGH`` or ``CRITICAL``), and the customer cannot be contacted.

.. _`CVE`: https://cve.mitre.org
.. _`Kubernetes Version Skew policy`: https://kubernetes.io/releases/version-skew-policy/
