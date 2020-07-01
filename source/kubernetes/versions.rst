.. _kubernetes-versions:

########
Versions
########

*******************
Kubernetes Versions
*******************

Kubernetes community releases a minor version about every three months. In those
minor version releases, there are some new features and bug fixes. Patch versions
will be released more frequent (e.g. weekly) and genereally to include critical
fixes , e.g. security fixes.

Catalyst Cloud Kubernetes Service supports each ``minor`` version for at least
``9`` months before deprecating it to give users enough time to upgrade their
clusters. The 9 months is calculated based on that the Kubernetes community
maintains release branches for the latest 3 minor versions and they release a
new mintor version about every three months. User will get support from
Catalyst Cloud to *any* patch and date version within these releases.

What is Kubernetes Versions
===========================

Kubernetes follows the standard `Semantic Versioning`_ terminology. Versions are
expressed as x.y.z, where x is the major version, y is the minor version and z
is the patch version.

+---------------+------------------------------------------------------------------+
| Version Part  | Description                                                      |
+===============+==================================================================+
| MAJOR         | versions that may make incompatible API changes                  |
+---------------+------------------------------------------------------------------+
| MINOR         | versions that adds functionality in a backwards compatible manner|
+---------------+------------------------------------------------------------------+
| PATCH         | versions that makes backwards compatible bug fixes               |
+---------------+------------------------------------------------------------------+

For example:

.. code-block:: bash

  [major].[minor].[patch]
  
  v1.18.2
  v1.17.5
  v1.16.9

Catalyst Cloud Kubernetes Service uses cluster template to manage each Kubernetes
version and the matrix of addons that running on top of Kubernetes cluster. And
users should be able to see the Kubernetes version from the cluster template name. For
example: *kubernetes-v1.16.9-prod-20200602*, the last 8 digits is the release
date of this template tagged by Catalyst Cloud.


For more information, see `Kubernetes Release Versioning`_.

.. _`Semantic Versioning`: http://semver.org/
.. _`Kubernetes Release Versioning`: https://github.com/kubernetes/community/blob/master/contributors/design-proposals/release/versioning.md#kubernetes-release-versioning

Kubernetes Versions Support Policy
==================================

Catalyst Cloud Kubernetes Service supports at least ``3`` minors versions. As long
as there is a new minor version released, Catalyst Cloud Kubernetes Service will
try to get it certified (pass the CNCF conformance test) and released in ``30``
days. And then deprecate the oldest minor version. For example, if the current
3 minor versions are v1.17.x, v1.16.x and v1.15.x. Then as long as the new
v1.18.x released, the version v1.15.x will be removed and out of supported.
Out of support means whenever users ask for support, you will be asked
to upgrade your clusters to supported versions first. In short, if the cluster
is running on a minor version which has been deprecated, then the cluster is
out of support.

Catalyst Cloud Kubernetes Service supports the latest stable patch versions
for each minor version. As long as there is a patch version released, the oldest
patch version will be hidded/removed. For example, if current versions
supported for v1.16.x are v1.16.9, then v1.16.9 will be hidded/removed in
favor of the release of v1.16.10. 

.. note::

    For clarity, hidding a ``patch`` version/template doesn't mean it is out of
    support, it means we are motivating customers to always use the latest one.
    If there is a bug impacting customers on the latest patch version we would
    either unhide the previous version or publish a new patch version.

Users should always aim to run the latest patch version for each minor version
to get the latest security enhancements. For example, if the current Kubernetes
cluster is running on v1.16.9 and the new patch version is v1.16.10, then it
is highly recommended to upgrade to v1.16.10 as soon as possible. 

.. note::

    Catalyst Cloud reserves the right to add/remove a new/existing cluster
    template if there is a cirtical issue identified in the version without
    further notice.

****************************
Upgrading Kubernetes Version
****************************

When doing Kubernetes version upgrade, minor vesion cannot be skipped. For
example, if the current cluster version is v1.16.x, then it's not allowed
to upgrade to v1.18.x. You have to upgrade to v1.17.x and then do another
upgrade to v1.18.x.

.. note::

    Catalyst Cloud reserves the right to do a force patch version upgrade if
    there is an urgent critical security vulnerbility (`CVE`_ rated as high) and
    the customer cannot be reached.

.. _`CVE`: https://cve.mitre.org/

*******************************
Node OS Version and CRI Version
*******************************

Catalyst Cloud Kubernetes Service is using Fedora CoreOS as the Kubernetes Node
operating system, the original image will be updated regularly. We're using Podman
and systemd to manage all the Kubernetes components and using Docker for the
container runtime of Kubernetes.

* Node Operating System: Fedora CoreOS 31
* Docker: 18.09.8
* Podman: 1.8.1

***********
CNI Version
***********

The only supported CNI on Catalyst Cloud Kubernetes Service is Calico and the
current versions is v3.13.1