.. _object-storage-access:

###############
Managing access
###############

The typical user roles, such as ``Project Member`` or ``Object Storage``, that
allow users to work with object storage resources; function as an all or
nothing approach. Either the user has the role and can do anything with the
container, or they do not have the role and they can't interact with any
object storage resources.

To overcome this limitation, it is possible to create a user with the
``Auth Only`` role and give them access to a container using an Access Control
List. You can find more information on the auth only role
:ref:`here <access_control>`.

****************************
Assumptions before beginning
****************************

The following are a list of assumptions that this tutorial makes about your
project before we can begin looking at the steps to creating an ACL. If you
do not have these pre-requisites already, then it will be useful to take a
second to set things up so you can follow along with the example.

We assume that:

* You have installed the OpenStack command line tools and understand how to
  work with an OpenStack RC file, as explained at :ref:`command-line-interface`
* For the purposes of this tutorial you have 3 users available, they are:

  * a cloud-user
  * restricted-user-1
  * restricted-user-2
  * Initially both of the restricted users will have just the ``Auth Only``
    role assigned to them. The cloud-user will have the ``Project Member``
    role assigned.
* You have two containers that will be used for these tutorials. In the
  examples below they are named, access_1 and access_2.

  * We assume that these containers have no existing ACLs assigned to them.
  * There should be a single file stored in access_1 called "foo.txt"

***************************
Setting up your storage URL
***************************

.. Warning::
  If the swift command is not given the correct storage URL it will try to log
  in to the cloud again, but will report an error about authentication options.

Another thing that you should be aware of before continuing with this example:
If you are using a Token for authentication to the cloud you will need to set
up another environment variable in order to interact with the Swift API. To
start, we need to find the object storage API endpoint for our region. You can
find the full list of API endpoints under :ref:`this section<apis>` of the
documentation.

For this example we will be using the object storage endpoint for nz-por-1, but
you can use whichever one fits the region you want to work in:

.. code-block::

  https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_%projectid%

The follow command sets the environmental variable for the swift command.

.. code-block:: bash

  $ export OS_STORAGE_URL="https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_${OS_PROJECT_ID}"

Alternately you can pass the URL as a command line option:

.. code-block:: bash

  $ swift --os-storage-url https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_${OS_PROJECT_ID} list

**************************
Using access control lists
**************************

By combining the use of Access Control Lists (**ACLs**) with the **Auth
Only** role, we are able to provide granular read/write access to
our object storage container(s) for specific users or from other cloud
projects.

Configuring a restricted user
=============================

In order to set up ACL controlled access you will first need to create a user
that has ``Auth Only`` as it's only role. This can be done through the
``Management -> Access Control -> Project Users`` page. From here click the
**+ Invite User** button.

You will need to provide an email address for the user and then ensure that the
only role that has been checked is the ``Auth Only`` role.

.. Note::

    It is possible to use an email with an extension for this user. An extension
    is where an additional text string is inserted typically with a "+" symbol
    within an existing email address. e.g. operations+restricted-storage@example.com

    This will send the email to the existing address of operations@example.com
    allowing it to be filtered and managed without the need to create a whole
    new email account.

    You may need to check that your email server supports this feature, and
    confirm that "+" is the correct symbol, some mail servers use different
    symbols. For more information see `Email Sub-addressing`_.

As mentioned in the prerequisites for this section, we will need two
restricted users. In our examples, they are named restricted-user-1 and
restricted-user-2.

Configuring the ACLs
====================

This part of the configuration will require the use of the command line tools.

Getting the auth only users identity
------------------------------------

First we need to retrieve the user ID for our auth_only user. To do this you
will need to log into the dashboard as the restricted user and download their
OpenRC file. Next, you will need to source the  OpenRC file, and then run the
following command. It will provide the ``user_id`` as one of the output fields,
be sure to make a note of this ID as we will use it later.

.. code-block:: bash

    # as the user: restricted-user-1

    $ openstack token issue
    +------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Field      | Value                                                                                                                                                                                   |
    +------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | expires    | 2019-08-19T12:59:17+0000                                                                                                                                                                |
    | id         | gAAAAABdWdhFLKs1OT8rGpiUqa_5BLFlxP-XXXXXXXXXXXXXXXXXX_Y_knnbS1CdCCE8qFECnmrubep652Dt6ITGgHQoXA0tZerOuxvkgvObEfsovHC61pOr8mvhZ0l7Nna9GcXLz37kJ05HifI3DiqodqrwfXNCsGpDq27DZ5z9LLPzqGvMBLI |
    | project_id | eac679e489614xxxxxxce29d755fe289                                                                                                                                                        |
    | user_id    | 11d1cb41f05140ebadxxxxxx9a67a2d7                                                                                                                                                        |
    +------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+


