The following is a list of the most commonly used commands that will help you
interact with the object storage service via the OpenStack command line.

|

To view the current containers on your project, you can use the ``openstack
container list`` command:

.. code-block:: bash

    $ openstack container list
    mycontainer-1
    mycontainer-2

|

To view the objects stored within a container:
``openstack object list <container_name>``

.. code-block:: bash

    $ openstack object list mycontainer-1
    +-------------+
    | Name        |
    +-------------+
    | file-1.txt  |
    | image-1.png |
    +-------------+

|

To create a new container: ``openstack container create <container_name>``

.. code-block:: bash

    $ openstack container create mynewcontainer

    +---------+----------------+----------------------------------------------------+
    | account | container      | x-trans-id                                         |
    +---------+----------------+----------------------------------------------------+
    | v1      | mynewcontainer | tx000000000000000146531-0057bb8fc9-2836950-default |
    +---------+----------------+----------------------------------------------------+

|

To add a new object to a container:
``openstack object create <container_name> <file_name>``

.. code-block:: bash

    $ openstack object create mynewcontainer hello.txt

    +-----------+----------------+----------------------------------+
    | object    | container      | etag                             |
    +-----------+----------------+----------------------------------+
    | hello.txt | mynewcontainer | d41d8cd98f00b204xxxxxx98ecf8427e |
    +-----------+----------------+----------------------------------+

|

To delete an object from a container: ``openstack object delete <container> <object>``

.. code-block:: bash

    $ openstack object delete mynewcontainer hello.txt

|

To delete a container: ``openstack container delete <container>``

.. note::

  this will only work if the container does not contain any objects.

.. code-block:: bash

    $ openstack container delete mycontainer-1

|

To delete a container and all of the objects within the container:
``openstack container delete --recursive <container>``

.. code-block:: bash

  $ openstack container delete --recursive mycontainer-1
