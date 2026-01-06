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

**Patch version releases** (the ``z`` in ``v1.31.z``) are released more frequently,
and include minor bug fixes, OS updates, and patches for critical security vulnerabilities.

Catalyst Cloud Kubernetes Service supports each **minor** version for *at least*
**6** months before it transitions to unsupported, giving users enough time to upgrade
their clusters. See the table below for currently supported versions and the expected
date they become unsupported.

.. _supported-kubernetes-versions:

**********************************
Supported CCKS Kubernetes Versions
**********************************

This table documents Catalyst Cloud Kubernetes Service minor versions and
their supported status. It does not show patch versions, as all patch
versions for a supported minor version are supported.

For unsupported releases we list the latest template name in case an old
version is needed for testing upgrades. Otherwise, these versions are hidden
in the API.


.. list-table::
   :widths: 11 20 30 30 30
   :header-rows: 1

   * - Version
     - Current Status
     - Initial Release Date
     - Unsupported Date
     - Last Released Template
   * - ``1.29``
     - Unsupported
     - 2024-05-27
     - 2025-03-19
     - ``kubernetes-v1.29.14-20250217``
   * - ``1.30``
     - Unsupported
     - 2024-08-26
     - 2025-06-28
     - ``kubernetes-v1.30.14-20250623``
   * - ``1.31``
     - Supported
     - 2024-12-20
     - 2025-11-07
     - ``kubernetes-v1.31.13-20250917``
       ``kubernetes-v1.31.14-20251130``
   * - ``1.32``
     - Supported
     - 2025-02-05
     - Expected 2026-02-28
     -
   * - ``1.33``
     - Supported
     - 2025-05-14
     - Expected 2026-06-28
     -
   * - ``1.34``
     - Supported
     - 2025-11-06
     - Expected 2026-10-27
     -


**********************
Version upgrade notes
**********************

Patch versions v1.32.11, v1.33.7 and v1.34.3
============================================

This release fixes a GPU driver installation regression present in v1.31.14,
v1.32.10, v1.33.6 and v1.34.2.

Note there is no release available for v1.31.14 with this fix as it is no
longer supported. It is recommended to upgrade clusters running v1.31.x to a
newer supported version. See :ref:`supported-kubernetes-versions` and the
:doc:`Cluster Upgrade </kubernetes/cluster-upgrade>` documentation for more
information.


Patch versions v1.31.14, v1.32.10, v1.33.6 and v1.34.2
======================================================

These patch versions contain two notable fixes:

* Upgraded containerd to 1.7.29 to fix several container escape vulnerabilities
  in runc. These are CVE-2025-31133, CVE-2025-52565 and CVE-2025-52881. No
  active exploits have been identified but it is recommended to upgrade any
  affected clusters to the latest patch version for security.
* Fixed a bug previously only available in v1.34 that was installing customer
  SSH keys onto nodes. This was causing problems when transferring cluster
  ownership. Direct access to nodes is not supported but is possible with
  privileged pods (eg. `kubectl ssh node` plugin).


Version v1.33 to v1.34
======================

Kubernetes `release changelog for v1.34 since v1.33`_.

.. _`release changelog for v1.34 since v1.33`: https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.34.md#changelog-since-v1330

In addition to the Kubernetes changes, we have:

* Upgraded patch version of Calico CNI.
* Upgraded base OS Flatcar to latest stable release.
* Fixed a bug that was installing customer SSH keys onto nodes. This was causing problems when
  transferring cluster ownership. Direct access to nodes is not supported but is possible
  with privileged pods (eg. `kubectl ssh node` plugin).
* Added reloader pod to support cluster credential rotation (API coming soon).

Note that skipping minor versions when upgrading a cluster is unsupported and
should not be attempted. For example, before upgrading to v1.34.x, you must
be running at least v1.33.x.


Patch versions v1.31.13, v1.32.9 and v1.33.5
============================================

As of these versions GPU support has been added to our OS images which will
auto-detect GPU compute flavors and install NVIDIA drivers.

For more information on using GPU with Kubernetes, please refer to
the :doc:`CCKS GPU acceleration documentation </kubernetes/gpu-acceleration>`.


Version v1.32 to v1.33
======================

Kubernetes `release changelog for v1.33 since v1.32`_.

.. _`release changelog for v1.33 since v1.32`: https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.33.md

In addition to the Kubernetes changes, we have:

* Upgraded minor versions of  CoreDNS, Cinder CSI and Cloud Provider OpenStack.
* Upgraded patch version of k8s-keystone-auth.
* Upgraded base OS Flatcar to latest stable release.
* Added kubeReserved to worker nodes to reserve memory and vCPU for Kubelet
  overhead to avoid OOM events. This value scales based on node size. More
  information can be found in the :ref:`k8s-kubelet-reserved` documentation
  topic.

