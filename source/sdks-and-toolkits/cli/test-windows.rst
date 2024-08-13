To test that everything is working correctly, run the following command:

.. code-block:: powershell

  openstack project show $Env:OS_PROJECT_ID

The details of your project should be output to your terminal.

.. code-block:: text

  > openstack project show $Env:OS_PROJECT_ID
  +-------------+----------------------------------+
  | Field       | Value                            |
  +-------------+----------------------------------+
  | created_on  | 2022-09-29T01:26:41              |
  | description |                                  |
  | domain_id   | default                          |
  | enabled     | True                             |
  | id          | 1a2b3c4d5e1a2b3c4d5e1a2b3c4d5e1a |
  | is_domain   | False                            |
  | name        | example.com                      |
  | parent_id   | default                          |
  | signup_type | individual                       |
  | tags        | []                               |
  +-------------+----------------------------------+
