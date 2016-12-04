#######################################
Backup to Object Storage with Duplicity
#######################################

Introduction
============

This is a basic overview showing how to create server backups in OpenStack
Swift object storage using `Duplicity`_.

.. _Duplicity: http://duplicity.nongnu.org/

Assumptions
-----------
- You have familiarity with the Linux commandline and Openstack CLI tools.
- You have a valid openstack RC file and know how to source it.

What is Duplicity
=================
Duplicity is a band-width efficient backup utility capable of providing
encrypted, digitally signed, versioned, remote backup in a space efficient
manner.

Duplicity creates an initial archive that is a full backup. All subsequent
backups are incremental and only save the difference between the latest (full
or incremental) backup. A full backup and corresponding series of incremental
backups can be recovered to any point in time covered by the incremental
backups. If an incremental backup is missing from the `backup chain`_ then any
subsequent incremental backup file cannot be recovered.

Duplicity is released under the terms of the GNU General Public License (`GPL`_),
and as such is free software.

.. _GPL: https://en.wikipedia.org/wiki/GNU_General_Public_License
.. _backup chain: http://sqlbak.com/academy/backup-chain/

Prerequisites
=============

If you're using a major Linux distribution you should be able to find a
pre-compiled package in the repositories. If not then a tar file is available
at `Duplicity`_.

.. code-block:: bash

  sudo apt-get update
  sudo apt-get install duplicity

Duplicity requires certain environment variables to be set. One option would
be to source a simple bash script like this.

.. code-block:: bash

  #!/bin/bash

  # Swift credentials for Duplicity
  export SWIFT_USERNAME="somebody@example.com"
  export SWIFT_TENANTNAME="mycloudtenant"
  export SWIFT_AUTHURL="https://api.cloud.catalyst.net.nz:5000/v2.0"
  export SWIFT_AUTHVERSION="2"

  # With Keystone you pass the keystone password.
  echo "Please enter your OpenStack Password: "
  read -sr PASSWORD_INPUT
  export SWIFT_PASSWORD=$PASSWORD_INPUT

Because we are going to authenticate against keystone it is also necessary to
install ```python-keystoneclient``` which is not a dependency of Duplicity.

.. code-block:: bash

  sudo apt-get install python-keystoneclient

or

.. code-block:: bash

  pip install python-keystoneclient

If you intend to create encrypted backups you will also require a GPG key. 





Other things to Consider
========================
Not a fan of the command line? Then consider using Deja-Dup as a front end for
Duplicity.