As a test we can confirm that currently our test user has no access to any
object storage containers within our project. If we try and list the available
containers we will receive a 403 error as access is currently forbidden.

.. code-block:: bash

  $ openstack container list
  Forbidden (HTTP 403)

Once you have the restricted user's ID value you will need to swap back to a
user with the project_member or object_storage role. Once that is done we can
begin assigning ACLs to our container.


Creating a READ access rule
===========================

Now we need to check the current state of access for the container we want
to work with. To list the available object storage containers in your project
run the following:

.. code-block:: bash

  # as the cloud-user

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
    | account      | AUTH_eac679e489614xxxxxxce29d755fe289 |
    | bytes_used   | 27                                    |
    | container    | access_1                              |
    | object_count | 1                                     |
    +--------------+---------------------------------------+

If any ACLs existed they would have been displayed in the table above as either
a ``read_acl`` or ``write_acl``. Now that we know there are no
existing ACLs, we can start to create our own. We will start by adding a read
access rule for our restricted object storage user.

We will be using the **swift client tools** to achieve this. If you do not
currently have these installed you can add them to your virtualenv with this
command:

.. code-block:: bash

  $ pip install python-swiftclient

The syntax of the command to add a read ACL to a container is as follows:

.. code-block:: bash

    $ swift post <container> --read-acl "<permissions>"

The same format is used for adding a write ACL and it is possible to add both
in the same action.

In this command:

* **<container>** is the name of the container to apply the ACL to.
* **<permissions>** is the string value denoting what access to assign to the
  container.

The following table describes how the permissions are defined. These can be
applied singularly or as a comma separated list to both the - -read-acl and
- -write-acl parameters.

+--------------------------+----------------------------------------------------------+
| Element                  | Description                                              |
+--------------------------+----------------------------------------------------------+
| <project-id>:<user-id>   | The specified user in the project has access             |
+--------------------------+----------------------------------------------------------+
| <project-id>:\*          | Any user with a role in the specified project has access |
+--------------------------+----------------------------------------------------------+
| \*:<user-id>             | The specified user has access                            |
+--------------------------+----------------------------------------------------------+

Let's add read access for restricted-user-1 to the container access-1. As names
are not supported for ACL definitions we will use the user id instead.


.. code-block:: bash

  $ swift post access_1 --read-acl "*:11d1cb41f05140ebadxxxxxx9a67a2d7"

And if we check the state of the container now we can see that there is a
``read_acl`` field present with the user's id associated with it.

.. code-block:: bash

  # as clouduser

  $ openstack container show access_1
  +--------------+---------------------------------------+
  | Field        | Value                                 |
  +--------------+---------------------------------------+
  | account      | AUTH_eac679e489614xxxxxxce29d755fe289 |
  | bytes_used   | 27                                    |
  | container    | access_1                              |
  | object_count | 1                                     |
  | read_acl     | *:11d1cb41f05140ebadxxxxxx9a67a2d7    |
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
  | account      | AUTH_eac679e489614xxxxxxce29d755fe289 |
  | bytes_used   | 27                                    |
  | container    | access_1                              |
  | object_count | 1                                     |
  +--------------+---------------------------------------+

We can also confirm that our second restricted user still has no access to the
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

The ``READ ACL`` does not give the user rights to create or delete
objects in a container, they can only view the contents. In order to perform
create or delete actions, the user will need to be included in the
``WRITE ACL``.

First let's repeat the process we used earlier to add the read access rule, and
instead add a write access rule for our restricted-user-2.

.. code-block:: bash

  # as clouduser

  $ swift post access_1 --write-acl "*:9298ecab1c90450abexxxxxx0e4136ce"

  $ openstack container show access_1
  +--------------+---------------------------------------+
  | Field        | Value                                 |
  +--------------+---------------------------------------+
  | account      | AUTH_eac679e489614xxxxxxce29d755fe289 |
  | bytes_used   | 27                                    |
  | container    | access_1                              |
  | object_count | 1                                     |
  | read_acl     | *:11d1cb41f05140ebadxxxxxx9a67a2d7    |
  | write_acl    | *:9298ecab1c90450abexxxxxx0e4136ce    |
  +--------------+---------------------------------------+


Now we can upload a test file to the container to confirm that the rule is
correct.

.. code-block:: bash

  # as restricted-user-2

  $ openstack object create access_1 bar.txt
  +---------+-----------+----------------------------------+
  | object  | container | etag                             |
  +---------+-----------+----------------------------------+
  | bar.txt | access_1  | fa2337fd140c5746fxxxxxxa80fa1510 |
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
following example shows that we can remove any content in the container, even
if it was not created by the current user.

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

***************
Link References
***************

.. target-notes::

.. _`Email Sub-addressing`: https://en.wikipedia.org/wiki/Email_address#Sub-addressing

