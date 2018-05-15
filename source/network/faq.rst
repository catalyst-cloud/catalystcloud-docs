###
FAQ
###

How do I find the external IP address of my instance?
=====================================================

There are scenarios where you may need to know the external IP address that
instances in your project are using. For example, you may wish to allow traffic
from your Catalyst Cloud instances to access a service that has firewalling or
other IP based access control in place.

For instances that have a floating IP you simply need to find the floating IP.
For instances that do not have a floating IP address, the external IP address
will be the external address of the router they are using to access the
``public-net``.

There are a number of methods you can use to find the IP address:

Using DNS on an instance
------------------------

From a cloud instance run the following command:

.. code-block:: bash

 ubuntu@my-instance:~$ dig +short myip.opendns.com @resolver1.opendns.com
 150.242.43.13

Using HTTP on an instance
-------------------------

From a cloud instance run the following command:

.. code-block:: bash

 ubuntu@my-instance:~$ curl http://ipinfo.io/ip
 150.242.43.13

Using a bash script on an instance
----------------------------------

You can use a bash script we have written for this purpose:

.. literalinclude:: ../_scripts/whats-my-ip.sh
  :language: bash

You can download and run this script on an instance:

.. code-block:: bash

 $ wget -q https://raw.githubusercontent.com/catalyst/catalystcloud-docs/master/scripts/whats-my-ip.sh
 $ chmod 744 whats-my-ip.sh
 $ ./whats-my-ip.sh
 finding your external ip ...
 Your external IP address is: 150.242.43.13

Using the OpenStack Command Line Tools
======================================

The method you use to find the external IP address will depend on whether the
instance has a floating IP address or not:

For an instance with a floating IP
----------------------------------

You can find the Floating IP of an instance in the instances list on the
dashboard. From the command line you can use the following command:

.. code-block:: bash

 $ openstack server show useful-machine -f value -c addresses | awk '{ print $2 }'
 150.242.43.13

For an instance without a floating IP
-------------------------------------

From a host where you have the OpenStack command line clients installed run the
following command:

.. code-block:: bash

 $ openstack router show border-router -f value -c external_gateway_info
 | external_gateway_info | {"network_id": "849ab1e9-7ac5-4618-8801-e6176fbbcf30", "enable_snat": true, "external_fixed_ips": [{"subnet_id": "aef23c7c-6c53-4157-8350-d6879c43346c", "ip_address": "150.242.40.120"}]} |

The address is the value associated with ``ip_address`` in
``external_fixed_ips``.

If you have ``jq`` installed you can run the following command:

.. code-block:: bash

 $ openstack router show border-router -f value -c external_gateway_info | jq -r '.external_fixed_ips[].ip_address'
 150.242.43.12


Why can't I SSH to my instance?
===============================

The standard way to SSH to an instance is to simply do so directly using an SSH
client like this:

.. code-block:: bash

  $ ssh ubuntu@103.254.156.248

.. note::

  The OpenStack command line client has an SSH option. This is not a
  recommended method for logging into an instance. This command
  currently has a bug where it cannot find the public address
  for an instance that does have a valid floating IP.

If you cannot SSH to an instance, there are two common root causes and one
less common one:

* Network issues connecting to the SSH Daemon on your instance
* Authentication issues after connecting to the SSH Daemon
* Issues with your instance such that the SSH Daemon is not available

Connection issues are generally caused by Security Group misconfiguration.
Authentication issues are generally caused by the use of incorrect users or SSH
keys.

If you are encountering a ``Connection timed out`` error then you have a
connection issue. If you are encountering a ``Permission denied (publickey).``
error then you have an authentication issue. If you are encountering a
different SSH error, then it is likely there is an issue with your instance.

Network issues
--------------

If you are encountering a ``Connection timed out`` error from your SSH client
then you have a network connection issue. The most common reason for this is a
Security Group misconfiguration. If you are experiencing this issue check the
following:

* Are you using the correct floating IP address when connecting?
* Do you have a security group that has a rule that allows incoming connections to port 22?
* Is your instance a member of the security group that allows SSH access?
* Is your source IP address within the CIDR IP range defined in the security group rule?

