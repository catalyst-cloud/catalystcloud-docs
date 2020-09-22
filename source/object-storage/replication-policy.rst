##################
Replication Policy
##################

When you create a container through the use of our object storage service, that
container will have a replication policy applied to it. The default policy
ensures that the container is replicated across all three regions of
the Catalyst Cloud. This is done as a means to provide geographic diversity and
security to your data in the event of a disaster affecting one of our regions.

However, there are some scenarios where you may not need your data to be
replicated across regions or you wish to save money on a cheaper policy. In
this case you can choose a replication policy that keeps three replicas of your
data in a single region instead of having them spread across all of them.

*****************************
What are the storage policies
*****************************

The following are the storage policies available, each of these (as their names
suggest) are related to one of the regions on the Catalyst cloud:

+--------------------------+------------------+------------------------+
| Storage class            | Failure-domain   | Replicas               |
+==========================+==================+========================+
| nz--o1--mr-r3 (default)  | Multi-region     | 3 (one in each region) |
+--------------------------+------------------+------------------------+
| nz-wlg-2--o1--sr-r3      | Single-region    | 3 (all in one region)  |
+--------------------------+------------------+------------------------+
| nz-por-1--o1--sr-r3      | Single-region    | 3 (all in one region)  |
+--------------------------+------------------+------------------------+
| nz-hlz-1--o1--sr-r3      | Single-region    | 3 (all in one region)  |
+--------------------------+------------------+------------------------+

.. Warning::
  You cannot change the storage policy of an already existing container. The
  only way to change the policy of a container is during it's creation.

There are multiple ways to create containers that use a single region policy.
You can create your container via the Dashboard or through the use of the
command line, making use of the openstack CLI or by making calls to the object
storage API directly. All of which are detailed below.

****************
Dashboard method
****************

It is now a required field when creating a container, to choose a replication
policy. The following will go through the process of creating a new container
via the dashboard and show you how to choose your replication policy.
Firstly, navigate to the 'containers' section under the object storage tab.

.. image:: assets/container-dash-screenshot-underline.png

Once here, we're going to make a new container by clicking on the "+ container"
button. The button will open up a new window that should look like this:

.. image:: assets/create-container.png

We'll give our container a name and in the storage policy tab below, we select
the region that we want our replicas to be created in. As you can see, by
default the multi-region option is selected, but for this example we'll choose
policy for the Porirua region and then click submit. Something important to
mention is even though the policy we have chosen uses the Porirua region for
storing the replicas, you are still able to access this container from any of
our regions.

.. image:: assets/create-container-dropdown.png

After you've created your container, it will function as normal. You should be
able to see the policy that your container has when selecting it from the
dashboard as seen below

.. image:: assets/container-after-create.png

********************
Programmatic methods
********************

