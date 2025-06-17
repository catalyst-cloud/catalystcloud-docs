# Application Credentials

Application Credentials allows you to give machine accounts the ability
to authenticate against Catalyst Cloud without needing a full user
account. Application Credentials can be given the same or a subset of
the roles of the user who creates them and an expiry time can be set.

## Creating an Application Credential

The openstack command line can be used to create an application
credential.

To create a credential with the same roles as your user and with a
generated secret then the command
`openstack application credential create <name>` will create one with
the given `<name>`:

``` bash
$ openstack application credential create cred1
+--------------+----------------------------------------------------------------------------------------+
| Field        | Value                                                                                  |
+--------------+----------------------------------------------------------------------------------------+
| description  | None                                                                                   |
| expires_at   | None                                                                                   |
| id           | b61580fb52e54909aab3************                                                       |
| name         | cred1                                                                                  |
| project_id   | 22d7e8ec60ec437f8b99************                                                       |
| roles        | project_admin _member_                                                                 |
| secret       | dqRk13A5HdekIyZAEdVoi9UjvvMvYkKgnRq16CwtG1VB86CLnkfkktkCGrYexkFwZFh1CPt3hDqwv5X3p6iing |
| unrestricted | False                                                                                  |
+--------------+----------------------------------------------------------------------------------------+
```

The option `--secret` is used to specify the secret.

The option `--role` can be used multiple times to define the roles
assigned to the credential.

The option `--description` sets a description for the credential.

The option `--expiration` sets an expiry time, in UTC, for the
credential. If this is not given then the credential does not expire.

``` bash
$ openstack application credential create cred2 --secret mysupersecret --description "Ansible CICD User" \
  --role _member_ --expiration "2024-03-08T00:00:00"
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| description  | Ansible CICD User                |
| expires_at   | 2024-03-08T00:00:00.000000       |
| id           | 342ddaab6f7643a5a60b80f8d727bd97 |
| name         | cred2                            |
| project_id   | 22d7e8ec60ec437f8b99************ |
| roles        | _member_                         |
| secret       | mysupersecret                    |
| unrestricted | False                            |
+--------------+----------------------------------+
```

## Using an Application Credential

Once the Application Credential is created then it can be used to
authenticate against Catalyst Cloud. Instead of providing a username
and password the machine user can authenticate using the application
credential ID and secret.

For example the following lists the servers running in the project:

``` bash
$ openstack server list --os-auth-url  https://api.nz-por-1.catalystcloud.io:5000  \
  --os-application-credential-secret mysupersecret \
  --os-application-credential-id 342ddaab6f7643a5a60b80f8d727bd97 \
  --os-auth-type v3applicationcredential
```

You can also obtain an authentication token and use that for further
operations:

``` bash
$ openstack token issue --os-auth-url  https://api.nz-por-1.catalystcloud.io:5000 \
  --os-application-credential-secret mysupersecret \
  --os-application-credential-id 342ddaab6f7643a5a60b80f8d727bd97  \
  --os-auth-type v3applicationcredential
```

The application credential can be used in the clouds.yaml file:

``` yaml
clouds:
  catalystcloud:
    auth_type: v3applicationcredential
    auth:
      auth_url: https://api.nz-por-1.catalystcloud.io:5000
      application_credential_id: 342ddaab6f7643a5a60b80f8d727bd97
      application_credential_secret: mysupersecret
    region: nz-por-1
    identity_api_version: 3
```

### Roles

If you want to restrict the roles that the application credential has
then we need to specify the role by the following names:

  | Role               | Name in the Openstack command |
  |--------------------|-------------------------------|
  | Project admin      | project_admin                 |
  | Project moderator  | project_mod                   |
  | Project Member     | \_member\_                    |
  | Heat stack owner   | heat_stack_owner              |
  | Compute start/stop | compute_start_stop            |
  | Object storage     | object_storage                |
  | Auth only          | auth_only                     |

You can only give roles to an application credential that your user
already has. Even if the role you have has a super set of the
permissions the role you want the application credential to have, if the
role is not assigned to your user you can't give it to the application
credentials you create. For example, if you have the \_member\_ role
you can't create a credential with the compute_start_stop role even
though the \_member\_ role has all the permissions in the
compute_start_stop role, you would need to give assign your user the
compute_start_stop role first.

If you try to create an application credential with roles that you do
not have then the openstack command will return an error:

``` bash
$ openstack application credential create cred6 --secret mysupersecret /
  --description "Ansible CICD User" --role _member_ --role heat_stack_owner
Invalid input for field 'roles/1/id': 'heat_stack_owner' does not match '^[a-zA-Z0-9-]+$'

Failed validating 'pattern' in schema['properties']['roles']['items']['properties']['id']:
    {'maxLength': 64,
     'minLength': 1,
     'pattern': '^[a-zA-Z0-9-]+$',
     'type': 'string'}

On instance['roles'][1]['id']:
    'heat_stack_owner' (HTTP 400) (Request-ID: req-c0fd3576-e95e-4bd1-a247-466c72392de8)
```

## Rotating an Application Credential

To rotate an Application Credential the process is as follows. First
create a new application credential with a new name and new secret, then
update the application's configuration to use the new Application
Credential. Once all applications are using the new credential then you
can delete the old application credential.
