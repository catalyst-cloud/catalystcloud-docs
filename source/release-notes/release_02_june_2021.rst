#################
02 June 2021
#################

This release includes some minor changes to the kubernetes service, a minor
change to the password policy on the cloud and some important deprecation
notices that will begin in future releases.

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


*************************************
Password Complexity changes (Horizon)
*************************************

Our password policy has been updated. The dashboard will now enforce a new
password complexity policy for all user accounts. This will not affect any
existing passwords for user accounts, and your current access will not be
affected by the change. However, when changing a password via the dashboard the
new complexity policy will apply.

The new policy requires either of the following:

- a password with 12 characters and 3 of 4 character groups (lowercase, uppercase, numbers, special chars excluding space); or
- a passphrase with 18 characters and 2 of 4 character group (lowercase, uppercase, numbers, special chars including space)

We encourage all customers to change their passwords on a regular basis, and to
enable Multi-Factor Authentication on user accounts. This will assist in
protecting your accounts from unauthorized use.

More information on the new policy and other security practices can be found
:ref:`here <password_protocols>`


*****************************************
Deprecation notices (HA proxy and Cinder)
*****************************************


Insecure ciphers on API endpoints to be disabled
================================================

From Tuesday, 14 September we are removing a number of ciphers, which are
insecure, from the allowed list of ciphers when communicating with our API
endpoints.

This will affect all Catalyst Cloud API endpoints except Object Storage.
The API endpoints will continue to offer a standard set of secure ciphers,
widely supported by up-to-date implementations of TLS. However, if your software
or operating system is not being kept up to date, or is too old to support
current implementations of TLS, it may not have the required support for modern
secure ciphers.

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