Once you have downloaded and installed the AWS CLI
(see `AWS CLI - Getting Started <https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html>`_ for more information),
you will need to use the Catalyst Cloud Client to create the credentials for the AWS CLI.

First, run ``openstack ec2 credentials create`` to create an EC2 credential.

.. code-block:: console

  $ openstack ec2 credentials create
  +-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------+
  | Field           | Value                                                                                                                                                |
  +-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------+
  | access          | ee55dd44cc33bb2211aaee55dd44cc33                                                                                                                     |
  | access_token_id | None                                                                                                                                                 |
  | app_cred_id     | None                                                                                                                                                 |
  | links           | {'self': 'https://api.nz-por-1.catalystcloud.io:5000/v3/users/1a2b3c4d5e1a2b3c4d5e1a2b3c4d5e1a/credentials/OS-EC2/e5d4c3b2a1e5d4c3b2a1e5d4c3b2a1e5'} |
  | project_id      | 1a2b3c4d5e1a2b3c4d5e1a2b3c4d5e1a                                                                                                                     |
  | secret          | 11aa22bb33cc44dd55ee11aa22bb33cc                                                                                                                     |
  | trust_id        | None                                                                                                                                                 |
  | user_id         | e5d4c3b2a1e5d4c3b2a1e5d4c3b2a1e5                                                                                                                     |
  +-----------------+------------------------------------------------------------------------------------------------------------------------------------------------------+

If you have an existing EC2 credential you'd like to use instead,
run ``openstack ec2 credentials list`` to fetch the access key ID and secret access key for the credendial.

.. code-block:: console

  $ openstack ec2 credentials list
  +----------------------------------+----------------------------------+----------------------------------+----------------------------------+
  | Access                           | Secret                           | Project ID                       | User ID                          |
  +----------------------------------+----------------------------------+----------------------------------+----------------------------------+
  | ee55dd44cc33bb2211aaee55dd44cc33 | 11aa22bb33cc44dd55ee11aa22bb33cc | 1a2b3c4d5e1a2b3c4d5e1a2b3c4d5e1a | e5d4c3b2a1e5d4c3b2a1e5d4c3b2a1e5 |
  +----------------------------------+----------------------------------+----------------------------------+----------------------------------+

Take the values for the ``access`` and ``secret`` fields, and use them to define the following environment variables
in your terminal session.

.. tabs::

  .. group-tab:: Linux / macOS

    .. code-block:: bash

      export AWS_ACCESS_KEY_ID=${access}
      export AWS_SECRET_ACCESS_KEY=${secret}

  .. group-tab:: Windows

    .. code-block:: powershell

      $Env:AWS_ACCESS_KEY_ID = "${access}"
      $Env:AWS_SECRET_ACCESS_KEY = "${secret}"

In addition, you will need to set the ``AWS_ENDPOINT_URL`` environment variable to tell the AWS CLI
the location of the Catalyst Cloud Object Storage S3 API.

.. include:: tutorial-scripts/endpoint-urls.rst

Once you have determined the correct endpoint URL to use, set the ``AWS_ENDPOINT_URL``
environment variable in your terminal session using the following command.

.. tabs::

  .. group-tab:: Linux / macOS

    .. code-block:: bash

      export AWS_ENDPOINT_URL=${endpoint_url}

  .. group-tab:: Windows

    .. code-block:: powershell

      $Env:AWS_ENDPOINT_URL = "${endpoint_url}"

At this point, you should now be able to use the AWS CLI to interact with Catalyst Cloud Object Storage.
