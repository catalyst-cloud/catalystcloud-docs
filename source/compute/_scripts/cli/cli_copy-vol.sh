
$ openstack server show <UUID_OR_NAME_OF_SERVER> | grep volumes_attached

| volumes_attached            | id='0a8f8181-5c92-4367-ae26-XXXXXXXXXXXX'                |

$ openstack volume create --source 0a8f8181-5c92-4367-ae26-XXXXXXXXXXXX <TEMPORARY_NAME>
