.. raw:: html

    <h3> Requirements </h3>

Before we can begin sending commands through the swift API we need to prepare
some environment variables for use. Sourcing an openRC file will take care of
most of the required environment variables, however we need to gather some
information to set the last few.

First need to set a storageURL for ourselves. We do this by grabbing the correct
Auth API from :ref:`this section<apis>` of the documentation. For our example we
will use the Porirua region's API:
``https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_``

Next we need to find our project ID. We can do this by using the following
command:

.. code-block:: bash

  $ openstack project show <name of the project you sourced your OpenRC with>
  +-------------+----------------------------------+
  | Field       | Value                            |
  +-------------+----------------------------------+
  | description |                                  |
  | domain_id   | default                          |
  | enabled     | True                             |
  | id          | 1xxxxxxxxxxxxxxxxxxxxxxxxxxxxe54 |
  | tags        | []                               |
  +-------------+----------------------------------+

We then take the ID that we find from this output and we combine it with
the Auth API from the region we want to operate in; exporting this
environment variable as "*OS_STORAGE_URL*" like so:

.. code-block:: bash

    $ export OS_STORAGE_URL="https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_1xxxxxxxxxxxxxxxxxxxxxxxxxxxxe54"

After we have set our storage URL, we need to find the name of the policy we
want our container to have. For this example we will use the wellington single
region policy:

.. code-block:: bash

    # Find the name of the policy you wish to use
    $ swift capabilities | grep policies

    policies: [{'default': True, 'name': 'nz--o1--mr-r3', 'aliases': 'nz--o1--mr-r3'}, \
    {'name': 'nz-por-1--o1--sr-r3', 'aliases': 'nz-por-1--o1--sr-r3'}, \
    {'name': 'nz-hlz-1--o1--sr-r3', 'aliases': 'nz-hlz-1--o1--sr-r3'}, \
    {'name': 'nz-wlg-2--o1--sr-r3', 'aliases': 'nz-wlg-2--o1--sr-r3'}]

    # If you are using an username and password to authenticate instead of a
    # token you will need to export an "OS_AUTH_TOKEN" for our later use.
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

    # Once we have the policy we need (and an Auth Token if you don't have one)
    # We export them for use later.

    $ export OS_AUTH_TOKEN="gAAAAABdwJ5KkgWpKIHN_4xaFxkqPpvivOO2Qc4kavx832WC3GNws74icYXvzGUQy7eHxkSgbSpbPzj-j2PikiY6KmbwaqFdlStRSUXbmW0ZR6edoKzw8fDy7FXedR1kWR-j83HQfICzw802Z1zbnZw1Tho7F6vDVo5OEyQw6ORQTSINl6diBD4"
    $ export policy="nz-wlg-2--o1--sr-r3"

.. raw:: html

    <h3> Creating our container </h3>

To create a container with a non-default policy we have to specify which
policy we want to use in a curl command. In this example we are goint to create
a container called "cont-pol"

.. Note::

    Make sure that you end the storage url with "/name-of-the-container" otherwise the API will not know what
    container you a referring to when you try to define it's storage policy.

.. code-block:: bash

    $ curl -v -X PUT -H "X-Auth-Token: $OS_AUTH_TOKEN" -H "X-Storage-Policy: $policy" $OS_STORAGE_URL/cont-pol

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

    $ curl -v -X PUT -T file1.txt -H "X-Auth-Token: $OS_AUTH_TOKEN" $OS_STORAGE_URL/cont-pol/file1.txt*

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
    < Etag: d41d8cd98f00b204xxxxxx98ecf8427e
    < X-Trans-Id: tx9c1ea1c7bd9d4c668be3f-005dd4a391
    <
    * Connection #0 to host object-storage.nz-wlg-2.catalystcloud.io left intact

Finally we check our containers and what rules they have applied to them to
confirm our new container is using the correct policy.

.. code-block:: bash

    # The thing to look out for here is that the "X-Account-Storage-Policy"
    # contains the data size of our file. This examples uses the wellington replication policy.

    $ curl -i -X GET -H "X-Auth-Token: $OS_AUTH_TOKEN" $OS_STORAGE_URL

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
