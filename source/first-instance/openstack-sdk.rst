***********************
Using the Openstack SDK
***********************

The Catalyst Cloud is built on top of the OpenStack project. There are many
Software Development Kits for a variety of different languages available for
OpenStack. Some of these SDKs are written specifically for OpenStack while
others are multi cloud SDKs that have an OpenStack provider. Some of these
libraries are written to support a particular service like Compute, while
others attempt to provide a unified interface to all services.

You will find an up to date list of recommended SDKs at
http://developer.openstack.org/. A more exhaustive list that includes in
development SDKs is available at https://wiki.openstack.org/wiki/SDKs.

This section covers the OpenstackSDK which is a python based sdk with
support currently only provided for python3. This sdk came out of 3
separate libraries originally: shade, os-client-config and
python-openstacksdk. They each have their own history on how they
were created but after awhile it was clear that there was a lot
to be gained by merging the three projects.

Installing OpenstackSDK
=======================

The recommended way to install an up to date version of the OpenstackSDK is to
use Python's pip installer. Simply run:

.. code-block:: bash

 pip install openstacksdk.

It is recommended that you use the openstack sdk from a virtual
environment. More information can be found here: :ref:`python-virtual-env`

OpenStack credentials
=====================

The first step in getting an instance running is to provide your Python script
with the correct credentials and configuration appropriate for your project.
The easiest way to achieve this is to make use of environment variables. You
can make use of the standard variables provided by an OpenStack RC file as
described at :ref:`source-rc-file`.

Once you have sourced your file and your env variables are set; to get them
into your python file you can use the following code:

.. code-block:: bash

 import os

 auth = os.environ['OS_AUTH_URL']
 region_name = os.environ['OS_REGION_NAME']
 project_name = os.environ['OS_PROJECT_NAME']
 username = os.environ['OS_USERNAME']
 password = os.environ['OS_PASSWORD']

.. Note::

  To ensure this works, you must have imported the 'os' library into your file first.

Connecting to your project
==========================

The next step is to connect your script to the catalyst cloud, so that you are
able to access all the resources provided. This is done by running the
following code block, after retrieving your environment variables.

.. code-bloc:: bash

 from openstack import connection

 conn = openstack.connect(
        auth_url=auth,
        project_name=project_name,
        username=username,
        password=password,
        region_name=region_name,
        app_name='examples',
        app_version='1.0',
    )

