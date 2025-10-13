The Metrics Service not only keeps track of the
state of a :ref:`resource <metrics-resources>`,
it also keeps a history of all state and metadata
changes made to a resource and when those changes
were made.

Using the resource history API you are able to query the **revisions**
of a resource's state, either over its entire lifetime or for a specific time period.

.. note::

  Previous resource history revisions are guaranteed to be available for up to 90 days.

.. tabs::

  .. group-tab:: OpenStack CLI

    To get the history of a resource's metadata, run the following command:

    .. code-block:: bash

      openstack metric resource history --type ${resource_type} ${resource_id}

    Example output:

    .. code-block:: console

      $ openstack metric resource history --type instance af6b97d9-d172-4e06-b565-db1e97097340
      +--------------------------------------+----------+----------------------------------+----------------------------------+--------------------------------------+----------------------------------+----------+----------------------------------+----------------------------------+-------------------------------------------------------------------+---------------+-----------+--------------------------------------+--------------+-------------+-----------+---------+------+---------------------------------------------------------------------+
      | id                                   | type     | project_id                       | user_id                          | original_resource_id                 | started_at                       | ended_at | revision_start                   | revision_end                     | creator                                                           | display_name  | image_ref | flavor_id                            | server_group | flavor_name | os_distro | os_type | host | metrics                                                             |
      +--------------------------------------+----------+----------------------------------+----------------------------------+--------------------------------------+----------------------------------+----------+----------------------------------+----------------------------------+-------------------------------------------------------------------+---------------+-----------+--------------------------------------+--------------+-------------+-----------+---------+------+---------------------------------------------------------------------+
      | af6b97d9-d172-4e06-b565-db1e97097340 | instance | 9864e20f92ef47238becfe06b869d2ac | 517bcd700274432d96f43616ac1e37ea | af6b97d9-d172-4e06-b565-db1e97097340 | 2025-03-18T02:16:55.790609+00:00 | None     | 2025-03-18T02:16:55.790617+00:00 | 2025-03-18T22:00:58.683260+00:00 | 42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d | test-instance | None      | 28153197-6690-4485-9dbc-fc24489b0683 | None         | c1.c1r1     | None      | None    | None | compute.instance.booting.time: c418003f-5115-4bd3-a56e-270d90e26b2f |
      |                                      |          |                                  |                                  |                                      |                                  |          |                                  |                                  |                                                                   |               |           |                                      |              |             |           |         |      | cpu: 6febda4a-4a3f-485f-b6e2-5f94d55e39b0                           |
      |                                      |          |                                  |                                  |                                      |                                  |          |                                  |                                  |                                                                   |               |           |                                      |              |             |           |         |      | disk.ephemeral.size: d0add36c-6208-40d3-a8d0-2f5ab3a550bd           |
      |                                      |          |                                  |                                  |                                      |                                  |          |                                  |                                  |                                                                   |               |           |                                      |              |             |           |         |      | disk.root.size: b4e3d818-444b-46a9-b874-c82fd78e3a66                |
      |                                      |          |                                  |                                  |                                      |                                  |          |                                  |                                  |                                                                   |               |           |                                      |              |             |           |         |      | instance: 53c46abc-5336-49a8-ac76-fc5aed5e5154                      |
      |                                      |          |                                  |                                  |                                      |                                  |          |                                  |                                  |                                                                   |               |           |                                      |              |             |           |         |      | memory: 1e87f21e-2238-41f0-80fd-950e3e2f9bcf                        |
      |                                      |          |                                  |                                  |                                      |                                  |          |                                  |                                  |                                                                   |               |           |                                      |              |             |           |         |      | vcpus: 9d60abe7-b1d7-425d-8d89-6c0eecd38c47                         |
      | af6b97d9-d172-4e06-b565-db1e97097340 | instance | 9864e20f92ef47238becfe06b869d2ac | 517bcd700274432d96f43616ac1e37ea | af6b97d9-d172-4e06-b565-db1e97097340 | 2025-03-18T02:16:55.790609+00:00 | None     | 2025-03-18T22:00:58.683260+00:00 | None                             | 42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d | test-instance | None      | 28153197-6690-4485-9dbc-fc24489b0683 | None         | c1.c1r1     | ubuntu    | linux   | None | compute.instance.booting.time: c418003f-5115-4bd3-a56e-270d90e26b2f |
      |                                      |          |                                  |                                  |                                      |                                  |          |                                  |                                  |                                                                   |               |           |                                      |              |             |           |         |      | cpu: 6febda4a-4a3f-485f-b6e2-5f94d55e39b0                           |
      |                                      |          |                                  |                                  |                                      |                                  |          |                                  |                                  |                                                                   |               |           |                                      |              |             |           |         |      | disk.ephemeral.size: d0add36c-6208-40d3-a8d0-2f5ab3a550bd           |
      |                                      |          |                                  |                                  |                                      |                                  |          |                                  |                                  |                                                                   |               |           |                                      |              |             |           |         |      | disk.root.size: b4e3d818-444b-46a9-b874-c82fd78e3a66                |
      |                                      |          |                                  |                                  |                                      |                                  |          |                                  |                                  |                                                                   |               |           |                                      |              |             |           |         |      | instance: 53c46abc-5336-49a8-ac76-fc5aed5e5154                      |
      |                                      |          |                                  |                                  |                                      |                                  |          |                                  |                                  |                                                                   |               |           |                                      |              |             |           |         |      | memory: 1e87f21e-2238-41f0-80fd-950e3e2f9bcf                        |
      |                                      |          |                                  |                                  |                                      |                                  |          |                                  |                                  |                                                                   |               |           |                                      |              |             |           |         |      | vcpus: 9d60abe7-b1d7-425d-8d89-6c0eecd38c47                         |
      +--------------------------------------+----------+----------------------------------+----------------------------------+--------------------------------------+----------------------------------+----------+----------------------------------+----------------------------------+-------------------------------------------------------------------+---------------+-----------+--------------------------------------+--------------+-------------+-----------+---------+------+---------------------------------------------------------------------+

    Add ``-f json`` to output the response as JSON:

    .. code-block:: console

      $ openstack metric resource history --type instance af6b97d9-d172-4e06-b565-db1e97097340 -f json
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
          "host": null,
          "metrics": {
            "compute.instance.booting.time": "c418003f-5115-4bd3-a56e-270d90e26b2f",
            "cpu": "6febda4a-4a3f-485f-b6e2-5f94d55e39b0",
            "disk.ephemeral.size": "d0add36c-6208-40d3-a8d0-2f5ab3a550bd",
            "disk.root.size": "b4e3d818-444b-46a9-b874-c82fd78e3a66",
            "instance": "53c46abc-5336-49a8-ac76-fc5aed5e5154",
            "memory": "1e87f21e-2238-41f0-80fd-950e3e2f9bcf",
            "vcpus": "9d60abe7-b1d7-425d-8d89-6c0eecd38c47"
          }
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
          "host": null,
          "metrics": {
            "compute.instance.booting.time": "c418003f-5115-4bd3-a56e-270d90e26b2f",
            "cpu": "6febda4a-4a3f-485f-b6e2-5f94d55e39b0",
            "disk.ephemeral.size": "d0add36c-6208-40d3-a8d0-2f5ab3a550bd",
            "disk.root.size": "b4e3d818-444b-46a9-b874-c82fd78e3a66",
            "instance": "53c46abc-5336-49a8-ac76-fc5aed5e5154",
            "memory": "1e87f21e-2238-41f0-80fd-950e3e2f9bcf",
            "vcpus": "9d60abe7-b1d7-425d-8d89-6c0eecd38c47"
          }
        }
      ]

  .. group-tab:: Python Client

    Call the following method:

    .. code-block:: python

      gnocchi_client.resource.history("{resource_type}", "{resource_id}")

    Example output:

    .. code-block:: python

      >>> pprint(gnocchi_client.resource.history("instance", "af6b97d9-d172-4e06-b565-db1e97097340"))
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
        'revision_end': None,
        'revision_start': '2025-03-18T22:00:58.683260+00:00',
        'server_group': None,
        'started_at': '2025-03-18T02:16:55.790609+00:00',
        'type': 'instance',
        'user_id': '517bcd700274432d96f43616ac1e37ea'}]

  .. group-tab:: cURL

    Make the following request:

    .. code-block:: bash

      curl -s \
           -H "X-Auth-Token: ${OS_TOKEN}" \
           -H "Accept: application/json" \
           https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/resource/${resource_type}/${resource_id}/history

    Example output:

    .. code-block:: console

      $ curl -s -H "X-Auth-Token: ${OS_TOKEN}" -H "Accept: application/json" https://api.$(echo "${OS_REGION_NAME}" | tr '_' '-').catalystcloud.nz:8041/v1/resource/instance/af6b97d9-d172-4e06-b565-db1e97097340/history | jq
      [
        {
          "id": "af6b97d9-d172-4e06-b565-db1e97097340",
          "revision_end": "2025-03-18T22:00:58.683260+00:00",
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
          "started_at": "2025-03-18T02:16:55.790609+00:00",
          "revision_start": "2025-03-18T02:16:55.790617+00:00",
          "ended_at": null,
          "user_id": "517bcd700274432d96f43616ac1e37ea",
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "original_resource_id": "af6b97d9-d172-4e06-b565-db1e97097340",
          "type": "instance",
          "display_name": "test-instance",
          "image_ref": null,
          "flavor_id": "28153197-6690-4485-9dbc-fc24489b0683",
          "server_group": null,
          "flavor_name": "c1.c1r1",
          "os_distro": null,
          "os_type": null,
          "host": null,
          "metrics": {
            "compute.instance.booting.time": "c418003f-5115-4bd3-a56e-270d90e26b2f",
            "cpu": "6febda4a-4a3f-485f-b6e2-5f94d55e39b0",
            "disk.ephemeral.size": "d0add36c-6208-40d3-a8d0-2f5ab3a550bd",
            "disk.root.size": "b4e3d818-444b-46a9-b874-c82fd78e3a66",
            "instance": "53c46abc-5336-49a8-ac76-fc5aed5e5154",
            "memory": "1e87f21e-2238-41f0-80fd-950e3e2f9bcf",
            "vcpus": "9d60abe7-b1d7-425d-8d89-6c0eecd38c47"
          },
          "created_by_user_id": "42dcfd23b04a4006b9e2b08c0a835aeb",
          "created_by_project_id": "70d50fbf0c2148689aa2c319351e634d"
        },
        {
          "id": "af6b97d9-d172-4e06-b565-db1e97097340",
          "revision_end": null,
          "creator": "42dcfd23b04a4006b9e2b08c0a835aeb:70d50fbf0c2148689aa2c319351e634d",
          "started_at": "2025-03-18T02:16:55.790609+00:00",
          "revision_start": "2025-03-18T22:00:58.683260+00:00",
          "ended_at": null,
          "user_id": "517bcd700274432d96f43616ac1e37ea",
          "project_id": "9864e20f92ef47238becfe06b869d2ac",
          "original_resource_id": "af6b97d9-d172-4e06-b565-db1e97097340",
          "type": "instance",
          "display_name": "test-instance",
          "image_ref": null,
          "flavor_id": "28153197-6690-4485-9dbc-fc24489b0683",
          "server_group": null,
          "flavor_name": "c1.c1r1",
          "os_distro": "ubuntu",
          "os_type": "linux",
          "host": null,
          "metrics": {
            "compute.instance.booting.time": "c418003f-5115-4bd3-a56e-270d90e26b2f",
            "cpu": "6febda4a-4a3f-485f-b6e2-5f94d55e39b0",
            "disk.ephemeral.size": "d0add36c-6208-40d3-a8d0-2f5ab3a550bd",
            "disk.root.size": "b4e3d818-444b-46a9-b874-c82fd78e3a66",
            "instance": "53c46abc-5336-49a8-ac76-fc5aed5e5154",
            "memory": "1e87f21e-2238-41f0-80fd-950e3e2f9bcf",
            "vcpus": "9d60abe7-b1d7-425d-8d89-6c0eecd38c47"
          },
          "created_by_user_id": "42dcfd23b04a4006b9e2b08c0a835aeb",
          "created_by_project_id": "70d50fbf0c2148689aa2c319351e634d"
        }
      ]

In the above example, we can see that there are two revisions - the first revision
from when the resource was initially created, and a second revision modifying some
metadata values (in this case, setting ``os_type`` and ``os_distro``).

When performing resource history queries, revisions are returned in chronological
order by default. Revisions are also delineated using the ``revision_start`` and
``revision_end`` attributes, with ``revision_end`` on the previous revision always
matching ``revision_start`` on the next revision. The latest (current) revision
has a ``revision_end`` value of ``null``.
