##########################################
Object storage with the command line tools
##########################################

****************
Before you begin
****************

Before you begin, ensure that you have installed the correct version of the
tools for your operating system version and have sourced your OpenStack RC file
see :ref:`command-line-interface` for full details.

***************************
Viewing your object storage
***************************

To view the containers currently in existence in your project, use ``openstack
container list``.

.. code-block:: bash

    $ openstack container list
    mycontainer-1
    mycontainer-2

To view the objects stored within a container, use ``openstack object list
<container_name>``.

.. code-block:: bash

    $ openstack object list mycontainer-1
    +-------------+
    | Name        |
    +-------------+
    | file-1.txt  |
    | image-1.png |
    +-------------+

*****************************
Adding to your object storage
*****************************

To create a new container, use ``openstack container create <container_name>``.

.. code-block:: bash

    $ openstack container create mynewcontainer
    +---------+----------------+----------------------------------------------------+
    | account | container      | x-trans-id                                         |
    +---------+----------------+----------------------------------------------------+
    | v1      | mynewcontainer | tx000000000000000146531-0057bb8fc9-2836950-default |
    +---------+----------------+----------------------------------------------------+


To add a new object to a container, use ``openstack object create
<container_name> <local_file_path>``.

.. code-block:: bash

    $ openstack object create mynewcontainer hello.txt
    +-----------+----------------+----------------------------------+
    | object    | container      | etag                             |
    +-----------+----------------+----------------------------------+
    | hello.txt | mynewcontainer | d41d8cd98f00b204e9800998ecf8427e |
    +-----------+----------------+----------------------------------+

*******************************
Downloading from object storage
*******************************

To download an object to your computer, use ``openstack object save <container>
<object>``.

.. code-block:: bash

   $ openstack object save mynewcontainer test.css
   +----------+----------------+----------------------------------+
   | object   | container      | etag                             |
   +----------+----------------+----------------------------------+
   | test.css | mynewcontainer | 3e1e451d6eaaf8682d0cebd7e867920d |
   +----------+----------------+----------------------------------+


To specify a specific path to save the file to, use ``openstack object save
--file <file_path> <container> <object>``.


*********************************
Deleting from your object storage
*********************************

To delete an object, use ``openstack object delete <container> <object>``.

.. code-block:: bash

    $ openstack object delete mynewcontainer hello.txt

To delete a container, use ``openstack container delete <container>``. Keep in
mind this will only work if the container is empty.

.. code-block:: bash

    $ openstack container delete mycontainer-1

However, to delete all of the objects within a container, and then the
container, use ``openstack container delete --recursive <container>``.

.. code-block:: bash

  $ openstack container delete --recursive mycontainer-1
