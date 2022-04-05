#######################
Using Audit Logs
#######################

********************************
Activating logs for your project
********************************

#. Create container in any project

#. Create credentials for access

Users may wish to create a new user with only the `Object Storage` role
assigned. As the EC2 credentials otherwise have a much larger reach into the
project than required.

.. code-block:: bash

    # Optional: Create a new EC2 credential. Accounts should have one created already.

    $ openstack ec2 credentials create

    +------------+---------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Field      | Value                                                                                                                                                   |
    +------------+---------------------------------------------------------------------------------------------------------------------------------------------------------+
    | access     | 7d84281f4bc542b987ddbxxxxxxxxxxx                                                                                                                        |
    | links      | {u'self': u'https://api.osppd.por.catalystcloud.nz:5000/v3/users/bf32a9a2c69e4d718022101e867cccec/credentials/OS-EC2/7d84281f4bc542b987ddbxxxxxxxxxxx'} |
    | project_id | 033556c5979b4c12814e7b6302cc6835                                                                                                                        |
    | secret     | 100e767eeb7b48dcaf25xxxxxxxxxxxx                                                                                                                        |
    | trust_id   | None                                                                                                                                                    |
    | user_id    | bf32a9a2c69e4d71xxxxxxxxxxxxxxxx                                                                                                                        |
    +------------+---------------------------------------------------------------------------------------------------------------------------------------------------------+

    # View EC2 credentials
    $ openstack ec2 credentials list -c Access -c Secret
    +----------------------------------+----------------------------------+
    | Access                           | Secret                           |
    +----------------------------------+----------------------------------+
    | 7d84281f4bc542b987ddbxxxxxxxxxxx | 100e767eeb7b48dcaf25xxxxxxxxxxxx |
    +----------------------------------+----------------------------------+

#. List project uuids to audit

$ openstack project list

#. Send creds and project uuids to Catalyst Cloud (securely!)

Create a support ticket - are these secure?

Don't include the AUTH_KEY, have openstack admin user find it?