.. tabs::

  .. tab:: Openstack CLI

    The following is a tutorial that will show you how to create a container that
    has a single region replication policy, using the openstack command line tools.
    There are a number of prerequisites you will need to meet before we can
    continue with this tutorial:

    - You must have version 5.2.0 or above of the openstack command line tools installed.
    - You need to have sourced an OpenRC file in your console.

    Once you have met these requirements we can create our container. For this
    container we are going to be using the Hamilton region. This means that when
    we use the command ``openstack container create`` we need to specify our
    policy with the ``--storage-policy`` flag.

    .. Note::
      Even if a container only uses a single region for it's replication policy,
      you are still able to access the container from any region on the Catalyst
      Cloud.

    .. code-block:: bash

       $ openstack container create --storage-policy nz-hlz-1--o1--sr-r3 single-region-cli
       +---------------------------------------+-------------------+------------------------------------+
       | account                               | container         | x-trans-id                         |
       +---------------------------------------+-------------------+------------------------------------+
       | AUTH_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx | single-region-cli | tx4e6c8d8ec77248279a74a-005e94d751 |
       +---------------------------------------+-------------------+------------------------------------+

    That is it. We have created a container with the single region policy. We can
    see this if we use the following command:

    .. code-block:: bash

       $ openstack container show single-region-cli
       +----------------+---------------------------------------+
       | Field          | Value                                 |
       +----------------+---------------------------------------+
       | account        | AUTH_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |
       | bytes_used     | 0                                     |
       | container      | single-region-cli                     |
       | object_count   | 0                                     |
       | storage_policy | nz-hlz-1--o1--sr-r3                  |
       +----------------+---------------------------------------+


  .. tab:: API method

    .. Note::
      Like the command line method, we are going to need to have a valid OpenRC file
      sourced for this tutorial. However, you must use an RC file that does not use
      MFA, otherwise you will not be able to communicate with the swift API
      correctly. Additionally, you will also need to have the python swiftclient
      installed.

    Because we are using the swift API's themselves instead of the openstack
    command line, we will need to find out our storage URL and Auth token. These
    will allow us to 'curl' the object storage API. After we have
    both of these, we can construct a curl command to create our new single
    region container. In this example we will use the Wellington region.

    .. code-block:: bash

        # Find the name of the policy you wish to use
        $ swift capabilities | grep policies

        policies: [{'default': True, 'name': 'nz--o1--mr-r3', 'aliases': 'nz--o1--mr-r3'}, \
        {'name': 'nz-por-1--o1--sr-r3', 'aliases': 'nz-por-1--o1--sr-r3'}, \
        {'name': 'nz-hlz-1--o1--sr-r3', 'aliases': 'nz-hlz-1--o1--sr-r3'}, \
        {'name': 'nz-wlg-2--o1--sr-r3', 'aliases': 'nz-wlg-2--o1--sr-r3'}]

        # Find the storageURL and Auth Token you need to access your object storage
        $ swift stat -v
                            StorageURL: https://object-storage.ostst.wgtn.cat-it.co.nz:443/v1/AUTH_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                            Auth Token: gAAAAABdwJ5KkgWpKIHN_4xaFxkqPpvivOO2Qc4kavx832WC3GNws74icYXvzGUQy7eHxkSgbSpbPzj-j2PikiY6KmbwaqFdlStRSUXbmW0ZR6edoKzw8fDy7FXedR1kWR-j83HQfICzw802Z1zbnZw1Tho7F6vDVo5OEyQw6ORQTSINl6diBD4
                               Account: AUTH_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                            Containers: 2
                               Objects: 2
                                 Bytes: 97359
       Containers in policy "o1-mr-r3": 2
          Objects in policy "o1-mr-r3": 2
            Bytes in policy "o1-mr-r3": 97359
                                Server: nginx/1.14.2
                          Content-Type: text/plain; charset=utf-8
                           X-Timestamp: 1530350012.25515
                         Accept-Ranges: bytes
           X-Account-Project-Domain-Id: default
                            X-Trans-Id: tx5deb854e32d94eec8c658-005dd47fc0

        # Once we have the storageURL, the token and the policy we need.
        # We export them for use in our curl command.

        $ export storageURL="https://object-storage.ostst.wgtn.cat-it.co.nz:443/v1/AUTH_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        $ export token="gAAAAABdwJ5KkgWpKIHN_4xaFxkqPpvivOO2Qc4kavx832WC3GNws74icYXvzGUQy7eHxkSgbSpbPzj-j2PikiY6KmbwaqFdlStRSUXbmW0ZR6edoKzw8fDy7FXedR1kWR-j83HQfICzw802Z1zbnZw1Tho7F6vDVo5OEyQw6ORQTSINl6diBD4"
        $ export policy="nz-wlg-2--o1--sr-r3"

    To create a container with a non-default policy we have to specify which
    policy we want to use in our curl command. Make sure that you end the storage
    url with "/name-of-the-container" otherwise the API will not know what
    container you a referring to when you try to define it's storage policy.
    In this example we are creating a container called "cont-pol"

    .. code-block:: bash

        $ curl -v -X PUT -H "X-Auth-Token: $token" -H "X-Storage-Policy: $policy" $storageURL/cont-pol

        *   Trying 202.78.240.219...
        > PUT /v1/AUTH_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/cont-pol HTTP/1.1
        > Host: object-storage.nz-wlg-2.catalystcloud.io
        > User-Agent: curl/7.58.0
        > Accept: */*
        > X-Auth-Token: gAAAAABd1H-_eoC2zXlZXVXRZs7CWem8bXqo-705zhux-GGcT2ZR6M6lyKDzvWC3mAf4XFWC9qN-hdrYvD4NJFwJmp5fug3L8u5G8EbVUxMhzNZMLQdOOAGuRAyTGmIdqD_Ax1hgQF8svBbF4nU6lbYKdFawzu4SyXqg_UBWhNxqHBzLENpASu8
        > X-Storage-Policy: nz-wlg-2--o1--sr-r3
        >
        < HTTP/1.1 201 Created
        < Server: nginx/1.16.0
        < Date: Thu, 21 Nov 2019 23:45:23 GMT
        < Content-Type: text/html; charset=UTF-8
        < Content-Length: 0
        < X-Trans-Id: tx77ee63a2009c4dbc863c8-005dd72193

        <.. code-block:: bash
        * Connection #0 to host object-storage.nz-wlg-2.catalystcloud.io left intact

    Next we are going to put a file in our new container. You can either create a
    file and upload it or you can upload an existing file from your working
    directory; in our case we will use a file called "file1.txt"

    .. code-block:: bash

        curl -v -X PUT -T file1.txt -H "X-Auth-Token: $token" $storageURL/cont-pol/file1.txt*

        Trying 202.78.240.219...
        > PUT /v1/AUTH_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/cont-pol/file1.txt HTTP/1.1
        > Host: object-storage.nz-wlg-2.catalystcloud.io
        > User-Agent: curl/7.58.0
        > Accept: */*
        > X-Auth-Token: gAAAAABd1H-_eoC2zXlZXVXRZs7CWem8bXqo-705zhux-GGcT2ZR6M6lyKDzvWC3mAf4XFWC9qN-hdrYvD4NJFwJmp5fug3L8u5G8EbVUxMhzNZMLQdOOAGuRAyTGmIdqD_Ax1hgQF8svBbF4nU6lbYKdFawzu4SyXqg_UBWhNxqHBzLENpASu8
        > Content-Length: 0
        >
        < HTTP/1.1 201 Created
        < Server: nginx/1.16.0
        < Date: Wed, 20 Nov 2019 02:23:13 GMT
        < Content-Type: text/html; charset=UTF-8
        < Content-Length: 0
        < Last-Modified: Wed, 20 Nov 2019 02:23:14 GMT
        < Etag: d41d8cd98f00b204e9800998ecf8427e
        < X-Trans-Id: tx9c1ea1c7bd9d4c668be3f-005dd4a391
        <
        * Connection #0 to host object-storage.nz-wlg-2.catalystcloud.io left intact

    Finally we check our containers and what rules they have applied to them to
    confirm our new container is using the correct policy.

    .. code-block:: bash

        # The thing to look out for here is that the "X-Account-Storage-Policy"
        # contains the data size of our file. This examples uses the wellington replication policy.

        $ curl -i -X GET -H "X-Auth-Token: $token" $storageURL

        HTTP/1.1 200 OK
        Server: nginx/1.14.2
        Date: Thu, 21 Nov 2019 22:26:17 GMT
        Content-Type: text/plain; charset=utf-8
        Content-Length: 9
        X-Account-Storage-Policy-Nz-Wlg-2--O1--Sr-R3-Container-Count: 1
        X-Account-Object-Count: 1
        X-Account-Storage-Policy-Nz-Wlg-2--O1--Sr-R3-Object-Count: 1
        X-Account-Storage-Policy-Nz--O1--Mr-R3-Bytes-Used: 0
        X-Account-Storage-Policy-Nz--O1--Mr-R3-Container-Count: 0
        X-Timestamp: 1530350012.25515
        X-Account-Storage-Policy-Nz--O1--Mr-R3-Object-Count: 0
        X-Account-Storage-Policy-Nz-Wlg-2--O1--Sr-R3-Bytes-Used: 40356
        X-Account-Bytes-Used: 40356
        X-Account-Container-Count: 1
        Accept-Ranges: bytes
        x-account-project-domain-id: default
        X-Trans-Id: txbd66d690a27f41fbbd44c-005dd70f09

        cont-pol


