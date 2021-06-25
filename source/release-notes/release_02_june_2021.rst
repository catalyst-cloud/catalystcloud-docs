#################
02 June 2021
#################

This release includes some minor changes to the kubernetes service, a minor
change to the password policy on the cloud, an update to our object storage
service and some important deprecation notices that will begin in future
releases.

****************************************
Kubernetes updates (Magnum)
****************************************

Rolling upgrade fix
=====================

There has been a fix applied to the rolling upgrade feature of kubernetes. This
release has solved an issue where kubernetes was not performing rolling
upgrades correctly when upgrading between k8s versions with an image digest or
when rebuilding a node based on an image change.

Fixed CA rotate
===============

A regression issue with CA rotate has been resolved in this release.

*************************************
Password Complexity changes (Horizon)
*************************************

Our password policy has been updated. The dashboard will now enforce a new
password complexity policy for all user accounts. This will not affect any
existing passwords for user accounts, and your current access will not be
affected by the change. However, when changing a password via the dashboard the
new complexity policy will apply.

More information on the new policy and other security practices can be found
:ref:`here <password_protocols>`

**********************************************
Deprecation notices (HA proxy, Cinder, Glance)
**********************************************

Insecure ciphers on API endpoints to be disabled
================================================

From Tuesday, 14 September we are removing a number of ciphers, which are
insecure, from the allowed list of ciphers when communicating with our API
endpoints.

This will affect all Catalyst Cloud API endpoints except Object Storage.

In particular, the following ciphers will no longer be available via our API
endpoints:

- ECDHE-RSA-AES128-SHA256
- ECDHE-RSA-AES256-SHA384

If possible, you should configure your software to deny using these ciphers and
test that you can still interact with our API endpoints, to ensure that when
these ciphers are removed you are not affected.

Deprecation of the v2 block storage API
=======================================

The block storage version 2 API is deprecating and will soon no longer be
available for use. To ensure that you are still able to interact with your block
storage resources you should check that any client tools that interact with the
block storage service are able to use the cinder v3 API.

If you are using the python-cinderclient tools to interact with your project
then making sure you have the up to date version of these tools will ensure this
deprecation does not effect you.

Deprecation of the Image service v1 API
=======================================

As of this month we are treating the Image service v1 API (known as Glance)
as deprecated. This API will remain functional until it is disabled at a later
date, however if you are using the version 1 API we strongly advise that you
reconfigure any tools or configuration to use a newer version and perform
testing.

We expect at least six months before the version 1 API will be disabled, and
we will provide an update at least one month before it is disabled. To ensure
that you are still able to interact with the image service as this change takes
place, we recommend updating your version of the python-glanceclient tools to
version 2.8 or above.

To get the most current version of the python-glanceclient tools on linux based
systems, you can run the following command:

.. code-block::

    pip install python-glanceclient -U


****************************
Object Storage Improvements
****************************

Recently we have made some improvements to our object storage service. This
update sees a number of improvements being made to the service, with a
focus around compatibility with Amazon's S3 Object storage service.

The most recent improvements are:

* Support 'version 4' signatures for S3 requests, enabling a wider range
  of S3-compatible tools to be used with our Object Storage
* Improved error messages when using S3 requests so they match the
  expected behavior on errors
* Improved the method of calculating static large object sizes, when
  versioned containers are involved
* Resolved random occurrences of 404 responses to some requests for objects
* A number of other bug fixes and general improvements
