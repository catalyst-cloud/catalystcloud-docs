##################
Replication policy
##################

Any container you make through our object storage service has a default
replication policy applied to it. This policy ensures that each container has
three replicas, one held on each region of the Catalyst Cloud.

However, there are some scenarios where you may not need your data to be
replicated across regions and you therefore wish to change this policy. Instead
you can choose to have three replicas on a single region.
This approach can save money, however it is less geographically diverse
and therefore not as safe as the default policy.

Storage policies
================

The following storage classes exist on the Catalyst Cloud:

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

The storage class of a container is not yet visible nor configurable via the
Catalyst dashboard. However you are still able to change the policy via the
use of the command line tools.

.. Note::
 Before continuing please ensure that you have sourced an OpenRC file for your
 project and that you have the Swift command line tools installed.

Before we create our new container, we need to find out the storage URL and
Auth token so that we can curl the object storage api. After we have these, we
are going to create a container with the new single region policy applied to
it.

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

    # To create a container with a non-default policy we have to specify our
    # policy when we use the curl command.
    # Make sure that you end the storage url with  "/name of the container"

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

    <
    * Connection #0 to host object-storage.nz-wlg-2.catalystcloud.io left intact

Next we are going to put a file in our new container. You can either create a
file and upload it or you can upload an existing file from your working
directory.

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


