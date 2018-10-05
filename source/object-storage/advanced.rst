################################
Advanced object storage features
################################

****************************************
Static websites hosted in object storage
****************************************

It is possible to host simple websites that contain only static content from
within a container.

To demonstrate this, we'll be using the `Python OpenStack SDK
<https://docs.openstack.org/openstacksdk/latest/index.html>`_.

First, insure you've :ref:`sourced an RC file <source-rc-file>`. Create a
container:

.. literalinclude:: assets/static-site-container-example.py
   :language: python
   :lines: 7-9

Configure the `read ACL
<https://docs.openstack.org/swift/latest/overview_acl.html>`_ to allow read
access and optionally allow files to be listed:

.. literalinclude:: assets/static-site-container-example.py
   :language: python
   :lines: 11-13

Next upload the files you wish to host as a static site:

.. literalinclude:: assets/static-site-container-example.py
   :language: python
   :lines: 44-46

You should now be able to view the files in the container by visiting
the container's URL:

.. literalinclude:: assets/static-site-container-example.py
   :language: python
   :lines: 48-52

.. code-block:: bash

   $ python3 static-site-container-example.py
   https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_8ciuas90998049cbasdas0f023eba693b4/mystaticsite/index.html

Now that you have a URL, you should be able to redirect a domain name to it. By
using domain name masking, you'll be able to hide the long object storage URL in
your visitor's browser, and replace it with your domain name.

*****************
Object Versioning
*****************

This provides a means by which multiple versions of your content can be stored
allowing for recovery from unintended overwrites.

To demonstrate this, we'll be using the `Python OpenStack SDK
<https://docs.openstack.org/openstacksdk/latest/index.html>`_.

First, insure you've :ref:`sourced an RC file <source-rc-file>`. We'll create a
main container, and a container that will act as our archive.

.. literalinclude:: assets/versioning-container-example.py
   :language: python
   :lines: 7-11

Now, set the ``versions_location`` metadata, to point the main container to the
archive container.

.. literalinclude:: assets/versioning-container-example.py
   :language: python
   :lines: 13-15

Now when we upload an object to the main container, a copy will by automatically
transferred to the archive container. As an example, let's upload an object, and
then overwrite the object with a new version.

.. literalinclude:: assets/versioning-container-example.py
   :language: python
   :lines: 17-24

When we print the contents, we can see there's a copy of each revision in the
archive.

.. literalinclude:: assets/versioning-container-example.py
   :language: python
   :lines: 26-37

.. code-block:: bash

   $ python3 versioning-container-example.py
   mycontainer contents:
   Name: test.txt - Hash: ee4ef965d44e9a172cbb49e43b274798

   mycontainer-archive contents:
   Name: 008test.txt/1538706227.70524 - Hash: ee4ef965d44e9a172cbb49e43b274798
   Name: 008test.txt/1538706252.58966 - Hash: cba9567e501f4ab6f6cab74ed81ade69

The backed up version will have the following format:
```<length><object_name>/<timestamp>```

Where ``<length>`` is the length of the object name ( as a three character zero padded
hex number ), ``<object_name>`` is the original object name and ``<timestamp>`` is the
unix timestamp of the original file creation.

``<length>`` and ``<object_name>`` are then combined to make a new container
(pseudo-folder in the dashboard) with the backed up object stored within using
the timestamp as its name.

To demonstrate that the archive is a real backup, we can delete the file in the
main container, and then print the contents of the archive container.

.. literalinclude:: assets/versioning-container-example.py
   :language: python
   :lines: 39-43

As you can see, the contents of the archive container has not changed:

.. code-block:: bash

   mycontainer-archive contents:
   Name: 008test.txt/1538706227.70524 - Hash: ee4ef965d44e9a172cbb49e43b274798
   Name: 008test.txt/1538706252.58966 - Hash: cba9567e501f4ab6f6cab74ed81ade69


*************
Temporary URL
*************

This is a means by which a temporary URL can be generated, to allow
unauthenticated access to the Swift object at the given path. The
access is via the given HTTP method (e.g. GET, PUT) and is valid
for the number of seconds specified when the URL is created.

The expiry time can be expressed as valid for the given number of seconds from
now or if the optional --absolute argument is provided, seconds is instead
interpreted as a Unix timestamp at which the URL should expire.

The syntax for the tempurl creation command is:

**swift tempurl [command-option] method seconds path key**

This generates a temporary URL allowing unauthenticated access to the Swift
object at the given path, using the given HTTP method, for the given number of
seconds, using the given TempURL key. If the optional --absolute argument is
provided, seconds is instead interpreted as a Unix timestamp at which the URL
should expire.

**Example:**

