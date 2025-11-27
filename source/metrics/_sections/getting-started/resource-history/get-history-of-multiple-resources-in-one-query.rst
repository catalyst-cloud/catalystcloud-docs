The history of multiple resources can be returned in a single query
using the :ref:`Resource Search <metrics-searching-resources>` API
with the ``history`` flag.

The below example fetches the history of all instances that existed
within a defined time period.

.. tabs::

  .. group-tab:: OpenStack CLI

    Run the following command:

    .. code-block:: bash

      resource_type="instance"
      start="2025-03-18T00:00:00+00:00"
      stop="2025-03-18T12:00:00+00:00"
      openstack metric resource search --type ${resource_type} "revision_start<'${stop}' and (revision_end>='${start}' or revision_end=null)" --history

    Example output:

    .. code-block:: console

      $ openstack metric resource search --type instance "revision_start<'2025-03-18T12:00:00+00:00' and (revision_end>='2025-03-18T00:00:00+00:00' or revision_end=null)" --history
      +--------------------------------------+----------+----------------------------------+----------------------------------+--------------------------------------+----------------------------------+----------+----------------------------------+----------------------------------+-------------------------------------------------------------------+-------------------+-----------+--------------------------------------+--------------+-----------------+-----------+---------+------+
      | id                                   | type     | project_id                       | user_id                          | original_resource_id                 | started_at                       | ended_at | revision_start                   | revision_end                     | creator                                                           | display_name      | image_ref | flavor_id                            | server_group | flavor_name     | os_distro | os_type | host |
      +--------------------------------------+----------+----------------------------------+----------------------------------+--------------------------------------+----------------------------------+----------+----------------------------------+----------------------------------+-------------------------------------------------------------------+-------------------+-----------+--------------------------------------+--------------+-----------------+-----------+---------+------+
      | af6b97d9-d172-4e06-b565-db1e97097340 | instance | 9864e20f92ef47238becfe06b869d2ac | 517bcd700274432d96f43616ac1e37ea | af6b97d9-d172-4e06-b565-db1e97097340 | 2025-03-18T02:16:55.790609+00:00 | None     | 2025-03-18T02:16:55.790617+00:00 | 2025-03-18T22:00:58.683260+00:00 | 42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d | test-instance     | None      | 28153197-6690-4485-9dbc-fc24489b0683 | None         | c1.c1r1         | None      | None    | None |
      | af6b97d9-d172-4e06-b565-db1e97097340 | instance | 9864e20f92ef47238becfe06b869d2ac | 517bcd700274432d96f43616ac1e37ea | af6b97d9-d172-4e06-b565-db1e97097340 | 2025-03-18T02:16:55.790609+00:00 | None     | 2025-03-18T22:00:58.683260+00:00 | null                             | 42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d | test-instance     | None      | 28153197-6690-4485-9dbc-fc24489b0683 | None         | c1.c1r1         | ubuntu    | linux   | None |
      | 054c7b9c-1560-4a52-8e83-dddb6a3de291 | instance | 9864e20f92ef47238becfe06b869d2ac | 517bcd700274432d96f43616ac1e37ea | 054c7b9c-1560-4a52-8e83-dddb6a3de291 | 2025-03-18T02:16:55.790609+00:00 | None     | 2025-03-18T02:16:55.790617+00:00 | 2025-03-18T22:00:58.683260+00:00 | 42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d | test-instance-gpu | None      | feed34b8-25e2-435d-b49b-eba449f389dc | None         | c3-gpu.c24r96g1 | None      | None    | None |
      | 054c7b9c-1560-4a52-8e83-dddb6a3de291 | instance | 9864e20f92ef47238becfe06b869d2ac | 517bcd700274432d96f43616ac1e37ea | 054c7b9c-1560-4a52-8e83-dddb6a3de291 | 2025-03-18T02:16:55.790609+00:00 | None     | 2025-03-18T22:00:58.683260+00:00 | null                             | 42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d | test-instance-gpu | None      | feed34b8-25e2-435d-b49b-eba449f389dc | None         | c3-gpu.c24r96g1 | ubuntu    | linux   | None |
      +--------------------------------------+----------+----------------------------------+----------------------------------+--------------------------------------+----------------------------------+----------+----------------------------------+----------------------------------+-------------------------------------------------------------------+-------------------+-----------+--------------------------------------+--------------+-----------------+-----------+---------+------+

    Add ``-f json`` to output the response as JSON:

    .. code-block:: console

      $ openstack metric resource search --type instance "revision_start<'2025-03-18T12:00:00+00:00' and (revision_end>='2025-03-18T00:00:00+00:00' or revision_end=null)" --history -f json
      [
        {
          "id": "af6b97d9-d172-4e06-b565-db1e97097340",
          "type": "instance",
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "user_id": "517bcd700274432d96f43616ac1e37ea",
          "original_resource_id": "af6b97d9-d172-4e06-b565-db1e97097340",
          "started_at": "2025-03-18T02:16:55.790609+00:00",
          "ended_at": null,
          "revision_start": "2025-03-18T02:16:55.790617+00:00",
          "revision_end": "2025-03-18T22:00:58.683260+00:00",
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
          "display_name": "test-instance",
          "image_ref": null,
          "flavor_id": "28153197-6690-4485-9dbc-fc24489b0683",
          "server_group": null,
          "flavor_name": "c1.c1r1",
          "os_distro": null,
          "os_type": null,
          "host": null
        },
        {
          "id": "af6b97d9-d172-4e06-b565-db1e97097340",
          "type": "instance",
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "user_id": "517bcd700274432d96f43616ac1e37ea",
          "original_resource_id": "af6b97d9-d172-4e06-b565-db1e97097340",
          "started_at": "2025-03-18T02:16:55.790609+00:00",
          "ended_at": null,
          "revision_start": "2025-03-18T22:00:58.683260+00:00",
          "revision_end": null,
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
          "display_name": "test-instance",
          "image_ref": null,
          "flavor_id": "28153197-6690-4485-9dbc-fc24489b0683",
          "server_group": null,
          "flavor_name": "c1.c1r1",
          "os_distro": "ubuntu",
          "os_type": "linux",
          "host": null
        },
        {
          "id": "054c7b9c-1560-4a52-8e83-dddb6a3de291",
          "type": "instance",
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "user_id": "517bcd700274432d96f43616ac1e37ea",
          "original_resource_id": "054c7b9c-1560-4a52-8e83-dddb6a3de291",
          "started_at": "2025-03-18T02:16:55.790609+00:00",
          "ended_at": null,
          "revision_start": "2025-03-18T02:16:55.790617+00:00",
          "revision_end": "2025-03-18T22:00:58.683260+00:00",
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
          "display_name": "test-instance-gpu",
          "image_ref": null,
          "flavor_id": "28153197-6690-4485-9dbc-fc24489b0683",
          "server_group": null,
          "flavor_name": "c1.c1r1",
          "os_distro": null,
          "os_type": null,
          "host": null
        },
        {
          "id": "054c7b9c-1560-4a52-8e83-dddb6a3de291",
          "type": "instance",
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "user_id": "517bcd700274432d96f43616ac1e37ea",
          "original_resource_id": "054c7b9c-1560-4a52-8e83-dddb6a3de291",
          "started_at": "2025-03-18T02:16:55.790609+00:00",
          "ended_at": null,
          "revision_start": "2025-03-18T22:00:58.683260+00:00",
          "revision_end": null,
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
          "display_name": "test-instance-gpu",
          "image_ref": null,
          "flavor_id": "28153197-6690-4485-9dbc-fc24489b0683",
          "server_group": null,
          "flavor_name": "c1.c1r1",
          "os_distro": "ubuntu",
          "os_type": "linux",
          "host": null
        }
      ]

  .. group-tab:: Python Client

    Call the following method:

    .. code-block:: python
      :emphasize-lines: 20

      resource_type = "instance"
      start = "2025-03-18T00:00:00+00:00"
      stop = "2025-03-18T12:00:00+00:00"
      gnocchi_client.resource.search(
          resource_type=resource_type,
          query={
              "and": [
                  # Filter revisions created after the end of the window.
                  {"<": {"revision_start": stop}},
                  {
                      "or": [
                          # Filter revisions ended before the start of the window.
                          {">=": {"revision_end": start}},
                          # Include the latest revision, if started before the end of the window.
                          {"=": {"revision_end": None}},
                      ],
                  },
              ],
          },
          history=True,
      )

    Example output:

    .. code-block:: python

      >>> resource_type = "instance"
      >>> start = "2025-03-18T00:00:00+00:00"
      >>> stop = "2025-03-18T12:00:00+00:00"
      >>> pprint(gnocchi_client.resource.search(
      ...     resource_type=resource_type,
      ...     query={
      ...         "and": [
      ...             # Filter revisions created after the end of the window.
      ...             {"<": {"revision_start": stop}},
      ...             {
      ...                 "or": [
      ...                     # Filter revisions ended before the start of the window.
      ...                     {">=": {"revision_end": start}},
      ...                     # Include the latest revision, if started before the end of the window.
      ...                     {"=": {"revision_end": None}},
      ...                 ],
      ...             },
      ...         ],
      ...     },
      ...     history=True,
      ... ))
      [{'created_by_project_id': '70d50fbf0c2148689aa2c319351e634d',
        'created_by_user_id': '42dcfd23b04a4006b9e2b08c0a835aeb',
        'creator': '42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d',
        'display_name': 'test-instance',
        'ended_at': None,
        'flavor_id': '28153197-6690-4485-9dbc-fc24489b0683',
        'flavor_name': 'c1.c1r1',
        'host': None,
        'id': 'af6b97d9-d172-4e06-b565-db1e97097340',
        'image_ref': None,
        'metrics': {'compute.instance.booting.time': 'c418003f-5115-4bd3-a56e-270d90e26b2f',
                    'cpu': '6febda4a-4a3f-485f-b6e2-5f94d55e39b0',
                    'disk.ephemeral.size': 'd0add36c-6208-40d3-a8d0-2f5ab3a550bd',
                    'disk.root.size': 'b4e3d818-444b-46a9-b874-c82fd78e3a66',
                    'instance': '53c46abc-5336-49a8-ac76-fc5aed5e5154',
                    'memory': '1e87f21e-2238-41f0-80fd-950e3e2f9bcf',
                    'vcpus': '9d60abe7-b1d7-425d-8d89-6c0eecd38c47'},
        'original_resource_id': 'af6b97d9-d172-4e06-b565-db1e97097340',
        'os_distro': None,
        'os_type': None,
        'project_id': '9864e20f92ef47238becfe06b869d2ac',
        'revision_end': '2025-03-18T22:00:58.683260+00:00',
        'revision_start': '2025-03-18T02:16:55.790617+00:00',
        'server_group': None,
        'started_at': '2025-03-18T02:16:55.790609+00:00',
        'type': 'instance',
        'user_id': '517bcd700274432d96f43616ac1e37ea'},
       {'created_by_project_id': '70d50fbf0c2148689aa2c319351e634d',
        'created_by_user_id': '42dcfd23b04a4006b9e2b08c0a835aeb',
        'creator': '42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d',
        'display_name': 'test-instance',
        'ended_at': None,
        'flavor_id': '28153197-6690-4485-9dbc-fc24489b0683',
        'flavor_name': 'c1.c1r1',
        'host': None,
        'id': 'af6b97d9-d172-4e06-b565-db1e97097340',
        'image_ref': None,
        'metrics': {'compute.instance.booting.time': 'c418003f-5115-4bd3-a56e-270d90e26b2f',
                    'cpu': '6febda4a-4a3f-485f-b6e2-5f94d55e39b0',
                    'disk.ephemeral.size': 'd0add36c-6208-40d3-a8d0-2f5ab3a550bd',
                    'disk.root.size': 'b4e3d818-444b-46a9-b874-c82fd78e3a66',
                    'instance': '53c46abc-5336-49a8-ac76-fc5aed5e5154',
                    'memory': '1e87f21e-2238-41f0-80fd-950e3e2f9bcf',
                    'vcpus': '9d60abe7-b1d7-425d-8d89-6c0eecd38c47'},
        'original_resource_id': 'af6b97d9-d172-4e06-b565-db1e97097340',
        'os_distro': 'ubuntu',
        'os_type': 'linux',
        'project_id': '9864e20f92ef47238becfe06b869d2ac',
        'revision_end': null,
        'revision_start': '2025-03-18T22:00:58.683260+00:00',
        'server_group': None,
        'started_at': '2025-03-18T02:16:55.790609+00:00',
        'type': 'instance',
        'user_id': '517bcd700274432d96f43616ac1e37ea'},
       {'created_by_project_id': '70d50fbf0c2148689aa2c319351e634d',
        'created_by_user_id': '42dcfd23b04a4006b9e2b08c0a835aeb',
        'creator': '42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d',
        'display_name': 'test-instance-gpu',
        'ended_at': None,
        'flavor_id': 'feed34b8-25e2-435d-b49b-eba449f389dc',
        'flavor_name': 'c1.c1r1',
        'host': None,
        'id': '054c7b9c-1560-4a52-8e83-dddb6a3de291',
        'image_ref': None,
        'metrics': {'compute.instance.booting.time': 'c418003f-5115-4bd3-a56e-270d90e26b2f',
                    'cpu': '6febda4a-4a3f-485f-b6e2-5f94d55e39b0',
                    'disk.ephemeral.size': 'd0add36c-6208-40d3-a8d0-2f5ab3a550bd',
                    'disk.root.size': 'b4e3d818-444b-46a9-b874-c82fd78e3a66',
                    'instance': '53c46abc-5336-49a8-ac76-fc5aed5e5154',
                    'memory': '1e87f21e-2238-41f0-80fd-950e3e2f9bcf',
                    'vcpus': '9d60abe7-b1d7-425d-8d89-6c0eecd38c47'},
        'original_resource_id': '054c7b9c-1560-4a52-8e83-dddb6a3de291',
        'os_distro': None,
        'os_type': None,
        'project_id': '9864e20f92ef47238becfe06b869d2ac',
        'revision_end': '2025-03-18T22:00:58.683260+00:00',
        'revision_start': '2025-03-18T02:16:55.790617+00:00',
        'server_group': None,
        'started_at': '2025-03-18T02:16:55.790609+00:00',
        'type': 'instance',
        'user_id': '517bcd700274432d96f43616ac1e37ea'},
       {'created_by_project_id': '70d50fbf0c2148689aa2c319351e634d',
        'created_by_user_id': '42dcfd23b04a4006b9e2b08c0a835aeb',
        'creator': '42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d',
        'display_name': 'test-instance-gpu',
        'ended_at': None,
        'flavor_id': 'feed34b8-25e2-435d-b49b-eba449f389dc',
        'flavor_name': 'c3-gpu.c24r96g1',
        'host': None,
        'id': '054c7b9c-1560-4a52-8e83-dddb6a3de291',
        'image_ref': None,
        'metrics': {'compute.instance.booting.time': 'c418003f-5115-4bd3-a56e-270d90e26b2f',
                    'cpu': '6febda4a-4a3f-485f-b6e2-5f94d55e39b0',
                    'disk.ephemeral.size': 'd0add36c-6208-40d3-a8d0-2f5ab3a550bd',
                    'disk.root.size': 'b4e3d818-444b-46a9-b874-c82fd78e3a66',
                    'instance': '53c46abc-5336-49a8-ac76-fc5aed5e5154',
                    'memory': '1e87f21e-2238-41f0-80fd-950e3e2f9bcf',
                    'vcpus': '9d60abe7-b1d7-425d-8d89-6c0eecd38c47'},
        'original_resource_id': '054c7b9c-1560-4a52-8e83-dddb6a3de291',
        'os_distro': 'ubuntu',
        'os_type': 'linux',
        'project_id': '9864e20f92ef47238becfe06b869d2ac',
        'revision_end': null,
        'revision_start': '2025-03-18T22:00:58.683260+00:00',
        'server_group': None,
        'started_at': '2025-03-18T02:16:55.790609+00:00',
        'type': 'instance',
        'user_id': '517bcd700274432d96f43616ac1e37ea'}]

  .. group-tab:: cURL

    First, save a file containing the request payload.

    Example JSON payload:

    .. code-block:: json

      {
        "and": [
          {"<": {"revision_start": "{stop}"}},
          {
            "or": [
              {">=": {"revision_end": "{start}"}},
              {"=": {"revision_end": null}}
            ]
          }
        ]
      }

    Populated with values (save as ``payload.json``):

    .. code-block:: json

      {
        "and": [
          {"<": {"revision_start": "2025-03-18T12:00:00+00:00"}},
          {
            "or": [
              {">=": {"revision_end": "2025-03-18T00:00:00+00:00"}},
              {"=": {"revision_end": null}}
            ]
          }
        ]
      }

    Make the following request:

    .. code-block:: bash
      :emphasize-lines: 7

      curl -s \
           -X POST \
           -H "X-Auth-Token: ${OS_TOKEN}" \
           -H "Content-Type: application/json" \
           -H "Accept: application/json" \
           https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/search/resource/instance \
           --url-query "history=true" \
           --data-binary "@payload.json"

    Example output:

    .. code-block:: console

      $ curl -s -X POST -H "X-Auth-Token: ${OS_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" "https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/search/resource/instance?history=true" --data-binary "@payload.json" | jq
      [
        {
          "id": "af6b97d9-d172-4e06-b565-db1e97097340",
          "type": "instance",
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "user_id": "517bcd700274432d96f43616ac1e37ea",
          "original_resource_id": "af6b97d9-d172-4e06-b565-db1e97097340",
          "started_at": "2025-03-18T02:16:55.790609+00:00",
          "ended_at": null,
          "revision_start": "2025-03-18T02:16:55.790617+00:00",
          "revision_end": "2025-03-18T22:00:58.683260+00:00",
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
          "display_name": "test-instance",
          "image_ref": null,
          "flavor_id": "28153197-6690-4485-9dbc-fc24489b0683",
          "server_group": null,
          "flavor_name": "c1.c1r1",
          "os_distro": null,
          "os_type": null,
          "host": null
        },
        {
          "id": "af6b97d9-d172-4e06-b565-db1e97097340",
          "type": "instance",
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "user_id": "517bcd700274432d96f43616ac1e37ea",
          "original_resource_id": "af6b97d9-d172-4e06-b565-db1e97097340",
          "started_at": "2025-03-18T02:16:55.790609+00:00",
          "ended_at": null,
          "revision_start": "2025-03-18T22:00:58.683260+00:00",
          "revision_end": null,
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
          "display_name": "test-instance",
          "image_ref": null,
          "flavor_id": "28153197-6690-4485-9dbc-fc24489b0683",
          "server_group": null,
          "flavor_name": "c1.c1r1",
          "os_distro": "ubuntu",
          "os_type": "linux",
          "host": null
        },
        {
          "id": "054c7b9c-1560-4a52-8e83-dddb6a3de291",
          "type": "instance",
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "user_id": "517bcd700274432d96f43616ac1e37ea",
          "original_resource_id": "054c7b9c-1560-4a52-8e83-dddb6a3de291",
          "started_at": "2025-03-18T02:16:55.790609+00:00",
          "ended_at": null,
          "revision_start": "2025-03-18T02:16:55.790617+00:00",
          "revision_end": "2025-03-18T22:00:58.683260+00:00",
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
          "display_name": "test-instance-gpu",
          "image_ref": null,
          "flavor_id": "28153197-6690-4485-9dbc-fc24489b0683",
          "server_group": null,
          "flavor_name": "c1.c1r1",
          "os_distro": null,
          "os_type": null,
          "host": null
        },
        {
          "id": "054c7b9c-1560-4a52-8e83-dddb6a3de291",
          "type": "instance",
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "user_id": "517bcd700274432d96f43616ac1e37ea",
          "original_resource_id": "054c7b9c-1560-4a52-8e83-dddb6a3de291",
          "started_at": "2025-03-18T02:16:55.790609+00:00",
          "ended_at": null,
          "revision_start": "2025-03-18T22:00:58.683260+00:00",
          "revision_end": null,
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
          "display_name": "test-instance-gpu",
          "image_ref": null,
          "flavor_id": "28153197-6690-4485-9dbc-fc24489b0683",
          "server_group": null,
          "flavor_name": "c1.c1r1",
          "os_distro": "ubuntu",
          "os_type": "linux",
          "host": null
        }
      ]
