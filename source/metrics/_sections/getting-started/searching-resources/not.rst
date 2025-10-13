Any condition can be negated using the ``not`` operator.

In this example, we are going to search for all instances
that do *not* have ``test-instance`` in their name.

.. tabs::

  .. group-tab:: OpenStack CLI

    Run the following command:

    .. code-block:: bash

      openstack metric resource search --type instance "not display_name like '%test-instance%'"

    Example output:

    .. code-block:: console

      $ openstack metric resource search --type instance "not display_name like '%test-instance%'"
      +--------------------------------------+----------+----------------------------------+----------------------------------+--------------------------------------+----------------------------------+----------+----------------------------------+--------------+-------------------------------------------------------------------+---------------------------------------------------------+-----------+--------------------------------------+--------------+-------------+-----------+---------+------+
      | id                                   | type     | project_id                       | user_id                          | original_resource_id                 | started_at                       | ended_at | revision_start                   | revision_end | creator                                                           | display_name                                            | image_ref | flavor_id                            | server_group | flavor_name | os_distro | os_type | host |
      +--------------------------------------+----------+----------------------------------+----------------------------------+--------------------------------------+----------------------------------+----------+----------------------------------+--------------+-------------------------------------------------------------------+---------------------------------------------------------+-----------+--------------------------------------+--------------+-------------+-----------+---------+------+
      | d2fa2bc2-184a-4694-85f1-4db10ad37cf3 | instance | 9864e20f92ef47238becfe06b869d2ac | 517bcd700274432d96f43616ac1e37ea | d2fa2bc2-184a-4694-85f1-4db10ad37cf3 | 2025-01-09T23:19:14.518004+00:00 | None     | 2025-05-23T00:42:36.409828+00:00 | None         | 42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d | test-cluster-4uexlwoysna4-default-worker-d1fbf004-p67wm | None      | c093745c-a6c7-4792-9f3d-085e7782eca6 | None         | c1.c2r4     | flatcar   | linux   | None |
      | 6040b4a8-b951-485b-88a6-422eb3f278dd | instance | 9864e20f92ef47238becfe06b869d2ac | 517bcd700274432d96f43616ac1e37ea | 6040b4a8-b951-485b-88a6-422eb3f278dd | 2025-01-09T23:19:14.090443+00:00 | None     | 2025-05-26T01:31:44.486588+00:00 | None         | 42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d | test-cluster-4uexlwoysna4-control-plane-2b817ab5-hlxnd  | None      | c093745c-a6c7-4792-9f3d-085e7782eca6 | None         | c1.c2r4     | flatcar   | linux   | None |
      +--------------------------------------+----------+----------------------------------+----------------------------------+--------------------------------------+----------------------------------+----------+----------------------------------+--------------+-------------------------------------------------------------------+---------------------------------------------------------+-----------+--------------------------------------+--------------+-------------+-----------+---------+------+

  .. group-tab:: Python Client

    Call the following method:

    .. code-block:: python

      gnocchi_client.resource.search(
          resource_type="instance",
          query={"not": {"like": {"display_name": "%test-instance%"}}},
      )

    Example output:

    .. code-block:: python

      >>> pprint(gnocchi_client.resource.search(resource_type="instance", query={"not": {"like": {"display_name": "%test-instance%"}}}))
      [{'created_by_project_id': '70d50fbf0c2148689aa2c319351e634d',
        'created_by_user_id': '42dcfd23b04a4006b9e2b08c0a835aeb',
        'creator': '42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d',
        'display_name': 'test-cluster-4uexlwoysna4-default-worker-d1fbf004-p67wm',
        'ended_at': None,
        'flavor_id': 'c093745c-a6c7-4792-9f3d-085e7782eca6',
        'flavor_name': 'c1.c2r4',
        'host': None,
        'id': 'd2fa2bc2-184a-4694-85f1-4db10ad37cf3',
        'image_ref': None,
        'metrics': {'compute.instance.booting.time': '4bcfb861-79a5-447c-acb2-ad412fbfb9b5',
                    'cpu': 'dd42ae93-402c-4df2-8ecb-c649fdf33c77',
                    'disk.ephemeral.size': '77497629-cace-4224-86ca-1b56c437d341',
                    'disk.root.size': '3fd2aa67-cd4c-4720-91b6-26c8b5ff1316',
                    'instance': '375d6e09-083d-439a-b038-88bae7af1259',
                    'memory': 'a02af497-3bbe-421c-9ac0-32e323c26b57',
                    'vcpus': '6b91d233-ec0b-496a-9870-a0d8a33f6bb0'},
        'original_resource_id': 'd2fa2bc2-184a-4694-85f1-4db10ad37cf3',
        'os_distro': 'flatcar',
        'os_type': 'linux',
        'project_id': '9864e20f92ef47238becfe06b869d2ac',
        'revision_end': None,
        'revision_start': '2025-05-23T00:42:36.409828+00:00',
        'server_group': None,
        'started_at': '2025-01-09T23:19:14.518004+00:00',
        'type': 'instance',
        'user_id': '517bcd700274432d96f43616ac1e37ea'},
       {'created_by_project_id': '70d50fbf0c2148689aa2c319351e634d',
        'created_by_user_id': '42dcfd23b04a4006b9e2b08c0a835aeb',
        'creator': '42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d',
        'display_name': 'test-cluster-4uexlwoysna4-control-plane-2b817ab5-hlxnd',
        'ended_at': None,
        'flavor_id': 'c093745c-a6c7-4792-9f3d-085e7782eca6',
        'flavor_name': 'c1.c2r4',
        'host': None,
        'id': '6040b4a8-b951-485b-88a6-422eb3f278dd',
        'image_ref': None,
        'metrics': {'compute.instance.booting.time': 'c7730e2a-b536-45d4-85a8-46d74fa40bbf',
                    'cpu': '54166b0a-7a93-4e26-acfd-3939578a937c',
                    'disk.ephemeral.size': '567748b2-9507-4faa-bf6c-dc22b3431ca1',
                    'disk.root.size': '2c2d9da6-16fc-44a6-ad0c-b9dbf0e7c278',
                    'instance': '2b00d300-459c-49c5-9a22-8bbe546c1326',
                    'memory': '1ab76159-718a-45c8-9fab-3f4cbf189671',
                    'vcpus': '9a1f3735-03c3-4d81-9f31-2f09bd1009d2'},
        'original_resource_id': '6040b4a8-b951-485b-88a6-422eb3f278dd',
        'os_distro': 'flatcar',
        'os_type': 'linux',
        'project_id': '9864e20f92ef47238becfe06b869d2ac',
        'revision_end': None,
        'revision_start': '2025-05-26T01:31:44.486588+00:00',
        'server_group': None,
        'started_at': '2025-01-09T23:19:14.090443+00:00',
        'type': 'instance',
        'user_id': '517bcd700274432d96f43616ac1e37ea'}]

  .. group-tab:: cURL

    Example JSON payload (save this as ``payload.json``):

    .. code-block:: json

      {"not": {"like": {"display_name": "%test-instance%"}}}

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
          "id": "d2fa2bc2-184a-4694-85f1-4db10ad37cf3",
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
          "started_at": "2025-01-09T23:19:14.518004+00:00",
          "revision_start": "2025-05-23T00:42:36.409828+00:00",
          "ended_at": null,
          "user_id": "517bcd700274432d96f43616ac1e37ea",
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "original_resource_id": "d2fa2bc2-184a-4694-85f1-4db10ad37cf3",
          "type": "instance",
          "display_name": "test-cluster-4uexlwoysna4-default-worker-d1fbf004-p67wm",
          "image_ref": null,
          "flavor_id": "c093745c-a6c7-4792-9f3d-085e7782eca6",
          "server_group": null,
          "flavor_name": "c1.c2r4",
          "os_distro": "flatcar",
          "os_type": "linux",
          "host": null,
          "revision_end": null,
          "metrics": {
            "compute.instance.booting.time": "4bcfb861-79a5-447c-acb2-ad412fbfb9b5",
            "cpu": "dd42ae93-402c-4df2-8ecb-c649fdf33c77",
            "disk.ephemeral.size": "77497629-cace-4224-86ca-1b56c437d341",
            "disk.root.size": "3fd2aa67-cd4c-4720-91b6-26c8b5ff1316",
            "instance": "375d6e09-083d-439a-b038-88bae7af1259",
            "memory": "a02af497-3bbe-421c-9ac0-32e323c26b57",
            "vcpus": "6b91d233-ec0b-496a-9870-a0d8a33f6bb0"
          },
          "created_by_user_id": "42dcfd23b04a4006b9e2b08c0a835aeb",
          "created_by_project_id": "70d50fbf0c2148689aa2c319351e634d"
        },
        {
          "id": "6040b4a8-b951-485b-88a6-422eb3f278dd",
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
          "started_at": "2025-01-09T23:19:14.090443+00:00",
          "revision_start": "2025-05-26T01:31:44.486588+00:00",
          "ended_at": null,
          "user_id": "517bcd700274432d96f43616ac1e37ea",
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "original_resource_id": "6040b4a8-b951-485b-88a6-422eb3f278dd",
          "type": "instance",
          "display_name": "test-cluster-4uexlwoysna4-control-plane-2b817ab5-hlxnd",
          "image_ref": null,
          "flavor_id": "c093745c-a6c7-4792-9f3d-085e7782eca6",
          "server_group": null,
          "flavor_name": "c1.c2r4",
          "os_distro": "flatcar",
          "os_type": "linux",
          "host": null,
          "revision_end": null,
          "metrics": {
            "compute.instance.booting.time": "c7730e2a-b536-45d4-85a8-46d74fa40bbf",
            "cpu": "54166b0a-7a93-4e26-acfd-3939578a937c",
            "disk.ephemeral.size": "567748b2-9507-4faa-bf6c-dc22b3431ca1",
            "disk.root.size": "2c2d9da6-16fc-44a6-ad0c-b9dbf0e7c278",
            "instance": "2b00d300-459c-49c5-9a22-8bbe546c1326",
            "memory": "1ab76159-718a-45c8-9fab-3f4cbf189671",
            "vcpus": "9a1f3735-03c3-4d81-9f31-2f09bd1009d2"
          },
          "created_by_user_id": "42dcfd23b04a4006b9e2b08c0a835aeb",
          "created_by_project_id": "70d50fbf0c2148689aa2c319351e634d"
        }
      ]