.. code-block:: bash

  swift tempurl GET $(date -d "Jan 1 2017" +%s) /v1/AUTH_foo/bar_container/quux.md my_secret_tempurl_key --absolute

- sets the expiry using the absolute method to be Jan 1 2017
- for the object : quux.md
- in the nested container structure : bar_container/quux.md
- with key : my_secret_tempurl_key

Creating Temporary URLs in the Catalyst Cloud
=============================================

At the time of writing, the only method currently available for the creation
of temporary URLs is using the command line tools.

Firstly you need to associate a secret key with your object store account.

.. code-block:: bash

  $ openstack object store account set --property Temp-Url-Key='testkey'

You can then confirm the details of the key.

.. code-block:: bash

  $ openstack object store account show
  +------------+---------------------------------------+
  | Field      | Value                                 |
  +------------+---------------------------------------+
  | Account    | AUTH_b24e9ee3447e48eab1bc99cb894cac6f |
  | Bytes      | 128                                   |
  | Containers | 4                                     |
  | Objects    | 8                                     |
  | properties | Temp-Url-Key='testkey'                |
  +------------+---------------------------------------+

Then, using the syntax outlined above, you can create a temporary URL to access
an object residing in the object store.

You will create a URL that will be valid for 600 seconds and provide access to
the object "file2.txt" that is located in the container "my-container".

.. code-block:: bash

  $ swift tempurl GET 600 /v1/AUTH_b24e9ee3447e48eab1bc99cb894cac6f/my-container/file2.txt "testkey"
  /v1/AUTH_b24e9ee3447e48eab1bc99cb894cac6f/my-container/file2.txt?temp_url_sig=2dbc1c2335a53d5548dab178d59ece7801e973b4&temp_url_expires=1483990005

You can test this using cURL and appending the generated URL to the Catalyst
Cloud's server URL "https://object-storage.nz-por-1.catalystcloud.io:443". If it is
successful, the request should return the contents of the object.

.. code-block:: bash

  $ curl -i "https://object-storage.nz-por-1.catalystcloud.io:443/v1/AUTH_b24e9ee3447e48eab1bc99cb894cac6f/my-container/file2.txt?temp_url_sig=2dbc1c2335a53d5548dab178d59ece7801e973b4&temp_url_expires=1483990005"
  HTTP/1.1 200 OK
  Server: nginx/1.10.1
  Date: Mon, 09 Jan 2017 19:22:05 GMT
  Content-Type: text/plain
  Content-Length: 501
  Accept-Ranges: bytes
  Last-Modified: Mon, 09 Jan 2017 19:18:47 GMT
  Etag: 137eed1d424a58831892172f5433594a
  X-Timestamp: 1483989526.71129
  Content-Disposition: attachment; filename="file2.txt"; filename*=UTF-8''file2.txt
  X-Trans-Id: tx9aa84268bd984358b6afe-005873e2dd

  "For those who have seen the Earth from space, and for the hundreds and perhaps thousands more who will, the experience most certainly changes your perspective. The things that we share in our world are far more valuable than those which divide us." "For those who have seen the Earth from space, and for the hundreds and perhaps thousands more who will, the experience most certainly changes your perspective. The things that we share in our world are far more valuable than those which divide us."

You could also access the object by taking the same URL that you passed to cURL
and pasting it into a web browser.

**************************
Working with Large Objects
**************************

Typically, the size of a single object cannot exceed 5GB. It is possible,
however, to use several smaller objects to break up the large object. When this
approach is taken, the resulting large object is made out of two types of
objects:

- **Segment Objects** which store the actual content. You need to split your content into chunks
  and then upload each piece as its own segment object.

- A **manifest object** then links the segment objects into a single logical object. To download
  the object, you download the manifest. Object storage then concatenates the segments and
  returns the contents.

There are tools available, both GUI and CLI, that will handle the segmentation
of large objects for you. For all other cases, you must manually split the
oversized files and manage the manifest objects yourself.

Using the Swift command line tool
=================================

The Swift tool which is included in the `python-swiftclient`_ library, for
example, is capable of handling oversized files and gives you the choice of
using either``static large objects (SLO)`` or``dynamic large objects (DLO)``,
which will be explained in more detail later.

.. _python-swiftclient: http://github.com/openstack/python-swiftclient

|

Here are two examples of how to upload a large object to an object storage
container using the Swift tool. To keep the output brief, a 512MB file
is used in the example.

example 1 : DLO
---------------

The default mode for the tool is the ``dynamic large object`` type, so in this
example, the only other parameter that is required is the segment size.
The ``-S`` flag is used to specify the size of each chunk, in this case
104857600 bytes (100MB).

