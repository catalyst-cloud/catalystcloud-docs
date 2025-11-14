.. _s3browser:

**********
S3 Browser
**********

A commercial (free for personal use) client for MS Windows. It is available
from https://s3browser.com/ . It is compatible
with Catalyst Cloud object storage using the OpenStack S3 API.

Configuration steps
===================

#. Accounts -> Add new account
#. Account type: select "S3 Compatible Storage"
#. REST Endpoint: select a "s3" URL from :ref:`apis`
#. Access Key & Secret Access Key: EC2 credentials (you may wish to create a dedicated user).
#. Select "advanced settings"
#. Signature version: select "Signature V4"
#. Select "Close"
#. Select "Add new account"

You should now be able to connect to the account and then browse, upload,
download etc. You may occasionally receive errors that some functionality
isn't supported.