You can check your floating IP address with the following command:

.. code-block:: bash

  $ openstack server show example-instance | grep private-net
  | private-net network                  | 10.0.0.10, 150.242.40.180                                  |

You can check you have a security group rule for SSH access with the following
command:

.. code-block:: bash

  $ openstack security group rule list example-instance-sg
  +-------------+-----------+---------+------------+--------------+
  | IP Protocol | From Port | To Port | IP Range   | Source Group |
  +-------------+-----------+---------+------------+--------------+
  | tcp         | 22        | 22      | 1.2.3.4/32 |              |
  +-------------+-----------+---------+------------+--------------+

You can check which security groups your instances is a member of with the
following command:

.. code-block:: bash

  $ openstack server show example-instance | grep security_groups
  | security_groups                      | example-instance-sg, default

You can check what your public source IP address is using one of the following
commands:

.. code-block:: bash

  $ dig +short myip.opendns.com @resolver1.opendns.com
  $ curl http://ipinfo.io/ip

There are also numerous web sites that provide this information:
https://www.google.co.nz/search?q=whats%20my%20ip.

Security Group setup for SSH access
===================================

Assuming you have already assigned a floating IP address to your instance,
you will also need to create a security group and associate it with the
instance. Then create a rule within this group that will allow inbound SSH
access to your public IP address.

Create a new security group with this command:

.. code-block:: bash

  $ openstack security group create <name> <description>

For example, create a new security group called test-security-group:

.. code-block:: bash

  $ openstack security group create test-security-group --description "security group for test instance"

Add a new rule to the security group to allow access with the following:

.. code-block:: bash

  $ openstack security group rule create --ingress --protocol <ip-proto> --dst-port <to-port> --src-ip <cidr> <secgroup>

For example allow SSH access from 1.2.3.4

.. code-block:: bash

  $ openstack security group rule create --ingress --protocol tcp --dst-port 22 --src-ip  1.2.3.4/32 test-security-group

Finally, associate the new security group with the instance:

.. code-block:: bash

  $ server add security group <server> <securitygroup>

For example associate test-security-group with the instance first-instance

.. code-block:: bash

  $ server add security group first-instance test-security-group

Now test your access: you should be able to connect to your instance.

The same outcome can be achieved via the Cloud dashboard.

Create a new security group under ``Access & Security → Security Groups →
Create Security Group``. Once the new group is created go to ``Manage Rules →
Add Rule`` and create the appropriate inbound access rule.

Return to the instance page, from the Actions drop-down menu on the right
select ``Edit Security Groups``. Click the plus on your new security group and
ensure it now appears as one of the Instance Security Groups.

Testing Network Access
======================

If you want to test you have set up security groups properly for SSH access, you
can check port 22 on the floating IP for an SSH banner using telnet or netcat:

.. code-block:: bash

  $ nc 103.254.157.197 22
  SSH-2.0-OpenSSH_6.6.1p1 Ubuntu-2ubuntu2.6
  ^C

If you do not see an SSH banner, then it is likely you have not configured your
security group rules appropriately.

Authentication issues
---------------------

If you are encountering a ``Permission denied (publickey).`` error from your
SSH client then you have an authentication issue. If you are getting this error
then check the following:

* Are you using the correct user?
* Are you using the correct SSH key pair?
* Did you specify a key pair when you created the instance?

.. _ssh-user:

SSH User
========

As stated previously a typical SSH connection command looks like this:

.. code-block:: bash

  $ ssh ubuntu@103.254.156.248

Note the use of the ubuntu username, this is the default user for Ubuntu,
change this as required for the distribution you are using as explained at
:ref:`images`.

.. _ssh_keypairs:

SSH Key Pairs
=============

SSH key pairs are required for SSH access to instances. You can either import
an existing key pair or you can have a key pair created for you.

A key pair consists of two files: one contains the private key and the other
contains the public key. The private key will remain on your local machine and
should be kept private and secure. The public key is uploaded to your project
and will be injected into the authorised keys (``~/.ssh/authorized_keys``) for
the default user of the cloud image you are using (see :ref:`ssh-user`) when
your instance is created.