.. code-block:: bash

  $ swift upload mycontainer -S 104857600 large_file
  large_file segment 5
  large_file segment 0
  large_file segment 4
  large_file segment 3
  large_file segment 1
  large_file segment 2
  large_file

|

example 2 : SLO
---------------

In the second example, the same segment size as above is used, but you specify
that the object type must now be the ``static large object`` type.

.. code-block:: bash

  $ swift upload mycontainer --use-slo -S 104857600 large_file
  large_file segment 5
  large_file segment 1
  large_file segment 4
  large_file segment 0
  large_file segment 2
  large_file segment 3
  large_file

Both of these approaches will successfully upload your large file into
object storage. The file would be split into 100MB segments which are
uploaded in parallel. Once all the segments are uploaded, the manifest file
will be created so that the segments can be downloaded as a single
object.

The Swift tool uses a strict convention for its segmented object support. All
segments that are uploaded are placed into a second container that has
``_segments`` appended to the original container name, in this case it would be
mycontainer_segments. The segment names follow the format of
``<name>/<timestamp>/<object_size>/<segment_size>/<segment_name>``.

If you check on the segments created in example 1, you can see this:

.. code-block:: bash

  $ swift list mycontainer_segments
  large_file/1500505735.549995/536870912/104857600/00000000
  large_file/1500505735.549995/536870912/104857600/00000001
  large_file/1500505735.549995/536870912/104857600/00000002
  large_file/1500505735.549995/536870912/104857600/00000003
  large_file/1500505735.549995/536870912/104857600/00000004
  large_file/1500505735.549995/536870912/104857600/00000005


In the above example, it will upload all the segments into a second container
named test_container_segments. These segments will have names like
large_file/1290206778.25/21474836480/00000000,
large_file/1290206778.25/21474836480/00000001, etc.

The main benefit for using a separate container is that the main container
listings will not be polluted with all the segment names. The reason for using
the segment name format of <name>/<timestamp>/<size>/<segment> is so that
an upload of a new file with the same name won’t overwrite the contents of the
first until the last moment when the manifest file is updated.


Swift will manage these segment files for you, deleting old segments on deletes
and overwrites, etc. You can override this behavior with the --leave-segments
option if desired; this is useful if you want to have multiple versions of
the same large object available.

Dynamic Large Objects (DLO) vs Static Large Objects (SLO)
=========================================================

The main difference between the two object types is to do with the associated
manifest file that describes the overall object structure within Swift.

In both of the examples above, the file would be split into 100MB chunks
and uploaded. This can happen concurrently if desired. Once the segments
are uploaded, it is then necessary to create a manifest file to describe
the object and allow it to be downloaded as a single file. When using
Swift, the manifest fles are created for you.

The manifest for the ``DLO`` is an empty file and all segments must be
stored in the same container, though depending on the object store
implementation the segments, as mentioned above, may go into a container
with '_segments' appended to the original container name. It also works
on the assumption that the container will eventually be consistent.

For ``SLO`` the difference is that a user-defined manifest file describing
the object segments is required. It also does not rely on eventually
consistent container listings to do so. This means that the segments can
be held in different container locations. The fact that once all files are
can't then change is the reason why these are referred to as 'static' objects.

A more manual approach
======================

While the Swift tool is certainly handy as it handles a lot of the underlying
file management tasks required to upload files into object storage, the same
can be achieved by more manual means.

Here is an example using standard linux commandline tools such as
``split`` and ``curl`` to perform a dynamic large object file upload.

The file 'large_file' is broken into 100MB chunks which are prefixed with
'split-'

.. code-block:: bash

  $ split --bytes=100M large_file split-


The upload of these segments is then handled by cURL. See `using curl`_
for more information on how to do this.

.. _using curl: http://docs.catalystcloud.io/object-storage.html#using-curl

The first cURL command creates a new container. The next two upload the two
segments created previously, and finally, a zero byte file is created for the
manifest.

.. code-block:: bash

  curl -i $storageURL/lgfile -X PUT -H “X-Auth-Token: $token"
  curl -i $storageURL/lgfile/split_aa -X PUT -H "X-Auth-Token: $token" -T split-aa
  curl -i $storageURL/lgfile/split_ab -X PUT -H "X-Auth-Token: $token" -T split-ab
  curl -i -X PUT -H "X-Auth-Token: $token" -H "X-Object-Manifest: lgfile/split_" -H "Content-Length: 0"  $storageURL/lgfile/manifest/1gb_sample.txt

A similar approach can also be taken to use the SLO type, but this is a lot more involved. A
detailed description of the process can be seen `here`_


.. _here: https://docs.openstack.org/swift/latest/overview_large_objects.html#module-swift.common.middleware.slo
