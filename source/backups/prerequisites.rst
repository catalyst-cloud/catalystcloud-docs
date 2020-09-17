#############
Prerequisites
#############

If you're using a major Linux distribution, you should be able to find a
pre-compiled package in the repositories. If not, then a tar file is available
at `Duplicity`_.

.. _Duplicity: http://duplicity.nongnu.org/

.. code-block:: bash

  sudo apt-get update
  sudo apt-get install duplicity

Because we are going to authenticate against keystone, it is also necessary to
install ``python-keystoneclient``.

.. code-block:: bash

  sudo apt-get install python-keystoneclient

or

.. code-block:: bash

  pip install python-keystoneclient

If you intend to create encrypted backups you will also require a GPG key. The
``gpg --gen-key`` command line tool can create a local one for you, see
(`GnuPG`_) for more information on this.

.. _GnuPG: https://www.gnupg.org/gph/en/manual/c14.html

Duplicity requires certain environment variables to be set. One option would
be to source a simple bash script like this. The data for these variables can
be obtained from your OpenStack RC file.

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

In order to source this file, run the following from the command line

.. code-block:: bash

  source <filename.sh>

This will need be done before each Duplicity run if the variables are not
already set.
