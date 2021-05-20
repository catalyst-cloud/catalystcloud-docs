##################################
Using containers
##################################

There are several different methods available to you for interacting with the
object storage service. The following sections cover the most common tools that
people use. Each of these examples shows some of the basic commands that you
can use to create and edit your object storage containers.

*****************
Via the dashboard
*****************

When using the object storage service, your data must be stored in a container
(also referred to as a bucket.) So our first step is to create at least one
container prior to uploading any data. To create a new container, navigate to
the "Containers" section on the dashboard and click "Create Container".

.. image:: assets/containers_ui.png
   :align: center

Provide a name for the container and select the appropriate access level and
click "Create".

.. note::

  Setting "Public" level access on a container means that anyone
  with the container's URL can access the contents of that container.

.. image:: assets/create_container.png
  :align: center

You should now see the newly created container. As this is a new container, it
currently does not contain any data. Click on the upload button next to
"Folder" to add some content.

.. image:: assets/new_container.png
   :align: center

Click on the "Browse" button to select the file you wish to upload and once
selected click "Upload File".

.. image:: assets/doing_upload.png
   :align: center

In the containers view the Object Count has gone up to one and the size of
the container is now 5 Bytes.

.. image:: assets/uploaded_file.png
   :align: center

************************
Via programmatic methods
************************

Prerequisites
=============

For several of the methods detailed below, you will have to prepare your
command line environment before continuing with the examples. The key things
that you have to prepare before continuing are:

* You must :ref:`Source an OpenRC file <command-line-interface>`.
* You must ensure that you have the correct role for using object storage on
  your cloud project. See :ref:`here<access_control>` for more details.

Once you have met these requirements, you can continue with whichever
method you choose:

|

.. _s3-api-documentation:

