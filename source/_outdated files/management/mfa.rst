###########################
Multi Factor Authentication
###########################

Catalyst Cloud provides the ability to further secure your cloud access by
enabling multi factor authentication (MFA). This is a per user feature and once
it has been enabled it will apply to any cloud project that the user tries to
access.

.. note::

    For users enabling MFA, you will find that version 2 of the Keystone API no longer allows
    authentication and you will have to authenticate with the v3 API to use this feature, or not
    turn it on. This will only affect users that are consuming the APIs directly, users who only
    login through the dashboard will automatically be authenticating with the version 3 API.

**************
Activating MFA
**************

MFA needs to be enabled through the user setting option in the cloud dashboard.
To see this navigate to the following

|

.. image:: ../_static/settings.png

|

From here you will be able to set up MFA for your user account.

|

.. image:: ../_static/mfa_settings.png

|

In order to proceed you will need an application such as Google Authenticator
or Authy on a mobile device or tablet. Using the app scan the QR code and then
enter the enter the 6 digit passcode provided. The pass codes are time
dependent and there is typically a visual indicator of some kind along side the
current code. Before entering your pass code ensure that there is enough time
to complete the entry and submit it otherwise you will have to redo it.

|

.. image:: ../_static/mfa_activate.png

|

.. note::

    If you are having trouble getting the MFA to activate and are receiving errors then try the
    following.

    - Refresh the page fully, rescan the QR code, try again.
    - Before you submit make sure that when you click the details link on the page, there are
      secret details there, if not, reload, rescan, retry."

|

If the passcode was successful you will be redirected back to the login screen
and prompted to re-login using MFA.

|

.. image:: ../_static/mfa_login_activated_msg.png

|

Place a tick in the **MFA Enabled** checkbox and enter a valid passcode from
your authentication app and click **Sign In**.

|

.. image:: ../_static/mfa_login_totp.png

|

****************************
Which users have MFA enabled
****************************

Any project user that has one of the admin roles assigned to them can view all
of the users currently able to access that project and see whether or not they
have MFA enabled.

************
Removing MFA
************

To remove MFA authentication from a user's account, login as that user, and
access the MFA settings via the settings menu, as shown above. Add a valid
passcode and click Submit,

|

.. image:: ../_static/remove_mfa.png

If the passcode was successful you will be redirected to the login screen and
prompted to re-login without using MFA.

.. image:: ../_static/mfa_removed_login.png

************************
MFA from the commandline
************************

Once MFA has been enabled for a user's account it is no longer possible use
v2.0 authentication with keystone. For most users this simply means downloading
a new openrc file with the updated authentication details.

This can be obtained in a couple of places as shown here.

|

.. image:: ../_static/user_menu_openrc.png

|

.. image:: ../_static/api_access_openrc.png

|

Now when the openrc file is sourced there will be an extra prompt, which will
require you to add a valid passcode. Once this has been entered successfully an
openstack authentication token will be added as an environment variable in your
current terminal session.


.. code-block:: bash

    $ source mfa-openstack-openrc.sh
    Please enter your OpenStack Password for project myproject as user someuser@catalyst.net.nz:
    Please enter your OpenStack MFA passcode (leave blank if not enabled):
    466021
    Your OS_TOKEN has been setup
