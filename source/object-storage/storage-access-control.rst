.. _object-storage-access:

###############
Managing access
###############

The typical user roles, such as ``Project Member`` or ``Object Storage``, that
allow access to people that need to work with object storage do not provide for
any level of granular control in regard to limiting a users level of access to
individual object storage containers and the objects within them.

To overcome this it is now possible to create a user with the ``Auth Only``
role. This role is described in more detail here.

**This tutorial assumes the following:**

* You have installed the OpenStack command line tools and understand how to
  work with an OpenStack RC file, as explained at :ref:`command-line-interface`

This walk through will make use of the following, preconfigured setup.

**Users**
For the purposes of this tutorial we have 3 users available, they are

* clouduser
* restricted-user-1
* restricted-user-2

Initially both of the restricted users will have just the ``Auth Only`` role
assigned to them. The clouduser will have the ``Project Member`` role assigned.

**Object Storage**
There are 2 object storage containers available, these are access_1 and
access_2. They have no existing ACLs assigned to them. The container access_1
has a single file stored within it called foo.txt.

**************************
Using access control lists
**************************

By combining the use of ``Access Control Lists`` (**ACL**) with the ``Auth
Only`` role, we are able to provide more granular read and write access to
either specific users or other cloud projects.

.. Note::

    While it is also possible to achieve the same level of object storage
    access control using the ``Compute Start/Stop`` role, users with this
    role will also have the ability to change the running state of any Compute
    resource with in the current project.

Configuring the user
====================

In order to set up ACL controlled access you will first need to create a user
that has ``Auth Only`` as it's only role. This can be done through the
``Management -> Access Control -> Project Users`` page. From here click the
**+ Invite User** button.

You will need to provide an email address for the user and then ensure that the
only role that has been checked is the ``Auth Only`` option.

.. Note::

    It is possible to use an email with a ``tag`` for this user. A tag is a
    where an additional text string is appended with a "+" symbol to an
    existing email address. e.g. operations+restricted-storage@example.com

    This will send the email to the existing address of operations@example.com
    allowing it to be filtered and managed without the need to create a whole
    new email account.

Configuring the ACLs
====================

This part of the configuration will require the use of the command line tools.

Getting the auth only users identity
------------------------------------

First we need to retrieve the user ID for our Auth Only user. To do this you
will need to log into the dashboard and download their openrc file. Source the
file and then run the following command. It will provide the user_id as one of
the output fields.

.. code-block:: bash

    # as the user restricted-user-1

    $ openstack token issue
    +------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Field      | Value                                                                                                                                                                                   |
    +------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | expires    | 2019-08-19T12:59:17+0000                                                                                                                                                                |
    | id         | gAAAAABdWdhFLKs1OT8rGpiUqa_5BLFlxP-cg59HEGkHu81WLNkRk_Y_knnbS1CdCCE8qFECnmrubep652Dt6ITGgHQoXA0tZerOuxvkgvObEfsovHC61pOr8mvhZ0l7Nna9GcXLz37kJ05HifI3DiqodqrwfXNCsGpDq27DZ5z9LLPzqGvMBLI |
    | project_id | eac679e4896146e6827ce29d755fe289                                                                                                                                                        |
    | user_id    | 11d1cb41f05140ebadcec49b9a67a2d7                                                                                                                                                        |
    +------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+


As a test we can confirm that currently our test user has no access to any
object storage containers within our project. If we try and list the available
containers we will receive a 403 error as access is currently forbidden.

.. code-block:: bash

  $ openstack container list
  Forbidden (HTTP 403)

.. Note::

    Once you have the restricted user's ID value you will need to swap to using a
    user with the Project Member or object storage role in order to assign ACLs to
    the storage containers.


Creating a READ access rule
===========================

Now we need to check the current state of the access for the container we want
to work with. To list the available object storage containers in your project
run the following:

.. code-block:: bash

    $ openstack container list
    +----------+
    | Name     |
    +----------+
    | access_1 |
    | access_2 |
    +----------+

To confirm that there are currently no access controls defined on these
containers we can execute the following command to display information about
a specific container.

.. code-block:: bash

    $ openstack container show access_1
    +--------------+---------------------------------------+
    | Field        | Value                                 |
    +--------------+---------------------------------------+
    | account      | AUTH_eac679e4896146e6827ce29d755fe289 |
    | bytes_used   | 27                                    |
    | container    | access_1                              |
    | object_count | 1                                     |
    +--------------+---------------------------------------+

If any ACLs existed they would have been displayed in the table above as either
a ``read_acl``or ``write_acl`` field if they were set.

We are now ready to add our access rule. We will start by adding read access
rule for our restricted object storage user.

We will be using the ``swift client`` to achieve this. If you do not currently
have this installed you can add it to your virtualenv with this command.

.. code-block:: bash

  $ pip install python-swiftclient

