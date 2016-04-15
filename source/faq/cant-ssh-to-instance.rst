###############################
Why can't I SSH to my instance?
###############################

The standard way to SSH to an instance is to simply do so directly like this:

.. code-block:: bash

 $ ssh ubuntu@103.254.156.248

This assumes you have configured the instance using a standard SSH keypair (eg
``~/.ssh/id_rsa*``) and have setup the appropriate security group rule.

If your SSH key is not in the standard location then you will need to use the
``-i`` flag to SSH to indicate the key you wish to use.

.. code-block:: bash

 $ ssh -i ~/alt-key.pem ubuntu@103.254.157.197

.. note::

 The ``-i`` flag should refer to the private key.

Testing Network Access
======================

If you want to test you have setup security groups properly for SSH access you
can check port 22 on the floating ip for an SSH banner using telnet or netcat:

.. code-block:: bash

 $ nc 103.254.157.197 22
 SSH-2.0-OpenSSH_6.6.1p1 Ubuntu-2ubuntu2.6
 ^C

If you do not see a SSH banner then it is likely that you have an issue with
your security groupps or with instance creation.

If you can see the banner but not login (eg you are getting a Permission denied
(publickey). error) then you are either using the wrong user or you are not
using the right ssh key.

SSH User
========

Note the use of the ubuntu username, this is the default user for ubuntu,
change this as required for the distro you are using, these are listed here:

http://docs.catalystcloud.io/image.html#images

.. note::

 The nova command line cleint has an SSH option this is not a recomended method to SSH to instances. This command currently has a bug where it cannot find the public address for an instances that does have a valid floating ip

Verifying SSH public key signatures
===================================

.. code-block:: bash

 $ ssh-keygen -lf cloud.key.pub
 2048 70:bb:b7:b8:64:5a:53:25:08:c5:fb:64:1e:37:f7:58  you@hostname (RSA)

Talk about public key injection intoinstances via the metadata service

Security Group Setup
====================

Assuming you have already assigned a floating IP address to your new instance,
you will also need to create a security group and associate it with this
instance. Then create a rule within this group that will allow inbound SSH
access to your public IP address.

Create a new security group with this command:

.. code-block:: bash

 $ nova secgroup-create <name> <description>

e.g. create a new security group called test-security-group

.. code-block:: bash

 $ nova secgroup-create test-security-group "security group for test instance"

then add a new rule to the security group to allow access with the following

.. code-block:: bash

 $ nova secgroup-add-rule <secgroup> <ip-proto> <from-port> <to-port> <cidr>

e.g. allow ssh access in from 1.2.3.4

.. code-block:: bash

 $ nova secgroup-add-rule test-security-group tcp 22 22 1.2.3.4/32

finally, associate the new security group with the instance

.. code-block:: bash

 $ nova add-secgroup <server> <securitygroup>

e.g. associate test-security-group with the instance first-instance

.. code-block:: bash

 $ nova add-secgroup first-instance test-security-group

Now test your access.

The same outcome can also be achieved via the Cloud dashboard.

Create a new security group under Access & Security -> Security Groups ->
Create Security Group. Once the new group is created go to Manage Rules -> Add
Rule and create the appropriate inbound access rule.

Now go back to the instance page and from the Actions drop-down menu on the
right select Edit Security Groups. Click the plus on your new security group
and ensure it now appears as one of the Instance Security Groups.