Note that skipping minor versions when upgrading a cluster is unsupported and
should not be attempted. For example, before upgrading to v1.33.x, you must
be running at least v1.32.x.


Patch versions v1.30.13, v1.31.9, v1.32.5
==========================================

In patch releases, to keep compatibility we typically only upgrade the
underlying OS and upgrade Kubernetes itself.

This patch release contains an additional bugfix that was introduced in
v1.33.0 that adds ``kubeReserved`` to worker nodes and as such some capacity
will no longer be available to workload pods.

To learn more about ``kubeReserved`` please refer to
the :ref:`k8s-kubelet-reserved` documentation topic.


Version v1.31 to v1.32
======================

Kubernetes `release changelog for v1.32 since v1.31`_.

.. _`release changelog for v1.32 since v1.31`: https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.32.md

In addition to the Kubernetes changes, we have:

* Upgraded minor versions of Calico CNI, CoreDNS, Cinder CSI and Cloud Provider OpenStack.
* Upgraded patch version of k8s-keystone-auth.
* Upgraded base OS Flatcar to latest stable release.


Note that skipping minor versions when upgrading a cluster is unsupported and
should not be attempted. For example, before upgrading to v1.32.x, you must
be running at least v1.31.x.


Version v1.30 to v1.31
======================

Kubernetes `release changelog for v1.31 since v1.30`_.

.. _`release changelog for v1.31 since v1.30`: https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.31.md

In addition to the Kubernetes changes, we have:

* Upgraded minor versions of Calico CNI, CoreDNS, Cinder CSI and Cloud Provider OpenStack.
* Upgraded patch version of etcd.
* Upgrades base OS flatcar to latest stable release.

This upgrade contains an incompatiblity between v1.30 control plane nodes and
v1.31 nodes. This typically causes the first worker node upgraded to fail
joining the cluster and be replaced by autohealing, after which time the
control plane nodes will have been upgraded. This requires label
`auto_healing_enabled=True`, and without auto-healing the upgrade may stall.
Please open a support ticket to either enable autohealing prior to your
upgrade, or to resolve the issue during the upgrade.

Note that skipping minor versions when upgrading a cluster is unsupported and
should not be attempted. For example, before upgrading to v1.31.x, you must
be running at least v1.30.x.


Version v1.29 to v1.30
======================

Kubernetes `release changelog for v1.30 since v1.29`_.

.. _`release changelog for v1.30 since v1.29`: https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.30.md

In addition to the Kubernetes changes, we have:

* Upgraded minor version of Calico CNI.
* Upgraded minor version of Cinder CSI and Cloud Provider OpenStack.
* Upgrades base OS flatcar to latest stable release.


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
* Upgraded minor version of Cinder CSI and Cloud Provider OpenStack.

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

  kubernetes-v1.31.4-20241220

  Here, the Kubernetes version is v1.31.4 (Major version 1, Minor version 31 and Patch version 4).
  The template creation date is 20th December 2024.

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

For example, when we release patch version ``v1.31.2``, the Cluster Template for
the previous patch version, ``v1.31.1`` will be marked as hidden.

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
  +--------------------------------------+------------------------------+------+
  | uuid                                 | name                         | tags |
  +--------------------------------------+------------------------------+------+
  | 59b4440d-05f1-4088-971c-60d5bd11690c | kubernetes-v1.30.7-20241121  | None |
  | ee9d62ac-bbf1-4b88-9e2a-d5e083e73708 | kubernetes-v1.31.4-20241220  | None |
  | 5613be85-5f5f-45ca-9f60-cad5c2850224 | kubernetes-v1.32.1-20250121  | None |
  +--------------------------------------+------------------------------+------+


Upgrading Kubernetes Versions
=============================

When upgrading a cluster to a new version, skipping minor versions is **unsupported**.

For example, if the current cluster version is v1.29.x, then you cannot
upgrade directly to a v1.31.x. You have to upgrade to v1.30.x first,
and then perform another upgrade to v1.31.x.

This is in line with the `Kubernetes Version Skew policy`_, and also takes into account the
additional components that Catalyst Cloud Kubernetes Service is formed with.

.. warning::

    Catalyst Cloud reserves the right to force a *patch* version upgrade if
    there is an urgent critical security vulnerability
    (`CVE`_ rated as ``HIGH`` or ``CRITICAL``), and the customer cannot be contacted.

.. _`CVE`: https://cve.mitre.org
.. _`Kubernetes Version Skew policy`: https://kubernetes.io/releases/version-skew-policy/
