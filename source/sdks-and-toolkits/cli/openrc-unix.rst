Open the `Catalyst Cloud Dashboard <https://dashboard.catalystcloud.nz>`_
in your browser and and login.

Click your email address in the top right corner of the dashboard page.
This opens a drop-down list with a few options.

.. image:: assets/openrc-download.png

Different OpenRC files are available for different platforms.
Click "OpenStack RC File for Linux/macOS" to download the correct OpenRC file
for your platform, and save the file to the current directory of your open terminal session.

The OpenRC file is a Bash script named ``project_name-openrc.sh``,
where ``project_name`` is the name of your Catalyst Cloud project.
To authenticate your terminal session with Catalyst Cloud,
run the following command to source the script into your session.

.. code-block:: bash

  source project_name-openrc.sh

This is referred to as **sourcing your OpenRC file**, and is required
to be done before using the ``openstack`` command to interact with
your Catalyst Cloud project.

First, you will be prompted for a password, as shown below.

.. code-block:: console

  $ source project_name-openrc.sh
  Please enter your password for user admin@example.com:

Type in your password as you would on the Catalyst Cloud Dashboard
login page. For security reasons, the password itself is not shown
in the prompt. Once you are done, press Enter to submit the password.

You will then be asked to enter your MFA verification code,
if you have enabled :ref:`multi-factor authentication (MFA) <multi_factor_authentication>`
on your account.

.. code-block:: console

  $ source project_name-openrc.sh
  Please enter your password for user admin@example.com:
  Please enter your MFA verification code (leave blank if not enabled):

If MFA is enabled on your account, type in the latest
verification code displayed on your authenticator device
and press Enter to submit it.
If you have not enabled MFA on your account,
leave the prompt blank and just press Enter to continue.

The OpenRC file will now login as your Catalyst Cloud user,
and generate an **access token** for your terminal session,
which gets configured in your environment variables.

.. code-block:: console

  $ source project_name-openrc.sh
  Please enter your password for user admin@example.com:
  Please enter your MFA verification code (leave blank if not enabled): 123456
  Requesting a new access token...
  Access token obtained successfully and stored in $OS_TOKEN.

The access token for your terminal session is valid for **12 hours**.
Once 12 hours have passed, you will need to source your OpenRC file again.

The OpenRC file also sets the ``OS_REGION_NAME`` environment variable,
which configures the active Catalyst Cloud region in your terminal session.
This gets set to the region active in the Catalyst Cloud Dashboard when you
downloaded the OpenRC file.

.. code-block:: console

  $ echo $OS_REGION_NAME
  nz-por-1

To change the active Catalyst Cloud region in your terminal session,
run the following command, setting the value to the region you'd like to switch to.

.. code-block:: bash

  export OS_REGION_NAME=nz-hlz-1
