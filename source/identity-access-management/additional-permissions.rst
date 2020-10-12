#########################################
Additional permissions and access methods
#########################################

The following section details additional ways that you can restrict or allow
user access to resources on your project. The sections below do not directly
make  use of the **roles** we have discussed so far and instead focus on
permissions that are given to the user by some other means.

We have split these sections into *Permissions* which talks about certain
cases where users are given more control over objects than others and
*Methods of access* which discusses ways you can allow others to access
resources from the cloud when normally they would have inadequate privileges.

****************
Permissions
****************

When creating certain objects on the cloud, there are unique commands that are
only available to the individual who initially created the object. This is
because when that user created the object they were given
*ownership permissions* of the object. The most common example of this is when
creating a kubernetes cluster. If you are the person who created the cluster
then you are known as the **cluster administrator** and you will have access to
a wider range of commands. While there is a role required for interacting with
kubernetes clusters (detailed in the
:ref:`kubernetes section <kubernetes-user-access>` of the documents) only the
cluster administrator has the ability to interact directly with certain nodes
of the cluster, and to dictate behaviour for the master nodes.

A similar behaviour is observed when creating a cluster using your SSH key.
When creating a compute instance, you supply one SSH key and the only
user who is able to access that instance will be the person with the matching
private key. You can change this behaviour by creating additional users on the
instance itself, either after logging in to the instance yourself or in a cloud
config file; you then create your new users and provide a public ssh key for
each.


******************
Methods of access
******************

The following are alternative ways in which you can give individuals access to
different objects or resources on your project, without using a pre-defined
role.

Object storage
==============

For object storage, you can make use of *container access control lists* (ACLs)
to allow users who have the "auth_only" role to be able to view or edit the
contents of your object storage containers. You can find the full list of
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
