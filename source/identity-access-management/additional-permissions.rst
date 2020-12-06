#########################################
Additional permissions and access methods
#########################################

The following section details additional ways that you can restrict or allow
user access to resources on your project. The sections below do not directly
make use of the **roles** we have discussed so far and instead focus on
permissions or access that are provided to the user or application by some
other means.

We have split these sections into *Permissions* which talks about certain
cases where users are given more control over objects than others and
*Methods of access* which discusses ways you can allow others to access
resources from the cloud when normally they would have inadequate privileges.

****************
Permissions
****************

When creating certain objects on the cloud, there are unique commands that are
only available to the individual who initially created the object. This is
because when the user creates the object they are assigned the equivalent
**root** or **admin** level rights for that object.

Kubernetes cluster access
=========================

One common example of this is when creating a kubernetes cluster. If you are
the person launching the cluster then you will have your cloud credentials
mapped to those of the **cluster administrator** through the use of a
trust created between your user and the cluster admin user. This in turn means
you will be the only user that can access that cluster by default.

While there is a role which dictates whether a user is able to
interact with **any** kubernetes clusters
(detailed in the :ref:`kubernetes section <kubernetes-user-access>` of the
documents) only the **cluster administrator** is able to initially communicate
with a cluster once it is created.

This trust provides the user with the *cluster admin* rights the ability to
download the cluster config file which they can then use to provide
authentication for tools such as **kubectl**.

In order to provide other users access to this cluster the following is
required:

* The creation of a cluster config file that uses keystone as the means to
  determine what right a user has in a cluster based on the roles they have
  associated with their cloud user account. A copy of this needs to be shared
  with all people that require access to the cluster.  See
  :ref:`Authenticating a non-admin cluster user<non-admin-cluster-user>`
* The addition of appropriate Kubernetes roles to those users that need access
  to the cluster. For an explanation of these see
  :ref:`user access<kubernetes-user-access>`


Cloud server access
===================

A similar behaviour is observed when creating a new cloud instance. It is a
best practice in cloud computing for user access to be restricted to
authentication using public/private keypairs which allows for access via
passwords to be disabled by defaul for greater security.

When a new compute instance is launched you supply the public part of an SSH
key, that you have access to, as one of the launch parameters, this is then
added the the **.ssh/authorized_keys** file for the default user of the OS
that you are deploying.

For example:

On an Ubuntu based compute instance you would log in as the user *ubuntu* using
the SSH key that corresponds to the public key information you provided at
instance creation time.

In order to give additional users access to this instance you would need to do
one of the following:

* As the user with access you add new users within the OS itself using the
  appropriate tools for that OS.
* Alternatively you can add further public SH keys to the **authorized_keys**
  giving the new users access to the instance via the existing default user.
  While this might seem like a convenient approach it does mean you sacrifice
  the ability to audit access to that server.

******************
Methods of access
******************

The following are ways in which you can restrict access for individuals and/or
applications to different objects or resources in your project, without
needing to use pre-defined roles or when access is anonymous and the use of a
role is not feasible.

Object storage
==============

For object storage, you can make use of *container access control lists* (ACLs)
to allow users who have the "auth_only" role to be able to view or edit the
contents of your object storage containers. You can find the full details of
permissions and restrictions you can set on your containers in the
`openstack swift documentation`_

.. _`openstack swift documentation`: https://docs.openstack.org/swift/latest/overview_acl.html

In addition to using ACLs to restrict or permit access to your object storage
containers, you also have the option of making your containers public or giving
them temporary URLs to allow access for a limited time. The processes for these
can be found in the :ref:`object storage<object-storage-access>` section of
this documentation.

Instances and clusters
======================

Another method of access control, that affects instances and clusters, is
security groups. These are used to define what traffic is able to pass into or
out of your instances. The full description of security groups and how they
function can be found in the :ref:`network section<security-groups>` of the
documentation.