.. tabs::

    .. tab:: Openstack CLI

        The following is a list of the most commonly used commands that will help you
        interact with the object storage service via the openstack command line.

        |

        To view the containers currently in existence in your project:

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

        To delete an object: ``openstack object delete <container> <object>``

        .. code-block:: bash

            $ openstack object delete mynewcontainer hello.txt

        |

        To delete a container: ``openstack container delete <container>``

        .. note::

          this will only work if the container is empty.

        .. code-block:: bash

            $ openstack container delete mycontainer-1

        |

        To delete a container and all of the objects within the container:
        ``openstack container delete --recursive <container>``

        .. code-block:: bash

          $ openstack container delete --recursive mycontainer-1

    .. tab:: Swift API

        For this section of the documentation, we will cover the basic features of
        using the Swift object storage API. For a more in depth understanding of the
        features that are offered via this API we recommend reading through the
        official `OpenStack documentation
        <http://developer.openstack.org/api-ref/object-storage/>`_

        .. raw:: html

            <h3> API endpoints </h3>

        +----------+---------+--------------------------------------------------------------------------+
        | Region   | Version | Endpoint                                                                 |
        +==========+=========+==========================================================================+
        | nz-por-1 | 1       | https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_%tenantid%  |
        +----------+---------+--------------------------------------------------------------------------+
        |          | 2       | https://api.nz-por-1.catalystcloud.io:5000/v2.0                          |
        +----------+---------+--------------------------------------------------------------------------+
        | nz_wlg_2 | 1       | https://object-storage.nz-wlg-2.catalystcloud.io:443/v1/AUTH_%tenantid%  |
        +----------+---------+--------------------------------------------------------------------------+
        |          | 2       | https://api.cloud.catalyst.net.nz:5000/v2.0                              |
        +----------+---------+--------------------------------------------------------------------------+
        | nz-hlz-1 | 1       | https://object-storage.nz-hlz-1.catalystcloud.io:443/v1/AUTH_%tenantid%  |
        +----------+---------+--------------------------------------------------------------------------+
        |          | 2       | https://api.nz-hlz-1.catalystcloud.io:5000/v2.0                          |
        +----------+---------+--------------------------------------------------------------------------+

        .. raw:: html

            <h3> Requirements </h4>

            <h4> Sourcing the correct environment variables </h5>

        Like the the other methods in this tutorial section, you will need to source an
        openRC file to interact with your object storage container. However, the openRC
        file we normally use to source our environment variables will not work with
        this example. This is because the swift API does not use token
        authentication, it only allows for username and password authentication.

        Because of this, we have created the following file that you can save
        as a ``.sh`` and use to source your environment variables the same as
        you would with a normal RC file. Some of the
        variables in this file are placeholders and you will have to change them
        to match the specifications for your project. Once this is done you
        should be able to source the file the same as any other openRC file:

        .. literalinclude:: assets/old-rc-file-format.sh
          :language: shell

        .. raw:: html

          <h4> Installing the correct tools</h4>

        After this file is edited and sourced, you will also need to install the
        standard client library for swift, which in this case is
        the Python Swiftclient. This can be added to your current Python environment;
        the example below illustrates how:

        .. code-block:: bash

          # Make sure you have pip and virtualenv installed
          sudo apt-get install python-pip python-virtualenv

          # Create a new virtual environment for Python and activate it
          virtualenv venv
          source venv/bin/activate

          # Install Python Swiftclient library on your virtual environment
          pip install python-swiftclient

        .. raw:: html

            <h3> Sample code </h3>

        The code below demonstrates how you can use the Python-Swiftclient to interact
        with swift via the version 2 compatible (auth) API. This version uses
        the same endpoint for all regions, but you have to specify which one you want
        to use when connecting.

        The code block will use the environment variables sourced from your openrc
        file to:

        1) create a container on your project
        2) add a file to the container
        3) list all of your containers and their contents.

        To use this file, save it as a '.py' and run it from your command line.


        .. code-block:: python

          #!/usr/bin/env python
          import os
          import swiftclient

          # Read configuration from environment variables (openstack.rc)
          auth_username = os.environ['OS_USERNAME']
          auth_password = os.environ['OS_PASSWORD']
          auth_url = os.environ['OS_AUTH_URL']
          project_name = os.environ['OS_PROJECT_NAME']
          region_name = os.environ['OS_REGION_NAME']
          options = {'tenant_name': project_name, 'region_name': region_name}

          # Establish the connection with the object storage API
          conn = swiftclient.Connection(
                  authurl = auth_url,
                  user = auth_username,
                  key = auth_password,
                  insecure = False,
                  os_options = options,
                  auth_version = '3'
          )

          # Create a new container
          container_name = 'mycontainer'
          conn.put_container(container_name)


          # Put an object in it
          conn.put_object(container_name, 'hello.txt',
                          contents='Hello World!',
                          content_type='text/plain')

          # List all containers and objects
          for container in conn.get_account()[1]:
              cname = container['name']
              print ("container\t{0}".format(cname))
              for data in conn.get_container(cname)[1]:
                  print ('\t{0}\t{1}\t{2}'.format(data['name'], data['bytes'], data['last_modified']))


        To use the version 1 (auth) API you need to have previously authenticated,
        and have remembered your token id (e.g using the keystone client). Also the
        endpoint for the desired region must be used (por in this case). ::

          https://object-storage.nz-por-1.catalystcloud.io:443/swift/v1/auth_tenant_id/container_name/object_name

        .. code-block:: python

          #!/usr/bin/env python
          import swiftclient
          token = 'thetokenid'
          stourl = 'https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_<tenant_id>'

          conn = swiftclient.Connection(
                  preauthtoken = token,
                  preauthurl = stourl,
                  insecure = False,
                  auth_version = 1,
          )

          # ...rest of program is unchanged

    .. tab:: S3 API


        The Swift object storage service has an Amazon S3 emulation layer that supports
        common S3 calls and operations.

        .. seealso::

          Swift3 middleware emulates the S3 REST API on top of OpenStack. Swift is
          documented fully `here
          <http://docs.openstack.org/mitaka/config-reference/object-storage/configure-s3.html>`_.

        .. raw:: html

            <h4> API endpoints </h4>

        +----------+------------------------------------------------------+
        | Region   | Endpoint                                             |
        +==========+======================================================+
        | nz-por-1 | https://object-storage.nz-por-1.catalystcloud.io:443 |
        +----------+------------------------------------------------------+
        | nz_wlg_2 | https://object-storage.nz-wlg-2.catalystcloud.io:443 |
        +----------+------------------------------------------------------+
        | nz-hlz-1 | https://object-storage.nz-hlz-1.catalystcloud.io:443 |
        +----------+------------------------------------------------------+

        .. raw:: html

            <h4> Requirements </h4>

        You need valid EC2 credentials in order to interact with the S3 compatible API.
        You can obtain your EC2 credentials from the dashboard (under Access &
        Security, API Access), or using the command line tools:

        .. code-block:: bash

          $ openstack ec2 credentials create

        If you are using boto to interact with the API, you need boto installed on your
        current Python environment. The example below illustrates how to install boto
        on a virtual environment:

        .. code-block:: bash

          # Make sure you have pip and virtualenv installed
          sudo apt-get install python-pip python-virtualenv

          # Create a new virtual environment for Python and activate it
          virtualenv venv
          source venv/bin/activate

          # Install Amazon's boto library on your virtual environment
          pip install boto

        .. raw:: html

            <h4> Sample code </h4>


        The code below demonstrates how you can use boto to interact with the S3
        compatible API.

        .. code-block:: python

          #!/usr/bin/env python

          import boto
          import boto.s3.connection

          access_key = 'fffff8888fffff888ffff'
          secret = 'bbbb5555bbbb5555bbbb555'
          api_endpoint = 'object-storage.nz-por-1.catalystcloud.io'
          port = 443
          mybucket = 'mytestbucket'

          conn = boto.connect_s3(aws_access_key_id=access_key,
                            aws_secret_access_key=secret,
                            host=api_endpoint, port=port,
                            calling_format=boto.s3.connection.OrdinaryCallingFormat())

          # Create new bucket if not already existing
          bucket = conn.lookup(mybucket)
          if bucket is None:
              bucket = conn.create_bucket(mybucket)

          # Store hello world file in it
          key = bucket.new_key('hello.txt')
          key.set_contents_from_string('Hello World!')

          # List all files in test bucket
          for key in bucket.list():
              print (key.name)

          # List all buckets
          for bucket in conn.get_all_buckets():
              print ("{name}\t{created}".format(
                  name = bucket.name,
                  created = bucket.creation_date,
              ))

    .. tab:: cURL

        To access object storage using cURL it is necessary to provide credentials
        to authenticate any requests you make.

        This can be done by sourcing your OpenRC file and retrieving your account specific details via the
        Swift command line tools; then exporting the required variables as shown below.

        .. Note::

           You will need to use an openRC file that does NOT use MFA, otherwise
           the swift API will not be able to interact with your requests correctly.

        .. code-block:: bash

            $ source openstack-openrc.sh

            $ swift stat -v
             StorageURL: https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                              Auth Token: 5f5a043e1bd24a8fa8xxxxxxcca8e0fc
                              Containers: 48
                                 Account: AUTH_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                                 Objects: 156
                                   Bytes: 11293750551
         Containers in policy "policy-0": 48
            Objects in policy "policy-0": 156
              Bytes in policy "policy-0": 11293750551
             X-Account-Project-Domain-Id: default
                                  Server: nginx/1.8.1
                             X-Timestamp: 1466047859.45584
                              X-Trans-Id: tx4bdb5d859f8c47f18b44d-00578c0e63
                            Content-Type: text/plain; charset=utf-8
                           Accept-Ranges: bytes

            $ export storageURL="https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
            $ export token="5f5a043e1bd24a8fa8xxxxxxcca8e0fc"

        To create a new container, use the following cURL request:

        .. code-block:: bash

            curl -i -X PUT -H "X-Auth-Token: $token" $storageURL/mycontainer

        Then run the following command to get a list of all available containers for
        your project:

        .. code-block:: bash

            curl -i -X GET -H "X-Auth-Token: $token" $storageURL

        You can optionally specify alternative output formats. For example: to have XML
        or JSON returned use the following syntax:

        .. code-block:: bash

            curl -i -X GET -H "X-Auth-Token: $token" $storageURL?format=xml
            curl -i -X GET -H "X-Auth-Token: $token" $storageURL?format=json

        To view the objects within a container, simply append the container name to
        the cURL request:

        .. code-block:: bash

            curl -i -X GET -H "X-Auth-Token: $token" $storageURL/mycontainer

        To upload a file to your container, use the following cURL format:

        .. code-block:: bash

            curl -i -T <my_object> -X PUT -H "X-Auth-Token: $token" $storageURL/mycontainer

        To delete a file from your container, use this code:

        .. code-block:: bash

           curl -X DELETE -H "X-Auth-Token: <token>" <storage url>/mycontainer/myobject

        Finally, to delete a container you can use the following syntax.

        .. Note::

           A container must be empty before you try and delete it. Otherwise the
           operation will fail.

        .. code-block:: bash

            curl -X DELETE -H "X-Auth-Token: <token>" <storage url>/mycontainer

    .. tab:: Heat Orchestration

        Using Heat you are able to manage a large number of resources by utilising a
        stack that will construct and monitor your objects. You can create a stack by using a pre-designed template.
        The following example assumes that you have some knowledge of Heat and how to use these
        template files.

        The following code snippet contains the minimum required components to construct
        an object storage container using Heat:

        .. code-block:: bash

            heat_template_version: 2015-04-30

            description: >
                Creating a swift container using HEAT

            resources:

              swift_container:
                type: OS::Swift::Container
                properties:
                  PurgeOnDelete: FALSE
                  name: heat-container

        For more information on object storage containers and what
        customization options you can select for them, please see the
        `Openstack Heat`_  documentation.

        .. _Openstack Heat: https://docs.openstack.org/heat/latest/template_guide/openstack.html#OS::Swift::Container

        Once you have your template constructed, you should make sure to validate
        it before creating any resources. You can do this by running the following code:

        .. code-block:: bash

            $ openstack orchestration template validate -t <your-template-name>

        If your template is constructed correctly then the output of this code
        should print out a copy of your template. If there is an error inside your template
        then you will be notified of the error in the output.

        Once you have ensured your template is valid, you can construct your
        stack:

        .. code-block:: bash

            $ openstack stack create -t <template> <stack-name>

        The ``stack_status`` indicates that creation is in progress. Use the
        ``event list`` command to check on the stack's orchestration progress:

        .. code-block:: bash

            $ openstack stack event list <stack-name>
            2020-11-09 22:53:56Z [container-stack]: CREATE_IN_PROGRESS  Stack CREATE started
            2020-11-09 22:53:57Z [container-stack.swift_container]: CREATE_IN_PROGRESS  state changed
            2020-11-09 22:54:01Z [container-stack.swift_container]: CREATE_COMPLETE  state changed
            2020-11-09 22:54:01Z [container-stack]: CREATE_COMPLETE  Stack CREATE completed successfully


        Once your status has reached CREATE_COMPLETE you should be able to see
        the resources on your project.

    .. tab:: Terraform

        This tutorial assumes that you have some experience with `Terraform`_
        and that you have an understanding of how Terraform scripts are written
        and how they function. We also assume that you have installed all of the
        prerequisites to run Terraform scripts.

        .. _Terraform: https://www.terraform.io/

        Below is an example template that contains the basic information required
        for Terraform to create an object storage container on the cloud. You can
        view the full list of customization options for this resource on the `Terraform documentation`_

        .. _Terraform documentation: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/objectstorage_container_v1

        .. code-block:: bash

            provider "openstack" {
            }
            resource "openstack_objectstorage_container_v1" "container_1" {
              name   = "tf-test-container-1"
              metadata = {
                test = "true"
              }
              content_type = "application/json"
            }

        Once you have saved this script you need to switch to the correct directory
        and run the following commands to create your new object storage container.
        The first command will outline what resources are going to be made and
        managed by Terraform and what their outputs will be:

        .. code-block:: bash

            $ terraform plan
              Refreshing Terraform state in-memory prior to plan...
              The refreshed state will be used to calculate this plan, but will not be
              persisted to local or remote state storage.
              ------------------------------------------------------------------------
              An execution plan has been generated and is shown below.
              Resource actions are indicated with the following symbols:
                + create

              Terraform will perform the following actions:

                # openstack_objectstorage_container_v1.container_1 will be created
                + resource "openstack_objectstorage_container_v1" "container_1" {
                    + content_type  = "application/json"
                    + force_destroy = false
                    + id            = (known after apply)
                    + metadata      = {
                        + "test" = "true"
                      }
                    + name          = "tf-test-container-1"
                    + region        = (known after apply)
                  }

              Plan: 1 to add, 0 to change, 0 to destroy.
              ------------------------------------------------------------------------
              Note: You didn't specify an "-out" parameter to save this plan, so Terraform
              can't guarantee that exactly these actions will be performed if
              "terraform apply" is subsequently run.

        After you review the Terraform plan and ensure that it has all the
        resources you want to be created, you can use the following code to
        create your new resources:

        .. code-block:: bash

            $ terraform apply
              ... #truncated for brevity
              Do you want to perform these actions?
              Terraform will perform the actions described above.
              Only 'yes' will be accepted to approve.

              Enter a value: yes

              openstack_objectstorage_container_v1.container_1: Creating...
              openstack_objectstorage_container_v1.container_1: Creation complete after 5s [id=tf-test-container-1]

              Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

        Once you have reached this step, you should have an object storage container created
        and managed by Terraform. If you want to delete this container in the future, as
        well as any other resources created in your plan, you can use the following code to
        delete them:

        .. code-block:: bash

            $ terraform destroy
              ... # truncated for brevity
              Do you really want to destroy all resources?
              Terraform will destroy all your managed infrastructure, as shown above.
              There is no undo. Only 'yes' will be accepted to confirm.

              Enter a value: yes

              openstack_objectstorage_container_v1.container_1: Destroying... [id=tf-test-container-1]
              openstack_objectstorage_container_v1.container_1: Destruction complete after 1s

              Destroy complete! Resources: 1 destroyed.

