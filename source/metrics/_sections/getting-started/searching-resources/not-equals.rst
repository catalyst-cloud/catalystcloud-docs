You can search for all resources that have an attribute
that does *not* equal the provided value.

In this example, we are going to search for all instances
that have been deleted.

.. tabs::

  .. group-tab:: OpenStack CLI

    Run the following command:

    .. code-block:: bash

      openstack metric resource search --type instance "ended_at!=null"

    Example output:

    .. code-block:: console

      $ openstack metric resource search --type instance "ended_at!=null"
      +--------------------------------------+----------+----------------------------------+----------------------------------+--------------------------------------+----------------------------------+----------------------------------+----------------------------------+--------------+-------------------------------------------------------------------+------------------------+-----------+--------------------------------------+--------------+-------------+-----------+---------+------+
      | id                                   | type     | project_id                       | user_id                          | original_resource_id                 | started_at                       | ended_at                         | revision_start                   | revision_end | creator                                                           | display_name           | image_ref | flavor_id                            | server_group | flavor_name | os_distro | os_type | host |
      +--------------------------------------+----------+----------------------------------+----------------------------------+--------------------------------------+----------------------------------+----------------------------------+----------------------------------+--------------+-------------------------------------------------------------------+------------------------+-----------+--------------------------------------+--------------+-------------+-----------+---------+------+
      | f6ebbaef-33da-40bf-a339-ce7dd051a38d | instance | 9864e20f92ef47238becfe06b869d2ac | 517bcd700274432d96f43616ac1e37ea | f6ebbaef-33da-40bf-a339-ce7dd051a38d | 2025-02-13T23:38:53.690143+00:00 | 2025-06-17T03:05:34.743285+00:00 | 2025-06-17T03:05:42.873501+00:00 | None         | 42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d | test-instance-20250214 | None      | c093745c-a6c7-4792-9f3d-085e7782eca6 | None         | c1.c2r4     | None      | None    | None |
      +--------------------------------------+----------+----------------------------------+----------------------------------+--------------------------------------+----------------------------------+----------------------------------+----------------------------------+--------------+-------------------------------------------------------------------+------------------------+-----------+--------------------------------------+--------------+-------------+-----------+---------+------+

  .. group-tab:: Python Client

    Call the following method:

    .. code-block:: python

      gnocchi_client.resource.search(
          resource_type="instance",
          query={"!=": {"ended_at": None}},  # 'ne' can also be used.
      )

    Example output:

    .. code-block:: python

      >>> pprint(gnocchi_client.resource.search(resource_type="instance", query={"!=": {"ended_at": None}}))
      [{'created_by_project_id': '70d50fbf0c2148689aa2c319351e634d',
        'created_by_user_id': '42dcfd23b04a4006b9e2b08c0a835aeb',
        'creator': '42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d',
        'display_name': 'test-instance-20250214',
        'ended_at': '2025-06-17T03:05:34.743285+00:00',
        'flavor_id': 'c093745c-a6c7-4792-9f3d-085e7782eca6',
        'flavor_name': 'c1.c2r4',
        'host': None,
        'id': 'f6ebbaef-33da-40bf-a339-ce7dd051a38d',
        'image_ref': None,
        'metrics': {'compute.instance.booting.time': 'aea2e871-570e-4c14-9695-9b045578f2dd',
                    'cpu': 'f3a01650-a493-4700-b326-e4ab4f913931',
                    'disk.ephemeral.size': '0e03a783-ff6d-430a-b643-01be72932301',
                    'disk.root.size': '5e1068b4-fe1b-4568-8458-9358d4fe1fdf',
                    'instance': '03c55595-35fd-42e6-ac49-65979af7e52e',
                    'memory': 'f459aadc-cf54-48e5-b7b7-a7d72a740a10',
                    'vcpus': '54312c05-af08-4aaf-9194-13427ba5d31d'},
        'original_resource_id': 'f6ebbaef-33da-40bf-a339-ce7dd051a38d',
        'os_distro': None,
        'os_type': None,
        'project_id': '9864e20f92ef47238becfe06b869d2ac',
        'revision_end': None,
        'revision_start': '2025-06-17T03:05:42.873501+00:00',
        'server_group': None,
        'started_at': '2025-02-13T23:38:53.690143+00:00',
        'type': 'instance',
        'user_id': '517bcd700274432d96f43616ac1e37ea'}]

  .. group-tab:: cURL

    Example JSON payload (save this as ``payload.json``):

    .. code-block:: json

      {"!=": {"ended_at": null}}

    Make the following request:

    .. code-block:: bash

      curl -s \
           -X POST \
           -H "X-Auth-Token: ${OS_TOKEN}" \
           -H "Content-Type: application/json" \
           -H "Accept: application/json" \
           https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/search/resource/instance \
           --data-binary "@payload.json"

    Example output:

    .. code-block:: console

      $ curl -s -X POST -H "X-Auth-Token: ${OS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/search/resource/instance --data-binary "@payload.json" | jq
      [
        {
          "id": "f6ebbaef-33da-40bf-a339-ce7dd051a38d",
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
          "started_at": "2025-02-13T23:38:53.690143+00:00",
          "revision_start": "2025-06-17T03:05:42.873501+00:00",
          "ended_at": "2025-06-17T03:05:34.743285+00:00",
          "user_id": "517bcd700274432d96f43616ac1e37ea",
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "original_resource_id": "f6ebbaef-33da-40bf-a339-ce7dd051a38d",
          "type": "instance",
          "display_name": "test-instance-20250214",
          "image_ref": null,
          "flavor_id": "c093745c-a6c7-4792-9f3d-085e7782eca6",
          "server_group": null,
          "flavor_name": "c1.c2r4",
          "os_distro": null,
          "os_type": null,
          "host": null,
          "revision_end": null,
          "metrics": {
            "compute.instance.booting.time": "aea2e871-570e-4c14-9695-9b045578f2dd",
            "cpu": "f3a01650-a493-4700-b326-e4ab4f913931",
            "disk.ephemeral.size": "0e03a783-ff6d-430a-b643-01be72932301",
            "disk.root.size": "5e1068b4-fe1b-4568-8458-9358d4fe1fdf",
            "instance": "03c55595-35fd-42e6-ac49-65979af7e52e",
            "memory": "f459aadc-cf54-48e5-b7b7-a7d72a740a10",
            "vcpus": "54312c05-af08-4aaf-9194-13427ba5d31d"
          },
          "created_by_user_id": "42dcfd23b04a4006b9e2b08c0a835aeb",
          "created_by_project_id": "70d50fbf0c2148689aa2c319351e634d"
        }
      ]