Default Key Pair
----------------

If you have imported a default SSH key pair (eg ``~/.ssh/id_rsa*``), then you
should be able to SSH using the standard SSH command:

.. code-block:: bash

  $ ssh ubuntu@103.254.156.248

Alternate Key Pair
------------------

If your SSH key pair is not in the standard location, you will need to use
the ``-i`` flag to SSH to indicate the key you wish to use.

.. code-block:: bash

  $ ssh -i ~/alt-key.pem ubuntu@103.254.157.197

.. note::

  The ``-i`` flag should reference the private key.

Created Key Pair
----------------

If you selected ``+ Create Key Pair`` from the dashboard, your browser
should have downloaded and saved the private key file for you. This will be
located in the default download location on your local machine (e.g.
``~/Downloads/keyname.pem``).

Before you can use this file you will need to change the permissions. If you do
not do so you will receive a warning entitled ``WARNING: UNPROTECTED PRIVATE
KEY FILE!`` and the key will be ignored which will result in a ``Permission
denied (publickey).`` error when connecting.

Do the following to secure this key:

.. code-block:: bash

  $ mv ~/Downloads/keyname.pem ~/.ssh/
  $ chmod 400 ~/.ssh/keyname.pem

When you use this option only the private key is downloaded to your machine. If
you need to know the public key (e.g. if you wish to use it elsewhere) you can
retrieve it using one of the following commands:

.. code-block:: bash

  $ openstack keypair show --public-key keyname
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCXX4g2e95XRH42zNN0rU+82e4UuND/5qjjMWeB/U7wm+kqPHHQpT98UJmDWMsyiJ93fpC+0vd9Hu2DAkycPhd0Tp4y8g/MagwaHj+hJrvUeCXnfHwHgPwcHQR3BoIXGBl0h/+BRELRBfyQAoN7+InlFlqp3lnhNQm9X6CKlfMNo7x1T0VWRUh64WdWrcjQOVU9EFFIL8xCHut7/eZY5l+X7NxIK8rALw+6Lo7AGAaWVo3Msi0DmE6y0y48OzGmOrXbZWUyS3mX7Tg0RsA9ynm2cJ2VM2GWpc7AMdxCv7VZu0J445MDj2ueJna4r8+qq4y6nJZ2JPJG3Su+51Vp4U93FtA0a90smTOGccOx6OMCly19sGEmQhUrUEevx0lrRHoDujZ+P7JD8mVR6cog/1n+OBqUMAa8dHgIGg0/KgcZ5ilDeyeqgELAcZoyRQLXu7eiQyH/hEc/Hh9xpXWwAK4kYe0HNXlJ0pB8j3aaY9Xrkk1s7xbCgZuoFZ2q1S+rEVMh9k1cflNurYwT8V5Iv9YuvX/rK7bSpmnFN6TtCEvJSBoqF3YXcxLjMCC7JMmhtXlNhWaethIdGz1iatjrVmKKe+r43N7IGBQX2iThi9sg6Uv6jeayjx5sUlPfimzFjnVB2/g/WKpiEFzA+nsfY8mKQzeLmRuuVQqlryWmCY0FIQ==
  $ ssh-keygen -f ~/.ssh/keyname.pem -y
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCDqJg/ijZsMk0AW33YOtGEmxatyakgEqOCE72hDy/MLyEiRPuInYPTJH9WhfjFQA8JgV/Wwt7iJqvosWWN65Sal8Vdqux2tVQtUHNTyllbh0JhlgNuRvQuPSLFN7IyRTlFSyUBztvDMLCBfR8785f8qwI4lNQ1LQyUWqAfXJ8sxYV0RO1puG3dIq6ME0MseQTxXB+G/ceiW17isUQ7zCK71KDECOhPF76sUgJaS/xBrKUFAwaXnHUmLxs7vLCChag0EGaMAo3yAAEy+Ptpfser+tdfK2xf54MvH4ebgQU+yZwPI8DpidbLmcuIOGimzqCG/MQUrCgY6jwT9CRlBsR

To write the public key to a file you can issue the following command:

.. code-block:: bash

  $ ssh-keygen -f ~/.ssh/keyname.pem -y > ~/.ssh/keyname.pub

Verifying SSH public key fingerprints
=====================================

According to `Wikipedia`_:

"In public-key cryptography, a public key fingerprint is a short sequence of
bytes used to identify a longer public key. Fingerprints are created by
applying a cryptographic hash function to a public key. Since fingerprints are
shorter than the keys they refer to, they can be used to simplify certain key
management tasks."

.. _Wikipedia: https://en.wikipedia.org/wiki/Public_key_fingerprint

Fingerprints are a useful way to verify that you are using the correct key
pair. If you have the public key locally then you can run this command to
generate the fingerprint:

.. code-block:: bash

  $ ssh-keygen -lf ~/.ssh/keyname.pub
  2048 34:de:c7:b7:f1:26:7f:88:d5:e7:10:6c:ab:af:a2:03 you@hostname (RSA)

If you have an OpenStack generated ``pem`` file and do not have the public key
stored locally, you can issue the following command:

.. code-block:: bash

  $ ssh-keygen -lf /dev/stdin <<< $( ssh-keygen -f ~/.ssh/keyname.pem -y )

To check the fingerprint of the key stored in your project, issue the following
command:

.. code-block:: bash

  $  openstack keypair show testkey | grep fingerprint
  | fingerprint | 34:de:c7:b7:f1:26:7f:88:d5:e7:10:6c:ab:af:a2:03 |

To check the key associated with an instance, issue the following
command:

.. code-block:: bash

  $ openstack server show first-instance | grep key_name
  | key_name                             | keyname                                         |

To check the key with the correct fingerprint was correctly injected into the
correct user's authorised keys, issue the following command:

.. code-block:: bash

  $ openstack console log show first-instance | grep 'Authorized keys' -A 5
  ci-info: ++++++Authorized keys from /home/ubuntu/.ssh/authorized_keys for user ubuntu++++++++++
  ci-info: +---------+-------------------------------------------------+---------+--------------+
  ci-info: | Keytype |                Fingerprint (md5)                | Options |  Comment     |
  ci-info: +---------+-------------------------------------------------+---------+--------------+
  ci-info: | ssh-rsa | 34:de:c7:b7:f1:26:7f:88:d5:e7:10:6c:ab:af:a2:03 |    -    | you@hostname |
  ci-info: +---------+-------------------------------------------------+---------+--------------+

Instance issues
===============

No route to host
----------------

If you are encountering a ``No route to host`` error, it is likely there is
an issue with your instance. You should check that the instance is running:

.. code-block:: bash

  $ openstack server show instance-name | grep status
  | status                               | SUSPENDED

The error can be triggered when an instance state is not ``ACTIVE``. In this
case, OpenStack will reply to a SSH connection attempt with a ICMP host
unreachable packet.

Connection refused
------------------

A ``connection refused`` error is caused by a TCP RST packet when attempting to
connect to the SSH port.

The most common reason for this error is misconfigured DNS servers on the
subnet where this instance resides. If DNS resolution is not working during
initialisation of the instance, delays will occur while the instance cloud-init
process waits for DNS. These delays occur before the SSH service is configured.
The service usually becomes available after about 5 minutes. When the SSH
connection becomes available it is often slow to connect. This is also caused
by broken DNS resolution on the instance.

Checking the instance console log can help verify if this is the issue you're
experiencing:

.. code-block:: bash

  $ openstack console log show broken-dns-instance --lines 6
  ci-info: +-------+-------------+-----------+---------------+-----------+-------+
  ci-info: | Route | Destination |  Gateway  |    Genmask    | Interface | Flags |
  ci-info: +-------+-------------+-----------+---------------+-----------+-------+
  ci-info: |   0   |   0.0.0.0   | 10.0.20.1 |    0.0.0.0    |    eth0   |   UG  |
  ci-info: |   1   |  10.0.20.0  |  0.0.0.0  | 255.255.255.0 |    eth0   |   U   |
  ci-info: +-------+-------------+-----------+---------------+-----------+-------+

If you see output similar to that shown above, it is likely the server is
waiting on DNS resolution.
