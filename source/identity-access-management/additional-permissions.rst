#####################################
Additional access methods/permissions
#####################################

The following section details different permissions that you are given that
exists outside the scope of the roles we have previously mentioned. We will
also discuss different methods of accessing objects on your project beyond the
use of roles.

****************
Permissions
****************

Some of the objects you create on your project will give ownership permissions
to the user who created them. The most common example of this is when creating
a kubernetes cluster. If you are the person who created the cluster then you
are known as the "cluster administrator." While there is a role required for
interacting with kubernetes clusters (detailed in the
:ref:`kubernetes section <kubernetes-user-access>` of the documents) the
individual user who initially creates the cluster has additional permissions
which allow them to interact directly with certain nodes of the cluster, and to
dictate behaviour for the master nodes.

Another example of having an individual have extra permissions is when someone
creates an instance and supplies their personal SSH key to the instance. The
user who creates the instance, using their SSH key, will be the only one able
to access the instance. You can change this behaviour by including additional
SSH keys in a cloud config file and injecting them into the instance when it is
created. Or you can add these key after the fact and restart your instance to
have it acknowledge the new keys. Either way, you will not be able to access an
instance if you have the incorrect SSH key to interface with it.

******************
Methods of access
******************

The following are some specific cases where you can allow access to different
objects or resources on your project, without giving a uses a specific role or
set of permissions.

For object storage, you can make use of *container access control lists* to
allow users who have the "auth_only" role to be able to view or edit the
contents of your object storage containers. You can find the full list of
permissions and restrictions you can set on your containers using ACLs
in the `openstack swift documentation`_

.. _`openstack swift documentation`: https://docs.openstack.org/swift/latest/overview_acl.html

In addition to using ACLs to restrict or permit access to your object storage
containers, you also have the option of making your containers public or giving
them temporary URLs to allow access for a limited time. The process for which
can be found in the :ref:`object storage<object-storage-access>` section of
this documentation.

For accessing clusters or instances created in your project, another method of
access control is using security groups to define what traffic is able to pass
into or out of your instances. The full description of security groups and
how they function can be found in the :ref:`network section<security-groups>`
of the documentation.