The syntax of the command to add a read ACL to a container is as follows. The
same format is used for adding a write ACL and it is possible to add both in
the same action.

.. code-block:: bash

    swift post <container> --read-acl "<permissions>"

Where:

* **<container>** is the name of the container to apply the ACL to.
* **<permissions>** is the string value denoting what access to assign to the
    container.

The following table describes how the permissions are defined. These can be
applied singularly or as a comma separated list to both the --read-acl and
--write-acl parameters.

+--------------------------+----------------------------------------------------------+
| Element                  | Description                                              |
+==========================+==========================================================+
| <project-id>:<user-id>   | The specified user in the project has access             |
+--------------------------+----------------------------------------------------------+
| <project-id>:\*          | Any user with a role in the specified project has access |
+--------------------------+----------------------------------------------------------+
| \*:<user-id>             | The specified user has access                            |
+--------------------------+----------------------------------------------------------+

Let's add read access for restricted-user-1 to the container access-1. As names
are not supported for ACL definitions we will use the user id instead.

.. code-block:: bash

  swift post access_1 --read-acl "*:11d1cb41f05140ebadcec49b9a67a2d7"

And if we check the state of the container now we can see that there is a
``read_acl`` field present with the user's id associated with it.

.. code-block:: bash

  # as clouduser

  $ openstack container show access_1
  +--------------+---------------------------------------+
  | Field        | Value                                 |
  +--------------+---------------------------------------+
  | account      | AUTH_eac679e4896146e6827ce29d755fe289 |
  | bytes_used   | 27                                    |
  | container    | access_1                              |
  | object_count | 1                                     |
  | read_acl     | *:11d1cb41f05140ebadcec49b9a67a2d7    |
  +--------------+---------------------------------------+

If we now source the credentials for the user that has been granted access they
should now be able to run the following command and see the details of the
container.

.. code-block:: bash

  # as restricted-user-1

  $ openstack container show access_1
  +--------------+---------------------------------------+
  | Field        | Value                                 |
  +--------------+---------------------------------------+
  | account      | AUTH_eac679e4896146e6827ce29d755fe289 |
  | bytes_used   | 27                                    |
  | container    | access_1                              |
  | object_count | 1                                     |
  +--------------+---------------------------------------+

We can also confirm that our other restricted user still has no access to the
container that we just modified.

.. code-block:: bash

  # as restricted-user-2

  $ openstack container show access_1
  Forbidden (HTTP 403)

With the ACL in place restricted-user-1 can now also view the contents of the
container and download them if desired.

.. code-block:: bash

  # as restricted-user-1

  $ openstack object list access_1
  +---------+
  | Name    |
  +---------+
  | foo.txt |
  +---------+

  $ openstack object save --file myfoo.txt access_1 foo.txt
  $ cat myfoo.txt
  Hello object storage user!


Creating a WRITE access rule
============================

The ``READ ACL`` does not however give the user rights to create or delete
objects in the container they can view. In order to do this they will need to
be included in the ``WRITE ACL``

First let's repeat the process we used earlier to add the read access rule and
add a write access rule to the access_1 container for restricted-user-2.

.. code-block:: bash

  # as clouduser

  $ swift post access_1 --write-acl "*:9298ecab1c90450abedcd82e0e4136ce"

  $ openstack container show access_1
  +--------------+---------------------------------------+
  | Field        | Value                                 |
  +--------------+---------------------------------------+
  | account      | AUTH_eac679e4896146e6827ce29d755fe289 |
  | bytes_used   | 27                                    |
  | container    | access_1                              |
  | object_count | 1                                     |
  | read_acl     | *:11d1cb41f05140ebadcec49b9a67a2d7    |
  | write_acl    | *:9298ecab1c90450abedcd82e0e4136ce    |
  +--------------+---------------------------------------+


Now we can upload a test file to the container to confirm that the rule is
correct.

.. code-block:: bash

  # as restricted-user-2

  $ openstack object create access_1 bar.txt
  +---------+-----------+----------------------------------+
  | object  | container | etag                             |
  +---------+-----------+----------------------------------+
  | bar.txt | access_1  | fa2337fd140c5746f9facfba80fa1510 |
  +---------+-----------+----------------------------------+


In order to verify that is worked we will need to switch back to a user that
has read access, this could be either **clouduser** or **restricted-user-1**.

.. code-block:: bash

  # as restricted-user-1

  $ openstack object list access_1
  +---------+
  | Name    |
  +---------+
  | bar.txt |
  | foo.txt |
  +---------+

The final operation we need to verify is ability to delete an object. The
following example show that we can remove any content in the container, even if
it was not created by the current user.

.. code-block:: bash

  # as restricted-user-2

  $ openstack object delete access_1 foo.txt

Again we can confirm success of the request with one of our READ enabled users.

.. code-block:: bash

  # as restricted-user-1

  $ openstack object list access_1
  +---------+
  | Name    |
  +---------+
  | bar.txt |
  +---------+
